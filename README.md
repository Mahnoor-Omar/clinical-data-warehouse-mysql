# Clinical Data Warehouse for Patient Deterioration Analytics

## 📌 Project Overview
Engineered an enterprise-grade **Star Schema Data Warehouse** in MySQL from raw, high-velocity clinical time-series flat files (Vitals & Laboratory tracking metrics). Designed highly optimized data ingestion pipelines, structural indexing systems, and memory-efficient virtual reporting layers to deliver real-time feature streams for downstream BI dashboards (Power BI) and predictive Machine Learning applications.

---

## 🏗️ Architecture & Star Schema Design
To eliminate data redundancy and maximize analytical performance, the dataset was decoupled into a centralized **Star Schema** using the Kimball Methodology:

* **`dim_patients` (Dimension Table):** Contains demographics, static patient profiles, baseline risk scores, and primary outcomes.
* **`fact_vitals` (Fact Table):** High-frequency time-stamped telemetry logs capture longitudinal vital signs.
* **`fact_labs` (Fact Table):** Granular time-stamped clinical biomarkers and laboratory risk models.
* **Virtual Reporting Views (`view_hospital_deterioration_hourly_panel`):** Deployed a virtual normalization layer to reconstruct unified analytical profiles on the fly without consuming additional disk space.



---

## ⚡ Data Engineering & Performance Optimizations

### 1. High-Velocity Bulk Ingestion
Standard iterative row-by-row wizard imports failed due to the massive scale of the time-series arrays. I reconfigured server-side execution parameters (`local_infile = 1`) and built optimized bulk-loading scripts to process hundreds of thousands of entries simultaneously:
```sql
LOAD DATA LOCAL INFILE 'vitals_timeseries.csv'
INTO TABLE fact_vitals
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;
