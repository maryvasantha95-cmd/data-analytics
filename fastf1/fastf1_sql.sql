select *
from fastf1_race_data


--  Count number of laps per driver
SELECT 
	"Driver",
	COUNT(*) AS lap_count
FROM fastf1_data
GROUP BY "Driver"
ORDER BY lap_count DESC;


--  Find the fastest lap time (min LapTime) for each driver (in seconds)
SELECT 
	"Driver",
	MIN(EXTRACT(EPOCH FROM "LapTime"::interval)) AS fastest_lap_seconds
FROM fastf1_data
GROUP BY "Driver"
ORDER BY fastest_lap_seconds ASC;


--  Average lap time per driver (in seconds)
SELECT
	"Driver",
	AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS avg_laptime_seconds
FROM fastf1_data
GROUP BY "Driver"
ORDER BY avg_laptime_seconds ASC;

--  Count laps by tyre compound
SELECT
	"Compound",
	COUNT(*) AS lap_count
FROM fastf1_data
GROUP BY "Compound"
ORDER BY lap_count DESC;


--  Average tyre life (TyreLife) by compound
SELECT
	"Compound",
	AVG("TyreLife") AS avg_tyre_life
FROM fastf1_data
GROUP BY "Compound"
ORDER BY avg_tyre_life DESC;


