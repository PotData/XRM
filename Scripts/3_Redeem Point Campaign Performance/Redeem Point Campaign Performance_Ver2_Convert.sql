/*Redeem Point Campaign Performance - Bi-Weekly*/

------------------------------------------------------
-- ##### Redeem Point Campaign 
Note #1 : ทุก Table หลัก จะสร้างเป็น Store Procedure ไว้ หรือมีการสร้าง Table ขึ้นมาจริงๆ จำเป็นต้องมีการ TRUNCATE TABLE กรณีที่ต้องการล้างข้อมูลเก่าออกก่อน
Note #2 : ไม่มีการสร้าง Table View สำหรับโปรแกรม Redeem Point Campaign .

-------------------------------------------------------

options dlcreatedir;
libname RP6 'G:\Ton\Redeem_Point_W2436';


TRUNCATE TABLE MKTCRM.Ton1.[RP.barcode_product]

/*import file product_full*/


-- สร้าง table BARCODE_PRODUCT ตาม workweek ที่ใช้
EXEC Ton1.RP_barcode_product 'WK2436';

/*
PROC SQL THREADS;
create table rp6.BARCODE_PRODUCT (compress= yes) as
		select distinct *
		from rp6.BARCODE_PRODUCT_Full
		where ID in ('WK2436') /*แก้ไข WK ล่าสุด ตาม ID ที่ใส่ไว้ใน File Excel*/
/*		where ID like ("WK22%") and ID <> "WK22"*/
;
*/



-- สร้าง table Bar ตาม workweek ที่ใช้
EXEC Ton1.RP_Bar 'WK2436';

SELECT * FROM MKTCRM.Ton1.[RP.Bar];

/*
PROC SQL THREADS;
create table rp6.Bar(compress= yes) as
		select distinct 'Product Barcode'n, Product_code, Product_eng_Desc, BRAND_ENG_NAME as brand, SUBDEPT_ENG_DESC, barcode as coupon_no
		from 	rp6.BARCODE_PRODUCT 
		left join topsrst.d_Merchandise 
				on 'Product Barcode'n = product_code
		where ID in ('WK2436') /*แก้ไข WK ล่าสุด ตาม ID ที่ใส่ไว้ใน File Excel*/
/*		where ID like ("WK22%") and ID <> "WK22"*/
;
*/

/* ปรับโค้ดแก้ไขใหม่
select distinct Product_Barcode, 
                Product_code, 
                Product_eng_Desc, 
                BRAND_ENG_NAME as brand, 
                SUBDEPT_ENG_DESC, 
                barcode as coupon_no
from MKTCRM.Ton1.[RP.barcode_product]
left join topsrst.dbo.d_Merchandise 
on Product_Barcode = product_code
where ID in ('WK2436');
*/




-- โค้ดเก่า Original
--%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
/*proc sql threads;
create table rp6.Sale_2436_&yyyymm (compress = yes) as
select distinct &yyyymm as month, sbl_member_id, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty
from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A , Topsrst.d_store as B
where B.STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET', 'Super Store A-P')
and trn_dte between '20240515' and '20240903'
and pr_code in (select distinct 'Product Barcode'n from rp6.BARCODE_PRODUCT ) 
and SBL_MEMBER_ID is not null and T1C_CARD_NO not like '709999999%' and T1C_CARD_NO 
not like '7011111111%' and  SBL_MEMBER_ID not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','','9999999999');;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
select distinct '202405' as month, sbl_member_id, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty
from Topst1c.dbo.SALES_PROMOTION_COMP_202405 as A , Topsrst.dbo.d_store as B
where B.STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET', 'Super Store A-P')
and trn_dte between '20240515' and '20240903'
and pr_code in (select distinct Product_Barcode from  MKTCRM.Ton1.[RP.barcode_product]) 
and SBL_MEMBER_ID is not null and T1C_CARD_NO not like '709999999%' and T1C_CARD_NO 
not like '7011111111%' and  SBL_MEMBER_ID not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','','9999999999');
*/


/*
OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202405)
%EXECUTE_SALE_TRANS_ALL(202406)
%EXECUTE_SALE_TRANS_ALL(202407)
%EXECUTE_SALE_TRANS_ALL(202408)
%EXECUTE_SALE_TRANS_ALL(202409)
;


data rp6.Sale_2436(compress= yes);
	set 
		rp6.Sale_2436_202405
		rp6.Sale_2436_202406
		rp6.Sale_2436_202407
		rp6.Sale_2436_202408
		rp6.Sale_2436_202409
;
run;
*/

TRUNCATE TABLE MKTCRM.Ton1.[RP.SALE_2436] ;

-- รันข้อมูลเข้า Table : RP.SALE_2436
-- รับค่า ชื่อ Workweek, yyyymm จาก Topst1c.dbo.SALES_PROMOTION_COMP_yyyymm และ startdate '20240515' กับ Enddate '20240903'
EXEC Ton1.RP_Sale '2436', '202405', '20240515', '20240903' ;
EXEC Ton1.RP_Sale '2436', '202406', '20240515', '20240903' ;
EXEC Ton1.RP_Sale '2436', '202407', '20240515', '20240903' ;
EXEC Ton1.RP_Sale '2436', '202408', '20240515', '20240903' ;
EXEC Ton1.RP_Sale '2436', '202409', '20240515', '20240903' ;


-- Note : เปรียบเทียบข้อมูล 2 ตาราง ว่าข้อมูลไหนที่ไม่มี ในทีนี้ ต่างกัน 780 row ที่ 202408 , trn_date = 20240801 เท่านั้น 

/*
SELECT [month], sbl_member_id, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty
FROM MKTCRM.Ton1.[RP.SALE_2436]
EXCEPT
SELECT [month], SBL_MEMBER_ID, REFERENCE, STORE_ID, PR_CODE, TOTAL, GP, NET_TOTAL, TRN_DTE, QTY
FROM MKTCRM.Ton1.test_RP_sale_2436;
*/





