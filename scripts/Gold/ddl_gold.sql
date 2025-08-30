/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


-- ==========view into gold layer================

-- ----------CREATE DIMENTION CUSTOMER------------------


drop view if exists gold.dim_customer;
create view gold.dim_customer as 
select 
row_number() over(order by cst_id) customer_key,
ci.cst_id customer_id, 
ci.cst_key customer_number, 
ci.cst_firstname first_name, 
ci.cst_lastname last_name, 
la.cntry country,
ci.cst_marital_status marital_status,
case when ci.cst_gndr != 'n/a' then cst_gndr
     else coalesce(ca.gen, 'n/a')
end gender,
ca.Bdate birthdate,
ci.cst_create_date create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca on ca.cid= ci.cst_key
left join silver.erp_loc_a101 la on la.cid= ci.cst_key;


-- ----------CREATE DIMENTION PRODUCT------------------

drop view if exists gold.dim_product;
create view gold.dim_product as
select
row_number() over(order by pn.prd_start_dt, pn.prd_key) product_key,
pn.prd_id product_id, 
pn.prd_key product_number,
pn.prd_nm product_name,
pn.cat_id category_id,
pc.cat category,
pc.subcat subcategory,
pc.maintenance,
pn.prd_cost product_cost, 
pn.prd_line product_line, 
pn.prd_start_dt start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc on pc.id= pn.cat_id
where prd_end_dt is null;        -- filter out historical data

-- ----------CREATE FACT SALES------------------

drop view if exists gold.fact_sales;
create view gold.fact_sales as
select
sd.sls_ord_num order_number, 
pr.product_key, 
cu.customer_key, 
sd.sls_order_dt order_date, 
sd.sls_ship_dt shipping_date, 
sd.sls_due_dt due_date, 
sd.sls_sales sales_amount, 
sd.sls_quantity quantity, 
sd.sls_price price
from silver.crm_sales_details sd
left join gold.dim_product pr on sd.sls_prd_key = pr.product_number
left join gold.dim_customer cu on sd.sls_cust_id= cu.customer_id;

-- -----------------------------------------------------------
