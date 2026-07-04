SET GLOBAL local_infile = 1;
USE clinical_dwh;

-- 1. Load Patients
LOAD DATA LOCAL INFILE 'C:/Users/Hp/Downloads/archive (17)/patients.csv'
INTO TABLE dim_patients
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

-- 2. Load Vitals 
LOAD DATA LOCAL INFILE 'C:/Users/Hp/Downloads/archive (17)/vitals_timeseries.csv'
INTO TABLE fact_vitals
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(patient_id, hour_from_admission, heart_rate, respiratory_rate, spo2_pct, temperature_c, systolic_bp, diastolic_bp, oxygen_device, oxygen_flow, mobility_score, nurse_alert);

-- 3. Load Labs
LOAD DATA LOCAL INFILE 'C:/Users/Hp/Downloads/archive (17)/labs_timeseries.csv'
INTO TABLE fact_labs
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(patient_id, hour_from_admission, wbc_count, lactate, creatinine, crp_level, hemoglobin, sepsis_risk_score);
SELECT * FROM clinical_dwh.fact_vitals LIMIT 100;
SELECT * FROM clinical_dwh.dim_patients LIMIT 100;
SELECT * FROM clinical_dwh.fact_labs LIMIT 100;
USE clinical_dwh;

-- 1. Accelerate query speeds by creating structural index pipelines
CREATE INDEX idx_vitals_patient_hour ON fact_vitals(patient_id, hour_from_admission);
CREATE INDEX idx_labs_patient_hour ON fact_labs(patient_id, hour_from_admission);

-- 2. Build the dynamic analytical layer view (Matches your original merged layout)
CREATE VIEW view_hospital_deterioration_hourly_panel AS
SELECT 
    v.patient_id,
    v.hour_from_admission,
    v.heart_rate, v.respiratory_rate, v.spo2_pct, v.temperature_c, v.systolic_bp, v.diastolic_bp,
    v.oxygen_device, v.oxygen_flow, v.mobility_score, v.nurse_alert,
    l.wbc_count, l.lactate, l.creatinine, l.crp_level, l.hemoglobin, l.sepsis_risk_score,
    p.age, p.gender, p.comorbidity_index, p.admission_type, p.baseline_risk_score, p.los_hours,
    p.deterioration_event, p.deterioration_within_12h_from_admission, p.deterioration_hour
FROM fact_vitals v
LEFT JOIN fact_labs l 
    ON v.patient_id = l.patient_id AND v.hour_from_admission = l.hour_from_admission
LEFT JOIN dim_patients p 
    ON v.patient_id = p.patient_id;
    SELECT * FROM view_hospital_deterioration_hourly_panel LIMIT 10;