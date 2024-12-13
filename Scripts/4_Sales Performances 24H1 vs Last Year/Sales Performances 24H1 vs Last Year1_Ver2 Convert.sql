/*Sales Performances YTDAug vs Last Year*/

------------------------------------------------------
-- ##### Sales Performances 
Note #1 : Table หลัก จะสร้างเป็น Store Procedure ไว้ หรือมีการสร้าง Table ขึ้นมาจริงๆ จำเป็นต้องมีการ TRUNCATE TABLE กรณีที่ต้องการล้างข้อมูลเก่าออกก่อน
Note #2 : Table ที่เป็น Temp หรือไม่มีการเปลี่ยนข้อมูลตัวแปรด้านใน จะสร้างเป็น Table View ไว้แทน เพื่อลดขั้นตอนการ TRUNCATE TABLE สามารถ select * from ข้อมูลออกมาได้เลย (ข้อมูลแปรเปลี่ยนตาม Table Main ใน Note #1 อยู่แล้ว)
Note #3 : ใช้ชื่อ Module เป็น SP ('Sales Performance') นำหน้าแต่ละชื่อ Table และ Procedure ในการจัดหมวดหมู่โปรแกรม ออกจากโปรแกรมอื่นๆ
-------------------------------------------------------

options dlcreatedir;
libname AH 'G:\Ton\Sales_Perform_Y24\';


/*Y2024*/

/****************************************************** CFR *******************************************************/
/****************************************************** CFR *******************************************************/
/****************************************************** CFR *******************************************************/


-- CFR_TY รวมกับ CFM_TY จะกลายเป็น CFG_TY (this year)
-- CFR รวมกับ CFM จะกลายเป็น CFG_LY (last year)


TRUNCATE TABLE MKTCRM.Ton1.[SP.CFR_SALE_YTD_TY] ;

-- รันข้อมูลที่จะใช้เข้า table : MKTCRM.Ton1.[SP.CFR_SALE_YTD_TY]
-- yyyymm รับค่า Topst1c.SALES_PROMOTION_COMP_&yyyymm 
-- yyyymmdd รับค่า trn_dte between '20240101' and '20241131' -> Startdate & Enddate

EXEC Ton1.SP_CFR_SALE_YTD_TY '202401' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202401' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202402' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202403' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202404' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202405' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202406' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202407' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202408' ,'20240101','20241131';


EXEC Ton1.SP_CFR_SALE_YTD_TY '202409' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202410' ,'20240101','20241131';
EXEC Ton1.SP_CFR_SALE_YTD_TY '202411' ,'20240101','20241131';

-- Original Script
/* 
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table AH.CFR_Sale_YTD_TY_&yyyymm as
	select distinct B.STORE_FORMAT, substr(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,
	            count(distinct catx('_', store_id, reference, trn_dte)) as Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFR' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B
	where A.store_id = B.store_code
	and trn_dte between '20240101' and '20241131'
	group by B.STORE_FORMAT, Year_mth, sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202401)
%EXECUTE_SALE_TRANS_ALL(202402)
%EXECUTE_SALE_TRANS_ALL(202403)
%EXECUTE_SALE_TRANS_ALL(202404)
%EXECUTE_SALE_TRANS_ALL(202405)
%EXECUTE_SALE_TRANS_ALL(202406)
%EXECUTE_SALE_TRANS_ALL(202407)
%EXECUTE_SALE_TRANS_ALL(202408)
;



data AH.CFR_Sale_YTD_TY;
set AH.CFR_Sale_YTD_TY_202401
AH.CFR_Sale_YTD_TY_202402
AH.CFR_Sale_YTD_TY_202403
AH.CFR_Sale_YTD_TY_202404
AH.CFR_Sale_YTD_TY_202405
AH.CFR_Sale_YTD_TY_202406
AH.CFR_Sale_YTD_TY_202407
AH.CFR_Sale_YTD_TY_202408
;
run;
*/


-- แก้ไข Script
/*
-- 202401 -- 2,263,442 row
select distinct B.STORE_FORMAT, SUBSTRING(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,
	            COUNT(DISTINCT A.store_id + '_' + A.reference + '_' + A.trn_dte) AS Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFR' as BU
	from Topst1c.dbo.SALES_PROMOTION_COMP_202401 as A, Topsrst.dbo.d_store as B
	where A.store_id = B.store_code
	and trn_dte between '20240101' and '20241131'
	group by B.STORE_FORMAT,  SUBSTRING(trn_dte, 1,6), sbl_member_id

-- 202402 -- 2,148,677 row
select distinct B.STORE_FORMAT, SUBSTRING(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,
	            COUNT(DISTINCT A.store_id + '_' + A.reference + '_' + A.trn_dte) AS Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFR' as BU
	from Topst1c.dbo.SALES_PROMOTION_COMP_202402 as A, Topsrst.dbo.d_store as B
	where A.store_id = B.store_code
	and trn_dte between '20240101' and '20241131'
	group by B.STORE_FORMAT,  SUBSTRING(trn_dte, 1,6), sbl_member_id
	
	
	
	
-- 202403 -- 2,201,783 row	
select distinct B.STORE_FORMAT, SUBSTRING(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,
	            COUNT(DISTINCT A.store_id + '_' + A.reference + '_' + A.trn_dte) AS Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFR' as BU
	from Topst1c.dbo.SALES_PROMOTION_COMP_202403 as A, Topsrst.dbo.d_store as B
	where A.store_id = B.store_code
	and trn_dte between '20240101' and '20241131'
	group by B.STORE_FORMAT,  SUBSTRING(trn_dte, 1,6), sbl_member_id
*/	
	


