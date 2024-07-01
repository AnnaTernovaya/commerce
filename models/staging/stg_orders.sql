{{ config(materialized = 'table') }}

-- The columns in the original CSV file for this table were scrambled and not aligned with schema order from the picture.
-- Therefore, we performed a quality check and compared the values in the timestamp columns to determine the correct label name for each column.
   SELECT * FROM {{ ref('ecommerce','orders') }}
