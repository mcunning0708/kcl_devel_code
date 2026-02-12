# ---
# title: "See ../Documents/KCL_EMAILS/EDGI%20and%20GLAD%20consent%20version%20discrepancies%20in%20earlier%20recruits.msg?csf=1&web=1&e=J58i6R "
# author: "Mark Cunningham"
# date: "20/01/2026"
# output: html_document
# ---

#' got files from Carola  - read these & match to ALL ppts then get the
#' consent_date, consent_form_version / information_leaflet_version
#'




# Install required packages if not already installed
# install.packages("DBI")
# install.packages("RMySQL")
# install.packages("readxl")
{
library(DBI)
library(readxl)
library(RMySQL)
#' where would i be without tidyverse ?
#' includes lubridate:: stringr:: readr::
library(tidyverse)
#' for the Mail Merge
library(blastula)
}
sessionInfo()

# Database connection details
{
  host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
  port <- 25060
  user <- "kcl_sgdp_readonly"
  dbname <- "mhbior"  # The actual DB name  cat("USING Credentials file...\n")
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  source(file = "credentials/paths.R")  #
  password1 <- substr(password, 6, nchar(password))
}

# N : Prompt user for input
{
answer <- readline(prompt = "Do you want to run Prompt for DB password(Y) or Read (N): ")
# Check response and run appropriate block
  if (toupper(answer) == "Y") {
    # Prompt for a value of DB password
    # cat("PROMPTING FOR pwd ON Enter in Console...\n")
    (password <- readline(prompt = "What is DB password for 'kcl_sgdp_readonly' ? "))
  } else {
    # Get the path of the current script and set working directory
    cat("USING Credentials file...\n")
    setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
    source(file = "credentials/paths.R")  #
    password1 <- substr(password, 6, nchar(password))
  }
}


# Create a connection
con <- dbConnect(RMySQL::MySQL(),
                 host = host,
                 port = port,
                 user = user,
                 password = password1,
                 dbname = dbname)

# Query: Select top 10 rows from view v_temp
# query_participants_sample <- "SELECT * FROM v_active_participants_reminders LIMIT 15;"
# query_consent_form_info_sample <- "SELECT * FROM v_consent_forms_newsletter_response LIMIT 100;"
#
# query_participants <- "SELECT * FROM v_active_participants_reminders;"

query_consent_form_info <- "SELECT * FROM v_consent_forms_newsletter_response;"
# query_generic <- "
#   SELECT
#      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
#      ps.id, ps.first_name as forename, ps.email,
#      ps2.information_sheet_id, infs.version,
#      ps2.consented_at AS ps2_consent_date,
#      s.study_id, s.date_kit_received, ss.name
#    FROM participants ps
#      INNER JOIN consent_form_responses cfr
#      ON cfr.participant_id = ps.id
# 	   INNER JOIN participant_study ps2
#      ON ps2.participant_id = ps.id
#      INNER JOIN information_sheets infs
#      ON ( ps2.information_sheet_id = infs.id AND ps2.study_id = infs.study_id )
#      INNER JOIN studies ss
#      ON ss.id = ps2.study_id
#      LEFT JOIN samples s
#      ON ps.id = s.participant_id
#    WHERE
#      ps.account_type = 'Active'
#      AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
#      AND ps.email IS NOT NULL
#      AND LOWER(ps.email) not like '%obscured%'
#      AND ps.withdrew_at IS NULL
#      AND ps2.consented_at IS NOT NULL
#      -- AND s.date_kit_received IS NOT NULL
#      -- below indicates ppt HAS completed questionnaire ...
#      -- AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
#   "

