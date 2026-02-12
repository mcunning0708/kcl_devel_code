#' Script for ...
#' MARK CUNNINGHAM 
#' 31 October 2025
#' Last updated / Processed : 31 October 2025

# install.packages("tidyverse")
# install.packages("GGIR", dependencies = TRUE)
#'install.packages("")

{
  library(tidyverse)
  library(lubridate)
}

getwd()

{
  # dir_root <- "\\\\wsl.localhost\\Ubuntu\\home\\k2585744\\projects_wsl"
  dir_root <- "//wsl.localhost/Ubuntu/home/k2585744/projects_wsl"
  dir_data <- file.path(dir_root, "data/sensitive")
  list.files( dir_data )
}

( file_to_read <- file.path( dir_data,"BioResourceRR-ALLREDCapAWSParticip_DATA_2025-10-31_1014.csv" ))
if (file.exists( file_to_read )) {
  print(sprintf("Reading REDcap Data from file %s", file_to_read ))
  
  df_0_REDCap_data <- readr::read_tsv( file_to_read )
} 

( file_to_read <- file.path( dir_data,"MHBIOR_Exp_ParticipantExport-1761906372-30.csv" ))
if (file.exists( file_to_read )) {
  sprintf("Reading MHBIOR Data from file %s", file_to_read )
  # NB : THIS file is csv NOT tsv 
  df_0_MHBIOR_data <- readr::read_csv( file_to_read )
} 

df_1_REDCap_data <- df_0_REDCap_data %>% 
  dplyr::filter( stringr::str_detect(participant_id, "^EDGI[0-9]{6}$|^GLAD[0-9]{6}$" ) ) 


df_1_MHBIOR_data <- df_0_MHBIOR_data %>% 
  dplyr::rename( participant_id = `Participant id`, 
          national_bioresource_id = `National BioResource ID`, 
          nhs_id = `NHS ID`, 
          phone_number = `Phone number`, 
          email = `Email address`, 
          dob = `Date of birth`, 
          addr_1 = `Address line 1`, 
          addr_2 = `Address line 2`)


df_2_MHBIOR_data <- df_1_MHBIOR_data %>%
  tidyr::separate_rows(Aliases, sep = "\\|") %>% 
  dplyr::filter( stringr::str_detect(Aliases, "^EDGI[0-9]{6}$|^GLAD[0-9]{6}$" ) ) 

df_9_REDCap_not_on_MHBIOR <- df_1_REDCap_data %>% 
  # dplyr::inner_join( df_2_MHBIOR_data  )
  dplyr::anti_join(df_2_MHBIOR_data, by = c("participant_id" = "Aliases"))

(fileWrite <- file.path(dir_data, 
                        paste("REDCap_participants_NOT_ON_MHBIOR_", as.Date(Sys.time()), sep = "")))
(WriteTxtFile <- paste(fileWrite, "tsv", sep = "."))
write_tsv( df_9_REDCap_not_on_MHBIOR, WriteTxtFile )
