/*
******************************
EXTRACT, TRANSFORM, LOAD
******************************

    - First I loaded the CSV files into Excel and transformed the data into desired columns and proper format.
    - Then I created the schema/database, created 8 relational tables, and loaded the data into the tables.
*/
CREATE SCHEMA olist;
USE olist;

CREATE TABLE orders (
	order_id CHAR(10) NOT NULL,
	category_name VARCHAR(50),
	name_length INT,
	description_length INT,
	photos_qty INT,
	length_cm INT,
	height_cm INT,
	width_cm INT,
PRIMARY KEY (order_id)
);

LOAD DATA INFILE 'olist_orders_dataset_cleaned.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE products (
	product_id CHAR(10) NOT NULL,
	category_name VARCHAR(50),
	name_length INT,
	description_length INT,
	photos_qty INT,
	weight_gram INT,
	length_cm INT,
	height_cm INT,
	width_cm INT,
PRIMARY KEY (product_id)
);

LOAD DATA INFILE 'olist_products_dataset_cleaned.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE order_items (
	order_id VARCHAR(10) NOT NULL,
	order_item_id INT NOT NULL,
	product_id VARCHAR(10) NOT NULL,
	seller_id VARCHAR(10) NOT NULL,
	shipping_limit_date DATETIME,
	price DECIMAL (7,2),
	freight_value DECIMAL (5,2)
);

LOAD DATA INFILE 'olist_order_items_dataset_cleaned.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE customers (
	customer_id VARCHAR(10) NOT NULL,
	customer_unique_id VARCHAR(10) NOT NULL,
	zip_code INT,
	city VARCHAR(50),
	state VARCHAR(2),
PRIMARY KEY (customer_id)
);

LOAD DATA INFILE 'olist_customers_dataset_cleaned.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE order_payments (
	order_id VARCHAR(10) NOT NULL,
	payment_sequential INT,
	payment_type VARCHAR(15),
	payment_installments INT,
	payment_value DECIMAL(7,2)
);

LOAD DATA INFILE 'olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE sellers (
	seller_id CHAR(10) NOT NULL,
	zip_code INT NOT NULL,
	city VARCHAR (50) NOT NULL,
	state INT NOT NULL,
PRIMARY KEY (seller_id)
);

LOAD DATA INFILE 'olist_sellers_dataset_cleaned.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE mql (
	mql_id CHAR(10) NOT NULL,
	first_contact_date DATE,
	landing_page_id CHAR(10) NOT NULL,
	origin VARCHAR(30),
PRIMARY KEY (mql_id)
);

LOAD DATA INFILE 'olist_marketing_qualified_leads_dataset_cleaned.csv'
INTO TABLE mql
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE closed_deals (
	mql_id CHAR(10),
	seller_id CHAR(10),
	sdr_id CHAR(10),
	sr_id CHAR(10),
	won_date DATETIME,
	business_segment VARCHAR(50),
	lead_type VARCHAR(50),
	lead_behavior_profile VARCHAR(25),
	has_company VARCHAR(10),
	has_gtin VARCHAR(10),
	average_stock VARCHAR(50),
	business_type VARCHAR(50),
	declared_product_catalog_size INT,
	declared_monthly_revenue INT
);
    

LOAD DATA INFILE 'olist_closed_deals_dataset_cleaned.csv'
INTO TABLE closed_deals
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


