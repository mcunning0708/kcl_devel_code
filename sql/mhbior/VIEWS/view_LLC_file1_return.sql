/* LLC File1 creation script
 * Author : Mark Cunningham (Prev versions all conflict)
 * Date : 15/01/2026
 * Revision 15/01/2026
 */
 use mhbior; 

 -- BASED on SQL used in REMINDERS process 
 drop view v_LLC_file1_return; 
 
create view v_LLC_file1_return as 
SELECT
-- 	JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) Aliases,
-- 	p.id,
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
p.address_country ADDRESS_5,
p.address_post_code POSTCODE,
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
p.created_at CREATE_DATE,
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
END NHS_NI_Linkage_Permission,
'9' NHS_NI_Study_Number,
'2' Geocoding_Permission,
'' Small_Area_Permission, 
'' Environment_Permission, 
'' Property_Level_Permission, 
'9' Multiple_Birth, 
'0' National_Opt_Out, 
'' DFE_Linkage_Permission, 
'' DWP_Linkage_Permission, 
'' HMRC_Linkage_Permission
FROM
participants p   
LEFT JOIN withdrawals AS w 
	ON p.id = w.participant_id 
LEFT JOIN participant_study AS ps
	ON p.id = ps.participant_id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
WHERE (lower(p.first_name) NOT LIKE 'test%' OR lower(p.last_name) NOT LIKE 'test%')
AND lower(p.email) not like '%obscured%' 
AND (jt.alias_matched REGEXP '^GLAD[0-9]{6}$' OR jt.alias_matched REGEXP '^EDGI[0-9]{6}$')
AND ps.consented_at IS NOT NULL
AND account_type = 'Active'
-- ? looks like we do NOT want clause below, reduces count to 9  ? 
-- AND w.can_access_medical_records  IS NOT NULL
;