/* Customer movement */

/*ลบข้อมูลบางช่วง*/
DELETE FROM MKTCRM.POM.CM_all_2023
WHERE ttm2 BETWEEN '20240901' AND '20240931';
/*ลบข้อมูลทั้งหมด*/
TRUNCATE TABLE MKTCRM.POM.CM_all_2023;

/*ดึงข้อมูลรายเดือน */
 
EXEC POM.CM_All_YYYYMM '202407';
EXEC POM.CM_All_YYYYMM '202408';
EXEC POM.CM_All_YYYYMM '202409';

/*ระบุ period ที่จะ compare*/
/*create VIEW Pom.CM_ALL_TY_1 AS
select store_id,sbl_member_id,REF_key,sum(QUANT) as quant, Sum(TOTAL) as total, sum(NET_TOTAL) as net_total, sum(GP) as gp,
store_format,STORE_NAME,TTM2 
from MKTCRM.Pom.CM_all_2023
where TTM2 between '20241101' and '20241130'  /*ระบุ period ที่จะ compare*/
group by  store_id,sbl_member_id,REF_key,store_format,STORE_NAME,TTM2;*/

/*ระบุ period ที่จะ compare แก้ใน VIEWS*/
/*create VIEW Pom.CM_ALL_PP_1  as
select store_id,sbl_member_id,REF_key,sum(QUANT) as quant, Sum(TOTAL) as total, sum(NET_TOTAL) as net_total, sum(GP) as gp,
store_format,STORE_NAME,TTM2 
from MKTCRM.Pom.CM_All_2023
where TTM2 between '20241001' and '20241031' /*ระบุ period ที่จะ compare*/
group by  store_id,sbl_member_id,REF_key,store_format,STORE_NAME,TTM2;*/


/**Count REFERENCE**/ 
/*create VIEW Pom.CM_ALL_TY_2  as
select sbl_member_id,store_id,COUNT(distinct ref_key) as Tx_TY, sum(quant) as quant_TY, sum(total) as total_TY, 
sum(net_total) as net_total_TY, sum(gp) as gp_TY, store_format, STORE_NAME 
from  MKTCRM.Pom.CM_ALL_TY_1
group by sbl_member_id,store_id,store_format,STORE_NAME ;*/


/*create VIEW Pom.CM_ALL_PP_2 as
select sbl_member_id,store_id,COUNT(distinct REF_key) as Tx_PP, sum(quant) as quant_PP, sum(total) as total_PP, 
sum(net_total) as net_total_PP, sum(gp) as gp_PP, store_format, STORE_NAME 
from  MKTCRM.Pom.CM_ALL_PP_1
group by sbl_member_id,store_id,store_format,STORE_NAME;*/



/**SUM REFERENCE**/
/*create VIEW Pom.CM_ALL_TY_3 as
select sbl_member_id,store_id,store_format,STORE_NAME,sum(TX_TY) as Tx_TY,sum(quant_TY) as quant_TY, sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY, sum(gp_TY) as gp_TY
from  MKTCRM.Pom.CM_ALL_TY_2
group by sbl_member_id,store_id,store_format,STORE_NAME ;*/


/*create VIEW Pom.CM_ALL_PP_3  as
select sbl_member_id,store_id,store_format,STORE_NAME,sum(TX_PP) as Tx_PP,sum(quant_PP) as quant_PP, sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP, sum(gp_PP) as gp_PP
from  MKTCRM.Pom.CM_ALL_PP_2
group by sbl_member_id,store_id,store_format,STORE_NAME;*/



/*Count T1C*/
/*create VIEW Pom.CM_ALL_TY_6  as
select count(distinct sbl_member_ID ) as  ID, sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY, Sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY 
from  MKTCRM.Pom.CM_ALL_TY_3;*/


/*create VIEW Pom.CM_ALL_PP_6 as
select count(distinct sbl_member_ID ) as  ID, sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, Sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP 
from  MKTCRM.Pom.CM_ALL_PP_3;*/



/**Store_Eligible**/
TRUNCATE TABLE MKTCRM.POM.CM_Eli_TY_1;/*ลบข้อมูลเดิมใน POM.CM_Eli_TY_1*/
TRUNCATE TABLE MKTCRM.POM.CM_Eli_PP_1;/*ลบข้อมูลเดิมใน POM.CM_Eli_PP_1*/

INSERT INTO MKTCRM.POM.CM_Eli_TY_1
(sbl_member_ID, store_id, store_format, STORE_NAME, Tx_TY, quant_TY, total_TY, net_total_TY, gp_TY)
select distinct sbl_member_ID,store_id,store_format,STORE_NAME,sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY, Sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY
from MKTCRM.POM.CM_ALL_TY_3
where sbl_member_ID is not null and store_id in ('012')  /*ระบุสาขา*/
group by sbl_member_ID,store_id,store_format,STORE_NAME;


INSERT INTO MKTCRM.POM.CM_Eli_PP_1
(sbl_member_ID, store_id, store_format, STORE_NAME, Tx_PP, quant_PP, total_PP, net_total_PP, gp_PP)
select distinct sbl_member_ID,store_id,store_format,STORE_NAME,sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, Sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP
from MKTCRM.POM.CM_ALL_PP_3
where sbl_member_ID is not null and store_id in ('012') /*ระบุสาขา*/
group by sbl_member_ID,store_id,store_format,STORE_NAME;



  
/*Group  T1C*/
/*create VIEW Pom.CM_Eli_TY_2 as
select distinct sbl_member_ID,sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY,Sum(total_TY) as total_TY,
	   sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY
from  MKTCRM.Pom.CM_Eli_TY_1
group by sbl_member_ID ;*/