-- จาก table MKTCRM.Ton1.[SP.CFR_SALE_YTD_TY] นี้ มาสร้าง MKTCRM.Ton1.[SP.CFR_Sale_YTD_TY_cok] ต่อ
-- select * from MKTCRM.Ton1.[SP.CFR_Sale_YTD_cok ;

SELECT * FROM MKTCRM.Ton1.[SP.CFR_Sale_YTD_TY_cok];

/* -- โค้ดเก่า ยังไม่ได้แก้ไข
create table MKTCRM.Ton1.CFR_Sale_YTD_TY_cok (compress = yes) as
select distinct '01_TY' as Period, BU, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFR_Sale_YTD_TY as L
group by Period, BU, Year_mth, Flag_member
-- เอา group by 'Period' ออก 
order by Period, BU, Year_mth, Flag_member asc
;
*/

/* -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้ว
CREATE VIEW dbo.[SP.CFR_Sale_YTD_TY_cok] AS
SELECT DISTINCT
    '01_TY' AS Period,
    BU,
    Year_mth,
    Flag_member,
    COUNT(DISTINCT sbl_member_id) AS No_id,
    SUM(tx) AS tx,
    SUM(QUANT) AS quant,
    SUM(COALESCE(total, 0)) AS total,
    SUM(COALESCE(net_total, 0)) AS net_total,
    SUM(COALESCE(GP, 0)) AS gp
FROM MKTCRM.Ton1.[SP.CFR_SALE_YTD_TY] AS L
GROUP BY BU, Year_mth, Flag_member;
*/



/****************************************************** CFM TY *******************************************************/
/****************************************************** CFM TY *******************************************************/
/****************************************************** CFM TY *******************************************************/




TRUNCATE TABLE MKTCRM.Ton1.[SP.CFM_SALE_YTD_TY] ; 

-- รันข้อมูลที่จะใช้เข้า table : MKTCRM.Ton1.[SP.CFM_SALE_YTD_TY]
-- yyyymm รับค่า Topst1c.dbo.CFM_SALES_PROMOTION_COMP_&yyyymm 
-- yyyymmdd รับค่า trn_dte between '20240101' and '20241131' -> Startdate & Enddate



EXEC Ton1.SP_CFM_SALE_YTD_TY '202401' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202402' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202403' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202404' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202405' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202406' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202407' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202408' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202409' ,'20240101','20241131'; -- ลบออกแล้วรันใหม่

select * from MKTCRM.Ton1.[SP.CFM_SALE_YTD_TY] ;


--DELETE FROM MKTCRM.Ton1.[SP.CFM_SALE_YTD_TY]
--WHERE Year_mth = '202409';

EXEC Ton1.SP_CFM_SALE_YTD_TY '202409' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202410' ,'20240101','20241131';
EXEC Ton1.SP_CFM_SALE_YTD_TY '202411' ,'20240101','20241131';


-- Original Script
/*
/*CFM*/
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table AH.CFM_Sale_YTD_TY_&yyyymm as
	select distinct 'CFM' as STORE_FORMAT, substr(trn_dte, 1,6) as Year_mth, A.sbl_member_id,

                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,

	            count(distinct catx('_', store_id, reference, trn_dte)) as Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFM' as BU
	from Topst1c.CFM_SALES_PROMOTION_COMP_&yyyymm as A, Topscfm.STORE_MASTER as B
	where A.store_id = B.store_code
	and trn_dte between '20240101' and '20241131'
	group by B.STORE_FORMAT, Year_mth, sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202401)
%EXECUTE_SALE_TRANS_ALL(202402)
%EXECUTE_SALE_TRANS_ALL(202403)
%EXECUTE_SALE_TRANS_ALL(202404)
%EXECUTE_SALE_TRANS_ALL(202405)
%EXECUTE_SALE_TRANS_ALL(202406)
%EXECUTE_SALE_TRANS_ALL(202407)
%EXECUTE_SALE_TRANS_ALL(202408)
;



data AH.CFM_Sale_YTD_TY;
set AH.CFM_Sale_YTD_TY_202401
AH.CFM_Sale_YTD_TY_202402
AH.CFM_Sale_YTD_TY_202403
AH.CFM_Sale_YTD_TY_202404
AH.CFM_Sale_YTD_TY_202405
AH.CFM_Sale_YTD_TY_202406
AH.CFM_Sale_YTD_TY_202407
AH.CFM_Sale_YTD_TY_202408
;
run;
*/


-- แก้ไข Script
/*
-- 202408 -- 461,542 row
select distinct 'CFM' as STORE_FORMAT, SUBSTRING(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,

	            count(distinct A.store_id + '_' + A.reference + '_' + A.trn_dte) AS Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFM' as BU
from Topst1c.dbo.CFM_SALES_PROMOTION_COMP_202408 as A, Topscfm.dbo.STORE_MASTER as B
where A.store_id = B.store_code
and trn_dte between '20240101' and '20241131'
group by B.STORE_FORMAT, SUBSTRING(trn_dte, 1,6), sbl_member_id


-- 202407 -- 448,787 row
select distinct 'CFM' as STORE_FORMAT, SUBSTRING(trn_dte, 1,6) as Year_mth, A.sbl_member_id,
                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,

	            count(distinct A.store_id + '_' + A.reference + '_' + A.trn_dte) AS Tx,
                sum(qty) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFM' as BU
from Topst1c.dbo.CFM_SALES_PROMOTION_COMP_202407 as A, Topscfm.dbo.STORE_MASTER as B
where A.store_id = B.store_code
and trn_dte between '20240101' and '20241131'
group by B.STORE_FORMAT, SUBSTRING(trn_dte, 1,6), sbl_member_id
*/


-- จาก table MKTCRM.Ton1.[SP.CFM_SALE_YTD_TY] นี้ มาสร้าง MKTCRM.Ton1.[SP.CFM_Sale_YTD_TY_cok] ต่อ

Select * FROM MKTCRM.Ton1.[SP.CFM_Sale_YTD_TY_cok];

-- โค้ดเก่า ยังไม่ได้แก้ไข
/*
proc sql;
create table AH.CFM_Sale_YTD_TY_cok (compress = yes) as
select distinct '01_TY' as Period, BU, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFM_Sale_YTD_TY as L
group by Period, BU, Year_mth, Flag_member
order by Period, BU, Year_mth, Flag_member asc
;
quit;
*/

