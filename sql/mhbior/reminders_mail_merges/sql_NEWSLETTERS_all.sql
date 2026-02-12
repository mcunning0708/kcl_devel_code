use mhbior;

-- original
   select count(*)
   -- JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
   -- ps.id,
   -- ps.first_name as forename,
   -- ps.email, s.study_id, s.date_kit_received, ss.name
   FROM participants ps, samples s, participant_study ps2, studies ss
   WHERE ps.id = s.participant_id
   AND ps2.participant_id = ps.id
   AND account_type = 'Active'
   AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
   AND LOWER(ps.email) not like '%obscured%'
   AND ps.withdrew_at IS NULL
   AND ps2.consented_at IS NOT NULL
   AND ps.email IS NOT NULL
   AND s.date_kit_received IS NOT NULL
   AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
   ;
   -- amended
      select count(*) 
   -- JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
   -- ps.id, ps.first_name as forename, ps.email,
   -- s.study_id, s.date_kit_received, ss.name
   FROM participants ps
   INNER JOIN consent_form_responses cfr
	ON cfr.participant_id = ps.id 
	INNER JOIN participant_study ps2 
    ON ps2.participant_id = ps.id
    INNER JOIN studies ss
    ON ss.id = ps2.study_id
    LEFT JOIN samples s 
    ON ps.id = s.participant_id
   WHERE 
   ps.account_type = 'Active'
   AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
   AND ps.email IS NOT NULL
   AND LOWER(ps.email) not like '%obscured%'
   AND ps.withdrew_at IS NULL
   AND ps2.consented_at IS NOT NULL
   -- AND s.date_kit_received IS NOT NULL
   AND (ps2.export_eligibility_state IS NOT NULL OR ps2.manual_eligibility_state IS NOT NULL)
   ;
   
SELECT 
	ps.id, 
    jt.alias_matched STUDY_ID,
    ps.first_name, ps.email, 
    ps2.study_id, 
    -- DATE_FORMAT( COALESCE(MIN(cfr.created_at), ps2.consented_at), '%d/%m/%Y' ) AS consented_date, 
    cf.id as consent_form_id, cf.active_version, cf.version -- , 
    -- cfi.consent_form_id, cfi.content, cfir.accepted
FROM 
	participants ps
		CROSS JOIN JSON_TABLE( ps.aliases, '$[*]' COLUMNS( alias_matched VARCHAR(255) PATH '$'  ) ) AS jt  
		INNER JOIN participant_study ps2 
		ON ps2.participant_id = ps.id
        INNER JOIN consent_form_responses cfr
		ON cfr.participant_id = ps2.id   
        INNER JOIN consent_forms cf 
        ON ( cf.id = cfr.consent_form_id AND cf.study_id = ps2.study_id )
        /*
        INNER JOIN consent_form_items cfi 
        ON ( cfi.consent_form_id = cf.id AND LOWER(cfi.content) LIKE '%newsletters%' )
        INNER JOIN consent_form_item_responses cfir 
        ON ( cfir.consent_form_item_id = cfi.id ) 
        */
-- GROUP BY ps.id 
-- jt.alias_matched 
WHERE 
	jt.alias_matched REGEXP '^(EDGI|GLAD)[0-9]{6}$'
    AND    ps.account_type = 'Active'
   AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
   AND ps.email IS NOT NULL
   AND LOWER(ps.email) not like '%obscured%'
   AND ps.withdrew_at IS NULL
   AND ps2.consented_at IS NOT NULL
;

select * from consent_forms;
select * from consent_form_items cfi where LOWER(cfi.content) LIKE '%newsletters%';

select * from consent_form_responses where participant_id = 20;
select * from participants where id = 20;
