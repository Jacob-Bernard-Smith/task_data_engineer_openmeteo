# 1. Application Installation
Within my Windows computer, I installed the following from their respective websites;
**PostgreSQL** (https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
**DBeaver** (https://dbeaver.io/download/)

I downloaded **WSL**, a Windows Subsystem for running a Linux environment (Ubuntu). This is to avoid any Python version conflicts already present on my Windows machine.

From UNIX (Ubuntu) command line, I installed the following;
Before installation:
> `sudo apt-get update`

**Python**
> `sudo apt-get install PostgreSQL`

**PostgreSQL**
> `sudo apt-get install python3`

The reason for installing PostgreSQL on both Windows and Linux environments is to be able to use its functions within Linux and create the necessary tables, and have an empty database present ready to move the tables into so DBeaver can connect to it.

# 2. Environment Setup
The directory "openmeteo" was created for this project under my UNIX user directory:
>`cd openmeteo`

To download and install Python packages, I created a virtual environment named "venviron".
Create virtual environment:
>`python3 -m venv venviron`

Enter virtual environment:
>`source venviron/bin/activate`

Within the virtual environment, the following Python packages were installed through UNIX from the **PyPI** index (https://pypi.org);
- **openmeteo-requests**
- **requests-cache**
- **retry-requests**
- **numpy**
- **pandas**
- **psycopg2**

The command to install them was:
>`pip install <package name(s)>`

"pip" is a Python package itself but it was installed alongside Python.

The PostgreSQL database was created from the following steps;
Connect to PostgreSQL:
>`sudo -u postgres psql`

My UNIX credentials were then entered.

Create the database:
>`CREATE DATABASE weather_db;`

The username and password is simply "PostgreSQL" and "password" respectively.
This is a localhost, so the IP address is 127.0.0.1.

# 3. Environment Tests

To make sure PostgreSQL was working, and that Python scripts work, I ran some commands. I used **Notepad++** (https://notepad-plus-plus.org) to make test scripts.

1. Checking if the database is active:
>`sudo systemctl status postgresql`

2. Command for running Python script, to connect to the PostgreSQL database using the required credentials:
>`python3 test_db.py`

File contents:
>import psycopg2
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

Expected the output of "Database connection successful!".
This uses the **psycopg2** package. Although the more recent **psycopg3** is available, psycopg2 has more widely-available knowledge among users.

3. Connect to the database with:
>`sudo -u postgres psql -d weather_db`

Command for running SQL script, to create a new table for the London data and then count how many rows are present:
>`\i test_create_table.sql`

File contents:
>CREATE TABLE IF NOT EXISTS london (
    date TIMESTAMPTZ NOT NULL,
    cloud_cover FLOAT,
    cloud_cover_low FLOAT,
    cloud_cover_mid FLOAT,
    cloud_cover_high FLOAT
);
SELECT * FROM london;

Expected to give 0 rows, but display the five columns specified.

4. Command for Python script, to connect to a different, simple API (https://randomfox.ca):
>`python3 test_api.py`

File contents:
>import requests
response = requests.get("https://randomfox.ca/floof")
"""print(response.status_code)
print(response.text)
print(response.json())"""
fox = response.json()
print(fox['image'])

Expected output is a URL to a random photo of a fox within the source's library.

# 4. API Variables

Within the documentation page of the Open-Meteo website (https://open-meteo.com/en/docs), parameters can be set for precise locations and the types of meteorological data to be retrieved. First, three entries are entered on the location list field; London, Amsterdam, Lisbon.
The input does not accept location names and requires coordinates. The coordinates were obtained from the city's respective Wikipedia page (e.g. https://en.wikipedia.org/wiki/London). This data itself is from GeoHack (e.g. https://geohack.toolforge.org/geohack.php?pagename=London&params=51_30_N_0_08_W_region), the same source used by Google and Bing. The three cities' coordinates are entered in the order of London, Amsterdam, Lisbon;
*51.5, -0.13
52.37, 4.89
38.73, -9.15*

The time interval was then entered as;
Start Date: *2012-01-01*
End Date: *2022-12-31*
The data retrieved will be at UTC, from 2012-01-01 00:00:00 to 2022-12-31 23:00:00.

The Hourly Weather Variables selected are the following;
*Cloud cover Total
Cloud cover Low
Cloud cover Mid
Cloud cover High*

The documentation on the Open-Meteo website has a sample Python code to start from.

# 5. API Data Retrieval Script

Using Notepad++, the Python file for retrieving API data is "meteo-api-to-pg.py". Its contents include;
1. Importing of the Python packages, then setting up an API client with cache.
2. Variables required, which are the coordinates of the three cities, start and end dates, and the hourly data for the four cloud cover variables.
3. Connecting to the PostgreSQL database using the: IP address (*127.0.0.1*), name (*weather_db*), username (*postgres*), password (*password*), using the usable by the **psycopg2** package. Then print out if the database connection was successful or not.
4. Update the parameters for the location to be specified, starting with London's coordinates.
5. Converting the cloud cover variables to a float so it is usable by the **NumPy** package.
6. A DataFrame was created to contain the variables, this was provided by the **pandas** package.
7. Prints to verify the data before inserting into a table, then create the table, named after the city, with the columns: *date*, *cloud_cover*, *cloud_cover_low*, *cloud_cover_mid*, and *cloud_cover_high*.
8. Insert the data into the table, then more prints to verify the data that is present within the table after insertion.
9. Sections 4-8 are repeated for the three locations.

This script was then ran:
>`python3 meteo-api-to-pg.py`

Lastly within UNIX, the following checks were made, first entering the database with:
>`sudo -u postgres psql -d weather_db`

Then checking the data within each city table, each query separately:

>`SELECT * FROM london;`

>`SELECT * FROM amsterdam;`

>`SELECT * FROM lisbon;`

Due to the number of rows in the table being extensive, to make sure the same volume of data was inserted into each table the following query was used:

>'SELECT 'london' , COUNT(*) FROM london
UNION ALL
SELECT 'amsterdam' , COUNT(*) FROM amsterdam
UNION ALL
SELECT 'lisbon' , COUNT(*) FROM lisbon;'

Each table should have the same number of rows, in this case it is 96,432.

## 6. Visualize Data with DBeaver

To move the retrieved API data from the UNIX environment into the DBeaver application, I took these steps:

Created a CSV file for each of the three city tables with the following three commands:

>`\copy london TO '/tmp/london_table.csv' WITH (FORMAT CSV, HEADER);`

>`\copy amsterdam TO '/tmp/amsterdam_table.csv' WITH (FORMAT CSV, HEADER);`

>`\copy lisbon TO '/tmp/lisbon_table.csv' WITH (FORMAT CSV, HEADER);`

For distinction, the names of the tables each have added "_table" into their names.

The new files are created in the Ubuntu \tmp\ folder, and then moved manually from that directory to a Windows directory by dragging and dropping the files to the desktop.

The PostgreSQL application was started and database created, with the same name and credentials as the one made within the UNIX environment.
Within DBeaver, a connection is established to the newly made PostgreSQL with those credentials. Then, the three CSV files were imported into the database, and contents checked.
The specification of the average (Total) cloud cover for each city in the year 2020 within each month was gathered using the following SQL query:

>SELECT 
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

This displays the data in three columns: *month*, *london_average_cloud_cover_2020*, *amsterdam_average_cloud_cover_2020*, and *lisbon_average_cloud_cover_2020*. Twelve rows are present, one for each month. This is the output.

|month|london_average_cloud_cover_2020|amsterdam_average_cloud_cover_2020|lisbon_average_cloud_cover_2020
|-|-|-|-|
|1|70.1787634408602151|76.8279569892473118|50.9381720430107527|
|2|67.1020114942528736|72.7945402298850575|49.9583333333333333|
|3|55.2678331090174966|52.5908479138627187|43.1520861372812921|
|4|47.1472222222222222|43.6013888888888889|58.4513888888888889|
|5|51.2043010752688172|47.7930107526881720|50.4422043010752688|
|6|61.0708333333333333|66.7277777777777778|29.3902777777777778|
|7|66.2190860215053763|63.0053763440860215|11.5295698924731183|
|8|65.3467741935483871|58.8118279569892473|28.4825268817204301|
|9|55.4041666666666667|56.3500000000000000|43.9916666666666667|
|10|71.1073825503355705|77.1261744966442953|44.7704697986577181|
|11|70.2486111111111111|67.6375000000000000|61.7180555555555556|
|12|75.6787634408602151|79.4448924731182796|59.7365591397849462|
