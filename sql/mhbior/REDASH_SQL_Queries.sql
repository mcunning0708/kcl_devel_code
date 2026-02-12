id,name,query
35,EDGI consented not finished survey,"/* EDGI consented participants who have not yet completed their baseline questionnaire- 
 * Date: 18/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id as 'Participant id',
 p.email,
 p.phone as mobile,
 first_name forename,
 last_name surname,
 ps.export_eligibility_state,
 consented_at,
 ps.manual_eligibility_state
 
 FROM participants p, participant_study ps, studies s
 WHERE p.id = ps.participant_id 
 AND s.id =ps.study_id 
 AND ps.export_eligibility_state IS NULL 
 AND ps.manual_eligibility_state IS NULL
 AND ps.consented_at IS NOT NULL
 AND p.withdrew_at IS NULL
 AND s.name = 'EDGI UK'
 AND account_type = 'Active';"
1,Weekly Reports - samples kits for GLAD,"/* Weekly Reports - samples kits for GLAD and EDGI
 * Date: 03/07/2023
 * Author: Ian Marsh
 */
 USE mhbior;
 

SELECT 
aliases participant_id,
bio_resource_id,
barcode,
-- ps2.study_id,
ss.name study_name,
s.date_kit_sent,
s.date_kit_received
FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND ss.name = 'GLAD'
AND ps.withdrew_at  IS NULL
AND date_kit_sent IS NOT NULL;"
4,Weekly Reports - Registrations for GLAD,"/* Weekly Reports - Registrations for GLAD and EDGI
 * Date: 03/07/2023
 * Author: Ian Marsh
 */

USE mhbior;

SELECT 
aliases participant_id,
bio_resource_id,
barcode,
-- ps2.study_id,
ss.name study_name
FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND ss.name = 'GLAD'
AND ps.withdrew_at  IS NULL;
"
2,Weekly Eligibility report GLAD,"/* Weekly Reports - Eligibility report GLAD and EDGI
 * Date: 03/07/2023
 * Author: Ian Marsh
 */

USE mhbior;


SELECT p.* FROM participants p, participant_study ps, studies s
WHERE p.id = ps.participant_id 
AND s.id =ps.study_id 
AND ps.export_eligibility_state = 1
AND s.name = 'GLAD'
AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test')
AND p.withdrew_at  IS NULL;
"
3,Weekly Reports - Consents for GLAD,"/* Weekly Reports - Consents for GLAD and EDGI
 * Date: 03/07/2023
 * Author: Ian Marsh
 */

USE mhbior;

SELECT p.* FROM participants p, participant_study ps, studies s
WHERE p.id = ps.participant_id 
AND s.id =ps.study_id 
AND ps.consented_at IS NOT NULL
AND s.name = 'GLAD'
AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test');
"
48,New Query,select * from queries
46,New Query,select * from temp_saliva
62,consent_newsletter,"SELECT
  user_id,
--  forename,
--  surname,
--  date_of_birth,
  consent_date,
  CASE WHEN consent_newsletter = 1 THEN 'YES' ELSE 'NO' END consent_newsletter,
  CASE WHEN consent_contact_gp = 1 THEN 'YES' ELSE 'NO' END consent_contact_gp,
   CASE WHEN consent_follow_up = 1 THEN 'YES' ELSE 'NO' END consent_follow_up
FROM
  EDGI_consented
-- WHERE user_id = '{{ Alias }}'"
11,GLAD saliva kits sent - Scotland,"/* GLAD saliva kits sent - Scotland - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 select
 aliases,
 ps.id,
 barcode,
 s.date_kit_sent,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_sent IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND ps.withdrew_at  IS NULL
 AND address_country = 'Scotland'
 AND ps2.export_eligibility_state = 1"
7,EDGI registration email reminder - 1 (2 weeks),"/* EDGI registration email reminder - 1 (2 weeks) 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 
 
 SELECT 
 
 
 FROM 
 
 Where project_id = 'EDGI'
 
 "
47,New Query,"select *from events where action = 'execute_query'
order by events desc"
21,New LLC File1 (MHBIOR),"/* LLC File1 creation script
 * Author : Ian Marsh
 * Date : 16/01/2024
 */
USE mhbior;

