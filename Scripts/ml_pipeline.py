import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, classification_report
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier

# =========================
# LOAD DATA
# =========================
patients = pd.read_csv("Raw_Data/Patients.csv")
visits = pd.read_csv("Raw_Data/Visits.csv")
billing = pd.read_csv("Raw_Data/Billing.csv")
claims = pd.read_csv("Raw_Data/Claims.csv")
outcomes = pd.read_csv("Raw_Data/Outcomes.csv")

# =========================
# MERGE DATASET
# =========================
df = visits.merge(patients, on="patient_id") \
           .merge(billing, on="visit_id") \
           .merge(claims, on="visit_id") \
           .merge(outcomes, on="visit_id")

# =========================
# CLEANING
# =========================
df = df.dropna()

le = LabelEncoder()

df["gender"] = le.fit_transform(df["gender"])
df["department"] = le.fit_transform(df["department"])
df["claim_status"] = le.fit_transform(df["claim_status"])

# =========================
# FEATURE ENGINEERING
# =========================
df["length_of_stay"] = (
    pd.to_datetime(df["discharge_date"]) -
    pd.to_datetime(df["admission_date"])
).dt.days

df["age_group"] = pd.cut(df["age"], [0,30,60,100], labels=["young","adult","old"])
df["age_group"] = le.fit_transform(df["age_group"])

# Risk category
df["risk"] = (df["age"] > 60).astype(int) + (df["length_of_stay"] > 5).astype(int)
df["risk"] = df["risk"].map({0:"Low",1:"Medium",2:"High"})
df["risk"] = le.fit_transform(df["risk"])

# =========================
# FEATURES
# =========================
features = ["age","gender","department","total_bill","length_of_stay"]
X = df[features]

# =========================================================
# MODEL 1: READMISSION PREDICTION
# =========================================================
y1 = df["readmission_flag"]

X_train, X_test, y_train, y_test = train_test_split(X, y1, test_size=0.2, random_state=42)

model1 = LogisticRegression(max_iter=1000)
model1.fit(X_train, y_train)

df["readmission_pred"] = model1.predict(X)

print("Readmission Accuracy:", accuracy_score(y_test, model1.predict(X_test)))

# =========================================================
# MODEL 2: CLAIM PREDICTION
# =========================================================
y2 = df["claim_status"]

X_train, X_test, y_train, y_test = train_test_split(X, y2, test_size=0.2, random_state=42)

model2 = RandomForestClassifier(n_estimators=100, random_state=42)
model2.fit(X_train, y_train)

df["claim_pred"] = model2.predict(X)

print("Claim Accuracy:", accuracy_score(y_test, model2.predict(X_test)))

# =========================================================
# MODEL 3: RISK PREDICTION
# =========================================================
y3 = df["risk"]

X_train, X_test, y_train, y_test = train_test_split(X, y3, test_size=0.2, random_state=42)

model3 = RandomForestClassifier(n_estimators=100, random_state=42)
model3.fit(X_train, y_train)

df["risk_pred"] = model3.predict(X)

print("Risk Accuracy:", accuracy_score(y_test, model3.predict(X_test)))

# =========================
# FINAL EXPORT FOR POWER BI
# =========================
df.to_csv("final_healthcare_ml_output.csv", index=False)

print("FINAL CSV GENERATED SUCCESSFULLY")