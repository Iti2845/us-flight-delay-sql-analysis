--Query 1: Which airline has the highest average departure delay?
select f.AIRLINE as Airline_Code, a.AIRLINE as Airline_Name,round(avg(f.DEPARTURE_DELAY)) as Avg_Departure_Delay
from FLIGHTS f inner join airlines a on f.AIRLINE=a.IATA_CODE 
group by f.AIRLINE order by round(avg(f.DEPARTURE_DELAY)) DESC;

--Query 2: Which day of week has the worst on-time performance?
select round(avg(DEPARTURE_DELAY)) as Avg_Departure_Delay, 
DAY_OF_WEEK, 
case when DAY_OF_WEEK=1 THEN 'MONDAY' 
when DAY_OF_WEEK=2 THEN 'TUESDAY' 
when DAY_OF_WEEK=3 THEN 'WEDNESDAY' 
when DAY_OF_WEEK=4 THEN 'THURSDAY' 
when DAY_OF_WEEK=5 THEN 'FRIDAY' 
when DAY_OF_WEEK=6 THEN 'SATURDAY' 
ELSE 'SUNDAY' END AS ' DAY_NAME' from FLIGHTS 
GROUP BY DAY_OF_WEEK
order by round(avg(DEPARTURE_DELAY)) DESC;

--Query 3: Which month has the highest average departure delay?
select round(avg(DEPARTURE_DELAY)) as Avg_Departure_Delay, MONTH, 
case when MONTH=1 THEN 'JAN' 
when MONTH=2 THEN 'FEB' 
when MONTH=3 THEN 'MAR' 
when MONTH=4 THEN 'APRIL' 
when MONTH=5 THEN 'MAY' 
when MONTH=6 THEN 'JUN'
when MONTH=7 THEN 'JUL'
when MONTH=8 THEN 'AUG'
when MONTH=9 THEN 'SEP'
when MONTH=10 THEN 'OCT'
when MONTH=11 THEN 'NOV'
ELSE 'DEC' END AS ' MONTH_NAME' from FLIGHTS 
GROUP BY MONTH
order by round(avg(DEPARTURE_DELAY)) DESC;

--Query 4: Which origin airports have the highest cancellation rates?
select f.ORIGIN_AIRPORT,count(*) as TOTAL_FLIGHTS,
sum(f.CANCELLED) as TOTAL_CANCELLATION,a.AIRPORT,a.CITY,
ROUND(sum(f.CANCELLED)/count(*)*100) AS CANCELLATION_RATE 
FROM FLIGHTS f inner join airports a on f.ORIGIN_AIRPORT = a.IATA_CODE 
group by a.AIRPORT,f.ORIGIN_AIRPORT,a.CITY 
having count(*)>1000 
order by ROUND(sum(f.CANCELLED)/count(*)*100) DESC 
LIMIT 10;

--Query 5: What is the on-time performance rank of each airline using RANK()?
SELECT 
    Airline_Name,
    Avg_Arrival_Delay,
    RANK() OVER (ORDER BY Avg_Arrival_Delay ASC) AS Performance_Rank
FROM (
    SELECT 
        a.AIRLINE AS Airline_Name,
        ROUND(AVG(f.ARRIVAL_DELAY)) AS Avg_Arrival_Delay
    FROM FLIGHTS f 
    INNER JOIN airlines a ON f.AIRLINE = a.IATA_CODE
    GROUP BY f.AIRLINE, a.AIRLINE
) AS airline_avg;

--Query 6: Which cancellation reason dominates?
SELECT COUNT(*),(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()) AS CANCELLATION_PERCENTAGE,
CASE 
WHEN CANCELLATION_REASON='A' THEN 'AIRLINE/CARRIER'
WHEN CANCELLATION_REASON='B' THEN 'WEATHER'
WHEN CANCELLATION_REASON='C' THEN 'NATIONAL AVIATION SYSTEM'
ELSE 'SECURITY' END AS CANCEL_REASON FROM FLIGHTS WHERE CANCELLED = 1 GROUP BY CANCELLATION_REASON
ORDER BY COUNT(*) DESC;

