/*******************DATA MANAGEMENT & EDA***************************/

/******ATTENDANCE PF CARDIO PROGRAMS AMONG WOMEN PATIENTS 
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

/********CARDIO PROGRAM ATTENDANCE***********/
/*attendance of cardio programs
step 1. hcs.institution  --> get institutionsid
step 2. hcs.Location  ---> get Locationsid & locationname
step 3. hcs.outpat_visit ---> get visit information with filtering to specifed locationsid
step 4. MOVE attendance (FROM outpat_visit) UNION cardiorisk.referrals_updated
step 5. Merge data to denominator file (denominator)
*/

/****STEP 1. Lookup institutionsid & institutionname FROM hcs.institution using sta3n & institutioncode****/
/*hcs.institution*/ 
SELECT * 
FROM  hcs.institution
WHERE (sta3n='a' AND institutioncode LIKE 'a%') OR
(sta3n='b' AND institutioncode LIKE 'b%') OR
(sta3n='c' AND institutioncode LIKE 'c%')
ORDER BY sta3n;
-- NOTE-OUTPUT: 93 rows affected

/*data check: verifying institutionname AND institutioncode once you have institutionsid*/
SELECT DISTINCT
institutionsid
,sta3n
,institutionname
,institutioncode
FROM hcs.institution 
WHERE (institutionsid = '123456') 
	 or institutionsid = '123457'
	 or institutionsid = '123458' 
	 or institutionsid = '123459' 
	 or institutionsid = '123450' 
	 or institutionsid = '123451' 
	 or institutionsid = '123452' 
	 or institutionsid = '123453' 
	 or institutionsid = '123454'   
ORDER BY sta3n;

/*step2. Lookup Locationsids AND locationnames FROM hcs.location  with sta3n,institutionsid,locationname FROM above query*/
SELECT DISTINCT 
Locationsid 
,sta3n
,locationname
,locationabbreviation
,primarystopcodesid
,secondarystopcodesid
,medicalservice 
,physicalLocation 
,inactivationDATE
,reactivationDATE
,institutionsid
,patientfriendlylocationname FROM hcs.location
WHERE (sta3n='a' AND 
((institutionsid='123456' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) 
OR (institutionsid='123457' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) 
OR (institutionsid='123458' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) 
OR (institutionsid='123459' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) 
OR (institutionsid='123450' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) 
OR (institutionsid='123451' AND (locationname LIKE 'abc%move%' OR locationname LIKE '%move%')) )) 
OR 
(sta3n='b' 
AND (((institutionsid='234567' AND locationname LIKE '%abc%move%' Or locationname LIKE '%move%'))
Or ((institutionsid='234568' AND locationname LIKE '%abc%move%' Or locationname LIKE '%move%')))) 
Or (sta3n='c' AND (institutionsid='234569' AND locationname LIKE '%abc%move%' Or locationname LIKE '%move%')) 
AND (locationname NOT LIKE 'ZZ%')  
AND (locationname NOT LIKE '%move%disord%')
AND (locationname NOT LIKE '%movement%disord%')
ORDER BY sta3n,locationname;
-- NOTE-OUTPUT: 398 rows affected

/*step 3. hcs.outpat_visit ---> get visit information with filtering to specifed locationsid*/
/*QUERY: attendance for site 1, 2 & 3
hcs.outpat_visit (filter visits FROM 12/1/2016-present) LEFT JOIN dim.Location (column locationname)
*/
DROP TABLE IF EXISTS MOVE_outpatvisit;

