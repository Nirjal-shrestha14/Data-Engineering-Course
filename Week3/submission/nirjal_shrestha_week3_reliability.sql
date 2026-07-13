--Q1 Indexes and measure 
-- Recording before applying indexes 
EXPLAIN ANALYZE SELECT * FROM trips WHERE driver_id = 3; 
EXPLAIN ANALYZE SELECT * FROM trips WHERE status = 'cancelled';
EXPLAIN ANALYZE SELECT * FROM trips WHERE driver_id = 3 AND status = 'completed'; 
--Adding Indexes
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_driver_status ON trips(driver_id,status) -- composite index

--              :  Before          After 
--Execution Time:  1.724 ms       0.176 ms
--Execution Time:  0.554 ms       0.303 ms
--Execution Time:  0.365 ms       0.233 ms

--Q2 completed_trips_view
CREATE OR REPLACE VIEW completed_trips_view AS
SELECT 
    t.trip_id,
    d.name AS driver_name,
    p.name AS passenger_name,
    pck.city_name AS pickup_city,
    drp.city_name AS dropoff_city,
    t.fare_amount,
    t.distance_km,
    t.rating,
    pm.name AS payment_method,
    t.requested_at,
    t.completed_at
FROM trips t 
JOIN drivers d ON t.driver_id = d.driver_id
JOIN passengers p ON t.passenger_id = p.passenger_id
JOIN locations pck ON t.pickup_location_id = pck.location_id
JOIN locations drp ON t.dropoff_location_id = drp.location_id
LEFT JOIN payment_methods pm ON t.payment_method_id = pm.payment_method_id
WHERE t.status = 'completed';

SELECT COUNT(*) FROM completed_trips_view; 
--2,863 
 SELECT * FROM completed_trips_view LIMIT 5;
-- trip_id|driver_name |passenger_name |pickup_city|dropoff_city|fare_amount|distance_km|rating|payment_method|requested_at           |completed_at           |
-- -------+------------+---------------+-----------+------------+-----------+-----------+------+--------------+-----------------------+-----------------------+
--       3|Suresh Magar|Sanjay Maharjan|Hetauda    |Kathmandu   |     493.19|      35.77|   3.1|cash          |2024-04-07 07:26:37.000|2024-04-07 08:05:37.701|
--       4|Anita Rai   |Meena Adhikari |Pokhara    |Hetauda     |     578.05|      20.78|   4.3|card          |2024-02-04 12:52:35.000|2024-02-04 13:50:12.306|
--       5|Priya Gurung|Meena Adhikari |Chitwan    |Kirtipur    |     691.99|      40.82|   4.7|khalti        |2024-12-24 19:52:17.000|2024-12-24 20:49:20.689|
--       7|Deepak Thapa|Ashok Neupane  |Lalitpur   |Pokhara     |     530.04|      30.16|   4.8|esewa         |2024-06-04 10:13:02.000|2024-06-04 11:04:19.703|
--       8|Bikash Karki|Prem Basnet    |Butwal     |Lalitpur    |     775.90|      41.20|   4.7|cash          |2024-02-11 21:51:55.000|2024-02-11 22:17:27.341|

--Q3 driver_summary_view

CREATE VIEW driver_summary AS 
SELECT d.name AS driver_name,
count(*) AS total_trips,
count(*) FILTER (WHERE t.status= 'completed') AS completed_trips,
count(*) FILTER (WHERE t.status='cancelled') AS cancelled_trips,
ROUND (count(*) FILTER (WHERE t.status = 'cancelled')::NUMERIC / NULLIF (count(*),0) *100,1) AS cancellation_rate,
round (avg(t.fare_amount) FILTER (WHERE t.status ='completed')::NUMERIC,2) AS avg_fare,
round (avg(t.rating) FILTER (WHERE t.status ='completed'),1) AS avg_rating FROM drivers d LEFT JOIN trips t ON d.driver_id = t.driver_id 
GROUP BY d.driver_id, d.name ORDER BY completed_trips DESC;

