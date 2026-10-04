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
