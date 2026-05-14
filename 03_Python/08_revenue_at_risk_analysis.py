import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder,StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from imblearn.over_sampling import SMOTE
from db_connection import create_connection

# ==========================================
# LOAD DATA
# ==========================================

connection = create_connection()
query = """SELECT * FROM churn_base"""

df = pd.read_sql(query,connection)

connection.close()

print("\nDATA LOADED")
print(df.shape)



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



# =====================================================
# ENCODE CATEGORICAL VARIABLES
# =====================================================
encoder = LabelEncoder()

X["gender"] = encoder.fit_transform(
    X["gender"]).astype(str)



# =====================================================
# HANDLE MISSING VALUES
# =====================================================

imputer = SimpleImputer(strategy="median")
X = pd.DataFrame(imputer.fit_transform(X), columns=X.columns)



# =====================================================
# FEATURE SCALING
# =====================================================

scaler = StandardScaler()
X = pd.DataFrame(scaler.fit_transform(X),columns=X.columns)



# =====================================================
# TRAIN TEST SPLIT
# =====================================================

X_train, X_test, y_train, y_test = train_test_split(
    X,y,test_size=0.2,random_state=42,stratify=y)



# =====================================================
# HANDLE CLASS IMBALANCE
# =====================================================

smote = SMOTE(random_state=42)

X_train_resampled, y_train_resampled = smote.fit_resample(
    X_train,y_train)


# =====================================================
# TRAIN MODEL
# =====================================================

model = LogisticRegression(max_iter=2000)

model.fit(X_train_resampled,y_train_resampled)

print("\nMODEL TRAINED")



# =====================================================
# CHURN PROBABILITIES
# =====================================================

y_prob = model.predict_proba(X_test)[:, 1]



# =====================================================
# CREATE RISK ANALYSIS DATAFRAME
# =====================================================

risk_df = pd.DataFrame (
    {"msno": df.loc[X_test.index, "msno"].values,
     "actual_churn": y_test.values,
      "churn_probability": y_prob}
)



# =====================================================
# ADD REVENUE DATA
# =====================================================

risk_df["total_revenue"] = (df.loc[X_test.index,"total_revenue"]
                            .values)



# =====================================================
# ESTIMATE REVENUE AT RISK
# =====================================================

risk_df["revenue_at_risk"] = risk_df["churn_probability"] * risk_df["total_revenue"]



# =====================================================
# CREATE RISK TIERS
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
risk_df["risk_tier"] = risk_df[
    "churn_probability"].apply(assign_risk_tier)



# =====================================================
# RISK TIER SUMMARY
# =====================================================
risk_summary = risk_df.groupby("risk_tier").agg(
    customers = ("msno","count"),
    avg_churn_probability = ("churn_probability","mean"),
    total_revenue_at_risk = ("revenue_at_risk","sum"),
    avg_revenue_at_risk = ("revenue_at_risk","mean")
).reset_index()

print("\nRISK TIER SUMMARY")
print(risk_summary)



# =====================================================
# TOTAL REVENUE EXPOSURE
# =====================================================

total_risk = risk_df["revenue_at_risk"].sum()

print(f"\nTOTAL ESTIMATED REVENUE AT RISK: "f"{total_risk:,.2f}")



# =====================================================
# TOP HIGH-RISK CUSTOMERS
# =====================================================

top_risk_customers = risk_df.sort_values(
    by="revenue_at_risk",ascending=False).head(20)


print("\nTOP HIGH-RISK CUSTOMERS")
print(top_risk_customers)


# =====================================================
# RISK TIER DISTRIBUTION
# =====================================================

tier_distribution = risk_df["risk_tier"].value_counts()

print("\nRISK TIER DISTRIBUTION")
print(tier_distribution)


# =====================================================
# EXPORT RESULTS
# =====================================================

risk_df.to_csv("output/customer_risk_predictions.csv",index=False)

risk_summary.to_csv("output/risk_tier_summary.csv",index=False)

print("\nFILES EXPORTED SUCCESSFULLY")