SELECT * FROM driver_summary ORDER BY completed_trips DESC;
--
--driver_name    |total_trips|completed_trips|cancelled_trips|cancellation_rate|avg_fare|avg_rating|
-----------------+-----------+---------------+---------------+-----------------+--------+----------+
--Rajan Pandey   |        507|            307|            125|             24.7|  487.98|       3.8|
--Nisha Bista    |        541|            300|            166|             30.7|  515.30|       3.8|
--Suresh Magar   |        487|            298|            126|             25.9|  502.64|       3.8|
--Bikash Karki   |        507|            291|            154|             30.4|  513.16|       3.7|
--Priya Gurung   |        495|            285|            135|             27.3|  508.49|       3.8|
--Anita Rai      |        481|            284|            127|             26.4|  502.16|       3.8|
--Ramesh Shrestha|        516|            278|            153|             29.7|  497.64|       3.8|
--Deepak Thapa   |        488|            278|            135|             27.7|  508.20|       3.8|
--Kabita Lama    |        488|            276|            144|             29.5|  474.30|       3.8|
--Sita Tamang    |        490|            265|            143|             29.2|  485.02|       3.8|
--Nirjal Shrestha|          1|              1|              0|              0.0|   17.96|       4.6|
--Rai Maila      |          1|              0|              0|              0.0|  [NULL]|    [NULL]|

--Q4 Transaction that fails on purpose 

BEGIN;

-- Insert a new driver
INSERT INTO drivers (name)
VALUES ('Test Driver');

-- First trip (valid)
INSERT INTO trips (
    driver_id,
    passenger_id,
    pickup_location_id,
    dropoff_location_id,
    fare_amount,
    distance_km,
    status,
    requested_at,
    completed_at,
    rating,
    payment_method_id
)
VALUES (
    (SELECT driver_id FROM drivers WHERE name = 'Test Driver'),
    16,
    3,
    8,
    17.96,
    31.75,
    'completed',
    '2024-10-27 12:16:55',
    '2024-10-27 13:26:12.960719',
    4.6,
    2
);

-- Second trip (intentional error: negative fare)
INSERT INTO trips (
    driver_id,
    passenger_id,
    pickup_location_id,
    dropoff_location_id,
    fare_amount,
    distance_km,
    status,
    requested_at,
    completed_at,
    rating,
    payment_method_id
)
VALUES (
    (SELECT driver_id FROM drivers WHERE name = 'Test Driver'),
    16,
    3,
    8,
    -17.96,
    31.75,
    'completed',
    '2024-10-27 12:16:55',
    '2024-10-27 13:26:12.960719',
    4.6,
    5
);

COMMIT;
--SQL Error [23514]: ERROR: new row for relation "trips" violates check constraint "trips_fare_amount_check"
--  Detail: Failing row contains (5005, 14, 16, 3, 8, -17.96, 31.75, completed, 2024-10-27 12:16:55, 2024-10-27 13:26:12.960719, 4.6, 5).
ROLLBACK;
SELECT * FROM drivers WHERE name = 'Test Driver';
--no driver with such name found


-- Verification query:
SELECT
    'drivers' AS tbl,
    COUNT(*) AS test_driver_rows
FROM drivers
WHERE name = 'Test Driver'
UNION ALL
SELECT 'trips', COUNT(*)
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
WHERE d.name = 'Test Driver';
--
--tbl    |test_driver_rows|
---------+----------------+
--drivers|               0|
--trips  |               0|


-- Q6 (STRETCH): Window function — running total fare per driver

-- the goal is to have cumulative fare amount column 
-- group by cannot do this because it cannot show what was the sum fare amount at a certain time
SELECT
    t.trip_id,
    d.name AS driver_name,
    t.requested_at,
    t.fare_amount,
    SUM(t.fare_amount) OVER (
        PARTITION BY t.driver_id
        ORDER BY t.requested_at
    ) AS running_total_fare
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
WHERE t.status = 'completed'
ORDER BY d.name, t.requested_at;

