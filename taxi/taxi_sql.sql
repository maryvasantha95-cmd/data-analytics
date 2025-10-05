SELECT *FROM Taxi_Trip_Data;

--  Count trips by passenger count
SELECT 
	passenger_count,
	COUNT(*) AS trip_count
FROM Taxi_Trip_Data
GROUP BY passenger_count
ORDER BY trip_count DESC;



--  Sort trips by trip distance ascending
SELECT *
FROM Taxi_Trip_Data
ORDER BY trip_distance ASC;



--  Convert datetime columns to proper timestamp
ALTER TABLE Taxi_Trip_Data 
ALTER COLUMN tpep_pickup_datetime TYPE TIMESTAMP
USING TO_TIMESTAMP(tpep_pickup_datetime, 'MM/DD/YYYY HH12:MI:SS AM');

ALTER TABLE Taxi_Trip_Data 
ALTER COLUMN tpep_dropoff_datetime TYPE TIMESTAMP
USING TO_TIMESTAMP(tpep_dropoff_datetime, 'MM/DD/YYYY HH12:MI:SS AM');



--  Hourly trip count & average fare
SELECT 
  EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
  COUNT(*) AS trip_count,
  ROUND(AVG(fare_amount)::numeric, 2) AS avg_fare
FROM Taxi_Trip_Data
GROUP BY pickup_hour
ORDER BY pickup_hour;



--  Average fare amount by passenger count
SELECT 
	passenger_count,
	AVG(fare_amount) AS avg_fare
FROM Taxi_Trip_Data
GROUP BY passenger_count
ORDER BY passenger_count;



--  Most common trip distance (mode approximation)
SELECT
	trip_distance,
	COUNT(*) AS frequency
FROM Taxi_Trip_Data
GROUP BY trip_distance
ORDER BY frequency DESC;



--  Top 10 longest trips
SELECT *
FROM Taxi_Trip_Data
ORDER BY trip_distance DESC
LIMIT 10;



--  Average fare amount overall
SELECT 
	AVG(fare_amount) AS overall_avg_fare
FROM Taxi_Trip_Data;



--  Total revenue per trip (fare + tip)
SELECT 
	fare_amount + tip_amount AS total_revenue
FROM Taxi_Trip_Data;



-- Average fare by payment type
SELECT
	payment_type,
	AVG(fare_amount) AS avg_fare
FROM Taxi_Trip_Data
GROUP BY payment_type
ORDER BY payment_type;



--  Revenue by day of week
SELECT 
  TO_CHAR(tpep_pickup_datetime, 'Day') AS day_of_week,
  SUM(fare_amount + tip_amount) AS total_revenue
FROM Taxi_Trip_Data
GROUP BY day_of_week
ORDER BY total_revenue DESC;



--  Top 10 pickup locations by trip count
SELECT 
  "PULocationID", 
  COUNT(*) AS trip_count
FROM Taxi_Trip_Data
GROUP BY 1
ORDER BY trip_count DESC
LIMIT 10;



--  Average tip percentage by payment type
SELECT 
  payment_type, 
  AVG(CASE WHEN fare_amount > 0 THEN (tip_amount / fare_amount) * 100 ELSE 0 END) AS avg_tip_pct
FROM Taxi_Trip_Data
GROUP BY payment_type;



--  Trips longer than 30 miles and their average fare
SELECT 
  COUNT(*) AS long_trips,
  AVG(fare_amount) AS avg_fare_long_trips
FROM Taxi_Trip_Data
WHERE trip_distance > 30;



--  Busiest hour by total trips and average trip duration
SELECT 
  EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
  COUNT(*) AS total_trips,
  AVG(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60) AS avg_trip_duration_minutes
FROM Taxi_Trip_Data
GROUP BY pickup_hour
ORDER BY total_trips DESC
LIMIT 1;



--  Average total amount (fare + tip + tolls) by passenger count
SELECT 
  passenger_count,
  AVG(fare_amount + tip_amount + tolls_amount) AS avg_total_amount
FROM Taxi_Trip_Data
GROUP BY passenger_count
ORDER BY passenger_count;



--  Top 5 longest average trips per RatecodeID
SELECT 
  "RatecodeID",
  AVG(trip_distance) AS avg_trip_distance
FROM Taxi_Trip_Data
GROUP BY 1
ORDER BY avg_trip_distance DESC
LIMIT 5;



--  Count of trips where store_and_fwd_flag = 'Y'
SELECT 
  COUNT(*) AS store_and_fwd_trips
FROM Taxi_Trip_Data
WHERE store_and_fwd_flag = 'Y';



--  Average trip duration (in minutes) by day of week
SELECT 
  TO_CHAR(tpep_pickup_datetime, 'Day') AS day_of_week,
  ROUND(AVG(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60),2) AS avg_duration_minutes
FROM Taxi_Trip_Data
GROUP BY day_of_week
ORDER BY avg_duration_minutes DESC;



--  Average speed (miles per hour) per trip
SELECT 
  trip_distance,
  ROUND((trip_distance / (EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/3600))::numeric, 2) AS avg_speed_mph
FROM Taxi_Trip_Data
WHERE trip_distance > 0
AND (EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) > 0);



-- 21️⃣ Correlation check between fare and trip distance (approximate)
SELECT 
  ROUND(CORR(fare_amount, trip_distance)::numeric, 3) AS fare_distance_correlation
FROM Taxi_Trip_Data;



--  Identify potential fare outliers (very high fares)
SELECT *
FROM Taxi_Trip_Data
WHERE fare_amount > (
  SELECT AVG(fare_amount) + 3 * STDDEV(fare_amount)
  FROM Taxi_Trip_Data
)
ORDER BY fare_amount DESC;



--  Total revenue by month
SELECT 
  TO_CHAR(tpep_pickup_datetime, 'Month') AS month_name,
  SUM(fare_amount + tip_amount) AS total_revenue
FROM Taxi_Trip_Data
GROUP BY month_name
ORDER BY total_revenue DESC;



--  Average fare per mile
SELECT 
  ROUND(AVG(fare_amount / NULLIF(trip_distance, 0)), 2) AS avg_fare_per_mile
FROM Taxi_Trip_Data;



--  Distribution of trip durations (bucketed)
SELECT 
  CASE 
    WHEN EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60 < 5 THEN '<5 min'
    WHEN EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60 < 15 THEN '5-15 min'
    WHEN EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60 < 30 THEN '15-30 min'
    WHEN EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60 < 60 THEN '30-60 min'
    ELSE '60+ min'
  END AS duration_bucket,
  COUNT(*) AS trip_count
FROM Taxi_Trip_Data
GROUP BY duration_bucket
ORDER BY trip_count DESC;



--  Identify top 10 drop-off locations by revenue
SELECT 
  "DOLocationID",
  SUM(fare_amount + tip_amount) AS total_revenue
FROM Taxi_Trip_Data
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;
