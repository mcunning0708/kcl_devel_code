#'
#' title: "SQL for GLAd & EDGI eligibility "
#' "\\wsl.localhost\Ubuntu\home\k2585744\projects_wsl\R\MHBIOR\eligibility_email_kit_on_way.R"
#' author: "Mark Cunningham"
#' created date: "23/01/2026"
#' LAST run : 05/02/2026 USING Date 04/02/2026
#' output: csv_file

# Install required packages if not already installed
# install.packages("DBI")
# install.packages("RMySQL")
{
  library(DBI)
  library(RMySQL)
  #' where would i be without tidyverse ?
  #' includes lubridate:: stringr:: readr::
  library(tidyverse)
  # if Mail Merge required
  library(blastula)
}
sessionInfo()

# Database connection details
{
  host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
  port <- 25060
  user <- "kcl_sgdp_readonly"
  dbname <- "mhbior"  # The actual DB name
  cat("USING Credentials file...\n")
  setwd(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)) )
  source(file = "credentials/paths.R")  #
  password1 <- substr(password, 6, nchar(password))

}

# N: NO NEED to Prompt user for input
{
  answer <- readline(prompt = "Do you want to run Prompt for DB password(Y) or Read (N): ")
  # Check response and run appropriate block
  if (toupper(answer) == "Y") {
    # Prompt for a value of DB password
    cat("PROMPTING FOR pwd ON Enter in Console...\n")
    (password <- readline(prompt = "What is DB password for 'kcl_sgdp_readonly' ? "))
  } else {
    # Get the path of the current script and set working directory
    cat("USING Credentials file...\n")
    setwd(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)) )
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

# Query: Select sample top 15 rows from tables
# (participants ps, samples s, participant_study ps2, studies ss)
query_edgi_eligibility <- "SELECT
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
      barcode,
      -- ps2.study_id,
      ss.name study_name,
      s.date_kit_sent,
      ps.email,
      ps.first_name as forename

      FROM participants ps, samples s, participant_study ps2, studies ss
      WHERE ps.id = s.participant_id
      AND ps2.participant_id = ps.id
      AND ss.id = ps2.study_id
      AND ss.name = 'EDGI UK'
      AND s.study_id = 2
      AND ps.withdrew_at IS NULL
      AND date_kit_sent = '2026-01-22'
      "

query_glad_eligibility <- "SELECT
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
      barcode,
      -- ps2.study_id,
      ss.name study_name,
      s.date_kit_sent,
      ps.email,
      ps.first_name as forename
      FROM participants ps, samples s, participant_study ps2, studies ss
      WHERE ps.id = s.participant_id
      AND ps2.participant_id = ps.id
      AND ss.id = ps2.study_id
      AND ss.name = 'GLAD'
      AND s.study_id = 1
      AND ps.withdrew_at IS NULL
      AND date_kit_sent = '2026-01-22'
      "

query_eligibility <- "SELECT
      ps.ID as id,
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
      barcode,
      ps2.study_id,
      ss.name study_name,
      s.date_kit_sent as relevant_date,
      ps.email as ppt_email,
      ps.first_name as ppt_forename
      FROM participants ps, samples s, participant_study ps2, studies ss
      WHERE ps.id = s.participant_id
      AND ps2.participant_id = ps.id
      AND ss.id = ps2.study_id
      AND ps.withdrew_at IS NULL
      AND date_kit_sent = '2026-02-04'
      "

# Fetch data into a dataframe
df_0_sample1 <- dbGetQuery(con, paste(query_edgi_eligibility, "LIMIT 20"))
df_0_sample2 <- dbGetQuery(con, paste(query_glad_eligibility, "LIMIT 20"))

#' THESE next 2 statements MAY Take a CONSIDERABLE time to run
#' EXERCISE Extreme Caution re WHEN u run them ....
#'
df_0_edgi_eligibility <- dbGetQuery(con, query_edgi_eligibility)
df_0_glad_eligibility <- dbGetQuery(con, query_glad_eligibility)
df_0_eligibility <- dbGetQuery(con, query_eligibility)

# Close the connection UNLESS you need get more data
dbDisconnect(con) # DONE 27/11/2025

#' ***************************************************
#' Let's process the data for Reminders
#' REMEMBER to Choose the specific Study at the appropriate Stage
#'
{
  dir_root <- "C:\\Users\\k2585744\\King's College London"
  dir_edgi <- "BioResource R Data - Eating Disorders Genetics Initiative\\Reminders"
  dir_glad <- "BioResource R Data - Genetic Links to Anxiety and Depression\\Reminders"
  dir_reg1 <- "Registration Reminders\\Make a difference today! (Two weeks)\\Contact lists"
  dir_reg2 <- "Registration Reminders\\Make your contribution count (Five weeks)\\Contact lists"
  dir_reg3 <- "Registration Reminders\\Youre on your way! (10 weeks)\\Contact lists"
  dir_cons1 <- "Consent and Survey Reminders\\Youre half way there! (Two weeks)\\Contact lists"
  dir_cons2 <- "Consent and Survey Reminders\\Your questionnaire is waiting for you (Four weeks)\\Contact lists"
  dir_cons3 <- "Consent and Survey Reminders\\Six week text_Your contribution\\Contact lists"
  dir_cons4 <- "Consent and Survey Reminders\\Dont forget us! (Ten weeks)\\Contact lists"
  dir_saliva1 <- "Saliva Kit\\Day kit sent Your kit is on its way! (The day kit sent)"

}