/* -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้ว
CREATE VIEW dbo.[SP.CFM_Sale_YTD_TY_cok] AS
SELECT DISTINCT 
    '01_TY' AS Period, 
    BU, 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx,0)) AS tx, 
    SUM(COALESCE(QUANT,0)) AS quant, 
    SUM(COALESCE(total,0)) AS total, 
    SUM(COALESCE(net_total,0)) AS net_total, 
    SUM(COALESCE(GP,0)) AS gp
FROM 
    MKTCRM.Ton1.[SP.CFM_Sale_YTD_TY] AS L
GROUP BY 
    BU, 
    Year_mth, 
    Flag_member
;
*/


/****************************************************** CFG 2024 *******************************************************/
/****************************************************** CFG 2024 *******************************************************/
/****************************************************** CFG 2024 *******************************************************/



-- ประกอบร่าง table ระหว่าง  CFR_Sale_YTD_TY และ CFM_Sale_YTD_TY


/*
data AH.CFG_Sale_YTD_TY;
set AH.CFR_Sale_YTD_TY
AH.CFM_Sale_YTD_TY
;
run;
*/

-- สร้างtable CFG_Sale_YTD_TY

-- สร้าง table CFG_Sale_YTD_TY (สร้าง CFG ของ TY , ที่รวม CFR + CFM ของ TY)
DROP TABLE MKTCRM.Ton1.[SP.CFG_SALE_YTD_TY]

EXEC Ton1.SP_CFG_SALE_YTD_TY ;




/*
CREATE TABLE  MKTCRM.Ton1.[SP.CFG_Sale_YTD_TY] (
			STORE_FORMAT VARCHAR(50),
		    Year_mth CHAR(6),
		    sbl_member_id VARCHAR(20),
		    Flag_member VARCHAR(15),
		    Tx INT,
		    quant INT,
		    total DECIMAL(18, 4),
		    net_total DECIMAL(18, 4),
		    GP DECIMAL(18, 4),
		    BU VARCHAR(10) );



INSERT INTO  MKTCRM.Ton1.[SP.CFG_Sale_YTD_TY] (STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU)
SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.[SP.CFM_Sale_YTD_TY]

UNION ALL

SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.[SP.CFR_Sale_YTD_TY] ;
*/

-- ประกอบร่างของ CFR และ CFM เป็นปี 2024
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TY] ;





/*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*/
/****************************************************** CFR LY *******************************************************/
/****************************************************** CFR LY *******************************************************/
/****************************************************** CFR LY *******************************************************/
/*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*//*Y2023*/




-- ต่อไปจะรันข้อมูลของปี 2023 ปีที่เป็น LY
-- รันข้อมูลที่จะใช้เข้า table : MKTCRM.Ton1.[SP.CFR_SALE_YTD_LY]
-- yyyymm รับค่า Topst1c.SALES_PROMOTION_COMP_&yyyymm 
-- yyyymmdd รับค่า trn_dte between '20230101' and '20230831' -> Startdate & Enddate

/*Y2023*/
/*CFR*/

EXEC Ton1.SP_CFR_SALE_YTD_LY '202301' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202302' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202303' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202304' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202305' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202306' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202307' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202308' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202309' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202310' ,'20230101','20230831';
EXEC Ton1.SP_CFR_SALE_YTD_LY '202311' ,'20230101','20230831';

-- โค้ดเก่า Original
/*
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table AH.CFR_Sale_YTD_LY_&yyyymm as
	select distinct B.STORE_FORMAT, substr(trn_dte, 1,6) as Year_mth, A.sbl_member_id,

                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,

	            count(distinct catx('_', store_id, reference, trn_dte)) as Tx,
                sum(qtY) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFR' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B
	where A.store_id = B.store_code
	and trn_dte between '20230101' and '20230831'
	group by B.STORE_FORMAT, Year_mth, sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202401)
%EXECUTE_SALE_TRANS_ALL(202402)
%EXECUTE_SALE_TRANS_ALL(202403)
%EXECUTE_SALE_TRANS_ALL(202404)
%EXECUTE_SALE_TRANS_ALL(202405)
%EXECUTE_SALE_TRANS_ALL(202406)
%EXECUTE_SALE_TRANS_ALL(202407)
%EXECUTE_SALE_TRANS_ALL(202408)
;


data AH.CFR_Sale_YTD_LY;
set AH.CFR_Sale_YTD_LY_202301
AH.CFR_Sale_YTD_LY_202302
AH.CFR_Sale_YTD_LY_202303
AH.CFR_Sale_YTD_LY_202304
AH.CFR_Sale_YTD_LY_202305
AH.CFR_Sale_YTD_LY_202306
AH.CFR_Sale_YTD_LY_202307
AH.CFR_Sale_YTD_LY_202308
;
run;


*/


-- โค้ดเก่า Original
/*
proc sql;
create table AH.CFR_Sale_YTD_LY_cok (compress = yes) as
select distinct '02_LY' as Period, BU, Year_mth, Flag_member, count(sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFR_Sale_YTD_LY as L
group by Period, BU, Year_mth, Flag_member
order by Period, BU, Year_mth, Flag_member asc
;
quit;
*/

/*
INSERT into MKTCRM.Ton1.[SR.CFR_Sale_YTD_LY_cok] (
	Period ,
    BU ,
    Year_mth,
    Flag_member ,
    No_id ,
    tx ,
    QUANT ,
    total ,
    net_total ,
    GP )
select distinct '02_LY' as Period, BU, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(COALESCE(total,0))as total, 
						sum(COALESCE(net_total,0)) as net_total,
                 		sum(COALESCE(GP,0)) as gp
from MKTCRM.Ton1.[SP.CFR_Sale_YTD_LY] as L
group by BU, Year_mth, Flag_member
order by Period, BU, Year_mth, Flag_member asc
*/