SELECT DISTINCT
a.sta3n
,a.patientsid
,cast (a.visitdatetime as DATE) as visitdate
,a.visitsid
,a.encountercreatedbystaffsid
,cast (a.encounterDATEtime as DATE) as encounterDATE
,a.visitidentifier
,a.uniquevisitnumber
,a.institutionsid
,a.Locationsid
,a.Primarystopcodesid
,a.secondarystopcodesid
,a.WorkloadLogicFlag
,a.encountertype
,a.noncountclinicFlag
,b.locationname 
INTO MOVE_outpatvisit
FROM cardiorisk.outpat_visit as a
LEFT OUTER JOIN hcs.location as b  
On (a.locationsid=b.locationsid) 
INNER JOIN cardiorisk.patientfile as c
on a.sta3n=c.sta3n AND a.patientsid=c.patientsid
WHERE (a.visitdatetime >='2016-12-01 00:00:00' AND a.visitdatetime <='2020-03-15 23:59:59') AND 
((a.sta3n='a' AND a.Locationsid IN
(17605275795, 21409783942, 4596419836, 91041289644, 19363494045, 37398894486, 94706178748, 32440040360, 6534384877, 
71705138216, 87744005205, 74107804780, 41516032645, 49857758825, 73130143313, 33644022986, 26051169396, 40909410727, 
96312239653, 79992435258, 37099982203, 70548057274, 90510678971, 72854269547, 2553905090, 38409247174, 5541050232, 
6587653171, 57716504843, 1690484957, 90621744505, 73547912383, 75777370429, 19148776010, 75421459265, 84724826011, 
84648511521, 11135774432, 6291727152, 3527987503, 94520000230, 19491908980, 80663859301, 23660314251, 46322761599, 
43881591776, 98967516631, 52202351562, 32961061961, 50506163025, 32149899468, 90306389680, 18695986924, 43079375883, 
99939915303, 84269524877, 56423331534, 26492315254, 85410889664, 51218676691, 42795491564, 82730330312, 9148308090, 
53198168086, 79186730987, 32334039244, 29425745945, 49101851606, 8394692041, 35019775881, 86232607561, 13636916592, 
67708411515, 69991765767, 60781418244, 85345297070, 77554089772, 3989088863, 68250411809, 79641310628, 90354714019, 
33215009892, 18988768444, 51850460613, 67508122105, 9994441081, 49227345569, 7354492737, 30500520846, 90297338958, 
25496880503, 3161606307, 98128362303, 8151568952, 36458583395, 85528442216, 92601444918, 95448237375, 48698761086))
OR
(a.sta3n='b'AND a.Locationsid IN
(87661693110, 81943555399, 61715781189, 74229467068, 92022442641, 87594313123, 40106059723, 99971410159, 76345100555, 
15446940371, 21096429944, 78373262551, 29165481972, 62731444030, 16266322942, 18543207488, 36428911034, 85171330083, 
63955045543, 34833942834, 39619354371, 14704159812, 69649513581, 5731617359, 58814478920, 22762431127, 11586403110, 
52152030908, 97129119694, 13661006621, 48282673452, 24844152271, 42160996506, 39030849238, 14531661470, 79541437165, 
91297705314, 11476188973, 71818944822, 68785573618, 66082775965, 48713273445, 77122881746, 17975268683, 59271303998, 
18373613439, 93669321510, 55164306228, 29731965398, 60423291279, 73408060859, 85448585236, 44972345865, 69762083353, 
22770808416, 14441017493, 28778435149, 77022311252, 50655967434, 35336055152, 81266703311, 23887068590, 15565217432, 
73412356399, 97548525168, 54391054492, 47389957365, 9512493995, 23201923882, 47654545679, 78512807385, 58072783257, 
46834381471, 95332095454, 63649995326, 90654260556, 74203118295, 98732349235, 27215002627, 49647505393, 53635624876, 
90083909894, 53932111839, 97889446669, 99863306666, 3784529257, 80970389820, 84339439982, 10845029139, 19676900444, 
36004514091, 6714875919, 6714884821, 74444175210, 20338232654, 83083218554, 25639962747, 84111874940, 37549548372))
OR
(a.sta3n='c' AND a.Locationsid IN
(12847839633, 23118952557, 49380157872, 8033706298, 33349159520, 25091291410, 40091447086, 23330761109, 76430559395, 
41159225429, 16563296374, 60229078759, 73790206284, 16251465264, 28784810297, 69334257102, 94755342102, 74177246146, 
64587374114, 31085056447, 58274794905, 97733528398, 50856374197, 85083582009, 94428392482, 48335589855, 89650504310, 
18086505642, 81598605355, 37542729705, 22738728623, 93077346154, 56640255702, 42345831757, 21552309476, 31506787047, 
8918186156, 38672492621, 95880389969, 20048817412, 3960858671, 35247944051, 63812358784, 73074899668, 35699398323, 
81726444112, 54448824935, 58496675921, 11827111627, 28877879579, 72765369596, 11669667489, 72723672094, 10578218433, 
96719180730, 8686184188, 30641049667, 50410040895, 96238620881, 54615180692, 32445027520, 76830772181, 83129235201, 
95069961656, 23146476537, 60111348600, 58167038304, 63901725619, 48740832504, 99586898854, 1731005543, 33827600315, 
55502076337, 12193658570, 65251437768, 50406382026, 82849260410, 74792705261, 70519491457, 82973337746, 5218978317, 
44401199877, 64515396832, 45937566840, 76036443687, 44165715137, 9869030461, 10230989485, 58880710186, 4719802929, 
80366206092, 52677684514, 52286245099, 28469379262, 13057716942, 56625396203, 29313555347, 23344588917, 7515375108))) 
AND
(a.PatientVeteranFlag='Y')
ORDER BY sta3n,locationname;
-- NOTE-OUTPUT: 12,343 rows affected