/*create VIEW Pom.CM_Eli_PP_2 as
select distinct sbl_member_ID,sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP,Sum(total_PP) as total_PP,
	   sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP
from MKTCRM.Pom.CM_Eli_PP_1
group by sbl_member_ID ;*/



/*Count T1C*/
/*create VIEW Pom.CM_Eli_TY_3 as
select count(distinct sbl_member_ID ) as ID, sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY, 
	   Sum(total_TY) as total_TY, sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY 
from MKTCRM.Pom.CM_Eli_TY_2;*/


/*create VIEW Pom.CM_Eli_PP_3 as
select count(distinct sbl_member_ID ) as ID, sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, 
	   Sum(total_PP) as total_PP, sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP 
from MKTCRM.Pom.CM_Eli_PP_2;*/



/**Flag Other Store**/
TRUNCATE TABLE MKTCRM.POM.CM_Other_TY; /*ลบข้อมูลเดิมใน MKTCRM.POM.CM_Other_TY*/
TRUNCATE TABLE MKTCRM.POM.CM_Other_PP; /*ลบข้อมูลเดิมใน MKTCRM.POM.CM_Other_PP*/

INSERT INTO MKTCRM.POM.CM_Other_TY (SBL_MEMBER_ID, STORE_ID, STORE_FORMAT, STORE_NAME, Tx_TY, quant_TY, total_TY, net_total_TY, gp_TY, STORE_RANK)
SELECT 
    a.SBL_MEMBER_ID,
    a.STORE_ID,
    a.STORE_FORMAT,
    a.STORE_NAME,
    a.Tx_TY,
    a.quant_TY,
    a.total_TY,
    a.net_total_TY,
    a.gp_TY,
    ROW_NUMBER() OVER (PARTITION BY a.sbl_member_ID ORDER BY a.TX_TY DESC, a.Total_TY DESC)  AS STORE_RANK
FROM 
    MKTCRM.POM.CM_All_TY_3 AS a
WHERE 
    a.store_id NOT IN ('012')  -- ระบุสาขา
ORDER BY 
    a.sbl_member_ID, a.TX_TY DESC, a.Total_TY DESC;



INSERT INTO MKTCRM.POM.CM_Other_PP (SBL_MEMBER_ID, STORE_ID, STORE_FORMAT, STORE_NAME, Tx_PP, quant_PP, total_PP, net_total_PP, gp_PP, STORE_RANK)
SELECT 
    a.SBL_MEMBER_ID,
    a.STORE_ID,
    a.STORE_FORMAT,
    a.STORE_NAME,
    a.Tx_PP,
    a.quant_PP,
    a.total_PP,
    a.net_total_PP,
    a.gp_PP,
    ROW_NUMBER() OVER (PARTITION BY a.sbl_member_ID ORDER BY a.TX_PP DESC, a.Total_PP DESC) AS STORE_RANK
FROM 
    MKTCRM.POM.CM_All_PP_3 AS a
WHERE 
    a.store_id NOT IN ('012')  -- ระบุสาขา
ORDER BY 
    a.sbl_member_ID, a.TX_PP DESC, a.Total_PP DESC;


   
/*CREATE VIEW Pom.CM_Other_TY_TYPE AS
SELECT 
    *,
    CASE 
        WHEN STORE_RANK = 1 THEN 'Second Store'
        ELSE 'Other Store'
    END AS TYPE
FROM MKTCRM.Pom.CM_Other_TY
WHERE Total_TY IS NOT NULL;*/


/*CREATE VIEW Pom.CM_Other_PP_TYPE AS
SELECT 
    *,
    CASE 
        WHEN STORE_RANK = 1 THEN 'Second Store'
        ELSE 'Other Store'
    END AS TYPE
FROM MKTCRM.Pom.CM_Other_PP
WHERE Total_PP IS NOT NULL;*/


/*CREATE VIEW Pom.CM_Other_TY_TYPE_T1C AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY,
    SUM(CAST(quant_TY AS FLOAT)) AS quant_TY,
    SUM(CAST(total_TY AS FLOAT)) AS total_TY, 
    SUM(CAST(net_total_TY AS FLOAT)) AS net_total_TY,
    SUM(CAST(gp_TY AS FLOAT)) AS gp_TY,
    TYPE
FROM MKTCRM.Pom.CM_Other_TY_TYPE
WHERE sbl_member_ID IS NOT NULL
GROUP BY sbl_member_ID, TYPE;*/


/*create VIEW Pom.CM_Other_PP_TYPE_T1C  as
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP,
    SUM(CAST(quant_PP AS FLOAT)) AS quant_PP,
    SUM(CAST(total_PP AS FLOAT)) AS total_PP, 
    SUM(CAST(net_total_PP AS FLOAT)) AS net_total_PP,
    SUM(CAST(gp_PP AS FLOAT)) AS gp_PP,
    TYPE
from MKTCRM.Pom.CM_Other_PP_TYPE
where sbl_member_ID is not null
group by sbl_member_ID,TYPE  ;*/


