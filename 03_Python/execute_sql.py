import pandas as pd

from db_connection import create_connection


def execute_sql_file(file_path):

    # READ SQL FILE
    with open(file_path, "r") as file:
        sql_query = file.read()

    # CREATE DB CONNECTION
    connection = create_connection()

    # EXECUTE QUERY
    df = pd.read_sql(sql_query, connection)

    # CLOSE CONNECTION
    connection.close()

    return df


from execute_sql import execute_sql_file

# ==========================================
# LOAD CHURN RATE ANALYSIS
# ==========================================

churn_df = execute_sql_file("C:\\Users\\priya\\OneDrive\\Desktop\\DataAnalytics2026\\02_Subscription_Revenue_Leakage_&_Retention_Intelligence\\02_SQL\\analysis_queries\\churn_rate.sql")

print("\nCHURN RATE ANALYSIS")
print(churn_df)


# ==========================================
# LOAD AUTO RENEW ANALYSIS
# ==========================================
renew_df = execute_sql_file("C:\\Users\\priya\\OneDrive\\Desktop\\DataAnalytics2026\\02_Subscription_Revenue_Leakage_&_Retention_Intelligence\\02_SQL\\analysis_queries\\auto_renew_analysis.sql")

print("\nAUTO RENEW ANALYSIS")
print(renew_df)


# ==========================================
# LOAD TENURE ANALYSIS
# ==========================================

tenure_df = execute_sql_file("C:\\Users\\priya\\OneDrive\\Desktop\\DataAnalytics2026\\02_Subscription_Revenue_Leakage_&_Retention_Intelligence\\02_SQL\\analysis_queries\\tenure_analysis.sql")

print("\nTENURE ANALYSIS")
print(tenure_df)


# ==========================================
# LOAD REVENUE ANALYSIS
# ==========================================

revenue_df = execute_sql_file("C:\\Users\\priya\\OneDrive\\Desktop\\DataAnalytics2026\\02_Subscription_Revenue_Leakage_&_Retention_Intelligence\\02_SQL\\analysis_queries\\revenue_analysis.sql")

print("\nREVENUE ANALYSIS")
print(revenue_df)