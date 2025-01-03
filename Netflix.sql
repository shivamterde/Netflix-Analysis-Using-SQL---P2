CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


/* Count the Number of Movies vs TV Shows */

SELECT type,COUNT(*) FROM netflix
GROUP BY 1

/*  Find the Most Common Rating for Movies and TV Shows */

SELECT type,rating FROM 
(SELECT type,rating,COUNT(*), 
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking 
FROM netflix
group by 1,2)
WHERE ranking = 1

/* List All Movies Released in a Specific Year (e.g., 2020) */

SELECT title,type FROM netflix
WHERE type = 'Movie'
AND release_year = '2020'

/* Find the Top 5 Countries with the Most Content on Netflix */

SELECT 
UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(show_id) AS total_content FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

/* Identify the Longest Movie */

SELECT title,duration FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY Split_PART(duration,' ',1)::INT DESC
LIMIT 1

/* Find Content Added in the Last 5 Years */

SELECT * FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 Year'

/* Find All Movies/TV Shows by Director 'Rajiv Chilaka' */

SELECT New_Directors,title, duration FROM
(SELECT UNNEST(STRING_TO_ARRAY(director,',')) AS New_Directors,title, duration FROM netflix)
WHERE New_Directors = 'Rajiv Chilaka'

/* List All TV Shows with More Than 5 Seasons */

SELECT title AS Title,SPLIT_PART(duration,' ',1) AS Season FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1)::INT > 5

/* Count the Number of Content Items in Each Genre */

SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS Genre,COUNT(*) AS Count FROM netflix
GROUP BY 1

/* Find each year and the average numbers of content release in India on netflix. */

SELECT 
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as Year,
Round(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ='India')::numeric * 100,2) AS Average FROM netflix
WHERE country = 'India'
GROUP BY 1

/* List All Movies that are Documentaries */

SELECT title,listed_in AS Genre FROM netflix
WHERE type = 'Movie' AND listed_in = 'Documentaries'

/* Find All Content Without a Director */

SELECT type,title,director FROM netflix
WHERE director IS NULL

/* Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years */

SELECT type,title,casts FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

/* Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India */

SELECT UNNEST(STRING_TO_ARRAY(casts,',')),count(*) FROM netflix
WHERE type = 'Movie' AND country = 'India'
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 10

/* Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords */

SELECT
CASE
WHEN description ILIKE '%kill%' OR description ILIKE '%Violence%' THEN 'Bad'
ELSE 'Good'
END AS category,
COUNT(*)
FROM netflix
group by category
