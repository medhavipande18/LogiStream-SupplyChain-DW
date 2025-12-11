# 🚀 LogiStream Supply Chain Data Pipeline: S3 to Redshift Data Warehouse

## 💡 Introduction: Project Aim and Scope

The **LogiStream** cloud data pipeline is engineered as a robust **hybrid solution**, optimized for scalable ingestion and transformation of both structured (CSV) and semi-structured (GeoJSON) data.  
This architecture utilizes **Amazon S3** for secure data staging and storage, **AWS Glue** for centralized data cataloging and complex **PySpark ETL** processing, and **AWS Lambda** for specialized GeoJSON flattening.  
The transformed, normalized data is consolidated into an **Amazon Redshift Serverless Data Warehouse**, enabling powerful, real-time operational dashboards for supply-chain analytics.

*Data Source:* https://www.kaggle.com/datasets/aaumgupta/refined-dataco-supply-chain-geospatial-dataset
---

## 📁 Repository Structure & Code Organization

```
The repository is structured to clearly separate infrastructure, ETL logic, DDL scripts, source data, and documentation for reproducibility.

LogiStream-SupplyChain-DW/
│
├── README.md                            # Project overview and replication guide (this file)
│
├── infrastructure/
│   ├── 01_iam_roles.json                # IAM policy and trust definitions
│   └── 02_redshift_vpc_config.json      # Redshift VPC and security group configuration
│
├── source_data/                         # Folder to upload raw and metadata source files
│   ├── raw_data/                        # Original CSV files
│   ├── geojson/                         # Raw GeoJSON input files
│   └── metadata/                        # Supporting data and mapping info
│
├── etl_jobs/
│   ├── lambda_geojson_processor.py      # Lambda function for GeoJSON flattening (WKT conversion)
│   └── glue_master_etl.py               # PySpark ETL script for Redshift loading
│
├── data_warehouse/
│   └── ddl_snowflake_schema.sql         # CREATE TABLE scripts for all 9 dimension and fact tables
│
├── bi_dashboards/
│   └── LogiStream_Analytics.pbix         # Power BI Dashboard
│   └── Dashboard.pdf                     # Power BI Dashboard Screenshots 
│
├── documentation/
│    └── Project_Report.pdf                # Final Project Report with all details.
└── image/
    └── architecture_diagram.png               # System Architecture


```
---

## 📐 Data Warehouse Creation and Multidimensional Modeling

The Data Warehouse was modeled by transforming flat operational data into an optimized **OLAP (Online Analytical Processing)** structure.

### Operational DB vs. Multidimensional Model

- **Operational Database (Source):**  
  Created by AWS Glue Crawlers, this database consists of high-volume flat files —  
  **`rawdata`** (transactional CSV) and **`processed_routes`** (flattened GeoJSON in WKT format).

- **Multidimensional Model (Target):**  
  The final **Snowflake Schema** in Redshift contains **8 Dimension tables** and **1 Fact table**,  
  designed to enhance analytical performance. Foreign keys link transactional measures to descriptive attributes.

### Key Analytical Features

- **Snowflake Hierarchy:**  
  The hierarchical structure — `dim_department` → `dim_category` → `dim_product` — supports multi-level profitability analysis.

- **Geospatial Integration:**  
  The `dim_route_shapes` table stores shipment routes as **WKT (Well-Known Text)** strings, enabling live geospatial dashboards in Tableau.

- **Operational Insights:**  
  The model supports **late-delivery alerts**, **route optimization**, and **carrier performance tracking**.

---

## 💻 AWS Architecture & Service Components

The pipeline is deployed entirely in **AWS US East (Ohio – `us-east-2`)**, using a serverless architecture for scalability and cost efficiency.

