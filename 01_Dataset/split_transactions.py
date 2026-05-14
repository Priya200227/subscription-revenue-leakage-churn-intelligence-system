import pandas as pd
import os

# INPUT FILE
input_file = r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\transactions.csv"

# OUTPUT FOLDER
output_folder = r"C:\kkbox_data\transactions_chunks"

os.makedirs(output_folder, exist_ok=True)

# CHUNK SIZE
chunk_size = 500000

# READ + SPLIT
chunk_number = 1

for chunk in pd.read_csv(input_file, chunksize=chunk_size):
    
    output_file = os.path.join(
        output_folder,
        f"transactions_part{chunk_number}.csv"
    )
    
    chunk.to_csv(output_file, index=False)
    
    print(f"Saved: {output_file}")
    
    chunk_number += 1

print("Splitting completed.")