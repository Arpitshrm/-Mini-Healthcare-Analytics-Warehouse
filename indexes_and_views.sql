-- schema/02_indexes_and_views.sql
SET search_path TO health;

-- Basic performance indexes
CREATE INDEX idx_encounters_patient_start
    ON encounters (patient_id, start_time);

CREATE INDEX idx_diagnoses_encounter
    ON diagnoses (encounter_id);

CREATE INDEX idx_diagnoses_code
    ON diagnoses (diagnosis_code);

CREATE INDEX idx_lab_results_encounter_time
    ON lab_results (encounter_id, result_time);

CREATE INDEX idx_vital_signs_encounter_time
    ON vital_signs (encounter_id, recorded_time);

CREATE INDEX idx_billing_claims_status
    ON billing_claims (claim_status);

-- Partial index for open claims only
CREATE INDEX idx_billing_claims_open
    ON billing_claims (encounter_id)
    WHERE claim_status IN ('OPEN','PENDING');

-- Window-based view: latest vitals per patient
CREATE VIEW v_patient_latest_vitals AS
WITH ordered_vitals AS (
    SELECT
        e.patient_id,
        v.*,
        ROW_NUMBER() OVER (
            PARTITION BY e.patient_id
            ORDER BY v.recorded_time DESC
        ) AS rn
    FROM vital_signs v
    JOIN encounters e ON e.encounter_id = v.encounter_id
)
SELECT
    patient_id,
    vital_id,
    encounter_id,
    recorded_time,
    systolic_bp,
    diastolic_bp,
    heart_rate,
    respiratory_rate,
    temperature_c
FROM ordered_vitals
WHERE rn = 1;

-- Materialized view: monthly encounter statistics by primary diagnosis
CREATE MATERIALIZED VIEW mv_monthly_encounter_stats AS
SELECT
    date_trunc('month', e.start_time)::date AS month_start,
    d.diagnosis_code,
    d.diagnosis_name,
    COUNT(DISTINCT e.encounter_id) AS encounter_count,
    COUNT(DISTINCT e.patient_id)   AS patient_count,
    AVG(EXTRACT(EPOCH FROM (e.end_time - e.start_time)) / 3600.0) AS avg_los_hours
FROM encounters e
JOIN diagnoses d
    ON d.encounter_id = e.encounter_id
   AND d.diagnosis_type = 'Primary'
GROUP BY
    date_trunc('month', e.start_time)::date,
    d.diagnosis_code,
    d.diagnosis_name;

-- Helper for refreshing materialized view
-- REFRESH MATERIALIZED VIEW CONCURRENTLY health.mv_monthly_encounter_stats;
