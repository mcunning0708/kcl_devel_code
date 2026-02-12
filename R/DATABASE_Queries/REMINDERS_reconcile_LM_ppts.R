#' REconcile my files with those gernated by LM in Jan 2026
#'

( dir_data <- file.path(dir_root, dir_edgi, dir_reg1) )
list.files( path = dir_data)
file_to_read <- file.path(dir_data, "export_registration_make_a_difference_20.01.2026.csv" )
df_0_edgi_LM <- read_csv(file_to_read)
df_1_edgi_LM <- df_0_edgi_LM %>%
  mutate(dt_registered_at = as.Date(registered_at, format = "%Y-%m-%d" ) ) %>%
  mutate(participant_id = `Participant id`)

df_1_edgi_LM %>% glimpse()

# should be NO overlap?
dfCheckNone <- df_1_edgi_LM %>%
  inner_join(df_1_reg1_EDGI_ppts, by = c("participant_id" = "id"))
