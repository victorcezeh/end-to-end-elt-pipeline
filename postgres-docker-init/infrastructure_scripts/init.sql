-- Create Schema
CREATE SCHEMA IF NOT EXISTS ECOMMERCE;

-- Create customers table
CREATE TABLE IF NOT EXISTS ECOMMERCE.CUSTOMERS (
    customer_id VARCHAR(255) PRIMARY KEY,
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(255),
    customer_state VARCHAR(2)
);

-- Import data into customers table
COPY ECOMMERCE.CUSTOMERS (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

-- Create geolocation table
CREATE TABLE IF NOT EXISTS ECOMMERCE.GEOLOCATION (
    geolocation_id SERIAL PRIMARY KEY,
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(2)
);

-- Import data into geolocation table
COPY ECOMMERCE.GEOLOCATION (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
FROM '/data/geolocation.csv' DELIMITER ',' CSV HEADER;

-- Create orders table
CREATE TABLE IF NOT EXISTS ECOMMERCE.ORDERS (
    order_id VARCHAR(255) PRIMARY KEY,
    customer_id VARCHAR(255),
    order_status VARCHAR(255),
    order_purchase_timestamp VARCHAR(255),
    order_approved_at VARCHAR(255),
    order_delivered_carrier_date VARCHAR(255),
    order_delivered_customer_date VARCHAR(255),
    order_estimated_delivery_date VARCHAR(255)
);

-- Import data into orders table
COPY ECOMMERCE.ORDERS (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

-- Create order items table
CREATE TABLE IF NOT EXISTS ECOMMERCE.ORDER_ITEMS (
    order_id VARCHAR(255),
    order_item_id INT,
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date VARCHAR(255),
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES ECOMMERCE.ORDERS(order_id)
);

-- Import data into order items table
COPY ECOMMERCE.ORDER_ITEMS (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM '/data/order_items.csv' DELIMITER ',' CSV HEADER;

-- Create order payments table
CREATE TABLE IF NOT EXISTS ECOMMERCE.ORDER_PAYMENTS (
    order_id VARCHAR(255),
    payment_sequential INT,
    payment_type VARCHAR(25),
    payment_installments INT,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES ECOMMERCE.ORDERS(order_id)
);

-- Import data into order payments table
COPY ECOMMERCE.ORDER_PAYMENTS (order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM '/data/order_payments.csv' DELIMITER ',' CSV HEADER;

-- Create order reviews table
CREATE TABLE IF NOT EXISTS ECOMMERCE.ORDER_REVIEWS (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(255),
    review_creation_date VARCHAR(255),
    review_answer_timestamp VARCHAR (255),
    PRIMARY KEY (review_id, order_id),
    FOREIGN KEY (order_id) REFERENCES ECOMMERCE.ORDERS(order_id)
);

-- Import data into order reviews table
COPY ECOMMERCE.ORDER_REVIEWS (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM '/data/order_reviews.csv' DELIMITER ',' CSV HEADER;

-- Create product category name translation table
CREATE TABLE IF NOT EXISTS ECOMMERCE.PRODUCT_CATEGORY_NAME_TRANSLATION (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);

-- Import data into product category name translation table
COPY ECOMMERCE.PRODUCT_CATEGORY_NAME_TRANSLATION (product_category_name, product_category_name_english)
FROM '/data/product_category_name_translation.csv' DELIMITER ',' CSV HEADER;

-- Create products table
CREATE TABLE IF NOT EXISTS ECOMMERCE.PRODUCTS (
    product_id VARCHAR(255) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Import data into products table
COPY ECOMMERCE.PRODUCTS (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- Create sellers table
CREATE TABLE IF NOT EXISTS ECOMMERCE.SELLERS (
    seller_id VARCHAR(255) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(255),
    seller_state VARCHAR(2)
);

-- Import data into sellers table
COPY ECOMMERCE.SELLERS (seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM '/data/sellers.csv' DELIMITER ',' CSV HEADER;
