
/*Moneyback Campaign Performances Bi-Weekly*/

options dlcreatedir;
libname MT ' G:\Ton\MoneyBack_SupplierPoint_w3336';


/*import Money Back Product master*/

-- กรณีต้องการล้างข้อมูลก่อนทั้งหมด ก่อนเริ่มรันใหม่
TRUNCATE TABLE MKTCRM.Ton1.[MB.moneyback_product] ;

-- EXEC Ton1.MB_moneyback_pd 'ใส่ workweek ที่ต้องการ' ;
EXEC Ton1.MB_moneyback_pd 'WK2433/36';

-- โค้ด Original
/*
proc sql;
	create table MT.moneyback_product as
	select distinct a.*, Product_eng_Desc, BRAND_ENG_NAME as brand, SUBDEPT_ENG_DESC
	from MT.moneyback_product_master as a
	left join topsrst.d_merchandise as b
	on a.pr_code = b.product_code
	where wk in ('WK2429/32')
	;
quit;
*/

-- ปรับโค้ดใหม่ในการสร้าง table MKTCRM.Ton1.moneyback_product
/*
	select distinct a.wk, a.cond_id, a.pr_code, a.detail, a.point, a.period, a.previous, a.period_start, a.period_end, a.previous_start, a.previous_end, Product_eng_Desc, BRAND_ENG_NAME as brand, SUBDEPT_ENG_DESC
	from MKTCRM.Ton1.moneyback_product_master as a
	left join topsrst.dbo.d_merchandise as b
	on a.pr_code = b.product_code
	where wk in ('WK2429/32')
*/




-- กรณีที่ต้องการล้างข้อมูลเก่าก่อน
TRUNCATE TABLE MKTCRM.Ton1.[MB.sale_mem]

-- รันข้อมูลที่ต้องการในแต่ละเดือนเข้า table MKTCRM.Ton1.[MB.sale_mem] เลย
-- รับค่า yyyymm ของเดือนที่ต้องการเอาข้อมูลจาก Topst1c.SALES_PROMOTION_COMP_202408 และ trn_dte between '20240501' and '20240930'
EXEC Ton1.MB_sale_mem '202405', '20240501' , '20240930' ;
EXEC Ton1.MB_sale_mem '202406', '20240501' , '20240930' ;
EXEC Ton1.MB_sale_mem '202407', '20240501' , '20240930' ;
EXEC Ton1.MB_sale_mem '202408', '20240501' , '20240930' ;
EXEC Ton1.MB_sale_mem '202409', '20240501' , '20240930' ;


-- table MKTCRM.Ton1.[MB.sale_mem]
/*
/*Sales*/

select * from MKTCRM.Ton1.[MB.sale_mem]

