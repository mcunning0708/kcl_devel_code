/* EDGI Saliva reminder 2-7
 * Date: 31/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 USE mhbior;
 
 SELECT
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 '2' study_id,
 contact_method, 
 c.type, 
 s.barcode as sample_barcode,
 c.number,
 ps.first_name as forename,
 ps.email,
 ps.phone,
 c.sent_at,
 last_name,
 ps2.export_eligibility_state,
 s.date_kit_sent

 FROM participants ps, samples s, participant_study ps2, studies ss, communications c
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND c.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'EDGI UK'
 AND s.study_id = 2
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL
 AND c.type = 'Sample Reminder';