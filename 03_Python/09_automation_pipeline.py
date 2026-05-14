import pandas as pd
import numpy as np

from datetime import datetime
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import (LabelEncoder,StandardScaler)
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from imblearn.over_sampling import SMOTE
from db_connection import create_connection


# =====================================================
# PIPELINE START
# =====================================================

print("\n==============================")
print("KKBOX CHURN PIPELINE STARTED")
print("==============================")

start_time = datetime.now()

print(f"\nSTART TIME: {start_time}")




# =====================================================
# LOAD DATA
# =====================================================

print("\nLOADING DATA...")

connection = create_connection()

query = """SELECT * FROM churn_base"""

df = pd.read_sql(query, connection)

connection.close()

print("\nDATA LOADED SUCCESSFULLY")
print(df.columns.tolist())



# =====================================================
# FEATURE SELECTION
# =====================================================

selected_features = [
    "city",
    "age",
    "gender",
    "registration_via",

    "avg_total_secs",
    "total_listening_secs",
    "avg_num_unq",
    "active_days",
    "avg_completion_ratio",
    "total_plays",

    "total_transactions",
    "total_revenue",
    "avg_payment_revenue",

    "cancellation_rate",
    "auto_renew_rate",

    "membership_tenure_days",
    "expiry_recency_days",

    "suspicious_payment_rate"
]

target = "is_churn"

X = df[selected_features].copy()
y = df[target]

# STORE CUSTOMER IDS

# STORE CUSTOMER IDS

customer_ids = df["msno"]


# =====================================================
# ENCODE CATEGORICAL VARIABLES
# =====================================================

print("\nENCODING CATEGORICAL FEATURES...")

encoder = LabelEncoder()

X["gender"] = encoder.fit_transform(X["gender"].astype(str))



# =====================================================
# HANDLE MISSING VALUES
# =====================================================

print("\nHANDLING MISSING VALUES...")

imputer = SimpleImputer(strategy="median")
X = pd.DataFrame(imputer.fit_transform(X),columns=X.columns)



# =====================================================
# FEATURE SCALING
# =====================================================

print("\nSCALING FEATURES...")

scaler = StandardScaler()

X = pd.DataFrame(scaler.fit_transform(X),columns=X.columns)



# =====================================================
# TRAIN TEST SPLIT
# =====================================================

print("\nCREATING TRAIN TEST SPLIT...")

X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.2,random_state=42,stratify=y)



# =====================================================
# HANDLE CLASS IMBALANCE
# =====================================================

print("\nAPPLYING SMOTE...")
smote = SMOTE(random_state=42)

X_train_resampled, y_train_resampled = smote.fit_resample(X_train,y_train)

print("\nSMOTE COMPLETE")



# =====================================================
# TRAIN MODEL
# =====================================================

print("\nTRAINING MODEL...")

model = LogisticRegression(max_iter=2000)
model.fit(X_train_resampled,y_train_resampled)

print("\nMODEL TRAINED SUCCESSFULLY")



# =====================================================
# GENERATE CHURN PROBABILITIES
# =====================================================

print("\nGENERATING CHURN PROBABILITIES...")

y_prob = model.predict_proba(X_test)[:, 1]

y_pred = model.predict(X_test)



# =====================================================
# BUILD RISK DATAFRAME
# =====================================================

print("\nBUILDING RISK DATAFRAME...")

risk_df = pd.DataFrame({

    "msno": customer_ids.loc[X_test.index].values,

    "actual_churn": y_test.values,

    "predicted_churn": y_pred,

    "churn_probability": y_prob
})



# =====================================================
# ADD REVENUE INFORMATION
# =====================================================

risk_df["total_revenue"] = (
    df.loc[X_test.index,"total_revenue"].values)



# =====================================================
# CALCULATE REVENUE AT RISK
# =====================================================

risk_df["revenue_at_risk"] = (
    risk_df["churn_probability"]*risk_df["total_revenue"])



# =====================================================
# ASSIGN RISK TIERS
# =====================================================

def assign_risk_tier(probability):

    if probability >= 0.80:
        return "Critical Risk"
    elif probability >= 0.60:
        return "High Risk"
    elif probability >= 0.30:
        return "Medium Risk"
    else:
        return "Low Risk"


risk_df["risk_tier"] = risk_df["churn_probability"].apply(assign_risk_tier)



# =====================================================
# RISK SUMMARY
# =====================================================

print("\nGENERATING RISK SUMMARY...")

risk_summary = risk_df.groupby("risk_tier").agg(
    customers=(
        "msno",
        "count"),
    avg_churn_probability=(
        "churn_probability",
        "mean"),
    total_revenue_at_risk=(
        "revenue_at_risk",
        "sum"),
    avg_customer_revenue=(
        "total_revenue",
        "mean")

).reset_index()


# =====================================================
# EXPORT OUTPUT FILES
# =====================================================

print("\nEXPORTING OUTPUT FILES...")

risk_df.to_csv("output/customer_risk_predictions.csv",index=False)

risk_summary.to_csv("output/risk_tier_summary.csv",index=False)


# =====================================================
# PIPELINE METRICS
# =====================================================

total_revenue_risk = risk_df["revenue_at_risk"].sum()

critical_customers = (risk_df["risk_tier"] == "Critical Risk").sum()

print("\n==============================")
print("PIPELINE RESULTS")
print("==============================")

print(f"\nTOTAL REVENUE AT RISK: "f"{total_revenue_risk:,.2f}")

print(f"\nCRITICAL RISK CUSTOMERS: "f"{critical_customers:,}")

print(f"\nOUTPUT FILES GENERATED:")

print("- customer_risk_predictions.csv")

print("- risk_tier_summary.csv")


# =====================================================
# PIPELINE END
# =====================================================

end_time = datetime.now()

execution_time = end_time - start_time

print("\n==============================")
print("PIPELINE COMPLETED")
print("==============================")

print(f"\nEND TIME: {end_time}")

print(f"\nTOTAL EXECUTION TIME: "f"{execution_time}")