import pandas as pd
import numpy as np

from scipy.stats import skew
from scipy.stats import mannwhitneyu
from scipy.stats import chi2_contingency

import matplotlib.pyplot as plt

from execute_sql import execute_sql_file


# ==========================================
# LOAD MASTER DATASET
# ==========================================

churn_base_query = """SELECT * FROM churn_base"""

from db_connection import create_connection

connection = create_connection()

churn_base_df = pd.read_sql(churn_base_query, connection)

connection.close()

print("\nCHURN BASE LOADED")
print(churn_base_df.shape) 


# ==========================================
# DISTRIBUTION ANALYSIS
# ==========================================

distribution_columns = ["total_revenue", 
                        "membership_tenure_days",
                        "avg_total_secs",
                        "active_days"]

print("\nDISTRIBUTION ANALYSIS")

for col in distribution_columns:
    mean_val = churn_base_df[col].mean()
    median_val = churn_base_df[col].median()
    skewness_val = skew(churn_base_df[col].dropna())

    print(f"\nCOLUMN: {col}")
    print(f"MEAN: {mean_val}")
    print(f"MEDIAN: {median_val}")
    print(f"SKEWNESS: {skewness_val}")


# ==========================================
# OUTLIER ANALYSIS
# ==========================================
print("\nOUTLIER ANALYSIS")

for col in distribution_columns:
    q1 = churn_base_df[col].quantile(0.25)
    q3 = churn_base_df[col].quantile(0.75)
    iqr = q3 - q1
    upper_bound = q3 + 1.5 * iqr

    outliers_count = (churn_base_df[col] > upper_bound).sum()

    print(f"\nCOLUMN: {col}")

    print(f"OUTLIERS COUNT: {outliers_count}")


# ==========================================
# PROBABILITY ANALYSIS
# ==========================================

print("\nPROBABILITY ANALYSIS")

# P(churn | low_auto_renew)

low_auto_renew = churn_base_df[churn_base_df["auto_renew_rate"] < 0.4]

prob_churn_low_renew = (low_auto_renew["is_churn"].mean())

print(f"\nP(churn | low_auto_renew): {prob_churn_low_renew:.4f}")

# P(churn | low_activity)

low_activity = churn_base_df[churn_base_df["active_days"] < 30]

prob_churn_low_activity = (low_activity["is_churn"].mean())

print(f"\nP(churn | low_activity): {prob_churn_low_activity:.4f}")


# ==========================================
# HYPOTHESIS TESTING
# ==========================================

print("\nHYPOTHESIS TESTING")

# Compare tenure distributions

churned = churn_base_df[
    churn_base_df["is_churn"] == 1]["membership_tenure_days"].dropna()

not_churned = churn_base_df[
    churn_base_df["is_churn"] == 0]["membership_tenure_days"].dropna() 

stat, p_value = mannwhitneyu(churned, not_churned)

print(f"\nMANN-WHITNEY U TEST")
print(f"STATISTIC: {stat}")
print(f"P-VALUE: {p_value}")


# ==========================================
# CHI-SQUARE TEST
# ==========================================
contingency_table = pd.crosstab(
    churn_base_df["is_churn"],
    churn_base_df["gender"]
)

chi2, p, dof, expected = chi2_contingency(
    contingency_table
)

print("\nCHI-SQUARE TEST")

print(f"Chi2 Statistic: {chi2}")

print(f"P-Value: {p}")