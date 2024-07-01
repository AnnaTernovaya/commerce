{{ config(materialized = 'table') }}

   SELECT 
    
    {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id', 'product_id')}} as primary_key 
    ,* 

   FROM {{ ref('ecommerce','order_items') }}
