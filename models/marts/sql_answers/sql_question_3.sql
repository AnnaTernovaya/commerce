{{ config(materialized = 'table') }}

-- Step 1: Identify the top 3 product categories with the most items sold in November 2017
WITH top_categories AS (
  SELECT
    p.product_category_name,
    SUM(oi.price) AS total_gmv,
    COUNT(oi.order_item_id) AS items_sold
  FROM order_items AS oi
  JOIN orders AS o 
  ON oi.order_id = o.order_id
  JOIN products AS p 
  ON oi.product_id = p.product_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) = 11
  GROUP BY p.product_category_name
  ORDER BY items_sold DESC
  LIMIT 3
),

-- Step 2: Calculate weekly GMV and running sum for each top category
cte_weekly_GMV AS (
  SELECT
    p.product_category_name,
    EXTRACT(WEEK FROM o.order_purchase_timestamp) AS week,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(oi.price) AS weekly_gmv
  FROM Order_Items  AS oi
  JOIN Orders AS o 
  ON oi.order_id = o.order_id
  JOIN Products AS p
  ON oi.product_id = p.product_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
    AND p.product_category_name IN (SELECT product_category_name FROM top_categories)
  GROUP BY p.product_category_name, year, week
),

-- Step 3: Calculate running sum of GMV and weekly GMV growth rate
running_sum_growth_rate AS (
  SELECT
    product_category_name,
    year,
    week,
    weekly_gmv,
    SUM(weekly_gmv) OVER (PARTITION BY product_category_name ORDER BY year, week) AS running_sum_gmv,
    LAG(weekly_gmv) OVER (PARTITION BY product_category_name ORDER BY year, week) AS previous_week_gmv,
    (weekly_gmv - LAG(weekly_gmv) OVER (PARTITION BY product_category_name ORDER BY year, week)) / LAG(weekly_gmv) OVER (PARTITION BY PRODUCT_CATEGORY_NAME ORDER BY year, week) AS gmv_growth_rate
  FROM cte_weekly_GMV
)

-- Step 4: Select the results
SELECT
  product_category_name,
  year,
  week,
  round(weekly_gmv,2) AS weekly_gmv,
  round(running_sum_gmv,2) AS running_sum_gmv,
  round(gmv_growth_rate,4) AS gmv_growth_rate
FROM running_sum_growth_rate
ORDER BY product_category_name, year, week