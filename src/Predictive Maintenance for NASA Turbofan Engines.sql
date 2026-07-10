-- ==============================================================================
-- PROJECT: Aerospace Predictive Maintenance and Supply Chain Optimizer
-- AUTHOR: Solomon Mensah
-- PURPOSE: Build a Medallion Architecture Data Warehouse in Snowflake
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- STEP 1: SNOWFLAKE ADMINISTRATION AND COST CONTROL 
-- ------------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

-- Create a Resource Monitor to ensure we don't accidentally burn through credits
CREATE OR REPLACE RESOURCE MONITOR nfi_project_monitor
  WITH CREDIT_QUOTA = 5
  TRIGGERS 
    ON 80 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;

-- Create a dedicated compute warehouse attached to the monitor
CREATE OR REPLACE WAREHOUSE nfi_compute_wh 
  WITH WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 300 
  AUTO_RESUME = TRUE
  RESOURCE_MONITOR = nfi_project_monitor;

-- Create Roles for governance (RBAC)
CREATE OR REPLACE ROLE nfi_data_scientist;
CREATE OR REPLACE ROLE nfi_supply_chain_analyst;


-- ------------------------------------------------------------------------------
-- STEP 2: MEDALLION ARCHITECTURE SETUP (Database, Schemas, Grants)
-- ------------------------------------------------------------------------------

CREATE OR REPLACE DATABASE NFI_PARTS_OPTIMIZER;
USE DATABASE NFI_PARTS_OPTIMIZER;

-- Create the schemas
CREATE OR REPLACE SCHEMA bronze_raw;    
CREATE OR REPLACE SCHEMA silver_clean;  
CREATE OR REPLACE SCHEMA gold_business; 

-- Grant access to roles
GRANT USAGE ON WAREHOUSE nfi_compute_wh TO ROLE nfi_data_scientist;
GRANT USAGE ON WAREHOUSE nfi_compute_wh TO ROLE nfi_supply_chain_analyst;
GRANT USAGE ON DATABASE NFI_PARTS_OPTIMIZER TO ROLE nfi_data_scientist;
GRANT USAGE ON SCHEMA gold_business TO ROLE nfi_data_scientist;
GRANT SELECT ON ALL TABLES IN SCHEMA gold_business TO ROLE nfi_supply_chain_analyst;


-- ------------------------------------------------------------------------------
-- STEP 3: BUILD THE GOLD LAYER (Base Fact Tables)
-- ------------------------------------------------------------------------------
USE SCHEMA gold_business;

CREATE OR REPLACE TABLE FACT_INVENTORY (
    PARTID VARCHAR(50),
    STOCK INT,
    LEADTIME INT,
    COST INT,
    STOCKOUTRISK BOOLEAN,
    REORDERQTY INT,
    ACTION VARCHAR(50)
);

CREATE OR REPLACE TABLE FACT_PREDICTIONS (
    VEHICLEID INT,
    PARTID VARCHAR(50),
    RUL INT,
    FAILURE_30_DAYS INT
);

CREATE OR REPLACE TABLE FACT_DEMAND (
    DATE DATE,
    PARTID VARCHAR(50),
    DEMAND INT,
    MONTH INT
);


-- ------------------------------------------------------------------------------
-- STEP 4: DYNAMIC DIMENSION TABLES (Aerospace Context)
-- NOTE: Execute this block ONLY AFTER your Python script uploads the actual CSV data!
-- ------------------------------------------------------------------------------

-- 1. Dynamically build DIM_PART for Aerospace (Turbofan Engines)
CREATE OR REPLACE TABLE DIM_PART AS
SELECT DISTINCT 
    PARTID AS PART_ID,
    'CMAPSS Turbofan Engine' AS PART_NAME,
    'Propulsion' AS SYSTEM_CATEGORY,
    1500000.00 AS UNIT_COST,
    'GE Aviation' AS SUPPLIER_NAME,
    90 AS LEAD_TIME_DAYS
