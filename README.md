# Rainfall–Runoff Modeling in the Mahaweli Basin Using the GR4J Model (R / airGR)

## Overview
This project demonstrates rainfall–runoff modeling of the Mahaweli River Basin, Sri Lanka using the conceptual GR4J hydrological model implemented in R with the airGR and airGRteaching packages.

### The rainfall–runoff process is modeled through two approaches:
#### 1. Synthetic Data Simulation Approach
- Synthetic daily rainfall and potential evapotranspiration (PET) data were generated to mimic Mahaweli Basin conditions.
- Synthetic observed streamflow (discharge) data were created using a simple runoff generation rule from synthetic rainfall.
- The GR4J model was calibrated and run on this fully synthetic dataset.
- The model performance metric (Nash-Sutcliffe Efficiency, NSE) achieved was 0.367, demonstrating moderate predictive skill with synthetic inputs.

#### 2. Real Data with Synthetic Discharge Approach
- Real rainfall and PET data were downloaded from Google Earth Engine and preprocessed via Google Colab into CSV format.
- These observed climate data were used as inputs to the GR4J model.
- Since observed discharge data were unavailable, synthetic discharge was generated from the rainfall data for model calibration and simulation.
- This approach illustrates the practical workflow of integrating real climate data into hydrological modeling.
- However, the model performance metric (Nash-Sutcliffe Efficiency, NSE) achieved was 0.08, demonstrating low predictive skill with synthetic discharge inputs.

## Objectives
1. Demonstrate hydrological modeling workflow using GR4J to simulate daily streamflow.
2. Show how to use both fully synthetic datasets and real climate data for catchment modeling.
3. Calibrate model parameters and evaluate model performance using key statistics:
  - Nash-Sutcliffe Efficiency (NSE)
  - Kling-Gupta Efficiency (KGE)
  - Root Mean Square Error (RMSE)
  - Coefficient of Determination (R²)
4. Provide a reproducible R-based pipeline for rainfall–runoff simulation adaptable to other basins.

### Synthetic Data Simulation Approach
<img width="1920" height="1004" alt="Screenshot (253)" src="https://github.com/user-attachments/assets/9164e42f-51e2-4c49-a6b5-f6352423e007" />

### Real Data with Synthetic Discharge Approach
<img width="1920" height="1007" alt="Screenshot (252)" src="https://github.com/user-attachments/assets/16fd8a1a-9d6f-49e0-b798-48e6585bb045" />

## Data Sources
1. Synthetic Data: Generated programmatically to represent Mahaweli-like climate.
2. Real Data: Daily rainfall and PET retrieved from Google Earth Engine for Mahaweli Basin, processed externally via Google Colab.
3. Discharge: Synthetic discharge generated from rainfall in both approaches (replaceable with observed discharge if available).

## Tools and Packages
- R programming language
- airGR and airGRteaching: Open-source R packages providing hydrological models including GR4J, calibration, simulation, and evaluation tools.
- Google Earth Engine (GEE): For climate data extraction.
- Google Colab: For preprocessing raw climate data into analysis-ready CSV files.

## References
1. airGR Project Documentation
2. Javed Ali et al., airGRteaching package for hydrological modeling in R, ResearchGate, Young Hydrologic Society, HESS. 
3. Perrin, C., Michel, C., & Andréassian, V. (2003). GR4J: A daily rainfall-runoff model with four parameters. Hydrological Sciences Journal, 48(3), 393-411.



