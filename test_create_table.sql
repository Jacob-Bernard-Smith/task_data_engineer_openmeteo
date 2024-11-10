-- Used to test creating a table.

CREATE TABLE IF NOT EXISTS london (
    date TIMESTAMPTZ NOT NULL,
    cloud_cover FLOAT,
    cloud_cover_low FLOAT,
    cloud_cover_mid FLOAT,
    cloud_cover_high FLOAT
);
SELECT * FROM london;

/*
CREATE TABLE IF NOT EXISTS amsterdam (
    date TIMESTAMPTZ NOT NULL,
    cloud_cover FLOAT,
    cloud_cover_low FLOAT,
    cloud_cover_mid FLOAT,
    cloud_cover_high FLOAT
);
SELECT * FROM amsterdam;
*/

/*
CREATE TABLE IF NOT EXISTS lisbon (
    date TIMESTAMPTZ NOT NULL,
    cloud_cover FLOAT,
    cloud_cover_low FLOAT,
    cloud_cover_mid FLOAT,
    cloud_cover_high FLOAT
);
SELECT * FROM lisbon;
*/