FROM FACT_INVENTORY
WHERE PARTID IS NOT NULL;

-- 2. Dynamically build DIM_VEHICLE (Representing Aircraft/Fleet)
CREATE OR REPLACE TABLE DIM_VEHICLE AS
SELECT DISTINCT 
    VEHICLEID AS VEHICLE_ID,
    2018 AS MODEL_YEAR,
    'Boeing 737 / Airbus A320' AS VEHICLE_TYPE,
    TRUE AS ACTIVE_STATUS
FROM FACT_PREDICTIONS
WHERE VEHICLEID IS NOT NULL;

-- 3. Create a NASA/Aviation Warehouse dimension
CREATE OR REPLACE TABLE DIM_WAREHOUSE AS
SELECT 
    'WH-001' AS WAREHOUSE_ID,
    'Kennedy Space Center' AS LOCATION_CITY,
    'East' AS REGION
UNION ALL
SELECT 
    'WH-002' AS WAREHOUSE_ID,
    'Johnson Space Center' AS LOCATION_CITY,
    'South' AS REGION;


-- ------------------------------------------------------------------------------
-- STEP 5: OPTIMIZED VIEWS FOR POWER BI DIRECTQUERY
-- ------------------------------------------------------------------------------

CREATE OR REPLACE VIEW VW_EXECUTIVE_SUMMARY AS
SELECT 
    COUNT(DISTINCT p.VEHICLEID) AS Total_Vehicles,
    COUNT(DISTINCT i.PARTID) AS Total_Parts,
    AVG(p.RUL) AS Avg_Remaining_Useful_Life,
    SUM(IFF(p.FAILURE_30_DAYS = 1, 1, 0)) AS Vehicles_Predicted_To_Fail,
    SUM(i.STOCK * i.COST) AS Total_Inventory_Value,
    SUM(IFF(i.STOCK <= i.REORDERQTY, 1, 0)) AS Parts_Requiring_Reorder
FROM FACT_PREDICTIONS p
LEFT JOIN FACT_INVENTORY i ON p.PARTID = i.PARTID;

CREATE OR REPLACE VIEW VW_RECOMMENDATIONS AS
SELECT 
    p.VEHICLEID,
    p.PARTID,
    p.RUL,
    p.FAILURE_30_DAYS,
    i.STOCK,
    i.LEADTIME,
    i.STOCKOUTRISK,
    CASE 
        WHEN p.FAILURE_30_DAYS = 1 AND i.STOCK = 0 THEN 'URGENT: Stockout & Imminent Failure'
        WHEN p.FAILURE_30_DAYS = 1 AND i.STOCK > 0 THEN 'Replace Immediately'
        WHEN p.RUL BETWEEN 31 AND 60 THEN 'Monitor & Stage Inventory'
        ELSE 'No Action Needed'
    END AS Maintenance_Action,
    CASE
        WHEN p.FAILURE_30_DAYS = 1 THEN i.REORDERQTY * 1.5 
        ELSE i.REORDERQTY
    END AS Recommended_Reorder_Qty
FROM FACT_PREDICTIONS p
JOIN FACT_INVENTORY i ON p.PARTID = i.PARTID;

USE ROLE ACCOUNTADMIN;
USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

-- 1. Re-build DIM_PART now that FACT_INVENTORY has real data
CREATE OR REPLACE TABLE DIM_PART AS
SELECT DISTINCT 
    PARTID AS PART_ID,
    'CMAPSS Turbofan Engine' AS PART_NAME,
    'Propulsion' AS SYSTEM_CATEGORY,
    1500000.00 AS UNIT_COST,
    'GE Aviation' AS SUPPLIER_NAME,
    90 AS LEAD_TIME_DAYS
FROM FACT_INVENTORY
WHERE PARTID IS NOT NULL;

