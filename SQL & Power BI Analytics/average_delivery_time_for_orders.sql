-- All delivery time metrics
SELECT 
    avg_delivery_time_days,
    min_delivery_time_days,
    max_delivery_time_days
FROM 
    `ecommerce_transformed.fct_avg_delivery_time`