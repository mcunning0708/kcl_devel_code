31,GLAD Newsletter - Has not returned kit,"/* GLAD Newsletter - Has not returned kit 
 * Date: 13/11/2023
 * Author: Chelsea Mika Malouf
 */
 
 /*this report is to create list of participants who are to be sent a newsletter and have not returned a kit. 
 This includes participants who have consented but not finished questionnaire, participants who were sent a questionnaire, and participant who were sent a kit*/
 
 USE mhbior;
 
 select
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) participant_id,
 ps.id,
 ps.first_name as forename,
 ps.email,
 s.date_kit_received
 
 FROM participants ps, samples s, participant_study ps2, studies ss
 WHERE ps.id = s.participant_id 
 AND ps2.participant_id = ps.id
 AND account_type = 'Active'
 AND ss.name = 'GLAD' 
 AND ps.withdrew_at IS NULL
 AND ps2.consented_at IS NOT NULL
 AND ps.email IS NOT NULL
 AND (s.study_id = 1 AND s.date_kit_received IS NULL)
 ;"
