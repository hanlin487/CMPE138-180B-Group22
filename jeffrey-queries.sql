
-- FEATURE 6: Trending Movies by Year
SELECT
  tb.primary_title AS title,
  tb.start_year,
  tr.average_rating AS rating,
  tr.num_votes AS votes,
  tb.genres,
  tb.runtime_minutes
FROM
  `bigquery-public-data.imdb.title_basics` AS tb
JOIN
  `bigquery-public-data.imdb.title_ratings` AS tr
ON
  tb.tconst = tr.tconst
WHERE
  tb.title_type = 'movie'
  AND tb.start_year = 2022
  AND tr.num_votes >= 1000
ORDER BY
  tr.average_rating DESC
LIMIT 15;

-- FEATURE 7: Yearly Trends - Average IMDb Rating
SELECT
  tb.start_year AS release_year,
  COUNT(*) AS total_movies,
  ROUND(AVG(tr.average_rating), 2) AS avg_rating
FROM
  `bigquery-public-data.imdb.title_basics` tb
JOIN
  `bigquery-public-data.imdb.title_ratings` tr
ON
  tb.tconst = tr.tconst
WHERE
  tb.title_type = 'movie'
  AND tb.start_year IS NOT NULL
  AND tb.start_year BETWEEN 1990 AND 2023
  AND tr.num_votes >= 1000
GROUP BY release_year
ORDER BY release_year;

-- FEATURE 8: Top Rated Newcomer Directors/Actors
WITH person_movies AS (
  SELECT
    p.nconst,
    p.tconst,
    p.category
  FROM `bigquery-public-data.imdb.title_principals` p
  WHERE p.category IN ('actor', 'actress', 'director')
),
person_ratings AS (
  SELECT
    pm.nconst,
    AVG(tr.average_rating) AS avg_rating,
    COUNT(pm.tconst) AS num_movies
  FROM person_movies pm
  JOIN `bigquery-public-data.imdb.title_ratings` tr
    ON pm.tconst = tr.tconst
  GROUP BY pm.nconst
)
SELECT
  nb.primary_name AS name,
  nb.birth_year,
  pr.avg_rating,
  pr.num_movies
FROM person_ratings pr
JOIN `bigquery-public-data.imdb.name_basics` nb
  ON pr.nconst = nb.nconst
WHERE
  nb.birth_year > 1985
  AND pr.num_movies >= 3
  AND pr.avg_rating IS NOT NULL
ORDER BY pr.avg_rating DESC
LIMIT 15;
