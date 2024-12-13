/*Store Campaign Performances - Giveaway Premium*/


------------------------------------------------------
-- ##### Store Campaign 
-- Note #1 : Table หลัก จะสร้างเป็น Store Procedure ไว้ หรือมีการสร้าง Table ขึ้นมาจริงๆ จำเป็นต้องมีการ TRUNCATE TABLE กรณีที่ต้องการล้างข้อมูลเก่าออกก่อน
-- Note #2 : Table ที่เป็น Temp หรือไม่มีการเปลี่ยนข้อมูลตัวแปรด้านใน จะสร้างเป็น Table View ไว้แทน เพื่อลดขั้นตอนการ TRUNCATE TABLE สามารถ select * from ข้อมูลออกมาได้เลย (ข้อมูลแปรเปลี่ยนตาม Table Main ใน Note #1 อยู่แล้ว)
-- Note #3 : ใช้ชื่อ Module เป็น SC ('Store Campaign') นำหน้าแต่ละชื่อ Table และ Procedure ในการจัดหมวดหมู่โปรแกรม ออกจากโปรแกรมอื่นๆ
-------------------------------------------------------




--options dlcreatedir;
--libname A5 'G:\Ton\Nanglyncgee_Premium_PH3\';



/*********************************** Flag Member - NL *******************************/
/*********************************** Flag Member - NL *******************************/
/*********************************** Flag Member - NL *******************************/


-- รับค่า date ตาม table A5.Premium_TX_17Oct24 ที่ import เข้ามา (ขึ้นอยู่กับชื่อ Table)
-- คำสั่งนี้ สร้าง table : MKTCRM.Ton1.[SC.Premium_TX_yyyymmdd_F]
-- ** เปลี่ยน variable ชื่อ date ของ table ที่ import เข้ามา **
EXEC Ton1.SC_Premium_TX '17Oct24' ;


/*
proc sql threads;
create table A5.Premium_TX_17Oct24_F (compress = yes) as
select A.*, sbl_member_id
from A5.Premium_TX_17Oct24 as A
left join topssbl.sbl_member_card_list b 
on A.t1c_card_no = B.t1c_card_no
;
quit;
*/


-- รับค่าชื่อ table ที่สร้างมาจาก Table MKTCRM.Ton1.[SC.Premium_TX_yyyymmdd_F]
-- คำสั่งนี้สร้าง table : MKTCRM.Ton1.[SC.Premium_TX_yyyymmdd_sbl]
-- ** เปลี่ยน variable ชื่อ date ของ table ที่ import เข้ามา **
EXEC Ton1.SC_Premium_TX_sbl '17Oct24' ;
/*
proc sql threads;
create table A5.Premium_TX_17Oct24_sbl (compress = yes) as
select distinct sbl_member_id
from A5.Premium_TX_17Oct24_F as A
where A.sbl_member_id is not null
group by sbl_member_id
;
quit;
*/


-- รับค่าชื่อ table ที่สร้างมาจาก Table MKTCRM.Ton1.[SC.Premium_TX_yyyymmdd_F]
-- คำสั่งนี้สร้าง table : MKTCRM.Ton1.[SC.Premium_TX_yyyymmdd_F_sumv]
-- ** เปลี่ยน variable ชื่อ date ของ table ที่ import เข้ามา **
EXEC Ton1.SC_Premium_TX_F_SumV '17Oct24' ;
/*
proc sql threads;
create table A5.Premium_TX_17Oct24_F_sumv (compress = yes) as
select sum(Premium_Qty) as Premium_Qty, sum(Premium_Qty*249) as Prem_Value
from A5.Premium_TX_17Oct24_F as A
;
quit;
*/




/*********************************** Eligible Tx *******************************/
/*********************************** Eligible Tx *******************************/
/*********************************** Eligible Tx *******************************/

/*TY*/

-- ล้างข้อมูลเก่าออกก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.NL_All_Prem_TY] ;



