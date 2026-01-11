-- queries/lab_trends.sql
SET search_path TO health;

WITH hba1c AS (
    SELECT
        e.patient_id,
        lr.lab_result_id,
        lr.result_time,
        lr.result_value
    FROM lab_results lr
    JOIN encounters e ON e.encounter_id = lr.encounter_id
    JOIN lab_tests lt ON lt.lab_test_id = lr.lab_test_id
    WHERE lt.test_code = 'HBA1C'
),
rolling AS (
    SELECT
        patient_id,
        lab_result_id,
        result_time,
        result_value,
        AVG(result_value) OVER (
            PARTITION BY patient_id
            ORDER BY result_time
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_last_3
    FROM hba1c
)
SELECT
    r.patient_id,
    p.first_name,
    p.last_name,
    r.result_time,
    r.result_value,
    r.rolling_avg_last_3
FROM rolling r
JOIN patients p ON p.patient_id = r.patient_id
ORDER BY r.patient_id, r.result_time;