-- โค้ดเก่า Original
proc sql;
	create table MT.sale_mem_M04 as
	select 202404 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.SALES_PROMOTION_COMP_202404
	where trn_dte between '20240417' and '20240430'
				and pr_code in (select distinct pr_code from MT.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
	;
quit;

proc sql;
	create table MT.sale_mem_M05 as
	select 202405 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.SALES_PROMOTION_COMP_202405
	where trn_dte between '20240501' and '20240531'
				and pr_code in (select distinct pr_code from MT.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
	;
quit;

proc sql;
	create table MT.sale_mem_M06 as
	select 202406 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.SALES_PROMOTION_COMP_202406
	where trn_dte between '20240601' and '20240630'
				and pr_code in (select distinct pr_code from MT.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
	;
quit;

proc sql;
	create table MT.sale_mem_M07 as
	select 202407 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.SALES_PROMOTION_COMP_202407
	where trn_dte between '20240701' and '20240731'
				and pr_code in (select distinct pr_code from MT.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
	;
quit;

proc sql;
	create table MT.sale_mem_M08 as
	select 202408 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.SALES_PROMOTION_COMP_202408
	where trn_dte between '20240801' and '20240806'
				and pr_code in (select distinct pr_code from MT.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
	;
quit;

-- ปรับแก้ไขโค้ดใหม่ 
	select 202406 as month, trn_dte, sbl_member_id, ref_key, store_id, pr_code, total, net_total, gp, qty
	from Topst1c.dbo.SALES_PROMOTION_COMP_202406
	where trn_dte between '20240601' and '20240630'
				and pr_code in (select distinct pr_code from MKTCRM.Ton1.moneyback_product)
				and sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and sbl_member_id is not null
;
*/

SELECT * FROM MKTCRM.Ton1.[MB.sale_mem] ;

/*
data MT.sale_mem (compress= yes);
	set 
		MT.sale_mem_M04
		MT.sale_mem_M05
		MT.sale_mem_M06
		MT.sale_mem_M07
		MT.sale_mem_M08
;
run;
*/


/*mapping member*/
/*proc sql;*/
/*	create table MT.sale_mem as*/
/*	select distinct L.*, R.sbl_member_id*/
/*	from MT.sale  as L*/
/*	LEFT JOIN topssbl.sbl_member_card_list as R*/
/*	on L.t1c_card_no = R.t1c_card_no*/
/*	where L.t1c_card_no is not null*/
/*				and R.sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')*/
/*				and R.sbl_member_id is not null*/
/*	;*/
/*quit;*/




/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*Flag period column*/

-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE table MKTCRM.Ton1.[MB.sale_mem_p] ;

EXEC Ton1.MB_sale_mem_p ;

-- โค้ดเก่า Original
/*
PROC SQL ;
create table MT.sale_mem_p as
	select distinct sbl_member_id, month, ref_key, store_id, cond_id, a.pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC, detail,
				total, gp, net_total, trn_dte, qty,
				case when trn_dte between period_start and period_end then wk
						when trn_dte between previous_start and previous_end then wk
						end as id,
				case when trn_dte between period_start and period_end then 'Period'
						when trn_dte between previous_start and previous_end then 'Previous' 
						end as period
	from MT.sale_mem as a 
	left join MT.moneyback_product as b
	on a.pr_code = b.pr_code
	having ID  not is null
	;
QUIT;
*/




/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*summary by pr_code*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB._01_prd] ;

EXEC Ton1.MB_01_prd;

-- โค้ดเก่า Original
/*
proc sql;
	create table MT._01_prd as 
	select distinct id,  period, cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p
	group by id, period, cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC
	;
quit;

proc sql;
	insert into dbo.[MB._01_prd]
	select distinct id, 
				period,
				0  as cond_id, 
				"total"  as pr_code, 
				"total"  as Product_eng_Desc, 
				"total"  as brand, 
				"total"  as SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MKTCRM.Ton1.[MB.sale_mem_p]
	group by id, period
	;
quit;
*/

SELECT * from MKTCRM.Ton1.[MB._01_prd] ;



/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*summary by cond_id*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB._02_conid] ;

EXEC Ton1.MB_02_conid;

/*
proc sql;
	create table MT._02_conid as 
	select distinct id, period, cond_id, detail, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p
	group by id, period, cond_id, detail, brand, SUBDEPT_ENG_DESC
	;
quit;


proc sql;
	insert into MT._02_conid
	select distinct id, 
				period, 
				0  as cond_id, 
				"total" as detail,
				"total"  as brand, 
				"total"  as SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p
	group by id, period
	;
quit;
*/

SELECT * from MKTCRM.Ton1.[MB._02_conid] ;



/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*Earn Point*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_mem_p] ;

EXEC Ton1.MB_earn_mem_p ;

-- โค้ดเก่า Original
/*
proc sql;
	create table MT.earn as
	select distinct t1c_card_no, store_id, ref_no, cond_id, trans_date, t1c_point
	from topsrst.t1c_point_trans as a
	where cond_id in (select distinct cond_id from MT.moneyback_product)
	;
quit;

proc sql;
	create table MT.earn_mem as
	select distinct L.*, R.sbl_member_id
	from MT.earn as L
	LEFT JOIN topssbl.sbl_member_card_list as R
	on L.t1c_card_no = R.t1c_card_no
	where L.t1c_card_no is not null
				and R.sbl_member_id not in ('9-014342304', '9-014223414',  '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
				and R.sbl_member_id is not null
	;
quit;

proc sql;
	create table MT.earn_mem_p as
	select distinct a.cond_id, sbl_member_id, store_id, ref_no, t1c_point, detail, brand, SUBDEPT_ENG_DESC, trans_date, 
						case when trans_date between period_start and period_end then wk end as id,
						b.point, b.period, b.previous,
						count(distinct pr_code) as no_sku
	from MT.earn_mem as a
	left join MT.moneyback_product as b
	on a.cond_id = b.cond_id
	group by a.cond_id, sbl_member_id, store_id, ref_no, t1c_point, detail, brand, SUBDEPT_ENG_DESC, trans_date, b.point, b.period, b.previous
	having id is not null
	;
quit;
*/


-- โค้ดใหม่ ในการรวม earn_mem , earn_mem และ earn_mem_p เข้าด้วยกัน , ลดขั้นในการสร้าง table ซ้ำซ้อน
/*
CREATE TABLE MKTCRM.Ton1.[MB.earn_mem_p] AS
SELECT DISTINCT 
    a.cond_id, 
    R.sbl_member_id, 
    a.store_id, 
    a.ref_no, 
    a.t1c_point, 
    b.detail, 
    b.brand, 
    b.SUBDEPT_ENG_DESC, 
    a.trans_date, 
    case when a.trans_date between b.period_start and b.period_end then b.wk end as id,
     --   ELSE NULL 
    b.point, 
    b.period, 
    b.previous,
    COUNT(DISTINCT b.pr_code) AS no_sku
FROM 
    (SELECT DISTINCT 
        t1c_card_no, 
        store_id, 
        ref_no, 
        cond_id, 
        trans_date, 
        t1c_point
     FROM 
        topsrst.dbo.t1c_point_trans AS a
     WHERE 
        cond_id IN (SELECT DISTINCT cond_id FROM MKTCRM.Ton1.moneyback_product)
    ) AS a
LEFT JOIN 
    topssbl.dbo.sbl_member_card_list AS R ON a.t1c_card_no = R.t1c_card_no
LEFT JOIN 
    MKTCRM.Ton1.moneyback_product AS b ON a.cond_id = b.cond_id
WHERE 
    a.t1c_card_no IS NOT NULL
    AND R.sbl_member_id NOT IN ('9-014342304', '9-014223414', '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999')
    AND R.sbl_member_id IS NOT NULL
GROUP BY 
    a.cond_id, 
    R.sbl_member_id, 
    a.store_id, 
    a.ref_no, 
    a.t1c_point, 
    b.detail, 
    b.brand, 
    b.SUBDEPT_ENG_DESC, 
    a.trans_date, 
    b.point, 
    b.period, 
    b.previous, 
    b.wk,  -- เพิ่ม b.wk เข้าไปใน GROUP BY
    b.period_start,  -- เพิ่ม b.period_start
    b.period_end -- -- เพิ่ม b.period_end
HAVING 
    COUNT(DISTINCT CASE 
        WHEN a.trans_date BETWEEN b.period_start AND b.period_end THEN b.pr_code 
    END) > 0;
*/

SELECT * from MKTCRM.Ton1.[MB.earn_mem_p] ;


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB._03_earn] ;

EXEC Ton1.MB_03_earn ;

-- โค้ดเก่า Original
/*
proc sql;
	create table MT._03_earn as
	select distinct a.id, "Earn point" as period, a.cond_id, a.detail, a.brand, a.SUBDEPT_ENG_DESC,
				max(a.period) as period_date,
				max(a.previous) as previous_date,
				max(a.no_sku) as no_sku,
				1 as no_items,
				count(distinct a.trans_date) as no_day,
				count(distinct a.sbl_member_id) as tc,
				count(distinct a.ref_no) as tx,
				sum(a.t1c_point) as t1c_point,
				max(b.point) as point
	from MT.earn_mem_p as a
	left join (select distinct cond_id, point from MT.moneyback_product) as b
	on a.cond_id = b.cond_id
	group by a.id, a.cond_id, a.detail, a.brand, a.SUBDEPT_ENG_DESC
	;
quit;

proc sql;
	insert into MT._03_earn 
	select distinct a.id, "Earn point" as period, 
				0 as cond_id, 
				"total" as detail, 
				"total" as brand, 
				"total" as SUBDEPT_ENG_DESC,
				max(a.period) as period_date,
				max(a.previous) as previous_date,
				0 as no_sku,
				count(distinct b.cond_id) as no_item,
				count(distinct a.trans_date) as no_day,
				count(distinct a.sbl_member_id) as tc,
				count(distinct a.ref_no) as tx,
				sum(a.t1c_point) as t1c_point,
				0 as point
	from MT.earn_mem_p as a
	left join (select distinct cond_id, count(distinct pr_code) as no_sku from MT.moneyback_product group by cond_id) as b
	on a.cond_id = b.cond_id
	group by id
	;
quit;
*/


-- โค้ดใหม่ Original
/*
create table MKTCRM.Ton1.[MB._03_earn ] as
	select distinct a.id, 'Earn point' as period, a.cond_id, a.detail, a.brand, a.SUBDEPT_ENG_DESC,
				max(a.period) as period_date,
				max(a.previous) as previous_date,
				max(a.no_sku) as no_sku,
				1 as no_items,
				count(distinct a.trans_date) as no_day,
				count(distinct a.sbl_member_id) as tc,
				count(distinct a.ref_no) as tx,
				sum(a.t1c_point) as t1c_point,
				max(b.point) as point
	from MKTCRM.Ton1.[MB.earn_mem_p] as a
	left join (select distinct cond_id, point from MKTCRM.Ton1.moneyback_product) as b
	on a.cond_id = b.cond_id
	group by a.id, a.cond_id, a.detail, a.brand, a.SUBDEPT_ENG_DESC
	;
	


	insert into MKTCRM.Ton1.[MB._03_earn ]
	select distinct a.id, 'Earn point' as period, 
				0 as cond_id, 
				'total' as detail, 
				'total' as brand, 
				'total' as SUBDEPT_ENG_DESC,
				max(a.period) as period_date,
				max(a.previous) as previous_date,
				0 as no_sku,
				count(distinct b.cond_id) as no_item,
				count(distinct a.trans_date) as no_day,
				count(distinct a.sbl_member_id) as tc,
				count(distinct a.ref_no) as tx,
				sum(a.t1c_point) as t1c_point,
				0 as point
	from MKTCRM.Ton1.[MB.earn_mem_p] as a
	left join (select distinct cond_id, count(distinct pr_code) as no_sku from MKTCRM.Ton1.moneyback_product group by cond_id) as b
	on a.cond_id = b.cond_id
	group by id
	;
*/



/*Combine period, previous, earnpoint*/
-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB._04_result] ;

