{{ config(materialized = 'table') }}

-- Identify the top 3 product categories with the most items sold in November 2017
WITH top_categories AS (
  SELECT
    p.product_category_name,
    SUM(oi.price) AS total_gmv,
    COUNT(oi.order_item_id) AS items_sold
  FROM {{ ref('stg_order_items') }} AS oi
  LEFT JOIN {{ ref('stg_orders') }} AS o 
  ON oi.order_id = o.order_id
  LEFT JOIN {{ ref('stg_order_products') }} AS p 
  ON oi.product_id = p.product_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) = 11
  GROUP BY p.product_category_name
  ORDER BY items_sold DESC
  LIMIT 3
),

-- Calculate weekly GMV and running sum for each top category
cte_weekly_GMV AS (
  SELECT
    p.product_category_name,
    EXTRACT(WEEK FROM o.order_purchase_timestamp) AS week,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(oi.price) AS weekly_gmv
  FROM {{ ref('stg_order_items') }} AS oi
  LEFT JOIN {{ ref('stg_orders') }} AS o 
  ON oi.order_id = o.order_id
  LEFT JOIN {{ ref('stg_products') }} AS p
  ON oi.product_id = p.product_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
    AND p.product_category_name IN (SELECT product_category_name FROM top_categories)
  GROUP BY p.product_category_name, year, week
),

-- Calculate running sum of GMV and weekly GMV growth rate
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

-- Select the results
SELECT
  product_category_name,
  year,
  week,
  cast(weekly_gmv AS Decimal) AS weekly_gmv,
  cast(running_sum_gmv AS Decimal) AS running_sum_gmv,
  cast(gmv_growth_rate AS Decimal) AS gmv_growth_rate
FROM running_sum_growth_rate
ORDER BY product_category_name, year, week
