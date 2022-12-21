   WITH raw_data AS (
      SELECT  
      DISTINCT *
      FROM `helical-kayak-321710.cohort_analysis.online_retail_raw` 
      WHERE Quantity IS NOT NULL 
      AND UnitPrice IS NOT NULL
      AND CustomerID IS NOT NULL
   ),
   
   
   t_repeat AS (
   SELECT *,
   CASE WHEN customer_seq > 1 THEN 'Repeat Customer'
   ELSE 'New Customer'
   END AS RepeatPurchase 
   FROM ( 
      SELECT  DISTINCT *,
      DATE(TIMESTAMP(InvoiceDate)) AS date,
      UnitPrice * Quantity AS Sales,
      RANK() OVER (PARTITION BY CustomerID ORDER BY DATE(TIMESTAMP(InvoiceDate))) AS customer_seq
      FROM raw_data
   )
 ),

 t_repurchase AS (
    SELECT *, 
    DATE_DIFF(date, first_purchase, MONTH) AS month_order
    FROM (
        SELECT *,
        FIRST_VALUE(date) OVER (PARTITION BY CustomerID ORDER BY DATE) AS first_purchase
        FROM t_repeat
    )
 ),

  t_previous_purchase AS (
    SELECT *, 
    DATE_DIFF(next_purchase, date, DAY) AS days_bet_purchase
    FROM (
        SELECT *,
        LEAD(date) OVER (PARTITION BY CustomerID ORDER BY DATE) AS next_purchase
        FROM t_repurchase
    )
   )


SELECT * FROM t_previous_purchase
