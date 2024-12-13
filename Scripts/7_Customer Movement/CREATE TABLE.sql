/*INSERT INTO MKTCRM.dbo.all_2023
(STORE_ID, SBL_MEMBER_ID, REF_KEY, TTM2, quant, TOTAL, NET_TOTAL, GP, STORE_FORMAT, STORE_NAME)
select distinct store_id,sbl_member_id,ref_key,trn_dte as ttm2,  
		SUM(QTY) AS quant,
    	SUM(TOTAL) AS total,
    	SUM(NET_TOTAL) AS net_total,
    	SUM(GP) AS gp,
	store_format,STORE_NAME 
from topst1c.dbo.Sales_promotion_comp_202409 a 
left join topsrst.dbo.D_store as b on a.store_id = b.STORE_CODE 
group by store_id,sbl_member_id,ref_key,trn_dte,store_format,STORE_NAME   
having Sum(TOTAL) > 0.00;*/

   -- ตรวจสอบว่ามี table นี้อยู่หรือไม่
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName AND TABLE_SCHEMA = 'dbo')
    BEGIN
        -- ถ้ามี table อยู่แล้ว ให้ลบข้อมูลทั้งหมดใน table ก่อน
        SET @SQL = N'TRUNCATE TABLE ' + @TableName + ';';
        EXEC sp_executesql @SQL;
    END
    ELSE
    BEGIN
        -- ถ้าไม่มี table ให้สร้างตารางใหม่
        SET @SQL = N'
        CREATE TABLE ' + @TableName + ' (
            STORE_ID VARCHAR(5),
            SBL_MEMBER_ID VARCHAR(30),
            REF_KEY VARCHAR(50),
            TTM2 VARCHAR(10),
            quant MONEY,
            TOTAL MONEY,
            NET_TOTAL MONEY,
            GP MONEY,
            STORE_FORMAT VARCHAR(50),
            STORE_NAME VARCHAR(100)
        );';
        EXEC sp_executesql @SQL;
    END



CREATE TABLE [10.35.0.77].MKTCRM.dbo.CM_all_2023 (
            STORE_ID VARCHAR(5),
			SBL_MEMBER_ID VARCHAR(30),
			REF_KEY VARCHAR(50),
			TTM2 VARCHAR(10),
			quant MONEY,
			TOTAL MONEY,
			NET_TOTAL MONEY,
			GP MONEY,
			STORE_FORMAT VARCHAR(50),
			STORE_NAME VARCHAR(100)
);

create table MKTCRM.dbo.ALL_TY_1 (
	STORE_ID VARCHAR(5),
	SBL_MEMBER_ID VARCHAR(30),
	REF_KEY VARCHAR(50),
	quant MONEY,
	TOTAL MONEY,
	NET_TOTAL MONEY,
	GP MONEY,
	STORE_FORMAT VARCHAR(50),
	STORE_NAME VARCHAR(100),
	TTM2 VARCHAR(10)
);


select sbl_member_id,store_id,store_format,STORE_NAME,sum(TX_TY) as Tx_TY,sum(quant_TY) as quant_TY, sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY, sum(gp_TY) as gp_TY

create VIEW Pom.CM_ALL_TY_1 AS
select store_id,sbl_member_id,REF_key,sum(QUANT) as quant, Sum(TOTAL) as total, sum(NET_TOTAL) as net_total, sum(GP) as gp,
store_format,STORE_NAME,TTM2 
from MKTCRM.Pom.CM_all_2023
where TTM2 between '20241101' and '20241130'  /*ระบุ period ที่จะ compare*/
group by  store_id,sbl_member_id,REF_key,store_format,STORE_NAME,TTM2;



create VIEW Pom.CM_ALL_PP_1  as
select store_id,sbl_member_id,REF_key,sum(QUANT) as quant, Sum(TOTAL) as total, sum(NET_TOTAL) as net_total, sum(GP) as gp,
store_format,STORE_NAME,TTM2 
from MKTCRM.Pom.CM_All_2023
where TTM2 between '20241001' and '20241031' /*ระบุ period ที่จะ compare*/
group by  store_id,sbl_member_id,REF_key,store_format,STORE_NAME,TTM2;


create VIEW Pom.CM_ALL_TY_2  as
select sbl_member_id,store_id,COUNT(distinct ref_key) as Tx_TY, sum(quant) as quant_TY, sum(total) as total_TY, 
sum(net_total) as net_total_TY, sum(gp) as gp_TY, store_format, STORE_NAME 
from  MKTCRM.Pom.CM_ALL_TY_1
group by sbl_member_id,store_id,store_format,STORE_NAME ;


