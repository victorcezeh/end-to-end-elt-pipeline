{{ config(materialized='table') }}

SELECT
    product_category_name,
    product_category_name_in_english,
    total_orders,
    total_sales,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM {{ ref('int_sales_by_category') }}