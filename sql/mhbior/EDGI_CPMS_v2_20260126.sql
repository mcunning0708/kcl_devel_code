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