/*create VIEW Pom.CM_Other_TY_TYPE_T1C_  as
select distinct sbl_member_ID
from MKTCRM.Pom.CM_Other_TY_TYPE_T1C
where sbl_member_ID is not null
group by sbl_member_ID ;*/

   
/*create VIEW Pom.CM_Other_PP_TYPE_T1C_  as
select distinct sbl_member_ID
from MKTCRM.Pom.CM_Other_PP_TYPE_T1C
where sbl_member_ID is not null
group by sbl_member_ID ;*/



/**Flag Store Type**/
/**Second Store**/
/*create VIEW Pom.CM_EP_Second_Store_TY as
select a.*
from MKTCRM.Pom.CM_Other_TY_TYPE as a
where TYPE = 'Second Store';*/

/*create VIEW Pom.CM_EP_Second_Store_PP as
select a.*
from MKTCRM.Pom.CM_Other_PP_TYPE as a
where TYPE = 'Second Store' ;*/

/*
CREATE VIEW Pom.CM_EP_Second_Store_TY_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY_SE, 
    SUM(CAST(total_TY AS FLOAT)) AS total_TY_SE, 
    SUM(CAST(gp_TY AS FLOAT)) / NULLIF(SUM(CAST(net_total_TY AS FLOAT)), 0) AS gp_per_TY_SE, 
    SUM(CAST(total_TY AS FLOAT)) / NULLIF(SUM(CAST(Tx_TY AS FLOAT)), 0) AS Basket_size_TY_SE,
    STORE_NAME AS MOST_STORE_TY_SE
FROM MKTCRM.Pom.CM_EP_Second_Store_TY
GROUP BY sbl_member_ID, STORE_NAME;*/


/*CREATE VIEW Pom.CM_EP_Second_Store_PP_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP_SE, 
    SUM(CAST(total_PP AS FLOAT)) AS total_PP_SE, 
    ISNULL(SUM(CAST(gp_PP AS FLOAT)) / NULLIF(SUM(CAST(net_total_PP AS FLOAT)), 0), 0) AS gp_per_PP_SE, 
    ISNULL(SUM(CAST(total_PP AS FLOAT)) / NULLIF(SUM(CAST(Tx_PP AS FLOAT)), 0), 0) AS Basket_size_PP_SE,
    STORE_NAME AS MOST_STORE_PP_SE
FROM MKTCRM.Pom.CM_EP_Second_Store_PP
GROUP BY sbl_member_ID, STORE_NAME;*/


/**Other Store**/
/*create VIEW Pom.CM_EP_Other_Store_TY as
select a.*
from MKTCRM.Pom.CM_Other_TY_TYPE as a
where TYPE = 'Other Store';*/

   
/*create VIEW Pom.CM_EP_Other_Store_PP as
select a.*
from MKTCRM.Pom.CM_Other_PP_TYPE as a
where TYPE = 'Other Store';*/


/*CREATE VIEW Pom.CM_EP_Other_Store_TY_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY_OT, 
    SUM(CAST(total_TY AS FLOAT)) AS total_TY_OT, 
    ISNULL(SUM(CAST(gp_TY AS FLOAT)) / NULLIF(SUM(CAST(net_total_TY AS FLOAT)), 0), 0) AS gp_per_TY_OT, 
    ISNULL(SUM(CAST(total_TY AS FLOAT)) / NULLIF(SUM(CAST(Tx_TY AS FLOAT)), 0), 0) AS Basket_size_TY_OT
FROM MKTCRM.Pom.CM_EP_Other_Store_TY
GROUP BY sbl_member_ID;*/


/*CREATE VIEW Pom.CM_EP_Other_Store_PP_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP_OT, 
    SUM(CAST(total_PP AS FLOAT)) AS total_PP_OT, 
    ISNULL(SUM(CAST(gp_PP AS FLOAT)) / NULLIF(SUM(CAST(net_total_PP AS FLOAT)), 0), 0) AS gp_per_PP_OT, 
    ISNULL(SUM(CAST(total_PP AS FLOAT)) / NULLIF(SUM(CAST(Tx_PP AS FLOAT)), 0), 0) AS Basket_size_PP_OT
FROM MKTCRM.Pom.CM_EP_Other_Store_PP 
GROUP BY sbl_member_ID;*/


/**Total Store**/
/*CREATE VIEW Pom.CM_EP_Total_Store_TY_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(Tx_TY) AS Tx_TY_TT, 
    SUM(total_TY) AS total_TY_TT, 
    ISNULL(SUM(gp_TY) / NULLIF(SUM(net_total_TY), 0), 0) AS gp_per_TY_TT, 
    ISNULL(SUM(total_TY) / NULLIF(SUM(Tx_TY), 0), 0) AS Basket_size_TY_TT
FROM MKTCRM.Pom.CM*/


/*CREATE VIEW Pom.CM_EP_Total_Store_PP_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP_TT, 
    SUM(CAST(total_PP AS FLOAT)) AS total_PP_TT, 
    ISNULL(SUM(CAST(gp_PP AS FLOAT)) / NULLIF(SUM(CAST(net_total_PP AS FLOAT)), 0), 0) AS gp_per_PP_TT, 
    ISNULL(SUM(CAST(total_PP AS FLOAT)) / NULLIF(SUM(CAST(Tx_PP AS FLOAT)), 0), 0) AS Basket_size_PP_TT
FROM MKTCRM.Pom.CM_All_PP_3
GROUP BY sbl_member_ID;*/



