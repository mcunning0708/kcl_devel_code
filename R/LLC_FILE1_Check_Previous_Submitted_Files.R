#' Check A Previous LLC Data File submission
{
  dir_root <- "C:\\Users\\k2585744\\King's College London\\BioResource R Data - Data"
  dir_llc <- "LLC\\File 1"
  # dir_root <- "//wsl.localhost/Ubuntu/home/k2585744/projects_wsl"
  # PREVIOUS Datafile
  dir_data_to_check <- file.path(dir_root, dir_llc, "2023/February 2023")
  setwd(dir_data_to_check)
  list.files(path = dir_data_to_check )
  #
  # COPY one from Console below
  (file_Read <- file.path( dir_data_to_check, "GLAD_FILE1_v2_20230208.csv" ) )
  df_0_file1_check_prev_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_file1_check_prev_data )
  df_0_file1_check_prev_data %>%  glimpse()
  df_1_EDGI_check_data <- df_0_file1_check_prev_data %>% filter( grepl("EDGI", STUDY_ID ))
  df_1_GLAD_check_data <- df_0_file1_check_prev_data %>% filter( grepl("GLAD", STUDY_ID ))

  # how many rows with ROW_STATUS == "C
  dfcheck <- df_0_file1_check_prev_data %>% filter( ROW_STATUS != "C" )
  dfcheck <- df_0_file1_check_prev_data %>% filter( ROW_STATUS == "C" )
}
