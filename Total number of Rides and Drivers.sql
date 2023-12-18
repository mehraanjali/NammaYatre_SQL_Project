USE [Namma Yatri];
/*
-- Ride table contains the number of successful ride and trips_details contains all searches, all rides.

PRINT 'Number of rides in Rides Table';
select count(*) from rides;

print'Number of successful rides in trips_details Table';
select count(*) from trips_details
where end_ride = 1;

-- checking for counts of trip id for cheking of there is any duplicate

print'Count of Trip ID';
select count(tripid) from trips_details;

print'Count of Distinct Trip ID';
select count(distinct tripid) from trips_details;

-- directly checking for duplicates

print'Number of duplicate Trip Ids';
select tripid,count(tripid) cnt from trips_details
group by tripid
having count(tripid)>1;

*/

-- Therefore Total number of Trips is the count of distinct tripid or count of tripid, because there is no duplicate values.

print'Total number of trips : ';
select count(distinct tripid) total_trips from trips_details;


print'Total number of Drivers : ';
select count(distinct driverid) Total_drivers from rides;

-- Total Earnings

select sum(fare) total_earning from rides;

-- total Completed trips

select count(distinct tripid) complete_trips from trips_details
where end_ride = 1;

-- total number of searches

select sum(searches) total_searches from trips_details;

--total searches which got estimate
--total searches for quotes
--total searches which got quotes

select sum(searches_got_estimate) searches_got_estimate,
sum(searches_for_quotes) searches_for_quotes,
sum(searches_got_quotes) searches_got_quotes
from trips_details;

--cancelled bookings by driver
select count(*) - sum(driver_not_cancelled) driver_cancel from trips_details;

--cancelled bookings by customer

select count(*) - sum(customer_not_cancelled) customer_cancel from trips_details;

--total otp entered
select sum(otp_entered) otp_entered from trips_details;

--total end ride
select sum(end_ride) end_rides from trips_details;

--average distance per trip

select AVG(distance) average_dis from rides;

--average fare per trip

select AVG(fare) average_fare from rides;

--distance travelled
select SUM(distance) dis_travelled from rides;

-- which is the most used payment method 

/*
-- FOR ALL FAREMETHOD COUNTS
select(faremethod), COUNT(tripid) from rides
group by faremethod
order by count(tripid) desc;
*/

/*
-- WITH THE HIGHEST FAREMETHOD COUNTS
select TOP 1 (faremethod), COUNT(tripid) from rides
group by faremethod
order by count(tripid) desc;
*/

SELECT A.method from payment A
INNER JOIN 
(select TOP 1 faremethod, COUNT(tripid) cnt from rides
group by faremethod
order by count(tripid) desc)B
ON A.id = B.faremethod;

-- which two locations had the most trips

/*
select loc_from,loc_to, count(loc_from) from rides
group by loc_from,loc_to
order by count(loc_from) desc;
*/

-- but to get the top values and that also can rely on data on our fixed top 2 or 5

select * from
(select *, dense_rank() over (order by trip desc) rnk
from
(select loc_from,loc_to, count(loc_from) trip from rides
group by loc_from,loc_to) a)b
where rnk = 1;

--top 5 earning drivers

select * from rides;

select top 5 driverid, sum(fare) earnings from rides
group by driverid
order by sum(fare) desc;

-- which duration had more trips
select top 10 duration.duration, count(rides.tripid) cnt from rides
inner join duration
on rides.duration = duration.id
group by duration.duration
order by count(rides.tripid) desc;

-- which driver , customer pair had more orders

/*
select driverid, custid, count(tripid) from rides
group by driverid, custid
order by count(tripid) desc;
*/

select * from
(select *, rank() over (order by cnt desc) rnk from
(select driverid, custid, count(tripid) cnt from rides
group by driverid, custid)a )b
where rnk = 1;

-- search to estimate rate
select sum(searches_got_estimate)*100.0/sum(searches) from trips_details;

-- estimate to search for quote rates
select sum(searches_for_quotes)*100.0/sum(searches_got_estimate) from trips_details;

-- quote acceptance rate
select sum(searches_got_quotes)*100.0/sum(searches_for_quotes) from trips_details;

-- quote to booking rate
select sum(customer_not_cancelled)*100.0/sum(searches_got_quotes) from trips_details;

/*
-- booking cancellation rate

canceled_bookings*100.0 / sum(searches_got_quotes) from trips_details;

-- conversion rate
select sum(searches_for_quotes)*100.0/sum(searches) from trips_details;
*/

-- which location got the highest number of trips in each duration present.
select * from
(select *, rank() over (partition by duration order by cnt desc) rnk from
(select duration, loc_from, count(distinct tripid) cnt from rides
group by duration, loc_from)a)b
where rnk = 1;

-- which duration got the highest number of trips in each of the location present.
select * from
(select *, rank() over (partition by loc_from order by cnt desc) rnk from
(select duration, loc_from, count(distinct tripid) cnt from rides
group by duration, loc_from)a)b
where rnk = 1;

-- which area got the highest fares, ,trips
select * from
(select *, rank() over (order by faresum desc) rnk from
(select loc_from, sum(fare) faresum from rides
group by loc_from)a) b
where rnk = 1;

-- which area got the highest driver cancellations
select * from
(select *, rank() over (order by driverc desc) rnk from
(select loc_from, count(*)-sum(driver_not_cancelled) driverc from trips_details
group by loc_from)a) b
where rnk = 1;

-- which area got the highest customer cancellations
select * from
(select *, rank() over (order by cusc desc) rnk from
(select loc_from, count(*)-sum(customer_not_cancelled) cusc from trips_details
group by loc_from)a) b
where rnk = 1;

-- which duration got the highest trips
select * from
(select *, rank() over (order by trips desc) rnk from
(select duration, count(tripid) trips from rides
group by duration)a) b
where rnk = 1;

-- which duration got the highest fares

select * from
(select *, rank() over (order by fare desc) rnk from
(select duration, sum(fare) fare from rides
group by duration)a) b
where rnk = 1;
