import mysql.connector


def create_connection():

    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Priya@200227",
        database="kkbox"
    )

    return connection