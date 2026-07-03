-- Week 2 Assignment: Schema Normalization
-- Q1 Create 4 tables + load data 

CREATE TABLE locations(
location_id serial PRIMARY KEY,
city_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE drivers(
driver_id serial PRIMARY KEY,
name varchar(100) NOT NULL 
);

CREATE TABLE passengers(
passenger_id serial PRIMARY KEY,
name varchar(100) NOT NULL 
);

CREATE TABLE payment_methods (
	payment_method_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE 
);

CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    passenger_id INTEGER NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    dropoff_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    fare_amount NUMERIC(10, 2) NOT NULL CHECK (fare_amount > 0),
    distance_km NUMERIC(6, 2) NOT NULL,
    status varchar(50) NOT NULL CHECK (status IN ('completed', 'cancelled', 'no_show')),
    requested_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    rating NUMERIC(2, 1) CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id INTEGER REFERENCES payment_methods(payment_method_id)
);

INSERT
	INTO
	drivers (name)
SELECT
	DISTINCT initcap(trim(regexp_replace(r.driver_name, '\s+', ' ', 'g')))
FROM
	rides r;

SELECT
	*
FROM
	drivers;

INSERT
	INTO
	passengers (name)
SELECT
	DISTINCT initcap(trim(regexp_replace(r.passenger_name, '\s+', ' ', 'g')))
FROM
	rides r;

SELECT
	*
FROM
	passengers;

INSERT
	INTO
	locations(city_name)
SELECT
	DISTINCT pickup_city
FROM
	rides r
UNION
SELECT
	DISTINCT dropoff_city
FROM
	rides r;

SELECT
	*
FROM
	locations;

INSERT
	INTO
	payment_methods(name)
SELECT
	DISTINCT payment_method
FROM
	rides r
WHERE
	payment_method IS NOT NULL;

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
SELECT 
(SELECT  driver_id 
	FROM drivers d 
	 WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
(SELECT  location_id  
		FROM locations l
	 WHERE l.city_name = r.pickup_city ) pickup_location_id,
(SELECT  location_id  
		FROM locations l
	 WHERE l.city_name = r.dropoff_city ) dropoff_location_id,
fare_amount,
ride_distance_km,
ride_status,
requested_at,
completed_at,
rating,

(SELECT  payment_method_id  
		FROM payment_methods pm  
		WHERE pm.name = r.payment_method  ) payment_method_id
FROM rides r;

SELECT * FROM trips;

