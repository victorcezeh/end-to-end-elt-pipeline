{{ config(materialized='table') }}

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_customers') }} c ON o.customer_id = c.customer_id
GROUP BY c.customer_state