-- Used in DBeaver for gathering average cloud coverage of each city within the year 2020.

SELECT 
    london.month, 
    london.london_average_cloud_cover_2020, 
    amsterdam.amsterdam_average_cloud_cover_2020, 
    lisbon.lisbon_average_cloud_cover_2020
FROM (
    SELECT EXTRACT(MONTH FROM date::timestamp) AS month, AVG(cloud_cover) AS london_average_cloud_cover_2020
    FROM london_table
    WHERE EXTRACT(YEAR FROM date::timestamp) = 2020
    GROUP BY month
) AS london
JOIN (
    SELECT EXTRACT(MONTH FROM date::timestamp) AS month, AVG(cloud_cover) AS amsterdam_average_cloud_cover_2020
    FROM amsterdam_table
    WHERE EXTRACT(YEAR FROM date::timestamp) = 2020
    GROUP BY month
) AS amsterdam ON london.month = amsterdam.month
JOIN (
    SELECT EXTRACT(MONTH FROM date::timestamp) AS month, AVG(cloud_cover) AS lisbon_average_cloud_cover_2020
    FROM lisbon_table
    WHERE EXTRACT(YEAR FROM date::timestamp) = 2020
    GROUP BY month
) AS lisbon ON london.month = lisbon.month
ORDER BY london.month;

--SQL query for PostgreSQL usage.
/*
SELECT 
    london.month, 
    london.london_average_cloud_cover_2020 AS london_average_cloud_cover_2020,
    amsterdam.amsterdam_average_cloud_cover_2020 AS amsterdam_average_cloud_cover_2020,
    lisbon.lisbon_average_cloud_cover_2020 AS lisbon_average_cloud_cover_2020
FROM (
    SELECT EXTRACT(MONTH FROM date) AS month, AVG(cloud_cover) AS london_average_cloud_cover_2020
    FROM london
    WHERE EXTRACT(YEAR FROM date) = 2020
    GROUP BY month
) AS london
JOIN (
    SELECT EXTRACT(MONTH FROM date) AS month, AVG(cloud_cover) AS amsterdam_average_cloud_cover_2020
    FROM amsterdam
    WHERE EXTRACT(YEAR FROM date) = 2020
    GROUP BY month
) AS amsterdam ON london.month = amsterdam.month
JOIN (
    SELECT EXTRACT(MONTH FROM date) AS month, AVG(cloud_cover) AS lisbon_average_cloud_cover_2020
    FROM lisbon
    WHERE EXTRACT(YEAR FROM date) = 2020
    GROUP BY month
) AS lisbon ON london.month = lisbon.month
ORDER BY london.month;
*/