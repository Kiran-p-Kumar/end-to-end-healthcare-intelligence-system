DROP DATABASE IF EXISTS healthcare;
CREATE DATABASE healthcare;
USE healthcare;

-- table creation--
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS Visits;

CREATE TABLE Visits (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    admission_date DATE,
    discharge_date DATE,
    department VARCHAR (50)
);

ALTER TABLE Visits
ADD CONSTRAINT fk_patient
FOREIGN KEY (patient_id)
REFERENCES Patients(patient_id);

DROP TABLE IF EXISTS Diagnoses;

CREATE TABLE Diagnoses (
    visit_id INT,
    diagnosis_code VARCHAR(10),
    diagnosis_name VARCHAR(100)
);

DROP TABLE IF EXISTS Procedures;

CREATE TABLE Procedures (
    visit_id INT,
    procedure_name VARCHAR(100),
    procedure_cost INT
);

DROP TABLE IF EXISTS Medications;

CREATE TABLE Medications (
    visit_id INT,
    medication_name VARCHAR(100),
    dosage VARCHAR(50)
);

DROP TABLE IF EXISTS Billing;

CREATE TABLE Billing (
    visit_id INT,
    total_bill INT,
    payment_status VARCHAR(20)
);

DROP TABLE IF EXISTS Claims;

CREATE TABLE Claims (
    visit_id INT,
    claim_amount INT,
    claim_status VARCHAR(20)
);

DROP TABLE IF EXISTS Outcomes;

CREATE TABLE Outcomes (
    visit_id INT,
    outcome VARCHAR(50),
    readmission_flag INT
);

DROP TABLE IF EXISTS Hospital_Resources;

CREATE TABLE Hospital_Resources (
    department VARCHAR(50),
    total_beds INT,
    occupied_beds INT
);
-- Sanity Check --
SELECT COUNT(*) FROM patients;
SELECT COUNT(*) FROM visits;
SELECT COUNT(*) FROM diagnoses;
SELECT COUNT(*) FROM billing;
SELECT COUNT(*) FROM claims;
SELECT COUNT(*) FROM outcomes;
-- Patient Visit Details --

SELECT 
p.patient_id,
p.gender,
p.age,
v.visit_id,
v.department,
v.admission_date,
v.discharge_date
FROM Patients p
JOIN Visits v
ON p.patient_id = v.patient_id;

-- Total Registered Patients --

SELECT COUNT(*) AS total_patients 
FROM Patients;

-- department Load (Patient Load for Department)--

SELECT department, 
COUNT(*) AS total_visits 
FROM Visits
GROUP BY department
ORDER BY total_visits DESC;

-- Avg lenghth of  Stay --

SELECT 
AVG(DATEDIFF(discharge_date, admission_date)) AS Avg_Stay_days
FROM Visits;

-- Revenue by Department -- 

SELECT 
v.department,
SUM(b.total_bill) AS Total_Revenue
FROM Visits v 
JOIN Billing b ON 
v. visit_id = b.visit_id 
GROUP BY department
ORDER BY Total_Revenue DESC;

-- Claim Approval Rate (Inusurance Approval Rate) -- 
SELECT 
SUM(CASE WHEN claim_status = "Approved" THEN 1 ELSE 0 END) / COUNT(*) AS Approval_Rate FROM Claims;

-- Patient Readmission Rate -- 
SELECT 
SUM(readmission_flag)* 1.0 / COUNT(*) AS Readmission_Rate FROM Outcomes;

-- Diagnosis Analysis (Health Issues)

SELECT 
diagnosis_name,
COUNT(*) AS total_cases
FROM Diagnoses
GROUP BY diagnosis_name
ORDER BY total_cases DESC;

-- patient cost overview (Complete Cost per patient) -- 

SELECT 
p.patient_id,
v.visit_id,
b.total_bill,
c.claim_amount
FROM Patients p 
JOIN Visits v on p.patient_id = v.patient_id 
JOIN Billing b on v.visit_id = b.visit_id
JOIN claims c on v.visit_id = c.visit_id;








   

               