create VIEW Pom.CM_ALL_PP_2 as
select sbl_member_id,store_id,COUNT(distinct REF_key) as Tx_PP, sum(quant) as quant_PP, sum(total) as total_PP, 
sum(net_total) as net_total_PP, sum(gp) as gp_PP, store_format, STORE_NAME 
from  MKTCRM.Pom.CM_ALL_PP_1
group by sbl_member_id,store_id,store_format,STORE_NAME;


create VIEW Pom.CM_ALL_TY_3 as
select sbl_member_id,store_id,store_format,STORE_NAME,sum(TX_TY) as Tx_TY,sum(quant_TY) as quant_TY, sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY, sum(gp_TY) as gp_TY
from  MKTCRM.Pom.CM_ALL_TY_2
group by sbl_member_id,store_id,store_format,STORE_NAME ;


create VIEW Pom.CM_ALL_PP_3  as
select sbl_member_id,store_id,store_format,STORE_NAME,sum(TX_PP) as Tx_PP,sum(quant_PP) as quant_PP, sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP, sum(gp_PP) as gp_PP
from  MKTCRM.Pom.CM_ALL_PP_2
group by sbl_member_id,store_id,store_format,STORE_NAME 



create VIEW Pom.CM_ALL_TY_6  as
select count(distinct sbl_member_ID ) as  ID, sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY, Sum(total_TY) as total_TY, 
sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY 
from  MKTCRM.Pom.CM_ALL_TY_3;


create VIEW Pom.CM_ALL_PP_6 as
select count(distinct sbl_member_ID ) as  ID, sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, Sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP 
from  MKTCRM.Pom.CM_ALL_PP_3;

/**Store_Eligible**/
create table MKTCRM.Pom.CM_Eli_TY_1 (
	SBL_MEMBER_ID VARCHAR(30),
	STORE_ID VARCHAR(5),
	STORE_FORMAT VARCHAR(50),
	STORE_NAME VARCHAR(100),
	Tx_TY MONEY,
	quant_TY MONEY,
	total_TY MONEY,
	net_total_TY MONEY,
	gp_TY MONEY
);


create table MKTCRM.Pom.CM_Eli_PP_1  (
	SBL_MEMBER_ID VARCHAR(30),
	STORE_ID VARCHAR(5),
	STORE_FORMAT VARCHAR(50),
	STORE_NAME VARCHAR(100),
	Tx_PP MONEY,
	quant_PP MONEY,
	total_PP MONEY,
	net_total_PP MONEY,
	gp_PP MONEY
);


create VIEW Pom.CM_Eli_PP_1  as
select distinct sbl_member_ID,store_id,store_format,STORE_NAME,sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, Sum(total_PP) as total_PP, 
sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP
from MKTCRM.dbo.ALL_PP_3
where sbl_member_ID is not null and store_id in ('054') /*ระบุสาขา*/
group by sbl_member_ID,store_id,store_format,STORE_NAME;


create VIEW Pom.CM_Eli_TY_2 as
select distinct sbl_member_ID,sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY,Sum(total_TY) as total_TY,
	   sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY
from  MKTCRM.Pom.CM_Eli_TY_1
group by sbl_member_ID ;

create VIEW Pom.CM_Eli_PP_2 as
select distinct sbl_member_ID,sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP,Sum(total_PP) as total_PP,
	   sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP
from MKTCRM.Pom.CM_Eli_PP_1
group by sbl_member_ID ;


create VIEW Pom.CM_Eli_TY_3 as
select count(distinct sbl_member_ID ) as ID, sum (Tx_TY) as Tx_TY ,sum(quant_TY) as quant_TY, 
	   Sum(total_TY) as total_TY, sum(net_total_TY) as net_total_TY,sum(gp_TY) as gp_TY 
from MKTCRM.Pom.CM_Eli_TY_2;

create VIEW Pom.CM_Eli_PP_3 as
select count(distinct sbl_member_ID ) as ID, sum (Tx_PP) as Tx_PP ,sum(quant_PP) as quant_PP, 
	   Sum(total_PP) as total_PP, sum(net_total_PP) as net_total_PP,sum(gp_PP) as gp_PP 
