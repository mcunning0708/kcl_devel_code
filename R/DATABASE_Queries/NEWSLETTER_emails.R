#'
#' title: "SQL for GLAd & EDGI NEWSLETTER emails "
#' "\\wsl.localhost\Ubuntu\home\k2585744\projects_wsl\R\DATABASE_Queries\..NEWSLETTER_emails.R"
#' author: "Mark Cunningham"
#' created date: "06/02/2026"
#' output: csv_file

# Install required packages if not already installed
# install.packages("DBI")
# install.packages("RMySQL")
{
  #' DBI is the one i use here
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

# N: Prompt user for input
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

#' DATABASE Query
{
  # Create a connection
  con <- dbConnect(RMySQL::MySQL(),
                   host = host,
                   port = port,
                   user = user,
                   password = password1,
                   dbname = dbname)

  # Query: Select sample top 15 rows from tables
  # (participants ps, samples s, participant_study ps2, studies ss)
  # query_HAS_returned_kit <- "
  #  select
  #  JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
  #  ps.id,
  #  ps.first_name as forename,
  #  ps.email,
  #  s.study_id,
  #  s.date_kit_received,
  #  ss.name
  #  FROM participants ps, samples s, participant_study ps2, studies ss
  #  WHERE ps.id = s.participant_id
  #  AND ps2.participant_id = ps.id
  #  AND account_type = 'Active'
  #  AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
  #  AND LOWER(ps.email) not like '%obscured%'
  #  AND ps.withdrew_at IS NULL
  #  AND ps2.consented_at IS NOT NULL
  #  AND ps.email IS NOT NULL
  #  AND s.date_kit_received IS NOT NULL
  #  AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
  #       "
  #
  # query_has_NOT_returned_kit <- "
  #  select
  #  JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
  #  ps.id,
  #  ps.first_name as forename,
  #  ps.email,
  #  s.study_id,
  #  s.date_kit_received,
  #  ss.name
  #  FROM participants ps, samples s, participant_study ps2, studies ss
  #  WHERE ps.id = s.participant_id
  #  AND ps2.participant_id = ps.id
  #  AND account_type = 'Active'
  #  AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
  #  AND LOWER(ps.email) not like '%obscured%'
  #  AND ps.withdrew_at IS NULL
  #  AND ps2.consented_at IS NOT NULL
  #  AND ps.email IS NOT NULL
  #  AND s.date_kit_received IS NULL
  #       "

  query_generic <- "
  SELECT
     JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
     ps.id, ps.first_name as forename, ps.email,
     s.study_id, s.date_kit_sent, s.date_kit_received,
     ss.name
   FROM participants ps
     INNER JOIN consent_form_responses cfr
     ON cfr.participant_id = ps.id
	   INNER JOIN participant_study ps2
     ON ps2.participant_id = ps.id
     INNER JOIN studies ss
     ON ss.id = ps2.study_id
     LEFT JOIN samples s
     ON ps.id = s.participant_id
   WHERE
     ps.account_type = 'Active'
     AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
     AND ps.email IS NOT NULL
     AND LOWER(ps.email) not like '%obscured%'
     AND ps.withdrew_at IS NULL
     AND ps2.consented_at IS NOT NULL
     -- AND s.date_kit_received IS NOT NULL
     -- below indicates ppt HAS completed questionnaire ...
     -- AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
  "

  query_consent_form_newsletter_info <- "
  SELECT * FROM v_consent_forms_newsletter_response
  "

  # Fetch data into a dataframe
  # df_0_sample1 <- dbGetQuery(con, paste(query_HAS_returned_kit, "LIMIT 20"))
  # df_0_sample2 <- dbGetQuery(con, paste(query_has_NOT_returned_kit, "LIMIT 20"))
  df_0_sample <- dbGetQuery(con, paste(query_generic, "LIMIT 20"))
  df_0_sample_cf_newsletter <- dbGetQuery(con, paste(query_consent_form_newsletter_info, "LIMIT 200"))

  #' THESE next statements MAY Take a CONSIDERABLE time to run
  #' EXERCISE Extreme Caution re WHEN u run them ....
  # df_0_HAS_returned_kit <- dbGetQuery(con, query_HAS_returned_kit)
  # df_0_has_NOT_returned_kit <- dbGetQuery(con, query_has_NOT_returned_kit)
  df_0_generic <- DBI::dbGetQuery(con, query_generic)
  # 96,454 on 11 Feb 2026
  df_0_cf_newsletter_info <- DBI::dbGetQuery(con, query_consent_form_newsletter_info)
  # 90,349 on 11 feb 2026

  df_1_generic <- df_0_generic %>%
    dplyr::distinct()
  # 91,375
  df_1_cf_newsletter_info <- df_0_cf_newsletter_info %>%
    distinct()
  # 89,806

  # dim(df_0_HAS_returned_kit)
  # df_0_HAS_returned_kit %>% glimpse()
  # dim(df_0_has_NOT_returned_kit)
  # df_0_has_NOT_returned_kit %>% glimpse()
  dim(df_1_generic)
  df_1_generic %>% glimpse()
  dim(df_1_cf_newsletter_info)
  df_1_cf_newsletter_info %>% glimpse()

  # SQL report listing all participants who have not ticked the newsletter item on the consent form

  # Close the connection UNLESS you need get more data
  dbDisconnect(con) # DONE 11/02/2026
}
#' ***************************************************
#' Let's process the data for Reminders
#' REMEMBER to Choose the specific Study at the appropriate Stage
#'
{
  dir_root <- "C:\\Users\\k2585744\\King's College London"
  dir_edgi <- "BioResource R Data - Eating Disorders Genetics Initiative"
  dir_glad <- "BioResource R Data - Genetic Links to Anxiety and Depression"
  dir_newsletter <- "Newsletter/February_2026/contact_list"

  dir_reg1 <- "Registration Reminders\\Make a difference today! (Two weeks)\\Contact lists"
  dir_reg2 <- "Registration Reminders\\Make your contribution count (Five weeks)\\Contact lists"
  dir_reg3 <- "Registration Reminders\\Youre on your way! (10 weeks)\\Contact lists"
  dir_cons1 <- "Consent and Survey Reminders\\Youre half way there! (Two weeks)\\Contact lists"
  dir_cons2 <- "Consent and Survey Reminders\\Your questionnaire is waiting for you (Four weeks)\\Contact lists"
  dir_cons3 <- "Consent and Survey Reminders\\Six week text_Your contribution\\Contact lists"
  dir_cons4 <- "Consent and Survey Reminders\\Dont forget us! (Ten weeks)\\Contact lists"
  dir_saliva1 <- "Saliva Kit\\Day kit sent Your kit is on its way! (The day kit sent)"
  dir_thankyou <- "Thank you saliva kit received\\Contact list"
}

fnWriteNewsletterCohorts <- function( ps_reminder, ps_filename, pdf_to_write ){
  #' DEBUG
  # ps_reminder <- "Newsletter"
  # ps_filename <- "Newsletter_already_sent_kit"
  # pdf_to_write <- df_2_HAS_returned_kit

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
    ps_reminder == "Thankyou" ~ dir_thankyou,
    ps_reminder == "Newsletter" ~ dir_newsletter,
    TRUE ~ "Other"
  )

  # BELOW not used for "Newsletters" but leaving in for alternative use
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
    ps_reminder == "Thankyou" ~ "Sample Received",
    ps_reminder == "Newsletter" ~ "Newsletter Sent",
    TRUE ~ "Other"
  )

  #' NOW split into GLAD & EDGI
  ( v_study_names <- pdf_to_write %>% distinct( study_id ) %>% pull( study_id ) )
  df_EDGI_ppts <- pdf_to_write %>%
    filter( study_id == 2)
  df_GLAD_ppts <- pdf_to_write %>%
    filter( study_id == 1)

  #' EDGI File
  ( dir_write <- file.path(dir_root, dir_edgi, dir_tail) )
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("EDGI", ps_filename, as.Date(Sys.time()), sep = "_")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    df_EDGI_ppts_Exp <- df_EDGI_ppts %>%
      mutate( forename = first_name,
              consent_newsletter = newsletter_response,
              email = email.x) %>%
      select( participant_id,
              forename, consent_newsletter, email) %>%
      distinct()

    write_csv( df_EDGI_ppts_Exp, WriteTxtFile )
  #     write_csv( df_EDGI_ppts %>%
