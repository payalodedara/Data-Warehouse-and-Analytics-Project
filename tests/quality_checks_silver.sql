/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer 
    - and may need to replace bronze to silver
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ============CHECK IN BRONZE, CORRECT AND CHECK AGAIN AFTER INSERTING INTO SILVER==================
-- expectation : no results

-- ===============crm_cust_info================================
-- changes required: cst_create_date date
-- ------------------------------------------------------------

--  Nulls or Duplicates in primary key (cst_id)

SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL;

-- check for unwanted space in firstname, lastname, gender, marital status

select cst_firstname
from bronze.crm_cust_info
where cst_firstname != trim(cst_firstname);

-- marital staus and gender types .......

select distinct cst_marital_status
from bronze.crm_cust_info;


-- Date almost verified, # convert to date formte

SELECT * FROM silver.crm_cust_info
WHERE cst_create_date IS NULL;


-- ===============crm_prd_info================================
-- changes required: prd_start_dt date, prd_end_dt date
-- ------------------------------------------------------------

-- prd_id, prd_key

SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 OR prd_id IS NULL;

-- check for unwanted space in prd_nm

select prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm);

-- check nulls or negative number in ptd_cost

select prd_cost
from silver.crm_prd_info
where prd_cost<0 or prd_cost is null;

-- check prd_line

select distinct prd_line
from silver.crm_prd_info;

-- check for invalid date orders

select * from silver.crm_prd_info
where prd_end_dt < prd_start_dt;

-- ===============crm_sales_details================================
-- 3 dates from varchar
-- sls_order_dt, sls_ship_dt, sls_due_dt  to date (change in silver layer DDL also)
-- ------------------------------------------------------------

-- check sls_ord_num

SELECT sls_ord_num
FROM bronze.crm_sales_details
where sls_ord_num != trim(sls_ord_num);

-- check sls_prd_key, sls_cust_id both are primary keys

SELECT sls_cust_id
FROM bronze.crm_sales_details
where sls_cust_id not in 
(select cst_id
from silver.crm_cust_info);

-- check order_date, ship_date, due_date

select sls_due_dt 
from bronze.crm_sales_details
where sls_due_dt = '0' or length(sls_due_dt) !=8;

-- invalide dates
select sls_order_dt, sls_ship_dt , sls_due_dt 
from silver.crm_sales_details
where sls_order_dt> sls_ship_dt or sls_order_dt> sls_due_dt;

-- sales, quantity, price

select sls_sales as old_sales, sls_quantity as old_q, sls_price as old_p, 
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
else sls_sales
end sls_sales,
sls_quantity,
case when sls_price is null or sls_price <= 0 then sls_sales div  nullif(sls_quantity,0)
else sls_price
end sls_price
-- select sls_sales as old_sales, sls_quantity as old_q, sls_price as old_p
from bronze.crm_sales_details
 where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price <=0;
 
 -- ------------------------
 
 select sls_sales, sls_quantity, sls_price
 from silver.crm_sales_details
 where sls_sales != sls_quantity * sls_price
 or sls_sales is null or sls_quantity is null or sls_price is null
 or sls_sales <=0 or sls_quantity <=0 or sls_price <=0;
 
 select * from bronze.crm_sales_details
 where sls_price = 0;
 
 -- ---------------------check tables-----------------------
 
select * from bronze.crm_cust_info;
select * from silver.crm_cust_info;
 
select * from bronze.crm_prd_info;
select * from silver.crm_prd_info;

select * from bronze.crm_sales_details;
select * from silver.crm_sales_details;


-- ===============erp_cust_az12================================
-- Bdate to date
-- ------------------------------------------------------------

-- cid
select cid, 
case when cid like 'NAS%' then substring(cid, 4, length(cid))
else cid
end cid
from bronze.erp_cust_az12;

-- Bdate (more then 100 yrs and future)

select Bdate
from bronze.erp_cust_az12
where str_to_date(Bdate, '%Y-%m-%d') < '1925-01-01' or Bdate > now();

-- gen

select distinct gen
from bronze.erp_cust_az12;

select gen
from bronze.erp_cust_az12
where upper(trim(gen))='F';

select gen
from bronze.erp_cust_az12
where upper(trim(regexp_replace(gen, '\\s+', ''))) = 'F';

select distinct gen,
case when upper(trim(regexp_replace(gen, '\\s+', ''))) in ('F', 'FEMALE') then 'Female'
     when upper(trim(regexp_replace(gen, '\\s+', ''))) in ('M', 'MALE') then 'Male'
     else 'n/a'
end gen
from bronze.erp_cust_az12;

select * from silver.erp_cust_az12;


-- ===============erp_cust_az12================================
-- ------------------------------------------------------------

-- cid

select cid,
replace(cid, '-', '') cid
from bronze.erp_loc_a101;

-- country

select distinct cntry
from bronze.erp_loc_a101;

select cntry
from bronze.erp_loc_a101
where cntry != trim(cntry);

select distinct cntry,
case when regexp_replace(cntry, '\\s+', '') in ('US', 'USA') then 'United States'
     when regexp_replace(cntry, '\\s+', '') = 'DE' then 'Germany'
     when regexp_replace(cntry, '\\s+', '') = '' then 'n/a'
     else trim(regexp_replace(cntry, '\\s+', ''))
end cntry
from bronze.erp_loc_a101;

select *
from bronze.erp_loc_a101
where trim(regexp_replace(cntry, '\\s+', '')) != cntry and trim(regexp_replace(cntry, '\\s+', '')) = 'Canada';

select * from silver.erp_loc_a101;


-- =============== erp_px_cat_g1v2 ================================
-- ------------------------------------------------------------

-- distinct cat, (subcat and maintenance) both issue 

select *  
from bronze.erp_px_cat_g1v2
where cat != trim(regexp_replace(cat, '\\s+', '')) or subcat != trim(regexp_replace(subcat, '\\s+', '')) or maintenance != trim(regexp_replace(maintenance, '\\s+', ''));

select distinct subcat
from bronze.erp_px_cat_g1v2
order by subcat;

select distinct maintenance,
case when regexp_replace(maintenance, '\\s+', '') = 'Yes' then 'Yes'
     else 'No'
end maintenance
from bronze.erp_px_cat_g1v2;

-- cid check with prd_key

select id
from bronze.erp_px_cat_g1v2
where id != regexp_replace(id, '\\s+', '');

select id
from bronze.erp_px_cat_g1v2
where id not in (select cat_id
    from silver.crm_prd_info);
    
-- mainternance check 

select *
from silver.erp_px_cat_g1v2
where maintenance= 'Yes';

-- ---------------------------------------------------------------------------------------------------------------