from MKTCRM.Pom.CM_Eli_PP_2;


create table MKTCRM.Pom.CM_Other_TY (
	SBL_MEMBER_ID VARCHAR(30),
	STORE_ID VARCHAR(5),
	STORE_FORMAT VARCHAR(50),
	STORE_NAME VARCHAR(100),
	Tx_TY MONEY,
	quant_TY MONEY,
	total_TY MONEY,
	net_total_TY MONEY,
	gp_TY VARCHAR(50),
	STORE_RANK INT);

/*create VIEW Pom.CM_Other_TY  as
select a.*
from MKTCRM.dbo.All_TY_3 as a 
where store_id not in ('054')   /*ระบุสาขา*/
order by sbl_member_ID, TX_TY desc, Total_TY desc;*/


create table MKTCRM.Pom.CM_Other_PP (
	SBL_MEMBER_ID VARCHAR(30),
	STORE_ID VARCHAR(5),
	STORE_FORMAT VARCHAR(50),
	Tx_PP MONEY,
	STORE_NAME VARCHAR(100),
	quant_PP MONEY,
	total_PP MONEY,
	net_total_PP MONEY,
	gp_PP VARCHAR(50),
	STORE_RANK INT);

/*create VIEW Pom.CM_Other_PP  as
select a.*
from MKTCRM.dbo.All_PP_3 as a
where store_id not in ('054')  /*ระบุสาขา*/
order by sbl_member_ID, TX_PP desc, Total_PP desc;*/


create VIEW Pom.CM_Other_PP as
select a.*
from MKTCRM.Pom.CM_All_PP_3 as a
where store_id not in ('054');  /*ระบุสาขา*/


CREATE VIEW Pom.CM_Other_TY_TYPE AS
SELECT 
    *,
    CASE 
        WHEN STORE_RANK = 1 THEN 'Second Store'
        ELSE 'Other Store'
    END AS TYPE
FROM MKTCRM.Pom.CM_Other_TY
WHERE Total_TY IS NOT NULL;


CREATE VIEW Pom.CM_Other_PP_TYPE AS
SELECT 
    *,
    CASE 
        WHEN STORE_RANK = 1 THEN 'Second Store'
        ELSE 'Other Store'
    END AS TYPE
FROM MKTCRM.Pom.CM_Other_PP
WHERE Total_PP IS NOT NULL;


CREATE VIEW Pom.CM_Other_TY_TYPE_T1C AS
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
GROUP BY sbl_member_ID, TYPE;


create VIEW Pom.CM_Other_PP_TYPE_T1C  as
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
group by sbl_member_ID,TYPE  ;

create VIEW Pom.CM_Other_TY_TYPE_T1C_  as
select distinct sbl_member_ID
from MKTCRM.Pom.CM_Other_TY_TYPE_T1C
where sbl_member_ID is not null
group by sbl_member_ID ;


create VIEW Pom.CM_Other_PP_TYPE_T1C_  as
select distinct sbl_member_ID
from MKTCRM.Pom.CM_Other_PP_TYPE_T1C
where sbl_member_ID is not null
group by sbl_member_ID ;


create VIEW Pom.CM_EP_Second_Store_TY as
select a.*
from MKTCRM.Pom.CM_Other_TY_TYPE as a
where TYPE = 'Second Store';


create VIEW Pom.CM_EP_Second_Store_PP as
select a.*
from MKTCRM.Pom.CM_Other_PP_TYPE as a
where TYPE = 'Second Store' ;


CREATE VIEW Pom.CM_EP_Second_Store_TY_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY_SE, 
    SUM(CAST(total_TY AS FLOAT)) AS total_TY_SE, 
    SUM(CAST(gp_TY AS FLOAT)) / SUM(CAST(net_total_TY AS FLOAT)) AS gp_per_TY_SE, 
    SUM(CAST(total_TY AS FLOAT)) / SUM(CAST(Tx_TY AS FLOAT)) AS Basket_size_TY_SE,
    STORE_NAME AS MOST_STORE_TY_SE
FROM MKTCRM.Pom.CM_EP_Second_Store_TY
GROUP BY sbl_member_ID, STORE_NAME;


CREATE VIEW Pom.CM_EP_Second_Store_PP_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP_SE, 
    SUM(CAST(total_PP AS FLOAT)) AS total_PP_SE, 
    SUM(CAST(gp_PP AS FLOAT)) / SUM(CAST(net_total_PP AS FLOAT)) AS gp_per_PP_SE, 
    SUM(CAST(total_PP AS FLOAT)) / SUM(CAST(Tx_PP AS FLOAT)) AS Basket_size_PP_SE,
    STORE_NAME AS MOST_STORE_PP_SE