/*Flag PP vs TY */
/*Loss Customer */ 
/*CREATE VIEW Pom.CM_Eli_PP_TY AS
SELECT 
    COALESCE(a.sbl_member_ID, b.sbl_member_ID) AS sbl_member_ID, 
    a.Tx_PP, a.quant_PP, a.total_PP, a.net_total_PP, a.gp_PP,
    b.Tx_TY, b.quant_TY, b.total_TY, b.net_total_TY, b.gp_TY  
FROM 
    Pom.CM_Eli_PP_2 a
FULL OUTER JOIN 
    Pom.CM_Eli_TY_2 b
ON 
    a.sbl_member_ID = b.sbl_member_ID;*/


/*CREATE VIEW  Pom.CM_Eli_PP_TY_F_LOST AS 
SELECT 
    *, 
    'LOS' AS FLAG
FROM 
   Pom.CM_Eli_PP_TY
WHERE 
    Total_TY IS NULL;*/


/*create view Pom.CM_EP_LOST  as
select distinct sbl_member_ID,FLAG
from Pom.CM_Eli_PP_TY_F_LOST
where FLAG = 'LOS'
group by sbl_member_ID,FLAG ;*/



/**Flag Customer Type**/
/**lost Customer**/
/*create VIEW  POM.CM_EP_LOST_TYPE  as
select  a.*,b.sbl_member_ID as ID
from Pom.CM_EP_LOST as a left join POM.CM_Other_TY_TYPE_T1C_  as b
on a.sbl_member_ID = b.sbl_member_ID
group by a.sbl_member_ID ;*/


/*CREATE view Pom.CM_EP_LOST_TYPE AS 
SELECT  
    a.sbl_member_ID, 
    a.FLAG,    -- เลือกเฉพาะคอลัมน์ที่ต้องการ
    b.sbl_member_ID AS ID
FROM 
    Pom.CM_EP_LOST AS a 
LEFT JOIN 
    Pom.CM_Other_TY_TYPE_T1C_ AS b
ON 
    a.sbl_member_ID = b.sbl_member_ID
GROUP BY 
    a.sbl_member_ID, a.FLAG,  b.sbl_member_ID;*/


/*CREATE view  Pom.CM_EP_LOST_TYPE_ AS
SELECT 
    a.*, 
    CASE 
        WHEN a.ID IS NULL THEN 'Lost_Company' 
        ELSE 'Lost_Store' 
    END AS TYPE
FROM 
    Pom.CM_EP_LOST_TYPE AS a
WHERE 
    a.sbl_member_ID IS NOT NULL;*/


/*create VIEW Pom.CM_EP_LOST_TYPE_END   as
select distinct sbl_member_ID,TYPE
from Pom.CM_EP_LOST_TYPE_
where sbl_member_ID is not null
group by sbl_member_ID,TYPE ;*/


/**Eligible Customer**/
/*create VIEW Pom.CM_EP_Eli_TY_2_END  as
select distinct sbl_member_ID, sum (Tx_TY) as Tx_TY, Sum(total_TY) as total_TY, 
sum(gp_TY)/sum(net_total_TY) as gp_per_TY, Sum(total_TY)/sum (Tx_TY) as Basket_size_TY
from Pom.CM_Eli_TY_2
group by sbl_member_ID  ;*/


/*create VIEW Pom.CM_EP_Eli_PP_2_END  as
select distinct sbl_member_ID, sum (Tx_PP) as Tx_PP, Sum(total_PP) as total_PP, 
sum(gp_PP)/sum(net_total_PP) as gp_per_PP, Sum(total_PP)/sum (Tx_PP) as Basket_size_PP
from Pom.CM_Eli_PP_2
group by sbl_member_ID ;*/



/*Output Table1*/
-- เตรียมสร้างตารางสุดท้าย DH.Eli_PP_TY_F_LOST_END3 โดยใช้ FULL OUTER JOIN พร้อมคำนวณ FLAG
--รวมตาราง Eli_TY_PP, Eli_TY_PP_F, Eli_PP_TY, Eli_PP_TY_F_LOST, Eli_PP_TY_F_LOST_END, Eli_PP_TY_F_LOST_END3
TRUNCATE TABLE  MKTCRM.POM.CM_Eli_PP_TY_F_LOST_END3;
INSERT INTO MKTCRM.POM.CM_Eli_PP_TY_F_LOST_END3
(sbl_member_ID, FLAG, T1C, Tx_PP, gp_PP, net_total_PP, Totals_PP, Tx_TY, gp_TY, net_total_TY, Totals_TY)
   SELECT 
    COALESCE(ty.sbl_member_ID, pp.sbl_member_ID) AS sbl_member_ID,
    CASE
        WHEN pp.Total_PP IS NULL AND ty.Total_TY IS NOT NULL THEN 'NEW'    -- กำหนด FLAG เป็น 'NEW' สำหรับลูกค้าใหม่
        WHEN pp.Total_PP IS NOT NULL AND ty.Total_TY IS NOT NULL THEN 'EXS'  -- กำหนด FLAG เป็น 'EXS' สำหรับลูกค้าที่มีอยู่
        WHEN pp.Total_PP IS NOT NULL AND ty.Total_TY IS NULL THEN 'LOS'    -- กำหนด FLAG เป็น 'LOS' สำหรับลูกค้าที่สูญเสีย
    END AS FLAG,
    count(DISTINCT COALESCE(ty.sbl_member_ID, pp.sbl_member_ID)) as T1C,
    SUM(pp.Tx_PP) AS Tx_PP,
    SUM(pp.gp_PP) AS gp_PP,
    SUM(pp.net_total_PP) AS net_total_PP,
    SUM(pp.Total_PP) AS Totals_PP,
    SUM(ty.Tx_TY) AS Tx_TY,
    SUM(ty.gp_TY) AS gp_TY,
    SUM(ty.net_total_TY) AS net_total_TY,
    SUM(ty.Total_TY) AS Totals_TY
