{{ config(materialized = 'table') }}

-- tests showed 1 null value in product_id, so we would like to exclude this from data qulity perspectives
   SELECT * FROM {{ ref('ecommerce','products') }}
   WHERE product_id IS NOT NULL
