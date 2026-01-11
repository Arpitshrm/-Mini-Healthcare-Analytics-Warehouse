# Mini Healthcare Analytics Warehouse (PostgreSQL)

This project is a small but realistic healthcare analytics database built on PostgreSQL, designed to showcase intermediate‑to‑advanced SQL skills including constraints, indexes, window functions, CTEs, views, and materialized views.

---

## Schema overview

The database models core clinical concepts:

- Patients, clinicians, and encounters (OP, IP, ER)
- Diagnoses, medication orders, lab results, vital signs
- Billing claims and encounter‑level financials

### Entity‑Relationship Diagram

> Export your ERD as `assets/erd.png` and it will render here.

![Healthcare ERD](erd.png)

---

## Features and SQL concepts

- **Data modelling**: Normalized schema across patients, encounters, clinical events, and billing.
- **Data integrity**: Primary/foreign keys and rich `CHECK` constraints (date ranges, physiological ranges, statuses).
- **Performance**: B‑tree and partial indexes for common access paths and open claims.
- **Advanced querying**:
  - CTE pipelines for multi‑step transformations.
  - Window functions (`LAG`, `NTILE`, `PERCENT_RANK`, rolling averages).
- **Reusable logic**:
  - View: `v_patient_latest_vitals` (latest vitals per patient).
  - Materialized view: `mv_monthly_encounter_stats` (monthly encounter and LOS stats).

---

## Getting started

### 1. Create database

```bash
createdb health_warehouse
psql -d health_warehouse -f schema/01_schema.sql
psql -d health_warehouse -f schema/02_indexes_and_views.sql
psql -d health_warehouse -f data/load_data.sql
