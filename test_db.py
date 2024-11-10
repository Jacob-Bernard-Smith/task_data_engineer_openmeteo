## Used to test connection to PostgreSQL database from UNIX environment.

import psycopg2
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
except psycopg2.OperationalError as e:
    print(f"Failed to connect to the database: {e}")