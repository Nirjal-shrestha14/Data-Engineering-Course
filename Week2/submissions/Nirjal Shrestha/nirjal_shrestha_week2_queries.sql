-- Week 2 Assignment: Schema Normalization

-- Q2 Completed rides per driver - name + count , descending order
SELECT
	d.name AS driver_name,
	count(trip_id) AS completed_rides
FROM
	drivers d
JOIN trips t ON
	d.driver_id = t.driver_id
WHERE
	t.status = 'completed'
GROUP BY
	d.name
ORDER BY
	count(trip_id) DESC;

-- Q3 Drivers with NO completed rides
SELECT
	d.name AS driver_name 
FROM
	drivers d
LEFT JOIN trips t ON
	d.driver_id = t.driver_id
	AND t.status = 'completed'
WHERE
	t.trip_id IS NULL;

-- Q4 Average fare per pickup city, descending
SELECT
	l.city_name AS pickup_city ,
	round(AVG(t.fare_amount), 2) AS avg_fare_amount
FROM
	locations l
JOIN trips t ON
	l.location_id = t.pickup_location_id
GROUP BY
	l.city_name
ORDER BY
	AVG(t.fare_amount) DESC;
    
--Q5 Rides where pickup and dropoff city are the same
SELECT
	t.trip_id,
	pck.city_name ,
	drp.city_name
FROM
	trips t
JOIN locations pck ON
	t.pickup_location_id = pck.location_id
JOIN locations drp ON
	t.dropoff_location_id = drp.location_id
WHERE
	t.pickup_location_id = t.dropoff_location_id ;

-- Q6 Re-write Week 1 Q7 (total revenue) on new schema
-- What is the total fare collected across completed rides only?

-- previous schema
SELECT
	SUM(r.fare_amount) AS total_fare
FROM
	rides r
WHERE
	r.ride_status = 'completed';
-- new schema
SELECT
	SUM(t.fare_amount) AS total_fare
FROM
	trips t
WHERE
	t.status = 'completed';