EXEC Ton1.MB_04_result;

-- โค้ดเก่า Original
/*
data MT._04_result;
set MT._03_earn
MT._02_conid
;
run;
*/

-- ปรับโค้ดใหม่
/*
-- Union MB._02_conid กับ MB._03_earn
SELECT id, period, cond_id, detail, brand, SUBDEPT_ENG_DESC, no_day, tc, tx, total, net_total, gp, qty, NULL, NULL, NULL, NULL, NULL, NULL
FROM MKTCRM.Ton1.[MB._02_conid]
	
UNION ALL
	
SELECT id, period, cond_id, detail, brand, SUBDEPT_ENG_DESC, no_day, tc, tx, NULL, NULL, NULL, NULL, period_date, previous_date, no_sku, no_items, t1c_point, point
FROM MKTCRM.Ton1.[MB._03_earn];
*/


-- For compare result --
/*
SELECT id, period, COND_ID, detail, brand, SUBDEPT_ENG_DESC, period_date, previous_date, no_sku, no_items, no_day, tc, tx, t1c_point, point, total, net_total, gp, qty
FROM MKTCRM.Ton1.test_MB_04_result;

SELECT DISTINCT cond_id , sum(gp) as gp, sum(net_total) as net_total , sum(t1c_point) as t1c_point , sum(point) as point
FROM MKTCRM.Ton1.test_MB_04_result
Group by cond_id;
*/

