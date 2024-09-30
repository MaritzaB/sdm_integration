import psycopg2, psycopg2.extras
import pandas as pd
import os
from shapely import wkt
import geopandas as gpd


def create_directory(directory):
    """
    Crea un directorio si no existe.
    Parámetros:
    - directory: El directorio a crear.
    """
    if not os.path.exists(directory):
        os.makedirs(directory)


def read_query_from_file(db_file):
    """
    Lee el contenido de un archivo SQL.
    Parámetros:
    - db_file: La ruta al archivo SQL.
    Retorna:
    - El contenido del archivo SQL como una cadena de texto.
    """
    with open(db_file, 'r') as file:
        query = file.read()
    return query


def execute_query(cur, query):
    """
    Ejecuta una consulta SQL en la base de datos.

    Parámetros:
    - cur: Cursor de la base de datos.
    - query: La consulta SQL a ejecutar.
    
    Retorna:
    - results: Los resultados de la consulta.
    - column_names: Los nombres de las columnas.
    """
    cur.execute(query)
    results = cur.fetchall()
    column_names = [desc[0] for desc in cur.description]
    return results, column_names


def save_results_to_csv(df, db_name, directory='data'):
    """
    Guarda los resultados de la consulta en un archivo CSV.

    Parámetros:
    - df: DataFrame con los resultados.
    - db_name: Nombre de la base de datos o tabla, usado como nombre de archivo.
    - directory: Directorio donde se guardará el archivo CSV.
    """
    create_directory(directory)
    csv_path = os.path.join(directory, f'{db_name}.csv')
    df.to_csv(csv_path, index=False)
    print(f'Data saved in {csv_path}')


def save_results_to_shapefile(df, db_name, directory='data', crs='EPSG:4326'):
    """
    Guarda los resultados de una consulta SQL en un archivo shapefile (.shp).

    Parámetros:
    - df: DataFrame con los resultados.
    - db_name: Nombre de la base de datos o tabla, usado como nombre de archivo.
    - directory: Directorio donde se guardará el archivo shapefile.
    - crs: Sistema de referencia de coordenadas (por defecto es EPSG:4326).
    """
    create_directory(directory)
    df['geometry'] = df['geom'].apply(lambda x: wkt.loads(x))
    gdf = gpd.GeoDataFrame(df, geometry='geometry')
    gdf.set_crs(crs, inplace=True)
    if 'geom' in gdf.columns:
        gdf = gdf.drop(columns=['geom'])
    shapefile_path = os.path.join(directory, f'{db_name}.shp')
    gdf.to_file(shapefile_path, driver='ESRI Shapefile')
    print(f'Shapefile guardado en {shapefile_path}')


def connection(db_parameters):
    try:
        connection = psycopg2.connect(**db_parameters)
        connection.set_session(readonly=True)
        print("Connection to PostgreSQL database successful!")

    except psycopg2.Error as e:
        print("Error: Could not connect to the PostgreSQL database.")
        print(e)
    
    return connection.cursor()


db_params = {
    "dbname": "metro_cdmx",
    "user": "admin",
    "password": "password",
    "host": "postgis",
    "port": "5432",
}


# Connect to the database
cur = connection(db_params)

# Databases to query
databases = {
    # name of the database: path to the query file
    'train_incubation': 'connection/db_queries/get_presence_train_incubation_data.sql',
    'train_brooding': 'connection/db_queries/get_presence_train_brooding_data.sql',
    'train_chicken_rearing': 'connection/db_queries/get_presence_train_chicken_rearing_data.sql',
    'test_incubation': 'connection/db_queries/get_presence_test_incubation_data.sql',
    'test_brooding': 'connection/db_queries/get_presence_test_brooding_data.sql',
    'test_chicken_rearing': 'connection/db_queries/get_presence_test_chicken_rearing_data.sql',
    'count_data': 'connection/db_queries/count_data.sql',
    'background_points': 'connection/db_queries/background_points.sql',
    'americas_shapefile': 'connection/db_queries/americas_shapefile.sql',
    'convex_hull': 'connection/db_queries/convex_hull.sql',
    #'presence_biomod': 'connection/db_queries/presence_dataset_biomod.sql',
    #'presence_filtered_biomod': 'connection/db_queries/presence_filtered_biomod.sql',
}


# Execute the queries and save the results to CSV
for db_name, db_file in databases.items():
    query = read_query_from_file(db_file)
    results, column_names = execute_query(cur, query)
    df = pd.DataFrame(results, columns=column_names)
    if db_name == 'convex_hull':
        save_results_to_shapefile(df, db_name, directory='data/binary')
    elif db_name == 'train_incubation' or db_name == 'train_brooding' or db_name == 'train_chicken_rearing':
        save_results_to_csv(df, db_name, directory='data/train')
    elif db_name == 'test_incubation' or db_name == 'test_brooding' or db_name == 'test_chicken_rearing':
        save_results_to_csv(df, db_name, directory='data/test')
    else:
        save_results_to_csv(df, db_name, directory='data/others')
