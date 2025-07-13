# ---- Install & Load Required Packages ----
if (!require("airGRteaching")) install.packages("airGRteaching")
if (!require("airGR")) install.packages("airGR")
library(airGRteaching)
library(airGR)

# ---- 1. Generate Synthetic Daily Data (for 1 year) ----
set.seed(42)  # For reproducibility

# ✅ FIX: Add time zone (UTC) to dates
dates <- seq(as.POSIXct("2024-01-01", tz = "UTC"),
             as.POSIXct("2024-12-31", tz = "UTC"),
             by = "day")

n <- length(dates)

# Generate synthetic daily data assuming Mahaweli-like rainfall and PET
precip <- runif(n, min = 0, max = 25)  # Rainfall in mm
pet <- runif(n, min = 3, max = 7)      # Potential Evapotranspiration in mm
qobs <- precip * runif(n, min = 0.1, max = 0.4)  # Simplified runoff generation

# Combine into data frame
df <- data.frame(DatesR = dates,
                 Precip = precip,
                 PotEvap = pet,
                 Qobs = qobs)

# ---- 2. Prepare Data for GR4J Model ----
prep <- PrepGR(DatesR = df$DatesR,
               Precip = df$Precip,
               PotEvap = df$PotEvap,
               Qobs = df$Qobs,
               HydroModel = "GR4J")

# ---- 3. Calibrate Model Parameters ----
cal <- CalGR(PrepGR = prep, CalPer = c(as.POSIXct("2024-01-01", tz = "UTC"),
                                          as.POSIXct("2024-12-31", tz = "UTC")))


# View Calibrated Parameters
print("Calibrated Parameters:")
print(cal$CalibOptions$ParamFinalR)

# ---- 4. Run Simulation ----
sim <- SimGR(PrepGR = prep,
             CalGR = cal,
             SimPer = c(as.POSIXct("2024-01-01", tz = "UTC"),
                        as.POSIXct("2024-12-31", tz = "UTC")))


# ---- 5. Plot Results ----
plot(sim, plot.type = "ts")  # Time-series plot of P, PET, Qobs, Qsim

# ---- 6. Evaluate Performance ----
 
summary(sim)
str(sim)



print("Model Performance:")


# ---- 7. Export Simulated Data ----
df$Qsim <- sim$OutputsModel$Qsim
write.csv(df, "Mahaweli_GR4J_simulated_results.csv", row.names = FALSE)
write.csv(df, "C:/Users/strangers/Documents/Mahaweli_GR4J_simulated_results.csv")

