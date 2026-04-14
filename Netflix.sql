--Netflix Database
use [netflix database]

--Netflix dataset
select * from netflix_titles

select COUNT(*) from netflix_titles

-- Count the number of Movies vs TV Shows
select type,count(type) [Total]
from netflix_titles
group by type

--Find the most common rating for movies and TV shows
select 
type,rating,count(show_id) [Count],
RANK() over(partition by type order by count(show_id) desc) [Ranking]
from netflix_titles
group by type,rating

--List all movies released in a specific year (e.g., 2020)
select type,title,release_year
from netflix_titles
where type = 'Movie' and release_year = 2020

--Find the top 5 countries with the most content on Netflix
with cte as(
SELECT value AS [New Country],show_id
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ','))
select TOP 5
[New Country],count(show_id) [Count],
RANK() over(order by count(show_id) desc ) [Rank]
from cte
group by [New Country]
order by count(show_id) desc

--Identify the longest movie
select TOP 1 type,title, duration
from netflix_titles
where type = 'Movie' and TRY_CAST(REPLACE(duration,' min','') as INT) is not null
order by TRY_CAST(REPLACE(duration,' min','') as INT) desc

--Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type,title,director
from netflix_titles
where director like '%Rajiv Chilaka%'

--List all TV shows with more than 5 seasons
with cte as(
select *, TRY_CAST(REPLACE(duration,' Seasons','')as int) as [Season Count]
from netflix_titles
where type = 'TV Show')
select * from cte
where [Season Count] >5
order by [Season Count] desc

--Count the number of content items in each genre
with cte as(
select * from netflix_titles
cross apply string_split(listed_in,','))
select value,count(show_id) [Genre Count]
from cte 
group by value
order by [Genre Count] desc

--Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
select TOP 5 
YEAR(date_added) [Year],COUNT(show_id) [Count Year-wise]
from netflix_titles
where country like '%india%'
group by YEAR(date_added)
order by [Count Year-wise] desc

--List all movies that are documentaries
select type,title,listed_in
from netflix_titles
where type = 'Movie' and listed_in like '%Documentaries%'

--Find all content without a director
select * from netflix_titles
where director is null

--Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
AND [cast] LIKE '%Salman Khan%'
AND TRY_CONVERT(DATE, date_added, 107) IS NOT NULL
AND YEAR(TRY_CONVERT(DATE, date_added, 107)) >= YEAR(GETDATE()) - 10;

--Find the top 10 actors who have appeared in the highest number of movies produced in India.
with cte as(
select * from netflix_titles
where type = 'Movie' and country like '%india%')
select top 10 value [Actors], count(show_id) [count]
from cte
cross apply string_split(cast,',')
group by value
order by [count] desc

--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
with cte as(
select *, 
case
     when description like '%kill%' or description like '%violence%' then 'Bad'
     else 'Good'
end as [Good/Bad]
from netflix_titles)
select [Good/Bad],count(show_id) [Count] from cte
group by [Good/Bad]



