-- 2. Re-build DIM_VEHICLE now that FACT_PREDICTIONS has real data
CREATE OR REPLACE TABLE DIM_VEHICLE AS
SELECT DISTINCT 
    VEHICLEID AS VEHICLE_ID,
    2018 AS MODEL_YEAR,
    'Boeing 737 / Airbus A320' AS VEHICLE_TYPE,
    TRUE AS ACTIVE_STATUS
FROM FACT_PREDICTIONS
WHERE VEHICLEID IS NOT NULL;

USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

SELECT COUNT(*) AS Fact_Predictions_Count FROM FACT_PREDICTIONS;
SELECT COUNT(*) AS Fact_Inventory_Count FROM FACT_INVENTORY;
SELECT COUNT(*) AS Dim_Vehicle_Count FROM DIM_VEHICLE;
SELECT COUNT(*) AS Dim_Part_Count FROM DIM_PART;


USE ROLE ACCOUNTADMIN;
USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

-- 1. Dynamically build DIM_PART for Aerospace
CREATE OR REPLACE TABLE DIM_PART AS
SELECT DISTINCT 
    PARTID AS PART_ID,
    'CMAPSS Turbofan Engine' AS PART_NAME,
    'Propulsion' AS SYSTEM_CATEGORY,
    1500000.00 AS UNIT_COST,
    'GE Aviation' AS SUPPLIER_NAME,
    90 AS LEAD_TIME_DAYS
FROM FACT_INVENTORY
WHERE PARTID IS NOT NULL;

-- 2. Dynamically build DIM_VEHICLE for Aerospace
CREATE OR REPLACE TABLE DIM_VEHICLE AS
SELECT DISTINCT 
    VEHICLEID AS VEHICLE_ID,
    2018 AS MODEL_YEAR,
    'Boeing 737 / Airbus A320' AS VEHICLE_TYPE,
    TRUE AS ACTIVE_STATUS
FROM FACT_PREDICTIONS
WHERE VEHICLEID IS NOT NULL;

-- 3. Create the Warehouse dimension
CREATE OR REPLACE TABLE DIM_WAREHOUSE AS
SELECT 'WH-001' AS WAREHOUSE_ID, 'Kennedy Space Center' AS LOCATION_CITY, 'East' AS REGION
UNION ALL
SELECT 'WH-002' AS WAREHOUSE_ID, 'Johnson Space Center' AS LOCATION_CITY, 'South' AS REGION;

-- 4. Create the Views for Power BI
CREATE OR REPLACE VIEW VW_EXECUTIVE_SUMMARY AS
SELECT 
    COUNT(DISTINCT p.VEHICLEID) AS Total_Vehicles,
    COUNT(DISTINCT i.PARTID) AS Total_Parts,
    AVG(p.RUL) AS Avg_Remaining_Useful_Life,
    SUM(IFF(p.FAILURE_30_DAYS = 1, 1, 0)) AS Vehicles_Predicted_To_Fail,
    SUM(i.STOCK * i.COST) AS Total_Inventory_Value,
    SUM(IFF(i.STOCK <= i.REORDERQTY, 1, 0)) AS Parts_Requiring_Reorder
FROM FACT_PREDICTIONS p
LEFT JOIN FACT_INVENTORY i ON p.PARTID = i.PARTID;

CREATE OR REPLACE VIEW VW_RECOMMENDATIONS AS
SELECT 
    p.VEHICLEID,
    p.PARTID,
    p.RUL,
    p.FAILURE_30_DAYS,
    i.STOCK,
    i.LEADTIME,
    i.STOCKOUTRISK,
    CASE 
        WHEN p.FAILURE_30_DAYS = 1 AND i.STOCK = 0 THEN 'URGENT: Stockout & Imminent Failure'
        WHEN p.FAILURE_30_DAYS = 1 AND i.STOCK > 0 THEN 'Replace Immediately'
        WHEN p.RUL BETWEEN 31 AND 60 THEN 'Monitor & Stage Inventory'
        ELSE 'No Action Needed'
    END AS Maintenance_Action,
    CASE
        WHEN p.FAILURE_30_DAYS = 1 THEN i.REORDERQTY * 1.5 
        ELSE i.REORDERQTY
    END AS Recommended_Reorder_Qty