FROM 
    MKTCRM.POM.CM_Eli_TY_2 AS ty
FULL OUTER JOIN 
    MKTCRM.POM.CM_Eli_PP_2 AS pp
ON 
    ty.sbl_member_ID = pp.sbl_member_ID
GROUP BY 
    COALESCE(ty.sbl_member_ID, pp.sbl_member_ID),
    CASE
        WHEN pp.Total_PP IS NULL AND ty.Total_TY IS NOT NULL THEN 'NEW'
        WHEN pp.Total_PP IS NOT NULL AND ty.Total_TY IS NOT NULL THEN 'EXS'
        WHEN pp.Total_PP IS NOT NULL AND ty.Total_TY IS NULL THEN 'LOS'
    END;



/**Flag Summary Sales Lost Customer**/
/** Sales Lost Store_Company**/

/*create VIEW Pom.CM_EP_LOST_Sale_ALL  as
select DISTINCT a.*,Tx_PP,total_PP,gp_PP,net_total_PP
from Pom.CM_Ep_lost_type_end as a left join Pom.CM_Eli_pp_2 as b
on a.sbl_member_ID = b.sbl_member_ID;*/


/*create View Pom.CM_EP_LOST_Sale_ALL_END  as
select [TYPE], count(distinct sbl_member_ID) as T1C,sum (Tx_PP) as Tx_PP,sum(gp_PP) as gp_PP,sum(Total_PP) as Totals_PP,
sum(gp_PP)/sum(net_total_PP) as gp_per_PP,Sum(total_PP)/sum (Tx_PP) as Basket_size_PP,
sum(Total_PP)/count(distinct sbl_member_ID) as SalesPerCard, sum (Tx_PP)/count(distinct sbl_member_ID) as Frequency
from Pom.CM_EP_LOST_Sale_ALL
group by [TYPE] ;*/

   
/** Sales Lost Total **/
/*create VIEW Pom.CM_EP_LOST_Sale_Total_END  as
select 'TOTAL ' as [TYPE] , count(distinct sbl_member_ID) as T1C,sum (Tx_PP) as Tx_PP,sum(gp_PP) as gp_PP,sum(Total_PP) as Totals_PP,
sum(gp_PP)/sum(net_total_PP) as gp_per_PP,Sum(total_PP)/sum (Tx_PP) as Basket_size_PP,
sum(Total_PP)/count(distinct sbl_member_ID) as SalesPerCard, sum (Tx_PP)/count(distinct sbl_member_ID) as Frequency
from Pom.CM_EP_LOST_Sale_ALL;*/

/*Append*/
/*CREATE VIEW Pom.CM_EP_LOST_Sale_Total_All AS
SELECT * 
FROM Pom.CM_EP_LOST_Sale_ALL_END
UNION ALL
SELECT * 
FROM Pom.CM_EP_LOST_Sale_Total_END;*/


/*Output Table2*/
/*20 Most Store Lost visit to*/
/*create ViEW Pom.CM_Ep_lost_type_end_lost_store  as
select a.*
from POM.CM_Ep_lost_type_end as a
where TYPE = 'Lost_Store';*/

TRUNCATE TABLE MKTCRM.POM.CM_Ep_lost_type_end_lost_store_;
INSERT INTO MKTCRM.POM.CM_Ep_lost_type_end_lost_store_
(sbl_member_ID, store_id, store_name, Tx_TY, gp_TY, total_TY, net_total_TY, gp_per_TY, Basket_size_TY)
SELECT 
    a.sbl_member_ID, 
    store_id,
    store_name,
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY,
    SUM(CAST(gp_TY AS FLOAT)) AS gp_TY,
    SUM(CAST(total_TY AS FLOAT)) AS total_TY,
    SUM(CAST(net_total_TY AS FLOAT)) AS net_total_TY,
    SUM(CAST(gp_TY AS FLOAT)) / NULLIF(SUM(CAST(net_total_TY AS FLOAT)), 0) AS gp_per_TY,
    SUM(CAST(total_TY AS FLOAT)) / NULLIF(SUM(CAST(Tx_TY AS FLOAT)), 0) AS Basket_size_TY
FROM 
    POM.CM_Ep_lost_type_end_lost_store a 
LEFT JOIN 
    POM.CM_Other_ty AS b ON a.sbl_member_ID = b.sbl_member_ID
GROUP BY 
    a.sbl_member_ID, store_id, store_name;