/*%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);*/
/*proc sql threads;*/
/*	insert into rp6.Sale_2414*/
/*		select &yyyymm as month,sbl_member_id, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty*/
/*		from Topst1c.SALES_PROMOTION_COMP_&yyyymm*/
/*		where trn_dte between '20230901' and '20230912'*/
/*					and pr_code in (select distinct 'Product Barcode'n from rp6.BARCODE_PRODUCT ) */
/*					and SBL_MEMBER_ID is not null and T1C_CARD_NO not like '709999999%' and T1C_CARD_NO */
/*							not like '7011111111%' and  SBL_MEMBER_ID not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','','9999999999');*/
/*quit;*/
/*%MEND;*/
/**/
/*OPTIONS mprint;*/
/*%EXECUTE_SALE_TRANS_ALL(202309)*/
/*;*/






/*mapping member*/
/*PROC SQL THREADS;*/
/*create table rp6.Sale_2414 (compress= yes) as*/
/*		select SBL_MEMBER_ID, a.**/
/*		from rp6.Sale_2414 a*/
/*		left join TOPSSBL.SBL_MEMBER_CARD_LIST b */
/*		on a.T1C_CARD_NO = b.T1C_CARD_NO;*/
/*QUIT;*/


/*PROC SQL THREADS;*/
/*alter table rp6.Sale_2414 DROP COLUMN FLAG_MEMBER;*/
/*create table rp6.Sale_2414 (compress= yes) as*/
/*		select *,*/
/*				case when SBL_MEMBER_ID is not null and SBL_MEMBER_ID not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','','9999999999') */
/*				then 'Member' */
/*				else 'Non Member' 	end as Flag_Member*/
/*		from rp6.Sale_2414*/
/*		having Flag_Member = 'Member';*/
/*quit;*/


-- ล้าง table
TRUNCATE TABLE MKTCRM.Ton1.[RP._00_]

/*create ID and Period column*/
-- รันข้อมูลเข้า Table : _00_ จาก SALE_WK
EXEC Ton1.RP_00_ '2436';

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._00_(compress= yes) as
	select distinct SBL_MEMBER_ID, month,reference, store_id, pr_code, total, gp, net_total, trn_dte, qty,
				max(case when trn_dte between 'Period Start'n and 'Period end'n then ID 
									when trn_dte between 'Previous Start'n and 'Previous end'n then ID 
									end) as id,
				max(case when trn_dte between 'Period Start'n and 'Period end'n then 'Period'
									when trn_dte between 'Previous Start'n and 'Previous end'n then 'Previous' 
									end ) as period
	from rp6.Sale_2436 a 
	left join rp6.BARCODE_PRODUCT
	on pr_code = 'Product Barcode'n
/*	left join topsrst.d_Merchandise */
/*	on pr_code = product_code*/
	group by SBL_MEMBER_ID, month, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty
	;
*/

-- ปรับแก้ไข โค้ดใหม่
/*
create table MKTCRM.Ton1._00_ as
select distinct SBL_MEMBER_ID, month,reference, store_id, pr_code, total, gp, net_total, trn_dte, qty,
				max(case when trn_dte between Period_Start and Period_end then ID 
					     when trn_dte between Previous_Start and Previous_end then ID 
				    end) as id,
				max(case when trn_dte between Period_Start and Period_end then 'Period'
									when trn_dte between Previous_Start and Previous_end then 'Previous' 
									end ) as period
from MKTCRM.Ton1.[RP.Sale_2436] a 
left join MKTCRM.Ton1.[RP.BARCODE_PRODUCT]
on pr_code = Product_Barcode
group by SBL_MEMBER_ID, month, reference, store_id, pr_code, total, gp, net_total, trn_dte, qty;
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._000_]

/*map sale with product code and product detail*/
-- รันข้อมูลเข้า Table : _000_ จาก _00_
EXEC Ton1.RP_000_ ;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table  rp6._000_(compress= yes) as
		select distinct id, period, store_format, store_name, a.*
		from rp6._00_ a 
		left join topsrst.d_store b
		on store_id = store_code
		where id is not null
;
*/

-- ปรับแก้ไข โค้ดใหม่
/*
create table  MKTCRM.Ton1._000_ as
		select distinct  id, period, store_format, store_name,  SBL_MEMBER_ID, [month], reference, store_id, pr_code, total, gp, net_total, trn_dte, qty
		from MKTCRM.Ton1.[PR._00_] a 
		left join topsrst.dbo.d_store b
		on store_id = store_code
		where id is not null
*/

TRUNCATE TABLE MKTCRM.Ton1.[RP._01_] ;

EXEC Ton1.RP_01_ ;

-- โค้ดเก่า Original
/*PROC SQL THREADS;
create table  rp6._01_(compress= yes) as
		select distinct id, period, BRAND_ENG_NAME, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, a.*
		from rp6._000_ a 
		left join topsrst.d_merchandise b
		on pr_code = product_code
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
select distinct id, period, BRAND_ENG_NAME, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, a.store_format,
			a.store_name,
			a.SBL_MEMBER_ID,
			a.month,
			a.reference,
			a.store_id,
			a.pr_code,
			a.total,
			a.gp,
			a.net_total,
			a.trn_dte,
			a.qty
from MKTCRM.Ton1.[RP._000_] as a
left join topsrst.dbo.d_merchandise b
on pr_code = product_code
;
*/



-- Check compare with Test table _01_ กับ test_01_
/*
SELECT  TRN_DTE, sum(QTY) QTY , STORE_ID, sum(NET_TOTAL) as NET_TOTAL
FROM MKTCRM.Ton1.[RP._01_]
group by  TRN_DTE, STORE_ID
order by TRN_DTE, sum(NET_TOTAL), STORE_ID
*/

TRUNCATE TABLE MKTCRM.Ton1.[RP._02_]  ;

