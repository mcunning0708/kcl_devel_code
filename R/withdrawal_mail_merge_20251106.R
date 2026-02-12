#' Packages BELOW must be installed / loaded for this R script
# install.packages(c("readr", "stringr", "blastula"))
# install.packages("devtools")

#' keeping the smtp server settings here ... 
#' THO remember to enter password WHEN you run script only
# file.edit("~/.Renviron")

# recommended to install the latest blastula
# devtools::install_github("rstudio/blastula")
library(readr)
library(blastula)
library(stringr)

sessionInfo()

# Set working directory
setwd("c:/Temp")

getwd()
# Read CSV file
list.files()
# df <- read_csv("test_email_merge.csv", locale = locale(encoding = "Windows-1252"))
df <- read_csv("final_withdrawal_contact_list.csv", locale = locale(encoding = "Windows-1252"))

spec(df)
# Read email body templates
# text_body <- read_file("email_mc.txt")
# test_footer <- read_file("email_txt_footer.txt")
# html_body <- read_file("GLAD_registration_make_difference.html")

# SMTP credentials as specified in .py script .... 
# s = smtplib.SMTP("email-smtp.eu-west-1.amazonaws.com")
# s.login("AKIAJZTUTERGPMI5CLZQ","Ar+P0YLV9V7WGB+QPcwKaCLuUMYqCHIwRHkkdh9shcyj")

# smtp_creds <- creds(
#   host = "email-smtp.eu-west-1.amazonaws.com",
#   port = 587,
#   username = "AKIAJZTUTERGPMI5CLZQ",
#   # password = "Ar+P0YLV9V7WGB+QPcwKaCLuUMYqCHIwRHkkdh9shcyj",
#   use_ssl = FALSE
# )

#' user / pwd credentials i have put in file ~/.Renviron
#' run file.edit("~/.Renviron") to see those or look above ... 
smtp_creds <- blastula::creds(
  host = "email-smtp.eu-west-1.amazonaws.com",
  # port = 587,
  port = 465, # to use SSL/TLS
  user = Sys.getenv("BLASTULA_SMTP_USER"),
  # password = Sys.getenv("BLASTULA_SMTP_PASSWORD"),
  use_ssl = TRUE # TRUE if port = 465 else FALSE for STARTTLS 
)

# Loop through each row to send personalized emails
dir_write <- getwd()
(fileWrite <- file.path(dir_write, paste("email_merge_log_", as.Date(Sys.time()), sep = "")))
# (fileWrite <- file.path(dir_write, paste("email_merge_log_", Sys.time(), sep = "")))
(fileWrite <- paste(fileWrite, "log", sep = "."))

sink(fileWrite)  # Start redirecting output

for (i in seq_len(nrow(df))) {
# for (i in c(3,4)) {
  forename <- df$Forename[i]
  surname <- df$Name[i]
  email <- df$Email[i]
  sender <- df$SenderEmail[i]
  attachment <- df$AttachmentPath[i]
  greeting <- sprintf("Dear %s,", forename)
  body_text_file <- df$BodyText[i]
  text_footer <- df$Footer[i]
  text_body <- read_file( body_text_file )
  
  # Compose email
  # bastula::compose_email()
  # email_msg <- blastula::compose_email(
  #   body = md(paste(greeting, text_body, sep = "\n\n")),
  #   footer = text_footer
  # )
  email_msg <- blastula::compose_email(
    body = blocks(greeting, 
                  # text_body)
    # md(body_text_file)
    md(text_body)
    )
  )
  
  
  # Add a plain-text fallback
  # email_msg <-  add_text_body(
  #   email = email_msg,
  #   text = "Hello, this is the test email in plain text."
  # )
  
  
  # Add attachment
  email_msg <- blastula::add_attachment(
    email = email_msg,
    file = attachment
  )
  
  # Send email with attachment
  
  blastula::smtp_send(
    email = email_msg,
    from = sender,
    to = email,
    subject = "testing mail merge !",
    credentials = smtp_creds
  )
  
  print(Sys.time())
  cat(sprintf("%d - Have just sent email with attachment %s to %s, using email address : %s\n", i, attachment, paste(forename, surname), email )) 
}

sink()

#' END of Srcipt ......
#' run 06 / 11 / 2025 
#' 