SELECT
-- p.aliases,
CASE JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[*]')) 
	WHEN SUBSTRING(JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')),1,4 = 'GLAD')  THEN JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) 
    ELSE CONCAT('GLAD',LPAD(p.id, 6,'0'))
END	
STUDY_ID,
-- p.id ID,
'C' ROW_STATUS,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
p.address_line_1 ADDRESS_1,
p.address_line_2 ADDRESS_2,
p.address_city ADDRESS_3,
p.address_county ADDRESS_4,
'' ADDRESS_5,
p.address_post_code POSTCODE,
NULL ADDRESS_START_DATE,
NULL ADDRESS_END_DATE,
p.date_of_birth DATE_OF_BIRTH,
CASE  p.gender_identity
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'unknown' THEN 9
            ELSE 9
END GENDER_CD,
p.created_at CREATE_DATE,
w.llc_opt_out_outcome UKLLC_STATUS,
-- p.address_country,
-- w.can_access_medical_records,
CASE ( w.can_access_medical_records AND p.address_country = 'England') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Scotland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Wales') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_W_Linkage_Permission,
CASE ( w.can_access_medical_records AND p.address_country = 'Northern Ireland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number,
-- ""NHS_S_Linkage_Permission"",""NHS_S_Study_Number"",""NHS_W_Linkage_Permission"",""NHS_NI_Linkage_Permission"",""NHS_NI_Study_Number"",
'2' Geocoding_Permission,
'1'  ZoeSymptomTracker_Permission,
'9'  Multiple_Birth,
'1'  National_Opt_Out
FROM
mhbior.participants p
LEFT JOIN mhbior.withdrawals w ON p.id = w.participant_id
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%') 
"
13,GLAD Saliva kits received - Northern Ireland,"/* GLAD Saliva kits received - Northern Ireland - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT DISTINCT
 aliases,
 ps.id,
 barcode,
 s.date_kit_received,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss, withdrawals w
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_received IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND sample_destruction_requested_at IS NULL
 AND address_country = 'Northern Ireland'
 AND ps2.export_eligibility_state = 1"
57,LLC_file1_mhbior_GLAD,"/* LLC File1 creation script EDGI
 * Author : Ian Marsh and Mika Malouf
 * Date : 16/07/2024
 */
 
SELECT
jt.alias_matched STUDY_ID,
'C' ROW_STATUS,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
p.address_line_1 ADDRESS_1,
p.address_line_2 ADDRESS_2,
p.address_city ADDRESS_3,
p.address_county ADDRESS_4,
'' ADDRESS_5,
p.address_post_code POSTCODE,
NULL ADDRESS_START_DATE,
NULL ADDRESS_END_DATE,
p.date_of_birth DATE_OF_BIRTH,
CASE  p.gender_identity
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'unknown' THEN 9
            ELSE 9
END GENDER_CD,
'16/07/2024' CREATE_DATE,
w.llc_opt_out_outcome UKLLC_STATUS,
-- p.address_country,
-- w.can_access_medical_records,
CASE ( w.can_access_medical_records AND p.address_country = 'England') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Scotland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Wales') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_W_Linkage_Permission,
CASE ( w.can_access_medical_records AND p.address_country = 'Northern Ireland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number,
-- ""NHS_S_Linkage_Permission"",""NHS_S_Study_Number"",""NHS_W_Linkage_Permission"",""NHS_NI_Linkage_Permission"",""NHS_NI_Study_Number"",
'2' Geocoding_Permission,
'1'  ZoeSymptomTracker_Permission,
'9'  Multiple_Birth,
'1'  National_Opt_Out

FROM
mhbior.consent_form_responses cf, mhbior.participants p

LEFT JOIN mhbior.withdrawals w ON p.id = w.participant_id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND p.id = cf.participant_id
AND cf.created_at IS NOT NULL
AND jt.alias_matched REGEXP '^GLAD[0-9]{6}$';"
37,EDGI UK Eligibility Email (kit on its way)," /* EDGI UK Eligibility Email (kit on its way)
 * Date: 19/06/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT 
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
AND date_kit_sent = '2024-07-04';"
30,Controls number,"/* GLAD Controls numbers for weekly GLAD figures - 
 * Date: 16/04/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 ps.export_eligibility_state,
 ps.case_status,
 s.date_kit_sent,
 s.date_kit_received,
 p.address_country
 
 
 FROM participants p, participant_study ps, studies ss, samples s
 WHERE p.id = ps.participant_id
 AND p.id = s.participant_id 
 AND ss.id = ps.study_id
 AND account_type = 'Active'
 AND p.withdrew_at IS NULL
 AND ss.name = 'GLAD'
 AND ps.case_status = 'Control';"
27,GLAD Saliva reminder 2-7: (2 weeks - 6 months) (communication),"/* GLAD Saliva reminder 2-7
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who were sent a sample reminder */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 s.study_id,
 contact_method, 
 c.type, 
 s.barcode as sample_barcode,
 c.number,
 ps.first_name as forename,
 ps.email,
 ps.phone,
 c.sent_at,
 last_name,
 ps2.export_eligibility_state,
 s.date_kit_sent

 FROM participants ps, samples s, participant_study ps2, studies ss, communications c
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND c.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'GLAD'
 AND s.study_id = 1
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL
 AND c.type = 'Sample Reminder';
 /*GLAD_Saliva_reminder_1_Top_tips_(One_week)_YYYY_MM_DD */"
23,GLAD thank you kit email (kit received)," /* GLAD thank you kit email (kit recieved)
 * Date: 01/02/2024
 * Author: Mika Malouf/Laura Meldrum
 */
 
 /*last time this script was run was on 2026-01-15*/
 
 /* INSTRUCTIONS - PLEASE READ 
 Step 1 - Update line 42 to the date on line 6.
 Step 2 - Update line 6 to the current date. 
 Step 3 - Click execute and save the script
 Step 3 - Export the file and save as export in the SharePoint BioResource R Data glad > reminders > thank you email folder
 Step 4 - Open the file and remove kits with study_id 2
 Step 5 - Remove duplicates by sample barcode
 Step 6 - Run the html email script and the MHBIOR communications script, then import into communications page on MHBIOR
 */
 
 USE mhbior;
 
SELECT 
/*TRIM('[""' FROM aliases) AS aliases, */
ps.id,
s.study_id,
'Email' contact_method,
'Sample Received' type,
barcode as sample_barcode,
-- c.number,
-- sent_at,
s.date_kit_received,
ps.email,
ps.first_name as forename

FROM participants ps, samples s, participant_study ps2, studies ss-- , communications c
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
-- AND c.participant_id = ps.id
AND ss.name = 'GLAD'
AND s.study_id = 1
AND ps.withdrew_at IS NULL
AND date_kit_sent IS NOT NULL
AND date_kit_received >= '2026-01-08'
-- AND c.type <> 'Sample Received';"
32,All track ID,"/* All track ids on MHBIOR - 
 * Date: 14/06/2024
 * Author: Chelsea Mika Malouf
 Purpose: Born social weekly recruitment numbers
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 s.study_id,
 royal_mail_tracking_id as tracking_id,
 s.date_kit_sent,
 s.date_kit_received

 FROM participants ps, samples s, participant_study ps2
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND royal_mail_tracking_id IS NOT NULL;"
26,GLAD ineligible,"/* GLAD ineligible - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 aliases,
 p.id,
 p.email,
 first_name forename,
 last_name surname,
 ps.export_eligibility_state,
 consented_at,
 ps.manual_eligibility_state
 
 FROM participants p, participant_study ps, studies s
 WHERE p.id = ps.participant_id 
 AND s.id =ps.study_id 
 AND ps.export_eligibility_state = 0
 AND p.withdrew_at  IS NULL
 AND (ps.manual_eligibility_state = 0 OR ps.manual_eligibility_state IS NULL)
 AND s.name = 'GLAD'
 AND account_type = 'Active';"
59,New_GLAD thank you kit email,"/* GLAD thank you kit email (kit recieved)
* Date: 01/02/2024
* Author: Mika Malouf
*/
 
/*last time this was ran was on 25.07.2024 */
 
/* INSTRUCTIONS - PLEASE READ 
 Step 1 - run the script
 Step 2 - Update line 41 to the current date. Run the script
 Step 3 - Update line 6 to the current date. Save the script
 Step 4 - export the file in the glad > reminders > thank you email folder as an export on the R drive
 Step 5 - Open the file and remove kits with study_id 2 for GLAD emails
 Step 6 - Remove duplicates by sample barcode
*/
 
USE mhbior;
 
SELECT 
/*TRIM('[""' FROM aliases) AS aliases, */
ps.id,
s.study_id,
'Email' contact_method,
'Sample Received' type,
c.type,
barcode as sample_barcode,
c.number,
sent_at,
s.date_kit_received,
ps.email,
ps.first_name as forename
FROM participants ps
INNER JOIN samples s ON ps.id = s.participant_id 
INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id
INNER JOIN studies ss ON ps2.study_id = ss.id
LEFT OUTER JOIN communications c ON ps.id = c.participant_id  AND c.study_id = ss.id AND c.contact_method = 'Email'
WHERE
ss.name = 'GLAD'
-- AND c.study_id = ss.id
AND s.study_id = ss.id
AND ps.withdrew_at IS NULL
-- AND s.date_kit_sent IS NOT NULL
AND s.date_kit_received >='2024-10-24' /* enter date as yyyy-mm-dd when running this report */
-- AND c.type = 'Sample Received'
AND c.type IS NULL
ORDER BY date_kit_received;"
10,GLAD saliva kits sent - Wales,"/* GLAD saliva kits sent - Wales - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 select
 aliases,
 ps.id,
 barcode,
 s.date_kit_sent,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_sent IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND ps.withdrew_at  IS NULL
 AND address_country = 'Wales'
 AND ps2.export_eligibility_state = 1"
9,GLAD saliva kits sent - Northern Ireland,"/* GLAD saliva kits sent - Northern Ireland - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 select
 aliases,
 ps.id,
 barcode,
 s.date_kit_sent,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_sent IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND ps.withdrew_at  IS NULL
 AND address_country = 'Northern Ireland'
 AND ps2.export_eligibility_state = 1"
12,GLAD Saliva kits received - England,"/* GLAD Saliva kits received - England - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT DISTINCT
 aliases,
 ps.id,
 barcode,
 s.date_kit_received,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss, withdrawals w
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_received IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND sample_destruction_requested_at IS NULL
 AND address_country = 'England'
 AND ps2.export_eligibility_state = 1"
14,GLAD Saliva kits received - Scotland,"/* GLAD Saliva kits received - Scotland - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT DISTINCT
 aliases,
 ps.id,
 barcode,
 s.date_kit_received,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss, withdrawals w
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_received IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND sample_destruction_requested_at IS NULL
 AND address_country = 'Scotland'
 AND ps2.export_eligibility_state = 1"
40,EDGI email reminder MHBIOR (registration 1),"/* EDGI reminder email (registration 1)
 * Date: 25/06/2024, edited on 20/01/2026
 * Author: Mika Malouf, edited by Laura Meldrum
 */
 
USE mhbior;
 
SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id as 'Participant id',
 ps2.export_eligibility_state,
 ps.registered_at

FROM participants ps, participant_study ps2
WHERE ps2.participant_id = ps.id
AND ps.account_type = 'Active'
AND ps2.study_id = '2'
AND ps.withdrew_at IS NULL
AND ps.email IS NOT NULL;"
19,LLC File1,"SELECT  
             record STUDY_ID,
             'C' ROW_STATUS,
 --         STR_TO_DATE (max( case when field_name ='saliva_kit_received_date' then NULLIF(value,NULL) end) ,'%Y-%m-%d') saliva_kit_received_date,    -- date
 --         STR_TO_DATE ( max( case when field_name ='date_of_birth' tdhen value end), '%d/%m/%Y') date_of_birth,
            CASE CHAR_LENGTH(REPLACE (REPLACE(max( case when field_name ='id_nhs' then value end),'-', ''), ' ', ''))
            WHEN 10 THEN REPLACE (REPLACE(max( case when field_name ='id_nhs' then value end),'-', ''), ' ', '')
            ELSE NULL
            END  NHS_NUMBER,
 --            max( case when field_name ='id_nhs' then value end)  nhs_number,   --   value REGEXP '^[0-9]+$';
             max( case when field_name ='surname' then value end) SURNAME,
             max( case when field_name ='forename' then value end) FORENAME,
             max( case when field_name ='second_name' then value end) MIDDLENAMES,
--            max( case when field_name ='address_line_1' then value  end) ADDRESS_1,
             NULL ADDRESS_1,
--           max( case when field_name ='address_town' then value end) ADDRESS_2,
             NULL ADDRESS_2,
--            max( case when field_name ='address_county' then value end) ADDRESS_3,
            NULL ADDRESS_3,
            NULL ADDRESS_4,
            NULL ADDRESS_5,
            SUBSTRING(max( case when field_name ='address_postcode' then UPPER(value) end),1,8) POSTCODE,
            NULL ADDRESS_START_DATE,
            NULL ADDRESS_END_DATE,
            max( case when field_name ='date_of_birth' then value end) DATE_OF_BIRTH,
 --                      REPLACE (max( case when field_name ='date_of_birth' then value end),'/','.') date_of_birth,
 --           STR_TO_DATE ( max( case when field_name ='date_of_birth' then value end), '%d/%m/%Y') date_of_birth,
 --           max( case when field_name ='date_of_birth' then value end) date_of_birth,
            CASE max( case when field_name ='gender' then value end)
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'unkown' THEN 9
            ELSE 8
            END GENDER_CD,
--            max( case when field_name ='gender' then value end) gender_cd,
--           max(case when field_name ='consent_date' then value end) created_date,
--           DATE_FORMAT(SUBSTRING( max(case when field_name ='consent_date' then value end),1,10),'%d/%m/%Y') create_date,
            SUBSTRING(max(case when field_name ='consent_date' then value end),1,10) CREATE_DATE,
--            '1' UKLLC_status,
          	CASE 
                WHEN max(case when field_name ='llc_opt_out_date' then value end) IS NOT NULL THEN 0
            	ELSE 1
            END UKLLC_STATUS,
            CASE 
                WHEN max(case when field_name ='consent_access_records' then value end) IS NOT NULL AND ( max(case when field_name ='address_country' then value end) IS NULL OR max(case when field_name ='address_country' then value end) = '1') THEN 1
            	ELSE 0
            END NHS_E_Linkage_Permission,
            9 NHS_Digital_Study_Number,
           CASE 
               WHEN max(case when field_name ='consent_access_records' then value end) IS NOT NULL AND max(case when field_name ='address_country' then value end) = '2' THEN 1
            	ELSE 0
            END NHS_S_Linkage_Permission,
            9 NHS_S_Study_Number,
            CASE 
                WHEN max(case when field_name ='consent_access_records' then value end) IS NOT NULL AND  max(case when field_name ='address_country' then value end) = '3' THEN 1
            	ELSE 0
            END NHS_W_Linkage_Permission,
            CASE 
               WHEN max(case when field_name ='consent_access_records' then value end) IS NOT NULL AND  max(case when field_name ='address_country' then value end) = '4' THEN 1
            	ELSE 0
            END NHS_NI_Linkage_Permission,
            9 NHS_NI_Study_Number,
            NULL Geocoding_Permission,
            NULL ZoeSymptomTracker_Permission,
            9 Multiple_Birth,
--            CASE max(case when field_name ='consent_date' then value end)
			CASE 
			  WHEN max(CASE WHEN field_name ='withdraw_date' THEN value END) IS NOT NULL THEN 1   
               ELSE 0
            END AS National_Opt_Out
 --           SUBSTRING(record,1,4) study
 --           NOW() update_datetime
from redcap_data
where  project_id = 15 and event_id = 68 AND record NOT IN (SELECT  
             record STUDY_ID
             from redcap_data
             where  project_id = 15 and event_id = 68 
             group by record
             HAVING  max(case when field_name ='withdraw_date' then value end) IS NOT NULL AND max(case when field_name ='withdraw_date' then value end) < '2021-11-01')
group by record
HAVING MAX(CASE WHEN field_name ='consent_date' then 1 end) = 1
-- forename if they are the following:
-- test
-- TEST
-- Test
-- AND (MAX( case when field_name ='surname' then value end) LIKE 'TEST%'  OR MAX( case when field_name ='surname' then value end) LIKE 'Test%' OR MAX( case when field_name ='surname' then value end) LIKE 'test%'  )
-- having  max(case when field_name ='rr_eligible' then value end) 
and substring(record,1,4) <> 'TTRR';"
25,GLAD Consent reminder 2-4,"/* GLAD Consent reminder 2_Questionnaire is waiting (4 wks) - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 cf.study_id,
 c.contact_method, 
 c.type, 
 NULL sample_barcode,
 c.number,
 p.first_name as forename,
 p.email,
 p.phone,
 c.sent_at,
 last_name,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c, consent_forms cf
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND ss.id = cf.study_id
 AND ss.name = 'GLAD'
 AND ps.consented_at IS NOT NULL
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL
 AND (c.type = 'Consent Reminder' and c.study_id = 1);"
15,GLAD Saliva kits received - Wales,"/* GLAD Saliva kits received - Wales - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT DISTINCT
 aliases,
 ps.id,
 barcode,
 s.date_kit_received,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss, withdrawals w
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_received IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND sample_destruction_requested_at IS NULL
 AND address_country = 'Wales'
 AND ps2.export_eligibility_state = 1"
24,LLC File 1 GLAD (MHBIOR) mika,"/* LLC File1 creation script
 * Author : Mika Malouf
 * Date : 01/02/2024
 */
USE mhbior;

SELECT
JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) AS STUDY_ID,
-- p.id ID,
'C' ROW_STATUS,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
NULL ADDRESS_1, /*p.address_line_1 */
NULL ADDRESS_2, /*p.address_line_2 */
NULL ADDRESS_3, /*p.address_city */
NULL ADDRESS_4, /*p.address_county */
'' ADDRESS_5,
p.address_post_code POSTCODE,
NULL ADDRESS_START_DATE,
NULL ADDRESS_END_DATE,
p.date_of_birth DATE_OF_BIRTH,
CASE  p.gender_identity
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'unknown' THEN 9
            ELSE 9
END GENDER_CD,
/*cf.created_at CREATE_DATE, */
DATE_FORMAT(cf.created_at, '%d/%m/%Y') CREATE_DATE, /*p.created_at CREATE_DATE, should be consent date*/
/*w.llc_opt_out_outcome UKLLC_STATUS,
-- p.address_country,
-- w.can_access_medical_records, */
CASE w.llc_opt_out_outcome
		WHEN 'Opt-out LLC medical record linkage' THEN 0
		WHEN 'Opt-out of LLC' THEN 0
		ELSE 1
END UKLLC_STATUS,
CASE ( w.can_access_medical_records AND p.address_country = 'England') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Scotland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Wales') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_W_Linkage_Permission,
CASE ( w.can_access_medical_records AND p.address_country = 'Northern Ireland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number,
-- ""NHS_S_Linkage_Permission"",""NHS_S_Study_Number"",""NHS_W_Linkage_Permission"",""NHS_NI_Linkage_Permission"",""NHS_NI_Study_Number"",
NULL Geocoding_Permission,
NULL ZoeSymptomTracker_Permission,
'9'  Multiple_Birth,
'0'  National_Opt_Out

FROM
mhbior.consent_form_responses cf, mhbior.participants p

LEFT JOIN mhbior.withdrawals w ON p.id = w.participant_id
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%') 
AND p.id = cf.participant_id"
41,EDGI Registration reminders - 2-3,"/* EDGI Registration reminders - 2-3
 * Date: 25/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 '2' study_id,
 c.contact_method, 
 c.type, 
 NULL sample_barcode,
 c.number,
 p.first_name as forename,
 p.email,
 p.phone,
 c.sent_at,
 last_name,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND ss.name = 'EDGI UK'
 AND ps.consented_at IS NULL
 AND c.study_id = 2
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL
 AND c.type = 'Registration Reminder'
 AND p.registered_at IS NOT NULL
 ;"
36,EDGI Consent reminder 2-4,"/* EDGI Consent reminder 2_Questionnaire is waiting (4 wks) - 
 * Date: 18/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 c.study_id,
 c.contact_method, 
 c.type, 
 NULL sample_barcode,
 c.number,
 p.first_name as forename,
 p.email,
 p.phone,
 c.sent_at,
 last_name,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND ss.name = 'EDGI UK'
 AND ps.consented_at IS NOT NULL
 AND  c.study_id = 2
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL
 AND c.type = 'Consent Reminder';"
16,GLAD Consent reminder 1_You're half way there (2 weeks) (pt 1),"/* GLAD Consent reminder 1_You're half way there (2 weeks) - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 /* not as useful as original format */
 
 USE mhbior;
 
 SELECT
 aliases,
 p.id as 'Participant id',
 ps.consented_at,
 first_name as forename,
 last_name,
 p.email,
 p.phone,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 
 FROM participants p, participant_study ps, samples s, studies ss
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 /*AND NOT LIKE '%Consent Reminder%' */
 AND ss.name = 'GLAD'
 AND ps.consented_at IS NOT NULL
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND ps.manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL;
 /* save as eligible_ppt_DD.MM.YYYY.csv */"
39,GLAD Registration reminders - 2-3,"/* GLAD Registration reminders - 2-3
 * Date: 25/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 '1' study_id,
 c.contact_method, 
 c.type, 
 NULL sample_barcode,
 c.number,
 p.first_name as forename,
 p.email,
 p.phone,
 c.sent_at,
 last_name,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND ss.name = 'GLAD'
 AND ps.consented_at IS NULL
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL
 AND c.type = 'Registration Reminder'
 AND p.registered_at IS NOT NULL
 ;"
54,EDGI Newsletter - Has not returned kit,"/* EDGI Newsletter - Has not returned kit 
 * Date: 14/08/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who are to be sent a newsletter and have not returned a kit. 
 This includes participants who have consented but not finished questionnaire, participants who were sent a questionnaire, and participant who were sent a kit*/
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 ps.first_name as forename,
 ps.email,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ss.name = 'EDGI UK' 
 AND ps.withdrew_at IS NULL
 AND ps2.consented_at IS NOT NULL
 AND ps.email IS NOT NULL
 AND (s.study_id = 2 AND s.date_kit_received IS NULL)
 ;"
31,GLAD Newsletter - Has not returned kit,"/* GLAD Newsletter - Has not returned kit 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who are to be sent a newsletter and have not returned a kit. 
 This includes participants who have consented but not finished questionnaire, participants who were sent a questionnaire, and participant who were sent a kit*/
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 ps.first_name as forename,
 ps.email,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ss.name = 'GLAD' 
 AND ps.withdrew_at IS NULL
 AND ps2.consented_at IS NOT NULL
 AND ps.email IS NOT NULL
 AND (s.study_id = 1 AND s.date_kit_received IS NULL)
 ;"
64,Johan scratch,"SELECT
jt.alias_matched STUDY_ID,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
p.address_line_1 ADDRESS_1,
p.address_line_2 ADDRESS_2,
p.address_city ADDRESS_3,
p.address_county ADDRESS_4,
'' ADDRESS_5,
p.address_post_code POSTCODE,
p.phone PHONE_NUMBER,
p.email,
p.date_of_birth DATE_OF_BIRTH,
p.date_of_death DATE_OF_DEATH,
p.gender_biological,
CASE  p.gender_identity
   			WHEN 'male' THEN 'male'
            WHEN 'female' THEN 'female'
            WHEN 'other' THEN 'other'
            ELSE p.gender_biological
END gender_identity,
ps2.consented_at CONSENT_ACCEPTED,
cf.version CONSENT_FORM_VERSION,
p.created_at CREATE_DATE,
-- destruction_request (value 1: request to destroy data, value 0: we are allowed to keep their data)
-- withdraw_samples (value 1: request to destroy samples, value 0: we are allowed to keep their sample)
w.llc_opt_out_outcome UKLLC_STATUS,	
/* CASE w.can_access_medical_records 
		WHEN '1' THEN '1'
		ELSE '0'
END withdrawn,
*/
-- '1'  National_Opt_Out,
CASE WHEN w.withdrew_at IS NULL
	THEN 0
	ELSE 1
END withdrawn,
w.withdrew_at,
w.reason withdrew_reason,
w.instigated_by withdrawn_by,
CASE WHEN w.sample_destruction_requested_at IS NULL
	THEN 0
	ELSE 1
END destruction_request,
is2.label information_sheet
FROM 
mhbior.participants p
LEFT JOIN mhbior.withdrawals w 
			ON p.id = w.participant_id
LEFT JOIN mhbior.participant_study ps 
   		    ON ps.participant_id = p.id
LEFT JOIN mhbior.studies s
			ON  s.id = ps.study_id
LEFT JOIN mhbior.consent_form_responses cfr
			ON cfr.participant_id  = p.id
LEFT JOIN mhbior.participant_study ps2 
            ON ( ps2.consent_form_response_id = cfr.id AND ps2.participant_id = p.id AND ps2.study_id = s.id)		
LEFT JOIN mhbior.consent_forms cf 
            ON ( cf.id = cfr.consent_form_id AND cf.study_id = s.id)
LEFT JOIN mhbior.information_sheets is2 
			ON ps.information_sheet_id = is2.id 
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%') 
AND s.name = 'GLAD'
AND jt.alias_matched IS NOT NULL
AND p.account_type = 'Active'
AND jt.alias_matched REGEXP '^GLAD[0-9]{6}$'
AND cf.study_id  = 1
AND cfr.created_at < '2024-10-03'"
29,GLAD email reminder MHBIOR (registration 1) - IN CURRENT USE," /* GLAD reminder email (registration 1)
 * Date: 27/02/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id as 'Participant id',
 /*ps2.consented_at,
 #ps.first_name as forename,
 #last_name as surname, 
 #ps.email,
 #ps.phone as mobile, */
 ps2.export_eligibility_state,
 ps.registered_at

FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND account_type = 'Active'
AND ps.withdrew_at IS NULL
AND ss.name = 'GLAD'
AND ps.email IS NOT NULL
AND date_kit_sent IS NULL
AND ps2.consented_at IS NULL
AND ps.registered_at IS NOT NULL;"
8,GLAD saliva kits sent - England,"/* GLAD saliva kits sent - England - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT DISTINCT
 aliases,
 ps.id,
 barcode,
 s.date_kit_sent,
 address_country
 
 FROM participants ps, samples s, participant_study ps2, studies ss, withdrawals w
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND date_kit_sent IS NOT NULL
 AND account_type = 'Active'
 AND ss.name = 'GLAD'
 AND sample_destruction_requested_at IS NULL
 AND address_country = 'England'
 AND ps2.export_eligibility_state = 1;"
43,Kits not receipted by NBC,"/* Kits not receipted by NBC - 
 * Date: 10/07/2024
 * Author: Chelsea Mika Malouf
 Purpose: RM vs NBC report to see what kits have been delivered but not receipted by lab
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 s.study_id,
 s.barcode as sample_barcode,
 royal_mail_tracking_id as tracking_id,
 s.date_kit_sent,
 s.date_kit_received

 FROM participants ps, samples s, participant_study ps2
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND ps.withdrew_at IS NULL
 AND s.date_kit_received IS NULL
 AND s.date_kit_sent IS NOT NULL
 AND royal_mail_tracking_id IS NOT NULL;"
6,GLAD CPMS Report,"/* CPMS GLAD Report
* Date: 13/11/2023
* Modified Date: 19/02/24
* Author: Chelsea Mika Malouf/Ian Marsh/Laura Meldrum
*/
 
USE mhbior;
 
SELECT 
JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
ps.id,
ns.legacy_code,
DATE_FORMAT(consented_at, '%d/%m/%Y') consented_at,
ps2.export_eligibility_state, 
ps2.manual_eligibility_state

FROM participants ps
INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id 
INNER JOIN studies ss ON ss.id = ps2.study_id
LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id

WHERE ps2.study_id = 1
  AND (ps2.manual_eligibility_state = TRUE
    OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE)
  )
  AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test')
  AND account_type = 'Active';"
55,GLAD Newsletter - Has returned kit,"/* GLAD Newsletter - Has returned kit 
 * Date: 14/08/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who are to be sent a newsletter and have returned a kit.*/
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 ps.first_name as forename,
 ps.email,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ss.name = 'GLAD' 
 AND (ps.first_name NOT LIKE 'test%' OR ps.last_name NOT LIKE 'test%')
 AND ps.withdrew_at IS NULL
 AND ps2.consented_at IS NOT NULL
 AND ps.email IS NOT NULL
 AND s.study_id = 1 
 AND s.date_kit_received IS NOT NULL
 AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
 ;"
49,All kits MHBIOR,"/* All kits MHBIOR
 * Date: 24/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 s.barcode,
 s.royal_mail_tracking_id,
 s.date_kit_received,
 s.date_kit_sent,
 s.study_id,
 s.type,
 s.nhs_provided, 
 s.kit_unusable, 
 s.destruction_certificate
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND s.date_kit_sent IS NOT NULL
 ;"
17,GLAD Study saliva kits to be sent out,"/* GLAD Study saliva kits to be sent out - 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT 
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 s.study_id,
 barcode,
 royal_mail_tracking_id,
 date_kit_sent,
 first_name,
 last_name,
 address_line_1,
 address_line_2,
 address_city,
 address_county,
 address_post_code
 
FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE  ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND (ps2.export_eligibility_state = 1 OR manual_eligibility_state = 1)
 AND date_kit_sent IS NULL
 AND date_kit_received IS NULL
 AND ps.withdrew_at IS NULL
 AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test') 
 AND ss.name = 'GLAD'
 AND address_line_1 IS NOT NULL
 AND s.study_id = 1
 AND s.type = 'Saliva'
 AND nhs_provided = 'No'
 AND account_type = 'Active';"
45,LLC_file1_mhbior_EDGI,"/* LLC File1 creation script EDGI
 * Author : Ian Marsh and Mika Malouf
 * Date : 16/07/2024
 */
 
SELECT
jt.alias_matched STUDY_ID,
'C' ROW_STATUS,
p.nhs_number NHS_NUMBER,
p.last_name SURNAME,
p.first_name FORENAME,
'' MIDDLENAMES,
p.address_line_1 ADDRESS_1,
p.address_line_2 ADDRESS_2,
p.address_city ADDRESS_3,
p.address_county ADDRESS_4,
'' ADDRESS_5,
p.address_post_code POSTCODE,
NULL ADDRESS_START_DATE,
NULL ADDRESS_END_DATE,
p.date_of_birth DATE_OF_BIRTH,
CASE  p.gender_identity
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'unknown' THEN 9
            ELSE 9
END GENDER_CD,
'16/07/2024' CREATE_DATE,
w.llc_opt_out_outcome UKLLC_STATUS,
-- p.address_country,
-- w.can_access_medical_records,
CASE ( w.can_access_medical_records AND p.address_country = 'England') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Scotland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Wales') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_W_Linkage_Permission,
CASE ( w.can_access_medical_records AND p.address_country = 'Northern Ireland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number,
-- ""NHS_S_Linkage_Permission"",""NHS_S_Study_Number"",""NHS_W_Linkage_Permission"",""NHS_NI_Linkage_Permission"",""NHS_NI_Study_Number"",
'2' Geocoding_Permission,
'1'  ZoeSymptomTracker_Permission,
'9'  Multiple_Birth,
'1'  National_Opt_Out

FROM
mhbior.consent_form_responses cf, mhbior.participants p

LEFT JOIN mhbior.withdrawals w ON p.id = w.participant_id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE ( p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND p.id = cf.participant_id
AND cf.created_at IS NOT NULL
AND jt.alias_matched REGEXP '^EDGI[0-9]{6}$';"
33,GLAD eligible,"/* GLAD completed questionnaire (eligible and ineligible) - 
 * Date: 18/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id as 'Participant id',
 p.email,
 first_name forename,
 last_name surname,
 ps.export_eligibility_state,
 consented_at,
 ps.manual_eligibility_state
 
 FROM participants p, participant_study ps, studies s
 WHERE p.id = ps.participant_id 
 AND s.id =ps.study_id 
 AND (ps.export_eligibility_state = 1 OR ps.manual_eligibility_state = 1)
 AND p.withdrew_at IS NULL
 AND s.name = 'GLAD'
 AND account_type = 'Active';"
42,EDGI Eligibility Email (kit on its way)," /* EDGI Eligibility Email (kit on its way)
 * Date: 09/07/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT 
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
AND date_kit_sent = '2026-01-08';"
22,GLAD Eligibility Email (kit on its way)," /* GLAD Eligibility Email (kit on its way)
 * Date: 31/01/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT 
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
AND date_kit_sent = '2026-01-08';"
65,GLAD email reminder MHBIOR (registration 1) v2 - NOT IN USE,"/*GLAD reminder email (registration 1) v2
  Date: 22/05/2025
  Author: Laura Meldrum */
 
SELECT JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) AS Aliases, 
p.id AS 'Participant id', 
p.first_name AS Forename,
p.last_name AS Surname, 
p.email AS 'Email address',
p.phone AS 'Phone number',
p.registered_at, 
ps.export_eligibility_state AS export_eligibility, 
ps.manual_eligibility_state AS manual_eligibility, 
ps.consented_at

FROM participants p

JOIN participant_study ps on ps.id = p.id
LEFT JOIN consent_form_responses cf on cf.participant_id = p.id
LEFT JOIN communications c on c.participant_id = p.id
LEFT JOIN withdrawals w on w.participant_id = p.id

WHERE p.account_type = 'Active'
AND cf.participant_id is NULL
AND c.participant_id is NULL
AND w.participant_id is NULL
AND p.withdrew_at is NULL
AND ps.study_id = 1
AND ps.export_eligibility_state IS NULL 
AND ps.manual_eligibility_state IS NULL
;

/*
Issues - LM 22/05/2025
are participants who have already consented still in this report?
are all withdrawn participants removed from this report?
does this remove all people who have already had a registration reminder? no it does not (obscured-1699250890-654882ca8c720@example.co.uk)
EDGI participants are in this list
why are there some consent dates in the consented_at column that do not match MHBIOR?

Testing: go through the usual registration reminders process and check if there are participants who are being removed in the merging steps*/"
38,EDGI CPMS Report,"/* CPMS EDGI
* Date: 24/06/2024
* Modified Date: 
* Author: Laura Meldrum, Mika Malouf
*/
 
USE mhbior;

SELECT 
--JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
CASE
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]')) REGEXP '^EDGI[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]'))
    ELSE NULL
END AS aliases,
ps2.participant_id,
ps2.study_id,
ns.legacy_code,
DATE_FORMAT(consented_at, '%d/%m/%Y') consented_at,
ps2.export_eligibility_state, 
ps2.manual_eligibility_state

FROM participants ps
INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id 
INNER JOIN studies ss ON ss.id = ps2.study_id
LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id

WHERE ps2.study_id = 2
  AND (ps2.manual_eligibility_state = TRUE
    OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE)
    )
 AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test')
 AND account_type = 'Active';"
56,EDGI Newsletter - Has returned kit,"/* EDGI Newsletter - Has returned kit 
 * Date: 14/08/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who are to be sent a newsletter and have returned a kit.*/
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 ps.first_name as forename,
 ps.email,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ss.name = 'EDGI UK' 
 AND (ps.first_name NOT LIKE 'test%' OR ps.last_name NOT LIKE 'test%')
 AND ps.withdrew_at IS NULL
 AND ps2.consented_at IS NOT NULL
 AND ps.email IS NOT NULL
 AND s.study_id = 2
 AND s.date_kit_received IS NOT NULL
 AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
 ;"
34,GLAD consented not finished survey,"/* GLAD consented participants who have not yet completed their baseline questionnaire- 
 * Date: 18/06/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id as 'Participant id',
 p.email,
 p.phone as mobile,
 first_name forename,
 last_name surname,
 ps.export_eligibility_state,
 consented_at,
 ps.manual_eligibility_state
 
 FROM participants p, participant_study ps, studies s
 WHERE p.id = ps.participant_id 
 AND s.id =ps.study_id 
 AND ps.export_eligibility_state IS NULL 
 AND ps.manual_eligibility_state IS NULL
 AND ps.consented_at IS NOT NULL
 AND p.withdrew_at IS NULL
 AND s.name = 'GLAD'
 AND account_type = 'Active';"
66,0_mbc_test_query,"SELECT count(*) 
FROM
  participants"
67,EDGI CPMS Report v2 - IN CURRENT USE,"/* CPMS EDGI Report v2
* Date: 28/22/2025
* Modified Date: 
* Author: Mark Cunningham (adapted from previous scripts by Laura Meldrum, Chelsea Mika Malouf, Ian Marsh)
*/

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
WHERE (ps2.manual_eligibility_state = TRUE OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE) )
  AND (UPPER(ps.first_name) <> 'TEST' OR UPPER(ps.last_name) <> 'TEST')
  AND ps.account_type = 'Active'
