-----------------------------------------------
-- DATA EXPLORATION - UNDERSTANDING THE DATA
-----------------------------------------------
-- Display all records, for testing purposes only
SELECT * FROM netflix LIMIT 5;

-- HOW MANY TOTAL CONTENTS ARE THERE
SELECT COUNT(*) AS total_count
FROM netflix;

-- What are the various types of content present in the data
SELECT DISTINCT type
FROM netflix;

-----------------------------------------------
-- DATA ANALYSIS
-----------------------------------------------

-- Count number of movies and tv shows
SELECT type, COUNT(*) AS category_count
FROM netflix
GROUP BY 1;

-- Find the most common rating for movies and tvshows
SELECT type, rating, ratings_count
FROM(
	SELECT type, rating, COUNT(*) AS ratings_count,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
	FROM netflix
	WHERE rating IS NOT NULL
	GROUP BY 1, 2
) AS subquery
WHERE rnk=1;

-- List all the movies released in the year 2020
SELECT *
FROM netflix
WHERE type='Movie' AND release_year=2020;

-- Find the top 5 countries with most content on netflix
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(*) AS number_of_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Identify the longest movie
SELECT *,
	SUBSTRING(duration FROM '[0-9]+')::INT AS duration_in_mins
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY duration_in_mins DESC
LIMIT 1;

-- Find all the content from last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY')>CURRENT_DATE - INTERVAL '5 years';

-- Find all the movies and tv shows directed by 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- List all tv shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- Get the number of contents in each genre
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS content_count
FROM netflix
GROUP BY 1;

-- Find average content released in india in each year and return the top 5 years with highest average
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added,
	COUNT(*) AS content_released_per_year,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::decimal * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1;

-- list all movies that are documentaries
SELECT *
FROM netflix
WHERE type='Movie' AND listed_in LIKE '%Documentaries%';

-- Find number of movies in which actor 'Salman Khan' appeared in last 10 years
SELECT *
FROM netflix
WHERE
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	AND
	casts ILIKE '%salman khan%';

-- Find top 10 actors who appeared in highest number of movies produced in india.
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(show_id) AS movie_count
FROM netflix
WHERE type='Movie' AND country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Categorize content as 'Bad' if it contains 'kill' or 'violence' in description field and 'Good' otherwise. Count the number of items in each category.
SELECT
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS category,
	COUNT(show_id) AS category_count
FROM netflix
GROUP BY 1;