-- รับค่า yyyymm ตาม table Topst1c.SALES_PROMOTION_COMP_&yyyymm ของเดือนที่จะใช้
-- รับค่า trn_dte ใส่มาตามที่ต้องการของ Between
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_NL_All_Prem_TY '202410', '20241001', '20241017';
/*
%MACRO EXECUTE_SALE_TRANS_All_Vou(yyyymm);
proc sql;
	create table A5.NL_All_Prem_TY_&yyyymm as
	select distinct B.store_code, B.store_name, A.sbl_member_id,
	            A.ref_key,
                sum(qty) as quant_ty,
				sum(total) as total_ty, sum(net_total) as net_total_ty, sum(GP) as GP_ty,
                'NL' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B
	where A.store_id = B.store_code
	and A.store_id in ('055')
	and trn_dte between '20241001' and '20241017'
	group by B.store_code, B.store_name, A.sbl_member_id, A.ref_key
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_All_Vou(202410)
;
*/

/*
data A5.NL_All_Prem_TY;
set A5.NL_All_Prem_TY_202410
;
run;
*/


-- ล้างข้อมูลเก่าออกก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.NL_All_Prem_TY_f] ;

EXEC Ton1.SC_NL_All_Prem_TY_f ;

/*
proc sql;
create table A5.NL_All_Prem_TY_f (compress = yes) as
select A.*,

case when total_ty <1500 then 'T1_<1500' 
when total_ty >=1500 then 'T2_>=1500'
end as Tx_range,

case when A.sbl_member_id is not null 
and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
Then '01_Member' else '02_Non_member' end as Flag_member

from A5.NL_All_Prem_TY as A
*/



-- Check Data SAS and SQL 
-- ต่างกัน 71 ref key , ใน SAS ไม่มี
/*
SELECT DISTINCT ref_key
FROM MKTCRM.Ton1.[SC.NL_All_Prem_TY_f]
EXCEPT
SELECT DISTINCT ref_key
FROM MKTCRM.Ton1.test_SC_nl_all_prem_ty_f;
*/




SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_TY_f_c_m] ;
-- โค้ดเก่า Original
/*
proc sql;
create table A5.NL_All_Prem_TY_f_c_m (compress = yes) as
select distinct Flag_member, Tx_range, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_All_Prem_TY_f bbbas A
where Flag_member in ('01_Member')
group by Flag_member, Tx_range
;
quit;
*/

-- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้าานใน รัน table ออกมาได้เลย
/*
create view dbo.[SC.NL_All_Prem_TY_f_c_m] as
select distinct Flag_member, Tx_range, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_All_Prem_TY_f] as A
where Flag_member in ('01_Member')
group by Flag_member, Tx_range
*/


SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_TY_card];
/*-- โค้ดเก่า Original
proc sql;
create table A5.NL_All_Prem_TY_card (compress = yes) as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_All_Prem_TY_f as A
where Flag_member in ('01_Member')
group by Flag_member
;
*/
/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้าานใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_All_Prem_TY_card] as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_All_Prem_TY_f] as A
where Flag_member in ('01_Member')
group by Flag_member
;
*/



/*Eligible*/
/*Eligible*/
/*Eligible*/

SELECT * from MKTCRM.Ton1.[SC.NL_Eli_Prem_TY_card] ;
/* -- โค้ดเก่า Original
proc sql;
create table A5.NL_Eli_Prem_TY_card (compress = yes) as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_All_Prem_TY_f as A
where Flag_member in ('01_Member')
and Tx_range in ('T2_>=1500')
group by Flag_member
;
*/
/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Eli_Prem_TY_card] as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_All_Prem_TY_f] as A
where Flag_member in ('01_Member')
and Tx_range in ('T2_>=1500')
group by Flag_member
;
*/



/*********************************** PP *******************************/
/*********************************** PP *******************************/
/*********************************** PP *******************************/
/*PP*/


-- ล้างข้อมูลเก่าออกก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.NL_All_Prem_PP_f] ;

-- สร้างข้อมูลแต่ละเดือน รวมเข้า MKTCRM.Ton1.[SC.NL_All_Prem_PP_f]
-- รับค่า yyyymm จาก table : Topst1c.SALES_PROMOTION_COMP_&yyyymm
-- รับค่า trn_dte ใส่มาตามที่ต้องการของ Between
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_NL_All_Prem_PP_f '202405', '20240506' , '20240522' ;
--EXEC Ton1.SC_NL_All_Prem_PP_f '202404', '20240101' , '20241231' ;
--EXEC Ton1.SC_NL_All_Prem_PP_f '202403', '20240101' , '20241231' ;