| Component | Role in Pipeline | Key Function |
|------------|------------------|---------------|
| **Amazon S3** | Data Lake / Staging Layer | Stores raw CSV, GeoJSON, and processed WKT outputs |
| **AWS Lambda** | Pre-processing Layer | Flattens nested GeoJSON into WKT (Well-Known Text) strings |
| **AWS Glue Crawlers** | Schema Discovery | Scans S3 folders and registers tables (`rawdata`, `processed_routes`) in the Glue Data Catalog |
| **Amazon Athena** | Verification Layer | Queries Catalog tables to verify schema and data integrity |
| **AWS Glue ETL (PySpark)** | Core Transformation Engine | Performs dimensional modeling, joins, and loads data into Redshift |
| **Amazon Redshift Serverless** | Data Warehouse | Stores final Snowflake schema for analytical querying |
| **Amazon CloudWatch** | Monitoring & Logging | Tracks execution and performance of ETL jobs |

![LogiStream Architecture](./images/architecture_diagram.png)

---

## 🛠️ Step-by-Step Execution Guide (Replicability)

Follow these steps to replicate the LogiStream data pipeline in your own AWS environment.

1. **Create IAM Roles & Permissions**  
   - Create necessary IAM roles (e.g., `AWSGlueServiceRole-LogiStream`)  
   - Attach policies granting access to S3, Glue, and Redshift  
   - Configure VPC and Security Group rules to allow Redshift traffic on **Port 5439**

2. **Create S3 Buckets & Upload Data**  
   - Create buckets such as `dataco-supply-chain-data` and `dataco-geospatial-data`  
   - Upload files into the following folders:  
     - `raw_data/`  
     - `metadata/`  
     - `geojson/`

3. **Create & Run Lambda Function**  
   - Deploy and execute `etl_jobs/lambda_geojson_processor.py`  
   - This function transforms GeoJSON into WKT CSV and writes it to the `processed_routes/` folder in S3

4. **Create & Run Glue Crawlers**  
   - Create the **`logistream_db`** database in AWS Glue Data Catalog  
   - Run two crawlers:  
     - One on the **structured CSV folders**  
     - One on the **`processed_routes/`** folder  
   - This establishes the operational database

5. **Operational Database Verification (Athena)**  
   - Use **Amazon Athena** to query `rawdata` and `processed_routes`  
   - Confirm all sources are properly cataloged and schema integrity is maintained

6. **Create Redshift Serverless DWH & DDL**  
   - Provision a Redshift Serverless Workgroup  
   - Execute `data_warehouse/ddl_snowflake_schema.sql`  
   - This creates all **8 Dimension** and **1 Fact** tables

7. **Create JDBC Connection**
   - In AWS Glue, create a **Redshift connection** (`Redshift connection`)  
   - Configure it to securely link Glue to your Redshift Serverless workgroup within the same VPC and subnet  
   - Ensure proper security group rules are in place to allow connectivity on **port 5439**

9. **Create & Run Glue ETL Job (PySpark)**  
   - Use `etl_jobs/glue_master_etl.py` to define the ETL workflow  
   - The job will:
     - Extract data from cataloged sources  
     - Apply dimensional modeling logic (key generation and joins)  
     - Load the final Fact and Dimension tables into Redshift  

---

## 📊 Business Intelligence & Insights
The project concludes with a 3-page Power BI dashboard designed for different organizational levels:

1. **Executive Summary (Strategic)**
Focuses on top-line growth and profitability hierarchy.
**Insight:** Identify high-margin product segments using the **Profitability Treemap** to prioritize marketing spend.

2. **Operational Performance (Tactical)**
Audits logistics reliability and risk.
**Insight:** Monitor **Schedule Adherence %** by carrier to optimize shipping modes and identify regional late-risk hotspots via geographic mapping.

3. **Order Detail (Forensic)**
Enables deep-dive investigation into specific problematic orders through **Drill-Through** functionality.

---

✅ **End Result:**  
A fully automated, serverless AWS data pipeline that ingests, transforms, and loads both CSV and GeoJSON data into a Redshift Snowflake Schema and finally an interactive Power BI Dashboard for proactive decision-making.