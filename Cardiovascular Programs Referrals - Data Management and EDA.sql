/*******************DATA MANAGEMENT & EDA***************************/

/******REFERRALS TO CARDIO PROGRAMS AMONG WOMEN PATIENTS 
       IDENTIFIED AS AT HIGH RISK FOR CARDIOVASCULAR DISEASE ********/
/***the codes below were originally run in SQL Server Management Studio (SSMS)*****/
/*******data pull time frame: 12/01/2016 to 03.15.20****/

/***** Objectives-Obtain samples of women patients identified at high-risk for cardiovascular disease with 
1. referrals to cardio programs vs
2. attendance of cardio programs

** databases: 
1. Project: cardiorisk
2. Healthcare system: hcs
****/

/*Referrals to Cardio Program
Step 1. cardiorisk.denominator --> number of patients with cardio risk
Step 2. cardiorisk.consultfile & hcs.institution &  ---> verify ordering institutions is NOT the (receiving) institution
Step 3a. create moverefs_consults table from cardiorisk.consultfile 
Step 3b. filter moverefs_consults table with referrals to hpdp
Step 4. union (combine rows) of rows of referrals specifically HPDP with cardiorisk.referrals_updated
Step 5. create move_referral_all --->  merge referals to cardio programs filtered to hpdp with data 
to denominator file (denominator)
*/

/*step 1. table cardiorisk.denominator: contains patients identified as having cardiovascular risks*/
SELECT DISTINCT * 
FROM  cardiorisk.denominator;

SELECT age,count(DISTINCT patientsid) 
FROM cardiorisk.denominator
GROUP BY age
ORDER BY age;

SELECT DISTINCT 
patientsid,
age 
FROM cardiorisk.denominator;
-- 6,009 DISTINCT patients

/* create table with referrals to cardio programs with 2 tables: 1. patientfile 2. consultfile, 
filtered to 
1.1. gender=female in patientfile
1.2. sites=a, b & c in consultfile
*/

/*step 2. task: Verify that orderinginstitutionsid is NOT the same as institutionsid*/
DROP TABLE IF EXISTS scratch;

CREATE TEMPORARY TABLE scratch 
SELECT DISTINCT
 a.orderinginstitutionsid
,b.institutionsid
,b.sta3n
,b.institutionname
,b.institutioncode
INTO scratch
FROM cardiorisk.consultfile AS a
LEFT JOIN hcs.institution AS b
ON a.sta3n=b.sta3n
WHERE (b.sta3n='a' AND institutionsid = '123456' OR institutionsid = '123457') OR
	  (b.sta3n='b' AND institutionsid = '234567') OR
	  (b.sta3n='c' AND institutionsid = '345678' Or institutionsid = '345679' OR institutionsid = '345670' 
	  OR institutionsid = '345671'  OR institutionsid = '345672' OR institutionsid = '345674') 
ORDER BY sta3n;

SELECT * FROM scratch;  
-- 588 rows
-- in temp table scratch, I verified that orderinginstitutionsid is NOT the same as institutionsid

/*step 3a. create table for referrals to cardio programs from consultfile*/
DROP TABLE IF EXISTS moverefs_consults;

CREATE TEMPORARY TABLE moverefs_consults
SELECT DISTINCT
consultsid 
,sta3n 
,patientsid 
,patientlocationsid 
,torequestservicesid 
,torequestservicename 
,cast(requestDATEtime as DATE) as requestDATE  
,requestDATEsid 
,fromlocationsid 
,tostaffsid 
,orderstatussid
,cprsordersid 
,cprsstatus 
,sendingstaffsid 
,orderinginstitutionsid
,orderingsta3n 
,provisionaldiagnosis 
,provisionaldiagnosiscode 
INTO moverefs_consults
FROM cardiorisk.consultfile 
WHERE ((sta3n ='a' AND orderinginstitutionsidin (123456,123457))  OR
(sta3n='b' AND Orderinginstitutionsid='234567') OR  
(sta3n='c' AND orderinginstitutionsidin (345678,345679)))  
AND 
(requestDATEtime >='2016-12-01 00:00:00' AND  requestDATEtime <='2020-03-15 23:59:59') AND 
(torequestservicename LIKE '%move%') AND 
(torequestservicename NOT LIKE '%move%disorder%' AND  torequestservicename nOt LIKE '%bariatric%') 
ORDER BY sta3n,patientsid,torequestservicename;
-- NOTE-OUTPUT: 1,387 rows

