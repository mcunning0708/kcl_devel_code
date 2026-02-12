/* LLC File1 creation script GLAD and EDGI
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
'18/07/2024' CREATE_DATE,
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
-- "NHS_S_Linkage_Permission","NHS_S_Study_Number","NHS_W_Linkage_Permission","NHS_NI_Linkage_Permission","NHS_NI_Study_Number",

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
AND account_type = 'Active';
