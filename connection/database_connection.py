import psycopg2, psycopg2.extras
import pandas as pd
import os

db_params = {
    "dbname": "metro_cdmx",
    "user": "admin",
    "password": "password",
    "host": "postgis",
    "port": "5432",
}
def connection(db_parameters):
    try:
        connection = psycopg2.connect(**db_parameters)
        connection.set_session(readonly=True)
        print("Connection to PostgreSQL database successful!")

    except psycopg2.Error as e:
        print("Error: Could not connect to the PostgreSQL database.")
        print(e)
    
    return connection.cursor()

cur = connection(db_params)

# Database operations

databases = {
    # name of the database: path to the query file
    #'trajectories': 'connection/db_queries/query_elapid.sql',
    #'count_data': 'connection/db_queries/count_data.sql',
    #'background_points': 'connection/db_queries/background_points.sql',
    #'americas_shapefile': 'connection/db_queries/americas_shapefile.sql',
    'convex_hull': 'connection/db_queries/convex_hull.sql',
}

for db_name, db_file in databases.items():
    with open(db_file, 'r') as file:
    # Read the entire file content
        database = file.read()
        print('Querying data: ', db_name)
    
    # Execute the query
    query = database
    cur.execute(query)
    results = cur.fetchall()
    column_names = [desc[0] for desc in cur.description]

    # Convert data into DataFrame
    df = f"{db_name}_df"
    df = pd.DataFrame(results)
    df.columns = column_names

    # Create directory if it doesn't exist
    dir = 'data'
    if not os.path.exists(dir):
        os.makedirs(dir)

    df.to_csv(f'{dir}/{db_name}.csv', index=False)
    print(f'Data saved in {dir}/{db_name}.csv')
