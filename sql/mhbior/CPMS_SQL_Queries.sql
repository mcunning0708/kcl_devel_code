use mhbior;

USE mhbior;
select * from participants where id = 40779;
-- Carola PPT 
select * from participants where aliases like '%GLAD035062%';
select * from participants where aliases like '%EDGI001006%';
-- Carola : 17717 / GLADonly 40779 / GLAD & EDGI 10476 
select * from participants where id = 118213;
select * from participant_study where participant_id  = 118213;
select * from consent_form_responses where participant_id  = 118213;
select * from consent_forms;

-- 118213 

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
DATE_FORMAT(ps2.consented_at, '%d/%m/%Y') AS ps2_consented_at, 
DATE_FORMAT( COALESCE(MIN(cfr.created_at), ps2.consented_at), '%d/%m/%Y' ) AS consented_date, 
ps2.export_eligibility_state, 
ps2.manual_eligibility_state
FROM participants ps 
INNER JOIN participant_study ps2 ON ps.id = ps2.participant_id 
INNER JOIN studies ss ON ss.id = ps2.study_id 
LEFT JOIN nhs_sites ns ON ns.id = ps2.nhs_site_id
LEFT JOIN consent_form_responses cfr
	ON ps.id = cfr.participant_id 
WHERE ps2.study_id = 1 
	-- AND ps.id = 40779  
	AND (ps2.manual_eligibility_state = TRUE
    OR (ps2.manual_eligibility_state IS NULL AND ps2.export_eligibility_state = TRUE)
  )
  AND (ps.first_name  <> 'Test' OR ps.first_name  <> 'TEST' OR ps.first_name  <> 'test' OR ps.last_name <> 'Test' OR ps.last_name <> 'TEST' OR ps.last_name <> 'test')
  AND account_type = 'Active'
  GROUP BY ps.id ;
 