TRUNCATE TABLE MKTCRM.POM.CM_EXP_Lost_Visit ;
INSERT INTO MKTCRM.POM.CM_EXP_Lost_Visit
(store_id, store_name, Customer, Tx_TY, gp_TY, total_TY, gp_per_TY, Basket_size_TY, SalesPerCard, Frequency)
SELECT 
    store_id,
    store_name,
    COUNT(DISTINCT sbl_member_ID) AS Customer,
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY,
    SUM(CAST(gp_TY AS FLOAT)) AS gp_TY,
    SUM(CAST(total_TY AS FLOAT)) AS total_TY,
    SUM(CAST(gp_TY AS FLOAT)) / SUM(CAST(net_total_TY AS FLOAT)) AS gp_per_TY,
    SUM(CAST(total_TY AS FLOAT)) / SUM(CAST(Tx_TY AS FLOAT)) AS Basket_size_TY,
    SUM(CAST(total_TY AS FLOAT)) / COUNT(DISTINCT sbl_member_ID) AS SalesPerCard,
    SUM(CAST(Tx_TY AS FLOAT)) / COUNT(DISTINCT sbl_member_ID) AS Frequency
FROM 
    Pom.CM_Ep_lost_type_end_lost_store_
GROUP BY 
    store_id, store_name
ORDER BY 
    Customer DESC;


/*Output table3*/
   
SELECT TOP 20 *
FROM POM.CM_EXP_Lost_Visit
WHERE store_id IS NOT NULL
order by Customer DESC ;



/**Lost Visit_all Store**/
/*create VIEW Pom.CM_EXP_Lost_Visit_all  as
select store_id,store_name, 
count(distinct sbl_member_ID) as Customer,
sum (Tx_TY) as Tx_TY,sum(gp_TY) as gp_TY, Sum(total_TY) as total_TY,
sum(gp_TY)/sum(net_total_TY) as gp_per_TY, Sum(total_TY)/sum (Tx_TY) as Basket_size_TY,
sum(Total_TY)/count(distinct sbl_member_ID) as SalesPerCard,sum (Tx_TY)/count(distinct sbl_member_ID) as Frequency
from Pom.CM_Ep_lost_type_end_lost_store_ 
group by store_id, store_name ;*/

/*create VIEW POM.CM_EXP_Lost_Visit_all_2  as
select count(distinct sbl_member_ID) as Customer,
sum (Tx_TY) as Tx_TY,Sum(total_TY) as total_TY
/*sum(gp_TY) as gp_TY,*/
/*sum(gp_TY)/sum(net_total_TY) as gp_per_TY, Sum(total_TY)/sum (Tx_TY) as Basket_size_TY,*/
/*sum(Total_TY)/count(distinct T1C_CUSTOMER_ID) as SalesPerCard,sum (Tx_TY)/count(distinct T1C_CUSTOMER_ID) as Frequency*/
from POM.CM_Ep_lost_type_end_lost_store_ ;*/



/**Exising Customer**/
/*create VIEW POM.CM_EP_Exising  as
select distinct sbl_member_ID,FLAG
from POM.CM_Eli_TY_PP_F 
where FLAG = 'EXS'
group by sbl_member_ID,FLAG ;*/


/*create VIEW POM.CM_EP_Exising_TYPE as
select  a.*,b.sbl_member_ID as ID
from POM.CM_EP_Exising  as a left join POM.CM_Other_TY_TYPE_T1C_ as b
on a.sbl_member_ID = b.sbl_member_ID;*/

/*CREATE VIEW POM.CM_EP_Exising_TYPE_ as
SELECT *,
       CASE 
           WHEN sbl_member_ID NOT IN (SELECT sbl_member_ID FROM POM.CM_Other_TY_TYPE_T1C_) 
            AND sbl_member_ID NOT IN (SELECT sbl_member_ID FROM POM.CM_Other_PP_TYPE_T1C_) 
           THEN 'Single Store' 
           ELSE 'Multi Store' 
       END AS TYPE
FROM POM.CM_EP_Exising_TYPE;*/


TRUNCATE TABLE MKTCRM.POM.CM_EP_Exising_TYPE_END ;
INSERT INTO MKTCRM.POM.CM_EP_Exising_TYPE_END
(sbl_member_ID, [TYPE])
select distinct sbl_member_ID,TYPE
from POM.CM_EP_Exising_TYPE_
where sbl_member_ID is not null
group by sbl_member_ID,TYPE ;


/**New Customer**/
TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW;
INSERT INTO MKTCRM.POM.CM_EP_NEW
(sbl_member_ID, FLAG)
select distinct sbl_member_ID,FLAG
from POM.CM_Eli_TY_PP_F 
where FLAG = 'NEW'
group by sbl_member_ID,FLAG ;

TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW_TYPE;
INSERT INTO MKTCRM.POM.CM_EP_NEW_TYPE
(sbl_member_ID, FLAG, ID)
select  a.*,b.sbl_member_ID as ID
from POM.CM_EP_NEW  as a left join POM.CM_Other_pp_TYPE_T1C_  as b
on a.sbl_member_ID = b.sbl_member_ID ;

TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW_TYPE_ ;
INSERT INTO MKTCRM.POM.CM_EP_NEW_TYPE_
(sbl_member_ID, FLAG, ID, [TYPE])
SELECT *,
       CASE 
           WHEN ID IS NULL THEN 'NEW_Company'
           WHEN ID IS NOT NULL THEN 'NEW_Store'
       END AS TYPE
FROM POM.CM_EP_NEW_TYPE
WHERE sbl_member_ID IS NOT NULL;


TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW_TYPE_END  ;
INSERT INTO MKTCRM.POM.CM_EP_NEW_TYPE_END
(sbl_member_ID, [TYPE])
select distinct sbl_member_ID,[TYPE]
from POM.CM_EP_NEW_TYPE_
where sbl_member_ID is not null;


