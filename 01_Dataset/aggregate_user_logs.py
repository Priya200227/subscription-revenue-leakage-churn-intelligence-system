import pandas as pd
import numpy as np

# INPUT FILE
file_path = r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\user_logs.csv"

# OUTPUT FILE
output_path = r"C:\kkbox_data\user_behavior_features.csv"

# CHUNK SIZE
chunk_size = 500000

# STORE CHUNK RESULTS
aggregated_chunks = []

print("Processing started...")

for chunk in pd.read_csv(file_path, chunksize=chunk_size):

    # -----------------------------
    # FORCE NUMERIC TYPES
    # -----------------------------

    numeric_cols = [
        "num_25",
        "num_50",
        "num_75",
        "num_985",
        "num_100",
        "num_unq",
        "total_secs"
    ]

    for col in numeric_cols:
        chunk[col] = pd.to_numeric(
            chunk[col],
            errors="coerce"
        )

    # -----------------------------
    # REMOVE INVALID VALUES
    # -----------------------------

    # Negative listening time impossible
    chunk = chunk[
        chunk["total_secs"] >= 0
    ]

    # Remove absurd listening durations
    chunk = chunk[
        chunk["total_secs"] <= 100000
    ]

    # Remove invalid play counts
    chunk = chunk[
        chunk["num_unq"] >= 0
    ]

    # -----------------------------
    # FILL NULLS
    # -----------------------------

    chunk[numeric_cols] = chunk[numeric_cols].fillna(0)

    # -----------------------------
    # SAFE COMPLETION RATIO
    # -----------------------------

    total_activity = (
        chunk["num_25"] +
        chunk["num_50"] +
        chunk["num_75"] +
        chunk["num_985"] +
        chunk["num_100"]
    )

    chunk["completion_ratio"] = np.where(
        total_activity > 0,
        chunk["num_100"] / total_activity,
        0
    )

    # -----------------------------
    # USER-LEVEL AGGREGATION
    # -----------------------------

    agg = chunk.groupby("msno").agg(

        avg_total_secs=(
            "total_secs",
            "mean"
        ),

        total_listening_secs=(
            "total_secs",
            "sum"
        ),

        avg_num_unq=(
            "num_unq",
            "mean"
        ),

        active_days=(
            "date",
            "nunique"
        ),

        avg_completion_ratio=(
            "completion_ratio",
            "mean"
        ),

        total_plays=(
            "num_100",
            "sum"
        )

    ).reset_index()

    aggregated_chunks.append(agg)

    print("Chunk processed.")

# ==========================================
# COMBINE ALL CHUNKS
# ==========================================

final_df = pd.concat(
    aggregated_chunks,
    ignore_index=True
)

# ==========================================
# FINAL USER AGGREGATION
# ==========================================

final_df = final_df.groupby("msno").agg(

    avg_total_secs=(
        "avg_total_secs",
        "mean"
    ),

    total_listening_secs=(
        "total_listening_secs",
        "sum"
    ),

    avg_num_unq=(
        "avg_num_unq",
        "mean"
    ),

    active_days=(
        "active_days",
        "sum"
    ),

    avg_completion_ratio=(
        "avg_completion_ratio",
        "mean"
    ),

    total_plays=(
        "total_plays",
        "sum"
    )

).reset_index()

# ==========================================
# FINAL ROUNDING
# ==========================================

final_df["avg_total_secs"] = final_df["avg_total_secs"].round(2)

final_df["total_listening_secs"] = final_df["total_listening_secs"].round(2)

final_df["avg_num_unq"] = final_df["avg_num_unq"].round(2)

final_df["avg_completion_ratio"] = final_df[
    "avg_completion_ratio"
].round(4)

# ==========================================
# SAVE OUTPUT
# ==========================================

final_df.to_csv(output_path, index=False)

print("\nFeature engineering completed.")
print(f"Saved to: {output_path}")