/*
CREATE view dbo.[SP.CFR_Sale_YTD_LY_cok] as 
select distinct '02_LY' as Period, BU, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(COALESCE(total,0))as total, 
						sum(COALESCE(net_total,0)) as net_total,
                 		sum(COALESCE(GP,0)) as gp
from MKTCRM.Ton1.[SP.CFR_Sale_YTD_LY] as L
group by BU, Year_mth, Flag_member
--order by Period, BU, Year_mth, Flag_member asc
*/


/*Y2023*/
/****************************************************** CFM LY *******************************************************/
/****************************************************** CFM LY *******************************************************/
/****************************************************** CFM LY *******************************************************/
/*Y2023*/



-- ต่อไปจะรันข้อมูลของปี 2023 ปีที่เป็น LY
-- รันข้อมูลที่จะใช้เข้า table : MKTCRM.Ton1.[SP.CFM_SALE_YTD_LY]
-- yyyymm รับค่า Topst1c.dbo.CFM_SALES_PROMOTION_COMP_&yyyymm 
-- yyyymmdd รับค่า trn_dte between '20230101' and '20230831' -> Startdate & Enddate
-- รันข้อมูลของปี 2023


-- รันข้อมูลปี 2023 เข้า table ;  MKTCRM.Ton1.[SP.CFM_SALE_YTD_LY]
EXEC Ton1.SP_CFM_SALE_YTD_LY '202301' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202302' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202303' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202304' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202305' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202306' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202307' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202308' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202309' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202310' ,'20230101','20230831';
EXEC Ton1.SP_CFM_SALE_YTD_LY '202311' ,'20230101','20230831';

-- โค้ดเก่า Original
/*
/*CFM*/
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table AH.CFM_Sale_YTD_LY_&yyyymm as
	select distinct 'CFM' as STORE_FORMAT, substr(trn_dte, 1,6) as Year_mth, A.sbl_member_id,

                case when A.sbl_member_id is not null 
                and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
                Then '01_Member' else '02_Non_member' end as Flag_member,

	            count(distinct catx('_', store_id, reference, trn_dte)) as Tx,
                sum(qtY) as quant,
				sum(total) as total, sum(net_total) as net_total, sum(GP) as GP, 'CFM' as BU
	from Topst1c.CFM_SALES_PROMOTION_COMP_&yyyymm as A, Topscfm.STORE_MASTER as B
	where A.store_id = B.store_code
	and trn_dte between '20230101' and '20230831'
	group by B.STORE_FORMAT, Year_mth, sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202401)
%EXECUTE_SALE_TRANS_ALL(202402)
%EXECUTE_SALE_TRANS_ALL(202403)
%EXECUTE_SALE_TRANS_ALL(202404)
%EXECUTE_SALE_TRANS_ALL(202405)
%EXECUTE_SALE_TRANS_ALL(202406)
%EXECUTE_SALE_TRANS_ALL(202407)
%EXECUTE_SALE_TRANS_ALL(202408)
;

data AH.CFM_Sale_YTD_LY;
set AH.CFM_Sale_YTD_LY_202301
AH.CFM_Sale_YTD_LY_202302
AH.CFM_Sale_YTD_LY_202303
AH.CFM_Sale_YTD_LY_202304
AH.CFM_Sale_YTD_LY_202305
AH.CFM_Sale_YTD_LY_202306
AH.CFM_Sale_YTD_LY_202307
AH.CFM_Sale_YTD_LY_202308
;
run;


*/ 

-- จาก table MKTCRM.Ton1.[SP.CFM_SALE_YTD_LY] นี้ มาสร้าง MKTCRM.Ton1.[SP.CFM_Sale_YTD_LY_cok] ต่อ

Select * FROM MKTCRM.Ton1.[SP.CFM_Sale_YTD_LY_cok];


 -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้ว
/*CREATE VIEW dbo.[SP.CFM_Sale_YTD_LY_cok] AS
SELECT DISTINCT 
    '02_TY' AS Period, 
    BU, 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx,0)) AS tx, 
    SUM(COALESCE(QUANT,0)) AS quant, 
    SUM(COALESCE(total,0)) AS total, 
    SUM(COALESCE(net_total,0)) AS net_total, 
    SUM(COALESCE(GP,0)) AS gp
FROM 
    MKTCRM.Ton1.[SP.CFM_Sale_YTD_LY] AS L
GROUP BY 
    BU, 
    Year_mth, 
    Flag_member
*/




/*Y2023*/
/****************************************************** CFG LY *******************************************************/
/****************************************************** CFG LY *******************************************************/
/****************************************************** CFG LY *******************************************************/
/*Y2023*/

-- ประกอบร่าง table ระหว่าง  MKTCRM.Ton1.[SP.CFR_Sale_YTD_LY] และ   MKTCRM.Ton1.[SP.CFM_Sale_YTD_TY]


-- สร้าง table CFG_Sale_YTD_LY (สร้าง CFG ของ LY , ที่รวม CFR + CFM ของ LY)
DROP TABLE MKTCRM.Ton1.[SP.CFG_Sale_YTD_LY] ;


EXEC Ton1.SP_CFG_SALE_YTD_LY ;


/*
CREATE TABLE MKTCRM.Ton1.[SP.CFG_Sale_YTD_LY] (
			STORE_FORMAT VARCHAR(50),
		    Year_mth CHAR(6),
		    sbl_member_id VARCHAR(20),
		    Flag_member VARCHAR(15),
		    Tx INT,
		    quant INT,
		    total DECIMAL(18, 4),
		    net_total DECIMAL(18, 4),
		    GP DECIMAL(18, 4),
		    BU VARCHAR(10)
		    );



INSERT INTO MKTCRM.Ton1.[SP.CFG_Sale_YTD_LY] (STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU)
SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.[SP.CFM_Sale_YTD_LY] 

UNION ALL

SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.[SP.CFR_Sale_YTD_LY]
;
*/
 

select * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_LY] ;

/****************************************************** Combine 2 Years, TYLY2  *******************************************************/
/****************************************************** Combine 2 Years, TYLY2  *******************************************************/
/****************************************************** Combine 2 Years, TYLY2  *******************************************************/