--  Percentage of null values per column (example for selected columns)
SELECT
  100.0 * SUM(CASE WHEN "PitInTime" IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS pct_null_pitintime,
  100.0 * SUM(CASE WHEN "LapTime" IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS pct_null_laptime,
  100.0 * SUM(CASE WHEN "Compound" IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS pct_null_compound
FROM fastf1_data;

--  Number of pit stops per driver (count of non-null PitInTime)
SELECT 
	"Driver",
	COUNT("PitInTime") AS pit_stop_count
FROM fastf1_data
WHERE "PitInTime" IS NOT NULL
GROUP BY "Driver"
ORDER BY pit_stop_count DESC;



--  Number of laps per driver per stint
SELECT 
	"Driver",
	"Stint",
	COUNT("LapNumber") AS laps_in_stint
FROM fastf1_data
GROUP BY 1,2
ORDER BY 1,2


--  Fastest sector times per driver (in seconds)
SELECT "Driver",
       MIN(EXTRACT(EPOCH FROM "Sector1Time"::interval)) AS sec1_fastest,
       MIN(EXTRACT(EPOCH FROM "Sector2Time"::interval)) AS sec2_fastest,
       MIN(EXTRACT(EPOCH FROM "Sector3Time"::interval)) AS sec3_fastest
FROM fastf1_data
GROUP BY "Driver"
ORDER BY sec1_fastest ASC;


--  Position changes of drivers over laps - lap-wise last position per driver
SELECT 
	"LapNumber",
	"Driver",
	MIN("Position") AS position
FROM fastf1_data
WHERE "Position" IS NOT NULL
GROUP BY "LapNumber", "Driver"
ORDER BY "LapNumber", position;

-- Lap Consistency: Lap Time Standard Deviation by Driver
SELECT 
  "Driver", 
  AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS avg_laptime_sec,
  STDDEV(EXTRACT(EPOCH FROM "LapTime"::interval)) AS stddev_laptime_sec,
  COUNT(*) AS lap_count
FROM fastf1_data
WHERE "LapTime" IS NOT NULL
GROUP BY "Driver"
ORDER BY stddev_laptime_sec ASC;


-- Identifying Anomalous or Slow Laps Indicating Reliability Issues
WITH driver_avg AS (
  SELECT 
    "Driver", 
    AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS avg_laptime_sec,
    STDDEV(EXTRACT(EPOCH FROM "LapTime"::interval)) AS stddev_laptime_sec
  FROM fastf1_data
  WHERE "LapTime" IS NOT NULL
  GROUP BY "Driver"
)
SELECT 
  f."Driver",
  f."LapNumber",
  f."LapTime",
  EXTRACT(EPOCH FROM "LapTime"::interval) AS lap_sec,
  da.avg_laptime_sec,
  da.stddev_laptime_sec,
  (EXTRACT(EPOCH FROM "LapTime"::interval) - da.avg_laptime_sec) / da.stddev_laptime_sec AS z_score
FROM fastf1_data f
JOIN driver_avg da ON f."Driver" = da."Driver"
WHERE "LapTime" IS NOT NULL
ORDER BY 7 DESC

-- Driver’s Average Position Gain/Loss per Lap
SELECT 
    "Driver",
    (MAX("Position") - MIN("Position")) AS net_position_change
FROM fastf1_data
WHERE "Position" IS NOT NULL
GROUP BY "Driver"
ORDER BY net_position_change ASC; -- negative = gained positions, positive = lost


-- Median Lap Time per Driver
SELECT 
    "Driver",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM "LapTime"::interval)) 
        AS median_laptime_sec
FROM fastf1_data
WHERE "LapTime" IS NOT NULL
GROUP BY "Driver"
ORDER BY median_laptime_sec ASC;


-- Longest Stint by Each Driver
SELECT 
    "Driver",
    "Stint",
    COUNT(*) AS stint_length
FROM fastf1_data
GROUP BY "Driver", "Stint"
ORDER BY stint_length DESC;


-- Pit Stop Impact on Lap Time (first lap after pit stop vs avg)
WITH pit_laps AS (
    SELECT 
        "Driver",
        "LapNumber",
        EXTRACT(EPOCH FROM "LapTime"::interval) AS lap_sec
    FROM fastf1_data
    WHERE "LapTime" IS NOT NULL
      AND "PitInTime" IS NOT NULL
)
SELECT 
    f."Driver",
    f."LapNumber" + 1 AS first_lap_after_pit,
    EXTRACT(EPOCH FROM f."LapTime"::interval) AS lap_after_pit_sec,
    da.avg_laptime_sec,
    (EXTRACT(EPOCH FROM f."LapTime"::interval) - da.avg_laptime_sec) AS delta
FROM fastf1_data f
JOIN (
    SELECT "Driver", AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS avg_laptime_sec
    FROM fastf1_data
    WHERE "LapTime" IS NOT NULL
    GROUP BY "Driver"
) da ON f."Driver" = da."Driver"
WHERE f."LapNumber" IN (SELECT "LapNumber" + 1 FROM pit_laps);


-- Best Average Sector Combination (Theoretical Best Lap)
SELECT 
    "Driver",
    MIN(EXTRACT(EPOCH FROM "Sector1Time"::interval)) +
    MIN(EXTRACT(EPOCH FROM "Sector2Time"::interval)) +
    MIN(EXTRACT(EPOCH FROM "Sector3Time"::interval)) AS theoretical_best_lap
FROM fastf1_data
GROUP BY "Driver"
ORDER BY theoretical_best_lap ASC;


-- Tyre Compound Usage Distribution by Driver
SELECT 
    "Driver",
    "Compound",
    COUNT(*) AS laps_on_compound
FROM fastf1_data
GROUP BY "Driver", "Compound"
ORDER BY "Driver", laps_on_compound DESC;


-- Detecting Fuel-Load Effect (Early vs Late Race Lap Times)
SELECT 
    "Driver",
    AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) FILTER (WHERE "LapNumber" <= 10) AS avg_first_10_laps,
    AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) FILTER (WHERE "LapNumber" > 40) AS avg_last_10plus_laps
FROM fastf1_data
WHERE "LapTime" IS NOT NULL
GROUP BY "Driver"
ORDER BY avg_first_10_laps;


-- Top 5 Consistently Fast Drivers (Coefficient of Variation)
SELECT 
    "Driver",
    AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS avg_lap,
    STDDEV(EXTRACT(EPOCH FROM "LapTime"::interval)) / AVG(EXTRACT(EPOCH FROM "LapTime"::interval)) AS coeff_variation
FROM fastf1_data
WHERE "LapTime" IS NOT NULL
GROUP BY "Driver"
ORDER BY coeff_variation ASC
LIMIT 5;