EXEC Ton1.RP_02_ ;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._02_(compress= yes) as
		select distinct a.id, period, store_format, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, barcode as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id, period, store_format, brand, barcode
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
SELECT DISTINCT 
    a.id, 
    period, 
    store_format, 
    BRAND_ENG_NAME AS brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    barcode AS coupon_no,
    COUNT(DISTINCT sbl_member_id) AS sbl_Member_id,
    COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
    SUM(total) AS total,
    SUM(gp) AS gp, 
    SUM(net_total) AS net_total,
    SUM(qty) AS qty
FROM 
    MKTCRM.Ton1.[RP._000_] a 
LEFT JOIN 
    topsrst.dbo.d_merchandise ON a.pr_code = product_code
LEFT JOIN 
    MKTCRM.Ton1.[RP.BARCODE_PRODUCT] ON a.Pr_code = 'Product Barcode'
WHERE 
    STORE_FORMAT IN ('Central Food Hall', 'TOPS MARKET')
GROUP BY 
    a.id, period, store_format, BRAND_ENG_NAME, DEPT_ENG_DESC,SUBDEPT_ENG_DESC, barcode;
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._02_t] ;

EXEC Ton1.RP_02_t ;


--SELECT * from MKTCRM.Ton1.[RP._02_t]
-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._02_t(compress= yes) as
		select distinct a.id, period, '__total' as store_format, '_total' as brand, 'total' as SUBDEPT_ENG_DESC, 'Total' as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id, period, store_format, brand, coupon_no
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
SELECT DISTINCT 
    a.id, 
    period, 
    '__total' AS store_format, 
    '_total' AS brand, 
    'total' AS SUBDEPT_ENG_DESC, 
    'Total' AS coupon_no,
    COUNT(DISTINCT sbl_member_id) AS sbl_Member_id,
    COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
    SUM(total) AS total,
    SUM(gp) AS gp, 
    SUM(net_total) AS net_total,
    SUM(qty) AS qty
FROM 
    MKTCRM.Ton1.[RP._000_]a 
LEFT JOIN 
    topsrst.dbo.d_merchandise ON a.pr_code = product_code
LEFT JOIN 
    MKTCRM.Ton1.[RP.BARCODE_PRODUCT] ON a.Pr_code = 'Product Barcode'
WHERE 
    STORE_FORMAT IN ('Central Food Hall', 'TOPS MARKET')
GROUP BY 
    a.id, period;
*/

-- Check compare with Test table _02_t กับ test_02_t
/*
SELECT id, period, sum(qty) as qty, sum(gp) as gp , sum(total) as total
FROM MKTCRM.Ton1.[RP._02_t]
GROUP BY id, period
*/




/*by store format by product*/

TRUNCATE TABLE MKTCRM.Ton1.[RP._02_P] ;

EXEC Ton1.RP_02_P;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table  rp6._02_P(compress= yes) as
		select distinct a.id, period, store_format, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, 
Product_code, Product_eng_Desc, barcode as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id, period, store_format, BRAND_ENG_NAME, brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, Product_code, Product_eng_Desc
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
SELECT DISTINCT 
    a.id, 
    period, 
    store_format, 
    BRAND_ENG_NAME AS brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc, 
    barcode AS coupon_no,
    COUNT(DISTINCT sbl_member_id) AS sbl_Member_id,
    COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
    SUM(total) AS total,
    SUM(gp) AS gp, 
    SUM(net_total) AS net_total,
    SUM(qty) AS qty
FROM 
     MKTCRM.Ton1.[RP._000_] a 
LEFT JOIN 
    topsrst.dbo.d_merchandise ON a.pr_code = product_code
LEFT JOIN 
    MKTCRM.Ton1.[RP.BARCODE_PRODUCT] ON a.Pr_code = 'Product Barcode'
WHERE 
    STORE_FORMAT IN ('Central Food Hall', 'TOPS MARKET')
GROUP BY 
    a.id, 
    period, 
    store_format, 
    barcode,
    BRAND_ENG_NAME, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc;
*/


-- Check compare with Test table _02_P กับ test_02_P
/*
SELECT id, period, sum(gp) as gp, sum(total) as total
FROM MKTCRM.Ton1.test_02_p
Group by id, period
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._02_P_t] ;

EXEC Ton1.RP_02_P_t;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table  rp6._02_P_t(compress= yes) as
		select distinct a.id, period,store_format, '__total' as brand, '_total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, 'Total' as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id,period, store_format
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่
/*
select distinct a.id, period,store_format, '__total' as brand, '_total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, 'Total' as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from MKTCRM.Ton1.[RP._000_] a 
		left join topsrst.dbo.d_merchandise 
		on pr_code = product_code
		left join MKTCRM.Ton1.[RP.BARCODE_PRODUCT]
		on a.Pr_code = 'Product Barcode'
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id,period, store_format;
*/


/******************************************************** Redeem **********************************************************/
/******************************************************** Redeem **********************************************************/
/******************************************************** Redeem **********************************************************/



/*redeem*/


TRUNCATE TABLE MKTCRM.Ton1.[RP.REDEEM_0] ;

EXEC Ton1.RP_REDEEM_0 ;


-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6.REDEEM_0(compress= yes) as
	select distinct *
	from Topsrst.CPN9_DAILY
	where COUPON_NO in (select 'Barcode'n from rp6.BARCODE_PRODUCT)
	;
QUIT;

data rp6.REDEEM_0 (drop=SEQ_NO)/*(drop=rec)*/;
set rp6.REDEEM_0  ;
run;

PROC SQL THREADS;
create table rp6.REDEEM_0(compress= yes) as
	select distinct *
	from rp6.REDEEM_0
	;
QUIT;
*/


/*
data rp6.REDEEM_0 (drop=rec);
	set rp6.REDEEM;
run;*/


