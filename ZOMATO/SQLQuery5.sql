--6) when was the first sale created by every member and what is the product?

select * from sales;

select * from(
select *,rank() over(partition by userid order by latestdate) rnk from(
select userid, min(created_date) latestdate ,product_id from sales group by userid,product_id) a) b
where rnk=1;

--7) which item was purchased first by the  customer after they became a member?

select c.* from (
select b.*,row_number() over(partition by userid order by created_date) rnk from(
select a.userid,b.created_date,b.product_id,a.goldsignupdate from goldusers_signup a
inner join sales b
on b.userid=a.userid and created_date>=goldsignupdate) b) c
where rnk=1

--7) which item was purchased first by the  customer before they became a member?

select c.* from (
select b.*,row_number() over(partition by userid order by created_date desc) rnk from(
select a.userid,b.created_date,b.product_id,a.goldsignupdate from goldusers_signup a
inner join sales b
on b.userid=a.userid and created_date<=goldsignupdate) b) c
where rnk=1

--8) what are the total orders and amount spent for each member before they become a member?

select userid,count(created_date) total_orders,sum(price) total_amt from(
select c.*,d.price from(
select a.userid,b.created_date,b.product_id,a.goldsignupdate from goldusers_signup a
inner join sales b
on b.userid=a.userid and created_date<=goldsignupdate) c inner join product d on d.product_id=c.product_id) e
group by userid;

--9) If buying each product generates points for eg 5rs =2 zomato points and each product has different purchasing points 
--for eg for p1 5rs=1 zomato point, for p2 10rs=5 zomato points and p3 5rs=1zomato points 
--calculate points collected by each customers and for which product most points have been given till now.

select userid, max_points*2.5 money_earned from(
select top 1 userid,product_id, max(points_earned) max_points from (
select userid,product_id,sum(points_earned) points_earned from(
select e.*,price/points points_earned from(
select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from( 
select userid,product_id,sum(price) price from(
select b.userid, a.product_id, a.price from product a inner join sales b on b.product_id=a.product_id) c
group by userid,product_id)d)e) f
group by userid,product_id) g
group by userid,product_id order by max_points desc)h


select product_id,sum(points_earned) points_earned from (
select e.*, price/points points_earned from (
select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from(
select userid,product_id,sum(price) price from(
select b.userid,a.product_id,a.price from product a inner join sales b on b.product_id=a.product_id) c
group by userid,product_id)d)e)f
group by product_id