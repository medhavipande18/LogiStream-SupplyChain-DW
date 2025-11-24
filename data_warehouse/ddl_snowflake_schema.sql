-- 1. Department Dimension
CREATE TABLE dim_department (
    dept_key INT IDENTITY(1,1) PRIMARY KEY,
    dept_id INT,
    dept_name VARCHAR(255)
);

-- 2. Category Dimension
CREATE TABLE dim_category (
    cat_key INT IDENTITY(1,1) PRIMARY KEY,
    cat_id INT,
    cat_name VARCHAR(255),
    dept_key INT REFERENCES dim_department(dept_key)
);

-- 3. Product Dimension
CREATE TABLE dim_product (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_card_id INT,
    product_name VARCHAR(255),
    product_price DECIMAL(10,2),
    product_image VARCHAR(500),
    cat_key INT REFERENCES dim_category(cat_key)
);

-- 4. Customer Dimension
CREATE TABLE dim_customer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    segment VARCHAR(100)
);

-- 5. Geography Dimension (Unified Location)
CREATE TABLE dim_geography (
    geo_key INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(100),
    market VARCHAR(100),
    latitude FLOAT,
    longitude FLOAT
);

-- 6. Date Dimension
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date_actual DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    day_of_week VARCHAR(20),
    quarter INT
);

-- 7. Execution Status (Junk Dimension)
CREATE TABLE dim_execution_status (
    status_key INT IDENTITY(1,1) PRIMARY KEY,
    shipping_mode VARCHAR(100),
    delivery_status VARCHAR(100),
    order_status VARCHAR(100)
);

-- 8. Route Shapes (For the GeoJSON Data)
CREATE TABLE dim_route_shapes (
    route_shape_key INT IDENTITY(1,1) PRIMARY KEY,
    origin_lat FLOAT,
    origin_long FLOAT,
    dest_lat FLOAT,
    dest_long FLOAT,
    shape_wkt VARCHAR(65535) -- Stores the path string for Tableau
);

-- 9. The Fact Table
CREATE TABLE fact_supplychain_events (
    fact_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    order_item_id INT,
    sales DECIMAL(10,2),
    quantity INT,
    discount_rate DECIMAL(10,2),
    profit DECIMAL(10,2),
    days_real INT,
    days_scheduled INT,
    late_risk INT,
    
    -- Foreign Keys
    product_key INT REFERENCES dim_product(product_key),
    customer_key INT REFERENCES dim_customer(customer_key),
    status_key INT REFERENCES dim_execution_status(status_key),
    order_date_key INT REFERENCES dim_date(date_key),
    shipping_date_key INT REFERENCES dim_date(date_key),
    order_geo_key INT REFERENCES dim_geography(geo_key),
    customer_geo_key INT REFERENCES dim_geography(geo_key),
    route_shape_key INT REFERENCES dim_route_shapes(route_shape_key)
);