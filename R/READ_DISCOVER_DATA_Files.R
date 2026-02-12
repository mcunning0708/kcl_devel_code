#' Script for READING DISCOVERING csv data files
#' MARK CUNNINGHAM
#' 02 January 2026
#' Last updated / Processed : 02 January 2026

# install.packages("tidyverse")
# install.packages("GGIR", dependencies = TRUE)
#' install.packages("")

{
  library(tidyverse)
  library(lubridate)
}

#' SET DIR parameters
{
  dir_root <- "//wsl.localhost/Ubuntu/home/k2585744/projects_wsl"
  dir_code <- file.path(dir_root, "R")
  setwd(dir_code)

  (dir_data <- file.path( dir_root, "data/sensitive"))
  # (dir_write <- file.path( dir_root, "Aggregate_Data"))
  # (dir_documentation <- file.path( dir_root, "Documentation"))

  setwd(dir_data)
  list.files()
}

#' Explore the file you are interested in .....
{
  # Prompt for a name of the file you want to read... COPY it from output of list.files
  (s_file <- readline(prompt = "WHAT is Name of File you want to read ? "))
  ( fileRead <- file.path( dir_data, s_file ))

  df_0_file_data <- read_csv( fileRead ) # if CSV
  # df_0_file_data <- read_tsv( fileRead ) # if TSV

  colnames(df_0_file_data )

  df_sample <- df_0_file_data[1:20, ]


  ( cols_to_check <- grep("(_increased|_decreased)$", colnames(df_0_file_data), value = TRUE) )
  print(cols_to_check)

}