;"
63,GLAD CPMS Report v3 - IN CURRENT USE,"/* CPMS GLAD Report v3
* Date: 27/11/2025
* Modified Date: 
* Author: Mark Cunningham (adapted from previous scripts by Laura Meldrum, Chelsea Mika Malouf, Ian Marsh)
*/
 
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
WHERE 
(ps2.manual_eligibility_state = TRUE OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE))
  AND (UPPER(ps.first_name) <> 'TEST' OR UPPER(ps.last_name) <> 'TEST')
  AND ps.account_type = 'Active'
;"
28,GLAD NBSM ID creation,"/* GLAD NBSM ID creation - 
 * Date: 15/02/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list NBSM ids */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 ps.email,
 ps.date_of_birth,
 s.date_kit_received,
 bio_resource_id,
 s.study_id

 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND s.study_id = ss.id
 AND bio_resource_id IS NULL
 AND ss.name = 'GLAD'
 AND s.study_id = 1
 AND s.date_kit_received IS NOT NULL
 AND ps.withdrew_at IS NULL
 AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test') 
 AND ps.account_type = 'Active'
 ;"
20,EDGI email reminder,"-- Criteria for registration reminder email 2 - version 2
-- Project id 15 = Bioresource_RR

/*SELECT rd1.record participant_id,
       rd1.value forename,
       cd.value email,
       DATE_FORMAT(le.ts, ""%Y-%m-%d %H:%i:%s"") registration_date,
       NULL registration_reminder_1,
       NULL registration_reminder_1_date
FROM redcap_data rd1, redcap_data rd2,
     redcap_data cd,
     redcap_log_event le
WHERE rd1.project_id = 15
  AND rd1.record LIKE 'EDGI%'
  AND rd1.record = rd2.record
  AND rd1.event_id = rd2.event_id
  AND rd2.project_id = 15
  AND rd1.record = cd.record
  AND rd1.event_id = cd.event_id
   AND cd.project_id = 15
  AND rd1.field_name = 'forename'
  AND ( rd1.value NOT LIKE 'Test%' OR  rd1.value NOT LIKE 'test%' OR  rd1.value NOT LIKE 'TEST%')
  AND rd2.field_name = 'surname'
  AND ( rd2.value NOT LIKE 'Test%' OR  rd2.value NOT LIKE 'test%' OR  rd1.value NOT LIKE 'TEST%')
  AND cd.field_name = 'email'
  AND rd1.record = le.pk
  AND le.project_id = 15
  AND le.object_type = 'redcap_data'
  AND le.event = 'INSERT'
  AND NOT EXISTS
    ( SELECT 1
     FROM redcap_data rd11
     WHERE rd11.project_id = 15
       AND rd11.record LIKE 'EDGI%'
       AND rd11.field_name = 'extra_registration_reminder_1'
       AND rd11.value = '1'
       AND rd11.record = rd1.record
     UNION  
     SELECT 1
     FROM redcap_data rd2
      WHERE rd2.project_id = 15
       AND rd2.record LIKE 'EDGI%'
       AND rd2.field_name = 'extra_registration_reminder_2'
       AND rd2.value = '1'
       AND rd2.record = rd1.record
      UNION
      SELECT 1 
      FROM  redcap_data rd3
       WHERE rd3.project_id = 15
       AND rd3.record LIKE 'EDGI%'
       AND rd3.field_name = 'extra_registration_reminder_3'
       AND rd3.value = '1'
       AND rd3.record = rd1.record)     
   AND NOT EXISTS 
   ( SELECT 1
     FROM redcap_data rd2
      WHERE rd2.project_id = 15
       AND rd2.record LIKE 'EDGI%'
       AND rd2.field_name = 'registration_reminder_2'
       AND rd2.value = '1'
       AND rd2.record = rd1.record
      UNION
      SELECT 1 
      FROM  redcap_data rd3
       WHERE rd3.project_id = 15
       AND rd3.record LIKE 'EDGI%'
       AND rd3.field_name = 'registration_reminder_3'
       AND rd3.value = '1'
       AND rd3.record = rd1.record)
  AND rd1.record NOT IN
    (SELECT record
     FROM redcap_data
     WHERE project_id = 15
       AND record LIKE 'EDGI%'
       AND field_name = 'consent_date'
       AND value IS NOT NULL )
  AND rd1.record NOT IN
    (SELECT record
     FROM redcap_data
     WHERE project_id = 15
       AND record LIKE 'EDGI%'
       AND field_name = 'withdrawal_complete'
       AND value IS NOT NULL)
ORDER BY le.ts */

 USE mhbior;
 
 SELECT 
 p.id,
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) AS alias1,
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[1]')) AS alias2, 
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[2]')) AS alias3,
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[3]')) AS alias4,
 p.gender_biological AS sex,
 p.gender_identity AS gender,
 p.withdrew_at,
 s.barcode,
 s.date_kit_received
 
