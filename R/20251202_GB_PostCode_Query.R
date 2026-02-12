




# Install required packages if not already installed
install.packages("DBI")
# install.packages("RMySQL")

library(DBI)
library(RMySQL)
#' where would i be without tidyverse ?
#' includes lubridate:: stringr:: readr::
library(tidyverse)
#' for the Mail Merge
library(blastula)

sessionInfo()

# Database connection details
host <- "db-mysql-lon1-68182-do-user-8092310-0.b.db.ondigitalocean.com"
port <- 25060
user <- "kcl_sgdp_readonly"
# Prompt for a value of DB password
(password <- readline(prompt = "What is DB password for 'kcl_sgdp_readonly' ? "))
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

#' up to date ACTIVE participants held in VIEW i set up for REMINDERS
query_participants <- "SELECT * FROM v_active_participants_reminders;"
query_communications <- "SELECT * FROM v_communications_reminders;"


# Fetch data into a dataframe
df_0_sample1 <- dbGetQuery(con, query_participants_sample)
df_0_sample2 <- dbGetQuery(con, query_communications_sample)

#' THESE next 2 statements WILL Take a CONSIDERABLE time to run
#' EXERCISE Extreme Caution re WHEN u run them ....
#'
df_0_participants <- dbGetQuery(con, query_participants)
df_0_Communications <- dbGetQuery(con, query_communications)

query_raw_participants <- "SELECT * FROM participants;"
# query_communications <- "SELECT * FROM v_communications_reminders;"


# Fetch data into a dataframe
df_0_raw_participants <- dbGetQuery(con, query_raw_participants)
# df_0_sample2 <- dbGetQuery(con, query_communications_sample)

#' i just want post code data here
df_1_raw_participants <- df_0_raw_participants %>%
  distinct( id, address_post_code  )

df_2 <- df_0_participants %>%
  left_join( df_1_raw_participants, by = 'id')
df_3 <- df_2 %>% distinct(id, study_name, address_post_code)
df_3a <- df_3 %>%
  mutate(postcode_root = toupper( sub(" .*", "", address_post_code) ) )

setwd("\\\\wsl.localhost/Ubuntu/home/k2585744/projects_wsl/R")
getwd()
list.files()
df_m25_postcodes <- read_csv("m25_postcodes.csv", locale = locale(encoding = "Windows-1252"))

df_4 <- df_3a %>%
  inner_join(df_m25_postcodes, by = c("postcode_root" = "PostcodePrefix"))

df_9 <- df_3a %>%
  group_by( study_name ) %>%
  summarise(n_ppts = n())

df_9a <- df_4 %>%
  group_by( study_name ) %>%
  summarise(n_ppts = n())


#'
#'****************************************************
# Close the connection UNLESS you need get more data
dbDisconnect(con) # DONE 27/11/2025
