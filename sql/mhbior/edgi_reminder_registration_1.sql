/* EDGI reminder email (registration 1)
 * Date: 25/06/2024
 * Author: Mika Malouf
 */
 

USE mhbior;

--
create view v_edgi_registration_1a as 
-- 
SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 --
 CASE
    WHEN JSON_LENGTH(ps.aliases) > 0 THEN
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, CONCAT('$[', JSON_LENGTH(ps.aliases) - 1, ']')))
    ELSE
      NULL
  END AS last_alias, 
 --
 ps.id as 'Participant id',
 ps2.export_eligibility_state,
 ps.registered_at

FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND account_type = 'Active'
AND ps.withdrew_at IS NULL
AND ss.name = 'EDGI UK'
AND ps.email IS NOT NULL
AND date_kit_sent IS NULL
AND ps2.consented_at IS NULL
AND ps.registered_at IS NOT NULL;


--
create view v_edgi_registration_1b as ;
--