FROM MKTCRM.Pom.CM_EP_Second_Store_PP
GROUP BY sbl_member_ID, STORE_NAME;



create VIEW Pom.CM_EP_Other_Store_TY as
select a.*
from MKTCRM.Pom.CM_Other_TY_TYPE as a
where TYPE = 'Other Store';



create VIEW Pom.CM_EP_Other_Store_PP as
select a.*
from MKTCRM.Pom.CM_Other_PP_TYPE as a
where TYPE = 'Other Store';


CREATE VIEW Pom.CM_EP_Other_Store_TY_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_TY AS FLOAT)) AS Tx_TY_OT, 
    SUM(CAST(total_TY AS FLOAT)) AS total_TY_OT, 
    SUM(CAST(gp_TY AS FLOAT)) / SUM(CAST(net_total_TY AS FLOAT)) AS gp_per_TY_OT, 
    SUM(CAST(total_TY AS FLOAT)) / SUM(CAST(Tx_TY AS FLOAT)) AS Basket_size_TY_OT
FROM MKTCRM.Pom.CM_EP_Other_Store_TY
GROUP BY sbl_member_ID;



CREATE VIEW Pom.CM_EP_Other_Store_PP_END AS
SELECT DISTINCT 
    sbl_member_ID, 
    SUM(CAST(Tx_PP AS FLOAT)) AS Tx_PP_OT, 
    SUM(CAST(total_PP AS FLOAT)) AS total_PP_OT, 
    SUM(CAST(gp_PP AS FLOAT)) / SUM(CAST(net_total_PP AS FLOAT)) AS gp_per_PP_OT, 
    SUM(CAST(total_PP AS FLOAT)) / SUM(CAST(Tx_PP AS FLOAT)) AS Basket_size_PP_OT
FROM MKTCRM.Pom.CM_EP_Other_Store_PP 
GROUP BY sbl_member_ID;


create VIEW Pom.CM_EP_Total_Store_TY_END as
select distinct sbl_member_ID, sum (Tx_TY) as Tx_TY_TT, Sum(total_TY) as total_TY_TT, 
sum(gp_TY)/sum(net_total_TY) as gp_per_TY_TT, Sum(total_TY)/sum (Tx_TY) as Basket_size_TY_TT
from MKTCRM.Pom.CM_All_TY_3
group by sbl_member_ID  ;


create VIEW Pom.CM_EP_Total_Store_PP_END  as
select distinct sbl_member_ID, sum (Tx_PP) as Tx_PP_TT, Sum(total_PP) as total_PP_TT, 
sum(gp_PP)/sum(net_total_PP) as gp_per_PP_TT, Sum(total_PP)/sum (Tx_PP) as Basket_size_PP_TT
from MKTCRM.Pom.CM_All_PP_3
group by sbl_member_ID ;


CREATE VIEW Pom.CM_Eli_TY_PP AS
SELECT 
    COALESCE(sorted_a.sbl_member_ID, sorted_b.sbl_member_ID) AS sbl_member_ID,
    sorted_a.Tx_TY, sorted_a.quant_TY, sorted_a.total_TY, sorted_a.net_total_TY, sorted_a.gp_TY,  -- คอลัมน์จาก DH.Eli_TY_2
    sorted_b.Tx_PP, sorted_b.quant_PP, sorted_b.total_PP, sorted_b.net_total_PP, sorted_b.gp_PP   -- คอลัมน์จาก DH.Eli_PP_2
FROM 
    (SELECT * FROM MKTCRM.Pom.CM_Eli_TY_2 ) AS sorted_a
FULL OUTER JOIN 
    (SELECT * FROM MKTCRM.Pom.CM_Eli_PP_2 ) AS sorted_b
ON 
    sorted_a.sbl_member_ID = sorted_b.sbl_member_ID;
  
  CREATE view Pom.CM_Eli_TY_PP_F as
   SELECT 
    *,
    CASE 
        WHEN Total_PP IS NULL OR Total_PP = '' THEN 'NEW'
        ELSE 'EXS'
    END AS FLAG

FROM Pom.CM_Eli_TY_PP
WHERE Total_TY IS NOT NULL;


   


