# ---- Install & Load Required Packages ----
if (!require("airGRteaching")) install.packages("airGRteaching")
if (!require("airGR")) install.packages("airGR")
library(airGRteaching)
library(airGR)

# ---- 1. Load and Merge CSVs ----

# Load rainfall data
rain <- read.csv("C:/Users/strangers/Documents/mahaweli_rainfall_2023.csv")
colnames(rain) <- c("Date", "Precip")

# Load ET data
et <- read.csv("C:/Users/strangers/Documents/mahaweli_et_2023.csv")
colnames(et) <- c("Date", "PotEvap")

# Trim whitespace (clean weird entries)
rain$Date <- trimws(rain$Date)
et$Date <- trimws(et$Date)

# Parse date (handle your format "1/1/2023" safely)
rain$Date <- as.Date(rain$Date, format = "%d/%m/%Y")
et$Date <- as.Date(et$Date, format = "%d/%m/%Y")

# Merge by Date
df <- merge(rain, et, by = "Date")

# Remove NA or duplicated dates
df <- df[!is.na(df$Date), ]
df <- df[!duplicated(df$Date), ]

# Rename parsed date column for model
df$DatesR <- df$Date



# Optional: Create synthetic observed discharge for now
set.seed(42)
df$Qobs <- df$Precip * runif(nrow(df), min = 0.1, max = 0.4)

# Reorder columns as required by airGR
df <- df[, c("DatesR", "Precip", "PotEvap", "Qobs")]

# ---- 3. Create complete daily date sequence ----
all_dates <- seq(min(df$DatesR), max(df$DatesR), by = "day")
df_full <- data.frame(DatesR = all_dates)

# ---- 4. Merge original data into complete date sequence ----
df_full <- merge(df_full, df, by = "DatesR", all.x = TRUE)

# ---- 5. Fill missing values ----
df_full$Precip[is.na(df_full$Precip)] <- 0
df_full$PotEvap[is.na(df_full$PotEvap)] <- 0
df_full$Qobs[is.na(df_full$Qobs)] <- 0

# FIX: Convert DatesR to POSIXct with UTC timezone
df_full$DatesR <- as.POSIXct(df_full$DatesR, tz = "UTC")



# ---- 6. Prepare input for the GR4J model ----
prep <- PrepGR(DatesR = df_full$DatesR,
               Precip = df_full$Precip,
               PotEvap = df_full$PotEvap,
               Qobs = df_full$Qobs,
               HydroModel = "GR4J")

# ---- 7. Calibrate model ----
cal <- CalGR(PrepGR = prep, CalPer = range(df_full$DatesR))

# ---- 8. Simulate using calibrated parameters ----
sim <- SimGR(PrepGR = prep,
             CalGR = cal,
             SimPer = range(df_full$DatesR))

# ---- Evaluate Model Performance ----

# Use observed and simulated streamflow
Qobs <- df_full$Qobs
Qsim <- sim$OutputsModel$Qsim

# Remove any NA values for evaluation
valid_idx <- which(!is.na(Qobs) & !is.na(Qsim))
Qobs_valid <- Qobs[valid_idx]
Qsim_valid <- Qsim[valid_idx]

# ---- 1. NSE (Nash-Sutcliffe Efficiency) ----
nse <- 1 - sum((Qobs_valid - Qsim_valid)^2) / sum((Qobs_valid - mean(Qobs_valid))^2)
cat("Nash-Sutcliffe Efficiency (NSE):", round(nse, 3), "\n")

# ---- 2. KGE (Kling-Gupta Efficiency) ----
mean_obs <- mean(Qobs_valid)
mean_sim <- mean(Qsim_valid)
sd_obs <- sd(Qobs_valid)
sd_sim <- sd(Qsim_valid)
r <- cor(Qobs_valid, Qsim_valid)

beta <- mean_sim / mean_obs
gamma <- sd_sim / sd_obs

kge <- 1 - sqrt((r - 1)^2 + (beta - 1)^2 + (gamma - 1)^2)
cat("Kling-Gupta Efficiency (KGE):", round(kge, 3), "\n")

# ---- 3. RMSE (Root Mean Square Error) ----
rmse <- sqrt(mean((Qobs_valid - Qsim_valid)^2))
cat("Root Mean Square Error (RMSE):", round(rmse, 3), "\n")

# ---- 4. R² (Coefficient of Determination) ----
r_squared <- cor(Qobs_valid, Qsim_valid)^2
cat("R-squared (R²):", round(r_squared, 3), "\n")


# ---- 9. Plot simulation results ----
plot(sim, plot.type = "ts")

# ---- 10. Check summary and structure ----
summary(sim)
str(sim)


# ---- 11. Save simulation results ----
df_full$Qsim <- sim$OutputsModel$Qsim
write.csv(df_full, "Mahaweli_GR4J_simulated_results.csv", row.names = FALSE)



