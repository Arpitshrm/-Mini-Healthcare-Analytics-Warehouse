-- patient_id,first_name,last_name,gender,birth_date,smoker_flag,bmi
-- 1,Arjun,Patel,Male,1985-06-15,false,27.5
-- 2,Sara,Lee,Female,1992-03-20,false,22.1
-- 3,Michael,Brown,Male,1978-11-02,true,30.2
-- 4,Emily,Johnson,Female,1969-09-10,true,32.8
-- 5,Aisha,Khan,Female,2000-01-25,false,24.0


-- clinician_id,first_name,last_name,specialty,active_flag
-- 1,Richard,Nguyen,Internal Medicine,true
-- 2,Laura,Smith,Cardiology,true
-- 3,Ahmed,Hassan,Endocrinology,true
-- 4,Julia,Wong,Emergency Medicine,true


-- medication_id,medication_name,atc_code
-- 1,Metformin,A10BA02
-- 2,Lisinopril,C09AA03
-- 3,Atorvastatin,C10AA05
-- 4,Insulin glargine,A10AE04


-- lab_test_id,test_code,test_name,unit,normal_min,normal_max
-- 1,HBA1C,Hemoglobin A1c,%,4.0,6.0
-- 2,LDL,LDL Cholesterol,mg/dL,0,130
-- 3,SBP,Systolic Blood Pressure,mmHg,90,140
-- 4,DBP,Diastolic Blood Pressure,mmHg,60,90


-- data/load_data.sql
SET search_path TO health;

-- Load dimension/reference data (patients, clinicians, medications, lab_tests)
-- Adjust paths as needed when running locally.

TRUNCATE TABLE lab_results, vital_signs, billing_claims,
    medication_orders, diagnoses, encounters,
    lab_tests, medications, clinicians, patients RESTART IDENTITY CASCADE;

-- Use COPY for bulk load (run from psql at repo root)
COPY patients (patient_id, first_name, last_name, gender, birth_date, smoker_flag, bmi)
FROM 'C:/Arpit''s File/SQL/Health care project/patients.csv'
DELIMITER ',' CSV HEADER;


COPY clinicians (clinician_id,first_name,last_name,specialty,active_flag)
FROM 'C:/Arpit''s File/SQL/Health care project/clinicians.csv'
DELIMITER ',' CSV HEADER;

COPY medications (medication_id,medication_name,atc_code)
FROM 'C:/Arpit''s File/SQL/Health care project/medications.csv'
DELIMITER ',' CSV HEADER;

COPY lab_tests (lab_test_id,test_code,test_name,unit,normal_min,normal_max)
FROM 'C:/Arpit''s File/SQL/Health care project/lab_tests.csv'
DELIMITER ',' CSV HEADER;


-- Insert encounters (simple synthetic data)
INSERT INTO encounters (patient_id, clinician_id, encounter_type_code, start_time, end_time, discharge_disposition)
VALUES
(1, 1, 'OP', '2024-01-10 09:00+00', '2024-01-10 10:00+00', 'Home'),
(1, 2, 'ER', '2024-02-05 18:00+00', '2024-02-05 22:00+00', 'Home'),
(1, 1, 'OP', '2024-03-01 09:00+00', '2024-03-01 09:45+00', 'Home'),
(2, 1, 'OP', '2024-01-15 11:00+00', '2024-01-15 11:30+00', 'Home'),
(3, 2, 'IP', '2024-01-20 08:00+00', '2024-01-22 10:00+00', 'Rehab'),
(3, 4, 'ER', '2024-02-15 20:00+00', '2024-02-16 02:00+00', 'Home'),
(4, 2, 'OP', '2024-02-01 10:00+00', '2024-02-01 10:30+00', 'Home'),
(5, 3, 'OP', '2024-03-05 14:00+00', '2024-03-05 14:40+00', 'Home');

