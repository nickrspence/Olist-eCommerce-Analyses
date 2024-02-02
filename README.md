<H2>Olist eCommerce data analysis / Power BI dashboards</H2>

<H3> Brief </H3>

- This real dataset is provided by Olist, the largest department store in Brazilian marketplaces. Olist connects small businesses to channels.
Those merchants are able to sell their products through the Olist Store and ship them directly to the customers using Olist logistics partners.
- This dataset was sourced from Kaggle, and it has been anonymized and sampled from the original dataset.
- This dataset provides information of 100k orders from 2017-2018 including price, payment, freight performance, customer location, product attributes, and vendors.

<H4> The Project </H4>

- I will act as a data analyst that seeks to assit the Olist Company to derive useful insights from their data and to provide recommendations.

I will split up the analyses into four sections and analyses:

1)  Sales Analyses
    - Quarterly product sales
    - Monthly product sales
    - Shipping time
    - Product order details
2)  Customer Analyses
    - Sales by geography
    - Comparative revenues of states and cities
3)  Product Analyses
     - Top selling product categories
     - Product categories by state
     - Seasonality of product categories
4)  Marketing Funnel Analyses
     - Top lead sources
     - Volume of closed deals
     - Conversion rates of lead sources

<H3> Data Set </H3>

-  Created 8-table relational database with key mapping, EER diagram, constraints -- see EER diagram in files section

-  Full source data included as ZIP file in project repository. Additionally, links are provided to Kaggle project pages.

<H4> Extract, Transform, Load (ETL) </H4>

- The Kaggle project provided CSV files for each of the 8 data sets. I performed the steps below to prepare the data for analyses.
1) Download each CSV file into an Excel worksheet
2) Clean, prepare, and format the data before importing into MySQL
        - Reduced each key id value column to only 10 characters for the purpose of manageability and data size
        - Removed unnecessary duplicate rows
        - Removed rows with missing data that was necessary
        - Added "0"s to the beginning of values where it was automatically removed upon upload (i.e. zipcodes, key IDs)
        - Replaced all empty cells with "\N" in order to import via LOAD INFILE function.
        - Formatted all dates and times according to MySQL format (i.e. ' yyy-mm-dd hh:mm:ss ')
        - Translated product categories into english for easier viewing
3) Created 8 tables in MySQL with identical columns as cleaned CSV files (see Olist_ETL file)
4) Ran 8 LOAD INFILE queries to load the data into each SQL table (see Olist_ETL file)
5) Validated that all the data was imported without error and fully


<H3> Power BI Visualizations </H3>

- Two Power BI dashboards are attached in PDF form in the projet files section. Unfortunately I am unable to share the interactive versions with no Power BI Pro license account.
- Used Power Query ETL, key mapping, dynamic dashboard, KPIs, slicers, DAX
1. Sales Dashboard
2. Website Activity Dashboard
