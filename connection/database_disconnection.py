import psycopg2, psycopg2.extras

# Close the connection when you're done working with the database
db_params = {
    "dbname": "metro_cdmx",
    "user": "admin",
    "password": "password",
    "host": "postgis",
    "port": "5432",
}

connection = psycopg2.connect(**db_params)
cur = connection.cursor()
cur.close
connection.close()
print("Connection closed successfully.")
