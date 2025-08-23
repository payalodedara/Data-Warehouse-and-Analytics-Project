/*
=============================================================
Create Database and Schemas
=============================================================
USING MYSQL Workbench
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
In MYSQL schema and datavbase are equivalent
*/

use mysql;

-- Create main DataWarehouse database
create database DataWarehouse;
use DataWarehouse;

-- Create schema-like databases 
create database bronze;
create database silver;
create database gold;