FROM participants p, samples s
 WHERE  p.id = s.participant_id; "
51,EDGI NBSM ID creation report,"/* EDGI UK NBSM ID creation - 
 * Date: 29/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list NBSM ids */
 
 USE mhbior;
 
 SELECT
 ps.alias as aliases,
 ps.id,
 ps.email,
 ps.date_of_birth,
 s.date_kit_received,
 bio_resource_id,
 s.study_id
 

 
 FROM 
 participants ps, samples s, participant_study ps2, studies ss
 
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND s.study_id = ss.id
 AND bio_resource_id IS NULL
 AND ss.name = 'EDGI UK'
 AND s.study_id = 2
 AND s.date_kit_received IS NOT NULL
 AND ps.withdrew_at IS NULL
 AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test') 
 AND ps.account_type = 'Active';"
58,GLAD CPMS Report v2 - DO NOT USE,"/* CPMS GLAD Report
* Date: 13/11/2023
* Modified Date: 19/02/24
* Author: Laura Meldrum/Chelsea Mika Malouf/Ian Marsh
*/
 
USE mhbior;
 
SELECT 
--JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
CASE
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[1]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[2]'))
    WHEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]')) REGEXP '^GLAD[0-9]{6}$' THEN JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[3]'))
    ELSE NULL
