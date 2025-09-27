SELECT * FROM insurance_claims LIMIT 50;

------------------------------------------------------------
--  Total number of insurance claims
------------------------------------------------------------
SELECT COUNT(*) AS total_claims
FROM insurance_claims;

------------------------------------------------------------
--  Count of fraudulent vs non-fraudulent claims
------------------------------------------------------------
SELECT fraud_reported,
       COUNT(*) AS claim_count
FROM insurance_claims
GROUP BY fraud_reported
ORDER BY claim_count DESC;

------------------------------------------------------------
--  Average total claim amount for fraud vs non-fraud
------------------------------------------------------------
SELECT fraud_reported,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_claims
GROUP BY fraud_reported;

------------------------------------------------------------
--  Total claim amount by vehicle make (Top 10)
------------------------------------------------------------
SELECT auto_make,
       SUM(total_claim_amount) AS total_claims_amount
FROM insurance_claims
GROUP BY auto_make
ORDER BY total_claims_amount DESC
LIMIT 10;

------------------------------------------------------------
--  Count of claims by incident type
------------------------------------------------------------
SELECT incident_type,
       COUNT(*) AS claim_count
FROM insurance_claims
GROUP BY incident_type
ORDER BY claim_count DESC;

------------------------------------------------------------
--  % Fraudulent Claims by Policy State
------------------------------------------------------------
SELECT policy_state,
       ROUND(100.0 * SUM(CASE WHEN fraud_reported = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2) AS percent_fraudulent
FROM insurance_claims
GROUP BY policy_state
ORDER BY percent_fraudulent DESC;

------------------------------------------------------------
--  Avg Claim Amount by Policy Deductible
------------------------------------------------------------
SELECT policy_deductable,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_claims
GROUP BY policy_deductable
ORDER BY policy_deductable;

------------------------------------------------------------
--  Customers with multiple claims
------------------------------------------------------------
SELECT insured_zip,
       COUNT(*) AS num_claims
FROM insurance_claims
GROUP BY insured_zip
HAVING COUNT(*) > 1
ORDER BY num_claims DESC;

------------------------------------------------------------
--  Claims per incident city (Top 15)
------------------------------------------------------------
SELECT incident_city,
       COUNT(*) AS claim_count
FROM insurance_claims
GROUP BY incident_city
ORDER BY claim_count DESC
LIMIT 15;

------------------------------------------------------------
--  Total & Avg claim amount by insured education level
------------------------------------------------------------
SELECT insured_education_level,
       SUM(total_claim_amount) AS total_claim_amount,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_claims
GROUP BY insured_education_level
ORDER BY total_claim_amount DESC;

------------------------------------------------------------
--  Top 5 incident types with highest avg claim amount
------------------------------------------------------------
SELECT incident_type,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_claims
GROUP BY incident_type
ORDER BY avg_claim_amount DESC
LIMIT 5;

------------------------------------------------------------
--  Claims by gender & fraud status
------------------------------------------------------------
SELECT insured_sex,
       fraud_reported,
       COUNT(*) AS claim_count
FROM insurance_claims
GROUP BY insured_sex, fraud_reported
ORDER BY insured_sex, fraud_reported;

------------------------------------------------------------
--  Avg Claim Amount by State & Fraud
------------------------------------------------------------
SELECT policy_state,
       fraud_reported,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim_amount
FROM insurance_claims
GROUP BY policy_state, fraud_reported
ORDER BY policy_state, avg_claim_amount DESC;

------------------------------------------------------------
--  Number of injury claims (injury_claim > 0)
------------------------------------------------------------
SELECT COUNT(*) AS injury_claims_count
FROM insurance_claims
WHERE injury_claim > 0;

------------------------------------------------------------
--  Fraudulent Claims by Vehicle Make
------------------------------------------------------------
SELECT auto_make,
       SUM(total_claim_amount) AS total_fraud_claims,
       ROUND(AVG(total_claim_amount), 2) AS avg_fraud_claim
FROM insurance_claims
WHERE fraud_reported = 'Y'
GROUP BY auto_make
ORDER BY total_fraud_claims DESC;

------------------------------------------------------------
--  Avg Claim by Incident Severity
------------------------------------------------------------
SELECT incident_severity,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY incident_severity
ORDER BY avg_claim DESC;

------------------------------------------------------------
--  Claims by Gender (Count & Value)
------------------------------------------------------------
SELECT insured_sex,
       COUNT(*) AS total_claims,
       SUM(total_claim_amount) AS total_claim_value
FROM insurance_claims
GROUP BY insured_sex
ORDER BY total_claims DESC;

------------------------------------------------------------
--  Collision Type vs Avg Claim
------------------------------------------------------------
SELECT collision_type,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY collision_type
ORDER BY avg_claim DESC;

------------------------------------------------------------
--  Claim Amount by Age Group
------------------------------------------------------------
SELECT CASE 
           WHEN age < 25 THEN 'Under 25'
           WHEN age BETWEEN 25 AND 40 THEN '25-40'
           WHEN age BETWEEN 41 AND 60 THEN '41-60'
           ELSE '60+'
       END AS age_group,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY age_group
ORDER BY avg_claim DESC;

------------------------------------------------------------
--  Top 5 States with Fraud Cases
------------------------------------------------------------
SELECT policy_state,
       COUNT(*) AS fraud_cases
FROM insurance_claims
WHERE fraud_reported = 'Y'
GROUP BY policy_state
ORDER BY fraud_cases DESC
LIMIT 5;

------------------------------------------------------------
--  Top 10 Customers with Highest Total Claims
------------------------------------------------------------
SELECT policy_number,
       SUM(total_claim_amount) AS total_claims
FROM insurance_claims
GROUP BY policy_number
ORDER BY total_claims DESC
LIMIT 10;

------------------------------------------------------------
--  Policy Holder’s Marital Status & Fraud Cases
------------------------------------------------------------
SELECT insured_education_level,
       insured_sex,
       insured_relationship,
       COUNT(*) FILTER (WHERE fraud_reported = 'Y') AS fraud_cases,
       COUNT(*) FILTER (WHERE fraud_reported = 'N') AS non_fraud_cases
FROM insurance_claims
GROUP BY insured_education_level, insured_sex, insured_relationship
ORDER BY fraud_cases DESC;

------------------------------------------------------------
--  Property vs Injury vs Vehicle Claim Comparison
------------------------------------------------------------
SELECT ROUND(AVG(property_claim), 2) AS avg_property_claim,
       ROUND(AVG(injury_claim), 2) AS avg_injury_claim,
       ROUND(AVG(vehicle_claim), 2) AS avg_vehicle_claim
FROM insurance_claims;

------------------------------------------------------------
--  Top 5 Incident Cities with Fraud
------------------------------------------------------------
SELECT incident_city,
       COUNT(*) AS fraud_cases
FROM insurance_claims
WHERE fraud_reported = 'Y'
GROUP BY incident_city
ORDER BY fraud_cases DESC
LIMIT 5;

------------------------------------------------------------
--  Avg Claim by Vehicle Age
------------------------------------------------------------
SELECT auto_year,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY auto_year
ORDER BY auto_year DESC;

------------------------------------------------------------
--  Claims by Collision Type (Count + Avg)
------------------------------------------------------------
SELECT collision_type,
       COUNT(*) AS total_claims,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY collision_type
ORDER BY total_claims DESC;

------------------------------------------------------------
-- Month-wise Claims Trend
------------------------------------------------------------
SELECT DATE_TRUNC('month', incident_date) AS claim_month,
       COUNT(*) AS total_claims,
       ROUND(AVG(total_claim_amount), 2) AS avg_claim
FROM insurance_claims
GROUP BY claim_month
ORDER BY claim_month;

------------------------------------------------------------
-- Deductible vs Fraud Rate
------------------------------------------------------------
SELECT policy_deductable,
       ROUND(100.0 * SUM(CASE WHEN fraud_reported = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_percent
FROM insurance_claims
GROUP BY policy_deductable
ORDER BY policy_deductable;

------------------------------------------------------------
-- Top Customers with Fraudulent Claims
------------------------------------------------------------
SELECT policy_number,
       COUNT(*) AS fraud_claims,
       SUM(total_claim_amount) AS fraud_total
FROM insurance_claims
WHERE fraud_reported = 'Y'
GROUP BY policy_number
ORDER BY fraud_total DESC
LIMIT 10;
