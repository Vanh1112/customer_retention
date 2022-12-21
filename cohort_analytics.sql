WITH t_first_purchase AS (
    SELECT DISTINCT
    date,
    DATE_DIFF(date, first_purchase_date, MONTH) AS month_order,
    DATE(FORMAT_DATETIME('%Y-%m-01', first_purchase_date)) AS first_purchase,
    Sales,
    CustomerID
    FROM (
      SELECT 
      DISTINCT
      DATE(TIMESTAMP(InvoiceDate)) AS date,
      UnitPrice * Quantity AS Sales,
      CustomerID,
      FIRST_VALUE(DATE(TIMESTAMP(InvoiceDate))) OVER (PARTITION BY CustomerID ORDER BY DATE(TIMESTAMP(InvoiceDate))) AS first_purchase_date
      FROM `helical-kayak-321710.cohort_analysis.online_retail_raw`
      WHERE Quantity IS NOT NULL 
      AND UnitPrice IS NOT NULL
      AND CustomerID IS NOT NULL 
    --   AND DATE(TIMESTAMP(InvoiceDate)) BETWEEN '2021-12-01' AND '2022-11-30'
    )
   ),

t_agg AS (
    SELECT 
    first_purchase,
    month_order,
    SUM(Sales) AS TotalSales,
    AVG(Sales) AS AvgSales,
    COUNT(DISTINCT CustomerID) AS Customers
    FROM 
    t_first_purchase
    GROUP BY first_purchase, month_order
),

 t_cohort AS (
     SELECT *,
     SAFE_DIVIDE(TotalSales, CohortTotalSales) AS CohortSalesPerc,
     SAFE_DIVIDE(Customers, CohortCustomers) AS CohortCustomersPerc
     FROM (
         SELECT *,
         FIRST_VALUE(TotalSales) OVER (PARTITION BY first_purchase ORDER BY month_order) AS CohortTotalSales,
         FIRST_VALUE(AvgSales) OVER (PARTITION BY first_purchase ORDER BY month_order) AS CohortAvgSales,
         FIRST_VALUE(Customers) OVER (PARTITION BY first_purchase ORDER BY month_order) AS CohortCustomers
         FROM t_agg
     )
 )

SELECT * FROM t_cohort 
WHERE first_purchase = '2022-05-01'
-- AND 
ORDER BY first_purchase, month_order