/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*Add Qty into Earn Point Tx*/


/*Wk2532*/

-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_gtx] ;

EXEC Ton1.MB_earn_gtx;

-- โค้ดเก่า Orignal
/*
proc sql;
	create table MT.earn_gtx as 
	select distinct A.sbl_member_id, store_id, ref_no, cond_id, trans_date, t1c_point, catx("_", STORE_ID, REF_NO, TRANS_DATE) as ref_key
	from MT.earn_mem_p as A
	group by A.sbl_member_id, store_id, ref_no, cond_id, trans_date, t1c_point
	;
quit;
*/

-- โค้ดใหม่ ปรับแก้ไข
/*
SELECT DISTINCT 
    A.sbl_member_id, 
    store_id, 
    ref_no, 
    cond_id, 
    trans_date, 
    t1c_point, 
    CONCAT(STORE_ID, '_', REF_NO, '_', FORMAT(TRANS_DATE, 'yyyyMMdd')) AS ref_key
FROM MKTCRM.Ton1.[MB.earn_mem_p] AS A
GROUP BY 
    A.sbl_member_id, 
    store_id, 
    ref_no, 
    cond_id, 
    trans_date, 
    t1c_point;
*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_tx_sale] ;

EXEC Ton1.MB_earn_tx_sale;


-- โค้ดเก่า Original
/*
proc sql;
	create table MT._Earn_tx_sale as 
	select A.*, t1c_point
	from MT.sale_mem_p as A
	join MT.EARN_GTX as B
	on A.ref_key = B.ref_key
	;
quit;
*/