-- ปรับแก้ไข โค้ดใหม่ table REDEEM_0
/*
select distinct STORE_CODE, RCPT_NO, PR_CODE, AMT, DISCOUNT, CARD_NO, COUPON_NO, TRANS_DATE, TOT_AMT
	from Topsrst.dbo.CPN9_DAILY
	where COUPON_NO in (select Barcode from MKTCRM.Ton1.[RP.BARCODE_PRODUCT])
	;
*/

TRUNCATE TABLE MKTCRM.Ton1.[RP.REDEEM_] ;

EXEC Ton1.RP_REDEEM_ ;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6.REDEEM_(compress= yes) as
		select  a.*,b.id,point,redeem_price, /*FDS_SALES*/ round(discount/Redeem_price) as qnt_f
		from rp6.REDEEM_0 a 
		left join rp6.BARCODE_PRODUCT b
		on  pr_code/*pcd */= 'Product Barcode'n 
				and COUPON_NO = b.'Barcode'n
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table REDEEM_
/*
select a.STORE_CODE, a.RCPT_NO, a.PR_CODE, a.AMT, a.DISCOUNT, a.CARD_NO, a.COUPON_NO, a.TRANS_DATE, a.TOT_AMT,b.id,point,redeem_price,
ROUND(discount / redeem_price, 0) AS qnt_f 
from MKTCRM.Ton1.[RP.REDEEM_0] as a 
left join MKTCRM.Ton1.[RP.BARCODE_PRODUCT] as b
on  a.pr_code = b.Product_Barcode and a.COUPON_NO = b.Barcode;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._03_]  ;

EXEC Ton1.RP_03_;


-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._03_(compress= yes) as
		select distinct b.*,a.*,qnt_f,qnt_f*point as point_
		from  rp6.REDEEM_ b 
		left join rp6._000_ a
		on reference = RCPT_NO/*ref */
			and store_id = STORE_CODE /*brn*/ 
			and a.pr_code = b.pr_code/*pcd */
			and a.id = b.id
			and trn_dte =  TRANS_DATE
/*			input(ttm,8.)*/
/*	input(put(year(TTM),4.)!!put(month(TTM),z2.)!!put(day(TTM),z2.),8.)*/
/*	input(put(datepart(ttm),yymmddn8.),8.)*/

	and a.period = 'Period'
	;
QUIT;
*/



-- ปรับแก้ไข โค้ดใหม่ table _03_
/*
select distinct b.STORE_CODE, 
       b.RCPT_NO, 
       b.PR_CODE, 
       b.AMT, 
       b.DISCOUNT, 
       b.CARD_NO, 
       b.COUPON_NO, 
       b.TRANS_DATE, 
       b.TOT_AMT,
       b.id, 
       b.point, 
       b.redeem_price,
       b.qnt_f, a.period, a.store_format, a.store_name, a.SBL_MEMBER_ID, a.month, a.reference, a.store_id, a.total, a.gp, a.net_total, a.trn_dte, a.qty,
       qnt_f*point as point_
from  MKTCRM.Ton1.[RP.REDEEM_] b 
left join MKTCRM.Ton1.[RP._000_] a
on a.reference = RCPT_NO
and a.store_id = STORE_CODE 
and a.pr_code = b.pr_code
and a.id = b.id
and a.trn_dte =  TRANS_DATE
and a.period = Period
;
*/


-- Comment ไว้อยู่แล้ว ไม่ใช้
/*PROC SQL THREADS;*/
/*CREATE TABLE rp6._03_Pre(compress= yes) as*/
/*SELECT distinct b.*,a.**/
/**/
/*FROM  rp6.REDEEM_ b left join rp6._00_ a*/
/*on a.pr_code = b.pr_code*/
/**/
/**/
/**/
/*where a.period = 'Previous'*/
/*and trn_dte <= '20230912'*/
/*;*/
/*QUIT;*/





/******************************************************** For tracking SKUs **********************************************************/
/******************************************************** For tracking SKUs **********************************************************/
/******************************************************** For tracking SKUs **********************************************************/


/*For tracking SKUs*/
TRUNCATE TABLE MKTCRM.Ton1.[RP._04_P]  ;

EXEC Ton1.RP_04_P;

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._04_P (compress= yes) as
		select distinct id, 'Redeem' as Period, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, store_format, Coupon_no, 
Product_code, Product_eng_Desc,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,
					0 as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount/*FDS_SALES*/) as FDS_SALES, 
					0/*sum(FDS_T1C)*/ as FDS_T1C,
					sum(point_) as point
		from rp6._03_ 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, store_format, Coupon_no, Product_code, Product_eng_Desc
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table _04_P
/*
select distinct id, 'Redeem' as Period, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, store_format, Coupon_no, 
Product_code, Product_eng_Desc,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,
					0 as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount) as FDS_SALES, 
					0 as FDS_T1C,
					sum(point_) as point
		from MKTCRM.Ton1.[RP._03_]
		left join topsrst.dbo.d_merchandise 
		on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, BRAND_ENG_NAME, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, store_format, Coupon_no, Product_code, Product_eng_Desc
;
*/


TRUNCATE Table MKTCRM.Ton1.[RP._04_P_t] ;

EXEC Ton1.RP_04_P_t;


-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._04_P_t (compress= yes) as
		select distinct id, 'Redeem' as Period, '_total' as brand ,'total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, store_format, 'total' as Coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,0 /*sum(fds)*/ as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount/*FDS_SALES*/) as FDS_SALES, 
					0/*sum(FDS_T1C)*/ as FDS_T1C,
					sum(point_) as point
		from rp6._03_ left join topsrst.d_merchandise on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table [RP._04_P_t]
/*
select distinct id, 'Redeem' as Period, '_total' as brand ,'total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, store_format, 'total' as Coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt, 0  as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount) as FDS_SALES, 
					0 as FDS_T1C,
					sum(point_) as point
		from MKTCRM.Ton1.[RP._03_]  left join topsrst.dbo.d_merchandise on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format;
*/

TRUNCATE Table MKTCRM.Ton1.[RP._05_P] ;

