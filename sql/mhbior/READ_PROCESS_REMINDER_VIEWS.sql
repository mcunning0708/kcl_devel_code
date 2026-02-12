-- WORKING 
use mhbior;


select count(*) from v_active_participants;

-- MY VIEWS 
select count(*) from v_active_participants_table_only;
select * from v_active_participants_reminders limit 10;
select count(*) from v_active_participants_reminders;
select count(distinct id) from v_active_participants_reminders;
select count(*) from v_communications_reminders;
select count(distinct id) from v_communications_reminders;

show columns from v_active_participants_table_only; 
show columns from v_active_participants_reminders;
show columns from v_communications_reminders;

select * from v_active_participants_table_only 
order by registered_at DESC 
limit 10;

-- STANDARD TABLES
select count(*) from communications;
select * from communications order by created_at DESC limit 10;
select type, contact_method, number, count(*) from communications group by type, contact_method, number ; 
