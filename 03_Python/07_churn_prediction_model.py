import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split

from sklearn.preprocessing import LabelEncoder,StandardScaler

from sklearn.impute import SimpleImputer

from sklearn.linear_model import LogisticRegression

from sklearn.metrics import (classification_report, 
                             confusion_matrix, 
                             roc_auc_score)

from imblearn.over_sampling import SMOTE

from db_connection import create_connection


# ==========================================
# LOAD DATA
# ==========================================
connection = create_connection()
query = """SELECT * FROM churn_base""" 

df = pd.read_sql(query, connection)

connection.close()

print("\nDATA LOADED")
print(df.shape)


# ==========================================
# FEATURE SELECTION
# ==========================================
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

X = df[selected_features]
y = df[target]



# ==========================================
# ENCODE CATEGORICAL VARIABLES
# ==========================================
categorical_columns = ["gender"]
encoder = LabelEncoder()

for col in categorical_columns:
    X[col] = encoder.fit_transform(X[col].astype(str))



# ==========================================
# HANDLE MISSING VALUES
# ==========================================
imputer = SimpleImputer(strategy="median")
X = pd.DataFrame(imputer.fit_transform(X), columns=X.columns)



# =====================================================
# FEATURE SCALING
# =====================================================

scaler = StandardScaler()

X = pd.DataFrame(
    scaler.fit_transform(X),
    columns=X.columns
)



# ==========================================
# TRAIN TEST SPLIT
# ==========================================
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y)

print("\nTRAIN TEST SPLIT COMPLETE")



# ==========================================
# HANDLE CLASS IMBALANCE
# ==========================================
smote = SMOTE(random_state=42)
X_train_resampled, y_train_resampled = smote.fit_resample(X_train, y_train)

print("\nSMOT AAPPLIED")

print(y_train_resampled.value_counts()) 



# ==========================================
# TRAIN MODEL
# ==========================================
model = LogisticRegression(max_iter=1000)

model.fit(X_train_resampled, y_train_resampled)

print("\nMODEL TRAINED")



# ==========================================
# PREDICTIONS
# ==========================================

y_pred = model.predict(X_test)

y_prob = model.predict_proba(X_test)[:, 1]



# ==========================================
# MODEL EVALUATION
# ==========================================
print("\nCLASSIFICATION REPORT")
print(classification_report(y_test, y_pred))

print("\nCONFUSION MATRIX")
print(confusion_matrix(y_test, y_pred))

roc_auc = roc_auc_score(y_test, y_prob)
print(f"\nROC AUC SCORE: {roc_auc:.4f}")
      
      
      
# =====================================================
# FEATURE IMPORTANCE
# =====================================================

feature_importance = pd.DataFrame({

    "Feature": X.columns,

    "Coefficient": model.coef_[0]

})

feature_importance["Absolute_Coefficient"] = (
    feature_importance["Coefficient"]
    .abs()
)

feature_importance = feature_importance.sort_values(

    by="Absolute_Coefficient",

    ascending=False
)

print("\nTOP FEATURE IMPORTANCE")

print(
    feature_importance[
        ["Feature", "Coefficient"]
    ].head(10)
)


# =====================================================
# CHURN PROBABILITY OUTPUT
# =====================================================

prediction_output = X_test.copy()

prediction_output["actual_churn"] = y_test.values

prediction_output["predicted_churn"] = y_pred

prediction_output["churn_probability"] = y_prob

print("\nPREDICTION SAMPLE")

print(
    prediction_output[
        [
            "actual_churn",
            "predicted_churn",
            "churn_probability"
        ]
    ].head(10)
)