-- ล้างข้อมูลเก่าก่อนรันใหม่
TRUNCATE TABLE MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] ; 

EXEC Ton1.SP_CFG_Sale_YTD_TYLY2 ;

/*Combine 2 Years*/

/*
data MKTCRM.Ton1.CFG_Sale_YTD_TYLY2;
set 
MKTCRM.dbo.CFG_Sale_YTD_TY
MKTCRM.dbo.CFG_Sale_YTD_LY
;
run;
*/

/*
CREATE TABLE MKTCRM.Ton1.CFG_Sale_YTD_TYLY2 (
			STORE_FORMAT VARCHAR(50),
		    Year_mth CHAR(6),
		    sbl_member_id VARCHAR(20),
		    Flag_member VARCHAR(15),
		    Tx INT,
		    quant INT,
		    total DECIMAL(18, 4),
		    net_total DECIMAL(18, 4),
		    GP DECIMAL(18, 4),
		    BU VARCHAR(10)



INSERT INTO  MKTCRM.Ton1.CFG_Sale_YTD_TYLY2 (STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU)
SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.CFG_Sale_YTD_TY

UNION ALL

SELECT STORE_FORMAT, Year_mth, sbl_member_id, Flag_member, Tx, quant, total, net_total, GP, BU
FROM MKTCRM.Ton1.CFG_Sale_YTD_LY;
*/
--

select * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] ; 





/****************************************************** CFG TYLY2_cok *****************************************************/
/****************************************************** CFG TYLY2_cok *****************************************************/
/****************************************************** CFG TYLY2_cok *****************************************************/
/****************************************************** CFG TYLY2_cok *****************************************************/


-- สร้าง table view สำหรับ MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2_cok] ไว้ เพราะเปลี่ยนแค่ table ต้นทาง 

SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2_cok] 


-- โค้ดเก่า Original
/*
proc sql;
create table AH.CFG_Sale_YTD_TYLY2_cok (compress = yes) as
select distinct Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY2 as L
group by Year_mth, Flag_member
order by Year_mth, Flag_member asc
;
*/

-- โค้ดใหม่ปรับแก้ไข
/*
CREATE TABLE CFG_Sale_YTD_TYLY2_cok (
    Year_mth VARCHAR(6),
    Flag_member VARCHAR(20),
    No_id INT,
    tx INT,
    quant INT,
    total DECIMAL(20, 4),
    net_total DECIMAL(20, 4),
    gp DECIMAL(20, 4)
);

INSERT INTO CFG_Sale_YTD_TYLY_cok (Year_mth, Flag_member, No_id, tx, quant, total, net_total, gp)
SELECT 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.CFG_Sale_YTD_TYLY2 AS L
GROUP BY 
    Year_mth, Flag_member
ORDER BY 
    Year_mth, Flag_member ASC;
*/
--

/* -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้ว
create view dbo.[SP.CFG_Sale_YTD_TYLY2_cok] as
SELECT 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] AS L
GROUP BY 
    Year_mth, Flag_member
--ORDER BY 
--    Year_mth, Flag_member 
*/


/****************************************************** CFGe TYLY2_cok *****************************************************/
/****************************************************** CFGe TYLY2_cok *****************************************************/
/****************************************************** CFGe TYLY2_cok *****************************************************/
/****************************************************** CFGe TYLY2_cok *****************************************************/




-- สร้าง table view สำหรับ MKTCRM.Ton1.[SP.CFGe_Sale_YTD_TYLY2_cok] ไว้ เพราะเปลี่ยนแค่ table ต้นทาง 

SELECT * from MKTCRM.Ton1.[SP.CFGe_Sale_YTD_TYLY2_cok]  

-- โค้ดเก่า Original
/*
proc sql;
create table AH.CFGe_Sale_YTD_TYLY_cok (compress = yes) as
select distinct Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY2 as L
where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET', 'TOPS Fine Food', 'Super Store A-P', 'TOPS DAILY', 'SEGAFREDO', 'Eathai', 'CFM')
group by Year_mth, Flag_member
order by Year_mth, Flag_member asc
;
quit;
*/


-- โค้ดใหม่ ปรับแก้ไขแล้ว
/*
CREATE TABLE MKTCRM.Ton1.CFGe_Sale_YTD_TYLY_cok (
    Year_mth VARCHAR(6),
    Flag_member VARCHAR(20),
    No_id INT,
    tx INT,
    quant INT,
    total DECIMAL(20, 4),
    net_total DECIMAL(20, 4),
    gp DECIMAL(20, 4)
);
*/

/*
INSERT INTO MKTCRM.Ton1.CFGe_Sale_YTD_TYLY_cok (Year_mth, Flag_member, No_id, tx, quant, total, net_total, gp)
SELECT 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.CFG_Sale_YTD_TYLY2 AS L
WHERE 
    STORE_FORMAT IN ('Central Food Hall', 'TOPS MARKET', 'TOPS Fine Food', 'Super Store A-P', 'TOPS DAILY', 'SEGAFREDO', 'Eathai', 'CFM')
GROUP BY 
    Year_mth, Flag_member
ORDER BY 
    Year_mth, Flag_member ASC;
*/

--

/* -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้ว
CREATE view dbo.[SP.CFGe_Sale_YTD_TYLY2_cok] as
SELECT 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.CFG_Sale_YTD_TYLY2 AS L
WHERE 
    STORE_FORMAT IN ('Central Food Hall', 'TOPS MARKET', 'TOPS Fine Food', 'Super Store A-P', 'TOPS DAILY', 'SEGAFREDO', 'Eathai', 'CFM')
GROUP BY 
    Year_mth, Flag_member; 
*/ 



/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



-- สร้าง table MKTCRM.Ton1.[SP.CFG_Sale_YTD_TY_card] ;

SELECT  * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TY_card]; 

-- โค้ดเก่า Original
/*
proc sql;
create table AH.CFG_Sale_YTD_TY_card (compress = yes) as
select distinct sbl_member_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TY as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by sbl_member_id
;
quit;
*/


