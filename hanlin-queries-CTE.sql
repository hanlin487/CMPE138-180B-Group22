-- GENRE AVGs
WITH filtered_movies AS (
  SELECT 
    tb.tconst,
    tb.genres,
    tr.average_rating
  FROM 
    `bigquery-public-data.imdb.title_basics` tb
  JOIN 
    `bigquery-public-data.imdb.title_ratings` tr 
  ON 
    tb.tconst = tr.tconst
  WHERE 
    tb.title_type = 'movie'
    AND tb.genres IS NOT NULL
    AND tr.num_votes > 100
),
en_ta AS (
  SELECT DISTINCT 
    title_id
  FROM 
    `bigquery-public-data.imdb.title_akas`
  WHERE 
    language = 'en' 
    AND region = 'US'
)
SELECT 
  fm.genres,
  AVG(fm.average_rating) AS avg_rating,
  COUNT(*) AS num_titles
FROM 
  filtered_movies fm
JOIN 
  en_ta ta 
ON 
  fm.tconst = ta.title_id
GROUP BY 
  fm.genres
ORDER BY 
  fm.genres ASC
LIMIT 100;

-- TRENDING MOVIES
WITH filtered_movies AS (
  SELECT 
    tb.tconst,
    tb.primary_title,
    tb.start_year,
    tb.genres,
    tr.average_rating,
    tr.num_votes
  FROM 
    `bigquery-public-data.imdb.title_basics` tb
  JOIN 
    `bigquery-public-data.imdb.title_ratings` tr
  ON 
    tb.tconst = tr.tconst
  WHERE 
    tb.title_type = 'movie'
    AND tb.start_year BETWEEN EXTRACT(YEAR FROM CURRENT_DATE()) - 2 AND EXTRACT(YEAR FROM CURRENT_DATE())
    AND tr.average_rating >= 7.0
    AND tr.num_votes >= 5000
),
en_ta AS (
  SELECT DISTINCT 
    title_id
  FROM `bigquery-public-data.imdb.title_akas`
  WHERE 
    region = 'US'
)
SELECT 
  fm.primary_title,
  fm.start_year,
  fm.genres,
  fm.average_rating,
  fm.num_votes
FROM 
  filtered_movies fm
JOIN 
  en_ta ta 
ON 
  fm.tconst = ta.title_id
ORDER BY 
  fm.average_rating DESC,
  fm.num_votes DESC
LIMIT 100;

-- UNDERRATED
WITH filtered_movies AS (
  SELECT 
    tb.tconst,
    tb.primary_title,
    tb.start_year,
    tb.genres,
    tr.average_rating,
    tr.num_votes
  FROM 
    `bigquery-public-data.imdb.title_basics` tb
  JOIN 
    `bigquery-public-data.imdb.title_ratings` tr 
  ON 
    tb.tconst = tr.tconst
  WHERE 
    tb.title_type = 'movie'
    AND tr.average_rating >= 8.0
    AND tr.num_votes BETWEEN 100 AND 1000
),
en_ta AS (
  SELECT DISTINCT 
    title_id
  FROM `bigquery-public-data.imdb.title_akas`
  WHERE 
    language = 'en'
)
SELECT 
  fm.primary_title,
  fm.start_year,
  fm.genres,
  fm.average_rating,
  fm.num_votes,
  'en' AS language
FROM 
  filtered_movies fm
JOIN 
  en_ta ta 
ON 
  fm.tconst = ta.title_id
ORDER BY 
  fm.average_rating DESC,
  fm.num_votes ASC
LIMIT 100;
