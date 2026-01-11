-- queries/high_risk_patients.sql
SET search_path TO health;

WITH chronic_conditions AS (
    SELECT DISTINCT
        e.patient_id
    FROM diagnoses d
    JOIN encounters e ON e.encounter_id = d.encounter_id
    WHERE d.diagnosis_code IN ('E11','I10')  -- diabetes or hypertension
),
abnormal_labs AS (
    SELECT DISTINCT
        e.patient_id
    FROM lab_results lr
    JOIN encounters e ON e.encounter_id = lr.encounter_id
    WHERE lr.abnormal_flag = TRUE
),
frequent_er_visits AS (
    SELECT
        e.patient_id,
        COUNT(*) AS er_visits_6m
    FROM encounters e
    WHERE e.encounter_type_code = 'ER'
      AND e.start_time >= (CURRENT_DATE - INTERVAL '6 months')
    GROUP BY e.patient_id
    HAVING COUNT(*) >= 2
),
combined AS (
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        COALESCE(f.er_visits_6m, 0) AS er_visits_6m,
        CASE WHEN c.patient_id IS NOT NULL THEN TRUE ELSE FALSE END AS has_chronic_condition,
        CASE WHEN a.patient_id IS NOT NULL THEN TRUE ELSE FALSE END AS has_abnormal_labs
    FROM patients p
    LEFT JOIN chronic_conditions c ON c.patient_id = p.patient_id
    LEFT JOIN abnormal_labs a ON a.patient_id = p.patient_id
    LEFT JOIN frequent_er_visits f ON f.patient_id = p.patient_id
)
SELECT *
FROM combined
WHERE has_chronic_condition
   OR has_abnormal_labs
   OR er_visits_6m >= 2
ORDER BY er_visits_6m DESC, patient_id;