-- โค้ดปรับใหม่แก้ไข
/*
CREATE TABLE MKTCRM.Ton1.CFG_Sale_YTD_TY_card (
    sbl_member_id VARCHAR(50),
    tx INT,
    quant INT,
    total DECIMAL(20, 4),
    net_total DECIMAL(20, 4),
    gp DECIMAL(20, 4)
);


INSERT INTO MKTCRM.Ton1.CFG_Sale_YTD_TY_card (sbl_member_id, tx, quant, total, net_total, gp)
SELECT 
    sbl_member_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.CFG_Sale_YTD_TY AS L
WHERE 
    store_format NOT IN ('TOPS CLUB', 'Super Khum WS')
    AND Flag_member IN ('01_Member')
GROUP BY 
    sbl_member_id
;
*/
--
/* -- แก้ไขเป็นโค้ดใหม่ เนื่องจาก ไม่มีการเปลี่ยนตัวแปรด้านใน เพื่อลดขั้นตอนการ TRUNCATE TABLE แล้วต้อง insert ข้อมูลเข้าไปใหม่ , กรณีนีสามารถ select * from ออกมาดูได้เลย เพราะได้แก้ไขที่ table ต้นทางไว้อยู่แล้
CREATE view dbo.[SP.CFG_Sale_YTD_TY_card] as
SELECT 
    sbl_member_id, 
    SUM(COALESCE(tx, 0)) AS tx, 
    SUM(COALESCE(QUANT, 0)) AS quant, 
    SUM(COALESCE(total, 0)) AS total, 
    SUM(COALESCE(net_total, 0)) AS net_total, 
    SUM(COALESCE(GP, 0)) AS gp
FROM 
    MKTCRM.Ton1.CFG_Sale_YTD_TY AS L
WHERE 
    store_format NOT IN ('TOPS CLUB', 'Super Khum WS')
    AND Flag_member IN ('01_Member')
GROUP BY 
    sbl_member_id
*/




/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

/*
/*YTD - All Banner*/
data AH.CFG_Sale_YTD_TYLY_a;
set AH.CFG_Sale_YTD_TY
AH.CFG_Sale_YTD_LY
;
run;
*/

-- จากข้างบน ใช้ Table นี้แทน [ CFG_Sale_YTD_TY + CFG_Sale_YTD_LY ]
--MKTCRM.dbo.[SP.CFG_Sale_YTD_TYLY2] ;


/******************************************** YTD - All exclude topsclub, skw ********************************************/
/******************************************** YTD - All exclude topsclub, skw ********************************************/
/******************************************** YTD - All exclude topsclub, skw ********************************************/

/*YTD - All exclude topsclub, skw*/

-- ล้างข้อมูลเก่าในตารางก่อนได้ 
TRUNCATE table MKTCRM.Ton1.[SP.CFG_SALE_YTD_TYLY_a2] ;

-- รันเพื่อสร้าง table ; MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2]
EXEC Ton1.SP_CFG_Sale_YTD_TYLY_a2 ;

-- ดึง table CFG TYLY2_a2 ออกมาดู
select * from MKTCRM.Ton1.[SP.CFG_SALE_YTD_TYLY_a2] ;

-- โค้ดเก่า Original
/*create table AH.CFG_Sale_YTD_TYLY_a2 (compress = yes) as
select A.*,
case when A.store_format in ('Central Food Hall', 'TOPS Fine Food') then '01_Tops Food Hall'
when A.store_format in ('TOPS MARKET') then '02_Tops Large'
when A.store_format in ('TOPS DAILY', 'CFM') then '03_Tops Daily'
else '04_Others' end as store_format2
from AH.CFG_Sale_YTD_TYLY_a as A
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
CREATE VIEW dbo.CFG_Sale_YTD_TYLY_a2 AS
SELECT A.*,
    CASE 
        WHEN A.store_format IN ('Central Food Hall', 'TOPS Fine Food') THEN '01_Tops Food Hall'
        WHEN A.store_format IN ('TOPS MARKET') THEN '02_Tops Large'
        WHEN A.store_format IN ('TOPS DAILY', 'CFM') THEN '03_Tops Daily'
        ELSE '04_Others' 
    END AS store_format2
FROM MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] AS A;
*/




/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_YTD] ; 


-- โค้ดเก่า Original
/*
create table AH.CFG3_Sale_YTD_TYLY_cok_YTD as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by Years, Flag_member
order by Years, Flag_member asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
CREATE VIEW dbo.[SP.CFG3_Sale_YTD_TYLY_cok_YTD] AS
SELECT 
    DISTINCT SUBSTRING(Year_mth, 1, 4) AS Years, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(tx) AS tx, 
    SUM(QUANT) AS quant, 
    SUM(total) AS total, 
    SUM(net_total) AS net_total, 
    SUM(GP) AS gp
FROM 
    MKTCRM.Ton1.[SP.CFG_SALE_YTD_TYLY_a2] AS L
WHERE 
    store_format NOT IN ('TOPS CLUB', 'Super Khum WS')
GROUP BY 
    SUBSTRING(Year_mth, 1, 4), 
    Flag_member
;
*/
--



/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth] ;

/*
proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
CREATE VIEW dbo.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth] AS
SELECT 
    DISTINCT SUBSTRING(Year_mth, 1, 4) AS Years, 
    Year_mth, 
    Flag_member, 
    COUNT(DISTINCT sbl_member_id) AS No_id, 
    SUM(tx) AS tx, 
    SUM(QUANT) AS quant, 
    SUM(total) AS total, 
    SUM(net_total) AS net_total, 
    SUM(GP) AS gp
FROM 
    MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] AS L
WHERE 
    store_format NOT IN ('TOPS CLUB', 'Super Khum WS')
GROUP BY 
    SUBSTRING(Year_mth, 1, 4), 
    Year_mth, 
    Flag_member;

--
*/


/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a] ;

/*
proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by Years, Year_mth
order by Years, Year_mth asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by substring(Year_mth, 1,4), Year_mth ;
*/
--

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_m] ;

