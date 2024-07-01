
{{ config(materialized = 'table') }}

   SELECT * FROM {{ ref('ecommerce','customers') }}