#                  dplyr::select(id, study_id,
#                        contact_method = "Email",
#                         type = reminder_type,
#                         sample_barcode,
# #                        2 as number,
#                         date_kit_received,
#                         email,
#                         forename
#                         # reminder = "registration_reminder_1",
#                         # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
#                  ), WriteTxtFile )

    # write_csv( df_EDGI_ppts, WriteTxtFile)
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
                            paste("GLAD", ps_filename, as.Date(Sys.time()), sep = "_")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    df_GLAD_ppts_Exp <- df_GLAD_ppts %>%
      mutate( forename = first_name,
              consent_newsletter = newsletter_response,
              email = email.x) %>%
      select( participant_id,
              forename, consent_newsletter, email) %>%
      distinct()

    write_csv( df_GLAD_ppts_Exp, WriteTxtFile )

  # x <- "example123"
  # result <- sub("[0-9]$", "", x)
  # last_digit <- sub(".*([0-9])$", "\\1", x)
}

# Newsletter Cohort files .....
{
  #' 1. HAVE THey returned their SALIVA/SAMPLE Kit
  df_1_HAS_returned_kit <- df_1_generic %>%
    # date_kit_received will NOT be NULL/NA
    dplyr::filter( !is.na(date_kit_received) ) %>%
    # REMOVE duplicate rows
    dplyr::distinct()
  df_1_has_NOT_returned_kit <- df_1_generic %>%
    # date_kit_received WILL be NULL/NA
    dplyr::filter( is.na(date_kit_received) ) %>%
    # REMOVE duplicate rows
    dplyr::distinct()
  #' 2. did they agree to receive NEWSLETTER ?
  df_2_HAS_returned_kit <- df_1_HAS_returned_kit %>%
    # JOIN to the consent form info data
    dplyr::inner_join( df_1_cf_newsletter_info,
                       by = c( "id" = "id",
                               "participant_id" = "alias_matched",
                               "study_id" = "study_id" ),
                       relationship = "many-to-many" ) %>%
    # NOW filter those who have newsletter_response == 1
    filter( newsletter_response == 1 )

  df_2_has_NOT_returned_kit <- df_1_has_NOT_returned_kit %>%
    # JOIN to the consent form info data
    dplyr::inner_join( df_1_cf_newsletter_info,
                       by = c( "id" = "id",
                               "participant_id" = "alias_matched",
                               "study_id" = "study_id" ),
                       relationship = "many-to-many" ) %>%
      # NOW filter those who have newsletter_response == 1
      filter( newsletter_response == 1 )

  fnWriteNewsletterCohorts( "Newsletter", "Newsletter_already_sent_kit", df_2_HAS_returned_kit )
  fnWriteNewsletterCohorts( "Newsletter", "Newsletter_has_not_returned_kit", df_2_has_NOT_returned_kit )

}