/* -- โค้ดเก่า Original 
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table A5.NL_All_Prem_PP_&yyyymm as
	select distinct B.store_code, B.store_name, A.sbl_member_id,
	            A.ref_key,
                sum(qty) as quant_PP,
				sum(total) as total_PP, sum(net_total) as net_total_PP, sum(GP) as GP_PP,
                'NL' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B
	where A.store_id = B.store_code
	and A.store_id in ('055')
	and trn_dte between '20240506' and '20240522'
	group by B.store_code, B.store_name, A.sbl_member_id, A.ref_key
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202405)
;

data A5.NL_All_Prem_PP;
set 
A5.NL_All_Prem_PP_202405
;
run;



proc sql;
create table A5.NL_All_Prem_PP_f (compress = yes) as
select A.*,

case when total_PP <1500 then 'T1_<1500' 
when total_PP >=1500 then 'T2_>=1500'
end as Tx_range,

case when A.sbl_member_id is not null 
and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
Then '01_Member' else '02_Non_member' end as Flag_member

from A5.NL_All_Prem_PP as A
*/


/* -- โค้ดใหม่ ที่รวบรวมแล้ว ประกอบย่อ
SELECT 
    -- คอลัมน์จากตาราง B (store_code, store_name)
    B.store_code, 
    B.store_name, 
    
    -- คอลัมน์จากตาราง A (sbl_member_id, ref_key)
    A.sbl_member_id,
    A.ref_key,
    
    -- การคำนวณรวมข้อมูล (quant_PP, total_PP, net_total_PP, GP_PP)
    SUM(A.qty) AS quant_PP,
    SUM(A.total) AS total_PP, 
    SUM(A.net_total) AS net_total_PP, 
    SUM(A.GP) AS GP_PP,
    
    -- ค่าคงที่ 'NL' สำหรับ BU
    'NL' AS BU,
    
    -- สร้าง Tx_range ตามเงื่อนไขที่กำหนด
    CASE 
        WHEN SUM(A.total) < 1500 THEN 'T1_<1500' 
        WHEN SUM(A.total) >= 1500 THEN 'T2_>=1500'
    END AS Tx_range,

    -- สร้าง Flag_member ตามเงื่อนไขที่กำหนด
    CASE 
        WHEN A.sbl_member_id IS NOT NULL 
        AND A.sbl_member_id NOT IN ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999') 
        THEN '01_Member' 
        ELSE '02_Non_member' 
    END AS Flag_member

FROM 
    Topst1c.dbo.SALES_PROMOTION_COMP_202405 AS A
JOIN 
    Topsrst.dbo.d_store AS B
    ON A.store_id = B.store_code
    
WHERE 
    A.store_id IN ('055') 
    AND A.trn_dte BETWEEN '20240506' AND '20240522'

GROUP BY 
    B.store_code, 
    B.store_name, 
    A.sbl_member_id, 
    A.ref_key;
*/



SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_PP_f_c_m] ;
/* -- โค้ดเก่า Original
create table A5.NL_All_Prem_PP_f_c_m (compress = yes) as
select distinct Flag_member, Tx_range, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_All_Prem_PP_f as A
where Flag_member in ('01_Member')
group by Flag_member, Tx_range
;*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_All_Prem_PP_f_c_m] as
select distinct Flag_member, Tx_range, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_All_Prem_PP_f] as A
where Flag_member in ('01_Member')
group by Flag_member, Tx_range
;
*/


SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_PP_card] ;
/* -- โค้ดเก่า Original
proc sql;
create table A5.NL_All_Prem_PP_card (compress = yes) as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_All_Prem_PP_f as A
where Flag_member in ('01_Member')
group by Flag_member
;
*/


/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_All_Prem_PP_card] as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_All_Prem_PP_f] as A
where Flag_member in ('01_Member')
group by Flag_member
;
*/





