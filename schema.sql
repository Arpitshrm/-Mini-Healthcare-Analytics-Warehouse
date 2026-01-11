-- schema/01_schema.sql
-- Mini Healthcare Analytics Warehouse (PostgreSQL)

CREATE SCHEMA IF NOT EXISTS health;

SET search_path TO health;

-- PATIENTS
CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    gender          VARCHAR(10) NOT NULL CHECK (gender IN ('Male','Female','Other')),
    birth_date      DATE NOT NULL CHECK (birth_date <= CURRENT_DATE),
    smoker_flag     BOOLEAN NOT NULL DEFAULT FALSE,
    bmi             NUMERIC(4,1) CHECK (bmi IS NULL OR (bmi >= 10 AND bmi <= 80)),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- CLINICIANS
CREATE TABLE clinicians (
    clinician_id    SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    specialty       VARCHAR(100) NOT NULL,
    active_flag     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ENCOUNTER TYPES
CREATE TABLE encounter_types (
    encounter_type_code VARCHAR(10) PRIMARY KEY,
    description         VARCHAR(100) NOT NULL
);

INSERT INTO encounter_types (encounter_type_code, description) VALUES
('OP', 'Outpatient'),
('IP', 'Inpatient'),
('ER', 'Emergency');

-- ENCOUNTERS
CREATE TABLE encounters (
    encounter_id        SERIAL PRIMARY KEY,
    patient_id          INT NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    clinician_id        INT NOT NULL REFERENCES clinicians(clinician_id),
    encounter_type_code VARCHAR(10) NOT NULL REFERENCES encounter_types(encounter_type_code),
    start_time          TIMESTAMPTZ NOT NULL,
    end_time            TIMESTAMPTZ NOT NULL,
    discharge_disposition VARCHAR(50),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_time >= start_time)
);

-- DIAGNOSES
CREATE TABLE diagnoses (
    diagnosis_id    SERIAL PRIMARY KEY,
    encounter_id    INT NOT NULL REFERENCES encounters(encounter_id) ON DELETE CASCADE,
    diagnosis_code  VARCHAR(20) NOT NULL,
    diagnosis_name  VARCHAR(255) NOT NULL,
    diagnosis_type  VARCHAR(20) NOT NULL CHECK (diagnosis_type IN ('Primary','Secondary')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- MEDICATIONS (reference)
CREATE TABLE medications (
    medication_id   SERIAL PRIMARY KEY,
    medication_name VARCHAR(255) NOT NULL,
    atc_code        VARCHAR(20),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- MEDICATION ORDERS
CREATE TABLE medication_orders (
    med_order_id    SERIAL PRIMARY KEY,
    encounter_id    INT NOT NULL REFERENCES encounters(encounter_id) ON DELETE CASCADE,
    medication_id   INT NOT NULL REFERENCES medications(medication_id),
    dose_mg         NUMERIC(7,2) NOT NULL CHECK (dose_mg > 0 AND dose_mg <= 10000),
    frequency_per_day INT NOT NULL CHECK (frequency_per_day BETWEEN 1 AND 6),
    start_date      DATE NOT NULL,
    end_date        DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

-- LAB TESTS (reference)
CREATE TABLE lab_tests (
    lab_test_id     SERIAL PRIMARY KEY,
    test_code       VARCHAR(20) NOT NULL UNIQUE,
    test_name       VARCHAR(255) NOT NULL,
    unit            VARCHAR(20),
    normal_min      NUMERIC(10,2),
    normal_max      NUMERIC(10,2),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- LAB RESULTS
CREATE TABLE lab_results (
    lab_result_id   SERIAL PRIMARY KEY,
    encounter_id    INT NOT NULL REFERENCES encounters(encounter_id) ON DELETE CASCADE,
    lab_test_id     INT NOT NULL REFERENCES lab_tests(lab_test_id),
    result_value    NUMERIC(10,2) NOT NULL,
    result_time     TIMESTAMPTZ NOT NULL,
    abnormal_flag   BOOLEAN,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- VITAL SIGNS
CREATE TABLE vital_signs (
    vital_id        SERIAL PRIMARY KEY,
    encounter_id    INT NOT NULL REFERENCES encounters(encounter_id) ON DELETE CASCADE,
    recorded_time   TIMESTAMPTZ NOT NULL,
    systolic_bp     INT CHECK (systolic_bp IS NULL OR (systolic_bp BETWEEN 60 AND 260)),
    diastolic_bp    INT CHECK (diastolic_bp IS NULL OR (diastolic_bp BETWEEN 30 AND 140)),
    heart_rate      INT CHECK (heart_rate IS NULL OR (heart_rate BETWEEN 30 AND 220)),
    respiratory_rate INT CHECK (respiratory_rate IS NULL OR (respiratory_rate BETWEEN 5 AND 60)),
    temperature_c   NUMERIC(4,1) CHECK (temperature_c IS NULL OR (temperature_c BETWEEN 30 AND 43)),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- BILLING CLAIMS
CREATE TABLE billing_claims (
    claim_id        SERIAL PRIMARY KEY,
    encounter_id    INT NOT NULL REFERENCES encounters(encounter_id) ON DELETE CASCADE,
    insurance_provider VARCHAR(100),
    claim_amount    NUMERIC(10,2) NOT NULL CHECK (claim_amount >= 0),
    claim_status    VARCHAR(20) NOT NULL CHECK (claim_status IN ('OPEN','PENDING','PAID','DENIED')),
    submitted_date  DATE NOT NULL,
    paid_date       DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (paid_date IS NULL OR paid_date >= submitted_date)
);
