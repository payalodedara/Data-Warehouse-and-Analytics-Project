/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse'. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
In MYSQL schema and datavbase are equivalent
*/

use mysql
create database DataWarehouse
use DataWarehouse

create database bronze
create database silver
create database gold
