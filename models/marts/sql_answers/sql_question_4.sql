{{ config(materialized = 'table') }}

SELECT 
   o.order_id,
   o.customer_id,
   oi.seller_id,
   oi.product_id,
   c.customer_city,
   c.customer_state,
   o.order_delivered_carrier_date AS order_delivered_carrier_timestamp,
   cast(o.order_delivered_customer_date as date) AS delivery_date,
   cast(SUM(oi.PRICE + oi.FREIGHT_VALUE) OVER (PARTITION BY o.order_id ) as decimal) as order_value
FROM {{ ref('stg_orders') }} AS o
LEFT JOIN {{ ref('stg_order_items') }} AS oi 
ON o.order_id = oi.order_id
LEFT JOIN {{ ref('stg_order_payments') }}  AS op 
ON o.order_id = op.order_id
LEFT JOIN {{ ref('stg_customers') }}  AS c 
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' 
    AND EXTRACT(YEAR FROM o.order_delivered_customer_date) = 2018
    AND c.customer_city <> '' 
    AND c.customer_state <> ''
    AND op.payment_type IN ('credit_card', 'debit_card')
    ORDER BY order_id, order_delivered_customer_date
