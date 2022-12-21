WITH cte_rev AS
(
  SELECT 
  	DATE(FORMAT_DATE("%Y-%m-01", DATE(InvoiceDate))) AS ym
  	,SUM(UnitPrice * Quantity) revenue
  FROM `helical-kayak-321710.cohort_analysis.online_retail_raw`
  GROUP BY 1
)
SELECT 
	cur.*,
	las.ym AS last_m,
	las.revenue last_revenue
FROM cte_rev cur 
LEFT JOIN cte_rev las ON cur.ym = las.ym + INTERVAL 1 MONTH