/***NEW Customer**/
/**Flag Summary Sales NEW Customer**/
/** Sales NEW Store_Company**/
/*create view POm.CM_EP_NEW_Sale_ALL as
select  a.*,Tx_TY,total_TY,gp_TY,net_total_TY
from Pom.CM_Ep_NEW_type_end as a left join Pom.CM_Eli_TY_2 as b
on a.sbl_member_ID = b.sbl_member_ID;*/


TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW_TYPE_END  ;
INSERT INTO MKTCRM.POM.CM_EP_NEW_Sale_ALL_END
([TYPE], T1C, Tx_TY, gp_TY, Totals_TY, gp_per_TY, Basket_size_TY, SalesPerCard, Frequency)
select TYPE, count(distinct sbl_member_ID) as T1C,sum (Tx_TY) as Tx_TY,sum(gp_TY) as gp_TY,sum(Total_TY) as Totals_TY,
sum(gp_TY)/sum(net_total_TY) as gp_per_TY,Sum(total_TY)/sum (Tx_TY) as Basket_size_TY,
sum(Total_TY)/count(distinct sbl_member_ID) as SalesPerCard, sum (Tx_TY)/count(distinct sbl_member_ID) as Frequency
from Pom.CM_EP_NEW_Sale_ALL
group by TYPE ;



/** Sales NEW Total **/
TRUNCATE TABLE MKTCRM.POM.CM_EP_NEW_Sale_Total_END ;
INSERT INTO MKTCRM.POM.CM_EP_NEW_Sale_Total_END
([TYPE], T1C, Tx_TY, gp_TY, Totals_TY, gp_per_TY, Basket_size_TY, SalesPerCard, Frequency)
select 'TOTAL ' as TYPE , count(distinct sbl_member_ID) as T1C,sum (Tx_TY) as Tx_TY,sum(gp_TY) as gp_TY,sum(Total_TY) as Totals_TY,
sum(gp_TY)/sum(net_total_TY) as gp_per_TY,Sum(total_TY)/sum (Tx_TY) as Basket_size_TY,
sum(Total_TY)/count(distinct sbl_member_ID) as SalesPerCard, sum (Tx_TY)/count(distinct sbl_member_ID) as Frequency
from Pom.CM_EP_NEW_Sale_ALL;

/*Append*/
/*CREATE view  Pom.CM_EP_NEW_Sale_Total_All AS
SELECT * 
FROM Pom.CM_EP_NEW_Sale_ALL_END
UNION ALL
SELECT * 
FROM Pom.CM_EP_NEW_Sale_Total_END;*/


/*Output Table4*/
/**Final Existing customer**/
TRUNCATE TABLE MKTCRM.POM.CM_EXP_EXIS_All ;
INSERT INTO MKTCRM.POM.CM_EXP_EXIS_All
(sbl_member_id, [TYPE], Tx_TY, total_TY, gp_per_TY, Basket_size_TY, Tx_TY_SE, total_TY_SE, gp_per_TY_SE, Basket_size_TY_SE, MOST_STORE_TY_SE, Tx_TY_OT, total_TY_OT, gp_per_TY_OT, Basket_size_TY_OT, Tx_TY_TT, total_TY_TT, gp_per_TY_TT, Basket_size_TY_TT, Tx_PP, total_PP, gp_per_PP, Basket_size_PP, Tx_PP_SE, total_PP_SE, gp_per_PP_SE, Basket_size_PP_SE, MOST_STORE_PP_SE, Tx_PP_OT, total_PP_OT, gp_per_PP_OT, Basket_size_PP_OT, Tx_PP_TT, total_PP_TT, gp_per_PP_TT, Basket_size_PP_TT)
SELECT a.sbl_member_id,a.[TYPE],
	b.Tx_TY, b.total_TY, b.gp_per_TY, b.Basket_size_TY,
	c.Tx_TY_SE, c.total_TY_SE, c.gp_per_TY_SE, c.Basket_size_TY_SE, c.MOST_STORE_TY_SE,
	d. Tx_TY_OT, d.total_TY_OT, d.gp_per_TY_OT, d.Basket_size_TY_OT,
	e.Tx_TY_TT, e.total_TY_TT, e.gp_per_TY_TT, e.Basket_size_TY_TT,
	f.Tx_PP, f.total_PP, f.gp_per_PP, f.Basket_size_PP,
	g.Tx_PP_SE, g.total_PP_SE, g.gp_per_PP_SE, g.Basket_size_PP_SE, g.MOST_STORE_PP_SE,
	h.Tx_PP_OT, h.total_PP_OT, h.gp_per_PP_OT, h.Basket_size_PP_OT,
	i.Tx_PP_TT, i.total_PP_TT, i.gp_per_PP_TT, i.Basket_size_PP_TT
FROM Pom.CM_EP_Exising_TYPE_END AS a
LEFT JOIN Pom.CM_EP_Eli_TY_2_END AS b ON a.sbl_member_id = b.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_TY_END AS c ON a.sbl_member_id = c.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_TY_END AS d ON a.sbl_member_id = d.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_TY_END AS e ON a.sbl_member_id = e.sbl_member_id
LEFT JOIN Pom.CM_EP_Eli_PP_2_END AS f ON a.sbl_member_id = f.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_PP_END AS g ON a.sbl_member_id = g.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_PP_END AS h ON a.sbl_member_id = h.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_PP_END AS i ON a.sbl_member_id = i.sbl_member_id;



