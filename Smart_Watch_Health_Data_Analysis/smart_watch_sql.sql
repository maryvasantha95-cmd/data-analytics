SELECT * FROM unclean_smartwatch_health_data LIMIT 10;

-- Row counts & unique users
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT "User ID") AS unique_users
FROM unclean_smartwatch_health_data;

-- Count nulls in critical columns
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN "Step Count" IS NULL THEN 1 ELSE 0 END) AS null_steps,
  SUM(CASE WHEN "Sleep Duration (hours)" IS NULL THEN 1 ELSE 0 END) AS null_sleep,
  SUM(CASE WHEN "Stress Level" IS NULL THEN 1 ELSE 0 END) AS null_stress,
  SUM(CASE WHEN "Activity Level" IS NULL THEN 1 ELSE 0 END) AS null_activity
FROM unclean_smartwatch_health_data;

-- Distinct values in Activity Level (spot typos)
SELECT "Activity Level", COUNT(*) 
FROM unclean_smartwatch_health_data
GROUP BY "Activity Level"
ORDER BY COUNT(*) DESC;

--  CREATE CLEANED TABLE

DROP TABLE IF EXISTS cleaned_smartwatch_health_data;

CREATE TABLE cleaned_smartwatch_health_data AS
SELECT
  "User ID"                                  AS user_id,
  COALESCE(NULLIF(TRIM("Activity Level"),''), 'unknown') AS activity_level_raw,
  CASE
    WHEN lower(TRIM("Activity Level")) IN ('low','sedentary','inactive') THEN 'Low'
    WHEN lower(TRIM("Activity Level")) IN ('medium','moderate','avg') THEN 'Medium'
    WHEN lower(TRIM("Activity Level")) IN ('high','very active','active') THEN 'High'
    ELSE 'Other'
  END AS activity_level,
  CASE WHEN "Step Count" >= 0 THEN "Step Count" ELSE NULL END AS step_count,
  CASE WHEN "Sleep Duration (hours)" BETWEEN 0 AND 24 THEN "Sleep Duration (hours)" ELSE NULL END AS sleep_hours,
  CASE WHEN "Stress Level" BETWEEN 0 AND 10 THEN "Stress Level" ELSE NULL END AS stress_level,
  record_timestamp::timestamp AS record_ts
FROM unclean_smartwatch_health_data

-- SUMMARY STATISTICS & OUTLIER DETECTION


-- Summary stats
SELECT
    MIN(step_count) AS min_steps,
    MAX(step_count) AS max_steps,
    AVG(step_count) AS avg_steps,
    STDDEV_POP(step_count) AS std_steps,
    MIN(sleep_hours) AS min_sleep,
    MAX(sleep_hours) AS max_sleep,
    AVG(sleep_hours) AS avg_sleep,
    STDDEV_POP(sleep_hours) AS std_sleep,
    MIN(stress_level) AS min_stress,
    MAX(stress_level) AS max_stress,
    AVG(stress_level) AS avg_stress,
    STDDEV_POP(stress_level) AS std_stress
FROM cleaned_smartwatch_health_data;

-- Step count distribution in bins
SELECT
    width_bucket(step_count, 0, 30000, 15) AS step_count_bin,
    AVG(stress_level) AS avg_stress_level,
    COUNT(*) AS records_in_bin
FROM cleaned_smartwatch_health_data
GROUP BY step_count_bin
ORDER BY step_count_bin;

-- Correlation matrix
SELECT
  corr(step_count, sleep_hours)      AS corr_steps_sleep,
  corr(step_count, stress_level)     AS corr_steps_stress,
  corr(sleep_hours, stress_level)    AS corr_sleep_stress
FROM cleaned_smartwatch_health_data;

-- IQR outlier detection (step count)
WITH q AS (
  SELECT
    percentile_cont(0.25) WITHIN GROUP (ORDER BY step_count) AS q1,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY step_count) AS q3
  FROM cleaned_smartwatch_health_data
)
SELECT c.*
FROM cleaned_smartwatch_health_data c, q
WHERE c.step_count IS NOT NULL
  AND (c.step_count < (q.q1 - 1.5 * (q.q3 - q.q1))
       OR c.step_count > (q.q3 + 1.5 * (q.q3 - q.q1)))
ORDER BY c.step_count DESC
LIMIT 50;


-- Average step count per user
SELECT user_id, AVG(step_count) AS avg_steps
FROM cleaned_smartwatch_health_data
GROUP BY user_id
ORDER BY avg_steps DESC;

-- Users with average step count < 5000 (sedentary)
SELECT user_id, AVG(step_count) AS avg_steps
FROM cleaned_smartwatch_health_data
GROUP BY user_id
HAVING AVG(step_count) < 5000
ORDER BY avg_steps;

-- Average sleep duration grouped by activity level
SELECT activity_level, AVG(sleep_hours) AS avg_sleep_duration
FROM cleaned_smartwatch_health_data
GROUP BY activity_level
ORDER BY avg_sleep_duration DESC;

-- Contingency table: activity level × stress category
SELECT activity_level,
       CASE 
           WHEN stress_level < 3 THEN 'Low'
           WHEN stress_level BETWEEN 3 AND 6 THEN 'Medium'
           ELSE 'High'
       END AS stress_category,
       COUNT(*) AS count
FROM cleaned_smartwatch_health_data
GROUP BY activity_level, stress_category
ORDER BY activity_level, stress_category;

--  FEATURE ENGINEERING (per user, 30-day window)

WITH maxd AS (
  SELECT MAX(record_ts::date) AS max_day FROM cleaned_smartwatch_health_data
),
recent AS (
  SELECT *
  FROM cleaned_smartwatch_health_data, maxd
  WHERE record_ts::date BETWEEN maxd.max_day - INTERVAL '29 days' AND maxd.max_day
)
SELECT
  user_id,
  COUNT(*) AS obs_30d,
  ROUND(AVG(step_count),2) AS avg_steps_30d,
  ROUND(AVG(CASE WHEN record_ts::date >= (maxd.max_day - INTERVAL '6 days') THEN step_count END),2) AS avg_steps_7d,
  ROUND(STDDEV_POP(step_count),2) AS steps_stddev_30d,
  ROUND(100.0 * SUM(CASE WHEN step_count >= 7000 THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS pct_days_>=7000_30d,
  ROUND(AVG(sleep_hours),2) AS avg_sleep_30d,
  ROUND(STDDEV_POP(sleep_hours),2) AS sleep_stddev_30d,
  ROUND(AVG(stress_level),2) AS avg_stress_30d
FROM recent CROSS JOIN (SELECT max(record_ts::date) AS max_day FROM cleaned_smartwatch_health_data) maxd
GROUP BY user_id
ORDER BY avg_steps_30d DESC
LIMIT 100;


