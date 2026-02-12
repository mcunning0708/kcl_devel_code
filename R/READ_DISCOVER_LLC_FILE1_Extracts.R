#' Script for READING DISCOVERING LLC FILE1 csv data files
#' MARK CUNNINGHAM
#' 14 January 2026
#' Last updated / Processed : 28 January 2026

# install.packages("tidyverse")
# install.packages("GGIR", dependencies = TRUE)
#' install.packages("")

{
  library(tidyverse)
  library(lubridate)
  library(DBI)

}

#' Previous/Latest LLC Data
{
  dir_root <- "C:\\Users\\k2585744\\King's College London\\BioResource R Data - Data"
  dir_llc <- "LLC\\File 1"
  # dir_root <- "//wsl.localhost/Ubuntu/home/k2585744/projects_wsl"
  # PREVIOUS Datafile
  dir_data <- file.path(dir_root, dir_llc, "2025")
  setwd(dir_data)
  list.files(path = dir_data )
  (file_Read <- file.path( dir_data, "GLAD_FILE1_v6_20250424.csv" ) )
  df_0_file1_prev_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_file1_prev_data )
  df_0_file1_prev_data %>%  glimpse()
  df_1_EDGI_prev_data <- df_0_file1_prev_data %>% filter( grepl("EDGI", STUDY_ID ))
  df_1_GLAD_prev_data <- df_0_file1_prev_data %>% filter( grepl("GLAD", STUDY_ID ))

  # LATEST Datafile
  dir_data <- file.path(dir_root, dir_llc, "2026")
  setwd(dir_data)
  list.files(path = dir_data )
  (file_Read <- file.path( dir_data, "GLAD_FILE1_v7_20260127.csv" ) )
  df_0_file1_prepared_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_file1_prepared_data )
  df_0_file1_prepared_data %>%  glimpse()
  df_1_EDGI_prepared_data <- df_0_file1_prepared_data %>% filter( grepl("EDGI", STUDY_ID ))
  df_1_GLAD_prepared_data <- df_0_file1_prepared_data %>% filter( grepl("GLAD", STUDY_ID ))
}

# Database connection details
{
  host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
  port <- 25060
  user <- "kcl_sgdp_readonly"
  dbname <- "mhbior"  # The actual DB name
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path) )
  source(file = "credentials/paths.R")  #
  password1 <- substr(password, 6, nchar(password))
}

#' Latest Data for LLC File1 submission of identifiable data (file1))
{
  # Create a connection
  con <- DBI::dbConnect(RMySQL::MySQL(),
                   host = host,
                   port = port,
                   user = user,
                   password = password1,
                   dbname = dbname)

  query_llc_file1 <- "SELECT distinct * from v_LLC_file1_return"
  df_0_file1_latest_data_sample <- dbGetQuery(con, paste(query_llc_file1, "LIMIT 20"))
  df_0_file1_latest_data <- dbGetQuery(con, query_llc_file1)
  # df_0_edgi_cpms <- dbGetQuery(con, query_edgi_cpms)

  # Close the connection UNLESS you need get more data
  DBI::dbDisconnect(con) # DONE 28/01/2026
}

