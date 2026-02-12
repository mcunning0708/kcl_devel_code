/* CPMS GLAD Report
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
  AND account_type = 'Active';