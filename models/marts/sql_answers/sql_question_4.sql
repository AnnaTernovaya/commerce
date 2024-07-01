{{ config(materialized = 'table') }}

WITH filtered_orders AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_delivered_carrier_date,
        oi.seller_id,
        oi.product_id,
        o.order_delivered_customer_date as delivery_date,
        SUM(oi.price + oi.freight_value) OVER (PARTITION BY o.order_id ) AS order_value
    FROM orders AS o
    JOIN order_items AS oi 
    ON o.order_id = oi.order_id
    JOIN order_payments AS op 
    ON o.order_id = op.order_id
    JOIN customers AS c 
    ON o.customer_id = c.customer_id
    WHERE 
        o.order_status = 'delivered' 
        AND EXTRACT(YEAR FROM o.order_delivered_customer_date) = 2018
        AND c.customer_city <> '' 
        AND c.customer_state <> ''
        AND op.payment_type IN ('credit_card', 'debit_card')
)

SELECT 
    delivery_date,
    seller_id,
    product_id,
    order_delivered_carrier_date,
    SUM(order_value) AS total_order_value
FROM filtered_orders
GROUP BY 
    delivery_date,
    seller_id,
    product_id,
    order_delivered_carrier_date
ORDER BY 
    delivery_date