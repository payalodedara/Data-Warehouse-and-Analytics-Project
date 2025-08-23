/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
Parameters:
    All data inserted in varchar
	  This stored procedure does not accept any parameters or return any values.
===============================================================================
*/

-- SQL Load Scripts

SET @batch_start_time = NOW();
SET @batch_end_time=null;

SELECT 'Starting data load...', @batch_start_time;

TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cst_id, @cst_key, @cst_firstname, @cst_lastname, @cst_marital_status, @cst_gndr, @cst_create_date)
SET
  cst_id = NULLIF(@cst_id,''),
  cst_key = NULLIF(@cst_key,''),
  cst_firstname = NULLIF(@cst_firstname,''),
  cst_lastname = NULLIF(@cst_lastname,''),
  cst_marital_status = NULLIF(@cst_marital_status,''),
  cst_gndr = NULLIF(@cst_gndr,''),
  cst_create_date = NULLIF(@cst_create_date,'');
  

TRUNCATE TABLE bronze.crm_prd_info;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@prd_id, @prd_key, @prd_nm, @prd_cost, @prd_line, @prd_start_dt, @prd_end_dt)
SET
  prd_id = NULLIF(@prd_id,''),
  prd_key = NULLIF(@prd_key,''),
  prd_nm = NULLIF(@prd_nm,''),
  prd_cost = NULLIF(@prd_cost,''),
  prd_line = NULLIF(@prd_line,''),
  prd_start_dt = NULLIF(@prd_start_dt,''),
  prd_end_dt = NULLIF(@prd_end_dt,'');
  

TRUNCATE TABLE bronze.crm_sales_details;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@sls_ord_num, @sls_prd_key, @sls_cust_id, @sls_order_dt, @sls_ship_dt, @sls_due_dt, @sls_sales, @sls_quantity, @sls_price)
SET
  sls_ord_num  = NULLIF(@sls_ord_num,''),
  sls_prd_key  = NULLIF(@sls_prd_key,''),
  sls_cust_id  = NULLIF(@sls_cust_id,''),
  sls_order_dt = NULLIF(@sls_order_dt,''),
  sls_ship_dt  = NULLIF(@sls_ship_dt,''),
  sls_due_dt   = NULLIF(@sls_due_dt,''),
  sls_sales    = NULLIF(@sls_sales,''),
  sls_quantity = NULLIF(@sls_quantity,''),
  sls_price    = NULLIF(@sls_price,'');


TRUNCATE TABLE bronze.erp_cust_az12;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cid, @Bdate, @gen)
SET
  cid   = NULLIF(@cid,''),
  Bdate = NULLIF(@Bdate,''),
  gen   = NULLIF(@gen,'');
  
  
TRUNCATE TABLE bronze.erp_loc_a101;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@cid, @cntry)
SET
  cid   = NULLIF(@cid,''),
  cntry = NULLIF(@cntry,'');
  

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @cat, @subcat, @maintenance)
SET
  id          = NULLIF(@id,''),
  cat         = NULLIF(@cat,''),
  subcat      = NULLIF(@subcat,''),
  maintenance = NULLIF(@maintenance,'');
  
SET @batch_end_time = NOW();
SELECT 'Data load finished at', @batch_end_time;