SELECT * from MKTCRM.Ton1.[SC.NL_Eli_Prem_PP_card] ;
/*Eligible*/
/* -- โค้ดเก่า Original
proc sql;
create table A5.NL_Eli_Prem_PP_card (compress = yes) as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_All_Prem_PP_f as A
where Flag_member in ('01_Member')
and Tx_range in ('T2_>=1500')
group by Flag_member
;
*/


/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Eli_Prem_PP_card] as
select distinct Flag_member, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_All_Prem_PP_f] as A
where Flag_member in ('01_Member')
and Tx_range in ('T2_>=1500')
group by Flag_member
;
*/



SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_TYPP_m] ;

/* -- โค้ดเก่า Original
data A5.NL_All_Prem_TYPP_m;
set A5.NL_All_Prem_TY_f_c_m
A5.NL_All_Prem_PP_f_c_m
;
run;
*/

/* โค้ดใหม่ ปรับให้สร้าง Table View ไว้  เอามา Union กันได้เลย
create view dbo.[SC.NL_All_Prem_TYPP_m] as 
SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_PP_f_c_m] 

Union all 
SELECT * from MKTCRM.Ton1.[SC.NL_All_Prem_TY_f_c_m]
*/




/*********************************** Parti tickets *******************************/
/*********************************** Parti tickets *******************************/
/*********************************** Parti tickets *******************************/



/*Parti tickets*/
/*NL - Parti cust Sales*/
/*TY*/

-- ล้างข้อมูลเก่าออกก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.NL_Partx_TY] ;

-- รันเพื่อสร้างข้อมูลมาเก็บไว้ใน table MKTCRM.Ton1.[SC.NL_Partx_TY]
-- รับค่า yyyymm เพื่อรันข้อมูลจาก ตาราง Topst1c.SALES_PROMOTION_COMP_&yyyymm
-- รับค่า trn_dte ใส่มาตามที่ต้องการของ Between Start and End
-- รับค่าชื่อ table: Premium_TX_17Oct24_F ให้เปลี่ยนตามชื่อ table ที่ import เข้ามา

-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_NL_Partx_TY '202410', '20241001', '20241017' , '17oct24' ;

/* โค้ดเก่า Original
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table A5.NL_Partx_TY_&yyyymm as
	select distinct B.store_code, B.store_name, A.store_id, A.reference, A.Trn_dte, A.ref_key, A.sbl_member_id,
                sum(qty) as quant_ty,
				sum(total) as total_ty, sum(net_total) as net_total_ty, sum(GP) as GP_ty,
                'NL' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B
	where A.store_id = B.store_code
	and A.reference in (select reference from A5.Premium_TX_17Oct24_F)
	and trn_dte between '20241001' and '20241017'
	and store_id in ('055')
	and sbl_member_id is not null 
    and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449') 
	group by B.store_code, B.store_name, A.store_id, A.reference, A.Trn_dte, A.ref_key, A.sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202410)
;

data A5.NL_Partx_TY;
set A5.NL_Partx_TY_202410
;
run;
*/

/* -- โค้ดใหม่ ปรับแก้ไข
select distinct B.store_code, B.store_name, A.store_id, A.reference, A.Trn_dte, A.ref_key, A.sbl_member_id,
                sum(qty) as quant_ty,
				sum(total) as total_ty, sum(net_total) as net_total_ty, sum(GP) as GP_ty,
                'NL' as BU
	from Topst1c.dbo.SALES_PROMOTION_COMP_202410 as A, Topsrst.dbo.d_store as B
	where A.store_id = B.store_code
	and A.reference in (select reference from MKTCRM.Ton1.[SC.Premium_TX_17oct24_F])
	and trn_dte between '20241001' and '20241017'
	and store_id in ('055')
	and sbl_member_id is not null 
    and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449') 
	group by B.store_code, B.store_name, A.store_id, A.reference, A.Trn_dte, A.ref_key, A.sbl_member_id
*/



SELECT * from MKTCRM.Ton1.[SC.NL_Partx_TY_c] ;

