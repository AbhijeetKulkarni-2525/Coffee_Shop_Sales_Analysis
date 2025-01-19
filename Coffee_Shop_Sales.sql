--Checking dataset
SELECT 
  * 
FROM 
  coffee_shop_sales


--Data Cleaning
ALTER TABLE 
  coffee_shop_sales ALTER COLUMN transaction_date DATE;

ALTER TABLE 
  coffee_shop_sales ALTER COLUMN transaction_time TIME(0);

ALTER TABLE 
  coffee_shop_sales ALTER COLUMN transaction_qty INT;



--Calculate the total sales for each respective month
SELECT 
  DATENAME(MONTH, transaction_date), 
  ROUND(
    SUM(transaction_qty * unit_price), 
    2
  ) AS total_sales 
FROM 
  coffee_shop_sales 
GROUP BY 
  DATENAME(MONTH, transaction_date)



--Dtermine the month on month increase or decrease in sales %
SELECT 
  MONTH(transaction_date) AS num_month, 
  ROUND(
    SUM(transaction_qty * unit_price), 
    2
  ) AS total_sales, 
  (
    SUM(transaction_qty * unit_price) - LAG(
      SUM(transaction_qty * unit_price), 
      1
    ) OVER (
      ORDER BY 
        MONTH(transaction_date)
    )
  )/ LAG(
    SUM(transaction_qty * unit_price), 
    1
  ) OVER (
    ORDER BY 
      MONTH(transaction_date)
  )* 100 AS mom_increase_percentage 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) IN (4, 5) 
GROUP BY 
  MONTH(transaction_date) 
ORDER BY 
  MONTH(transaction_date)




--Calculate the total number of orders for each respective month
SELECT 
  DATENAME(MONTH, transaction_date) AS month_name, 
  COUNT(transaction_id) AS total_orders 
FROM 
  coffee_shop_sales 
GROUP BY 
  DATENAME(MONTH, transaction_date) --Dtermine the month on month increase or decrease in number of orders
  ;
WITH MonthlyOrders AS (
  SELECT 
    MONTH(transaction_date) AS num_month, 
    CAST (
      COUNT(transaction_id) AS FLOAT
    ) AS total_orders 
  FROM 
    coffee_shop_sales 
  WHERE 
    MONTH(transaction_date) IN(4, 5) 
  GROUP BY 
    MONTH(transaction_date)
)


SELECT 
  num_month, 
  CASE WHEN LAG(total_orders) OVER(
    ORDER BY 
      num_month
  ) IS NOT NULL THEN (
    total_orders - LAG(total_orders) OVER(
      ORDER BY 
        num_month
    )
  )/ LAG(total_orders) OVER(
    ORDER BY 
      num_month
  )* 100 ELSE NULL END AS mom_percentage_increase 
FROM 
  MonthlyOrders 
ORDER BY 
  num_month;




--Calculate the total quantity sold for each respective month
SELECT 
  DATENAME(MONTH, transaction_date) AS month_name, 
  SUM(transaction_qty) AS total_quantity_sold 
FROM 
  coffee_shop_sales 
GROUP BY 
  DATENAME(MONTH, transaction_date);




--Dtermine the month on month increase or decrease in number of quantity
WITH MonthlyQuantities AS (
  SELECT 
    MONTH(transaction_date) AS num_month, 
    CAST(
      SUM(transaction_qty) AS FLOAT
    ) AS total_quantity 
  FROM 
    coffee_shop_sales 
  WHERE 
    MONTH(transaction_date) IN (4, 5) 
  GROUP BY 
    MONTH(transaction_date)
)


SELECT 
  num_month, 
  CASE WHEN LAG(total_quantity) OVER(
    ORDER BY 
      num_month
  ) IS NOT NULL THEN (
    total_quantity - LAG(total_quantity) OVER(
      ORDER BY 
        num_month
    )
  )/ LAG(total_quantity) OVER(
    ORDER BY 
      num_month
  )* 100 ELSE NULL END AS percentage_of_total_quantity 
FROM 
  MonthlyQuantities 
ORDER BY 
  num_month