END AS aliases,
ps.id,
ns.legacy_code,
DATE_FORMAT(consented_at, '%d/%m/%Y') consented_at,
ps2.export_eligibility_state, 
ps2.manual_eligibility_state

FROM participants ps
INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id 
INNER JOIN studies ss ON ss.id = ps2.study_id
LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id

WHERE ps2.study_id = 1
  AND (ps2.manual_eligibility_state = TRUE
    OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE)
  )
  AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test')
  AND account_type = 'Active';"
68,Duplicates," /* Duplicates report
* Date: 02/01/2026
* Modified Date: 08/01/2026
* Author: Laura Meldrum
*/
 
 USE mhbior;
 
SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 ps.first_name as forename,
 ps.last_name as surname,
 ps.email,
 ps.phone as phone_number,
 ps.date_of_birth,
 ps.gender_biological as sex,
 ps.address_city as city,
 ps.address_post_code as postcode,
 ps.account_type,
 ps2.export_eligibility_state, 
 ps2.manual_eligibility_state,
 DATE_FORMAT(ps2.consented_at, '%d/%m/%Y') as consented_at,
 s.date_kit_sent,
 s.date_kit_received
FROM participants ps
JOIN participant_study ps2 
    ON ps.id = ps2.participant_id
JOIN samples s
    ON ps.id = s.participant_id
