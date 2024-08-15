{{ config(materialized='view') }}

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    price,
    freight_value
FROM {{ source('ecommerce', 'order_items') }}