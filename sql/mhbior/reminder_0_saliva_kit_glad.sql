 /* GLAD Eligibility Email (kit on its way)
 * Date: 31/01/2024
 * Author: Mika Malouf
 */
 

USE mhbior;
 
SELECT 
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
barcode,
-- ps2.study_id,
ss.name study_name,
s.date_kit_sent,
ps.email,
ps.first_name as forename

FROM participants ps, samples s, participant_study ps2, studies ss
WHERE ps.id = s.participant_id 
AND ps2.participant_id = ps.id
AND ss.id = ps2.study_id
AND ss.name = 'GLAD'
AND s.study_id = 1
AND ps.withdrew_at IS NULL
AND date_kit_sent = '2025-10-07'