/**Final lost customer**/
TRUNCATE TABLE MKTCRM.POM.CM_EXP_LOST_All ;
INSERT INTO MKTCRM.POM.CM_EXP_LOST_All
(sbl_member_ID, [TYPE], Tx_TY, total_TY, gp_per_TY, Basket_size_TY, Tx_TY_SE, total_TY_SE, gp_per_TY_SE, Basket_size_TY_SE, MOST_STORE_TY_SE, Tx_TY_TT, total_TY_TT, gp_per_TY_TT, Basket_size_TY_TT, Tx_PP, total_PP, gp_per_PP, Basket_size_PP, Tx_PP_SE, total_PP_SE, gp_per_PP_SE, Basket_size_PP_SE, MOST_STORE_PP_SE, Tx_PP_OT, total_PP_OT, gp_per_PP_OT, Basket_size_PP_OT, Tx_PP_TT, total_PP_TT, gp_per_PP_TT, Basket_size_PP_TT)
SELECT a.sbl_member_ID, a.[TYPE],
	Tx_TY, total_TY, gp_per_TY, Basket_size_TY,
	Tx_TY_SE, total_TY_SE, gp_per_TY_SE, Basket_size_TY_SE, MOST_STORE_TY_SE,
	Tx_TY_TT, total_TY_TT, gp_per_TY_TT, Basket_size_TY_TT,
	Tx_PP, total_PP, gp_per_PP, Basket_size_PP,
	Tx_PP_SE, total_PP_SE, gp_per_PP_SE, Basket_size_PP_SE, MOST_STORE_PP_SE,
	Tx_PP_OT, total_PP_OT, gp_per_PP_OT, Basket_size_PP_OT,
	Tx_PP_TT, total_PP_TT, gp_per_PP_TT, Basket_size_PP_TT
FROM Pom.CM_EP_LOST_TYPE_END AS a
LEFT JOIN Pom.CM_EP_Eli_TY_2_END AS b ON a.sbl_member_id = b.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_TY_END AS c ON a.sbl_member_id = c.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_TY_END AS d ON a.sbl_member_id = d.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_TY_END AS e ON a.sbl_member_id = e.sbl_member_id
LEFT JOIN Pom.CM_EP_Eli_PP_2_END AS f ON a.sbl_member_id = f.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_PP_END AS g ON a.sbl_member_id = g.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_PP_END AS h ON a.sbl_member_id = h.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_PP_END AS i ON a.sbl_member_id = i.sbl_member_id;


/**Final New customer**/
TRUNCATE TABLE MKTCRM.POM.CM_EXP_LOST_All ;
INSERT INTO MKTCRM.POM.CM_EXP_New_All
(sbl_member_ID, [TYPE], Tx_TY, total_TY, gp_per_TY, Basket_size_TY, Tx_TY_SE, total_TY_SE, gp_per_TY_SE, Basket_size_TY_SE, MOST_STORE_TY_SE, Tx_TY_OT, total_TY_OT, gp_per_TY_OT, Basket_size_TY_OT, Tx_TY_TT, total_TY_TT, gp_per_TY_TT, Basket_size_TY_TT, Tx_PP, total_PP, gp_per_PP, Basket_size_PP, Tx_PP_SE, total_PP_SE, gp_per_PP_SE, Basket_size_PP_SE, MOST_STORE_PP_SE, Tx_PP_OT, total_PP_OT, gp_per_PP_OT, Basket_size_PP_OT, Tx_PP_TT, total_PP_TT, gp_per_PP_TT, Basket_size_PP_TT)
SELECT a.sbl_member_ID , a.[TYPE],
	Tx_TY, total_TY, gp_per_TY, Basket_size_TY,
	Tx_TY_SE, total_TY_SE, gp_per_TY_SE, Basket_size_TY_SE, MOST_STORE_TY_SE,
	Tx_TY_OT, total_TY_OT, gp_per_TY_OT, Basket_size_TY_OT,
	Tx_TY_TT, total_TY_TT, gp_per_TY_TT, Basket_size_TY_TT,
	Tx_PP, total_PP, gp_per_PP, Basket_size_PP,
	Tx_PP_SE, total_PP_SE, gp_per_PP_SE, Basket_size_PP_SE, MOST_STORE_PP_SE,
	Tx_PP_OT, total_PP_OT, gp_per_PP_OT, Basket_size_PP_OT,
	Tx_PP_TT, total_PP_TT, gp_per_PP_TT, Basket_size_PP_TT
FROM Pom.CM_EP_New_TYPE_END AS a
LEFT JOIN Pom.CM_EP_Eli_TY_2_END AS b ON a.sbl_member_id = b.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_TY_END AS c ON a.sbl_member_id = c.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_TY_END AS d ON a.sbl_member_id = d.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_TY_END AS e ON a.sbl_member_id = e.sbl_member_id
LEFT JOIN Pom.CM_EP_Eli_PP_2_END AS f ON a.sbl_member_id = f.sbl_member_id
LEFT JOIN Pom.CM_EP_Second_Store_PP_END AS g ON a.sbl_member_id = g.sbl_member_id
LEFT JOIN Pom.CM_EP_Other_Store_PP_END AS h ON a.sbl_member_id = h.sbl_member_id
LEFT JOIN Pom.CM_EP_Total_Store_PP_END AS i ON a.sbl_member_id = i.sbl_member_id;


