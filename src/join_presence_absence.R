ignore <- suppressPackageStartupMessages({
  library(dplyr)
  source("functions/balance_presence_absence.R")
})

presence_absence_files <- list(
    train_crianza = list(
        presence = "train_crianza.csv",
        absence = "absence_train_crianza.csv"
    ),
    test_crianza = list(
        presence = "test_crianza.csv",
        absence = "absence_test_crianza.csv"
    ),
    train_empollamiento = list(
        presence = "train_empollamiento.csv",
        absence = "absence_train_empollamiento.csv"
    ),
    test_empollamiento = list(
        presence = "test_empollamiento.csv",
        absence = "absence_test_empollamiento.csv"
    ),
    train_incubacion = list(
        presence = "train_incubacion.csv",
        absence = "absence_train_incubacion.csv"
    ),
    test_incubacion = list(
        presence = "test_incubacion.csv",
        absence = "absence_test_incubacion.csv"
    )
)

args <- commandArgs(trailingOnly = TRUE)
n_vars <- as.numeric(args[1])
dirs <- get_data_directories(n_vars)

absence_dir <- dirs$absence_dir
presence_dir <- dirs$presence_dir
out_dir <- paste0("presence_absence_", n_vars, "vars/")

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

for (name in names(presence_absence_files)) {
  presence_data <- read.csv(paste0(presence_dir, "/", presence_absence_files[[name]]$presence))
  absence_data <- read.csv(paste0(absence_dir, "/", presence_absence_files[[name]]$absence))
  out_file <- paste0(out_dir, name, ".csv")
  balanced_dataset <- balance_data_by_month_year(presence_data, absence_data, sample_ratio = 1.5)
  write.csv(balanced_dataset, out_file, row.names = FALSE)
  cat("Archivo balanceado creado:", out_file, "\n")
}
