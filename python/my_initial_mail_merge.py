# -*- coding: utf-8 -*-
"""
Created on 

@author: mc
"""

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import pandas as pd
import os

os.chdir("c:/temp")
filename = 'export_registration_make_a_difference_28.08.2025.csv'

df = pd.read_csv(filename, encoding = 'cp1252')
emails = df.email.values.tolist()

for i, value in df.iterrows():
  forename = value["forename"]
email = value["email"]
greeting_line = 'Dear %s,' %forename
# me == my email address
# you == recipient's email address
me = "no-reply@gladstudy.org.uk"
you = email

# Create message container - the correct MIME type is multipart/alternative.
msg = MIMEMultipart('alternative')
msg['Subject'] = "Make a difference today!"
msg['From'] = me
msg['To'] = you

# Create the body of the message (a plain-text and an HTML version).
with open("file1.txt", 'r') as f:
  text = f.read()

with open("file2.html", 'r') as f:
  html = f.read()

personal_text = greeting_line + text
personal_html = greeting_line + html

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(personal_text, 'plain')
part2 = MIMEText(personal_html, 'html')

# Attach parts into message container.
# According to RFC 2046, the last part of a multipart message, in this case
# the HTML message, is best and preferred.
msg.attach(part1)
msg.attach(part2)

# Send the message via local SMTP server.
s = smtplib.SMTP("my-smtp.server.com")
s.starttls()
s.login("userid","pwd")
# sendmail function takes 3 arguments: sender's address, recipient's address
# and message to send - here it is sent as one string.
email = value["email"]
s.sendmail(me, email, msg.as_string())
s.quit()
