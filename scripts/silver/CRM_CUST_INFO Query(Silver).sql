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