EXEC Ton1.RP_05_P ;
/*
data rp6._05_P(compress= yes);
	set rp6._02_P
	    rp6._02_P_t
		rp6._04_P
		rp6._04_P_t
;
run;
*/


-- ประกอบร่าง สร้าง _05_P
/*
SELECT 
    id, 
    period, 
    store_format, 
    brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc, 
    coupon_no, 
    sbl_Member_id, 
    [ref], 
    total, 
    gp, 
    net_total, 
    qty, 
    NULL AS amt,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS fds,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS TOT_AMT,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS FDS_SALES,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS FDS_T1C,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS point  -- ไม่มีใน 02_P และ 02_P_t
FROM MKTCRM.Ton1.[RP._02_P]
UNION ALL
SELECT 
    id, 
    period, 
    store_format, 
    brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc, 
    coupon_no, 
    sbl_Member_id, 
    [ref], 
    total, 
    gp, 
    net_total, 
    qty, 
    NULL AS amt,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS fds,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS TOT_AMT,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS FDS_SALES,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS FDS_T1C,  -- ไม่มีใน 02_P และ 02_P_t
    NULL AS point  -- ไม่มีใน 02_P และ 02_P_t
FROM MKTCRM.Ton1.[RP._02_P_t]
UNION ALL
SELECT 
    id, 
    period, 
    store_format, 
    brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc, 
    coupon_no, 
    sbl_Member_id, 
    [ref], 
    total, 
    gp, 
    net_total, 
    qty, 
    amt, 
    fds, 
    TOT_AMT, 
    FDS_SALES, 
    FDS_T1C, 
    point
FROM MKTCRM.Ton1.[RP._04_P]
UNION ALL
SELECT 
    id, 
    period, 
    store_format, 
    brand, 
    DEPT_ENG_DESC, 
    SUBDEPT_ENG_DESC, 
    Product_code, 
    Product_eng_Desc, 
    coupon_no, 
    sbl_Member_id, 
    [ref], 
    total, 
    gp, 
    net_total, 
    qty, 
    amt, 
    fds, 
    TOT_AMT, 
    FDS_SALES, 
    FDS_T1C, 
    point
FROM MKTCRM.Ton1.[RP._04_P_t] ;
*/


/*
PROC EXPORT DATA= rp6._05_P
            OUTFILE= "E:\Pu\Export_SAS\Redeem1Baht\D_05_product.txt" 
            DBMS=DLM REPLACE;
     DELIMITER='7C'x; 
     PUTNAMES=YES;
RUN;
*/



/******************************************************** For tracking store **********************************************************/
/******************************************************** For tracking store **********************************************************/
/******************************************************** For tracking store **********************************************************/


TRUNCATE TABLE MKTCRM.Ton1.[RP._02_S] ;

EXEC Ton1.RP_02_S;



/*For tracking store*/

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table  rp6._02_S(compress= yes) as
		select distinct a.id, period, store_format, store_id, store_name, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, 
Product_code, Product_eng_Desc, barcode as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id, period, store_format, store_id, store_name, brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, Product_code, Product_eng_Desc
	;
QUIT;
*/



-- ปรับแก้ไข โค้ดใหม่ table RP._02_S
/*
select distinct a.id, period, store_format, store_id, store_name, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, 
Product_code, Product_eng_Desc, barcode as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from MKTCRM.Ton1.[RP._000_] a 
		left join topsrst.dbo.d_merchandise 
		on pr_code = product_code
		left join MKTCRM.Ton1.[RP.BARCODE_PRODUCT]
		on a.Pr_code = Product_Barcode
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id, period, store_format, store_id, store_name, BRAND_ENG_NAME, DEPT_ENG_DESC, SUBDEPT_ENG_DESC, Product_code, Product_eng_Desc, barcode
	;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._02_S_t] ;

EXEC Ton1.RP_02_S_t;


-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table  rp6._02_S_t(compress= yes) as
		select distinct a.id, period,store_format, store_id, store_name, '__total' as brand, '_total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, 'Total' as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from rp6._000_ a 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		left join rp6.BARCODE_PRODUCT 
		on a.Pr_code = 'Product Barcode'n
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id,period, store_format, store_id, store_name
	;
QUIT;
*/




-- ปรับแก้ไข โค้ดใหม่ table _02_S_t
/*
select distinct a.id, period,store_format, store_id, store_name, '__total' as brand, '_total' as DEPT_ENG_DESC, 'total' as SUBDEPT_ENG_DESC, 
'total' as Product_code, 'total' as Product_eng_Desc, 'Total' as coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(qty) as qty
		from MKTCRM.Ton1.[RP._000_] a 
		left join topsrst.dbo.d_merchandise 
		on pr_code = product_code
		left join MKTCRM.Ton1.[RP.BARCODE_PRODUCT]
		on a.Pr_code = Product_Barcode
		where STORE_FORMAT in ('Central Food Hall', 'TOPS MARKET')
		group by a.id,period, store_format, store_id, store_name
	;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._04_S] ;

EXEC Ton1.RP_04_S;



-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._04_S(compress= yes) as
		select distinct id, 'Redeem' as Period, store_format, store_id, store_name, Coupon_no, 
Product_code, Product_eng_Desc, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,
					0 as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount/*FDS_SALES*/) as total_dis, 
					sum(point_) as point
		from rp6._03_ 
		left join topsrst.d_merchandise 
		on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format, store_id, store_name, Coupon_no, Product_code, Product_eng_Desc, brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table _04_S
/*
select distinct id, 'Redeem' as Period, store_format, store_id, store_name, Coupon_no, 
Product_code, Product_eng_Desc, BRAND_ENG_NAME as brand, DEPT_ENG_DESC, SUBDEPT_ENG_DESC,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,
					0 as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount) as total_dis, 
					sum(point_) as point
		from MKTCRM.Ton1.[RP._03_]
		left join topsrst.dbo.d_merchandise 
		on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format, store_id, store_name, Coupon_no, Product_code, Product_eng_Desc, BRAND_ENG_NAME, DEPT_ENG_DESC, SUBDEPT_ENG_DESC
	;

*/



