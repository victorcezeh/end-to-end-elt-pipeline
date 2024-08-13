import os
from airflow import DAG
from airflow.providers.google.cloud.transfers.postgres_to_gcs import (
    PostgresToGCSOperator,
)
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import (
    GCSToBigQueryOperator,
)
from airflow.models import Variable
from datetime import datetime, timedelta
import json
import logging

# Retrieve Config Variables from Airflow Variables
BQ_CONN_ID = Variable.get("BQ_CONN_ID")
BQ_PROJECT = Variable.get("BQ_PROJECT")
BQ_DATASET = Variable.get("BQ_DATASET")
BQ_BUCKET = Variable.get("BQ_BUCKET")

PG_CONN_ID = Variable.get("PG_CONN_ID")
PG_SCHEMA = Variable.get("PG_SCHEMA")

# Retrieve the tables configuration
TABLES = Variable.get("TABLES", deserialize_json=True)

# Define default arguments for the DAG
ENV = os.environ.get("ENV", "dev")
DEFAULT_ARGS = {
    "owner": "Victor Ezeh",
    "retries": 2,
    "retry_delay": timedelta(minutes=3),
    "start_date": datetime(2024, 1, 1),
    "email": ["ezeh_victor@yahoo.com"],
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
}

# Create a DAG instance
with DAG(
    dag_id=f"{ENV}-postgres_to_bigquery_multiple_tables",
    description="Loading Data from PostgreSQL to BigQuery for multiple tables",
    default_args=DEFAULT_ARGS,
    schedule_interval=None,
    max_active_runs=1,
    catchup=False,
) as dag:

    for table in TABLES:
        logging.info(f"Processing table: {table['pg_table']}")

        postgres_to_gcs = PostgresToGCSOperator(
            task_id=f"postgres_{table['pg_table']}_to_gcs",
            sql=f'SELECT * FROM "{PG_SCHEMA}"."{table["pg_table"]}";',
            bucket=BQ_BUCKET,
            filename=f"{table['pg_table']}_" + "{{ ds_nodash }}.csv",
            export_format="CSV",
            postgres_conn_id=PG_CONN_ID,
            field_delimiter=",",
            gzip=False,
            gcp_conn_id=BQ_CONN_ID,
        )

        # Load the schema from the JSON file
        schema_file_path = f"/mnt/c/Users/Victor/Desktop/de-capstone-project/apache-airflow/schemas/{table['bq_table']}.json"
        try:
            with open(schema_file_path, "r") as schema_file:
                schema = json.load(schema_file)
        except FileNotFoundError:
            raise ValueError(f"Schema file not found for table: {table['bq_table']}")
        except json.JSONDecodeError:
            raise ValueError(f"Invalid JSON schema for table: {table['bq_table']}")

        gcs_to_bq = GCSToBigQueryOperator(
            task_id=f"gcs_{table['pg_table']}_to_bigquery",
            bucket=BQ_BUCKET,
            source_objects=[f"{table['pg_table']}_" + "{{ ds_nodash }}.csv"],
            destination_project_dataset_table=f"{BQ_PROJECT}.{BQ_DATASET}.{table['bq_table']}",
            schema_fields=schema,
            create_disposition="CREATE_IF_NEEDED",
            write_disposition="WRITE_TRUNCATE",
            gcp_conn_id=BQ_CONN_ID,
            max_bad_records=100000,
            ignore_unknown_values=True,
            allow_jagged_rows=True,
        )

        postgres_to_gcs >> gcs_to_bq
