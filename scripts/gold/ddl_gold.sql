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

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_customers;

CREATE VIEW GOLD.DIM_CUSTOMERS AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY CST_ID) AS 
	CUSTOMER_KEY,
	CCI.CST_ID                   AS CUSTOMER_ID,
	CCI.CST_KEY                  AS CUSTOMER_NUMBER,
	CCI.CST_FIRSTNAME            AS FIRST_NAME,
	CCI.CST_LASTNAME             AS LAST_NAME,
	CASE 
  		WHEN  CCI.CST_GNDR !='UNKNOWN' THEN CCI.CST_GNDR --CRM IS THE PRIMARY SOURCE FOR GENDER
  		ELSE ECI.GEN 
	END                          AS GENDER,
	ECI.BDATE                    AS BIRTH_DATE,
	ELO.CNTRY                    AS COUNTRY,
	CCI.CST_MARITAL_STATUS       AS MARITAL_STATUS,
	CCI.CST_CREATE_DATE          AS CREATE_DATES
FROM SILVER.CRM_CUST_INFO CCI
LEFT JOIN SILVER.ERP_CUST_AZ12 ECI
      ON ECI.CID=CCI.CST_KEY
LEFT JOIN SILVER.ERP_LOC_A101 ELO
      ON ELO.CID=CCI.CST_KEY;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW GOLD.DIM_PRODUCTS AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY PR.PRD_START_DT,PR.PRD_KEY) AS PRODUCT_KEY,
	PR.PRD_ID             AS PRODUCT_ID,
	PR.PRD_KEY            AS PRODUCT_NUMBER ,
	PR.PRD_NM             AS PRODUCT_NAME,
	PR.CAT_ID             AS CATEROGY_ID,
	EPR.CAT               AS CATEGORY_NAME,
	EPR.SUBCAT            AS SUB_CATEGORY_NAME,
	EPR.MAINTANCE         AS MAINTANCE,
	PR.PRD_COST           AS PRODUCT_COST,
	PR.PRD_LINE           AS PRODUCT_LINE,
	PR.PRD_START_DT       AS START_DATE
FROM SILVER.CRM_PRD_INFO PR
LEFT JOIN SILVER.ERP_PX_CAT_G1V2 EPR
      ON PR.CAT_ID=EPR.ID
WHERE PR.PRD_END_DT IS NULL; --FILTERING OUT THE HISTORICAL DATA

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
 DROP VIEW IF EXISTS gold.fact_sales;

CREATE VIEW GOLD.FACTS_SALES AS
SELECT  
	SD.SLS_ORD_NUM         AS ORDER_NUMBER,
	GPR.PRODUCT_KEY        AS PRODUCT_KEY,
	GCI.CUSTOMER_KEY       AS CUSTOMER_KEY,
	SD.SLS_ORDER_DT        AS ORDER_DATE,
	SD.SLS_SHIP_DT         AS SHIP_DATE,
	SD.SLS_DUE_DT          AS DUE_DATE,
	SD.SLS_SALES           AS SALES,
	SD.SLS_QUANTITY        AS QUANTITY,
	SD.SLS_PRICE           AS PRICE
FROM SILVER.CRM_SALES_DETAILS SD
LEFT JOIN GOLD.DIM_PRODUCTS GPR
ON 		  SD.SLS_PRD_KEY=GPR.PRODUCT_NUMBER
LEFT JOIN GOLD.DIM_CUSTOMERS GCI 
ON	  GCI.CUSTOMER_ID=SD.SLS_CUST_ID;