-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._04_S_t (compress= yes) as
		select distinct id, 'Redeem' as Period, store_format, store_id, store_name, '__total' as brand, '_total' as DEPT_ENG_DESC, 
'total' as SUBDEPT_ENG_DESC, 'total' as Product_code, 'total' as Product_eng_Desc, 'total' as Coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					Count(distinct reference!!store_id!!trn_dte) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,0 /*sum(fds)*/ as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount/*FDS_SALES*/) as total_dis, 
					sum(point_) as point
		from rp6._03_ left join topsrst.d_merchandise on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format, store_id
	;
QUIT;
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._04_S_t] ;

EXEC Ton1.RP_04_S_t;



-- ปรับแก้ไข โค้ดใหม่ table RP._04_S_t
/*
select distinct id, 'Redeem' as Period, store_format, store_id, store_name, '__total' as brand, '_total' as DEPT_ENG_DESC, 
'total' as SUBDEPT_ENG_DESC, 'total' as Product_code, 'total' as Product_eng_Desc, 'total' as Coupon_no,
					count(distinct sbl_member_id) as sbl_Member_id,
					COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
					sum(total) as total,
					sum(gp) as gp, 
					sum(net_total) as net_total,
					sum(amt) as amt,0 as fds, 
					sum(qnt_f) as qty,
					sum(TOT_AMT) as TOT_AMT, 
					sum(discount) as total_dis, 
					sum(point_) as point
		from MKTCRM.Ton1.[RP._03_] left join topsrst.dbo.d_merchandise on pr_code = product_code
		where store_code is not null
		and store_format is not null
		group by id, store_format, store_id, store_name;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._05_S] ;

EXEC Ton1.RP_05_S;

/*
data rp6._05_S(compress= yes);
	set rp6._02_S
	    rp6._02_S_t
		rp6._04_S
		rp6._04_S_t
;
run;
*/


-- ประกอบร่าง สร้าง _05_S
/*
SELECT 
    id,
    period,
    store_format,
    store_id,
    store_name,
    brand,
    DEPT_ENG_DESC,
    SUBDEPT_ENG_DESC,
    Product_code,
    Product_eng_Desc,
    coupon_no,
    sbl_Member_id,
    [ref],
    total,
    gp,
    net_total,
    qty,
    NULL AS amt,  -- เพิ่ม NULL สำหรับ amt
    NULL AS fds,  -- เพิ่ม NULL สำหรับ fds
    NULL AS TOT_AMT,  -- เพิ่ม NULL สำหรับ TOT_AMT
    NULL AS total_dis,  -- เพิ่ม NULL สำหรับ total_dis
    NULL AS point  -- เพิ่ม NULL สำหรับ point
FROM MKTCRM.Ton1.[RP._02_S]

UNION ALL

SELECT 
    id,
    period,
    store_format,
    store_id,
    store_name,
    brand,
    DEPT_ENG_DESC,
    SUBDEPT_ENG_DESC,
    Product_code,
    Product_eng_Desc,
    coupon_no,
    sbl_Member_id,
    [ref],
    total,
    gp,
    net_total,
    qty,
    NULL AS amt,
    NULL AS fds,
    NULL AS TOT_AMT,
    NULL AS total_dis,
    NULL AS point
FROM MKTCRM.Ton1.[RP._02_S_t]

UNION ALL

SELECT 
    id,
    Period,
    store_format,
    store_id,
    store_name,
    Coupon_no,
    Product_code,
    Product_eng_Desc,
    brand,
    DEPT_ENG_DESC,
    SUBDEPT_ENG_DESC,
    sbl_Member_id,
    [ref],
    total,
    gp,
    net_total,
    NULL AS qty,  -- เพิ่ม NULL สำหรับ qty
    amt,
    fds,
    TOT_AMT,
    total_dis,
    point
FROM MKTCRM.Ton1.[RP._04_S]

UNION ALL

SELECT 
    id,
    Period,
    store_format,
    store_id,
    store_name,
    Coupon_no,
    Product_code,
    Product_eng_Desc,
    brand,
    DEPT_ENG_DESC,
    SUBDEPT_ENG_DESC,
    sbl_Member_id,
    [ref],
    total,
    gp,
    net_total,
    NULL AS qty,
    amt,
    fds,
    TOT_AMT,
    total_dis,
    point
FROM MKTCRM.Ton1.[RP._04_S_t];
*/




/******************************************************** by store **********************************************************/
/******************************************************** by store **********************************************************/
/******************************************************** by store **********************************************************/


TRUNCATE TABLE MKTCRM.Ton1.[RP._06_store] ;

EXEC Ton1.RP_06_store ;

-- SELECT * from  MKTCRM.Ton1.[RP._06_store]

/*by store*/

