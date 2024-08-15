{{ config(materialized='table') }}

SELECT
    order_id,
    TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS delivery_time_days
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL