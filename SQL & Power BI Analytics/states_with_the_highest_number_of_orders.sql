-- Top 5 states by number of orders (including rank)
SELECT 
    customer_state,
    total_orders,
    order_rank
FROM 
    `ecommerce_transformed.fct_orders_by_state`
WHERE
    order_rank <= 5
ORDER BY 
    order_rank