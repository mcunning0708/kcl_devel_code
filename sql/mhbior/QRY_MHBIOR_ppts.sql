-- Script for Quierying Participants MHBIOR 

USE mhbior;

SET @alias := /*prompt*/ 'EDGI000229';
select @alias;
select CONCAT('%', @alias, '%' );
select * from participants where aliases like CONCAT('%', @alias, '%' ) ;
SET @participant_id := /*prompt*/ '156';
select @participant_id;
SELECT CONCAT('a', '*', 'b') AS result;
SELECT CONCAT( '%', @alias, '%');

select p.aliases, p.* from participants p where id = @participant_id;
-- Carola PPT 
select * from participants where aliases like CONCAT( '%', @alias, '%') ;
select * from participants where aliases like '%GLAD029863%';

-- Carola : 17717 / GLADonly 40779 / GLAD & EDGI 10476 
select * from participants where id = @participant_id;
select * from participant_study where participant_id  = @participant_id;
select * from consent_form_responses where participant_id  = @participant_id;
select * from consent_forms;