-- Provides the average cloud coverage for each city per year.
SELECT
    london.year,
    london.london_cloud_coverage,
    amsterdam.amsterdam_cloud_coverage,
    lisbon.lisbon_cloud_coverage
FROM (
    SELECT EXTRACT(YEAR FROM date::timestamp) AS year, AVG(cloud_cover) AS london_cloud_coverage
    FROM london
    WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
    GROUP BY year
) AS london
JOIN (
    SELECT EXTRACT(YEAR FROM date::timestamp) AS year, AVG(cloud_cover) AS amsterdam_cloud_coverage
    FROM amsterdam
    WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
    GROUP BY year
) AS amsterdam ON london.year = amsterdam.year
JOIN (
    SELECT EXTRACT(YEAR FROM date::timestamp) AS year, AVG(cloud_cover) AS lisbon_cloud_coverage
    FROM lisbon
    WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022
    GROUP BY year
) AS lisbon ON london.year = lisbon.year
ORDER BY london.year;

-- Provides the average cloud coverage altitude metic for each city between the year 2012 to 2022.
SELECT
    'cloud_cover' AS metric,
    london.cloud_cover AS london_cloud_cover,
    amsterdam.cloud_cover AS amsterdam_cloud_cover,
    lisbon.cloud_cover AS lisbon_cloud_cover
FROM
    (SELECT AVG(cloud_cover) AS cloud_cover FROM london WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS london,
    (SELECT AVG(cloud_cover) AS cloud_cover FROM amsterdam WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS amsterdam,
    (SELECT AVG(cloud_cover) AS cloud_cover FROM lisbon WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS lisbon
UNION ALL
SELECT
    'cloud_cover_low' AS metric,
    london.cloud_cover_low AS london_cloud_cover_low,
    amsterdam.cloud_cover_low AS amsterdam_cloud_cover_low,
    lisbon.cloud_cover_low AS lisbon_cloud_cover_low
FROM
    (SELECT AVG(cloud_cover_low) AS cloud_cover_low FROM london WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS london,
    (SELECT AVG(cloud_cover_low) AS cloud_cover_low FROM amsterdam WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS amsterdam,
    (SELECT AVG(cloud_cover_low) AS cloud_cover_low FROM lisbon WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS lisbon
UNION ALL
SELECT
    'cloud_cover_mid' AS metric,
    london.cloud_cover_mid AS london_cloud_cover_mid,
    amsterdam.cloud_cover_mid AS amsterdam_cloud_cover_mid,
    lisbon.cloud_cover_mid AS lisbon_cloud_cover_mid
FROM
    (SELECT AVG(cloud_cover_mid) AS cloud_cover_mid FROM london WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS london,
    (SELECT AVG(cloud_cover_mid) AS cloud_cover_mid FROM amsterdam WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS amsterdam,
    (SELECT AVG(cloud_cover_mid) AS cloud_cover_mid FROM lisbon WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS lisbon
UNION ALL
SELECT
    'cloud_cover_high' AS metric,
    london.cloud_cover_high AS london_cloud_cover_high,
    amsterdam.cloud_cover_high AS amsterdam_cloud_cover_high,
    lisbon.cloud_cover_high AS lisbon_cloud_cover_high
FROM
    (SELECT AVG(cloud_cover_high) AS cloud_cover_high FROM london WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS london,
    (SELECT AVG(cloud_cover_high) AS cloud_cover_high FROM amsterdam WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS amsterdam,
    (SELECT AVG(cloud_cover_high) AS cloud_cover_high FROM lisbon WHERE EXTRACT(YEAR FROM date::timestamp) BETWEEN 2012 AND 2022) AS lisbon;