SELECT * FROM  MOVE_OutpatVisit;

/*data check 1: locationname*/
SELECT sta3n
,institutionsid
,locationname
,COUNT(DISTINCT patientsid) 
FROM  MOVE_OutpatVisit
GROUP BY sta3n,institutionsid,locationname;
-- NOTE-OUTPUT: 176 rows affected

/*step 4a. pullling attendance FROM cardiorisk.referrals_updated*/
DROP TABLE IF EXISTS MOVE_HPDP;

CREATE TEMPORARY TABLE MOVE_HPDP
SELECT DISTINCT 
sta3n 
,patientsid  
,cast (visitdatetime  as DATE) as visitdate 
,visitsid  
,encountercreatedbystaffsid  
,cast (encounterDATEtime as DATE) as encounterDATE  
,visitidentifier 
,uniquevisitnumber   
,institutionsid  
,Locationsid  
,Primarystopcodesid 
,secondarystopcodesid 
,WorkloadLogicFlag 
,encountertype 
,noncountclinicFlag  
,locationname 
FROM cardiorisk.referrals_updated;
-- NOTE-OUTPUT: 236 rows affected

 SELECT DISTINCT * FROM MOVE_HPDP;
-- 236 rows affected

/*data check 2: locationname*/
SELECT  sta3n
,institutionsid
,locationname
,COUNT(DISTINCT patientsid) 
FROM MOVE_HPdP
GROUP BY sta3n,institutionsid,locationname;
-- 15 rows

/*step 4b-append MOVE_outpat_visit with MOVE_HPDP*/
DROP TABLE IF EXISTS move_outpatvisit_dflthpdp;

SELECT DISTINCT
sta3n
,patientsid
,visitdate
,visitsid
,encountercreatedbystaffsid
,encounterdate
,visitidentifier
,uniquevisitnumber
,institutionsid
,locationsid
,primarystopcodesid
,secondarystopcodesid
,workloadlogicflag
,encountertype
,noncountclinicflag
,locationname
,datasource='MOVE_OutpatVisit'
INTO move_outpatvisit_dflthpdp
FROM  MOVE_OutpatVisit
UNION
SELECT DISTINCT
 sta3n