JOIN (
    SELECT 
        first_name,
        last_name,
        date_of_birth
    FROM participants
    WHERE account_type = 'Active'
    AND first_name != 'Withdraw'
    AND last_name != 'Withdraw'
    AND address_city != 'Withdraw'
    GROUP BY 
        first_name,
        last_name,
        date_of_birth
    HAVING COUNT(*) >= 2
) dup
    ON ps.first_name = dup.first_name
   AND ps.last_name = dup.last_name
   AND ps.date_of_birth = dup.date_of_birth
   ORDER BY 
    ps.first_name,
    ps.last_name,
    ps.date_of_birth,
    ps.id;
"
52,EDGI Saliva reminder 1: Top tips (One week) (sample list),"/* EDGI Saliva reminder 1: Top tips (One week) - 
 * Date: 30/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who were sent a sample but have not returned their sample */
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 s.study_id,
 ps.first_name as forename,
 s.barcode,
 ps.email,
 s.date_kit_sent


 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'EDGI UK'
 AND s.study_id = 2
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL;"
44,LLC_file1_mhbior,"/* LLC File1 creation script GLAD and EDGI
 * Author : Ian Marsh and Mika Malouf
 * Date : 16/07/2024
 */
 
SELECT
jt.alias_matched STUDY_ID,
'C' ROW_STATUS,
p.nhs_number NHS_NUMBER,
CASE p.last_name
           WHEN 'Withdrawal' THEN ''
           ELSE p.last_name
