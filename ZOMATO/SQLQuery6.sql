--10) In the first one year after a customer joins the gold program (including their join date) irrespective of what
--the customer has purchased they earn 5 zomato points for every 10 rs spent. who earned more 1 or 3? and what was their points earnings
--in their first year?

select d.*, price*0.5 points_earned from (
select c.*,d.price from ( 
select a.userid,b.created_date,b.product_id,a.goldsignupdate from goldusers_signup a
inner join sales b on b.userid=a.userid and created_date>=goldsignupdate and created_date<=dateadd(year,1,goldsignupdate)) c
inner join product d on d.product_id=c.product_id) d

--11) rank all the transactions of the customers 

select *,rank() over(partition by userid order by created_date ) rnk from sales

--12) rank all  the transactions for each member whenever they are a zomato gold member for every non gold member transaction mark as NA

select d.*, case when rnk =0 then 'na' else rnk end as rnkk from(
select c.*,cast((case when goldsignupdate is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) rnk from(
select a.userid,a.created_date,a.product_id,b.goldsignupdate from sales a
left join goldusers_signup b
on a.userid=b.userid and created_date>=goldsignupdate)c)d

