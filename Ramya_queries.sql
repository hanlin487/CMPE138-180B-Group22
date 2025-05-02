
-- Similar movie recommendation

WITH input_movie AS (
    SELECT 
        tb.tconst,
        tb.primary_title,
        tb.genres,
        STRING_AGG(DISTINCT tp.nconst) AS actors,
        tc.directors,
        tb.start_year,
        tr.average_rating
    FROM 
        `bigquery-public-data.imdb.title_basics` tb 
    JOIN 
        `bigquery-public-data.imdb.title_ratings` tr ON tb.tconst = tr.tconst
    JOIN 
        `bigquery-public-data.imdb.title_principals` tp ON tb.tconst = tp.tconst
    JOIN 
        `bigquery-public-data.imdb.title_crew` tc ON tb.tconst = tc.tconst
    WHERE 
        tb.primary_title = 'Titanic' 
    GROUP BY 
        tb.tconst, tb.primary_title, tb.genres, tc.directors, tb.start_year, tr.average_rating
)
SELECT 
    DISTINCT tb.primary_title AS Recommended_Movies,
    tb.start_year AS Release_Year,
    tr.average_rating AS Average_rating,
    tb.genres AS Genres
FROM 
   `bigquery-public-data.imdb.title_basics` tb
JOIN 
    `bigquery-public-data.imdb.title_ratings` tr ON tb.tconst = tr.tconst
JOIN 
    `bigquery-public-data.imdb.title_principals` tp ON tb.tconst = tp.tconst
JOIN 
    `bigquery-public-data.imdb.title_crew` tc ON tb.tconst = tc.tconst,
    input_movie im
WHERE 
    (
        EXISTS (
            SELECT 1
            FROM UNNEST(SPLIT(im.genres, ',')) AS ig
            WHERE tb.genres LIKE CONCAT('%', ig, '%')
        )
        OR tp.nconst IN (SELECT nconst FROM UNNEST(SPLIT(im.actors, ',')))
        OR tc.directors LIKE CONCAT('%', im.directors, '%')
    )
    AND ABS(tb.start_year - im.start_year) <= 5
    AND tb.tconst != im.tconst
    AND tr.average_rating >= 6.0
    AND tb.title_type = 'movie' 
GROUP BY 
    tb.primary_title, tb.start_year, tr.average_rating, tb.genres
ORDER BY 
    tr.average_rating DESC
LIMIT 10;

-- Cast/Crew Based Recommendations

SELECT
  tb.primary_title AS Movie,
  tb.start_year AS Year,
  tr.average_rating AS Rating,
  tr.num_votes AS Votes,
  tb.genres AS Genres
FROM
  `bigquery-public-data.imdb.title_basics` tb
JOIN `bigquery-public-data.imdb.title_ratings` tr  ON tb.tconst = tr.tconst

LEFT JOIN `bigquery-public-data.imdb.title_principals` tp
  ON tb.tconst = tp.tconst AND tp.category IN ('actor','actress')
LEFT JOIN `bigquery-public-data.imdb.title_crew` tc
  ON tb.tconst = tc.tconst

LEFT JOIN `bigquery-public-data.imdb.name_basics` nb_cast
  ON tp.nconst = nb_cast.nconst
LEFT JOIN `bigquery-public-data.imdb.name_basics` nb_dir
  ON tc.directors = nb_dir.nconst

WHERE
  tb.title_type = 'movie'
  AND tr.num_votes >= 1000
  AND (
       nb_cast.primary_name = 'Scarlett Johansson'
    OR nb_dir.primary_name  = 'Scarlett Johansson'
  )
ORDER BY
  tr.average_rating DESC,
  tr.num_votes DESC
LIMIT 10;

-- Top-Rated Movies with Multiple Filters

SELECT
  tb.primary_title AS Movie_Title,
  tb.start_year AS Release_Year,
  tb.genres AS Genre,
  ak.language AS Language,
  ak.region AS Country,
  tr.average_rating AS Rating,
  tr.num_votes AS Popularity
FROM
  `bigquery-public-data.imdb.title_basics` tb
JOIN
  `bigquery-public-data.imdb.title_ratings` tr
  ON tb.tconst = tr.tconst
LEFT JOIN
  `bigquery-public-data.imdb.title_akas` ak
  ON tb.tconst = ak.title_id
WHERE
  tb.title_type = 'movie'
  AND tb.start_year BETWEEN 2015 AND 2024
  AND tr.num_votes >= 1000
  AND tr.average_rating >= 7.5
  AND tb.genres IS NOT NULL
ORDER BY
  tr.average_rating DESC,
  tr.num_votes DESC
LIMIT 20;