{{ config(materialized='view') }}

SELECT
    product_category_name,
    product_category_name_english as product_category_name_in_english
FROM {{ source('ecommerce', 'product_category_name_translation') }}