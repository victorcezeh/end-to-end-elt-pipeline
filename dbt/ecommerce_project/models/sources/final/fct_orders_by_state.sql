{{ config(materialized='table') }}

SELECT
    customer_state,
    total_orders,
    DENSE_RANK() OVER (ORDER BY total_orders DESC) AS order_rank
FROM {{ ref('int_orders_by_state') }}