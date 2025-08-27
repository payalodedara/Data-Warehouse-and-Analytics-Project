
-- ==========clean and insert into silver layer================

-- ===============crm_cust_info================================
-- --------------------------------------------------------------

SET @batch_start_time = NOW();
SET @batch_end_time=null;

SELECT 'Starting data load silver layer...', @batch_start_time;

TRUNCATE TABLE silver.crm_cust_info;
insert into silver.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
select cst_id,
cst_key, 
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'S' then 'Single'
     when upper(trim(cst_marital_status)) = 'M' then 'Married'
     else 'n/a'
end cst_marital_status,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
     when upper(trim(cst_gndr)) = 'M' then 'Male'
     else 'n/a'
end cst_gndr,
STR_TO_DATE(cst_create_date, '%Y-%m-%d') AS cst_create_date
from (
select *, row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id is not null and STR_TO_DATE(cst_create_date, '%Y-%m-%d') IS NOT NULL
)t where flag_last = 1; 

-- ===============crm_prd_info================================
-- --------------------------------------------------------------

TRUNCATE TABLE silver.crm_prd_info;
insert into silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
select
prd_id, 
replace(substring(prd_key,1,5), '-', '_') as cat_id,
substring(prd_key,7, length(prd_key)) as prd_key,
prd_nm, 
ifnull(prd_cost, 0) as prd_cost,
case upper(trim(prd_line)) 
	 when 'M' then 'Mountain'
	 when 'R' then 'Road'
     when 'S' then 'Other Sales'
     when 'T' then 'Touring'
     else 'n/a'
end prd_line, 
str_to_date(prd_start_dt, '%Y-%m-%d') as prd_start_dt, 
date_sub(
        lead(str_to_date(prd_start_dt, '%Y-%m-%d')) over (partition by prd_key order by str_to_date(prd_start_dt, '%Y-%m-%d')), INTERVAL 1 DAY) AS prd_end_dt
from bronze.crm_prd_info;


-- ===============crm_sales_details================================
-- --------------------------------------------------------------

TRUNCATE TABLE silver.crm_sales_details;
insert into silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
select
sls_ord_num, 
sls_prd_key, 
sls_cust_id,
case when sls_order_dt = '0' or length(sls_order_dt) != 8 then null
     else str_to_date(sls_order_dt, '%Y%m%d')
end sls_order_dt,
case when sls_ship_dt = '0' or length(sls_ship_dt) != 8 then null
     else str_to_date(sls_ship_dt, '%Y%m%d')
end sls_ship_dt, 
case when sls_due_dt = '0' or length(sls_due_dt) != 8 then null
     else str_to_date(sls_due_dt, '%Y%m%d')
end sls_due_dt, 

case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
else sls_sales
end sls_sales,
sls_quantity,
case when sls_price is null or sls_price <= 0 then sls_sales div  nullif(sls_quantity,0)
else sls_price
end sls_price
from bronze.crm_sales_details;


-- ===============erp_cust_az12================================
-- --------------------------------------------------------------

TRUNCATE TABLE silver.erp_cust_az12;
insert into silver.erp_cust_az12(cid, Bdate, gen)
select
case when cid like 'NAS%' then substring(cid, 4, length(cid))
else cid
end cid,
case when Bdate > now() then null
else str_to_date(Bdate, '%Y-%m-%d')
end Bdate,
case when upper(trim(regexp_replace(gen, '\\s+', ''))) in ('F', 'FEMALE') then 'Female'
     when upper(trim(regexp_replace(gen, '\\s+', ''))) in ('M', 'MALE') then 'Male'
     else 'n/a'
end gen
from bronze.erp_cust_az12;

-- ===============erp_loc_a101================================
-- --------------------------------------------------------------

TRUNCATE TABLE silver.erp_loc_a101;
insert into silver.erp_loc_a101(cid, cntry)
select 
replace(cid, '-', '') cid,
case when regexp_replace(cntry, '\\s+', '') in ('US', 'USA') then 'United States'
     when regexp_replace(cntry, '\\s+', '') = 'DE' then 'Germany'
     when regexp_replace(cntry, '\\s+', '') = '' then 'n/a'
     else trim(regexp_replace(cntry, '\\s+', ''))
end cntry
from bronze.erp_loc_a101;


-- ===============erp_px_cat_g1v2================================
-- --------------------------------------------------------------

TRUNCATE TABLE silver.erp_px_cat_g1v2;
insert into silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
select 
id,
cat,
trim(regexp_replace(subcat, '\\s+', '')) subcat,
case when regexp_replace(maintenance, '\\s+', '') = 'Yes' then 'Yes'
     else 'No'
end maintenance
from bronze.erp_px_cat_g1v2
where id in (select cat_id from silver.crm_prd_info);

-- ------------------------------------------------------

SET @batch_end_time = NOW();
SELECT 'Data load finished at', @batch_end_time;

-- ====================================================================
