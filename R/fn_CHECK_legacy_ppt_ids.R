#' CHECKING that specific DF / tibble does NOT have legacy ppt_id from the incorrect study ... ....
fnSplitByStudyID <- function( pn_study, pdf_to_split) {
  ldf_ppts <- pdf_to_split %>%
    filter( study_id == pn_study)
  # df_GLAD_ppts <- pdf_to_write %>%
  #   filter( study_id == 1)
  return( ldf_ppts )
}

#' if i use ABOVE fn to filter for EDGI (pn_study == 2) into dfCheck THEN ..
#' if dfCheck1 i should check for GLAD which SHOULD have ZERO rows ...
#' & vice versa
#' use with specific df /tibbles & change the ref to 'participant_id' below as necessary
dfCheck <-fnSplitByStudyID( 2, df_2_HAS_returned_kit )
dfCheck %>% glimpse()
dfCheck1 <- dfCheck %>% filter( substr(participant_id, 1, 4) == "GLAD" )
dfCheck1 %>% glimpse()

dfCheck <-fnSplitByStudyID( 2, df_2_has_NOT_returned_kit )
dfCheck %>% glimpse()
dfCheck1 <- dfCheck %>% filter( substr(participant_id, 1, 4) == "GLAD" )
dfCheck1 %>% glimpse()

dfCheck <-fnSplitByStudyID( 1, df_2_HAS_returned_kit )
dfCheck %>% glimpse()
dfCheck1 <- dfCheck %>% filter( substr(participant_id, 1, 4) == "EDGI" )
dfCheck1 %>% glimpse()

dfCheck <-fnSplitByStudyID( 1, df_2_has_NOT_returned_kit )
dfCheck %>% glimpse()
dfCheck1 <- dfCheck %>% filter( substr(participant_id, 1, 4) == "EDGI" )
dfCheck1 %>% glimpse()

dfviewCheck <-fnSplitByStudyID( 1, df_1_cf_newsletter_info )
dfviewCheck %>% glimpse()
dfviewCheck1 <- dfviewCheck %>% filter( substr(id, 1, 4) == "EDGI" )
dfviewCheck1 %>% glimpse()
# SO my VIEW does NOT have the Wrong ppt_study in the relevant


#' *******************************
#'
dfviewCheck <-fnSplitByStudyID( 1, df_1_generic )
dfviewCheck %>% glimpse()
dfviewCheck1 <- dfviewCheck %>% filter( substr(id, 1, 4) == "EDGI" )
dfviewCheck1 %>% glimpse()

dfCheck <- df_0_cf_newsletter_info %>%
  filter( newsletter_response == 0 )