,patientsid
,visitdate 
,visitsid
,encountercreatedbystaffsid
,encounterdate
,visitidentifier
,uniquevisitnumber
,institutionsid
,locationsid
,primarystopcodesid
,secondarystopcodesid
,workloadlogicflag
,encountertype
,noncountclinicflag
,locationname
,datasource='dflt_MOVEHPdP_29aug20'
FROM MOVE_HPdP;
-- NOTE-OUTPUT: 12,579 rows affected ---> n(#MOVE_OutpatVisit)=12,343 + n(#MOVE_HPdP)=236 --> n(#move_outpatVisit_dflthpdp)=12,575

SELECT * FROM  move_outpatVisit_dflthpdp; -- (12,579 rows affected)

/*step4c. #MOVE_attend_dFLt_HPdP LEFT JOIN hcs.stopcode */
DROP TABLE IF EXISTS move_outpatVisit_dflthpdp_stopcodes;

CREATE TEMPORARY TABLE move_outpatVisit_dflthpdp_stopcodes
SELECT DISTINCT
a.sta3n
,a.patientsid
,a.visitdate
,a.visitsid
,a.encountercreatedbystaffsid
,a.encounterdate
,a.visitidentifier
,a.uniquevisitnumber
,a.institutionsid
,a.locationsid
,a.primarystopcodesid
,a.secondarystopcodesid
,a.workloadlogicflag
,a.encountertype
,a.noncountclinicflag
,a.locationname  
,a.datasource
,b.stopcode 
,b.stopcodename	
INTO move_outpatVisit_dflthpdp_stopcodes 
FROM move_outpatVisit_dflthpdp as a
LEFT JOIN hcs.stopcode as b  
on a.sta3n=b.sta3n AND a.primarystopcodesid=b.stopcodesid;
-- NOTE-OUTPUT: 12579 rows affected

SELECT * FROM move_outpatVisit_dflthpdp_stopcodes; -- 12579 rows affected
SELECT * FrOM cardiorisk.denominator; -- 27644 rows affected

/*step 5. denominator LEFT JOIN #MOVE_attend_dFLtHdPd_stopcodes */

/*NOTE: n (dflt.denominator)=27,644 & n (#MOVE_attend_dflthpdp_stopcodes)=12,575*/
DROP TABLE IF EXISTS cardiorisk.move_attendance_all;

CREATE TABLE cardiorisk.move_attendance_all
SELECT DISTINCT	
a.patientsid  
,a.sta3n 
,a.institutionname   
,a.age 
,b.visitdate
,b.visitsid
,b.encountercreatedbystaffsid
,b.encounterDATE
,b.visitidentifier
,b.uniquevisitnumber
,b.institutionsid
,b.LocationsId
,b.primarystopcodesId
,b.secondarystopcodesId
,b.WorkloadLogicFlag
,b.encountertype
,b.noncountclinicFlag
,b.locationname  
,b.datasource
,b.stopcode 
,b.stopcodename	
FROM denominator as a
LEFT JOIN move_outpatVisit_dflthpdp_stopcodes as b
On a.sta3n=b.sta3n AND a.patientsid=b.patientsid;
-- NOTE-OUTPUT: 10183 rows affected

/*data checks*/
SELECT * FROM cardiorisk.move_attendance_all
ORDER BY sta3n,institutionname,locationname; 

SELECT COUNT(DISTINCT patientsid) FROM move_attendance_all;   -- 6009

SELECT locationname, COUNT(DISTINCT patientsid) FROM cardiorisk.move_attendance_all
GROUP BY locationname; 

SELECT institutionname,COUNT(patientsid) FROM move_attendance_all
GROUP BY institutionname;

SELECT locationname,datasource,cOUnt (patientsid) FROM move_attendance_all
GROUP BY  locationname,datasource
ORDER BY datasource;
-- (102 rows affected)

SELECT sta3n,institutionname,locationname,datasource,cOUnt (patientsid) FROM move_attendance_all
GROUP BY sta3n,institutionname,locationname,datasource
ORDER BY datasource,sta3n;
-- 143 rows affected

SELECT sta3n,institutionname,visitdate,locationname,datasource,cOUnt (patientsid) FROM move_attendance_all
GROUP BY sta3n,institutionname,visitdate,locationname,datasource
ORDER BY datasource,sta3n,visitdate;
-- 3168 rows affected