use HAPPY

USE project;

------------------------------------------------------------
-- 1. DATA CLEANING
------------------------------------------------------------

-- Handle missing values in fare
SELECT * FROM rides_dataset1 WHERE fare IS NULL;
DELETE FROM rides_dataset1 WHERE fare IS NULL;

-- Replace NULL fares with 0 (for reporting)
SELECT ride_id, COALESCE(fare, 0) AS fare_cleaned
FROM rides_dataset1;

select* from rides_dataset1
-- Remove duplicate rides
WITH ranked_rides AS (
    SELECT ride_id,
           ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY ride_id) AS RN
    FROM rides_dataset1
)
DELETE FROM rides_dataset1
WHERE ride_id IN (SELECT ride_id FROM ranked_rides WHERE RN > 1);

-- Remove cities with missing population
select * FROM city_dataset2 WHERE population IS NULL;

DELETE FROM city_dataset2 WHERE population IS NULL;

-- Check duplicate rides
SELECT ride_id, COUNT(*) AS count
FROM rides_dataset1
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Ensure driver consistency
DELETE FROM driver_dataset3
WHERE driver_id NOT IN (SELECT driver_id FROM rides_dataset1);

------------------------------------------------------------
-- 2. CITY-LEVEL PERFORMANCE OPTIMIZATION
------------------------------------------------------------

-- Top 3 cities needing driver recruitment
SELECT TOP 3 c.city_name,
       COUNT(r.ride_id) AS total_rides,
       SUM(CASE WHEN r.ride_status = 'Canceled' THEN 1 ELSE 0 END) AS canceled_rides,
       ROUND(AVG(d.avg_driver_rating), 2) AS avg_driver_rating
FROM rides_dataset1 r
JOIN driver_dataset3 d ON r.driver_id = d.driver_id
JOIN city_dataset2 c ON d.city_id = c.city_id
GROUP BY c.city_name
ORDER BY canceled_rides DESC, avg_driver_rating ASC;

------------------------------------------------------------
-- 3. REVENUE LEAKAGE ANALYSIS
------------------------------------------------------------

-- Detect completed rides without proper payment
SELECT r.ride_id, r.ride_status, r.fare, p.fare AS paid_fare, p.transaction_status
FROM rides_dataset1 r
LEFT JOIN payment_dataset4 p ON r.ride_id = p.ride_id
WHERE r.ride_status = 'Completed'
  AND (p.fare IS NULL OR p.transaction_status != 'Completed');

------------------------------------------------------------
-- 4. CANCELLATION ANALYSIS
------------------------------------------------------------

-- Cancellation patterns across cities
SELECT r.start_city,
       r.ride_status,
       COUNT(*) AS ride_count,
       ROUND(SUM(CASE WHEN r.ride_status = 'Completed' THEN r.fare ELSE 0 END), 2) AS completed_revenue
FROM rides_dataset1 r
GROUP BY r.start_city, r.ride_status
ORDER BY ride_count DESC;

-- Cancellation patterns by vehicle type
SELECT r.start_city,
       d.vehicle_type,
       COUNT(*) AS total_rides,
       SUM(CASE WHEN r.ride_status = 'Canceled' THEN 1 ELSE 0 END) AS cancellations,
       SUM(CASE WHEN r.ride_status = 'Completed' THEN r.fare ELSE 0 END) AS revenue
FROM rides_dataset1 r
JOIN driver_dataset3 d ON r.driver_id = d.driver_id
GROUP BY r.start_city, d.vehicle_type;

-- Cancellation patterns by time of day
SELECT DATEPART(HOUR, r.start_time) AS hour_of_day,
       COUNT(*) AS ride_count,
       SUM(CASE WHEN r.ride_status = 'Completed' THEN r.fare ELSE 0 END) AS completed_revenue
FROM rides_dataset1 r
GROUP BY DATEPART(HOUR, r.start_time)
ORDER BY ride_count DESC;

------------------------------------------------------------
-- 5. SEASONAL FARE VARIATIONS
------------------------------------------------------------

SELECT CASE 
         WHEN MONTH(ride_date) IN (3,4,5) THEN 'Spring'
         WHEN MONTH(ride_date) IN (6,7,8) THEN 'Summer'
         WHEN MONTH(ride_date) IN (9,10,11) THEN 'Autumn'
         ELSE 'Winter'
       END AS season,
       sum(fare) AS Total_fare
FROM rides_dataset1
GROUP BY CASE 
           WHEN MONTH(ride_date) IN (3,4,5) THEN 'Spring'
           WHEN MONTH(ride_date) IN (6,7,8) THEN 'Summer'
           WHEN MONTH(ride_date) IN (9,10,11) THEN 'Autumn'
           ELSE 'Winter'
         END;

------------------------------------------------------------
-- 6. AVERAGE RIDE DURATION BY CITY
------------------------------------------------------------

SELECT start_city,
       ROUND(AVG(DATEDIFF(MINUTE, start_time, end_time)), 2) AS avg_duration_minutes
FROM rides_dataset1
GROUP BY start_city;

------------------------------------------------------------
-- 7. PERFORMANCE OPTIMIZATION WITH INDEXES
------------------------------------------------------------

-- Index for ride_date filtering
CREATE INDEX idx_ride_date ON rides_dataset1(ride_date);

-- Index for payment method filtering
CREATE INDEX idx_payment_method ON payment_dataset4(payment_method);

------------------------------------------------------------
-- 8. VIEWS FOR QUICK REPORTING
------------------------------------------------------------

-- Average fare by city
CREATE VIEW avg_fare_by_city AS
SELECT c.city_name,
       ROUND(AVG(r.fare), 2) AS average_fare
FROM rides_dataset1 r
INNER JOIN city_dataset2 c ON r.start_city = c.city_id
WHERE r.fare IS NOT NULL
GROUP BY c.city_name;

select * from avg_fare_by_city 

-- Driver performance metrics
CREATE VIEW driver_performance AS
SELECT d.driver_id,
       d.driver_name,
       ROUND(d.avg_driver_rating, 2) AS avg_rating,
       d.total_rides,
       ROUND(d.total_earnings, 2) AS total_earnings,
       ROUND(d.ride_acceptance_rate, 2) AS acceptance_rate
FROM driver_dataset3 d;

select * from driver_performance
------------------------------------------------------------
-- 9. TRIGGERS FOR AUDITING
------------------------------------------------------------

-- Ride status change logging
CREATE TABLE ride_status_log (
    log_id INT IDENTITY PRIMARY KEY,
    ride_id INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_time DATETIME
);

CREATE TRIGGER trg_ride_status_change
ON rides_dataset1
AFTER UPDATE
AS
BEGIN
  IF UPDATE(ride_status)
  BEGIN
    INSERT INTO ride_status_log (ride_id, old_status, new_status, change_time)
    SELECT d.ride_id, d.ride_status, i.ride_status, GETDATE()
    FROM deleted d
    JOIN inserted i ON d.ride_id = i.ride_id;
  END
END;