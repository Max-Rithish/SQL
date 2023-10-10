--Data cleaning for customer_orders and driver_order columns

--7) For each customer, how many delivered rolls had at least 1 change and how many had no change?

select * from customer_orders;

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items,order_date) as
(
select order_id,customer_id,roll_id, case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_tems,
case when extra_items_included is null or extra_items_included= ' ' or extra_items_included ='NaN' then '0' else extra_items_included end as new_extra_items_included, 
order_date from customer_orders
)
,

temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as 
(
select order_id,driver_id,pickup_time,distance,duration, case when cancellation in ('cancellation','customer cancellation') then 0 else 1 end as new_driver_order
from driver_order
)
select customer_id,order_status,count(order_id) atleast1_change_status from
(select *,case when not_include_items='0' and extra_items='0' then 'No-change' else 'change' end as order_status from temp_customer_orders where order_id in(
select order_id from temp_driver_order where new_cancellation=1))a
group by customer_id,order_status

--8) How many rolls were delivered that had both exclusions and extras?

with temp_customer_orders (order_id,customer_id,roll_id,not_include_items,extra_items,order_date) as
(
select order_id,customer_id,roll_id, case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_tems,
case when extra_items_included is null or extra_items_included= ' ' or extra_items_included ='NaN' then '0' else extra_items_included end as new_extra_items_included, 
order_date from customer_orders
)
,

temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as 
(
select order_id,driver_id,pickup_time,distance,duration, case when cancellation in ('cancellation','customer cancellation') then 0 else 1 end as new_driver_order
from driver_order
)
select change_status,count(change_status) No_of_incl from
(select *,case when not_include_items!='0' and extra_items!='0' then 'both inc' else 'excl' end as change_status from temp_customer_orders where order_id in(
select order_id from temp_driver_order where new_cancellation=1))a
group by change_status

--9) what was the total number of rolls ordered for each hour of the day?

select * from [dbo].[customer_orders]

select hr_group,count(hr_group) No_of_orders from(
select *,concat(cast(datepart(hour,order_date) as varchar),'-', cast(datepart(hour,order_date)+1 as varchar)) hr_group from customer_orders)a
group by hr_group;

--10) What was the number of orders for each day of the week?

select * from [dbo].[customer_orders]

select day_name, count(distinct order_id ) No_of_orders from(
select *, datename(dw,order_date) day_name from customer_orders) a
group by day_name;

--B) driver and customer experience

--1) what was the average time in minutes it took for each driver to arrive to the fassos HQ to pickup the order?

select * from [dbo].[customer_orders]
select * from [dbo].[driver_order]

select driver_id, avg(diff) avg_time from(
select * from(
select *,row_number() over(partition by order_id order by diff) rnk from(
select a.order_id,a.customer_id,a.roll_id,a.extra_items_included,a.order_date,
b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation, datediff(minute,a.order_date,b.pickup_time) diff from customer_orders a
inner join driver_order b
on b.order_id = a.order_id
where pickup_time is not null)c) d where rnk=1)e group by driver_id 



update driver_order
set[pickup_time] = dateadd(yyyy,+1,pickup_time)
where cancellation is null

--2) Is there any relationship between the number of rolls and how long the order takes to prepare?

select order_id,count(roll_id) cnt,avg(diff) avg_time from(
select d.* from(
select *, row_number() over ( partition by order_id order by diff) rnk from(
select a.order_id,a.customer_id,a.roll_id,b.distance ,datediff(minute,order_date,pickup_time) diff from customer_orders a inner join driver_order b on a.order_id=b.order_id
where pickup_time is not null)c)d) e group by order_id

--3) What was the average distance travelled for each customer?

select e.customer_id,avg(time1) avg_time from(
select d.* from(
select c.*,row_number() over(partition by order_id order by roll_id) rnk from(
select a.order_id,a.customer_id,a.roll_id,a.order_date,b.driver_id,b.pickup_time,cast(trim(REPLACE(b.distance,'km','')) as decimal(4,1)) time1,b.duration,b.cancellation from [dbo].[customer_orders] a
inner join [dbo].[driver_order] b
on a.order_id=b.order_id
where pickup_time is not null) c) d where rnk=1) e
group by customer_id

--4) What was the difference between the longest and shortest delivery times for all orders?

select * from driver_order

select max(duration)-min(duration) diff from(
select cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration end as integer) duration from driver_order
where duration is not null)a

--5) What was the average speed for each driver for each delivery and do you notice any trend for these values?

	select a.order_id,a.driver_id,a.dist/a.duration speed from(
	select order_id,driver_id, cast(trim(REPLACE(lower(distance),'km','')) as decimal(4,2)) dist,
	cast(case when duration like '%min%' then left(duration,charindex('m',duration)-1) else duration end as integer) duration from driver_order where pickup_time is not null ) a
	inner join (select order_id,count(roll_id) cnt from customer_orders group by order_id) b on a.order_id=b.order_id 


--6) What is the successful delivery percentage of each driver?

select * from driver_order

select *,delivered*100.0/total_ordered percentage from(
select driver_id,sum(status) delivered,count(driver_id) total_ordered from(
select driver_id,case when cancellation like '%cancel%' then 0 else 1 end as status from driver_order) a
group by driver_id)b