-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._06_store(compress= yes) as
	select distinct id, 'Total' as store_id, put('Total',$80.) as STORE_NAME, put('Total',$80.) as STORE_Format, trn_dte,
				count(distinct sbl_member_id) as sbl_Member_id,
				Count(distinct reference!!store_id!!trn_dte) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 /*sum(fds)*/ as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount/*FDS_SALES*/) as FDS_SALES, 
				0/*sum(FDS_T1C)*/ as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from rp6._03_ 
	where store_code is not null
	group by  id, trn_dte
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table _06_store
/*
SELECT DISTINCT 
    id, 
    'Total' AS store_id, 
    'Total' AS STORE_NAME, 
    'Total' AS STORE_Format, 
    trn_dte,
    COUNT(DISTINCT sbl_member_id) AS sbl_Member_id,
    COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
    SUM(total) AS total,
    SUM(gp) AS gp, 
    SUM(net_total) AS net_total,
    SUM(amt) AS amt,
    0 AS fds, 
    SUM(qnt_f) AS qty,
    SUM(TOT_AMT) AS TOT_AMT, 
    SUM(discount) AS FDS_SALES, 
    0 AS FDS_T1C,
    SUM(point * qnt_f) AS point_redeem
FROM 
    MKTCRM.Ton1.[RP._03_]
WHERE 
    store_code IS NOT NULL
GROUP BY  
    id, 
    trn_dte;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._06_store_t] ;

EXEC Ton1.RP_06_store_t;

-- SELECT * from MKTCRM.Ton1.[RP._06_store_t]
-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._06_store_t(compress= yes) as
	select distinct id, 'Total' as store_id, put('Total',$80.) as STORE_NAME, put('Total',$80.) as STORE_Format, '0' as trn_dte,
				count(distinct sbl_member_id) as sbl_Member_id,
				Count(distinct reference!!store_id!!trn_dte) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 /*sum(fds)*/ as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount/*FDS_SALES*/) as FDS_SALES, 
				0/*sum(FDS_T1C)*/ as FDS_T1C,
				sum(point*qnt_f) as point_redeem

	from rp6._03_ a left join topsrst.d_store b on a.store_code = b.store_code
	where a.store_code is not null
	group by id
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table _06_store_t
/*
select distinct id, 'Total' as store_id, 'Total' AS STORE_NAME, 'Total' AS STORE_Format, '0' as trn_dte,
				count(distinct sbl_member_id) as sbl_Member_id,
				COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0  as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount) as FDS_SALES, 
				0 as FDS_T1C,
				sum(point*qnt_f) as point_redeem
from MKTCRM.Ton1.[RP._03_] a left join topsrst.dbo.d_store b on a.store_code = b.store_code
where a.store_code is not null
group by id
;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._06_store_t2] ;

EXEC Ton1.RP_06_store_t2;
-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._06_store_t2(compress= yes) as 
	select distinct id, store_id, a.STORE_NAME, a.STORE_Format, '0' as trn_dte,
				count(distinct sbl_member_id) as sbl_Member_id,
				Count(distinct reference!!store_id!!trn_dte) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 /*sum(fds)*/ as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount/*FDS_SALES*/) as FDS_SALES, 
				0/*sum(FDS_T1C)*/ as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from rp6._03_ a 
	left join topsrst.d_store b 
	on a.store_code = b.store_code
	where a.store_code is not null
	group by id, store_id, a.STORE_NAME, a.STORE_Format
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table _06_store_t2
/*
select distinct id, store_id, a.STORE_NAME, a.STORE_Format, '0' as trn_dte,
				count(distinct sbl_member_id) as sbl_Member_id,
				COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount) as FDS_SALES, 
				0 as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from MKTCRM.Ton1.[RP._03_] a 
	left join topsrst.dbo.d_store b 
	on a.store_code = b.store_code
	where a.store_code is not null
	group by id, store_id, a.STORE_NAME, a.STORE_Format
	;
*/




TRUNCATE TABLE MKTCRM.Ton1.[RP._06_store_t3] ;

EXEC Ton1.RP_06_store_t3 ;
-- โค้ดเก่า Original
/*
PROC SQL THREADS;
create table rp6._06_store_t3(compress= yes) as
		select distinct id, store_id, a.STORE_NAME, a.STORE_Format, trn_dte,
			count(distinct sbl_member_id) as sbl_Member_id,
			Count(distinct reference!!store_id!!trn_dte) AS ref,
			sum(total) as total,
			sum(gp) as gp, 
			sum(net_total) as net_total,
			sum(amt) as amt,
			0 /*sum(fds)*/ as fds, 
			sum(qnt_f) as qty,
			sum(TOT_AMT) as TOT_AMT, 
			sum(discount/*FDS_SALES*/) as FDS_SALES, 
			0/*sum(FDS_T1C)*/ as FDS_T1C,
			sum(point*qnt_f) as point_redeem

		from rp6._03_ a 
		left join topsrst.d_store b 
		on a.store_code = b.store_code
		where a.store_code is not null
		group by id,store_id, a.STORE_NAME , a.STORE_Format, trn_dte
	;
QUIT;
*/


-- ปรับแก้ไข โค้ดใหม่ table RP._06_store_t3
/*
select distinct id, store_id, a.STORE_NAME, a.STORE_Format, trn_dte,
			count(distinct sbl_member_id) as sbl_Member_id,
			COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
			sum(total) as total,
			sum(gp) as gp, 
			sum(net_total) as net_total,
			sum(amt) as amt,
			0 as fds, 
			sum(qnt_f) as qty,
			sum(TOT_AMT) as TOT_AMT, 
			sum(discount) as FDS_SALES, 
			0 as FDS_T1C,
			sum(point*qnt_f) as point_redeem
		from MKTCRM.Ton1.[RP._03_] a 
		left join topsrst.dbo.d_store b 
		on a.store_code = b.store_code
		where a.store_code is not null
		group by id,store_id, a.STORE_NAME , a.STORE_Format, trn_dte;
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._06_store_V2] ;

EXEC Ton1.RP_06_store_V2 ;

/*
data rp6._06_store_v2 (compress= yes);
	set rp6._06_store
		rp6._06_store_t
        rp6._06_store_t2
		rp6._06_store_t3
;
run;
*/

/*
SELECT id, store_id, STORE_NAME, STORE_Format, trn_dte, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._06_store]
UNION ALL
SELECT id, store_id, STORE_NAME, STORE_Format, trn_dte, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._06_store_t]
UNION ALL
SELECT id, store_id, STORE_NAME, STORE_Format, trn_dte, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._06_store_t2]
UNION ALL
SELECT id, store_id, STORE_NAME, STORE_Format, trn_dte, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._06_store_t3]
*/


/*
PROC EXPORT DATA= rp6._06_store
            OUTFILE= "E:\Pu\Export_SAS\Redeem1Baht\D_06_store.txt" 
            DBMS=DLM REPLACE;
     DELIMITER='7C'x; 
     PUTNAMES=YES;
RUN;

*/