END SURNAME,
CASE p.first_name 
           WHEN 'Withdrawal' THEN ''
           ELSE p.first_name 
END FORENAME,
'' MIDDLENAMES,
NULL ADDRESS_1, /*p.address_line_1 ADDRESS_1,*/
NULL ADDRESS_2, /*p.address_line_2 ADDRESS_2,*/
NULL ADDRESS_3, /*p.address_city ADDRESS_3,*/
NULL ADDRESS_4, /*p.address_county ADDRESS_4,*/
'' ADDRESS_5,
CASE p.address_post_code 
           WHEN 'X12 3YZ' THEN ''
           ELSE p.address_post_code 
END POSTCODE,
NULL ADDRESS_START_DATE,
NULL ADDRESS_END_DATE,
p.date_of_birth DATE_OF_BIRTH,
CASE  p.gender_identity
   			WHEN 'male' THEN 1
            WHEN 'female' THEN 2
            WHEN 'other' THEN 7
            WHEN 'non-binary' THEN 7
            WHEN 'unknown' THEN 9
            ELSE 9
END GENDER_CD,
'14/01/2025' CREATE_DATE,
-- w.llc_opt_out_outcome UKLLC_STATUS,
CASE w.llc_opt_out_outcome
		WHEN 'Opt-out LLC medical record linkage' THEN 0
		WHEN 'Opt-out of LLC' THEN 0
		ELSE 1
