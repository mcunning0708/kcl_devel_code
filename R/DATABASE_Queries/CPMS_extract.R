#'
#' title: "SQL for GLAd & EDGI eligibility "
#' "\\wsl.localhost\Ubuntu\home\k2585744\projects_wsl\R\MHBIOR\CPMS_extract.R"
#' author: "Mark Cunningham"
#' created date: "26/01/2026"
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
  # library(blastula)
}
sessionInfo()

# Database connection details
{
  host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
  port <- 25060
  user <- "kcl_sgdp_readonly"
  dbname <- "mhbior"  # The actual DB name
}

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
  setwd(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)) )
  source(file = "credentials/paths.R")  # 
  password1 <- substr(password, 6, nchar(password))
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

query_glad_cpms <- "
    SELECT
      CASE
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]'))
          ELSE NULL
      END AS aliases,
      ps.id,
      ns.legacy_code,
      DATE_FORMAT(COALESCE(sub.min_created_at, ps2.consented_at), '%d/%m/%Y') as consented_at,
      ps2.export_eligibility_state, ps2.manual_eligibility_state
      FROM participants ps
      INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id
      INNER JOIN studies ss ON ss.id = ps2.study_id
      LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id
      INNER JOIN (
      SELECT cf.label, cf.study_id, cfr.participant_id, MIN(cfr.created_at) AS min_created_at
          FROM consent_form_responses cfr
          INNER JOIN consent_forms cf
              on ( cf.id = cfr.consent_form_id )
              WHERE SUBSTR(cf.label, 1,4) = 'GLAD'
          GROUP BY label, study_id, participant_id
      ) AS sub
              ON ( ps.id = sub.participant_id AND ps2.study_id = sub.study_id )
      WHERE (ps2.manual_eligibility_state = TRUE OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE))
        AND (UPPER(ps.first_name) <> 'TEST' OR UPPER(ps.last_name) <> 'TEST')
        AND ps.account_type = 'Active'
    "

query_edgi_cpms <- "
    SELECT
      CASE
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]'))
          WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]'))
          ELSE NULL
      END AS aliases,
      ps.id,
      ns.legacy_code,
      DATE_FORMAT(COALESCE(sub.min_created_at, ps2.consented_at), '%d/%m/%Y') as consented_at,
      ps2.export_eligibility_state, ps2.manual_eligibility_state
      FROM participants ps
      INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id
      INNER JOIN studies ss ON ss.id = ps2.study_id
      LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id
      INNER JOIN (
      SELECT cf.label, cf.study_id, cfr.participant_id, MIN(cfr.created_at) AS min_created_at
          FROM consent_form_responses cfr
          INNER JOIN consent_forms cf
              on ( cf.id = cfr.consent_form_id )
              WHERE SUBSTR(cf.label, 1,4) = 'EDGI'
          GROUP BY label, study_id, participant_id
      ) AS sub
              ON ( ps.id = sub.participant_id AND ps2.study_id = sub.study_id )
      WHERE (ps2.manual_eligibility_state = TRUE OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE))
        AND (UPPER(ps.first_name) <> 'TEST' OR UPPER(ps.last_name) <> 'TEST')
        AND ps.account_type = 'Active'
    "

# Fetch data into a dataframe
#' THESE next statements MAY Take a CONSIDERABLE time to run
#' EXERCISE Extreme Caution re WHEN u run them ....
#'
df_0_glad_cpms_sample <- dbGetQuery(con, paste(query_glad_cpms, "LIMIT 20"))
df_0_glad_cpms <- dbGetQuery(con, query_glad_cpms)

df_0_edgi_cpms_sample <- dbGetQuery(con, paste(query_edgi_cpms, "LIMIT 20"))
df_0_edgi_cpms <- dbGetQuery(con, query_edgi_cpms)

# Close the connection UNLESS you need get more data
dbDisconnect(con) # DONE 27/11/2025

#' ***************************************************
#' Let's process the data for Reminders
#' REMEMBER to Choose the specific Study at the appropriate Stage
#'
{
  dir_root <- "C:\\Users\\k2585744\\King's College London"
  dir_edgi <- "BioResource R Data - Eating Disorders Genetics Initiative\\NHS Sites"
  dir_glad <- "BioResource R Data - Genetic Links to Anxiety and Depression\\NHS Sites"
  # dir_reg1 <- "Registration Reminders\\Make a difference today! (Two weeks)\\Contact lists"
  # dir_reg2 <- "Registration Reminders\\Make your contribution count (Five weeks)\\Contact lists"
  # dir_reg3 <- "Registration Reminders\\Youre on your way! (10 weeks)\\Contact lists"
  # dir_cons1 <- "Consent and Survey Reminders\\Youre half way there! (Two weeks)\\Contact lists"
  # dir_cons2 <- "Consent and Survey Reminders\\Your questionnaire is waiting for you (Four weeks)\\Contact lists"
  # dir_cons3 <- "Consent and Survey Reminders\\Six week text_Your contribution\\Contact lists"
  # dir_cons4 <- "Consent and Survey Reminders\\Dont forget us! (Ten weeks)\\Contact lists"
  # dir_saliva1 <- "Saliva Kit\\Day kit sent Your kit is on its way! (The day kit sent)"
  list.files()
}

fnWriteCPMSFiles <- function( ps_study, pdf_to_write ){
  #' DEBUG
  # ps_reminder <- "Saliva1"

  dir_tail = case_when(
    ps_study == "edgi" ~ "BioResource R Data - Eating Disorders Genetics Initiative",
    ps_study == "glad" ~ "BioResource R Data - Genetic Links to Anxiety and Depression",
    TRUE ~ "Other"
  )

  #' NOW split into GLAD & EDGI
  # ( v_study_names <- pdf_to_write %>% distinct( study_name ) %>% pull( study_name ) )
  # df_EDGI_ppts <- pdf_to_write %>%
  #   filter( study_name == "EDGI UK")
  # df_GLAD_ppts <- pdf_to_write %>%
  #   filter( study_name == "GLAD")

  #' create Dir & File vars
  ( dir_write <- file.path(dir_root, dir_tail, "NHS Sites") )
  list.files(path = dir_write)
    # EXPORT File
    (fileWrite <- file.path(dir_write,
                            paste("MBC_CPMS", ps_study, as.Date(Sys.time()), sep = "_")))
    (WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
    write_csv( pdf_to_write, WriteTxtFile )

  # x <- "example123"
  # result <- sub("[0-9]$", "", x)
  # last_digit <- sub(".*([0-9])$", "\\1", x)
}

# GET DIR to WRITE to  ..... 
{
  # 1.
  #' 

  #'
  fnWriteCPMSFiles( "glad", df_0_glad_cpms )
  fnWriteCPMSFiles( "edgi", df_0_edgi_cpms )
  

}

