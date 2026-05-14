import os
import mysql.connector

# MYSQL CONNECTION
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Priya@200227",
    database="kkbox",
    allow_local_infile=True
)

cursor = conn.cursor()

# FOLDER PATH
folder_path = r"C:\kkbox_data\transactions_chunks"

# GET FILES
files = sorted([
    f for f in os.listdir(folder_path)
    if f.endswith(".csv")
])

print(f"Found {len(files)} files.")

# LOOP THROUGH FILES
for file in files:

    file_path = os.path.join(folder_path, file)

    # Convert backslashes to forward slashes
    mysql_path = file_path.replace("\\", "/")

    print(f"\nUploading: {file}")

    query = f"""
    LOAD DATA LOCAL INFILE '{mysql_path}'
    INTO TABLE raw_transactions
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\\n'
    IGNORE 1 ROWS;
    """

    try:
        cursor.execute(query)
        conn.commit()

        print(f"Successfully uploaded: {file}")

    except Exception as e:
        print(f"Failed: {file}")
        print(e)

# CLOSE CONNECTION
cursor.close()
conn.close()

print("\nAll uploads completed.")