-- โค้ดใหม่ ปรับแก้ไข
/*
select a.sbl_member_id, a.month, a.ref_key, a.store_id, a.cond_id, a.pr_code, a.Product_eng_Desc, a.brand, a.SUBDEPT_ENG_DESC, a.detail, a.total, a.gp, a.net_total, a.trn_dte, a.qty, a.id, a.period, b.t1c_point
from MKTCRM.Ton1.[MB.sale_mem_p] as A
join MKTCRM.Ton1.[MB.EARN_GTX] as B
on A.ref_key = B.ref_key;
;
*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_tx_prd] ;

EXEC Ton1.MB_earn_tx_prd;

-- โค้ด Original 
/*
proc sql;
	create table MT._Earn_tx_prd as 
	select distinct id,  '01_Earn' as period, A.cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct A.sbl_member_id) as tc,
				count(distinct A.ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p as A
	join MT.EARN_GTX as B
	on A.ref_key = B.ref_key
	group by id, period, A.cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC
	;
quit;


proc sql;
	insert into MT._Earn_tx_prd
	select distinct id, 
				period,
				0  as cond_id, 
				"total"  as pr_code, 
				"total"  as Product_eng_Desc, 
				"total"  as brand, 
				"total"  as SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p
	group by id, period
	;
quit;
*/


