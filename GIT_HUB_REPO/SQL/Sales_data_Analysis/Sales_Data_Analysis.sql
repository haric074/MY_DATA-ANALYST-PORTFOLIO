-- Sales Data Analysis
--- @Raw Data ---- https://www.kaggle.com/kyanyoga/sample-sales-data

-- Display the entire sales_data_sample table
SELECT * FROM qatest.sales_data_sample;

-- Count the total number of rows in the sales_data_sample table
SELECT COUNT(*) FROM qatest.sales_data_sample;

-- Total Sales
SELECT SUM(SALES) AS Total_Sales FROM qatest.sales_data_sample; -- 10,032,628.85

-- Average Order Value
SELECT AVG(SALES) AS Average_Order_Value FROM qatest.sales_data_sample; -- 3,553.89

-- Total Quantity Sold
SELECT SUM(QUANTITYORDERED) AS Total_Quantity_Sold FROM qatest.sales_data_sample; -- 99,067

-- Number of Orders
SELECT COUNT(DISTINCT ORDERNUMBER) AS Number_of_Orders FROM qatest.sales_data_sample; -- 307

-- Sales by Product Line
SELECT PRODUCTLINE, SUM(SALES) AS Total_Sales FROM qatest.sales_data_sample GROUP BY PRODUCTLINE;
-- Trains             226,243.47
-- Motorcycles       1,166,388.34
-- Ships             714,437.13
-- Trucks and Buses  1,127,789.84
-- Vintage Cars      1,903,150.84
-- Classic Cars      3,919,615.66
-- Planes            975,003.57

-- Sales by Year and Quarter
SELECT YEAR_ID AS "Year", QTR_ID AS "Quarter", SUM(SALES) AS Total_Sales
FROM qatest.sales_data_sample
GROUP BY YEAR_ID, QTR_ID
ORDER BY YEAR_ID, QTR_ID ASC;
-- (results omitted for brevity)

-- Top Selling Products
SELECT PRODUCTLINE, SUM(SALES) AS Total_Sales FROM qatest.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY Total_Sales DESC;
-- Classic Cars       3,919,615.66
-- Vintage Cars       1,903,150.84
-- Motorcycles        1,166,388.34
-- Trucks and Buses   1,127,789.84
-- Planes             975,003.57
-- Ships              714,437.13
-- Trains             226,243.47

-- Monthly Sales Trend
-- Adding month name using month_id
ALTER TABLE qatest.sales_data_sample ADD COLUMN month_name VARCHAR(20);

UPDATE qatest.sales_data_sample
SET month_name = 
    CASE 
        WHEN month_id = 1 THEN 'January'
        WHEN month_id = 2 THEN 'February'
        WHEN month_id = 3 THEN 'March'
        WHEN month_id = 4 THEN 'April'
        WHEN month_id = 5 THEN 'May'
        WHEN month_id = 6 THEN 'June'
        WHEN month_id = 7 THEN 'July'
        WHEN month_id = 8 THEN 'August'
        WHEN month_id = 9 THEN 'September'
        WHEN month_id = 10 THEN 'October'
        WHEN month_id = 11 THEN 'November'
        WHEN month_id = 12 THEN 'December'
        ELSE 'Invalid Month'
    END;

-- Display monthly sales trend
SELECT month_name, SUM(SALES) AS Total_Sales
FROM qatest.sales_data_sample
GROUP BY month_name, qatest.sales_data_sample.MONTH_ID
ORDER BY qatest.sales_data_sample.MONTH_ID;
-- (results omitted for brevity)

-- Customer-based Metrics
-- Analyze customer-related metrics, such as total sales per customer, the number of orders per customer, etc.
SELECT CUSTOMERNAME, SUM(SALES) AS Total_Sales, COUNT(ORDERNUMBER) AS No_of_Orders
FROM qatest.sales_data_sample
GROUP BY CUSTOMERNAME;

-- Deal Size Analysis: Analyze the distribution of deal sizes.
SELECT DISTINCT(DEALSIZE), COUNT(DEALSIZE) AS Deal_Count, SUM(SALES) AS Total_Sales
FROM qatest.sales_data_sample
GROUP BY DEALSIZE;