/* โค้ดเก่า Original
proc sql;
create table A5.NL_Partx_TY_c (compress = yes) as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_Partx_TY as L
group by store_code, store_name
;
*/

/* -- โค้ดใหม่ ปรับแก้ไข
create view dbo.[SC.NL_Partx_TY_c]  as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, count(distinct ref_key) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_Partx_TY] as L
group by store_code, store_name
*/






/*********************************** NL - Parti cust Sales *******************************/
/*********************************** NL - Parti cust Sales *******************************/
/*********************************** NL - Parti cust Sales *******************************/


/*NL - Parti cust Sales*/

TRUNCATE Table MKTCRM.Ton1.[SC.PARTI_NL_Prem_sbl] ;

--รับค่าชื่อ table: Premium_TX_17Oct24_F ให้เปลี่ยนตามชื่อ table ที่ import เข้ามา
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_PARTI_NL_Prem_sbl '17oct24' ;

/* โค้ดเก่า Original
proc sql;
create table A5.PARTI_NL_Prem_sbl (compress = yes) as
select distinct sbl_member_id, sum(Premium_Qty*249) as Prem_Value
from A5.Premium_TX_17Oct24_F as L
where sbl_member_id is not null 
and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449')
group by sbl_member_id
;
quit;
*/

/* -- โค้ดใหม่ ปรับแก้ไข
select distinct sbl_member_id, sum(Premium_Qty*249) as Prem_Value
from MKTCRM.Ton1.[SC.Premium_TX_17oct24_F] as L
where sbl_member_id is not null 
and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449')
group by sbl_member_id
;
*/



-- ล้างข้อมูลเก่าออกก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.NL_Parti_Prem_TY] ;

-- รันเพื่อสร้างข้อมูลมาเก็บไว้ใน table MKTCRM.Ton1.[SC.NL_Parti_Prem_TY]
-- รับค่า yyyymm เพื่อรันข้อมูลจาก ตาราง Topst1c.SALES_PROMOTION_COMP_&yyyymm
-- รับค่า trn_dte ใส่มาตามที่ต้องการของ Between Start and End
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_NL_Parti_Prem_TY '202410' , '20241001' ,'20241017';

/*TY*/
/* โค้ดเก่า Original
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table A5.NL_Parti_Prem_TY_&yyyymm as
	select distinct B.store_code, B.store_name, A.sbl_member_id,
	            count(distinct ref_key) as Tx_ty,
                sum(qty) as quant_ty,
				sum(total) as total_ty, sum(net_total) as net_total_ty, sum(GP) as GP_ty,
                'NL' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B, A5.PARTI_NL_Prem_sbl as C
	where A.store_id = B.store_code
	and A.sbl_member_id = C.sbl_member_id
	and A.store_id in ('055')
	and trn_dte between '20241001' and '20241017'
	group by B.store_code, B.store_name, A.sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202410)
;




data A5.NL_Parti_Prem_TY;
set A5.NL_Parti_Prem_TY_202410
;
run;
*/

/* โค้ดใหม่ ปรับแก้ไข
select distinct B.store_code, B.store_name, A.sbl_member_id,
	            count(distinct ref_key) as Tx_ty,
                sum(qty) as quant_ty,
				sum(total) as total_ty, sum(net_total) as net_total_ty, sum(GP) as GP_ty,
                'NL' as BU
	from Topst1c.dbo.SALES_PROMOTION_COMP_202410 as A, Topsrst.dbo.d_store as B, MKTCRM.Ton1.[SC.PARTI_NL_Prem_sbl] as C
	where A.store_id = B.store_code
	and A.sbl_member_id = C.sbl_member_id
	and A.store_id in ('055')
	and trn_dte between '20241001' and '20241017'
	group by B.store_code, B.store_name, A.sbl_member_id
;
*/



SELECT * from MKTCRM.Ton1.[SC.NL_Parti_Prem_TY_c] ;
/* โค้ดเก่า Original
proc sql;
create table A5.NL_Parti_Prem_TY_c (compress = yes) as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, sum(tx_ty) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_Parti_Prem_TY as A
group by store_code, store_name
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Parti_Prem_TY_c] as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, sum(tx_ty) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_Parti_Prem_TY] as A
group by store_code, store_name
;
*/


