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