--Query 7: Which top 10 routes have highest average arrival delay?
SELECT COUNT(*) AS NO_OF_FLIGHTS,ROUND(AVG(f.ARRIVAL_DELAY)) AVG_ARRIVAL_DELAY,
CONCAT(a1.city,'->',a2.city) as ROUTE 
FROM FLIGHTS f INNER JOIN airports a1 on f.ORIGIN_AIRPORT = a1.IATA_CODE 
INNER JOIN airports a2 ON f.DESTINATION_AIRPORT=a2.IATA_CODE 
GROUP BY f.ORIGIN_AIRPORT,f.DESTINATION_AIRPORT 
HAVING COUNT(*) >=100 order by ROUND(AVG(f.ARRIVAL_DELAY)) DESC 
LIMIT 10 ;

--Query 8
SELECT 
    Month_Name,
    Avg_Delay,
    LAG(Avg_Delay) OVER (ORDER BY MONTH) AS Previous_Month_Delay,
    Avg_Delay - LAG(Avg_Delay) OVER (ORDER BY MONTH) AS Month_Over_Month_Change
FROM (
select round(avg(DEPARTURE_DELAY)) as Avg_Delay, MONTH, 
case when MONTH=1 THEN 'JAN' 
when MONTH=2 THEN 'FEB' 
when MONTH=3 THEN 'MAR' 
when MONTH=4 THEN 'APRIL' 
when MONTH=5 THEN 'MAY' 
when MONTH=6 THEN 'JUN'
when MONTH=7 THEN 'JUL'
when MONTH=8 THEN 'AUG'
when MONTH=9 THEN 'SEP'
when MONTH=10 THEN 'OCT'
when MONTH=11 THEN 'NOV'
ELSE 'DEC' END AS Month_Name from FLIGHTS 
GROUP BY MONTH
) AS monthly_avg;

--Query 9:
SELECT * 
FROM (
    SELECT 
        ORIGIN_AIRPORT,
        ROUTE,
        AVG_ARRIVAL_DELAY,
        ROW_NUMBER() OVER (
            PARTITION BY ORIGIN_AIRPORT 
            ORDER BY AVG_ARRIVAL_DELAY DESC
        ) AS rn
    FROM (
        SELECT 
            f.ORIGIN_AIRPORT,
            CONCAT(a1.CITY, '->', a2.CITY) AS ROUTE,
            ROUND(AVG(f.ARRIVAL_DELAY)) AS AVG_ARRIVAL_DELAY,
            COUNT(*) AS NO_OF_FLIGHTS
        FROM FLIGHTS f 
        INNER JOIN airports a1 ON f.ORIGIN_AIRPORT = a1.IATA_CODE 
        INNER JOIN airports a2 ON f.DESTINATION_AIRPORT = a2.IATA_CODE 
        GROUP BY f.ORIGIN_AIRPORT, f.DESTINATION_AIRPORT
        HAVING COUNT(*) >= 100
    ) AS route_avg
) AS ranked
WHERE rn = 1
LIMIT 15;

--Query 10:
SELECT 
    a.AIRLINE AS airline_name,
    ROUND(AVG(f.AIRLINE_DELAY)) AS avg_airline_delay,
    ROUND(AVG(f.LATE_AIRCRAFT_DELAY)) AS avg_late_aircraft_delay,
    ROUND(AVG(f.AIR_SYSTEM_DELAY)) AS avg_air_system_delay,
    ROUND(AVG(f.WEATHER_DELAY)) AS avg_weather_delay,
    ROUND(AVG(f.SECURITY_DELAY)) AS avg_security_delay
FROM FLIGHTS f
JOIN airlines a 
    ON f.AIRLINE = a.IATA_CODE
GROUP BY a.AIRLINE
ORDER BY avg_airline_delay DESC;
