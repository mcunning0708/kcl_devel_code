




# Install required packages if not already installed
# install.packages("DBI")
# install.packages("RMySQL")
{
library(DBI)
library(RMySQL)
#' where would i be without tidyverse ?
#' includes lubridate:: stringr:: readr::
library(tidyverse)
#' for the Mail Merge
library(blastula)
}
sessionInfo()

# Database connection details
host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
port <- 25060
user <- "kcl_sgdp_readonly"


# Prompt user for input
answer <- readline(prompt = "Do you want to run Prompt for DB password(Y) or Read (N): ")
# Check response and run appropriate block
if (toupper(answer) == "Y") {
  # Prompt for a value of DB password
  cat("PROMPTING FOR pwd ON Enter in Console...\n")
  (password <- readline(prompt = "What is DB password for 'kcl_sgdp_readonly' ? "))
} else {
  # Get the path of the current script and set working directory
  cat("USING Credentials file...\n")
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  source(file = "credentials/paths.R")  # 
  password1 <- substr(password, 6, nchar(password))
}
``
dbname <- "mhbior"  # The actual DB name

# Create a connection
con <- dbConnect(RMySQL::MySQL(),
                 host = host,
                 port = port,
                 user = user,
                 password = password,
                 dbname = dbname)

# Query: Select top 10 rows from view v_temp
query_participants_sample <- "SELECT * FROM v_active_participants_reminders LIMIT 15;"
query_communications_sample <- "SELECT * FROM v_communications_reminders LIMIT 100;"

query_participants <- "SELECT * FROM v_active_participants_reminders;"
query_communications <- "SELECT * FROM v_communications_reminders;"


# Fetch data into a dataframe
df_0_sample1 <- dbGetQuery(con, query_participants_sample)
df_0_sample2 <- dbGetQuery(con, query_communications_sample)

#' THESE next 2 statements WILL Take a CONSIDERABLE time to run
#' EXERCISE Extreme Caution re WHEN u run them ....
#'
df_0_participants <- dbGetQuery(con, query_participants)
# 139,067 on 9 Dec 2025
# 139,149 on 10 Dec 2025
# 139,451 on 17 Dec 2025
# 162,115 on 15 Jan 2026
df_1_participants <- df_0_participants %>%
  mutate(dt_created_at = as.Date(created_at, format = "%Y-%m-%d" ) ) %>%
  mutate(dt_registered_at = as.Date(registered_at, format = "%Y-%m-%d" ) ) %>%
  mutate(dt_consented_at = as.Date(consented_at, format = "%Y-%m-%d" ) ) %>%
  mutate(dt_date_kit_sent = as.Date(date_kit_sent, format = "%Y-%m-%d" ) ) %>%
  mutate(dt_date_kit_sent = as.Date(date_kit_sent, format = "%Y-%m-%d" ) )

df_0_Communications <- dbGetQuery(con, query_communications)
# 425,465 on 9 Dec 2025
# 426,531 on 17 Dec 2025
# 427,151 on 15 Jan 2026

# Print the dataframe
# print(df1)

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

}

