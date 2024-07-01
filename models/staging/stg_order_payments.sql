{{ config(materialized = 'table') }}

   SELECT * FROM {{ ref('ecommerce','order_payments') }}
