-- AVERAGE GENRE RATINGS
SELECT 
  tb.genres,
  AVG(tr.average_rating) AS avg_rating,
  COUNT(*) AS num_titles
FROM 
  `bigquery-public-data.imdb.title_basics` tb
JOIN 
  `bigquery-public-data.imdb.title_ratings` tr
ON 
  tb.tconst = tr.tconst
JOIN 
  `bigquery-public-data.imdb.title_akas` ta
ON 
  tb.tconst = ta.title_id
WHERE 
  tb.genres is not null
  AND tb.title_type = 'movie'
  -- AND tb.start_year = 2022
  AND ta.language = 'en'
  AND ta.region = 'US'
  AND tr.num_votes > 100
GROUP BY 
  tb.genres
ORDER BY 
  genres ASC
LIMIT 100;

-- TRENDING MOVIES
SELECT DISTINCT
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
JOIN 
  `bigquery-public-data.imdb.title_akas` ta
ON 
  tb.tconst = ta.title_id
WHERE 
  tb.title_type = 'movie'
  AND tb.start_year BETWEEN EXTRACT(YEAR FROM CURRENT_DATE()) - 2 AND EXTRACT(YEAR FROM CURRENT_DATE())
  AND tr.average_rating >= 7.0
  AND tr.num_votes >= 5000
  AND tb.is_adult = 0
  AND ta.region = 'US'
ORDER BY 
  tr.average_rating DESC,
  tr.num_votes DESC
LIMIT 50;

-- UNDERRATED MOVIES
SELECT 
  tb.primary_title,
  tb.start_year,
  tb.genres,
  tr.average_rating,
  tr.num_votes,
  ta.language
FROM 
  `bigquery-public-data.imdb.title_basics` tb
JOIN
  `bigquery-public-data.imdb.title_akas` ta
ON
  tb.tconst = ta.title_id
JOIN 
  `bigquery-public-data.imdb.title_ratings` tr
ON 
  tb.tconst = tr.tconst
WHERE 
  tb.title_type = 'movie'
  AND tr.average_rating >= 8.0
  AND tr.num_votes BETWEEN 100 and 1000
  AND ta.language = 'en'
ORDER BY 
  tr.average_rating DESC,
  tr.num_votes ASC
LIMIT 100;