FROM FACT_PREDICTIONS p
JOIN FACT_INVENTORY i ON p.PARTID = i.PARTID;

USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

SELECT COUNT(*) AS Fact_Predictions_Count FROM FACT_PREDICTIONS;
SELECT COUNT(*) AS Fact_Inventory_Count FROM FACT_INVENTORY;
SELECT COUNT(*) AS Dim_Vehicle_Count FROM DIM_VEHICLE;
SELECT COUNT(*) AS Dim_Part_Count FROM DIM_PART;

USE ROLE ACCOUNTADMIN;
USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

-- Populate DIM_PART from existing FACT_INVENTORY
CREATE OR REPLACE TABLE DIM_PART AS
SELECT DISTINCT PARTID AS PART_ID, 'CMAPSS Turbofan Engine' AS PART_NAME, 'Propulsion' AS SYSTEM_CATEGORY, 1500000.00 AS UNIT_COST, 'GE Aviation' AS SUPPLIER_NAME, 90 AS LEAD_TIME_DAYS
FROM FACT_INVENTORY WHERE PARTID IS NOT NULL;
-- Update the table structure to include the cycle information
ALTER TABLE FACT_PREDICTIONS ADD COLUMN IF NOT EXISTS CURRENT_CYCLE INT;

-- If you have the data in a staging table, update it:
-- UPDATE FACT_PREDICTIONS p SET p.CURRENT_CYCLE = s.time_cycles 
-- FROM bronze_raw.your_staging_table s WHERE p.VEHICLEID = s.unit_number;

-- Populate DIM_VEHICLE from existing FACT_PREDICTIONS
CREATE OR REPLACE TABLE DIM_VEHICLE AS
SELECT DISTINCT VEHICLEID AS VEHICLE_ID, 2018 AS MODEL_YEAR, 'Boeing 737 / Airbus A320' AS VEHICLE_TYPE, TRUE AS ACTIVE_STATUS
FROM FACT_PREDICTIONS WHERE VEHICLEID IS NOT NULL;

-- Create DIM_WAREHOUSE (Static reference table)
CREATE OR REPLACE TABLE DIM_WAREHOUSE AS
SELECT 'WH-001' AS WAREHOUSE_ID, 'Kennedy Space Center' AS LOCATION_CITY, 'East' AS REGION
UNION ALL
SELECT 'WH-002' AS WAREHOUSE_ID, 'Johnson Space Center' AS LOCATION_CITY, 'South' AS REGION;

SELECT COUNT(*) FROM FACT_INVENTORY;
SELECT COUNT(*) FROM FACT_PREDICTIONS;

USE DATABASE NFI_PARTS_OPTIMIZER;
USE SCHEMA gold_business;

-- Create Dimensions
CREATE OR REPLACE TABLE DIM_PART AS
SELECT DISTINCT PARTID AS PART_ID, 'Turbofan Engine Component' AS PART_NAME, 'Propulsion' AS SYSTEM_CATEGORY, 1500000.00 AS UNIT_COST FROM FACT_INVENTORY;

CREATE OR REPLACE TABLE DIM_VEHICLE AS
SELECT DISTINCT VEHICLEID AS VEHICLE_ID, 2018 AS MODEL_YEAR, 'Boeing 737 / Airbus A320' AS VEHICLE_TYPE FROM FACT_PREDICTIONS;

-- Refresh Views
CREATE OR REPLACE VIEW VW_EXECUTIVE_SUMMARY AS
SELECT COUNT(DISTINCT p.VEHICLEID) AS Total_Vehicles, SUM(i.STOCK * i.COST) AS Total_Inventory_Value FROM FACT_PREDICTIONS p LEFT JOIN FACT_INVENTORY i ON p.PARTID = i.PARTID;