SELECT * from MKTCRM.Ton1.[SC.NL_Parti_Prem_TY_card] ;
/* โค้ดเก่า Original
proc sql;
create table A5.NL_Parti_Prem_TY_card (compress = yes) as
select distinct store_code, store_name, sbl_member_id, sum(tx_ty) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from A5.NL_Parti_Prem_TY as A
group by store_code, store_name, sbl_member_id
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Parti_Prem_TY_card] as
select distinct store_code, store_name, sbl_member_id, sum(tx_ty) as tx_ty, 
                 		sum(total_ty)as total_ty, 
						sum(net_total_ty) as net_total_ty,
                 		sum(GP_ty) as gp_ty, sum(QUANT_ty) as quant_ty
from MKTCRM.Ton1.[SC.NL_Parti_Prem_TY] as A
group by store_code, store_name, sbl_member_id
;
*/



/*********************************** PP *******************************/
/*********************************** PP *******************************/
/*********************************** PP *******************************/


TRUNCATE Table MKTCRM.Ton1.[SC.NL_Parti_Prem_PP] ;
/*PP*/
-- รันเพื่อสร้างข้อมูลมาเก็บไว้ใน table MKTCRM.Ton1.[SC.NL_Parti_Prem_PP]
-- รับค่า yyyymm เพื่อรันข้อมูลจาก ตาราง Topst1c.SALES_PROMOTION_COMP_&yyyymm
-- รับค่า trn_dte ใส่มาตามที่ต้องการของ Between Start and End
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_NL_Parti_Prem_PP '202405' , '20240506' ,'20240522' ;

/*
%MACRO EXECUTE_SALE_TRANS_ALL(yyyymm);
proc sql;
	create table A5.NL_Parti_Prem_PP_&yyyymm as
	select distinct B.store_code, B.store_name, A.sbl_member_id,
	            count(distinct ref_key) as Tx_PP,
                sum(qty) as quant_PP,
				sum(total) as total_PP, sum(net_total) as net_total_PP, sum(GP) as GP_PP,
                'NL' as BU
	from Topst1c.SALES_PROMOTION_COMP_&yyyymm as A, Topsrst.d_store as B, A5.NL_Parti_Prem_TY_card as C
	where A.store_id = B.store_code
	and A.sbl_member_id = C.sbl_member_id
	and A.store_id in ('055')
	and trn_dte between '20240506' and '20240522'
	group by B.store_code, B.store_name, A.sbl_member_id
	;
quit;
%MEND;

OPTIONS mprint;
%EXECUTE_SALE_TRANS_ALL(202405)
;

data A5.NL_Parti_Prem_PP;
set 
A5.NL_Parti_Prem_PP_202405
;
run;
*/

SELECT * from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP_c]; 
/* โค้ดเก่า Original
proc sql;
create table A5.NL_Parti_Prem_PP_c (compress = yes) as
select distinct  count(distinct sbl_member_id) as No_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_Parti_Prem_PP as L
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Parti_Prem_PP_c] as
select distinct  count(distinct sbl_member_id) as No_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP] as L
;
*/


SELECT * from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP_c2]; 
/* โค้ดเก่า Original
proc sql;
create table A5.NL_Parti_Prem_PP_c (compress = yes) as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_Parti_Prem_PP as L
group by store_code, store_name
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Parti_Prem_PP_c2] as
select distinct store_code, store_name, count(distinct sbl_member_id) as No_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP] as L
group by store_code, store_name
;
*/

SELECT * from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP_card]; 
/* โค้ดเก่า Original
proc sql;
create table A5.NL_Parti_Prem_PP_card (compress = yes) as
select distinct store_code, store_name, sbl_member_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from A5.NL_Parti_Prem_PP as L
group by store_code, store_name, sbl_member_id
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_Parti_Prem_PP_card]  as
select distinct store_code, store_name, sbl_member_id, sum(tx_PP) as tx_PP, 
                 		sum(total_PP)as total_PP, 
						sum(net_total_PP) as net_total_PP,
                 		sum(GP_PP) as gp_PP, sum(QUANT_PP) as quant_PP
from MKTCRM.Ton1.[SC.NL_Parti_Prem_PP] as L
group by store_code, store_name, sbl_member_id
*/



