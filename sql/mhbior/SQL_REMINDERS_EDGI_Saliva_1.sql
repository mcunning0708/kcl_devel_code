/* EDGI Saliva reminder 1: Top tips (One week) - 
 * Date: 30/07/2024
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who were sent a sample but have not returned their sample */
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) Aliases,
 ps.id,
 s.study_id,
 ps.first_name as forename,
 s.barcode,
 ps.email,
 s.date_kit_sent


 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ps.withdrew_at  IS NULL
 AND ss.name = 'EDGI UK'
 AND s.study_id = 2
 AND ps.email IS NOT NULL
 AND s.date_kit_received IS NULL
 AND date_kit_sent IS NOT NULL;