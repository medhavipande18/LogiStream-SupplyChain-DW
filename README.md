# 🚀 LogiStream Supply Chain Data Pipeline: S3 to Redshift Data Warehouse

## 💡 Introduction: Project Aim and Scope

[cite_start]The LogiStream cloud data pipeline is engineered as a robust **hybrid solution**, optimized for scalable ingestion and transformation of both structured (CSV) and complex semi-structured (GeoJSON) data[cite: 80, 81]. [cite_start]This architecture utilizes **Amazon S3** for secure data staging and storage, **AWS Glue** for centralized data cataloging and performing complex **PySpark ETL** processing, and **AWS Lambda** for specialized functions like GeoJSON flattening[cite: 82]. [cite_start]The transformed, normalized data is then consolidated into an **Amazon Redshift Serverless** Data Warehouse[cite: 87]. [cite_start]This multidimensional model enables powerful, real-time operational dashboards[cite: 82].

---

## 📁 Repository Structure & Code Organization

The project components are organized to separate infrastructure definitions, ETL logic, schema DDL, and documentation, ensuring clarity and replicability.

LogiStream-SupplyChain-DW/ ├── README.md <-- Project overview and replication guide (this file). ├── infrastructure/ │ ├── 01_iam_roles.json <-- IAM policy/trust definitions. │ └── 02_redshift_vpc_config.json ├── etl_jobs/ │ ├── lambda_geojson_processor.py <-- Python code for GeoJSON flattening (WKT conversion). │ └── glue_master_etl.py <-- Final PySpark script for ETL. ├── data_warehouse/ │ └── ddl_snowflake_schema.sql <-- CREATE TABLE scripts for all 9 tables. └── documentation/ └── milestone_reports/ ├── Milestone5_Group4.pdf └── Milestone6_Group4.pdf

---

## 📐 Data Warehouse Creation and Multidimensional Modeling

[cite_start]The creation of the Data Warehouse involved deliberately modeling the data from a flat operational structure into an optimized analytical structure (OLAP)[cite: 80].

### Operational DB vs. Multidimensional Model

* [cite_start]**Operational Database (Source):** The database created by the Glue Crawler consists of flat, high-volume files: **`rawdata`** (transactional CSV) and **`processed_routes`** (flattened GeoJSON WKT)[cite: 83, 85].
* **Multidimensional Model:** The final **Snowflake Schema** in Redshift uses **8 Dimensions** and **1 Fact table** to prioritize analytical performance. This structure allows the pipeline to link transactional events (measures) to descriptive attributes (dimensions) using unique integer Foreign Keys (FKs).

### Key Analytical Features

* [cite_start]**Snowflake Structure:** The hierarchical relationship between **`dim_department`** $\rightarrow$ **`dim_category`** $\rightarrow$ **`dim_product`** supports multi-level profitability analysis[cite: 58].
* [cite_start]**Geospatial Integration:** The **`dim_route_shapes`** table stores the complex geometric path of each shipment as a **WKT (Well-Known Text)** string[cite: 8]. [cite_start]This enables Tableau to plot **actual shipping paths** to support the Live Geospatial Dashboard[cite: 53, 1759].
* [cite_start]**Operational Insights:** The model directly supports **Proactive Late-Delivery Alerts** and **Route & Carrier Optimization**[cite: 51, 57].

---

## 💻 AWS Architecture & Service Components

The pipeline is entirely implemented and configured within the **AWS US East (Ohio / us-east-2)** control plane. 

| Component | Role in Pipeline | Key Function |
| :--- | :--- | :--- |
| **Amazon S3** | Data Lake / Staging Layer | [cite_start]Stores raw CSVs, GeoJSON, and processed WKT output[cite: 83]. |
| **AWS Lambda** | GeoJSON Pre-processing | [cite_start]Flattens nested GeoJSON into **WKT strings** (Programming component)[cite: 84]. |
| **AWS Glue Crawlers** | Cataloging / Schema Inference | [cite_start]Scans S3 and registers tables (**`rawdata`**, **`processed_routes`**) in the **`logistream_db`**[cite: 85]. |
| **Amazon Athena** | Verification Layer | [cite_start]Queries the operational database (Catalog tables) to validate schema and data integrity[cite: 86]. |
| **AWS Glue ETL (PySpark)** | Core Transformation Engine | [cite_start]Implements dimensional modeling and performs complex joins to load Redshift[cite: 87]. |
| **Amazon Redshift Serverless**| Data Warehouse (DW) | [cite_start]High-performance, columnar storage for the final **Snowflake Schema**[cite: 87]. |
| **CloudWatch** | Monitoring & Logging | [cite_start]Used to monitor and troubleshoot the execution of the Glue ETL Jobs[cite: 89]. |

---

## 🛠️ Step-by-Step Execution Guide (Replicability)

This sequence describes the necessary setup for someone to replicate the pipeline in their environment.

1.  **Create IAM Roles & Permissions:** Create the necessary IAM roles (e.g., **`AWSGlueServiceRole-LogiStream`**) and attach policies granting access to S3, Glue, and Redshift. Configure VPC and Security Group rules to allow Redshift traffic on **Port 5439**.
2.  [cite_start]**Create S3 Buckets, Upload Data:** Create the required S3 buckets (e.g., `dataco-supply-chain-data`, `dataco-geospatial-data`) and upload files into the designated folders (`raw_data/`, `metadata/`, and `geojson/`)[cite: 83].
3.  **Create & Run Lambda Function:** Deploy and execute the saved Python Lambda function (`etl_jobs/lambda_geojson_processor.py`). [cite_start]This performs the initial transformation, writing the WKT CSV to the **`processed_routes/`** folder in S3[cite: 84].
4.  **Create & Run Glue Crawlers:** Create the **`logistream_db`** in the Glue Data Catalog. Run two separate crawlers: one on the **structured CSV folders** and one on the **`processed_routes/`** folder. [cite_start]This establishes the complete operational database[cite: 85].
5.  [cite_start]**Operational Database Verification (Athena):** Use **Amazon Athena** to query the new Catalog tables (`rawdata`, `processed_routes`) to confirm all sources are correctly cataloged and schema integrity is maintained[cite: 86].
6.  **Create Redshift Serverless DWH & DDL:** Provision the Redshift Serverless Workgroup and execute the **SQL DDL script** (`data_warehouse/ddl_snowflake_schema.sql`) to create all **9 empty dimension and fact tables**.
7.  **Create Connection:** Create the Glue JDBC Connection (**`Redshift connection`**) linking Glue to the Redshift Serverless cluster within the correct VPC configuration.
8.  **Create & Run Glue ETL Job (PySpark):** Create the Glue ETL job using **`etl_jobs/glue_master_etl.py`**. The job will:
    * Extract data from the cataloged sources.
    * Apply the dimensional modeling logic (generating keys and performing all joins).
    * [cite_start]Load the final Fact and Dimension tables into Redshift[cite: 87].
