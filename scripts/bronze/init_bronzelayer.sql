-- Create Table PX_CAT_G1V2 -- 
CREATE TABLE bronze.erp_PX_CAT_G1V2(
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
);

-- Create Table CUST_AZ12 --
CREATE TABLE bronze.erp_CUST_AZ12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
);

--Create Table LOC_A101 --
CREATE TABLE bronze.erp_LOC_A101 (
    CID NVARCHAR(50),
    COUNTRY NVARCHAR(50),
);

-- Create Table sales_details --
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- Create Table prd_info --
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost NVARCHAR(50),
    prd_line NVARCHAR(50),
    prd_start NVARCHAR(50),
    prd_end_dt DATE
);

-- Create Table cust_info -- 
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

-- Create Stored Procedure for Loading Data into Bronze Layer --
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declare Variables for StartTime and EndTime --
    DECLARE @starttime DATETIME, @endtime DATETIME

    -- Now Truncate and Insert Data from CSV into SQL Table with FULL LOAD -- 
    TRUNCATE TABLE bronze.crm_cust_info;

    SET @starttime = GETDATE();
    BULK INSERT bronze.crm_cust_info
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_crm\cust_info.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );
    SET @endtime = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(seconds,@starttime,@endtime) AS NVARCHAR) + ' seconds';
    PRINT '>> --------------------- '

    -- Insert prd_info --
    TRUNCATE TABLE bronze.crm_prd_info;

    SET @starttime = GETDATE();

    BULK INSERT bronze.crm_prd_info
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_crm\prd_info.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );

    SET @endtime = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(seconds,@starttime,@endtime) AS NVARCHAR) + ' seconds';
    PRINT '>> --------------------- '

    -- Insert sales_details --
    TRUNCATE TABLE bronze.crm_sales_details;

    BULK INSERT bronze.crm_sales_details
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_crm\sales_details.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );

    -- Insert CUST_AZ12 --
    TRUNCATE TABLE bronze.erp_CUST_AZ12;

    BULK INSERT bronze.erp_CUST_AZ12
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_erp\CUST_AZ12.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );

    -- Insert LOC_A101 --
    TRUNCATE TABLE bronze.erp_LOC_A101;

    BULK INSERT bronze.erp_LOC_A101
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_erp\LOC_A101.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );

    -- Insert PX_CAT_G1V2 --
    TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

    BULK INSERT bronze.erp_PX_CAT_G1V2
    FROM 'D:\SQL-Ultimate-Course\Data Warehouse Project\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH(
        FIRSTROW = 2 ,   -- Tells that start with Row 2 because in 1st row there is a columns name --
        FIELDTERMINATOR = ',',   -- Tells that each field value ends up with ',' --
        TABLOCK
        );
END