#' CLEANUP according to file
#' https://emckclac-my.sharepoint.com/:b:/r/personal/k2585744_kcl_ac_uk/Documents/
#' Documents/KCL_Documentation/DOC-DAT-044_UK%20LLC_LPSFileFormattingGuidance_V3.0.pdf?csf=1&web=1&e=AhzdmK
{
  # 1. if NHS # contains spaces delete them
  df_1_file1_latest_data <- df_0_file1_latest_data %>%
    # RECORD the MHBIOR NHS_NUMBER - to be dropped b4 writing file
    mutate(mhbior_nhs_number = NHS_NUMBER) %>%
    mutate(NHS_NUMBER = str_replace_all(NHS_NUMBER, "\\s+", ""))

  # 2. POSTCODE should only be format 4&3, 3&3 or 2&3
  df_1_file1_latest_data <- df_1_file1_latest_data %>%
    mutate(
      postcode_clean = str_to_upper(POSTCODE),
      postcode_clean = str_replace_all(postcode_clean, "\\s+", "")
      ) %>%
    mutate(
      valid = str_detect(postcode_clean, "^([A-Z]{1,2}[0-9][0-9A-Z]?)([0-9][A-Z]{2})$"),
      postcode_std = if_else(
        valid,
        str_replace(postcode_clean,
                    "^([A-Z]{1,2}[0-9][0-9A-Z]?)([0-9][A-Z]{2})$",
                    "\\1 \\2"),
        NA_character_  # or keep original if you prefer
      )
    ) %>%
    mutate( mhbior_postcode = POSTCODE,
            POSTCODE = postcode_std)


  dfCheck <- df_1_file1_latest_data %>% filter(mhbior_postcode != postcode_std ) %>%
    select(STUDY_ID, mhbior_postcode, POSTCODE, postcode_clean, postcode_std )

  # 3. DATES should be in the format DD/MM/YYYY only
  df_1_file1_latest_data <- df_1_file1_latest_data %>%
    mutate(DATE_OF_BIRTH = as.character(format(ymd(DATE_OF_BIRTH), "%d/%m/%Y")) ) %>%
    mutate(CREATE_DATE = as.character(format(ymd_hms(CREATE_DATE), "%d/%m/%Y")) )
    # mutate(datetime = format(ymd_hms(datetime), "%d/%m/%Y")) %>%
    # mutate(datetime = format(ymd_hms(datetime), "%d/%m/%Y"))

  # 3a. DROP the WORKING columns added above (all have lower_case names)
  df_2_file1_latest_data <- df_1_file1_latest_data %>%
    # select( -mhbior_nhs_number, -mhbior_postcode, -postcode_clean, -postcode_std, -valid )
    # below BETTER tidyverse uses !
    select( !c(mhbior_nhs_number, mhbior_postcode, postcode_clean, postcode_std, valid) )
}
#'
{
  ( dir_data <- file.path(dir_root, dir_llc, "2026") )
  setwd(dir_data)
  list.files(path = dir_data )

  ( dir_write <- file.path(dir_root, dir_llc, "2026") )
  list.files(path = dir_write)
  # EXPORT File
  (fileWrite <- file.path(dir_write,
                          paste("GLAD_FILE1_v7", format(Sys.time(), "%Y%m%d"), sep = "_")))
  (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
  write_csv( df_2_file1_latest_data, WriteTxtFile )
  list.files(path = dir_data )
}
#'
#' **************************************
#' TEST submission files ...
  n_distinct(df_0_file1_prev_data$STUDY_ID) # 83,706 for v6 file
  df_0_file1_prev_data %>% distinct(ROW_STATUS) # ALL == C
  # current file
  n_distinct(df_2_file1_latest_data$STUDY_ID) # 90,083
  df_4_duplicates <- df_2_file1_latest_data %>%
    dplyr::group_by( STUDY_ID ) %>%
    dplyr::summarise( n_rows = n() ) %>%
    dplyr::filter (n_rows > 1) # SHOULD BE ==0 and is

  df_2_file1_latest_data %>%  filter(UKLLC_STATUS == 1) %>%
    count() # 90,079

  df1 <- df_2_file1_latest_data %>%
    filter(
        NHS_E_Linkage_Permission == "0" & NHS_S_Linkage_Permission == "0" &
        NHS_W_Linkage_Permission == "0" & NHS_NI_Linkage_Permission == "0"  )
  # investigate couple of these
  # EDGI000229 / GLAD032679 , GLAD148354 / EDGI048572
  dfcheck1 <- df_0_file1_latest_data %>% filter (STUDY_ID %in% c("GLAD148354", "EDGI048572") )
  dfcheck2 <- df_0_file1_latest_data %>% filter (STUDY_ID %in% c("GLAD032679", "EDGI000229") )
  dfg_check <- df_0_file1_latest_data %>% filter (STUDY_ID == "GLAD148354")
  dfe_check <- df_0_file1_latest_data %>% filter (STUDY_ID == "EDGI000229")
#' **************************************

{
  # LATEST Datafiles
  dir_data <- file.path(dir_root, dir_llc, "2026")
  setwd(dir_data)
  list.files(path = dir_data )
  (file_Read <- file.path( dir_data, "GLAD_FILE1_v7_20260114.csv" ) )
  df_0_file1_current_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_file1_current_data )
  df_0_file1_current_data %>% glimpse()

  # partial datasets created by  LLC_file1_mhbior_EDGI.sql &LLC_file1_mhbior_GLAD.sql
  (file_Read <- file.path( dir_data, "LLC_file1_mhbior_GLAD_2026_01_14.csv" ) )
  df_0_LLC_file1_GLAD_current_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_LLC_file1_GLAD_current_data )
  df_0_LLC_file1_GLAD_current_data %>% glimpse()

  (file_Read <- file.path( dir_data, "LLC_file1_mhbior_EDGI_2026_01_14.csv" ) )
  df_0_LLC_file1_EDGI_current_data <- readr::read_csv( file_Read ) # if CSV
  dim( df_0_LLC_file1_EDGI_current_data )
  df_0_LLC_file1_EDGI_current_data %>% glimpse()

  setdiff( colnames(df_0_file1_prev_data), colnames(df_0_file1_current_data) )
  setwd(dir_data)
  list.files()

  # GLAD Data
  (file_Read <- file.path( dir_data, "LLC_file1_mhbior_GLAD_2026_01_14.csv" ) )
  df_0_file1_GLAD_current_data <- readr::read_csv( file_Read ) # if CSV
  # update the CREATE_DATE value to today
  df_0_file1_GLAD_current_data$CREATE_DATE <- format( Sys.time(), "%d/%m/%Y")
  dim( df_0_file1_GLAD_current_data )
  df_0_file1_GLAD_current_data %>% glimpse()

  # EDGI Data
  (file_Read <- file.path( dir_data, "LLC_file1_mhbior_EDGI_2026_01_14.csv" ) )
  df_0_file1_EDGI_current_data <- readr::read_csv( file_Read ) # if CSV
  # update the CREATE_DATE value to today
  df_0_file1_EDGI_current_data$CREATE_DATE <- format( Sys.time(), "%d/%m/%Y")
  dim( df_0_file1_EDGI_current_data )
  df_0_file1_EDGI_current_data %>% glimpse()

  setdiff( colnames(df_0_file1_EDGI_current_data), colnames(df_0_file1_GLAD_current_data) )
  #' should be NO difference ?

  # MERGE the 2 files above
  df_1_LLC_file1_current_data <- df_0_file1_GLAD_current_data %>%
    bind_rows(df_0_file1_EDGI_current_data)

  # how many distinct STUDY_IDs
   n_distinct(df_1_LLC_file1_current_data$STUDY_ID )

   df_1_LLC_duplicates <- df_1_LLC_file1_current_data %>%
     group_by( STUDY_ID ) %>%
     filter(n() > 1 ) %>%
     ungroup

   bind_r
}


