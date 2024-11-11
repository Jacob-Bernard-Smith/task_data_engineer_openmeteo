-- Used in DBeaver for gathering average cloud coverage of each city within the year 2020.
-- Ammended SQL query
-- Grouped by year, month
-- Ordered by year, month, average_cloud_cover

SELECT
    'London' AS city,
    EXTRACT(YEAR FROM date::timestamp) AS year,
    EXTRACT(MONTH FROM date::timestamp) AS month,
    AVG(cloud_cover) AS average_cloud_cover
FROM london
WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
GROUP BY year, month
UNION ALL
SELECT
    'Amsterdam' AS city,
    EXTRACT(YEAR FROM date::timestamp) AS year,
    EXTRACT(MONTH FROM date::timestamp) AS month,
    AVG(cloud_cover) AS average_cloud_cover
FROM amsterdam
WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
GROUP BY year, month
UNION ALL
SELECT
    'Lisbon' AS city,
    EXTRACT(YEAR FROM date::timestamp) AS year,
    EXTRACT(MONTH FROM date::timestamp) AS month,
    AVG(cloud_cover) AS average_cloud_cover
FROM lisbon
WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
GROUP BY year, month
ORDER BY year, month, average_cloud_cover;