-- Primary and secondary diagnoses
INSERT INTO diagnoses (encounter_id, diagnosis_code, diagnosis_name, diagnosis_type)
VALUES
(1, 'E11', 'Type 2 diabetes mellitus', 'Primary'),
(1, 'I10', 'Essential (primary) hypertension', 'Secondary'),
(2, 'I10', 'Essential (primary) hypertension', 'Primary'),
(3, 'E11', 'Type 2 diabetes mellitus', 'Primary'),
(4, 'E66', 'Obesity', 'Primary'),
(5, 'I21', 'Acute myocardial infarction', 'Primary'),
(6, 'I10', 'Essential (primary) hypertension', 'Primary'),
(7, 'E11', 'Type 2 diabetes mellitus', 'Primary'),
(8, 'E11', 'Type 2 diabetes mellitus', 'Primary');

-- Medication orders
INSERT INTO medication_orders (encounter_id, medication_id, dose_mg, frequency_per_day, start_date, end_date)
VALUES
(1, 1, 500, 2, '2024-01-10', '2024-04-10'),
(1, 2, 10, 1, '2024-01-10', NULL),
(2, 2, 20, 1, '2024-02-05', NULL),
(3, 1, 1000, 2, '2024-03-01', NULL),
(5, 2, 20, 1, '2024-01-20', NULL),
(5, 3, 40, 1, '2024-01-20', NULL),
(7, 1, 500, 2, '2024-02-01', NULL),
(8, 4, 10, 1, '2024-03-05', NULL);

-- Lab results (HbA1c trend, LDL, BP)
INSERT INTO lab_results (encounter_id, lab_test_id, result_value, result_time, abnormal_flag)
VALUES
(1, 1, 8.2, '2024-01-10 09:30+00', true),
(3, 1, 7.4, '2024-03-01 09:15+00', true),
(7, 1, 6.8, '2024-02-01 10:10+00', true),
(8, 1, 6.1, '2024-03-05 14:20+00', true),
(1, 2, 160, '2024-01-10 09:35+00', true),
(5, 2, 140, '2024-01-20 09:00+00', true),
(3, 2, 130, '2024-03-01 09:20+00', false);

-- Vital signs
INSERT INTO vital_signs (encounter_id, recorded_time, systolic_bp, diastolic_bp, heart_rate, respiratory_rate, temperature_c)
VALUES
(1, '2024-01-10 09:10+00', 150, 95, 88, 18, 36.9),
(1, '2024-01-10 09:40+00', 145, 92, 82, 18, 36.8),
(2, '2024-02-05 18:15+00', 170, 100, 104, 22, 37.5),
(3, '2024-03-01 09:10+00', 138, 88, 80, 18, 36.7),
(5, '2024-01-20 08:30+00', 160, 98, 96, 20, 37.1),
(6, '2024-02-15 20:20+00', 155, 96, 92, 20, 37.3),
(7, '2024-02-01 10:05+00', 148, 94, 86, 18, 36.9),
(8, '2024-03-05 14:10+00', 142, 90, 84, 18, 36.8);

-- Billing claims
INSERT INTO billing_claims (encounter_id, insurance_provider, claim_amount, claim_status, submitted_date, paid_date)
VALUES
(1, 'Ontario Health', 250.00, 'PAID', '2024-01-11', '2024-01-20'),
(2, 'Ontario Health', 800.00, 'PAID', '2024-02-06', '2024-02-25'),
(3, 'Private Insurer A', 180.00, 'PENDING', '2024-03-02', NULL),
(4, 'Ontario Health', 120.00, 'PAID', '2024-01-16', '2024-01-30'),
(5, 'Private Insurer B', 2500.00, 'PAID', '2024-01-21', '2024-02-10'),
(6, 'Private Insurer B', 900.00, 'DENIED', '2024-02-16', NULL),
(7, 'Ontario Health', 200.00, 'OPEN', '2024-02-02', NULL),
(8, 'Private Insurer A', 160.00, 'OPEN', '2024-03-06', NULL);






























