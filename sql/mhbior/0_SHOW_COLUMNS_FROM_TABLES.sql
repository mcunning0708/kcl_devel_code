use mhbior;

select upper('abc');
select Now() - '16/07/2024' time_passed;
SELECT DATEDIFF(NOW(), '2024-11-25') AS days_passed;
-- SELECT JSON_UNQUOTE(JSON_EXTRACT(["a","b","c"], '$[0]')) as a1 ; 
select count(*) from participants ps where email like '%obscured%';

select * from v_test;
show columns from communications;
SHOW Columns from consent_forms; 
show columns from consent_form_responses;
show columns from consent_form_items;
show columns from consent_form_item_responses;
show columns from participants; 
show columns from participant_study;
show columns from samples;
show columns from studies;

select * from participant_study order by created_at desc limit 10;
show columns from studies;
select * from studies;
show columns from samples;
show columns from communications; 
select * from communications 
    -- order by created_at desc limit 10;
	where participant_id = 131593;
    
select * from v_communications_reminders
	where id = 131593;  
select max(id) from v_communications_reminders;

select distinct communication_import_id from communications; 

show columns from consent_forms;
select * from consent_forms;
select count(*) from consent_forms;
show columns from consent_form_responses;
select * from consent_form_responses;
select count(*) from consent_form_responses;
select count(distinct participant_id) from consent_form_responses;
SET @consent_form_id := /*prompt*/ '2';
show columns from consent_form_items;
select * from consent_form_items;
select * from consent_form_items WHERE consent_form_id = @consent_form_id;
select count(*) from consent_form_items;
show columns from consent_form_item_responses;
select * from consent_form_item_responses LIMIT 10;
select count(*) from consent_form_item_responses; -- 1,563,677 on 4 Feb 2026 
show columns from consent_form_responses;
select * from consent_form_responses LIMIT 10;
select count(*) from consent_form_responses;
select count(distinct participant_id) from consent_form_responses;
select count(distinct consent_form_id) from consent_form_responses;

create view v_test_markc as 
	select 
	name, id, 
	long_description from studies;

SELECT
 aliases, JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, '$[0]')) as first_alias,
  CASE
    WHEN JSON_LENGTH(ps.aliases) > 0 THEN
      JSON_UNQUOTE(JSON_EXTRACT(ps.aliases, CONCAT('$[', JSON_LENGTH(ps.aliases) - 1, ']')))
    ELSE
      NULL
  END AS last_alias
FROM participants ps 
limit 100;

select * from participants limit 10;
select count(*) from participants ps 
-- BELOW is critical 
where ps.deleted_at is null ;
and	ps.account_type = 'Active';

SHOW Columns from participants; 
show columns from consent_forms;
SHOW Columns from participant_study; 
select count(*) from participant_study where consented_at is not null;
SHOW Columns from studies; 
-- RECREATE Step 1a 
SELECT ps.id, ps.email, ps.registered_at 
FROM participants ps -- limit 10;
JOIN participant_study ps2 ON ps2.participant_id = ps.id
JOIN studies ss ON ss.id = ps2.study_id
WHERE ps.deleted_at is null 
AND ps.account_type = 'Active'
AND ss.name = 'EDGI UK' 
AND ps.withdrew_at IS NULL
AND ps2.consented_at IS NOT NULL
order by ps.registered_at desc; 


-- investigate Step 2
SHOW Columns from consent_forms; 
select * from consent_forms;
select * from participant_study limit 10;
select distinct study_id from consent_forms;
-- recreate step 2 .... 
SELECT cf.label, cf.version  
FROM consent_forms cf 
-- JOIN participant_study ps2 ON ps2.participant_id = ps.id
JOIN studies ss ON ss.id = cf.study_id 
WHERE ss.name = 'EDGI UK';  

-- recreate step 3
SHOW Columns from communications; 
select * from communications limit 10;

SELECT 
count(*) 
-- c.participant_id, c.type, c.contact_method, c.sent_at, c.number 
FROM communications c 
WHERE 
	c.type = 'Registration Reminder' 
	and c.study_id = 2 
    and c.number = 1;
--  multiple schemas ? 
SHOW DATABASES;
--list tables in schema  = mhbior
SHOW TABLES FROM mhbior;

-- for TM
-- it is possible to allow a MySQL user like kcl_sgdp_readonly to create views without giving them write access to any existing tables.
-- Grant CREATE VIEW privilege
GRANT CREATE VIEW ON your_schema.* TO 'kcl_sgdp_readonly'@'localhost';

-- Optional) Grant SHOW VIEW if they need to inspect view definitions
GRANT SHOW VIEW ON your_schema.* TO 'kcl_sgdp_readonly'@'localhost';

-- Prevent write access
-- Make sure the user does not have any of the following privileges:
-- INSERT UPDATE DELETE DROP ALTER
-- You can check privileges with:
SHOW GRANTS FOR 'kcl_sgdp_readonly'@'localhost';

--If kcl_sgdp_readonly wants to create a view like:
CREATE VIEW my_view AS
SELECT name, age FROM sensitive_table;
-- They can do this without being able to modify sensitive_table, as long as they have SELECT and CREATE VIEW.

