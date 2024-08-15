---

# E-Commerce ETL Project

## Overview

This project demonstrates an end-to-end ETL (Extract, Transform, Load) process using a Brazilian E-Commerce dataset from Kaggle. The project involves data ingestion into PostgreSQL, orchestration with Apache Airflow, data transformation and modeling with dbt, and loading the transformed data into Google BigQuery. 

## Project Structure

- **PostgreSQL Scripts**: SQL scripts for creating tables and ingesting data.
- **Airflow DAG**: Orchestrates the ETL process from PostgreSQL to BigQuery.
- **dbt Models**: Models for transforming and modeling the data.
- **Analysis**: SQL queries to answer key analytical questions.
- **Docker Compose File**: Configurations for setting up PostgreSQL with Docker.

## Prerequisites

1. **Docker & Docker Compose**: For containerizing PostgreSQL.
2. **Apache Airflow**: For orchestrating the ETL process.
3. **dbt**: For transforming and modeling the data.
4. **Google Cloud Platform Account**: For using BigQuery and Cloud Storage.

## Setup

### 1. PostgreSQL Setup with Docker

1. **Create a Docker Compose File**: Save the following content in `docker-compose.yml`:

    ```yaml
    version: '3.8'

    services:
      postgres:
        image: postgres:latest
        environment:
          POSTGRES_DB: ecommerce
          POSTGRES_USER: <YOUR_POSTGRES_USER>
          POSTGRES_PASSWORD: <YOUR_POSTGRES_PASSWORD>
        volumes:
          - ./pg_data:/var/lib/postgresql/data
          - ./data:/data
          - ./infrastructure_scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
        ports:
          - "5434:5432"
    ```

2. **Start the PostgreSQL Container**:
    ```bash
    docker-compose up -d
    ```

### 2. PostgreSQL Data Ingestion

1. **Create Tables and Import Data**: Use the provided SQL scripts to create tables and ingest data into PostgreSQL. The scripts are located in the `sql_scripts` folder and include:

    - `create_schema_and_tables.sql`
    - `import_data.sql`

2. **Run SQL Scripts**:
    ```bash
    psql -h localhost -p 5434 -U <YOUR_POSTGRES_USER> -d ecommerce -f create_schema_and_tables.sql
    psql -h localhost -p 5434 -U <YOUR_POSTGRES_USER> -d ecommerce -f import_data.sql
    ```

### 3. Apache Airflow Setup

1. **Airflow DAG**: The Airflow DAG is defined in `airflow_dag.py`. It orchestrates the ETL process by:

    - Extracting data from PostgreSQL.
    - Loading data into Google Cloud Storage (GCS).
    - Loading data from GCS into BigQuery.

2. **Configure Airflow Variables**:
    Set the following variables in Airflow:
    - `BQ_CONN_ID`: BigQuery connection ID.
    - `BQ_PROJECT`: BigQuery project ID.
    - `BQ_DATASET`: BigQuery dataset name.
    - `BQ_BUCKET`: GCS bucket name.
    - `PG_CONN_ID`: PostgreSQL connection ID.
    - `PG_SCHEMA`: PostgreSQL schema name.
    - `TABLES`: JSON configuration of tables.

3. **Start Airflow**:
    ```bash
    airflow db init
    airflow webserver --port 8080
    airflow scheduler
    ```

### 4. dbt Setup

1. **Define dbt Models**: The dbt models are located in the `dbt/models` directory. Key models include:

    - **Staging Models**:
        - `stg_customers.sql`: Extracts raw customer data.
        - `stg_order_items.sql`: Extracts raw order items data.
        - `stg_orders.sql`: Extracts raw orders data.
        - `stg_product_category_translation.sql`: Extracts product category translations.
        - `stg_products.sql`: Extracts raw product data.

    - **Intermediate Models**:
        - `int_avg_delivery_time.sql`: Calculates average delivery time.
        - `int_orders_by_state.sql`: Aggregates orders by state.
        - `int_sales_by_category.sql`: Aggregates sales by category.

    - **Final Models**:
        - `fct_avg_delivery_time.sql`: Final average delivery time.
        - `fct_orders_by_state.sql`: Final orders by state.
        - `fct_sales_by_category.sql`: Final sales by category.

2. **Run dbt**:
    ```bash
    dbt run
    ```

### 5. Analysis

1. **SQL Queries**: To answer key analytical questions, use the following queries:

    - `average_delivery_time_for_orders.sql`: Calculates average delivery time for orders.
    - `product_categories_with_highest_sales.sql`: Identifies top 5 product categories by sales.
    - `states_with_the_highest_number_of_orders.sql`: Identifies top 5 states by number of orders.

## Explanation of Each dbt Model

- **Staging Models**: Load raw data from sources into views for easier transformation.
    - `stg_customers.sql`: Loads customer details.
    - `stg_order_items.sql`: Loads order items with necessary data transformations.
    - `stg_orders.sql`: Loads orders with timestamp conversion.
    - `stg_product_category_translation.sql`: Loads category translations.
    - `stg_products.sql`: Loads product details.

- **Intermediate Models**: Perform aggregations and calculations.
    - `int_avg_delivery_time.sql`: Computes delivery times from order data.
    - `int_orders_by_state.sql`: Aggregates order counts by state.
    - `int_sales_by_category.sql`: Calculates total sales and orders by product category.

- **Final Models**: Produce final aggregated results for reporting and analysis.
    - `fct_avg_delivery_time.sql`: Provides average, minimum, and maximum delivery times.
    - `fct_orders_by_state.sql`: Ranks states by order count.
    - `fct_sales_by_category.sql`: Ranks product categories by sales.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or issues, please contact:

- **Victor Ezeh**
- Email: ezeh_victor@yahoo.com

---

Feel free to replace `<YOUR_POSTGRES_USER>`, `<YOUR_POSTGRES_PASSWORD>`, `<YOUR_EMAIL>`, and other placeholders with your specific information when setting up the project.
