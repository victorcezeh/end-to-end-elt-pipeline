{{ config(materialized='table') }}

WITH order_products AS (
    SELECT
        o.order_id,
        oi.product_id,
        p.product_category_name,
        oi.price
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_order_items') }} oi ON o.order_id = oi.order_id
    JOIN {{ ref('stg_products') }} p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
)

SELECT
    op.product_category_name,
    COALESCE(pct.product_category_name_in_english, op.product_category_name) AS product_category_name_in_english,
    COUNT(DISTINCT op.order_id) AS total_orders,
    SUM(op.price) AS total_sales
FROM order_products op
LEFT JOIN {{ ref('stg_product_category_translation') }} pct ON op.product_category_name = pct.product_category_name
GROUP BY op.product_category_name, pct.product_category_name_in_english