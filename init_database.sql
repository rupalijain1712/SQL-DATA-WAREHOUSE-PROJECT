/*
====================================================
CREATE DATABASE AND SCHEMA
====================================================

SCRIPT PURPOSE:
		This script creates a new database 'DataWareHouse' before checking wheather is exists in the system or not.
		If the database exists, it will first drop the database and will recreate it. Addtionally, the script set up  
		3 schemas : 1. bronze 
					2. silver
					3. gold
*/

--Drop the 'DataWareHouse' database
DROP DATABASE IF EXISTS DataWareHouse;

--Recreate the 'DataWareHouse' database
CREATE DATABASE DataWareHouse;

--CREATE 'BRONZE' , 'SILVER' , 'GOLD' SCHEMA
CREATE SCHEMA BRONZE;
CREATE SCHEMA SILVER;
CREATE SCHEMA GOLD;
