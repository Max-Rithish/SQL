select * from [Census project].dbo.Data1;
select * from [Census project].dbo.Data2;

select count(*) from Data1;


select * from Data1   where state in ('andhra pradesh','kerala') group by State;

select sum(Population) as total_population from Data2;

select State,Max(sex_ratio) Sex_ratio from Data1 
group by State
order by Sex_ratio desc;

select state,round(avg(Literacy),1) as literacy from Data1 
group by State having round(avg(Literacy),1)>75
order by literacy desc;

select top 3 State,round(avg(Sex_Ratio),2) as Sex_Ratio from Data1 
group by State
order by Sex_Ratio asc;

--temp table for top3 literacy states 
drop table if exists topstates_temp
create table topstates_temp
( State nvarchar(255),
  Literacy float)

insert into topstates_temp
select state,round(avg(Literacy),1) as literacy from Data1 
group by State 
order by round(avg(Literacy),1) desc

select top 3 * from topstates_temp order by Literacy desc

--temp table for bottom3 literacy states 
drop table if exists bottomstates_temp
create table bottomstates_temp
( state nvarchar(255),
  Literacy float
  )
insert into bottomstates_temp
select state,round(avg(Literacy),1) as literacy from Data1
group by State
order by round(avg(Literacy),1) asc

select top 3 * from bottomstates_temp order by Literacy asc

--union

select * from(select top 3 * from topstates_temp order by topstates_temp.Literacy desc) a 
union
select * from (select top 3 * from bottomstates_temp order by bottomstates_temp.Literacy asc) b
order by Literacy desc

--Like

select distinct state from Data1 where State like 'a%'
select distinct state from Data1 where State like '%a'
select distinct state from Data1 where State like 'a%' and state like '%h';