END UKLLC_STATUS,
-- p.address_country,
-- w.can_access_medical_records,
/*CASE ( w.can_access_medical_records AND p.address_country = 'England') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Scotland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE ( w.can_access_medical_records AND p.address_country = 'Wales') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_W_Linkage_Permission,
CASE ( w.can_access_medical_records AND p.address_country = 'Northern Ireland') 
		WHEN '0' THEN '0'
		ELSE '1'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number, */
-- ""NHS_S_Linkage_Permission"",""NHS_S_Study_Number"",""NHS_W_Linkage_Permission"",""NHS_NI_Linkage_Permission"",""NHS_NI_Study_Number"",

CASE p.address_country
		WHEN 'England' THEN '1'
		ELSE '0'
END NHS_E_Linkage_Permission,
'9' NHS_Digital_Study_Number,
CASE p.address_country
		WHEN 'Scotland' THEN '1'
		ELSE '0'
END NHS_S_Linkage_Permission,
'9' NHS_S_Study_Number,
CASE p.address_country
		WHEN 'Wales' THEN '1'
		ELSE '0'
END NHS_W_Linkage_Permission,
CASE p.address_country
		WHEN 'Northern Ireland' THEN '1'
		ELSE '0'
END NHS_N_Linkage_Permission,
'9' NHS_N_Study_Number,
'' Geocoding_Permission,
''  ZoeSymptomTracker_Permission,
'9'  Multiple_Birth,
'0'  National_Opt_Out,
ps.consented_at,
ps.study_id

FROM
mhbior.participant_study ps, mhbior.participants p

LEFT JOIN mhbior.withdrawals w ON p.id = w.participant_id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE (p.first_name NOT LIKE 'test%' OR p.last_name NOT LIKE 'test%')
AND p.id = ps.participant_id
AND (jt.alias_matched REGEXP '^GLAD[0-9]{6}$' OR jt.alias_matched REGEXP '^EDGI[0-9]{6}$')
AND ps.consented_at IS NOT NULL
AND account_type = 'Active';"
5,GLAD - kits by country,"/* Kits by country - 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 address_country,
 barcode,
 s.date_kit_sent,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'GLAD'
 AND s.study_id = 1
 AND date_kit_sent IS NOT NULL;"
18,GLAD Saliva reminder 1: Top tips (One week) (sample list),"/* GLAD Saliva reminder 1: Top tips (One week) - 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who were sent a sample but have not returned their sample */
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 s.study_id,
 ps.first_name as forename,
 s.barcode,
 ps.email,
 s.date_kit_sent


 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'GLAD'
 AND s.study_id = 1
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL;"
53,EDGI Saliva reminder 2-7: (2 weeks - 6 months) (communication),"/* EDGI Saliva reminder 2-7
 * Date: 31/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 '2' study_id,
 contact_method, 
 c.type, 
 s.barcode as sample_barcode,
 c.number,
 ps.first_name as forename,
 ps.email,
 ps.phone,
 c.sent_at,
 last_name,
 ps2.export_eligibility_state,
 s.date_kit_sent

 FROM participants ps, samples s, participant_study ps2, studies ss, communications c
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND c.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'EDGI UK'
 AND s.study_id = 2
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL
 AND c.type = 'Sample Reminder';"
60,LLC opt outs,"/* LLC opt outs
 * Date: 06/01/2025
 * Author: Laura Meldrum
 Purpose: To generate a list of LLC opt outs for LLC File 2
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 w.llc_objected_at, 
 w.llc_opt_out_outcome, 
 w.withdrew_at

 FROM participants ps, withdrawals w
 AND w.participant_id = ps.id
 AND w.llc_objected_at IS NOT NULL;"
50,EDGI thank you kit email (kit received)," /* GLAD thank you kit email (kit recieved)
 * Date: 25/07/2024
 * Author: Mika Malouf
 */
 
 /*last time this was run was 2026-01-15*/
 
/* INSTRUCTIONS - PLEASE READ 
 Step 1 - Update line 41 to the date on line 6.
 Step 2 - Update line 6 to the current date. Click execute and save the script
 Step 3 - Export the file and save as export in the SharePoint BioResource R Data edgi > reminders > thank you email folder
 Step 4 - Open the file and remove kits with study_id 1
 Step 5 - Remove duplicates by sample barcode
 Step 6 - Run the html email script and the MHBIOR communications script, then import into communications page on MHBIOR
 */
 
 USE mhbior;
 
SELECT 
/*TRIM('[""' FROM aliases) AS aliases, */
ps.id,
s.study_id,
'Email' contact_method,
'Sample Received' type,
barcode as sample_barcode,
'2' number,
NULL sent_at,
s.date_kit_received,
ps.email,
ps.first_name as forename

FROM participants ps, samples s, participant_study ps2, studies ss-- , communications c
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
-- AND c.participant_id = ps.id
AND ss.name = 'EDGI UK'
AND s.study_id = 2
AND ps.withdrew_at IS NULL
AND date_kit_sent IS NOT NULL
AND date_kit_received >= '2026-01-08';  /* run this report without edits and then update line 39 to todays date */
-- AND c.type <> 'Sample Received';"
61,All withdrawals GLAD and EDGI,"/* All withdrawals GLAD and EDGI
 * Date: 06/01/2025
 * Author: Laura Meldrum
 Purpose: A list of all withdrawals in GLAD and EDGI for LLC File 2
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 ps.id,
 w.llc_objected_at, 
 w.llc_opt_out_outcome, 
 w.withdrew_at

 FROM participants ps, withdrawals w
 AND w.participant_id = ps.id
 AND w.withdrew_at IS NOT NULL;"