query_generic <- "
  SELECT
     jt.alias_matched participant_id,
     ps.id, ps.first_name as forename, ps.email,
     ps2.information_sheet_id, infs.version,
     ps2.consented_at AS ps2_consent_date,
     ps2.study_id, ss.name
   FROM participants ps
		 CROSS JOIN JSON_TABLE( ps.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
     INNER JOIN consent_form_responses cfr
     ON cfr.participant_id = ps.id
	   INNER JOIN participant_study ps2
     ON ps2.participant_id = ps.id
     INNER JOIN information_sheets infs
     ON ( ps2.information_sheet_id = infs.id AND ps2.study_id = infs.study_id )
     INNER JOIN studies ss
     ON ss.id = ps2.study_id
   WHERE
		TRIM(jt.alias_matched) REGEXP '^(EDGI|GLAD)[0-9]{6}$'
		AND ps.account_type = 'Active'
     AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
     AND ps.email IS NOT NULL
     AND LOWER(ps.email) not like '%obscured%'
     AND ps.withdrew_at IS NULL
     AND ps2.consented_at IS NOT NULL
  "

# Fetch data into a dataframe
# df_0_sample1 <- dbGetQuery(con, query_participants_sample)
# df_0_sample2 <- dbGetQuery(con, query_consent_form_info_sample)

#' THESE next 2 statements WILL Take a CONSIDERABLE time to run
#' EXERCISE Extreme Caution re WHEN u run them ....
#'
# df_0_participants <- dbGetQuery(con, query_participants)
# 139,067 on 9 Dec 2025
# 139,149 on 10 Dec 2025
# 139,451 on 17 Dec 2025
# 162,115 on 15 Jan 2026
# 141,879 on 05 Feb 2026
# 142,166 on 11 Feb 2026
# df_1_participants <- df_0_participants %>%
#   mutate(dt_created_at = as.Date(created_at, format = "%Y-%m-%d" ) ) %>%
#   mutate(dt_registered_at = as.Date(registered_at, format = "%Y-%m-%d" ) ) %>%
#   mutate(dt_consented_at = as.Date(consented_at, format = "%Y-%m-%d" ) ) %>%
#   mutate(dt_date_kit_sent = as.Date(date_kit_sent, format = "%Y-%m-%d" ) ) %>%
#   mutate(dt_date_kit_sent = as.Date(date_kit_sent, format = "%Y-%m-%d" ) ) %>%
#   distinct()

df_0_participants_SQL_here <- dbGetQuery(con, query_generic)
# 96,314 on 6 Feb

df_0_MHBIOR_consent_form_info <- DBI::dbGetQuery(con, query_consent_form_info)
# 90,217 on 05 Feb 2026
# 90,378 on 11 Feb 2026

df_1_participants_SQL_here <- df_0_participants_SQL_here %>%
  dplyr::distinct()
# 90,858
df_1_MHBIOR_consent_form_info <- df_0_MHBIOR_consent_form_info %>%
  distinct()
# 89,828
#

# Print the dataframe
# print(df1)

# Close the connection UNLESS you need get more data
dbDisconnect(con) # DONE 05/02/2026

#' ***************************************************
#' Let's process the data for Reminders
#' REMEMBER to Choose the specific Study at the appropriate Stage
#'
{
  dir_root <- getwd()
  # move up one level
  dir_parent <- dirname(dir_root)
  dir_data <- file.path(dir_parent, "data/sensitive")
  list.files(path = dir_data)

}

#' IF Working with Carola's discrepancy files
{
  #' read discrepancy files into datasets
  file_to_read <- file.path(dir_data, "20250919_edgi_consent_version_discrepancies.xlsx" )
  df_0_edgi_discrepancies <- read_excel(file_to_read, sheet = "Sheet1")
  dim(df_0_edgi_discrepancies)
  df_0_edgi_discrepancies %>% dplyr::glimpse()

  file_to_read <- file.path(dir_data, "20250919_glad_consent_version_discrepancies.xlsx" )
  df_0_glad_discrepancies <- read_excel(file_to_read, sheet = "Sheet1")
  # View the first few rows
  dim(df_0_glad_discrepancies)
  df_0_glad_discrepancies %>% dplyr::glimpse()

  df_1_working_edgi <- df_0_edgi_discrepancies %>%
    dplyr::left_join( df_0_MHBIOR_consent_form_info, by = c( "cih_type_edgi_id" = "alias_matched" ) )
  df_2_working_edgi <- df_1_working_edgi %>%
    mutate(
      kcl_consent_date = as.Date(first_cfr_at ),
      kcl_consent_form = paste(substr(cih_type_edgi_id, 1,4 ), cf_version, " " )
    ) %>%
    select( cih_type_edgi_id,
            nbr_consent_date = consent_date,
            consent_version_maudsley, consent_version_orca,
            first_cfr_at,
            kcl_consent_date, kcl_consent_form
            )
  df2 <- df_2_working_edgi %>% filter((nbr_consent_date != kcl_consent_date ))

  df_1_working_glad <- df_0_glad_discrepancies %>%
    dplyr::left_join( df_0_MHBIOR_consent_form_info, by = c( "cih_type_glad_id" = "alias_matched" ) )
}
#'
#'
fnWriteFiles <- function( pdf_to_write ){
  # pdf_to_write <- df_2_participants_to_send

  #' NOW split into GLAD & EDGI
  # ( v_study_names <- pdf_to_write %>% distinct( study_name ) %>% pull( study_name ) )
  df_EDGI_ppts <- pdf_to_write %>%
    filter( study_id == 2)
  df_GLAD_ppts <- pdf_to_write %>%
    filter( study_id == 1)

  #' EDGI File
  ( dir_write <- dir_data )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("EDGI_ConsentForm_InfoSheet_versions_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_EDGI_ppts, WriteTxtFile )
    # IMPORT File

  #' GLAD File
  ( dir_write <- dir_data )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("GLAD_ConsentForm_InfoSheet_versions_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_GLAD_ppts, WriteTxtFile )

  # x <- "example123"
  # result <- sub("[0-9]$", "", x)
  # last_digit <- sub(".*([0-9])$", "\\1", x)
}

#' FOR Carola just send her my latestestimation of the latest consent form date
#' & consent form / information sheet versions
# df_1_participants_SQL_here <- df_0_participants_SQL_here %>%
#   mutate( info_sheet_version = version) %>%
#   select( participant_id, study_id, info_sheet_version ) %>%
#   distinct()
# # 90,228

df_2_participants_to_send <- df_1_participants_SQL_here %>%
  # JOIN to the consent form info data
  dplyr::inner_join( df_1_MHBIOR_consent_form_info,
                     by = c( "id" = "id",
                             "participant_id" = "alias_matched",
                             "study_id" = "study_id" ),
                     relationship = "many-to-many" ) %>%
  mutate(consent_form_version = cf_version,
         consent_date = as.Date(first_cfr_at),
         info_sheet_version = version) %>%
  select( id, participant_id, study_id, consent_date, consent_form_version, info_sheet_version ) %>%
  distinct()
# 89,304

fnWriteFiles( df_2_participants_to_send )


