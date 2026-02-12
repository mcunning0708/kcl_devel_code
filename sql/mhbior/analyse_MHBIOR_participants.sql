use mhbior;

select count(*) from participants ps 
-- BELOW is critical 
where ps.deleted_at is null ;

SHOW Columns from participants; 

-- Get Data for Analysis of MHBIOR data v that in REDCap_AWS
SELECT
 ps.id as 'Participant id',
 JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) aliases,
 CASE
    WHEN JSON_LENGTH(ps.aliases) > 0 THEN
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, CONCAT('$[', JSON_LENGTH(ps.aliases) - 1, ']')))
    ELSE
      NULL
  END AS last_alias, 
 ps.first_name, ps.last_name, 
 ps.gender_biological, ps.gender_identity,
 ps.date_of_birth, ps.email, ps.address_post_code 
 from participants ps
 where ps.deleted_at is null ;
 INTO outfile 'C:\Users\k2585744\Downloads\WSL\data_mhbior\MySQL_temp'
 FIELDS terminated by '\t'
 lines terminated by '\n';
 
 -- CHECKING those discovered in "\\wsl.localhost\Ubuntu\home\k2585744\projects_wsl\R\analyse_REDCapAWS_MHBIOR_participants.R"
-- EXISTS
 select * 
 from participants ps 
	WHERE JSON_SEARCH(aliases, 'all', 'GLAD000006') IS NOT NULL;
 -- PERHAPS DOES NOT EXIST EDGI009335 ; EDGI017806 ; GLAD000000 ; GLAD117662; GLAD118176
 select * 
 from participants ps 
	WHERE JSON_SEARCH(aliases, 'all', 'GLAD118176') IS NOT NULL;
 