CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
DECLARE @start_time DATETIME, @end_time DATETIME;

BEGIN TRY
    SET @batch_start_time = GETDATE();
    PRINT '================================================';
    PRINT 'Loading Silver Layer';
    PRINT '================================================';

    -- Example: Loading CRM Customer Info
    PRINT '>> Loading CRM Customer Info...';
    SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.crm_cust_info;
    INSERT INTO Silver.crm_cust_info (
	    cst_id,
	    cst_key,
	    cst_firstname,
	    cst_lastname,
	    cst_marital_status,
	    cst_gndr,
	    cst_create_date)
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
	        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
	        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
	        ELSE 'n/a'
        END AS cst_marital_status,  -- Normalize Material status values to readable format
        CASE 
	        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
	        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
	        ELSE 'n/a'
        END AS cst_gndr, -- Normalize gender values to readable format 
        cst_create_date
    FROM (
	    SELECT 
	        *,
	        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last -- It generate row_numbers of same primary key and we seen that if duplication in primary key there must be one primary key that didn't have any much information like missing date in this case so we add order by create_date so that the primary key which have create date should come first and the row_number assign 1 to them
	    FROM Bronze.crm_cust_info
	    WHERE cst_id IS NOT NULL
    )t 
    WHERE flag_last = 1
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';

    -- Example 2: Loading CRM Products Info
    PRINT '>> Loading CRM Products Info...';
    SET @start_time = GETDATE();
    TRUNCATE TABLE Silver.crm_prd_info;
    INSERT INTO Silver.crm_prd_info(
	    prd_id,
	    cat_id,
	    prd_key,
	    prd_nm,
	    prd_cost,
	    prd_line,
	    prd_start_dt,
	    prd_end_dt
    )
    SELECT
	    prd_id,
	    REPLACE(SUBSTRING(UPPER(TRIM(prd_key)),1,5),'-','_') AS cid,  -- Extract Category ID AND REPLACE -(HYPHEN) WITH _(UNDERSCORE)
	    SUBSTRING(UPPER(TRIM(prd_key)),7,LEN(prd_key)) AS prd_key,
	    prd_nm,
	    ISNULL(prd_cost,0) AS prd_cost,
	    CASE
		    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Tourising'
		    ELSE 'n/a'
	    END AS prd_line,
	    CAST(prd_start AS DATE) AS prd_start,
	    CAST(CAST(LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start) AS DATETIME) -1 AS DATE) AS prd_end_dt -- Calculate end date as one day before the next start date 
    FROM Bronze.crm_prd_info;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';

    -- Example 3: Loading Sales Details Info
PRINT '>> Loading Sales Details Info...';
SET @start_time = GETDATE();
TRUNCATE TABLE Silver.crm_sales_details;
INSERT INTO Silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 
            THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 
            THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 
            THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE
	    WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price)
	    ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 
            THEN NULLIF(sls_sales, 0) / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';

-- Example 4: Loading ERP Customer Info
PRINT '>> Loading ERP Customer Info...';
SET @start_time = GETDATE();
TRUNCATE TABLE Silver.erp_cust_info;
INSERT INTO Silver.erp_cust_az12 (
cid,
bdate,
gen
)
SELECT
	CASE
		WHEN cid LIKE 'NAS%' 
			THEN SUBSTRING(cid, 4, LEN(cid))
	    ELSE cid
	END AS cid,
	CASE
		WHEN bdate > GETDATE() 
			THEN NULL
	    ELSE bdate
	END AS bdate,
	CASE
		WHEN UPPER(TRIM(gen)) = 'F' 
			THEN 'Female'
		WHEN UPPER(TRIM(gen)) = 'M' 
			THEN 'Male'
		WHEN UPPER(TRIM(gen)) IS NULL OR UPPER(TRIM(gen)) = '' 
			THEN 'n/a'
		ELSE UPPER(TRIM(gen))
	END AS gen
FROM bronze.erp_cust_az12;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';


-- Example 5: Loading ERP Location Info
PRINT '>> Loading ERP LOCATION Info...';
SET @start_time = GETDATE();
TRUNCATE TABLE Silver.erp_loc_a101;
INSERT INTO Silver.erp_loc_a101 (
cid,
cntry
)
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN UPPER(TRIM(COUNTRY)) IN ('DE', 'GERMANY') 
			THEN 'Germany'
		WHEN UPPER(TRIM(COUNTRY)) IN ('US', 'USA', 'UNITED STATES') 
			THEN 'United States'
		WHEN UPPER(TRIM(COUNTRY)) IN ('UK', 'GB', 'UNITED KINGDOM') 
			THEN 'United Kingdom'
		WHEN UPPER(TRIM(COUNTRY)) IS NULL OR UPPER(TRIM(COUNTRY)) = '' 
			THEN 'n/a'
		ELSE UPPER(TRIM(COUNTRY))
	END AS cntry
FROM bronze.erp_loc_a101;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';


-- Example 6: Loading ERP Products Info
PRINT '>> Loading ERP Products Info...';
SET @start_time = GETDATE();
TRUNCATE TABLE Silver.crm_cust_info;
INSERT INTO Silver.erp_px_cat_g1v2 (
	cid,
	cat,
	subcat,
	maintenance
) 
SELECT
	ID,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;
SET @end_time = GETDATE();
PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';

    -- Repeat truncation and insertion logic for other tables
    -- (erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2, etc.)

    SET @batch_end_time = GETDATE();
    PRINT '================================================';
    PRINT 'Silver Layer Loaded. Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
    PRINT '================================================';

END TRY
BEGIN CATCH
    PRINT 'ERROR OCCURRED DURING LOAD';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH
END;
