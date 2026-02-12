drop view v_active_participants_reminders; 


create view v_active_participants_reminders as 
select
  JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) Aliases,
  p.id,
  p.first_name as ppt_forename, p.last_name as ppt_surname, 
  p.email as ppt_email,
  p.phone as ppt_mobile, 
  p.created_at, p.registered_at, 
  ps.consented_at, 
  ps.export_eligibility_state, ps.manual_eligibility_state, 
  cfr.consent_form_id, cf.active_version, cf.label, cf.version, 
  ss.id as study_id, 
  ss.name as study_name, 
  ss.email as study_email, 
  s.barcode,
  s.date_kit_sent, 
  s.date_kit_received
 FROM participants as p
 -- , samples s, participant_study ps, studies ss
	INNER JOIN participant_study AS ps
		ON p.id = ps.participant_id 
	INNER JOIN studies ss 
		ON ps.study_id = ss.id 
	LEFT JOIN samples as s 
		ON p.id = s.participant_id 
	LEFT JOIN consent_form_responses cfr
		ON p.id = cfr.participant_id
	LEFT JOIN consent_forms cf
		ON cfr.consent_form_id = cf.id 
 WHERE p.account_type = 'Active'
   AND p.withdrew_at IS NULL
   AND lower(p.email) not like '%obscured%' 
 -- BELOW WAS FOR TESTING ONLY
 -- AND s.date_kit_sent is null 
 ;

