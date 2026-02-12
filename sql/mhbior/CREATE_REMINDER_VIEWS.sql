use mhbior;

select count(*) from participants; 
show columns from participants;
select 'mc';

-- drop view v_active_participants;
-- drop view v_active_participants_reminders;

-- PURELY based on participants table 
create view v_active_participants_table_only as 
	select * from participants ps 
		where lower(ps.email) not like '%obscured%' 
		and ps.account_type = 'Active'
		and ps.withdrew_at IS NULL; ;
 
 -- BASED on SQL used in REMINDERS process 
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

-- drop view v_communications_reminders; 
create view v_communications_reminders as 
select
	JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) Aliases,
	p.id,
	p.first_name as ppt_forename, p.last_name as ppt_surname, 
	p.email as ppt_email,
    p.phone as ppt_mobile, 
    p.created_at, p.registered_at, 
    ps.consented_at, 
    ps.export_eligibility_state, ps.manual_eligibility_state, 
    ss.id as study_id, 
    ss.name as study_name, 
    ss.email as study_email, 
	s.barcode,
	s.date_kit_sent, 
    s.date_kit_received, 
    c.type, c.contact_method, c.number, c.sent_at, c.communication_import_id 
 FROM participants as p
 -- , samples s, participant_study ps, studies ss
	INNER JOIN participant_study AS ps
		ON p.id = ps.participant_id 
	INNER JOIN studies AS ss 
		ON ps.study_id = ss.id 
	-- MUST review JOINS below  
	INNER JOIN communications AS c 
		on p.id = c.participant_id 
	LEFT JOIN samples AS s 
		ON p.id = s.participant_id 

 WHERE p.account_type = 'Active'
 AND p.withdrew_at IS NULL
 AND lower(p.email) not like '%obscured%' 
 -- BELOW WAS FOR TESTING ONLY
 -- AND s.date_kit_sent is null 
 ;
 
 -- ANALYSE BELOW & check ok ..
select count(*) from v_active_participants_table_only;
select * from v_active_participants_reminders limit 10;
select count(distinct id) from v_active_participants_reminders;
select count(*) from v_communications_reminders;
select count(distinct id) from v_communications_reminders;