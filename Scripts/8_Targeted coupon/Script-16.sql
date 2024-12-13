

TRUNCATE TABLE MKTCRM.Pom.TC_exclusion_item2;
INSERT INTO MKTCRM.Pom.TC_exclusion_item2
(product_code, PRODUCT_ENG_DESC, SUBCAT_CODE, SUBCAT_ENG_DESC)
select distinct B.product_code, PRODUCT_ENG_DESC, B.SUBCAT_CODE, B.SUBCAT_ENG_DESC
from cfhqsasdidb01.topsrst.dbo.B_CATEGORYCONDITION as A 
JOIN cfhqsasdidb01.topsrst.dbo.D_MERCHANDISE as B on A.cat_code = B.subcat_code
where A.Conditionid = 42022
group by product_code, PRODUCT_ENG_DESC, SUBCAT_CODE, SUBCAT_ENG_DESC;


/*card*/
/*tableview*/
SELECT DIH_BATCH_ID, REC_CREATED, REC_CREATED_BY, REC_LUPD_DATE, REC_LUPD_BY, SBL_MEMBER_ID, T1C_CARD_NO, T1C_CARD_STATUS, CREATED_DATE, MODIFICATION_DATE, LUPD_DATE
FROM MKTCRM.POM.TC_Card;
/*proc sql threads;
create table T24Q3.Card(compress=yes) as
select distinct a.*
from  topssbl.SBL_MEMBER_CARD_LIST a
where T1C_CARD_STATUS ="Active"
and SBL_MEMBER_ID ^= '9999999999'
order by SBL_Member_ID,T1C_card_no desc;
quit;
data T24Q3.Card(compress=yes);
set T24Q3.Card;
by SBL_Member_ID;
if first.SBL_Member_ID Then output;
run;*/

/*ลบข้อมูลทั้งหมด*/
TRUNCATE TABLE MKTCRM.POM.TC_00_saleall;
/*ลบข้อมูลบางส่วน*/
DELETE FROM MKTCRM.Pom.TC_00_saleall
WHERE [month]='202409';

EXEC Pom.TC_execute_S  '202407','20240701','20240731';
EXEC Pom.TC_execute_S  '202408','20240801','20240831';
EXEC Pom.TC_execute_S  '202409','20240901','20240930';
EXEC Pom.TC_execute_S_cfm '202407','20240701','20240731';
EXEC Pom.TC_execute_S_cfm '202408','20240801','20240831';
EXEC Pom.TC_execute_S_cfm '202409','20240901','20240930';






TRUNCATE TABLE MKTCRM.POM.TC_00_saleall_T01_format;

INSERT INTO MKTCRM.POM.TC_00_saleall_T01_format
(SBL_MEMBER_id, format_name, [ref], total, gp, net_total)
select distinct SBL_MEMBER_id, store_format as format_name,
sum(ref) as ref ,sum(total) as total,sum (gp) as gp,sum(net_total) as net_total
from MKTCRM.POM.TC_00_saleall a 
group by SBL_MEMBER_id,store_format
having SUM(total) >0
and SBL_MEMBER_id IS NOT null
order by SBL_MEMBER_id, ref desc,total desc ;

TRUNCATE TABLE MKTCRM.POM.TC_00_saleall_T02_Total;
INSERT INTO MKTCRM.POM.TC_00_saleall_T02_Total
(SBL_MEMBER_id, [ref], total, gp, net_total)
select distinct SBL_MEMBER_id,
sum(ref) as ref ,sum(total) as total,sum (gp) as gp,sum(net_total) as net_total
from MKTCRM.POM.TC_00_saleall_T01_format
where SBL_MEMBER_id IS NOT null 
group by SBL_MEMBER_id
order by total desc;



/*format*/
/*ยุบรวม _01_cusformat, _01_cusformat_T*/
SELECT *
FROM MKTCRM.POM.TC_01_cusformat_T

/*data T24Q3._01_cusformat (compress=yes) ;
set T24Q3._00_saleall_T01_format;
if format_name = "TOPS DAILY" then daily = ref;
if (format_name = "Super Khum WS" ) then SKW = ref;
if (format_name = "Super Khum Tambon") then SKT = ref;
if (format_name ^= "TOPS DAILY" and format_name ^= "Super Khum WS" and format_name ^= "Super Khum Tambon") then other = ref;
run;
proc sql threads;
create table T24Q3._01_cusformat_T (compress=yes) as
select SBL_MEMBER_id, sum(daily) as daily, sum(other) as other , sum(SKW) as SKW , sum(SKT) as SKT
from T24Q3._01_cusformat
group by SBL_MEMBER_id;
quit;*/


SELECT SBL_MEMBER_id, daily, SKW, other, [ref], total, gp, net_total
FROM MKTCRM.POM.TC_01_cusformat_T01;
/*proc sql threads;
create table T24Q3._01_cusformat_T01 (compress=yes) as
select distinct _01_cusformat_T.*,_00_saleall_T02_Total.*
from T24Q3._01_cusformat_T left join T24Q3._00_saleall_T02_Total 
on _00_saleall_T02_Total.SBL_MEMBER_id = _01_cusformat_T.SBL_MEMBER_id;
quit;*/

