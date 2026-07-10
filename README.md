# ✈️ Aerospace Predictive Maintenance & Supply Chain Optimizer

### End-to-End Predictive Maintenance, Failure Forecasting, and Supply Chain Optimization Platform

**Developed by Solomon Mensah**

---

## 📌 Project Overview

Unexpected aircraft engine failures can lead to costly maintenance events, aircraft downtime, supply chain disruptions, and safety concerns.

This project leverages the NASA CMAPSS Turbofan Engine Dataset to develop an end-to-end predictive maintenance solution capable of forecasting engine degradation, estimating Remaining Useful Life (RUL), identifying high-risk assets, and optimizing inventory decisions through a modern cloud-based analytics architecture.

The solution integrates:

- Python & Jupyter Notebooks
- Exploratory Data Analysis (EDA)
- Feature Engineering
- Machine Learning (XGBoost)
- Explainable AI (SHAP)
- Snowflake Data Warehouse
- Power BI Executive Reporting

---

# 🎯 Business Problem

Traditional maintenance approaches typically rely on fixed inspection intervals or historical averages.

This often results in:

- Premature component replacement
- Unexpected equipment failures
- Excess spare-parts inventory
- Aircraft-On-Ground (AOG) events
- Increased maintenance costs

This project introduces a predictive maintenance framework that enables organizations to:

✅ Predict engine failures before they occur

✅ Estimate Remaining Useful Life (RUL)

✅ Identify critical maintenance actions

✅ Optimize inventory allocation

✅ Improve fleet reliability

✅ Reduce operational disruptions

---

# 🏗️ Solution Architecture

text
NASA CMAPSS Dataset
          │
          ▼
Exploratory Data Analysis
          │
          ▼
Feature Engineering
          │
          ▼
Machine Learning (XGBoost)
          │
          ▼
Model Explainability (SHAP)
          │
          ▼
Snowflake Data Warehouse
(Bronze → Silver → Gold)
          │
          ▼
Power BI Command Center


---

# 📊 Exploratory Data Analysis

The first stage focused on understanding degradation patterns and identifying how engine behavior changes as failure approaches.

Understanding these trends helps establish maintenance thresholds and supports predictive maintenance decision-making.

---

## Engine Lifespan Distribution

The histogram below shows the distribution of total engine lifecycles before failure.

images/engine_lifespan_distribution.png

### Key Insights

- Mean engine lifespan is approximately **206 cycles**
- Engine failures follow a roughly normal distribution
- Significant lifecycle variability exists across engines
- Fixed maintenance intervals may not be optimal for all assets

---

## Extreme Engine Lifespans

To understand best-case and worst-case operational scenarios, the longest and shortest-performing engines were analyzed.

extreme_engine_lifespans.png

### Key Insights

- Some engines exceeded **360 cycles**
- Others failed near **130 cycles**
- Lifecycle variation highlights the need for predictive maintenance rather than fixed scheduling
- High-performing and low-performing engines provide valuable degradation benchmarks

---

# ⚙️ Feature Engineering & Sensor Intelligence

Predictive maintenance depends heavily on identifying sensor variables that consistently change as engines degrade.

Sensor trends were examined to isolate the most informative variables and eliminate low-value noise.

---

## Sensor Correlation with Remaining Useful Life

The heatmap below identifies sensors with the strongest relationship to Remaining Useful Life (RUL).
sensor_correlation_heatmap.png

### Key Insights

Strong predictors include:

- Ps30
- T50
- Time Cycles
- BPR
- htBleed
- T24
- Nf
- NRf

These variables demonstrated the strongest relationships with engine degradation and became critical inputs to the machine learning model.

---

## Healthy vs Failing Engine States

Understanding how sensor values shift between healthy and failing states is essential for predictive maintenance.

healthy_vs_failing_engines.png

### Key Insights

As engine failure approaches:

- Temperature variables drift significantly
- Pressure measurements shift consistently
- Distribution overlap decreases
- Healthy and failing states become increasingly distinguishable

These patterns provide strong predictive signals for machine learning algorithms.

---

# 🤖 Machine Learning Model

An XGBoost Regression model was developed to estimate Remaining Useful Life (RUL) using engineered sensor features.

---

## Remaining Useful Life Formula

```text
RUL = Failure Cycle - Current Cycle
```

The model continuously estimates how many operating cycles remain before engine failure occurs.

---

## PCA Analysis: Engine Degradation Trajectory

To visualize degradation patterns across many sensors, Principal Component Analysis (PCA) was applied.

pca_degradation_analysis.png

### Key Insights

- PCA captures approximately **65% of the sensor information**
- Healthy engines cluster in high-RUL regions
- Degraded engines move toward low-RUL regions
- Clear degradation pathways emerge before failure