/*
create table AH.CFG3_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
--



/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_fm] ;


/*
proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cok_fm (compress = yes) as
select distinct store_format2, substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by store_format2, Years, Flag_member
order by store_format2, Years, Flag_member asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_fm  as
select distinct store_format2, substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format not in ('TOPS CLUB', 'Super Khum WS')
group by store_format2, substring(Year_mth, 1,4), Flag_member
;
*/
--





/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_fm_m] ;

/*
create table AH.CFG3_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct store_format2, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by store_format2, Years, Year_mth, Flag_member
order by store_format2, Years, Year_mth, Flag_member asc
;
*/

-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_fm_m as
select distinct store_format2, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from  MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by store_format2, substring(Year_mth, 1,4), Year_mth, Flag_member ;
*/
--




/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/

select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cmth]

/*
proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cmth (compress = yes) as
select distinct store_format2, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by store_format2, Years, Year_mth, Flag_member
order by store_format2, Years, Year_mth, Flag_member asc
;
*/


-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cmth  as
select distinct store_format2, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by store_format2, substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
--




/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


select * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_card] ;

/*
proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cok_card (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;

*/


-- ปรับแก้ไข โค้ดใหม่ 
/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_card as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where store_format2 not in ('TOPS CLUB', 'Super Khum WS')
and Flag_member in ('01_Member')
group by substring(Year_mth, 1,4), Flag_member;
*/ 



/*********************************************** CFG - All format ************************************************************/
/*********************************************** CFG - All format ************************************************************/
/*********************************************** CFG - All format ************************************************************/
/*********************************************** CFG - All format ************************************************************/




/*CFG - All format*/


-- โค้ดเก่า Original
/*
proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
group by Years, Year_mth
order by Years, Year_mth asc
;
quit;

proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;



proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_fm (compress = yes) as
select distinct store_format2, substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
group by store_format2, Years, Flag_member
order by store_format2, Years, Flag_member asc
;
quit;

proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct store_format2, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
group by store_format2, Years, Year_mth, Flag_member
order by store_format2, Years, Year_mth, Flag_member asc
;
quit;


proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_card (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.CFG_Sale_YTD_TYLY_cok_all (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;

*/


-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย

/*CFG - All format*/
/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_YTD as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
group by substring(Year_mth, 1,4), Flag_member;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_YTD] ;

/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_YTD_mth  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_YTD_mth] ;

/*
create view dbo.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
group by substring(Year_mth, 1,4), Year_mth
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG3_Sale_YTD_TYLY_cok_YTD_mth_a] ;

/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_YTD_mth_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_YTD_mth_m] ;


/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_fm  as
select distinct store_format2, substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
group by store_format2, substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_fm] ;


/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_fm_m as
select distinct store_format2, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
group by store_format2, substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_fm_m] ;


/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_card as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_card] ;



/*
create view dbo.[SP.CFG_Sale_YTD_TYLY_cok_all as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
group by substring(Year_mth, 1,4), Flag_member
;
*/


SELECT * from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_cok_all] ;

/*************************************************** Tops Food Hall ********************************************************/
/*************************************************** Tops Food Hall ********************************************************/
/*************************************************** Tops Food Hall ********************************************************/
/*************************************************** Tops Food Hall ********************************************************/


-- โค้ดเก่า Original
/*By Banner*/
/*Tops Food Hall*/

/*
proc sql;
create table AH.TFH_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('Central Food Hall')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.TFH_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('Central Food Hall')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TFH_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('Central Food Hall')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TFH_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct store_format, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('Central Food Hall')
group by store_format, Years, Year_mth, Flag_member
order by store_format, Years, Year_mth, Flag_member asc
;
quit;
*/




-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*By Banner*/
/*Tops Food Hall*/
/*
CREATE VIEW dbo.[SP.TFH_Sale_YTD_TYLY_cok_YTD] as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('Central Food Hall')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFH_Sale_YTD_TYLY_cok_YTD] ;



/*
CREATE VIEW dbo.[SP.TFH_Sale_YTD_TYLY_cok_YTD_mth]  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('Central Food Hall')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFH_Sale_YTD_TYLY_cok_YTD_mth] ;


/*
CREATE VIEW dbo.[SP.TFH_Sale_YTD_TYLY_cok_YTD_mth_m]  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('Central Food Hall')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFH_Sale_YTD_TYLY_cok_YTD_mth_m] ;


/*
CREATE VIEW dbo.[SP.TFH_Sale_YTD_TYLY_cok_fm_m]  as
select distinct store_format, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('Central Food Hall')
group by store_format, substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/

SELECT * from MKTCRM.Ton1.[SP.TFH_Sale_YTD_TYLY_cok_fm_m] ;

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



/*Tops Large*/

/*
proc sql;
create table AH.LFM_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.LFM_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.LFM_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.LFM_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct store_format, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by store_format, Years, Year_mth, Flag_member
order by store_format, Years, Year_mth, Flag_member asc
;
quit;
*/


-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*Tops Large*/

/*
CREATE VIEW dbo.[SP.LFM_Sale_YTD_TYLY_cok_YTD]  as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.LFM_Sale_YTD_TYLY_cok_YTD] ;


/*
CREATE VIEW dbo.[SP.LFM_Sale_YTD_TYLY_cok_YTD_mth] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.LFM_Sale_YTD_TYLY_cok_YTD_mth] ; 
 

/*
CREATE VIEW dbo.[SP.LFM_Sale_YTD_TYLY_cok_YTD_mth_m] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.LFM_Sale_YTD_TYLY_cok_YTD_mth_m] ;


/*
CREATE VIEW dbo.[SP.LFM_Sale_YTD_TYLY_cok_fm_m] as
select distinct store_format, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS MARKET', 'Super Store A-P')
group by store_format, substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.LFM_Sale_YTD_TYLY_cok_fm_m] ;


/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



/*Tops Small*/
-- โค้ดเก่า Original
/*
proc sql;
create table AH.SFM_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.SFM_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.SFM_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.SFM_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;
*/


