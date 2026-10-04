INSERT INTO silver.erp_cust_az12 (
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
