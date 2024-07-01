{{ config(materialized = 'table') }}

WITH order_data AS (
  SELECT
    oi.order_id,
    oi.seller_id,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    EXTRACT(WEEK FROM o.order_purchase_timestamp) AS week,
    EXTRACT(DAY FROM o.order_purchase_timestamp) AS day
  FROM {{ ref('stg_order_items') }} AS oi
  LEFT JOIN {{ ref('stg_orders') }} AS o ON oi.order_id = o.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2017
),

seller_activity AS (
  SELECT
    order_id,
    seller_id,
    year,
    month,
    week,
    day,
    COUNT(ORDER_ID) OVER (PARTITION BY seller_id, year, month) AS monthly_order_count,
    COUNT(ORDER_ID) OVER (PARTITION BY seller_id, year, month, week) AS weekly_order_count,
    COUNT(ORDER_ID) OVER (PARTITION BY seller_id, year, month, week, day) AS daily_order_count
  FROM order_data
),

-- Filter based on the required criteria for active sellers
active_sellers AS (
  SELECT
    year,
    month,
    seller_id,
    IF(monthly_order_count >= 25, 1, 0) AS is_monthly_active,
    IF(weekly_order_count >= 5, 1, 0) AS is_weekly_active,
    IF(daily_order_count >= 1, 1, 0) AS is_daily_active
  FROM seller_activity
),

-- Summarize the counts for each seller
summary AS (
  SELECT
    year,
    month,
    COUNT(DISTINCT IF(is_monthly_active = 1, seller_id, NULL)) AS monthly_active_sellers,
    AVG(COUNT(DISTINCT IF(is_weekly_active = 1, seller_id, NULL))) OVER (PARTITION BY year, month) AS avg_weekly_active_sellers,
    AVG(COUNT(DISTINCT IF(is_daily_active = 1, seller_id, NULL))) OVER (PARTITION BY year, month) AS avg_daily_active_sellers
  FROM active_sellers
  GROUP BY year, month
)

SELECT
  year,
  month,
  MAX(monthly_active_sellers) AS monthly_active_sellers,
  MAX(avg_weekly_active_sellers) AS avg_weekly_active_sellers,
  MAX(avg_daily_active_sellers) AS avg_daily_active_sellers
FROM summary
GROUP BY year, month
ORDER BY year, month