-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*Tops Small*/
/*
CREATE VIEW dbo.[SP.SFM_Sale_YTD_TYLY_cok_YTD] as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.SFM_Sale_YTD_TYLY_cok_YTD] ;



/*
CREATE VIEW dbo.[SP.SFM_Sale_YTD_TYLY_cok_YTD_mth] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.SFM_Sale_YTD_TYLY_cok_YTD_mth] ;


/*
CREATE VIEW dbo.[SP.SFM_Sale_YTD_TYLY_cok_YTD_mth_m] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.SFM_Sale_YTD_TYLY_cok_YTD_mth_m] ;



/*
CREATE VIEW dbo.[SP.SFM_Sale_YTD_TYLY_cok_fm_m] as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY', 'CFM')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.SFM_Sale_YTD_TYLY_cok_fm_m] ;



/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


/*Tops daily*/

/*
proc sql;
create table AH.TDS_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS DAILY')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.TDS_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('TOPS DAILY')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TDS_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TDS_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;
*/

-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*Tops daily*/
/*
CREATE VIEW dbo.TDS_Sale_YTD_TYLY_cok_YTD as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS DAILY')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TDS_Sale_YTD_TYLY_cok_YTD] ;


/*
CREATE VIEW dbo.TDS_Sale_YTD_TYLY_cok_YTD_mth as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('TOPS DAILY')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TDS_Sale_YTD_TYLY_cok_YTD_mth] ;


/*
CREATE VIEW dbo.TDS_Sale_YTD_TYLY_cok_YTD_mth_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TDS_Sale_YTD_TYLY_cok_YTD_mth_m] ;


/*
CREATE VIEW dbo.TDS_Sale_YTD_TYLY_cok_fm_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS DAILY')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TDS_Sale_YTD_TYLY_cok_fm_m] ;


/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/



/*CFM*/

/*
proc sql;
create table AH.CFM_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('CFM')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.CFM_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where STORE_FORMAT in ('CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.CFM_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.CFM_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a2 as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('CFM')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

*/


-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*CFM*/
/*
CREATE VIEW dbo.CFM_Sale_YTD_TYLY_cok_YTD as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('CFM')
group by substring(Year_mth, 1,4) , Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFM_Sale_YTD_TYLY_cok_YTD] ;



/*
CREATE VIEW dbo.CFM_Sale_YTD_TYLY_cok_YTD_mth as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where STORE_FORMAT in ('CFM')
group by substring(Year_mth, 1,4) , Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFM_Sale_YTD_TYLY_cok_YTD_mth]


/*
CREATE VIEW dbo.CFM_Sale_YTD_TYLY_cok_YTD_mth_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('CFM')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFM_Sale_YTD_TYLY_cok_YTD_mth_m] ;


/*
CREATE VIEW dbo.CFM_Sale_YTD_TYLY_cok_fm_m as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY_a2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('CFM')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.CFM_Sale_YTD_TYLY_cok_fm_m] ;


/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/




/*Tops fine food*/

/*
proc sql;
create table AH.TFF_Sale_YTD_TYLY_cok_YTD (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a as L
where STORE_FORMAT in ('TOPS Fine Food')
group by Years, Flag_member
order by Years, Flag_member asc
;
quit;


proc sql;
create table AH.TFF_Sale_YTD_TYLY_cok_YTD_mth (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a as L
where STORE_FORMAT in ('TOPS Fine Food')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TFF_Sale_YTD_TYLY_cok_YTD_mth_m (compress = yes) as
select distinct substr(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS Fine Food')
group by Years, Year_mth, Flag_member
order by Years, Year_mth, Flag_member asc
;
quit;

proc sql;
create table AH.TFF_Sale_YTD_TYLY_cok_fm_m (compress = yes) as
select distinct store_format, substr(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from AH.CFG_Sale_YTD_TYLY_a as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS Fine Food')
group by store_format, Years, Year_mth, Flag_member
order by store_format, Years, Year_mth, Flag_member asc
;
quit;

*/


-- โค้ดใหม่ Create Table View ไว้แล้ว ไม่ได้เปลี่ยนตัวแปรด้านใน รันได้เลย
/*Tops fine food*/
/*
CREATE VIEW dbo.[SP.TFF_Sale_YTD_TYLY_cok_YTD  as
select distinct substring(Year_mth, 1,4) as Years, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] as L
where STORE_FORMAT in ('TOPS Fine Food')
group by substring(Year_mth, 1,4), Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFF_Sale_YTD_TYLY_cok_YTD] ;


/*
CREATE VIEW dbo.[SP.TFF_Sale_YTD_TYLY_cok_YTD_mth  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] as L
where STORE_FORMAT in ('TOPS Fine Food')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFF_Sale_YTD_TYLY_cok_YTD_mth] ;



/*
CREATE VIEW dbo.[SP.TFF_Sale_YTD_TYLY_cok_YTD_mth_m  as
select distinct substring(Year_mth, 1,4) as Years, Year_mth, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS Fine Food')
group by substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/
SELECT * from MKTCRM.Ton1.[SP.TFF_Sale_YTD_TYLY_cok_YTD_mth_m] ;



/*
CREATE VIEW dbo.[SP.TFF_Sale_YTD_TYLY_cok_fm_m as
select distinct store_format, substring(Year_mth, 1,4) as Years, Year_mth, Flag_member, count(distinct sbl_member_id) as No_id, sum(tx) as tx, sum(QUANT) as quant, 
                 		sum(total)as total, 
						sum(net_total) as net_total,
                 		sum(GP) as gp
from MKTCRM.Ton1.[SP.CFG_Sale_YTD_TYLY2] as L
where Flag_member in ('01_Member')
and STORE_FORMAT in ('TOPS Fine Food')
group by store_format, substring(Year_mth, 1,4), Year_mth, Flag_member
;
*/

select * from MKTCRM.Ton1.[SP.TFF_Sale_YTD_TYLY_cok_fm_m] ;

/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/