/*********************************** Map Parti Card by Premium - Sales *******************************/
/*********************************** Map Parti Card by Premium - Sales *******************************/
/*********************************** Map Parti Card by Premium - Sales *******************************/

/*Map Parti Card by Premium - Sales*/


select * from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP] ; 

/* โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP as
select distinct A.*,
tx_pp,
total_pp,
net_total_pp,
gp_pp,
quant_pp
from A5.NL_PARTI_Prem_TY_CARD as A
left join A5.NL_PARTI_Prem_PP_CARD as B
on A.sbl_member_id = B.sbl_member_id
group by A.sbl_member_id
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP] as
select distinct A.*,
tx_pp,
total_pp,
net_total_pp,
gp_pp,
quant_pp
from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TY_CARD] as A
left join MKTCRM.Ton1.[SC.NL_PARTI_Prem_PP_CARD] as B
on A.sbl_member_id = B.sbl_member_id
--group by A.sbl_member_id
;
*/


select * from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f] ;

/* โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP_f as 
select distinct A.*, 

case when tx_pp is null then '02_NEW'
when tx_pp is not null then '01_EXS'
end as Cust_type

from A5.NL_PARTI_Prem_TYPP as A
group by sbl_member_id
;
quit;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP_f] as 
select distinct A.*, 
case when tx_pp is null then '02_NEW'
when tx_pp is not null then '01_EXS'
end as Cust_type
from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP] as A
--group by sbl_member_id
;
*/



select * from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f_c] ;

/* โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP_f_c as
select distinct Cust_type,
count(distinct sbl_member_id) as no_id,
		sum(tx_ty) as tx_ty,
        sum(total_ty) as total_ty,
		sum(net_total_ty) as net_total_ty,
		sum(gp_ty) as gp_ty,
		sum(quant_ty) as quant_ty, 

		sum(tx_pp) as tx_pp,
        sum(total_pp) as total_pp,
		sum(net_total_pp) as net_total_pp,
		sum(gp_pp) as gp_pp,
		sum(quant_pp) as quant_pp
from A5.NL_PARTI_Prem_TYPP_f as A
group by Cust_type
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP_f_c] as
select distinct Cust_type,
count(distinct sbl_member_id) as no_id,
		sum(tx_ty) as tx_ty,
        sum(total_ty) as total_ty,
		sum(net_total_ty) as net_total_ty,
		sum(gp_ty) as gp_ty,
		sum(quant_ty) as quant_ty, 

		sum(tx_pp) as tx_pp,
        sum(total_pp) as total_pp,
		sum(net_total_pp) as net_total_pp,
		sum(gp_pp) as gp_pp,
		sum(quant_pp) as quant_pp
from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f] as A
group by Cust_type
;
*/





/*********************************** New Register *******************************/
/*********************************** New Register *******************************/
/*********************************** New Register *******************************/

-- กรณีต้องการล้างข้อมูลก่อน
TRUNCATE Table MKTCRM.Ton1.[SC.New_REGISTER] ; 

-- สร้าง table : MKTCRM.Ton1.[SC.REGISTER_'xxxxx']
-- รับค่าใน parameter แรก เพื่อเอาไปใส่ในคอลัมน์ 'regis'
-- รับค่า parameter ที 2 และ 3 คือ regis_date between 20241001 and 20241017
-- ** เปลี่ยน variable -> yyyymm ของ table และ transdate **
EXEC Ton1.SC_New_REGISTER 'regis24', '20241001' , '20241017' ;

/* โค้ดเก่า Original
proc sql;
create table A5.new_Regist_Y24 (compress=yes) as
select distinct a.sbl_member_id,input(put(datepart(REGISTER_DATE),yymmddn8.),8.) as regis_date, REGISTER_BU,'regis24' as regis
from topssbl.sbl_customer a
having regis_date between 20241001 and 20241017
;
*/