--Finding Key matrics
SELECT 
  ROUND(
    SUM(transaction_qty * unit_price), 
    1
  ) AS total_sales, 
  ROUND(
    SUM(transaction_qty), 
    1
  ) AS total_quantity_sold, 
  ROUND(
    COUNT(transaction_id), 
    1
  ) AS total_orders 
FROM 
  coffee_shop_sales 
WHERE 
  transaction_date = '2023-05-18';




--Finding revenue for weekdays and weekends by a given month
SELECT 
  CASE WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'week_end' ELSE 'week_day' END AS day_type, 
  CONCAT(
    ROUND(
      SUM(unit_price * transaction_qty)/ 1000, 
      1
    ), 
    'K'
  ) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  CASE WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'week_end' ELSE 'week_day' END;





--Finding total revenue by location for a given month
SELECT 
  store_location, 
  CONCAT(
    ROUND(
      SUM(unit_price * transaction_qty)/ 1000, 
      1
    ), 
    'K'
  ) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  store_location





--Finding out the avg. monthly sales for a given month
SELECT 
  CONCAT(
    ROUND(
      AVG(total_sales)/ 1000, 
      2
    ), 
    'K'
  ) AS avg_sales 
FROM 
  (
    SELECT 
      SUM(unit_price * transaction_qty) AS total_sales 
    FROM 
      coffee_shop_sales 
    WHERE 
      MONTH(transaction_date) = 5 
    GROUP BY 
      transaction_date
  ) AS internal_query





--Find out the total sales for each individual day for a given month
SELECT 
  DAY(transaction_date) AS day_month, 
  CONCAT(
    ROUND(
      SUM(unit_price * transaction_qty)/ 1000, 
      2
    ), 
    'K'
  ) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  DAY(transaction_date) 
ORDER BY 
  DAY(transaction_date)




--Compare individual daily sales with avg.daily monthly sales(if they are above or below avg)
SELECT 
  day_of_month, 
  CASE WHEN total_sales > avg_sales THEN 'Above Average' WHEN total_sales < avg_sales THEN 'Below Average' ELSE 'Equal to Average' END AS sales_status, 
  total_sales 
FROM 
  (
    SELECT 
      DAY(transaction_date) AS day_of_month, 
      SUM(unit_price * transaction_qty) AS total_sales, 
      AVG(
        SUM(unit_price * transaction_qty)
      ) OVER() AS avg_sales 
    FROM 
      coffee_shop_sales 
    WHERE 
      MONTH(transaction_date) = 5 
    GROUP BY 
      DAY(transaction_date)
  ) AS sales_data 
ORDER BY 
  day_of_month




--Find total revenue by product category for a given month
SELECT 
  product_category, 
  SUM(unit_price * transaction_qty) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  product_category 
ORDER BY 
  SUM(unit_price * transaction_qty) DESC





--Find top 10 products by sales/revenue for a given month
SELECT 
  TOP 10 product_type, 
  SUM(unit_price * transaction_qty) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  product_type 
ORDER BY 
  SUM(unit_price * transaction_qty) DESC




--Find out total sales, total quantitties sold, total orders by day of the week and hour of the day(in where clause 2 is Monday and 8 is 8AM) 
SELECT 
  SUM(unit_price * transaction_qty) AS total_sales, 
  SUM(transaction_qty) AS total_qty_sold, 
  COUNT(*) AS total_orders 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
  AND DATEPART(WEEKDAY, transaction_date) = 2 
  AND DATEPART(HOUR, transaction_time) = 8





--Finding out total sales by hour of the day for a given month
SELECT 
  DATEPART(HOUR, transaction_time) AS hour_of_the_day, 
  SUM(unit_price * transaction_qty) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  DATEPART(HOUR, transaction_time) 
ORDER BY 
  SUM(unit_price * transaction_qty) DESC




--Finding out total sales by day of the week for a given month

SELECT 
  DATENAME(WEEKDAY, transaction_date) AS week_day, 
  SUM(unit_price * transaction_qty) AS total_sales 
FROM 
  coffee_shop_sales 
WHERE 
  MONTH(transaction_date) = 5 
GROUP BY 
  DATENAME(WEEKDAY, transaction_date)









