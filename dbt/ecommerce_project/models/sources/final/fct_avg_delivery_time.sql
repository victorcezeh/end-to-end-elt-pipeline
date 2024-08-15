{{ config(materialized='table') }}

SELECT
    AVG(delivery_time_days) AS avg_delivery_time_days,
    MIN(delivery_time_days) AS min_delivery_time_days,
    MAX(delivery_time_days) AS max_delivery_time_days
FROM {{ ref('int_avg_delivery_time') }}