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