/* โค้ดใหม่ ปรับแก้ไข
SELECT DISTINCT 
    a.sbl_member_id,
    CONVERT(VARCHAR(8), a.REGISTER_DATE, 112) AS regis_date,  -- ใช้ CONVERT ในการแปลงวันที่
    a.REGISTER_BU,
    'regis24' AS regis
FROM 
    topssbl.dbo.sbl_customer a
WHERE 
    CONVERT(VARCHAR(8), a.REGISTER_DATE, 112) BETWEEN '20241001' AND '20241017';  -- กรองวันที่
*/



select * from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f2] ;
/* โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP_f2 as
select distinct A.*, regis, REGISTER_BU
from A5.NL_PARTI_Prem_TYPP_f as A
left join A5.new_Regist_Y24 as B
on A.sbl_member_id = B.sbl_member_id
group by A.sbl_member_id
;
*/

/* -- โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP_f2] as
select distinct A.*, regis, REGISTER_BU
from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f] as A
left join MKTCRM.Ton1.[SC.New_REGISTER] as B
on A.sbl_member_id = B.sbl_member_id
group by A.sbl_member_id, store_code, store_name, tx_ty, total_ty, net_total_ty, gp_ty, quant_ty, tx_pp, total_pp, net_total_pp,gp_pp, quant_pp, Cust_type, B.regis, B.REGISTER_BU;
*/



SELECT * from dbo.[SC.NL_PARTI_Prem_TYPP_f3] ;

/*โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP_f3 as 
select distinct A.*, 

case when Cust_type in ('02_NEW') and regis in ('regis24') then '03_NewRe'
when Cust_type in ('02_NEW') and regis not in ('regis24') then '02_React'
else '01_EXS' end as Cust_type2

from A5.NL_PARTI_Prem_TYPP_f2 as A

;
*/

/* --โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP_f3] as  
select distinct A.*, 

case  WHEN Cust_type IN ('02_NEW') AND regis IN ('regis24') THEN '03_NewRe'
        WHEN Cust_type IN ('02_NEW') AND (regis NOT IN ('regis24') OR regis IS NULL) THEN '02_React'
        ELSE '01_EXS' 
end as Cust_type2

from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f2] as A
*/


SELECT * from dbo.[SC.NL_PARTI_Prem_TYPP_f3_c] ; 

/*โค้ดเก่า Original
proc sql;
create table A5.NL_PARTI_Prem_TYPP_f3_c as
select distinct Cust_type2,
count(distinct sbl_member_id) as no_id,
		sum(tx_ty) as tx_ty,
        sum(total_ty) as total_ty,
		sum(net_total_ty) as net_total_ty,
		sum(gp_ty) as gp_ty,
		sum(quant_ty) as quant_ty, 

		sum(tx_pp) as tx_pp,
        sum(total_pp) as total_pp,
		sum(net_total_pp) as net_total_pp,
		sum(gp_pp) as gp_pp,
		sum(quant_pp) as quant_pp
from A5.NL_PARTI_Prem_TYPP_f3 as A
group by Cust_type2
;
quit;
*/


/* --โค้ดใหม่ ปรับให้สร้าง Table View ไว้ เนื่องจากไม่ได้มีการเปลี่ยนตัวแปรอะไรด้านใน รัน table ออกมาได้เลย
create view dbo.[SC.NL_PARTI_Prem_TYPP_f3_c] as
select distinct Cust_type2,
count(distinct sbl_member_id) as no_id,
		sum(tx_ty) as tx_ty,
        sum(total_ty) as total_ty,
		sum(net_total_ty) as net_total_ty,
		sum(gp_ty) as gp_ty,
		sum(quant_ty) as quant_ty, 
		sum(tx_pp) as tx_pp,
        sum(total_pp) as total_pp,
		sum(net_total_pp) as net_total_pp,
		sum(gp_pp) as gp_pp,
		sum(quant_pp) as quant_pp
from MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f3] as A
group by Cust_type2
*/


-- Check
/*
SELECT COUNT(*) Store_code,  Cust_type2
FROM MKTCRM.Ton1.[SC.NL_PARTI_Prem_TYPP_f3]
group by  Store_code,  Cust_type2
*/