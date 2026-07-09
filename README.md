# Aerospace-Predictive-Maintenance
End-to-End Aerospace Predictive Maintenance and Supply Chain Optimization Platform using Snowflake, Python, Machine Learning and Power BI.
Aerospace Predictive Maintenance & Supply Chain Optimizer
Developed by Solomon Mensah

### Exploratory Data Analysis
We analyzed sensor degradation patterns to ensure only meaningful features were fed into our machine learning model.
![Engine Lifespan Distribution](screenshot/image1.png)
![Sensor Correlation with RUL](images/sensor_correlation.png)

An End-to-End Enterprise Solution leveraging Machine Learning, Cloud Data Warehousing, and Executive Business Intelligence.
.

🚀 Project Architecture Overview
This project delivers a complete enterprise analytical framework designed to minimize unscheduled aircraft downtime and maximize inventory efficiency. By transforming high-dimensional time-series sensor data from turbofan engines into clean, business-ready data structures, this framework provides automated procurement actions linked to real-time risk profiles.
🎛️ Executive Command Center
The system culminates in a live business dashboard that mirrors production status, unifying operational maintenance requirements with automated supply chain workflows.

📊 Phase 1: Exploratory Data Analysis & Lifespan Analytics
To understand the mechanics of engine degradation, a deep exploration of engine failure thresholds was performed. The data evaluates multiple engines running sequentially until system failure occurs.

🕒 Distribution of Total Life Cycles
Statistical profiling of the overall operational threshold reveals that engine breakdown behaves symmetrically around a distinct mean lifespan. This provides baseline physics indicating when predictive alerts should intensify.

Mean Lifespan: The historical baseline shows systems naturally reach failure around 206 operational cycles.

Operational Variance: The continuous curve indicates the probability distribution, warning managers against basic scheduled maintenance strategies due to premature engine failure risks.

📉 Extreme Lifespan Disparities
Understanding anomalous engine behaviors helps isolate outer operational bounds, allowing safety analysts to determine worst-case fleet scenarios.

🛠️ Phase 2: Feature Engineering & Sensor Drift MechanicsA core technical challenge is selecting features that drift predictably as systems degrade, discarding dead channels with constant values or low variance that introduce computational noise.🌡️ Target Correlation EngineeringRemaining Useful Life (RUL) represents the dependent target variable generated for the machine learning model, mathematically formulated as:$$\text{RUL}_t = t_{\text{failure}} - t_{\text{current}}$$Correlation mapping reveals which physical metrics move linearly with progressive machine wear.

📈 Healthy vs. Failing State Separability
Top-performing prognostic sensors display distinct probability distribution shifts between initial healthy runs (green) and late-stage operating states (red).

Signal Shifting: Active sensors like T50 and Ps30 display strong monotonic drift, providing distinct non-overlapping indicators as failure nears.

Symmetry Breakdown: Distorted distributions highlight accelerated physical degradation in the final 30 cycles of operation.

🤖 Phase 3: Advanced Modeling & Interpretability Pipeline
To resolve high-dimensional multi-sensor interactions, an XGBoost Regressor algorithm was trained on engineered degradation features.

🗺️ PCA Projection: Engine Degradation Trajectory
Principal Component Analysis (PCA) maps the high-dimensional sensor readings down to an optimal 2D coordinate space, illustrating the system's irreversible flight path from peak health to failure.

🔍 Explainable AI (XAI) via SHAP Interaction Values
To make the black-box ensemble model acceptable to engineering and safety directors, SHAP (SHapley Additive exPlanations) values decompose the unique interaction effects driving real-time prediction curves.

Engineering Insight: Decomposing overlapping sensor attributes via SHAP values isolates conditional dependencies (such as temperature spikes vs. pressure drops), ensuring explainable threshold constraints across all prediction outputs.

❄️ Phase 4: Snowflake Data Warehouse Architecture
The core data processing layer utilizes a automated cloud infrastructure built entirely inside Snowflake to guarantee secure, production-grade scalability.

🏗️ Medallion Architecture Setup
Data transitions cleanly through independent structural schemas:

Bronze Layer (bronze_raw): Raw time-series ingestion tables preserving immutable history.

Silver Layer (silver_clean): Cleaned, filtered data structures with outliers eliminated.

Gold Layer (gold_business): Production-ready fact tables (FACT_INVENTORY, FACT_PREDICTIONS, FACT_DEMAND) feeding optimized business objects.

🛡️ Administrative Governance & Financial Optimization
The script applies robust system management principles to eliminate compute waste and restrict unauthorized view access:

Resource Monitors: Enforces a dedicated 5-credit maximum threshold to suspend rogue computing costs instantly.

Role-Based Access Control (RBAC): Restricts data read and write privileges via isolated professional definitions (nfi_data_scientist, nfi_supply_chain_analyst).

Materialized Optimization Views: Implements optimized relational schemas (VW_EXECUTIVE_SUMMARY, VW_RECOMMENDATIONS) allowing rapid DirectQuery data updates inside Power BI without executing expensive dataset refreshes.
📈 Key Portfolio Outcomes & Business Value
Zero-Downtime Logistics: Bridges data engineering with operations, flagging parts requiring immediate attention before critical failures cause unexpected AOG (Aircraft on Ground) events.

Intelligent Supply Chain Syncing: Evaluates supplier lead times alongside real-time failure risk to automate optimal reorder quantities, preventing cost-intensive overstocking.

Governance First: Proves proficiency in writing real-world, enterprise-ready SQL code incorporating automated safety controls, security definitions, and optimized view execution layers.
