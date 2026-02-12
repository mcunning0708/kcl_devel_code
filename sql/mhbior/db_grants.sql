use mhbior; 
select * from participants limit 5;

SELECT CURRENT_USER();

SHOW GRANTS FOR CURRENT_USER();

SHOW GRANTS FOR kcl_sgdp_readonly@%;

SELECT * FROM information_schema.user_privileges WHERE grantee LIKE "'kcl_sgdp_readonly'@'%'";
