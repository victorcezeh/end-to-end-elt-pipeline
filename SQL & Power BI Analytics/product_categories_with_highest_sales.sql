-- Top 5 product categories by sales
SELECT 
    product_category_name, 
    product_category_name_in_english,
    total_sales
FROM 
    `ecommerce_transformed.fct_sales_by_category`
ORDER BY 
    total_sales DESC
LIMIT 
    5;