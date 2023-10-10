--(ROll metrics)

select *  from [fassos].dbo.customer_orders

--1) How many rolls were ordered?
 
 select count(roll_id) orders from customer_orders;

--2) How many unique customer orders were made?

select count(distinct order_id) orders from customer_orders;

--3) How many successful orders were delievered by each driver?

select * from driver_order

with cte as 
(
select *, case when cancellation like '%cancellation%' then 0 else 1 end as successful_orders from driver_order)
select driver_id,sum(successful_orders) successful_orders from cte
group by driver_id

--4) How many each type of rolls were delievered?

select roll_id, count(roll_id) no_of_rolls_delievered from [dbo].[customer_orders] where order_id in (
select order_id from (
select * ,case when cancellation in('Cancellation','Customer Cancellation') then 0 else 1 end as successful_orders from driver_order ) a
where successful_orders=1)
group by roll_id

--5) How many veg and non veg rolls were ordered by each customer?

select * from customer_orders

select a.*,b.roll_name from(
select customer_id, roll_id,count(order_date) cnt from customer_orders group by customer_id,roll_id) a 
inner join rolls b on b.roll_id=a.roll_id

--6) What was the maximum number of rolls delivered in a single order?

select * from driver_order

select * from(
select d.*,rank() over( order by cnt_of_rolls desc) rnk from(
select c.order_id,count(c.roll_id) cnt_of_rolls from(
select a.*, b.roll_id from(
select order_id from driver_order where order_status =1) a 
inner join customer_orders b on b.order_id=a.order_id)c
group by c.order_id) d)e
where rnk=1

