-- View all data
SELECT * FROM Telco_Customer_Churn_Data;


--  Total customers and churn count
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data;


--  Churn rate by contract type
SELECT 
    "Contract",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "Contract"
ORDER BY churn_rate_percent DESC;


--  Average MonthlyCharges and TotalCharges by churn status
SELECT 
    "Churn",
    ROUND(AVG("MonthlyCharges"), 2) AS avg_monthly_charges,
    ROUND(AVG("TotalCharges"), 2) AS avg_total_charges
FROM Telco_Customer_Churn_Data
GROUP BY "Churn";


--  Count of customers by tenure groups
SELECT 
    "TenureGroup",
    COUNT(*) AS customer_count
FROM Telco_Customer_Churn_Data
GROUP BY "TenureGroup"
ORDER BY "TenureGroup";


--  Percentage of churn by InternetService type
SELECT 
    "InternetService",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "InternetService"
ORDER BY churn_rate_percent DESC;


--  Count of customers by PaymentMethod and churn
SELECT 
    "PaymentMethod",
    "Churn",
    COUNT(*) AS count
FROM Telco_Customer_Churn_Data
GROUP BY "PaymentMethod", "Churn"
ORDER BY "PaymentMethod";


--  Average tenure by churn status
SELECT 
    "Churn",
    ROUND(AVG("tenure"), 2) AS avg_tenure
FROM Telco_Customer_Churn_Data
GROUP BY "Churn";


--  Customers with high monthly charges but no churn
SELECT *
FROM Telco_Customer_Churn_Data
WHERE "MonthlyCharges" > 100 AND "Churn" = 'No'
ORDER BY "MonthlyCharges" DESC;


--  Top 5 cities by customer count (if available)
SELECT "City", COUNT(*) AS customer_count
FROM Telco_Customer_Churn_Data
GROUP BY "City"
ORDER BY customer_count DESC
LIMIT 5;


-- Distribution of contract lengths
SELECT "Contract", COUNT(*) AS count
FROM Telco_Customer_Churn_Data
GROUP BY "Contract"
ORDER BY count DESC;


--  Average TotalCharges for customers with Fiber optic internet
SELECT 
    ROUND(AVG("TotalCharges"), 2) AS avg_total_charges
FROM Telco_Customer_Churn_Data
WHERE "InternetService" = 'Fiber optic';


--  Number of customers with multiple services
SELECT COUNT(*) AS count_multiple_services
FROM Telco_Customer_Churn_Data
WHERE "PhoneService" = 'Yes' AND "InternetService" != 'No';


--  Churn rate by gender
SELECT 
    "gender",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "gender"
ORDER BY churn_rate_percent DESC;


--  Average MonthlyCharges by PaymentMethod
SELECT 
    "PaymentMethod",
    ROUND(AVG("MonthlyCharges"), 2) AS avg_monthly_charges
FROM Telco_Customer_Churn_Data
GROUP BY "PaymentMethod"
ORDER BY avg_monthly_charges DESC;


--  Count of customers by InternetSecurity status and churn
SELECT 
    "InternetSecurity",
    "Churn",
    COUNT(*) AS count
FROM Telco_Customer_Churn_Data
GROUP BY "InternetSecurity", "Churn"
ORDER BY "InternetSecurity";


--  Churn by StreamingTV and StreamingMovies (Entertainment bundle effect)
SELECT 
    "StreamingTV",
    "StreamingMovies",
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    COUNT(*) AS total_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "StreamingTV", "StreamingMovies"
ORDER BY churn_rate_percent DESC;


--  Senior Citizens vs Churn
SELECT 
    "SeniorCitizen",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "SeniorCitizen"
ORDER BY churn_rate_percent DESC;


--  Churn rate by multiple lines
SELECT 
    "MultipleLines",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "MultipleLines"
ORDER BY churn_rate_percent DESC;


--  Churn rate by OnlineBackup service
SELECT 
    "OnlineBackup",
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS churn_rate_percent
FROM Telco_Customer_Churn_Data
GROUP BY "OnlineBackup"
ORDER BY churn_rate_percent DESC;


--  Top 10 high-value churned customers (most loss)
SELECT 
    "customerID", "MonthlyCharges", "TotalCharges", "tenure", "Contract"
FROM Telco_Customer_Churn_Data
WHERE "Churn" = 'Yes'
ORDER BY "TotalCharges" DESC
LIMIT 10;
