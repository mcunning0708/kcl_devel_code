use mhbior;
select count(*) from v_LLC_file1_return;
/* EDGI reminder email (registration 1)
 * Date: 25/06/2024
 * Author: Mika Malouf
 */
 

-- GET COUNTS for LLC File1 Checker Program 

USE mhbior;
 
select count(*) from v_LLC_file1_return; 
-- REMEMBER THIS changes 
-- as of 29 January was 93,477
select count(distinct STUDY_ID ) from v_LLC_file1_return;
-- as of 29 January it was 90,103
-- on 28 Jan (when i prepared return ) it was 90,083

SELECT
 -- JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 -- ps.id as 'Participant id',
 -- ps2.export_eligibility_state,
 -- ps.registered_at
 count( jt.alias_matched )
FROM participants AS p
LEFT JOIN withdrawals AS w ON p.id = w.participant_id 
LEFT JOIN participant_study ps2 ON p.id = ps2.participant_id
CROSS JOIN JSON_TABLE( p.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt
-- INNER JOIN consent_form_responses cfr ON p.id =  cfr.participant_id 
-- INNER JOIN samples ss ON p.id = ss.participant_id
WHERE 
(lower(p.first_name) NOT LIKE 'test%' OR lower(p.last_name) NOT LIKE 'test%')
AND lower(p.email) not like '%obscured%' 
AND (jt.alias_matched REGEXP '^GLAD[0-9]{6}$' OR jt.alias_matched REGEXP '^EDGI[0-9]{6}$')
AND ps2.consented_at IS NOT NULL  -- GB : REC said we can include people who have not sent back their saliva kits
AND p.account_type = 'Active' 
-- AND p.deleted_at IS NULL 
--   AND p.email IS NOT NULL
--   AND p.registered_at IS NOT NULL

-- AND p.withdrew_at IS NOT NULL -- ADD to DETERMINE those who withdrew !
-- AND w.can_access_medical_records = '0' -- NO LINKAGE permitted
;

