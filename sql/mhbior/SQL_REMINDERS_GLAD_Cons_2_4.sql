/* GLAD Consent reminder 2_Questionnaire is waiting (4 wks) - 
 * Date: 21/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(p.aliases, '$[0]')) aliases,
 p.id,
 cf.study_id,
 c.contact_method, 
 c.type, 
 NULL sample_barcode,
 c.number,
 p.first_name as forename,
 p.email,
 p.phone,
 c.sent_at,
 last_name,
 ps.export_eligibility_state,
 s.date_kit_sent
 
 FROM participants p, participant_study ps, samples s, studies ss, communications c, consent_forms cf
 WHERE p.id = s.participant_id 
 AND ps.participant_id = p.id
 AND ss.id = ps.study_id
 AND c.participant_id = p.id
 AND ss.id = cf.study_id
 AND ss.name = 'GLAD'
 AND ps.consented_at IS NOT NULL
 AND (p.first_name  <> 'Test' OR p.first_name  <> 'TEST' OR p.first_name  <> 'test' OR p.last_name <> 'Test' OR p.last_name <> 'TEST' OR p.last_name <> 'test') 
 AND p.withdrew_at IS NULL
 AND p.account_type = 'Active'
 AND ps.export_eligibility_state IS NULL 
 AND manual_eligibility_state IS NULL
 AND s.date_kit_sent IS NULL
 AND s.date_kit_received IS NULL
 AND (c.type = 'Consent Reminder' and c.study_id = 1);