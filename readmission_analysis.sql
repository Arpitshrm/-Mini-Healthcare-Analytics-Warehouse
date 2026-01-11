-- queries/readmission_analysis.sql
SET search_path TO health;

WITH ordered_encounters AS (
    SELECT
        e.patient_id,
        e.encounter_id,
        e.start_time,
        e.end_time,
        LAG(e.end_time) OVER (
            PARTITION BY e.patient_id
            ORDER BY e.start_time
        ) AS prev_end_time
    FROM encounters e
),
readmissions AS (
    SELECT
        patient_id,
        encounter_id,
        start_time,
        end_time,
        prev_end_time,
        EXTRACT(DAY FROM (start_time - prev_end_time)) AS days_since_last_encounter,
        CASE
            WHEN prev_end_time IS NULL THEN FALSE
            WHEN start_time - prev_end_time <= INTERVAL '30 days' THEN TRUE
            ELSE FALSE
        END AS is_readmission_30d
    FROM ordered_encounters
)
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    r.encounter_id,
    r.start_time,
    r.end_time,
    r.prev_end_time,
    r.days_since_last_encounter,
    r.is_readmission_30d
FROM readmissions r
JOIN patients p ON p.patient_id = r.patient_id
ORDER BY p.patient_id, r.start_time;
