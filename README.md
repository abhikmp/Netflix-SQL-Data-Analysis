# Netflix Movies And Shows Data Analysis Using SQL 📊
![](Netflix_logo.png)
 
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Netflix titles](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Dataset Overview  
The dataset contains information about Netflix titles, including type, title, director, cast, country, release year, rating, and more.  
- **Total Entries**: 8,807  
- **Columns**: 12

## Schema
```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(220),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(300)
);
```
---

## Data Analysis
### 1. Determine the distribution of content types on Netflix
```sql
SELECT type, COUNT(*) AS category_count
FROM netflix
GROUP BY 1;
```

### 2. Find the Most Common Rating for Movies and TV Shows
```sql
SELECT type, rating, ratings_count
FROM(
	SELECT type, rating, COUNT(*) AS ratings_count,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
	FROM netflix
	WHERE rating IS NOT NULL
	GROUP BY 1, 2
) AS subquery
WHERE rnk=1;
```

### 3. List All Movies Released in a Specific Year (e.g., 2020
```sql
SELECT *
FROM netflix
WHERE type='Movie' AND release_year=2020;
```

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
	COUNT(*) AS number_of_contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
### 5. Identify the Longest Movie
```sql
SELECT *,
	SUBSTRING(duration FROM '[0-9]+')::INT AS duration_in_mins
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY duration_in_mins DESC
LIMIT 1;
```

### 6. Find all content added in the Last 5 Years
```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY')>CURRENT_DATE - INTERVAL '5 years';
```

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type='TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

### 9. Count the Number of Content Items in Each Genre
```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	COUNT(show_id) AS content_count
FROM netflix
GROUP BY 1;
```

### 10. Find average content released in india in each year and return the top 5 years with highest average
```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added,
	COUNT(*) AS content_released_per_year,
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%india%')::decimal * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1;
```

### 11. List All Movies that are Documentaries
```sql
SELECT *
FROM netflix
WHERE type='Movie' AND listed_in LIKE '%Documentaries%';
```

### 12. Find All Content Without a Director
```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT *
FROM netflix
WHERE
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	AND
	casts ILIKE '%salman khan%';
```

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(show_id) AS movie_count
FROM netflix
WHERE type='Movie' AND country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### 15. Categorize content as 'Bad' if it contains 'kill' or 'violence' in description field and 'Good' otherwise. Count the number of items in each category.
```sql
SELECT
	CASE
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS category,
	COUNT(show_id) AS category_count
FROM netflix
GROUP BY 1;
```

---

## Key Findings and Insights 

### 1️⃣ Content Type Distribution  
Netflix offers a diverse catalog:  
- **Movies**: 5,174 titles  
- **TV Shows**: 3,633 titles  

📌 **Movies dominate the platform, making up ~59% of the total content.**  

---

### 2️⃣ Most Common Ratings  
The most frequent ratings indicate content targeted at mature audiences:  
- **Movies**: TV-MA (1,576 titles)  
- **TV Shows**: TV-MA (1,317 titles)  

📌 **TV-MA is the predominant rating, reflecting Netflix's focus on mature-themed content.**  

---

### 3️⃣ Release Trends  
**Movies Released in 2020**:  
Netflix released 334 movies in 2020, showing a strong production pace even during global challenges.  

**Recent Additions**:  
- **Last 5 Years**: 4,053 titles added  
📌 **This indicates a surge in content acquisition and production in recent years.**  

---

### 4️⃣ Geographic Analysis  
**Top 5 Countries with Most Content**:  
1. **United States**: 3,056 titles  
2. **India**: 972 titles  
3. **United Kingdom**: 419 titles  
4. **Japan**: 336 titles  
5. **South Korea**: 334 titles  

📌 **The U.S. leads content creation, while India ranks second with a substantial contribution.**  

---

### 5️⃣ Notable Highlights  
**Longest Movie**:  
- *The Irishman* (209 minutes)  

**Content Genres**:  
Diverse genres like Documentaries, Comedies, and Dramas dominate the platform.  

**Director Spotlight**:  
Directors like *Rajiv Chilaka* contribute significantly to children’s content.  

---


## Author - Abhijeeth S
