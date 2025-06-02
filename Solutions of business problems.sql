-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT
	type,
	COUNT(show_id) AS media_count
FROM netflix
GROUP BY type
ORDER BY media_count DESC


-- 2. Find the most common rating for movies and TV shows

WITH rating_count_cte AS 

(SELECT
	type,
	rating,
	COUNT(*) AS rating_count
FROM netflix
GROUP BY type, rating),


rating_rank_cte AS 
(SELECT 
	type,
	rating,
	rating_count,
	RANK()OVER(PARTITION BY type ORDER BY rating_count DESC) AS rating_rank
FROM rating_count_cte)

SELECT * 
FROM rating_rank_cte
WHERE rating_rank = 1


-- 3. List all movies released in a specific year (2021)

SELECT 
	show_id,
	type,
	title,
	release_year
FROM netflix
WHERE type = 'Movie' AND release_year = 2021

-- 4.Find the top 5 countries with the most content on Netflix
WITH country_count AS 

(SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC)

SELECT * FROM country_count
WHERE country IS NOT NULL
LIMIT 5


-- 5. Identify the longest movie

SELECT
	show_id,
	type,
	title,
	duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC 
LIMIT 1

-- 6. Find content added in the last 5 years

SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

WITH director_cte AS 
(SELECT 
	show_id,
	type,
	title,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director
FROM netflix)

SELECT * FROM director_cte
WHERE director = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT 
	show_id,
	type,
	title,
	duration
FROM netflix
WHERE type = 'TV Show'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT < 5


-- 9. Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
COUNT(*) AS genre_count
FROM netflix
GROUP BY 1 
ORDER BY 2 DESC


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
-- Indian shows 
WITH indian_shows AS 
(SELECT
	show_id,
	country,
	release_year
FROM netflix
WHERE ',' || country || ',' LIKE '%,India,%' 
OR country = 'India'),

-- Total count of indian releases

total_indian_count AS
(SELECT 
COUNT(*) AS total_count
FROM indian_shows),

-- Group by year
yearly_indian_count AS
(SELECT 
'India' AS country,
release_year,
COUNT(*) AS yearly_count
FROM indian_shows
GROUP BY release_year)

-- Final calculation 

SELECT
	country,
	release_year,
	yearly_count,
	ROUND(
	(yearly_count * 100.0 / (SELECT total_count FROM total_indian_count)), 2
	) AS release_percentage 
FROM yearly_indian_count
ORDER BY release_percentage DESC
LIMIT 5

-- 11. List all movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%'



-- 12. Find all content without a director

SELECT * 
FROM netflix 
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%' 
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

-- Indian movies 
WITH 
indian_movies AS  

(SELECT 
	show_id,
	country,
	casts
FROM netflix
WHERE (',' || country || ',' LIKE '%,India,%' OR country = 'India')
OR country = 'India')


-- Extract actors count 
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
COUNT(*) AS actor_count
FROM indian_movies
GROUP BY 1
ORDER BY actor_count DESC
LIMIT 10 



-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH 
category_cte AS 
(SELECT *,
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%'THEN 'Bad'
		ELSE 'Good'
	END AS category
FROM netflix)

SELECT 
type,
category,
COUNT(*) AS movie_count
FROM category_cte
GROUP BY 1,2
ORDER BY 3 DESC

