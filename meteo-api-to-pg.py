import requests

import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry

import psycopg2
from psycopg2 import sql

#import numpy as np

# Setup the Open-Meteo API client with cache
cache_session = requests_cache.CachedSession('.cache', expire_after=3600)
# Retry on error
retry_session = retry(cache_session, retries=5, backoff_factor=0.2)
openmeteo = openmeteo_requests.Client(session=retry_session)

# API data source
url = "https://archive-api.open-meteo.com/v1/archive"
# All required weather variables
# Order of variables in hourly is important for correct assignement

# Coordinates and table names
locations = [
    {"latitude": 51.5, "longitude": -0.13, "table": "london"},
    {"latitude": 52.37, "longitude": 4.89, "table": "amsterdam"},
    {"latitude": 38.73, "longitude": -9.15, "table": "lisbon"}
]
# Data scope
params = {
    "start_date": "2012-01-01",
    "end_date": "2022-12-31",
    "hourly": ["cloud_cover", "cloud_cover_low", "cloud_cover_mid", "cloud_cover_high"]
}

try:
    # Connect to database
    conn = psycopg2.connect(
        host="127.0.0.1",
        dbname="weather_db",
        user="postgres",
        password="password"
    )
    conn.autocommit = True
    cur = conn.cursor()
    print("Database connection successful!")

    for location in locations:
        # Update params with specific coordinates
        params["latitude"] = location["latitude"]
        params["longitude"] = location["longitude"]

        # Show the data being retrieved
        print(f"API request parameters for {location['table']}: {params}")
        responses = openmeteo.weather_api(url, params=params)

        # Show raw API response to verify
        print("Raw API response:")
        for response in responses:
            print(response)

        # Process location
        response = responses[0]
        print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E")
        print(f"Elevation {response.Elevation()} m asl")
        print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}")
        print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s")

        # Process hourly data (converted to usable float)
        hourly = response.Hourly()
        hourly_cloud_cover = hourly.Variables(0).ValuesAsNumpy().astype(float)
        hourly_cloud_cover_low = hourly.Variables(1).ValuesAsNumpy().astype(float)
        hourly_cloud_cover_mid = hourly.Variables(2).ValuesAsNumpy().astype(float)
        hourly_cloud_cover_high = hourly.Variables(3).ValuesAsNumpy().astype(float)

        # Create DataFrame
        hourly_df = pd.DataFrame({
            'date': pd.date_range(
                start=pd.to_datetime(hourly.Time(), unit="s", utc=True),
                end=pd.to_datetime(hourly.TimeEnd(), unit="s", utc=True),
                freq=pd.Timedelta(seconds=hourly.Interval()),
                inclusive="left"
            ),
            'cloud_cover': hourly_cloud_cover,
            'cloud_cover_low': hourly_cloud_cover_low,
            'cloud_cover_mid': hourly_cloud_cover_mid,
            'cloud_cover_high': hourly_cloud_cover_high
        })

        # Check for NaN values and print a message if found
        nan_rows = hourly_df[hourly_df.isnull().any(axis=1)]
        if not nan_rows.empty:
            print("Rows with NaN values found:")
            print(nan_rows)

        # Drop rows with NaN values
        hourly_df = hourly_df.dropna()

        # Convert DataFrame to list of tuples to handle Timestamps and numpy types
        hourly_data = [(row.date.to_pydatetime(), float(row.cloud_cover), float(row.cloud_cover_low), float(row.cloud_cover_mid), float(row.cloud_cover_high)) for row in hourly_df.itertuples(index=False)]

        # Show first 5 rows to verify
        print(f"Prepared data for insertion into {location['table']} (first 5 rows):", hourly_data[:5])

        # Create tables if it doesn't exist
        create_table_query = sql.SQL("""
        CREATE TABLE IF NOT EXISTS {table} (
            date TIMESTAMPTZ NOT NULL,
            cloud_cover FLOAT,
            cloud_cover_low FLOAT,
            cloud_cover_mid FLOAT,
            cloud_cover_high FLOAT
        );
        """).format(table=sql.Identifier(location["table"]))
        cur.execute(create_table_query)

        # Insert data into the table
        insert_query = sql.SQL("""
        INSERT INTO {table} (date, cloud_cover, cloud_cover_low, cloud_cover_mid, cloud_cover_high)
        VALUES (%s, %s, %s, %s, %s);
        """).format(table=sql.Identifier(location["table"]))
        for row in hourly_data:
            print(f"Inserting row into {location['table']}: {row}")
            cur.execute(insert_query, row)

        # After inserting data:
        # Show first 5 rows of table to verify
        cur.execute(sql.SQL("SELECT * FROM {table} LIMIT 5;").format(table=sql.Identifier(location["table"])))
        result = cur.fetchall()
        print(f"First 5 rows in the {location['table']} table:", result)

except psycopg2.OperationalError as e:
    print(f"Failed to connect to the database: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    cur.close()
    conn.close()
    print("Connection closed")