/******************************************************** by store group **********************************************************/
/******************************************************** by store group **********************************************************/
/******************************************************** by store group **********************************************************/



TRUNCATE TABLE MKTCRM.Ton1.[RP._08_store] ;

EXEC Ton1.RP_08_store ;

/*by store group*/
-- โค้ดเก่า
/*
PROC SQL THREADS;
create table rp6._08_store(compress= yes) as
	select distinct id, 'Total' as store_id, put('Total',$80.) as STORE_NAME, put('Total',$80.) as STORE_Format,
				count(distinct sbl_member_id) as sbl_Member_id,
				Count(distinct reference!!store_id!!trn_dte) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 /*sum(fds)*/ as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount/*FDS_SALES*/) as FDS_SALES, 
				0/*sum(FDS_T1C)*/ as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from rp6._03_ 
	where store_code is not null
	group by  id
	;
*/

-- ปรับแก้ไข โค้ดใหม่ table _08_store
/*
select distinct id, 'Total' as store_id, 'Total' as STORE_NAME, 'Total' as STORE_Format,
				count(distinct sbl_member_id) as sbl_Member_id,
				COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount) as FDS_SALES, 
				0 as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from MKTCRM.Ton1.[RP._03_]
	where store_code is not null
	group by  id
	;
*/



TRUNCATE TABLE MKTCRM.Ton1.[RP._08_store_t] ;

EXEC Ton1.RP_08_store_t ;

-- โค้ดเก่า
/*
PROC SQL THREADS;
create table rp6._08_store_t(compress= yes) as
	select distinct id, store_id, a.STORE_NAME, a.STORE_Format,
				count(distinct sbl_member_id) as sbl_Member_id,
				Count(distinct reference!!store_id!!trn_dte) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0 /*sum(fds)*/ as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount/*FDS_SALES*/) as FDS_SALES, 
				0/*sum(FDS_T1C)*/ as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from rp6._03_ a 
	left join topsrst.d_store b 
	on a.store_code = b.store_code
	where a.store_code is not null
	group by id, store_id, a.STORE_NAME, a.STORE_Format
	;
QUIT;
*/

-- ปรับแก้ไข โค้ดใหม่ table RP._08_store_t
/*
select distinct id, store_id, a.STORE_NAME, a.STORE_Format,
				count(distinct sbl_member_id) as sbl_Member_id,
				COUNT(DISTINCT CONCAT(reference, store_id, trn_dte)) AS ref,
				sum(total) as total,
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(amt) as amt,
				0  as fds, 
				sum(qnt_f) as qty,
				sum(TOT_AMT) as TOT_AMT, 
				sum(discount) as FDS_SALES, 
				0 as FDS_T1C,
				sum(point*qnt_f) as point_redeem
	from MKTCRM.Ton1.[RP._03_] a 
	left join topsrst.dbo.d_store b 
	on a.store_code = b.store_code
	where a.store_code is not null
	group by id, store_id, a.STORE_NAME, a.STORE_Format
	;
*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._08_store_V2] ;

EXEC Ton1.RP_08_store_V2

/*
data rp6._08_store_v2 (compress= yes);
	set rp6._08_store
		rp6._08_store_t
;
run;
*/


-- ประอบร่างรวมกัน
/*
SELECT id, store_id, STORE_NAME, STORE_Format, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._08_store]
UNION ALL
SELECT id, store_id, STORE_NAME, STORE_Format, sbl_Member_id, [ref], total, gp, net_total, amt, fds, qty, TOT_AMT, FDS_SALES, FDS_T1C, point_redeem
FROM MKTCRM.Ton1.[RP._08_store_t] ;
*/




/******************************************************** summary by store & item **********************************************************/
/******************************************************** summary by store & item **********************************************************/
/******************************************************** summary by store & item **********************************************************/




/*summary by store & item*/


TRUNCATE TABLE MKTCRM.Ton1.[RP._07_store_item] ;

EXEC Ton1.RP_07_store_item

-- โค้ดเก่า
/*
proc sql;
	create table rp6._07_store_item as
	select distinct id, store_id, STORE_NAME, STORE_Format, pr_code, product_eng_desc,
/*			count(distinct sbl_member_id) as sbl_Member_id,*/
/*			count(distinct reference!!store_id!!put(trn_dte,8.))AS ref,*/
			sum(total) as total,
			sum(gp) as gp, 
			sum(net_total) as net_total,
			sum(amt) as amt,
			sum(qnt_f) as qty,
			sum(TOT_AMT) as TOT_AMT, 
			sum(discount/*FDS_SALES*/) as FDS_SALES, 
			sum(point*qnt_f) as point_redeem
	from rp6._03_ as a, topsrst.d_store as b, topsrst.d_merchandise as c
	where a.store_code = b.store_code
				and a.pr_code = c.product_code
				and a.store_code is not null
	group by id, store_id, STORE_NAME, STORE_Format, pr_code, product_eng_desc
	;
quit;
*/


-- ปรับแก้ไข โค้ดใหม่ table RP._07_store_item
/*
select distinct id, store_id, a.STORE_NAME, a.STORE_Format, pr_code, product_eng_desc,
			sum(total) as total,
			sum(gp) as gp, 
			sum(net_total) as net_total,
			sum(amt) as amt,
			sum(qnt_f) as qty,
			sum(TOT_AMT) as TOT_AMT, 
			sum(discount) as FDS_SALES, 
			sum(point*qnt_f) as point_redeem
from MKTCRM.Ton1.[RP._03_] as a, topsrst.dbo.d_store as b, topsrst.dbo.d_merchandise as c
where a.store_code = b.store_code
				and a.pr_code = c.product_code
				and a.store_code is not null
group by id, store_id, a.STORE_NAME,a.STORE_Format, pr_code, product_eng_desc
;
*/




/*end*/

/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------*/