The PCA visualization demonstrates how engines transition through measurable health states throughout their lifecycle.

---

# 🔍 Explainable AI (SHAP)

Machine learning predictions must be understandable by engineering and maintenance teams.

To improve transparency, SHAP (SHapley Additive Explanations) was used to interpret model behavior.

---

## SHAP Interaction Analysis

The interaction matrix below illustrates how critical sensors influence one another during prediction generation.

shap_interaction_analysis.png

### Key Insights

- Ps30 and T50 display significant interaction effects
- Sensor relationships contribute jointly to degradation predictions
- Interactions reveal deeper patterns than isolated feature importance
- Helps engineers understand complex failure mechanisms

---

## SHAP Feature Relationships

The visualization below highlights the combined influence of critical variables within the predictive model.

shap_feature_relationships.png

### Key Insights

- Sensor interactions are highly nonlinear
- Important predictors reinforce one another
- Failure predictions are driven by combinations of sensor behaviors
- Explainability increases confidence in maintenance decisions

---

# ❄️ Snowflake Data Warehouse

A Medallion Architecture was implemented within Snowflake to support scalable, governed analytics.

---

## Bronze Layer

```text
bronze_raw
```

Stores raw sensor and operational data.

### Purpose

- Historical preservation
- Raw ingestion
- Auditability

---

## Silver Layer

```text
silver_clean
```

Stores cleaned and transformed datasets.

### Purpose

- Data quality improvements
- Feature preparation
- Standardization

---

## Gold Layer

```text
gold_business
```

Contains business-ready structures supporting executive reporting.

### Fact Tables

- FACT_PREDICTIONS
- FACT_INVENTORY
- FACT_DEMAND

### Dimension Tables

- DIM_PART
- DIM_VEHICLE
- DIM_WAREHOUSE

### Business Views

- VW_EXECUTIVE_SUMMARY
- VW_RECOMMENDATIONS

---

## Governance & Cost Optimization

Enterprise-grade governance controls were implemented in Snowflake.

### Resource Monitoring

```text
5-Credit Resource Monitor
```

Prevents uncontrolled warehouse spending.

### Role-Based Access Control (RBAC)

Roles include:

```text
nfi_data_scientist
nfi_supply_chain_analyst
```

### Dedicated Compute Resources

```text
NFI_COMPUTE_WH
```

### Power BI DirectQuery Optimization

Optimized reporting views enable efficient dashboard refreshes while minimizing compute costs.

---

# 📊 Aerospace Predictive Maintenance Command Center

The final deliverable is an executive dashboard designed to connect maintenance planning, fleet health, and supply chain optimization into a single decision-support platform.

image3.png

---

## Executive Dashboard Features

### Fleet Monitoring

- Total Vehicles
- Fleet Health Score
- Average Remaining Useful Life
- Healthy Fleet Percentage

### Failure Prediction

- 30-Day Failure Risk
- Fleet Health Distribution
- Failure Risk Monitoring

### Maintenance Planning

- Maintenance Action Breakdown
- Immediate Replacement Requirements
- Monitoring Recommendations

### Supply Chain Optimization

- Inventory Investment Analysis
- Component-Level Inventory Value
- Reorder Planning Support

---

# 📈 Business Value Delivered

## Predictive Maintenance

Predicts future failures before operational disruption occurs.

## Inventory Optimization

Aligns parts inventory with forecasted maintenance requirements.

## Operational Reliability

Improves fleet readiness through proactive maintenance scheduling.

## Executive Visibility

Provides leadership with a real-time view of fleet risk, inventory investment, and maintenance demand.

## Cost Control

Reduces unnecessary inventory investments while minimizing stockout risk.

---

# 🛠️ Technology Stack

## Data Engineering

- Snowflake
- SQL
- Medallion Architecture
- RBAC Security

## Data Science

- Python
- Pandas
- NumPy
- Scikit-Learn
- XGBoost
- SHAP

## Business Intelligence

- Power BI
- DAX
- DirectQuery

## Development Tools

- Jupyter Notebook
- Anaconda
- GitHub

---

# 🚀 Future Enhancements

- Real-Time Sensor Streaming
- Azure Data Factory Integration
- Snowpark ML Deployment
- MLOps Monitoring Framework
- Predictive Procurement Automation
- Digital Twin Simulation
- Automated Alerting Workflows

---

# 👨‍💻 Author

**Solomon Mensah**

Data Analytics | Business Intelligence | Snowflake | Power BI | Machine Learning

📍 Winnipeg, Manitoba, Canada

---

### ⭐ If you found this project useful, please consider starring this repository.
