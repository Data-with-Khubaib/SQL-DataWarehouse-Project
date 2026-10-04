INSERT INTO silver.erp_loc_a101 (
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
