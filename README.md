# E-Commerce ELT Project

---

## Table of Contents
1. [Overview](#1-overview)
2. [ELT Pipeline Architecture](#2-elt-pipeline-architecture)
3. [Project Structure](#3-project-structure)
4. [Prerequisites](#4-prerequisites)
5. [Setup](#5-setup)
   - [5.1 PostgreSQL Setup with Docker](#51-postgresql-setup-with-docker)
   - [5.2 PostgreSQL Data Ingestion](#52-postgresql-data-ingestion)
   - [5.3 Apache Airflow Setup](#53-apache-airflow-setup)
   - [5.4 dbt Setup](#54-dbt-setup)
   - [5.5 Analysis](#55-analysis)
6. [Explanation of Each dbt Model](#6-explanation-of-each-dbt-model)
   - [6.1 Staging Models](#61-staging-models)
   - [6.2 Intermediate Models](#62-intermediate-models)
   - [6.3 Final Models](#63-final-models)
7. [License](#7-license)
8. [Contact](#8-contact)
9. [Contributing](#9-contributing)
10. [Acknowledgements](#10-acknowledgements)
   
---

## 1. Overview

This project demonstrates an end-to-end ELT (Extract, Load, Transform) process using a Brazilian E-Commerce dataset from Kaggle. The project involves data ingestion into PostgreSQL, orchestration with Apache Airflow, data transformation and modeling with dbt, and loading the transformed data into Google BigQuery.

## 2. ELT Pipeline Architecture

![ELT ARCHITECTURE](https://github.com/user-attachments/assets/964a6b4c-9dd1-4164-8faa-14ad2248c101)

## 3. Project Structure

- **PostgreSQL Scripts**: SQL scripts for creating tables and ingesting data.
- **Airflow DAG**: Orchestrates the ETL process from PostgreSQL to BigQuery.
- **dbt Models**: Models for transforming and modeling the data.
- **Analysis**: SQL queries to answer key analytical questions.
- **Docker Compose File**: Configurations for setting up PostgreSQL with Docker.

## 4. Prerequisites

1. **Docker & Docker Compose**: For containerizing PostgreSQL.
2. **Apache Airflow**: For orchestrating the ETL process.
3. **dbt**: For transforming and modeling the data.
4. **Google Cloud Platform Account**: For using BigQuery and Cloud Storage.

## 5. Setup

### 5.1 PostgreSQL Setup with Docker

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

### 5.2 PostgreSQL Data Ingestion

1. **Create Tables and Import Data**: Use the provided SQL script to create tables and ingest data into PostgreSQL. The script is located in the `infrastructure_scripts` folder and is named `init.sql`.
2. **Run SQL Script**:
    ```bash
    psql -h localhost -p 5434 -U <YOUR_POSTGRES_USER> -d ecommerce -f infrastructure_scripts/init.sql
    ```

Make sure to replace `<YOUR_POSTGRES_USER>` with your actual PostgreSQL username.

### 5.3 Apache Airflow Setup

1. **Airflow DAG**: The Airflow DAG is defined in the `postgres_to_bigquery_dag.py` file under the `dags` folder. It orchestrates the ETL process by:
    - Extracting data from PostgreSQL.
    - Loading data into Google Cloud Storage (GCS).
    - Loading data from GCS into BigQuery.
2. **Configure Airflow Variables**: Set the following variables in Airflow:
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

### 5.4 dbt Setup

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

### 5.5 Analysis

1. **SQL Queries**: To answer key analytical questions, use the following queries:
   - `product_categories_with_highest_sales.sql`: Identifies top 5 product categories by sales.
   - `states_with_the_highest_number_of_orders.sql`: Identifies top 5 states by number of orders.
   - `average_delivery_time_for_orders.sql`: Calculates average delivery time for orders.
  

### Top 5 Product Categories by Sales

The query was executed to identify the top 5 product categories by total sales from the `fct_sales_by_category` table. The result shows the following product categories:

1. **Health & Beauty (`beleza_saude`)**: $1,233,131.72
2. **Watches & Gifts (`relogios_presentes`)**: $1,166,176.98
3. **Bed, Bath & Table (`cama_mesa_banho`)**: $1,023,434.76
4. **Sports & Leisure (`esporte_lazer`)**: $954,852.55
5. **Computers & Accessories (`informatica_acessorios`)**: $888,724.61

These categories represent the highest sales volumes in the dataset, with the Health & Beauty category leading the list. The sales figures are represented in the local currency with high precision, highlighting the significant contribution of each category to the overall sales.

### Delivery Time Metrics

The query was executed to calculate the average, minimum, and maximum delivery times in days from the `fct_avg_delivery_time` table. The result provides insights into the overall delivery performance:

- **Average Delivery Time**: 12.09 days
- **Minimum Delivery Time**: 0 days
- **Maximum Delivery Time**: 209 days

The data reveals that, on average, deliveries take approximately 12 days to reach customers. However, the delivery time varies significantly, ranging from same-day delivery (0 days) to an extreme of 209 days. This wide range indicates a mix of efficient and delayed deliveries within the dataset.

### Top 5 States by Number of Orders

The query was run to determine the top 5 states in Brazil by the number of customer orders, along with their respective rankings. The result is as follows:

1. **São Paulo (SP)**: 41,746 orders
2. **Rio de Janeiro (RJ)**: 12,852 orders
3. **Minas Gerais (MG)**: 11,635 orders
4. **Rio Grande do Sul (RS)**: 5,466 orders
5. **Paraná (PR)**: 5,045 orders

This ranking highlights that São Paulo (SP) significantly leads in the number of orders, followed by Rio de Janeiro (RJ) and Minas Gerais (MG). The concentration of orders in these states may reflect their larger population sizes and economic activity within Brazil.


## Brazilian E-commerce Dashboard
![BRAZILIAN E-COMMERCE INSIGHTS](https://github.com/user-attachments/assets/70157b96-5dda-42aa-8cbf-d8260191cc1a)

## 6. Explanation of Each dbt Model

### 6.1 Staging Models

- **stg_customers.sql**: Loads customer details.
- **stg_order_items.sql**: Loads order items with necessary data transformations.
- **stg_orders.sql**: Loads orders with timestamp conversion.
- **stg_product_category_translation.sql**: Loads category translations.
- **stg_products.sql**: Loads product details.

### 6.2 Intermediate Models

- **int_avg_delivery_time.sql**: Computes delivery times from order data.
- **int_orders_by_state.sql**: Aggregates order counts by state.
- **int_sales_by_category.sql**: Calculates total sales and orders by product category.

### 6.3 Final Models

- **fct_avg_delivery_time.sql**: Provides average, minimum, and maximum delivery times.
- **fct_orders_by_state.sql**: Ranks states by order count.
- **fct_sales_by_category.sql**: Ranks product categories by sales.

## 7. License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 8. Contact

If you have any questions, feedback, or concerns, don't hesitate to reach out:
- **Instructor**: [Emmanuel Ogunwede](https://github.com/JesuFemi-O)
- **Student**: [Victor Ezeh](https://linktr.ee/victorcezeh)

## 9. Contributing
Collaboration drives innovation in data engineering. If you have suggestions, improvements, or new ideas to contribute, we welcome your input. Simply fork this repository, implement your changes, and submit a pull request. Your contributions are invaluable and greatly appreciated!

## 10. Acknowledgements

I owe a special thanks to [Altschool Africa](https://altschoolafrica.com/) and [Emmanuel Ogunwede](https://github.com/JesuFemi-O) for their unwavering support and invaluable expertise, which were vital to the success of this project. Their contributions made all the difference.

---

Feel free to replace `<YOUR_POSTGRES_USER>`, `<YOUR_POSTGRES_PASSWORD>`, and other placeholders with your specific information when setting up the project.