SELECT *
FROM MKTCRM.POM.TC_01_cusformat_T01_WS_top1;
/*Proc sql threads;
create table T24Q3._01_cusformat_T01_WS_top1 (compress=yes) as
select distinct _01_cusformat_T01.*,
case when Segment_GP_E = 'Healthy & Premium Fresh' then a.SBL_MEMBER_id end as TOP1
from T24Q3._01_cusformat_T01 a left join crm.CRM_SINGLE_VIEW_24Q2 b 
on a.SBL_MEMBER_id = b.SBL_MEMBER_ID
 where a.SBL_MEmber_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449')
order by total desc;
quit;*/


SELECT *
FROM MKTCRM.POM.TC_Whole_sale_ 
/*Proc sql threads;
create table T24Q3.Whole_sale_ (compress=yes) as
select distinct SBL_Member_id, Segment_GP_E
from crm.CRM_SINGLE_VIEW_24Q2                /* edit sing view*/
where Segment_GP_E = 'Wholesale';
quit;*/



SELECT DISTINCT format_ 
FROM MKTCRM.POM.TC_01_cusformat_T02;

SELECT format_, Sale_group, SBL_MEMBER_id, [ref], total, gp, net_total
FROM MKTCRM.POM.TC_02_cus_;


/*address,mobile*/
--รวม _02_cus_contact, _02_cus_contact_ 
SELECT format_, Sale_group, IsAddress, IsMobilePhone, [language], SBL_MEMBER_id, [ref], total, gp, net_total, Gp_group
FROM MKTCRM.POM.TC_02_cus_contact ;


SELECT format_, Sale_group, IsAddress, IsMobilePhone, [language], SBL_MEMBER_id, [ref], total, gp, net_total, gpp, Gp_group, basket_size
FROM MKTCRM.POM.TC_02_cus_contact_;



/*Auto redeem*/
/*import data*/
SELECT SBL_Member_Id, T1c_card_no, Previous_balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Value3, Point_Voucher_Number3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Value7, Spending_Voucher_Number7
FROM MKTCRM.POM.TC_register_p_tik;

/*table view*/
SELECT SBL_Member_ID, T1C_card_no, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7
FROM MKTCRM.POM.TC_Register_voucher;



/*tableview กลับมาแก้ */
--CRM.FINAL_TARGETED_24Q3_20240919 a /*****อย่าลืมเปลี่ยนข้อมูล**/
SELECT SBL_MEmber_Id, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2_all;


/* map cpn2*/
/* Register*/
/*เช็ตอีกที่ นำเข้าข้อมูลT24Q3.Register_voucher  T24Q3._04_CPN2_all(นำเข้าข้อมูลFINAL_TARGETED_24Q3_20240919) */
/*สร้างเป็นtable view รวม _04_CPN2map_01_register,_04_CPN2map_02_register*/
SELECT SBL_Member_ID, T1C_card_no, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_02_register;


SELECT SBL_Member_ID, T1C_card_no, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_03_register;


SELECT SBL_Member_ID, T1C_card_no, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4, fG
FROM MKTCRM.POM.TC_04_CPN2map_04_register;


SELECT SBL_Member_Id, T1C_Card_No, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_05_register;


SELECT SBL_Member_ID, T1C_card_no, Previous_Balance, Auto_redeem, Total_point_voucher, Current_Balance, accumulate_spending, Total_Spending_Voucher, Total_Voucher, Voucher_Count, Point_Voucher_Value1, Point_Voucher_Number1, Point_Voucher_Expire1, Point_Voucher_Value2, Point_Voucher_Number2, Point_Voucher_Expire2, Point_Voucher_Value3, Point_Voucher_Number3, Point_Voucher_Expire3, Spending_Voucher_Value1, Spending_Voucher_Number1, Spending_Voucher_Expire1, Spending_Voucher_Value2, Spending_Voucher_Number2, Spending_Voucher_Expire2, Spending_Voucher_Value3, Spending_Voucher_Number3, Spending_Voucher_Expire3, Spending_Voucher_Value4, Spending_Voucher_Number4, Spending_Voucher_Expire4, Spending_Voucher_Value5, Spending_Voucher_Number5, Spending_Voucher_Expire5, Spending_Voucher_Value6, Spending_Voucher_Number6, Spending_Voucher_Expire6, Spending_Voucher_Value7, Spending_Voucher_Number7, Spending_Voucher_Expire7, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_register_all;



/*Export  Register group*/
/* map cpn2*/
/* Not Register*/
SELECT format_, sbl_member_id, total
FROM MKTCRM.POM.TC_04_CPN2map_01_not_register;

SELECT format_, sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_02_not_register;


SELECT format_, sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_03_not_register;
/*create table T24Q3._04_CPN2map_03_not_register (compress=yes) as
select distinct a.*
from T24Q3._04_CPN2map_02_not_register a
where a.CPN_Discount_1 Is null;*/

/*กลับมาแก้*/
SELECT format_, sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_04_not_register;


SELECT format_, sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4, fG
FROM MKTCRM.POM.TC_04_CPN2map_05_not_register;
/*
create table T24Q3._04_CPN2map_05_not_register(compress=yes) as
select distinct a.*,
case when final_group is null then 'NR02' else 'NR02' end as fG
from T24Q3._04_CPN2map_03_not_register a;*/


SELECT format_, SBL_Member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
FROM MKTCRM.POM.TC_04_CPN2map_06_not_register;


SELECT *
FROM MKTCRM.POM.TC_04_CPN2map_not_register_all


select distinct a.*, language
from MKTCRM.POM.TC_04_CPN2map_not_register_all a 
left join cfhqsasdidb01.topssbl.dbo.sbl_customer b on a.sbl_member_id = b.sbl_member_id

/*Export  Not-Register group*/