fnWriteExportImportReminderFiles <- function( ps_reminder, pdf_to_write ){
  #' DEBUG
  ps_reminder <- "Saliva1"
  pdf_to_write <- df_0_eligibility

  dir_tail = case_when(
    ps_reminder == "Reg1" ~ dir_reg1,
    ps_reminder == "Reg2" ~ dir_reg2,
    ps_reminder == "Reg3" ~ dir_reg3,
    ps_reminder == "Cons1" ~ dir_cons1,
    ps_reminder == "Cons2" ~ dir_cons1,
    ps_reminder == "Cons3" ~ dir_cons1,
    ps_reminder == "Cons4" ~ dir_cons1,
    ps_reminder == "Sam1" ~ "NA",
    ps_reminder == "Sam2" ~ "NA",
    ps_reminder == "Saliva1" ~ dir_saliva1,
    TRUE ~ "Other"
  )

  reminder_type = case_when(
    ps_reminder == "Reg1" ~ "Registration Reminder",
    ps_reminder == "Reg2" ~ "Registration Reminder",
    ps_reminder == "Reg3" ~ "Registration Reminder",
    ps_reminder == "Cons1" ~ "Consent Reminder",
    ps_reminder == "Cons2" ~ "Consent Reminder",
    ps_reminder == "Cons3" ~ "Consent Reminder",
    ps_reminder == "Cons4" ~ "Consent Reminder",
    ps_reminder == "Sam1" ~ "Sample Reminder",
    ps_reminder == "Sam2" ~ "Sample Reminder",
    ps_reminder == "Saliva1" ~ "Saliva Sent Reminder",
    TRUE ~ "Other"
  )

  #' NOW split into GLAD & EDGI
  ( v_study_names <- pdf_to_write %>% distinct( study_name ) %>% pull( study_name ) )
  df_EDGI_ppts <- pdf_to_write %>%
    filter( study_name == "EDGI UK")
  df_GLAD_ppts <- pdf_to_write %>%
    filter( study_name == "GLAD")

  #' EDGI File
  ( dir_write <- file.path(dir_root, dir_edgi, dir_tail) )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("MBC_export_saliva_kit_on_its_way_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_EDGI_ppts %>%
                 select(aliases, barcode, study_name,
                        date_kit_sent = relevant_date,
                        email = ppt_email,
                        forename = ppt_forename
                        # reminder = "registration_reminder_1",
                        # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
                 ), WriteTxtFile )
    # IMPORT File
    # (fileWrite <- file.path(dir_write,
    #                         paste("TEST_MBC_REMINDER_import_", as.Date(Sys.time()), sep = "")))
    # (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    # write_csv( df_EDGI_ppts %>%
    #              select(participant_id = id) %>%
    #               mutate(study_id = 2,
    #                     contact_method = "Email",
    #                     type = reminder_type,
    #                     sample_barcode = "",
    #                     number = as.integer( sub(".*([0-9])$", "\\1", ps_reminder) ),
    #                     sent_at = as.Date(Sys.time())
    #              ), WriteTxtFile )


  #' GLAD File
  ( dir_write <- file.path(dir_root, dir_glad, dir_tail) )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("MBC_export_saliva_kit_on_its_way_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_GLAD_ppts %>%
                 select(aliases, barcode, study_name,
                        date_kit_sent = relevant_date,
                        email = ppt_email,
                        forename = ppt_forename
                        # reminder = "registration_reminder_1",
                        # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
                 ), WriteTxtFile )
    # IMPORT FILE
    # (fileWrite <- file.path(dir_write,
    #                         paste("TEST_MBC_REMINDER_import_", as.Date(Sys.time()), sep = "")))
    # (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    # write_csv( df_GLAD_ppts %>%
    #              select(participant_id = id) %>%
    #              mutate(study_id = 1,
    #                     contact_method = "Email",
    #                     type = reminder_type,
    #                     sample_barcode = "",
    #                     number = as.integer( sub(".*([0-9])$", "\\1", ps_reminder) ),
    #                     sent_at = as.Date(Sys.time())
    #              ), WriteTxtFile )


  # x <- "example123"
  # result <- sub("[0-9]$", "", x)
  # last_digit <- sub(".*([0-9])$", "\\1", x)
}

# Saliva 1 : Kit is on way .....
{
  # 1.
  #'

  #'
  fnWriteExportImportReminderFiles( "Saliva1", df_0_eligibility )


}

