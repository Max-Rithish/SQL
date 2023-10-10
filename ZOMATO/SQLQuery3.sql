--1) what is the total amount each customer spent on zomato?

select b.userid,sum(a.price) amount_spent from sales b 
inner join product a 
on a.product_id=b.product_id
group by b.userid;

--2) How many days has each customer visited zomato?

select userid,count(distinct created_date) days_visited from sales group by userid

--3) What was the first product purchased by each customer?

select * from (
select *,rank() over(partition by userid order by created_date  ) rnk from sales) a where rnk=1;

--4) what is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(product_id) from sales where product_id in(
select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid;

--5) which item is most popular for each of the customer?

select * from (
select userid,product_id,row_number() over(partition by userid order by cnt desc) rnk from(
select userid,product_id,count(product_id) cnt from sales group by product_id,userid)a)b
where rnk=1;










