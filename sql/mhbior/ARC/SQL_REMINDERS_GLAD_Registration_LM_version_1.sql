/*GLAD reminder email (registration 1) v2
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

Testing: go through the usual registration reminders process and check if there are participants who are being removed in the merging steps*/