# Define limits for variable and list reasoning below
# Variable name:
#   - Upper:
#   - Lower:
#   ```{r Date vars define limits}
variables_date <- c(
  "ADDRESS_START_DATE", "ADDRESS_END_DATE", "DATE_OF_BIRTH", "CREATE_DATE"
)

df_2_LLC_file1_current_data <- df_1_LLC_file1_current_data %>%
  mutate(across(all_of(variables_date), ~ as.Date(., format = "%d/%m/%Y")))

upper_limit <- as.POSIXct("2025-12-31")
lower_limit <- as.POSIXct("1960-01-01")
# ```
# Recode variable outliers to NA
# ```{r Date vars recode outliers to NA}
df_3_LLC_file1_current_data <- df_2_LLC_file1_current_data %>%
  mutate(across(all_of(variables_date),
                ~ifelse(. > upper_limit | # bigger than the upper limit
                          . < lower_limit, # smaller than the lower limit
                        yes = NA_real_,
                        no = .)
  )
  ) %>%
  mutate(across(all_of(variables_date),
                ~as.POSIXct(.,
                            origin = lubridate::origin)
  ))

df_4_LLC_file1_current_data <- df_3_LLC_file1_current_data %>%
  filter ( !grepl("AB1 2CD|X12 3YZ", POSTCODE)) %>%
  filter ( !grepl( "withdrawal", str_to_upper(FORENAME ) ))


#' **********************************************************
#'

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