-- โค้ดที่ปรับปรุง แก้ไขใหม่
/* -- ส่วนที่ 1
select distinct id,  '01_Earn' as period, A.cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct A.sbl_member_id) as tc,
				count(distinct A.ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
from MKTCRM.Ton1.[MB.sale_mem_p] as A
join MKTCRM.Ton1.[MB.EARN_GTX] as B
on A.ref_key = B.ref_key
group by id, period, A.cond_id, pr_code, Product_eng_Desc, brand, SUBDEPT_ENG_DESC
;

-- ส่วนที่ 2
SELECT 
        id, 
        period,
        0 AS cond_id, 
        'total' AS pr_code, 
        'total' AS Product_eng_Desc, 
        'total' AS brand, 
        'total' AS SUBDEPT_ENG_DESC,
        COUNT(DISTINCT trn_dte) AS no_day,
        COUNT(DISTINCT sbl_member_id) AS tc,
        COUNT(DISTINCT ref_key) AS tx,
        SUM(total) AS total,
        SUM(net_total) AS net_total,
        SUM(gp) AS gp,
        SUM(qty) AS qty
    FROM MKTCRM.Ton1.[MB.sale_mem_p]
    GROUP BY id, period
;
*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_tx_condi] ;

EXEC Ton1.MB_earn_tx_condi;

--โค้ดเก่า Original
/*
proc sql;
	create table MT._Earn_tx_condi as 
	select distinct id,  '01_Earn' as period, A.cond_id, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct A.sbl_member_id) as tc,
				count(distinct A.ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
	from MT.sale_mem_p as A
	join MT.EARN_GTX as B
	on A.ref_key = B.ref_key
	group by id, period, A.cond_id, brand, SUBDEPT_ENG_DESC
	;
quit;
*/


-- โค้ดที่ปรับปรุง แก้ไขใหม่
/*
select distinct id,  '01_Earn' as period, A.cond_id, brand, SUBDEPT_ENG_DESC,
				count(distinct trn_dte) as no_day,
				count(distinct A.sbl_member_id) as tc,
				count(distinct A.ref_key) as tx,
				sum(total) as total,
				sum(net_total) as net_total,
				sum(gp) as gp,
				sum(qty) as qty
from MKTCRM.Ton1.[MB.sale_mem_p] as A
join MKTCRM.Ton1.[MB.EARN_GTX] as B
on A.ref_key = B.ref_key
group by id, period, A.cond_id, brand, SUBDEPT_ENG_DESC
;
*/


/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*Cal qty*/


-- กรณีต้องการล้างข้อมูลก่อนเก่า
TRUNCATE TABLE MKTCRM.Ton1.[MB.earn_mem_p_qty] ;

EXEC Ton1.MB_earn_mem_p_qty;

--โค้ดเก่า Original
/*
proc sql;
	create table MT.earn_mem_p_q as 
	select A.*, t1c_point/point as Qty
	from MT.earn_mem_p as A
	;
quit;
*/

-- โค้ดที่ปรับปรุง แก้ไขใหม่
/*
select a.cond_id, a.sbl_member_id, a.store_id, a.ref_no, a.t1c_point, a.detail, a.brand, a.SUBDEPT_ENG_DESC, a.trans_date, a.id, a.point, a.period, a.previous, a.no_sku, t1c_point/point as Qty
from MKTCRM.Ton1.[MB.earn_mem_p] as A
;
*/

-- for check result 
/*
SELECT cond_id, sum(Qty) as Qty
FROM MKTCRM.Ton1.[MB.earn_mem_p_qty]
Group by cond_id;
*/



SELECT * from MKTCRM.Ton1.[MB.earn_gtx_qty]

/*
proc sql;
	create table MT.earn_gtx as 
	select distinct cond_id, sum(qty) as qty
	from MT.earn_mem_p_q as A
	group by cond_id
	;
quit;
*/

-- สร้างเป็น View ไว้ เนื่องจากไม่ได้รันเปลี่ยนตัวแปร
/*
CREATE View dbo.[MB.earn_gtx_qty] as
SELECT cond_id, sum(Qty) as Qty
FROM MKTCRM.Ton1.[MB.earn_mem_p_qty]
Group by cond_id;
*/






--END
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/