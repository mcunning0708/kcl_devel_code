use mhbior; 

DROP VIEW v_consent_forms_newsletter_response;

-- THIS VIEW SHOULD return CRITICAL consent form data INCL whether or not PPT wishes to receive newsletters
CREATE VIEW v_consent_forms_newsletter_response AS  
WITH filtered_aliases AS (
    SELECT
        ps.id,
        TRIM(jt.alias_matched) AS alias_matched, 
        CASE LEFT( TRIM(jt.alias_matched), 4 ) 
          WHEN 'GLAD' THEN 1 
          WHEN 'EDGI' THEN 2 
          ELSE NULL 
		END AS derived_study_id 
    FROM participants ps
    CROSS JOIN JSON_TABLE(
        ps.aliases, '$[*]'
        COLUMNS(alias_matched VARCHAR(255) PATH '$')
    ) jt
    WHERE TRIM(jt.alias_matched) REGEXP '^(EDGI|GLAD)[0-9]{6}$'
),
-- If cfr records are per participant (no study_id in cfr):
cfr_one AS (
    SELECT cfr.participant_id, cf.study_id, 
    MIN(cfr.created_at) AS first_cfr_at, MIN(cf.id) as first_cf_id, MIN(cf.version) as cf_version  
    FROM consent_form_responses cfr 
    INNER JOIN consent_forms cf 
		ON ( cf.id = cfr.consent_form_id )
	GROUP BY participant_id, study_id 
        -- AND cf.study_id = ps2.study_id )GROUP BY participant_id
)
SELECT 
    fa.id,
    fa.alias_matched, 
    fa.derived_study_id,
    ps.first_name, 
    ps.email, 
    cfr1.first_cf_id, cfr1.first_cfr_at, cfr1.study_id, cfr1.cf_version, 
    cfir.accepted as newsletter_response 
    -- COALESCE(cfr.first_cfr_at, ps2.consented_at) AS cfr_consented_date
FROM 
-- IMPORTANT tp START with 2 sub Selects ABOVE THEN JOIN 
filtered_aliases fa
INNER JOIN participants ps 
  ON ps.id = fa.id
-- do NOT rely on participant_study ps2 in this VIEW 
INNER JOIN cfr_one cfr1
	ON ( cfr1.participant_id = ps.id AND cfr1.study_id = fa.derived_study_id )
INNER JOIN consent_form_items cfi 
	ON ( cfi.consent_form_id = cfr1.first_cf_id AND LOWER(cfi.content) LIKE '%newsletters%' )
LEFT JOIN consent_form_item_responses cfir 
	ON ( cfir.consent_form_item_id = cfi.id 
		AND cfir.participant_id = fa.id 
		-- AND cfir.consent_form_response_id = cfr1.first_cf_id 
        -- ??? MUST CHECK if ABOVE is necessary  ??? 
        )        
WHERE 
    -- ps.id > 19 AND ps.id < 1000 AND 
	ps.account_type = 'Active'
	AND (LOWER(ps.first_name) NOT LIKE 'test%' OR LOWER(ps.last_name) NOT LIKE 'test%')
	AND LOWER(ps.email) not like '%obscured%'
	AND ps.email IS NOT NULL
	AND ps.withdrew_at IS NULL
;