fnWriteExportImportReminderFiles <- function( ps_reminder, pdf_to_write ){
  #' EDGI File

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
                            paste("TEST_MBC_REMINDER_export_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_EDGI_ppts %>%
                 select(participant_id = id,
                        forename = ppt_forename,
                        email = ppt_email,
                        registration_date = dt_registered_at
                        # reminder = "registration_reminder_1",
                        # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
                 ), WriteTxtFile )
    # IMPORT File
    (fileWrite <- file.path(dir_write,
                            paste("TEST_MBC_REMINDER_import_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_EDGI_ppts %>%
                 select(participant_id = id) %>%
                  mutate(study_id = 2,
                        contact_method = "Email",
                        type = reminder_type,
                        sample_barcode = "",
                        number = as.integer( sub(".*([0-9])$", "\\1", ps_reminder) ),
                        sent_at = as.Date(Sys.time())
                 ), WriteTxtFile )


  #' GLAD File
  ( dir_write <- file.path(dir_root, dir_glad, dir_tail) )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("TEST_MBC_REMINDER_export_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_GLAD_ppts %>%
                 select(participant_id = id,
                        forename = ppt_forename,
                        email = ppt_email,
                        registration_date = dt_registered_at
                        # reminder = "registration_reminder_1",
                        # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
                 ), WriteTxtFile )
    # IMPORT FILE
    (fileWrite <- file.path(dir_write,
                            paste("TEST_MBC_REMINDER_import_", as.Date(Sys.time()), sep = "")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( df_GLAD_ppts %>%
                 select(participant_id = id) %>%
                 mutate(study_id = 1,
                        contact_method = "Email",
                        type = reminder_type,
                        sample_barcode = "",
                        number = as.integer( sub(".*([0-9])$", "\\1", ps_reminder) ),
                        sent_at = as.Date(Sys.time())
                 ), WriteTxtFile )


  # x <- "example123"
  # result <- sub("[0-9]$", "", x)
  # last_digit <- sub(".*([0-9])$", "\\1", x)
}

# Registration 1 - Make a Difference
{
  # 1.
  #' remove all those sent ANY reminders
  #'
  ( v_reminder_types <- df_0_Communications %>% distinct(type) %>% pull(type) )
  # identify ALL ppts who HAVE veen sent a reminder to date
  df_1_ppts_reminders_sent <- df_0_Communications %>%
    filter( type %in% v_reminder_types ) %>%
    distinct( id, type ) %>%
    arrange( type )

  df_1_reg1_ppts <- df_1_participants %>%
    # only want those who have NOT consented
    filter( is.na(dt_consented_at ) ) %>%
    # those who have NOT received ANY reminders
    anti_join( df_1_ppts_reminders_sent, by = "id" ) %>%
    # DOES NOT WORK filter( !( id %in% df_1_ppts_reminders_sent )) %>%
    # exclude those registered in past 14 days
    filter ( !( Sys.Date() - dt_registered_at ) < 7 ) %>%
    # exclude those registered before the LAST set of reminders sent
    # ??? 36 or 21 days appropriate ?
     filter ( !( Sys.Date() - dt_registered_at ) > 182 ) %>%
    distinct( id, ppt_forename,  ppt_email, dt_registered_at, Aliases, study_name, dt_registered_at, dt_consented_at, export_eligibility_state, manual_eligibility_state ) %>%
    arrange( id )


  # Count unique values in column 'id'
  ( n_unique <- df_1_reg1_ppts %>%
      summarise(unique_count = n_distinct(id )) )

  #'
  {
    df_1_reg1_EDGI_ppts <- df_1_reg1_ppts %>%
      filter( study_name == "EDGI UK" )
    ( n_unique_EDGI <- df_1_reg1_EDGI_ppts %>% summarise(unique_count = n_distinct(id )) )
    df_1_reg1_GLAD_ppts <- df_1_reg1_ppts %>%
      filter( study_name == "GLAD" )
    ( n_unique_GLAD <- df_1_reg1_GLAD_ppts %>% summarise(unique_count = n_distinct(id )) )
  }
  #'
  #'fnWriteExportImportReminderFiles( "Reg1", df_1_reg1_ppts )


}

# Registration 2 - Make Your Contribution Count
{
  #' identify those who have already received reminders for after this
  #' "Sample Reminder"       "Consent Reminder"      "Sample Received"
  #' OR "registration Reminder" #'s 2 or 3
  #' NB ***
  #' *** OR those who have JUST received RegReminder#1
  #' THIS requires CAREFUL implementation / phasing !
  #' if we do NOT update df_0_Communications in meantime we CAN exclude those who have just
  #' been put in cohorts above !!!!!
  #' ***
  #'
  df_1_reg2_ppts_to_exclude <- df_0_Communications %>%
    filter( ( type %in% c("Sample Reminder", "Consent Reminder", "Sample Received" ) )
            |
              ( type %in% c("Registration Reminder") & number %in% c (2, 3)) ) %>%
    # filter( id %in% df_1_reg1_ppts ) %>%
    distinct( id, type, number ) %>%
    arrange( type )

  ( v_types <- df_1_reg2_ppts_to_exclude %>% distinct( type, number ) %>% pull( type, number ) )
  # ( v_numbers <- df_1_reg2_ppts_to_exclude %>% distinct( number ) %>% pull( number ) )

  df_1_reg2_ppts <- df_1_participants %>%
    # only want those who have NOT consented
    filter( is.na(dt_consented_at ) ) %>%
    # those who have NOT received ANY OF ABOVE reminders
    anti_join( df_1_reg2_ppts_to_exclude, by = "id" ) %>%
    # DOES NOT WORK filter( !( id %in% df_1_reg2_ppts_to_exclude )) %>%
    # exclude those registered before the LAST set of reminders sent
    # ??? below appropriate here ???
    anti_join( df_1_reg1_ppts, by  = 'id') %>%
    # exclude those registered in past 14 days
    filter ( !( Sys.Date() - dt_registered_at ) < 15 ) %>%
    # ??? WHAT # days appropriate  - 36 or 21 days appropriate ?
    filter ( !( Sys.Date() - dt_registered_at ) > 100 ) %>%
    distinct( id, ppt_forename,  ppt_email, dt_registered_at, Aliases, study_name, dt_registered_at, dt_consented_at, export_eligibility_state, manual_eligibility_state ) %>%
    arrange( id )

  # ***
  # Count unique values in column 'id'
  ( n_unique <- df_1_reg2_ppts %>%
      summarise(unique_count = n_distinct(id )) )

  fnWriteExportImportReminderFiles( "Reg2", df_1_reg2_ppts )

  # ***
}

# Registration 3
{
  df_1_reg3_ppts_to_exclude <- df_0_Communications %>%
    filter( ( type %in% c("Sample Reminder", "Consent Reminder", "Sample Received" ) )
            |
              ( type %in% c("Registration Reminder") & number %in% c(3)) ) %>%
    # filter( id %in% df_1_reg1_ppts ) %>%
    distinct( id, type, number ) %>%
    arrange( type )

  ( v_types <- df_1_reg3_ppts_to_exclude %>% distinct( type, number ) %>% pull( type, number ) )

  df_1_reg3_ppts <- df_1_participants %>%
    # only want those who have NOT consented
    filter( is.na(dt_consented_at ) ) %>%
    # those who have NOT received ANY OF ABOVE reminders
    anti_join( df_1_reg3_ppts_to_exclude, by = "id" ) %>%
    # DOES NOT WORK filter( !( id %in% df_1_reg3_ppts_to_exclude )) %>%
    # exclude those registered before the LAST TWO sets of reminders sent
    # ??? below appropriate here ???
    anti_join( df_1_reg1_ppts, by  = 'id' ) %>%
    anti_join( df_1_reg2_ppts, by = 'id' ) %>%
    # exclude those registered in past 14 days
    filter ( !( Sys.Date() - dt_registered_at ) < 15 ) %>%
    # ??? WHAT # days appropriate  - 36 or 21 days appropriate ?
    filter ( !( Sys.Date() - dt_registered_at ) > 150 ) %>%
    distinct( id, ppt_forename,  ppt_email, dt_registered_at, Aliases, study_name, dt_registered_at, dt_consented_at, export_eligibility_state, manual_eligibility_state ) %>%
    arrange( id )
  # ??? NOT sure of above  - seems same asdf_1_reg2_ppts ... ???

  ### Write the files ...
  fnWriteExportImportReminderFiles( "Reg3", df_1_reg3_ppts )

}

# Consent 1
{
  #'
  #'
  df_1_cons1_ppts_to_exclude <- df_0_Communications %>%
    filter( ( type %in% c("Sample Reminder", "Sample Received", "Consent Reminder" ) ) ) %>%
            # |
              # ( type %in% c("Consent Reminder") & number %in% c (2, 3)) ) %>%
            #   ( type %in% c("Consent Reminder") ) %>%
    # filter( id %in% df_1_reg1_ppts ) %>%
    distinct( id, type, number ) %>%
    arrange( type )

  ( v_types <- df_1_cons1_ppts_to_exclude %>% distinct( type, number ) %>% pull( type, number ) )
  # ( v_numbers <- df_1_reg2_ppts_to_exclude %>% distinct( number ) %>% pull( number ) )

  df_1_cons1_ppts <- df_1_participants %>%
    filter( !( is.na(dt_consented_at) ) ) %>%
    # Have NOT finished Questionnaires
    filter(  is.na(export_eligibility_state ) & is.na( manual_eligibility_state )  ) %>%
    # those who have NOT received ANY OF ABOVE reminders
    anti_join( df_1_cons1_ppts_to_exclude, by = "id" ) %>%
    # filter( !( id %in% df_1_cons1_ppts_to_exclude )) %>%
    # filter( export_eligibility_state == 1 | manual_eligibility_state == 1 ) %>%
    ### remove anyone consented in last 2 weeks and BEFORE some PREV date tbd w LM 
    ### 
    distinct( id, ppt_forename,  ppt_email, dt_registered_at, Aliases, study_name, dt_registered_at, dt_consented_at, export_eligibility_state, manual_eligibility_state ) %>%
    arrange( id )

  max(df_1_cons1_ppts$id)
  min(df_1_cons1_ppts$id)

  df_1_cons1_EDGI_ppts <- df_1_cons1_ppts %>%
    filter( study_name == "EDGI UK" )
  df_1_cons1_GLAD_ppts <- df_1_cons1_ppts %>%
    filter( study_name == "GLAD" )  # try 7781 / 7704
  dfCheck <- df_0_Communications %>% filter( id == 119157 )
  dfCheck1 <- df_1_cons1_EDGI_ppts %>% filter( id == 30 )
  dfCheck <- df_0_Communications %>% filter( id == 7781 )
  dfCheck2 <- df_1_cons1_ppts_to_exclude %>% filter( id == 30 ) # should NOT be in ecause of line


}
