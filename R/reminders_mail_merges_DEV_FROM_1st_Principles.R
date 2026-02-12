#' scratch area for REMINDERS 04/12/2025
#'
#' Reg 1 - Make a Diff
{


}
#'
#' NB  - BEFORE EVERY subsequent REMINDER  / AFTER the UPLOAD
#' you will HAVE to refresh df_0_Communications
#'
#' Reg 2 - Make Contrib Count
{

}
#'
#' REg 3 - You'e on your way
{
  #' identify those who have already received reminders for after this
  #' "Sample Reminder"       "Consent Reminder"      "Sample Received"
  #' OR "registration Reminder" #' s 2 or 3
  df_1_reg3_ppts_to_exclude <- df_0_Communications %>%
    filter( ( type %in% c("Sample Reminder", "Consent Reminder", "Sample Received" ) )
            |
            ( type %in% c("Registration Reminder") & number %in% c (3)) ) %>%
    distinct( id, type, number ) %>%
    arrange( type )

  ( v_types <- df_1_reg3_ppts_to_exclude %>% distinct( type, number ) %>% pull( type, number ) )
  ( v_numbers <- df_1_reg3_ppts_to_exclude %>% distinct( number ) %>% pull( number ) )

  df_1_reg3_ppts <- df_1_participants %>%
    # those who have NOT received ANY OF ABOVE reminders
    filter( !( id %in% df_1_reg3_ppts_to_exclude )) %>%
    # exclude those registered in past 14 days
    filter ( !( Sys.Date() - dt_registered_at ) < 15 ) %>%
    # exclude those registered before the LAST set of reminders sent
    # ??? WHAT # days appropriate  - 36 or 21 days appropriate ?
    filter ( !( Sys.Date() - dt_registered_at ) > 100 ) %>%
    distinct( id, ppt_forename,  ppt_email, dt_registered_at, Aliases, study_name, dt_registered_at, dt_consented_at, export_eligibility_state, manual_eligibility_state ) %>%
    arrange( id )

}
#'
#' Cons 1 - You're halfway there
#'
#' Cons 2 - YourQestionnaire is waiting fr you
#'
#' Cons 3 - txt above
#'
#' Cons 4 - Don't forget about us
#'
#' Sal 1
#'
#' Sal 2
#'
#' ...
#' *******************************************************************************
#' OLD CODE
#' Reg1
{
  #' using df_0_participants determine & keep those who :
  #' 1. Have NOT consented or
  #' 2. do NOT have an obscured email (withdrawn) - THIS is already done in the DB VIEW
  #' 3.
  #'
    df_1_not_consented <- df_0_participants %>%
    dplyr::filter( is.na(consent_form_id)) %>%
    distinct( id )
  df_1_ppts_consent_samples_sent <- df_0_Communications %>%
    filter( type %in% v_reminder_types )
  # check NONE have an '*obscured*' email address ?
  df_1_check <- df_1_not_consented %>%
    dplyr::filter(!grepl("obscured", ppt_email, ignore.case = TRUE))
  # 3.
  df_1a_not_consented_no_communication <- df_1_not_consented %>%
    dplyr::anti_join( df_0_Communications , by = "id" )
  #
  df_1_check <- df_0_participants %>%
    dplyr::distinct(id) %>%
    inner_join(df_0_Communications, by = "id") %>%
    distinct(id )
  #'
  # filter down to unique ids, emails.... etc
  # 4 Dec 2025
}

#' Reg 2
#'
{
  #' Using Communications View
  # 1, only keep those where date_kit_sent is NULL - not rows BUT only ppts who have
  # date_kits_sent == NULL
  df_1_ppts_nul_date_kit_sent <- df_0_Communications %>%
    #' ??? need figure how i GET rid of those ppts from comms view  WHO HAVE had
    #' 'Sample Reminders' and 'Consent Reminders' and REg REminders > 1
    filter( is.na(date_kit_sent) ) %>%
    filter( type != "Sample Reminder") %>%
    filter( number != 2 ) %>%
    select ( id, type, number ) %>%
    arrange( desc( number ) )


  # filter( number == 1 )# only those with 1
  df_1_make_contrib_count <- df_0_Communications %>%
    filter (!(id %in% df_1_ppts_nul_date_kit_sent )
}


#' Bucket
#' *********************************************************8
#' NOW split into GLAD & EDGI
( v_study_names <- df_1_reg1_ppts %>% distinct( study_name ) %>% pull( study_name ) )
df_1_reg1_EDGI_ppts <- df_1_reg1_ppts %>%
  filter( study_name == "EDGI UK")

df_1_reg1_GLAD_ppts <- df_1_reg1_ppts %>%
  filter( study_name == "GLAD")
#' EDGI File
( dir_write <- file.path(dir_root, dir_edgi, dir_reg1) )
(fileWrite <- file.path(dir_write,
                        paste("TEST_MBC_export_registration_make_a_difference_", as.Date(Sys.time()), sep = "")))
(WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
write_csv( df_1_reg1_EDGI_ppts %>%
             select(participant_id = id,
                    forename = ppt_forename,
                    email = ppt_email,
                    registration_date = dt_registered_at
                    # reminder = "registration_reminder_1",
                    # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
             ), WriteTxtFile )
#' GLAD File
( dir_write <- file.path(dir_root, dir_glad, dir_reg1) )
(fileWrite <- file.path(dir_write,
                        paste("TEST_MBC_export_registration_make_a_difference_", as.Date(Sys.time()), sep = "")))
(WriteTxtFile <- paste(fileWrite, "csv", sep = "."))
write_csv( df_1_reg1_GLAD_ppts %>%
             select(participant_id = id,
                    forename = ppt_forename,
                    email = ppt_email,
                    registration_date = dt_registered_at
                    # reminder = "registration_reminder_1",
                    # registration_reminder_1_date = as.character( as.Date(Sys.time()) )
             ), WriteTxtFile )


