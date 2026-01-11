-- queries/length_of_stay.sql
SET search_path TO health;

WITH encounter_los AS (
    SELECT
        e.encounter_id,
        e.patient_id,
        e.start_time,
        e.end_time,
        EXTRACT(EPOCH FROM (e.end_time - e.start_time)) / 3600.0 AS los_hours
    FROM encounters e
),
stats AS (
    SELECT
        encounter_id,
        patient_id,
        start_time,
        end_time,
        los_hours,
        NTILE(4) OVER (ORDER BY los_hours) AS los_quartile,
        PERCENT_RANK() OVER (ORDER BY los_hours) AS los_percent_rank
    FROM encounter_los
)
SELECT
    s.*,
    p.first_name,
    p.last_name
FROM stats s
JOIN patients p ON p.patient_id = s.patient_id
ORDER BY los_hours DESC;
