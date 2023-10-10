--highest population
select distinct a.State, a.District,a.Sex_Ratio/1000, a.literacy, b.population from [Census project].dbo.Data1 a 
inner join 
[Census project].dbo.Data2 b
on a.district=b.district
order by Population desc

--Males and Females by above population query

select c.State, c.District, c.population, round(c.population/(c.Sex_ratio+1),0) males, round((c.population*(c.sex_ratio)/(c.sex_ratio+1)),0) Females from 
(select distinct a.State, a.District,a.Sex_ratio/1000 Sex_ratio , a.literacy, b.population from [Census project].dbo.Data1 a 
inner join 
[Census project].dbo.Data2 b
on a.district=b.district  ) c


--Group by State
select d.State,sum(d.population) population,sum(d.males) males,sum(d. females) females from (
select c.State, c.District, c.population, round(c.population/(c.Sex_ratio+1),0) males, round((c.population*(c.sex_ratio)/(c.sex_ratio+1)),0) Females from 
(select distinct a.State, a.District,a.Sex_ratio/1000 Sex_ratio , a.literacy, b.population from [Census project].dbo.Data1 a 
inner join 
[Census project].dbo.Data2 b
on a.district=b.district  ) c) d
group by d.State

--Total Literates and illerates

select c.state, round(sum(c.literacy*c.population),0) total_literate,round(sum(c.population-(c.literacy*c.population)),0) total_illerate,sum(c.population) total_population from
(select a.State, a.district, a.literacy/100 literacy,b.population population from[Census project].dbo.Data1 a
inner join 
[Census project].dbo.Data2 b
on a.State=b.State) c
group by c.state

--Population of previous yr
select sum(e.previous_population) India_previous_population,sum(e.present_population) India_present_population from (
select d.state,sum(d.previous_population) previous_population,sum(d.present_population) present_population from (
select c.state, round(c.population/(1+c.growth),0) previous_population,c.population present_population  from 
(select a.state,a.district,a.Growth,b.population from [Census project].dbo.Data1 a 
inner join [Census project].dbo.Data2 b
on a.state=b.state) c) d
group by d.State) e

---finding top 3 districts (state wise) giving them the ranks

select a.* from
(select state,district, literacy,rank() over(partition by state order by literacy desc) rnk from [Census project].dbo.Data1) a
where a.rnk in (1,2,3)

select a.* from
(select state,district, literacy,rank() over(partition by state order by literacy asc) rnk from [Census project].dbo.Data1) a
where a.rnk in (1,2,3)