/*data check: see flat file*/
SELECT * 
FROM moverefs_consults
ORDER BY sta3n,orderinginstitutionsid,patientsid,torequestservicename;   
-- NOTE-OUTPUT: 1,387  rows (or referrals)

/*data check: count DISTINCT patientsid*/
SELECT COUNT(DISTINCT patientsid) 
FROM  moverefs_consults;
-- NOTE-OUTPUT: 1,062 DISTINCT patientsids

/*step 3b. filter moverefs_consults table to those referred to hpdp*/
SELECT 
sta3n,
torequestservicename,
COUNT(DISTINCT patientsid) 
FROM  moverefs_consults
GROUP BY sta3n, torequestservicename
ORDER BY sta3n;

SELECT sta3n,
orderinginstitutionsid,
torequestservicename,
COUNT(DISTINCT patientsid)
FROM moverefs_consults
GROUP BY sta3n,orderinginstitutionsid,torequestservicename
ORDER BY sta3n;

/*cardiorisk.referrals_updatEd*/
SELECT DISTINCT * 
FROM cardiorisk.referrals_updated;
-- NOTE-OUTPUT: 236 rows

/*SELECTING rows relevant to referrals FROM cardiorisk.referrals_updated */
SELECT DISTINCT 
sta3n
,patientsid
,cast (consult_requesteDATEtime as DATE) as  requestdate 
,torequestservicename 
,cprsstatus
FROM cardiorisk.referrals_updated;

/*step 4. task: UNION or combine rows of referrals specifically HPDP to cardiorisk.referrals_updated*/
DROP TABLE IF EXISTS MOVE_refs_consultsHPDP;

CREATE TEMPORARY TABLE MOVE_refs_consultsHPDP
SELECT DISTINCT
sta3n
,patientsid
,requestDATE 
,torequestservicename 
,cprsstatus
,datasource='con_consult'
INTO MOVE_refs_consultsHPDP
FROM moverefs_consults   /*n=1,3847*/
UNION 
SELECT DISTINCT
sta3n
,patientsid
,cast (consult_requesteDATEtime as DATE) as  requestdate 
,torequestservicename 
,cprsstatus
,datasource='CT_HPDP'
FROM cardiorisk.referrals_updated; /*n=236*/
-- NOTE-OUTPUT: n=1,495 WHERE 1,383 are from moverefs_consults AND 112 are from cardiorisk.referrals_updated

-- data checks
SELECT DISTINCT * FROM MOVE_refs_consultsHPDP
ORDER BY datasource;  
-- NOTE-OUTPUT: 1495 rows 

SELECT DISTINCT cardiorisk.denominator;
-- NOTE-OUTPUT: 27,644  rows affected

SELECT institutionname,COUNT(DISTINCT patientsid) 
FROM cardiorisk.denominator
GROUP BY institutionname;

/*
institutionname	 count (DISTINCT patientsid)
cLinic 1			470
cLinic 2			1243
cLinic 3			630
cLinic 4			2205
cLinic 5			1461
*/

SELECT sta3n
,institutionname
,locationname,
COUNT(DISTINCT patientsid) 
FROM cardiorisk.denominator
GROUP BY sta3n,institutionname,locationname;

/*step 5. create move_referral_all: merge referals to cardio programs filtered to hpdp with data to denominator file (denominator)
cardiorisk.denominator (27,644 rows) LEFT JOIN move_consults_spatient (1,384 rows) */
DROP TABLE IF EXISTS cardiorisk.move_referral_all;

CREATE TABLE cardiorisk.move_referral_all
SELECT DISTINCT	
a.patientsid  
,a.sta3n 
,a.institutionname   
,b.torequestservicename	
,b.requestDATE	
,b.cprsstatus	
FROM cardiorisk.denominator as a
LEFT JOIN MOVE_refs_consultsHPDP as b
ON a.sta3n=b.sta3n AND a.patientsid=b.patientsid;
-- NOTE-OUTPUT: 6313 rows affected

SELECT DISTINCT * FROM cardiorisk.move_referral_all;
-- cardiorisk.move_referral_all used as analytic file of referrals to cardio programs


