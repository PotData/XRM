
TRUNCATE TABLE MKTCRM.Pom.TC_exclusion_item2;
INSERT INTO MKTCRM.Pom.TC_exclusion_item2
(product_code, PRODUCT_ENG_DESC, SUBCAT_CODE, SUBCAT_ENG_DESC)
select distinct B.product_code, PRODUCT_ENG_DESC, B.SUBCAT_CODE, B.SUBCAT_ENG_DESC
from cfhqsasdidb01.topsrst.dbo.B_CATEGORYCONDITION as A 
JOIN cfhqsasdidb01.topsrst.dbo.D_MERCHANDISE as B on A.cat_code = B.subcat_code
where A.Conditionid = 42022
group by product_code, PRODUCT_ENG_DESC, SUBCAT_CODE, SUBCAT_ENG_DESC;


/*card*/
/*create VIEW Pom.TC_Card AS
WITH Ranked_Cards AS (
    SELECT 
        a.*, 
        ROW_NUMBER() OVER (
            PARTITION BY SBL_MEMBER_ID 
            ORDER BY T1C_card_no DESC
        ) AS RowNum
    FROM 
        cfhqsasdidb01.topssbl.dbo.SBL_MEMBER_CARD_LIST AS a
    WHERE 
        T1C_CARD_STATUS = 'Active'
        AND SBL_MEMBER_ID <> '9999999999'
)
SELECT *
FROM Ranked_Cards
WHERE  RowNum = 1;*/


/*ลบข้อมูลทั้งหมด*/
TRUNCATE TABLE MKTCRM.POM.TC_00_saleall;
/*ลบข้อมูลบางส่วน*/
DELETE FROM MKTCRM.Pom.TC_00_saleall
WHERE [month]='202407';

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
WHERE SBL_MEMBER_id IS NOT null
group by SBL_MEMBER_id,store_format
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
/*CREATE VIEW Pom.TC_01_cusformat_T AS
SELECT 
    SBL_MEMBER_id,
    SUM(CASE WHEN format_name = 'TOPS DAILY' THEN ref ELSE 0 END) AS daily,
    SUM(CASE WHEN format_name = 'Super Khum WS' THEN ref ELSE 0 END) AS SKW,
    SUM(CASE WHEN format_name = 'Super Khum Tambon' THEN ref ELSE 0 END) AS SKT,
    SUM(CASE WHEN (format_name NOT IN ('TOPS DAILY', 'Super Khum WS', 'Super Khum Tambon')OR format_name IS NULL) THEN ref ELSE 0 END) AS other
FROM MKTCRM.POM.TC_00_saleall_T01_format
GROUP BY SBL_MEMBER_id;*/


/*CREATE VIEW Pom.TC_01_cusformat_T01  as
select distinct a.*,b.[ref] ,b.total ,b.gp,b.net_total 
from MKTCRM.Pom.TC_01_cusformat_T a left join MKTCRM.Pom.TC_00_saleall_T02_Total b
on b.SBL_MEMBER_id = a.SBL_MEMBER_id;*/


/*CREATE VIEW POM.TC_01_cusformat_T01_WS_top1 AS
SELECT DISTINCT 
    a.*,
    CASE 
        WHEN b.Segment_GP_E = 'Healthy & Premium Fresh' THEN a.SBL_MEMBER_id 
        ELSE NULL 
    END AS TOP1
FROM MKTCRM.Pom.TC_01_cusformat_T01 a
LEFT JOIN MKTCRM.dbo.crm_single_view_2409  b ON  a.SBL_MEMBER_id = b.SBL_MEMBER_ID
WHERE 
    a.SBL_MEMBER_id NOT IN ('9-014342304', '9-014223414', '9-014511211', '9-014493473', '9-014234126', '9-014651449');*/


/*create view Pom.TC_Whole_sale_ AS
select distinct SBL_Member_id, Segment_GP_E
from MKTCRM.dbo.crm_single_view_2409 /* edit sing view*/
where Segment_GP_E = 'Wholesale';*/


/*CREATE VIEW Pom.TC_01_cusformat_T02 AS
SELECT 
    a.*, 
    CASE 
        WHEN b.segment_GP_E <> '' THEN 'Whole_sale'
        WHEN SKW <> '' AND daily = '' AND other = '' THEN 'SKW'
        WHEN SKW >= daily AND other = '' THEN 'SKW'
        WHEN SKW < daily AND other = '' THEN 'Daily'
        WHEN other <> '' AND TOP1 <> '' THEN 'Normal_TOP1%'
        WHEN other <> '' AND TOP1 = '' THEN 'Normal'
        WHEN daily <> '' AND SKW = '' AND other = '' THEN 'Daily'
        ELSE ''
    END AS format_,
    CASE 
        WHEN total >= 5000 THEN '00_>=5000'
        WHEN total >= 4000 AND total < 5000 THEN '01_4000-4999'
        WHEN total >= 3000 AND total < 4000 THEN '02_3000-3999'
        WHEN total < 3000 THEN '03_<3000'
        ELSE ''
    END AS Sale_group
FROM MKTCRM.Pom.TC_01_cusformat_T01_WS_top1 a
LEFT JOIN MKTCRM.Pom.TC_Whole_sale_ b
ON a.SBL_MEMBER_id = b.SBL_Member_id ;*/


/*create VIEW POM.TC_02_cus_  as
select distinct format_,Sale_group,SBL_MEMBER_id,ref,total,gp,net_total
from MKTCRM.POM.TC_01_cusformat_t02
where format_ IS NOT null;*/


/*address,mobile*/
--รวม _02_cus_contact, _02_cus_contact_ 
/*create VIEW Pom.TC_02_cus_contact  as
select format_,Sale_group,
case when HOME_ADDR_ISVALID ='N' then 'Y' 
else case when HOME_ADDR_ISVALID ='Y' then 'N' end end as IsAddress,
IS_MOBILEPHONE as IsMobilePhone,
/*IsAddress,IsMobilePhone,*/
CASE 
    WHEN b.language IS NULL 
         AND (FIRST_TH_NAME IS NULL 
              OR SUBSTRING(FIRST_TH_NAME, 1, 1) IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))
    THEN 'EN'
    WHEN b.language IS NULL 
    THEN 'TH'
    ELSE UPPER(b.language) 
END AS language,
a.SBL_MEMBER_id,ref,total,gp,net_total
from MKTCRM.POM.TC_02_cus_ a
left join topssbl.dbo.sbl_customer b on a.SBL_Member_id = b.SBL_Member_ID;*/


/*Auto redeem*/
/*import data  MKTCRM.POM.register_p_tik*/  /*อย่าลืมอัปเดตเป็นของใหม่*/

/*create VIEW POM.TC_Register_voucher as  /*อย่าลืมอัปเดตเป็นของใหม่*/
select 
SBL_Member_ID,
T1C_card_no,
Previous_Balance,
Auto_redeem,
Total_point_voucher,
Current_Balance,
accumulate_spending,
Total_Spending_Voucher,
Total_Voucher,
Voucher_Count,
Point_Voucher_Value1,Point_Voucher_Number1,'' as Point_Voucher_Expire1,
Point_Voucher_Value2,Point_Voucher_Number2,'' as Point_Voucher_Expire2,
Point_Voucher_Value3,Point_Voucher_Number3,'' as Point_Voucher_Expire3,
Spending_Voucher_Value1,Spending_Voucher_Number1,'' as Spending_Voucher_Expire1,
Spending_Voucher_Value2,Spending_Voucher_Number2,'' as Spending_Voucher_Expire2,
Spending_Voucher_Value3,Spending_Voucher_Number3,'' as Spending_Voucher_Expire3,
Spending_Voucher_Value4,Spending_Voucher_Number4,'' as Spending_Voucher_Expire4,
Spending_Voucher_Value5,Spending_Voucher_Number5,'' as Spending_Voucher_Expire5,
Spending_Voucher_Value6,Spending_Voucher_Number6,'' as Spending_Voucher_Expire6,
Spending_Voucher_Value7,Spending_Voucher_Number7,'' as Spending_Voucher_Expire7

from MKTCRM.Pom.REGISTER_P_TIK   /*อย่าลืมอัปเดตเป็นของใหม่*/;*/


/*tableview กลับมาแก้ */
CRM.FINAL_TARGETED_24Q3_20240919 a /*****อย่าลืมเปลี่ยนข้อมูล**/
/*create VIEW Pom.TC_04_CPN2_all as
select distinct SBL_MEmber_Id,
Final_group,
CPN_Discount_1,CPN_Purchase_1,CPN_Barcode_1,
CPN_Discount_2,CPN_Purchase_2,CPN_Barcode_2,
CPN_Discount_3,CPN_Purchase_3,CPN_Barcode_3,
CPN_Discount_4,CPN_Purchase_4,CPN_Barcode_4
/*CPN_Discount_5,CPN_Purchase_5,CPN_Barcode_5,
CPN_Discount_6,CPN_Purchase_6,CPN_Barcode_6,
CPN_Discount_7,CPN_Purchase_7,CPN_Barcode_7,
CPN_Discount_8,CPN_Purchase_8,CPN_Barcode_8*/

from MKTCRM.Pom.CRM_FINAL_TARGETED_24Q3_20240919 a /*****อย่าลืมเปลี่ยนข้อมูล**/
/*left join barcode b on Final_Group = GROUP*/;*/

/* map cpn2*/
/* Register*/
/*เช็ตอีกที่ นำเข้าข้อมูลT24Q3.Register_voucher  T24Q3._04_CPN2_all(นำเข้าข้อมูลFINAL_TARGETED_24Q3_20240919) */
/*สร้างเป็นtable view รวม _04_CPN2map_01_register,_04_CPN2map_02_register*/
/*CREATE VIEW Pom.TC_04_CPN2map_02_register AS
SELECT DISTINCT 
	a.SBL_Member_ID, a.T1C_card_no, a.Previous_Balance, a.Auto_redeem, a.Total_point_voucher, 
	a.Current_Balance, a.accumulate_spending, a.Total_Spending_Voucher, a.Total_Voucher, 
	a.Voucher_Count, a.Point_Voucher_Value1, a.Point_Voucher_Number1, a.Point_Voucher_Expire1, 
	a.Point_Voucher_Value2, a.Point_Voucher_Number2, a.Point_Voucher_Expire2, a.Point_Voucher_Value3, 
	a.Point_Voucher_Number3, a.Point_Voucher_Expire3, a.Spending_Voucher_Value1, a.Spending_Voucher_Number1, 
	a.Spending_Voucher_Expire1, a.Spending_Voucher_Value2, a.Spending_Voucher_Number2, a.Spending_Voucher_Expire2, 
	a.Spending_Voucher_Value3, a.Spending_Voucher_Number3, a.Spending_Voucher_Expire3, a.Spending_Voucher_Value4, 
	a.Spending_Voucher_Number4, a.Spending_Voucher_Expire4, a.Spending_Voucher_Value5, a.Spending_Voucher_Number5, 
	a.Spending_Voucher_Expire5, a.Spending_Voucher_Value6, a.Spending_Voucher_Number6, a.Spending_Voucher_Expire6, 
	a.Spending_Voucher_Value7, a.Spending_Voucher_Number7, a.Spending_Voucher_Expire7,
    /*b*/
    b.Final_group, b.CPN_Discount_1, b.CPN_Purchase_1, b.CPN_Barcode_1, b.CPN_Discount_2, b.CPN_Purchase_2, 
    b.CPN_Barcode_2, b.CPN_Discount_3, b.CPN_Purchase_3, b.CPN_Barcode_3, b.CPN_Discount_4, b.CPN_Purchase_4, b.CPN_Barcode_4

FROM MKTCRM.Pom.TC_Register_voucher a 
LEFT JOIN MKTCRM.Pom.TC_04_CPN2_all b
    ON a.sbl_member_id = b.sbl_member_id
WHERE b.CPN_Discount_1 IS NULL;*/


/*
CREATE VIEW POM.TC_04_CPN2map_03_register AS
SELECT DISTINCT 
    a.SBL_Member_ID, a.T1C_card_no, a.Previous_Balance, a.Auto_redeem, a.Total_point_voucher, 
    a.Current_Balance, a.accumulate_spending, a.Total_Spending_Voucher, a.Total_Voucher, a.Voucher_Count, 
    a.Point_Voucher_Value1, a.Point_Voucher_Number1, a.Point_Voucher_Expire1, a.Point_Voucher_Value2, 
    a.Point_Voucher_Number2, a.Point_Voucher_Expire2, a.Point_Voucher_Value3, a.Point_Voucher_Number3, 
    a.Point_Voucher_Expire3, a.Spending_Voucher_Value1, a.Spending_Voucher_Number1, a.Spending_Voucher_Expire1, 
    a.Spending_Voucher_Value2, a.Spending_Voucher_Number2, a.Spending_Voucher_Expire2, a.Spending_Voucher_Value3, 
    a.Spending_Voucher_Number3, a.Spending_Voucher_Expire3, a.Spending_Voucher_Value4, a.Spending_Voucher_Number4, 
    a.Spending_Voucher_Expire4, a.Spending_Voucher_Value5, a.Spending_Voucher_Number5, a.Spending_Voucher_Expire5, 
    a.Spending_Voucher_Value6, a.Spending_Voucher_Number6, a.Spending_Voucher_Expire6, a.Spending_Voucher_Value7, 
    a.Spending_Voucher_Number7, a.Spending_Voucher_Expire7,
    b.Final_group, b.CPN_Discount_1, b.CPN_Purchase_1, b.CPN_Barcode_1, b.CPN_Discount_2, b.CPN_Purchase_2, 
    b.CPN_Barcode_2, b.CPN_Discount_3, b.CPN_Purchase_3, b.CPN_Barcode_3, b.CPN_Discount_4, b.CPN_Purchase_4, 
    b.CPN_Barcode_4
FROM MKTCRM.Pom.TC_Register_voucher AS a
LEFT JOIN MKTCRM.Pom.TC_04_CPN2_all AS b
ON a.SBL_Member_ID = b.SBL_Member_ID;*/

/*create VIEW Pom.TC_04_CPN2map_04_register as
select distinct a.*,
case when final_group is null then 'R02' else 'R02' end as fG
from MKTCRM.Pom.TC_04_CPN2map_02_register a;*/


/*create VIEW POM.TC_04_CPN2map_05_register as
select distinct SBL_Member_Id,T1C_Card_No,	Previous_Balance,	Auto_redeem	,Total_point_voucher,
Current_Balance,	accumulate_spending,	Total_Spending_Voucher	,Total_Voucher,	Voucher_Count,
Point_Voucher_Value1,Point_Voucher_Number1,	Point_Voucher_Expire1,	
Point_Voucher_Value2,Point_Voucher_Number2,	Point_Voucher_Expire2,
Point_Voucher_Value3,Point_Voucher_Number3,	Point_Voucher_Expire3,
Spending_Voucher_Value1	,Spending_Voucher_Number1,	Spending_Voucher_Expire1,
Spending_Voucher_Value2	,Spending_Voucher_Number2,	Spending_Voucher_Expire2,
Spending_Voucher_Value3	,Spending_Voucher_Number3,	Spending_Voucher_Expire3,
Spending_Voucher_Value4	,Spending_Voucher_Number4,	Spending_Voucher_Expire4,
Spending_Voucher_Value5 ,Spending_Voucher_Number5,	Spending_Voucher_Expire5,
Spending_Voucher_Value6	,Spending_Voucher_Number6,	Spending_Voucher_Expire6, 
Spending_Voucher_Value7	,Spending_Voucher_Number7,	Spending_Voucher_Expire7, /*จำนวน voucher*/
b.Final_group,
b.CPN_Discount_1,b.CPN_Purchase_1,b.CPN_Barcode_1,
b.CPN_Discount_2,b.CPN_Purchase_2,b.CPN_Barcode_2,
b.CPN_Discount_3,b.CPN_Purchase_3,b.CPN_Barcode_3,
b.CPN_Discount_4,b.CPN_Purchase_4,b.CPN_Barcode_4
/*b.CPN_Discount_5,b.CPN_Purchase_5,b.CPN_Barcode_5,
b.CPN_Discount_6,b.CPN_Purchase_6,b.CPN_Barcode_6,
b.CPN_Discount_7,b.CPN_Purchase_7,b.CPN_Barcode_7,
b.CPN_Discount_8,b.CPN_Purchase_8,b.CPN_Barcode_8*/

from MKTCRM.Pom.TC_04_CPN2map_04_register a left join MKTCRM.Pom.cpn2_tier b
on a.fG = b.Final_Group ;*/


/*CREATE VIEW  Pom.TC_04_CPN2map_register_all AS
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_03_register
UNION ALL
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_05_register;*/


/*Export  Register group*/
/* map cpn2*/
/* Not Register*/
/*create VIEW Pom.TC_04_CPN2map_01_not_register  as
select distinct format_,sbl_member_id,total
from  MKTCRM.Pom.TC_02_cus_contact_ a 
where total >=4000
and a.SBL_Member_id not in (select SBL_MEMBER_ID from MKTCRM.Pom.TC_04_CPN2map_register_all)
group by format_,sbl_member_id,total;*/


/*create VIEW Pom.TC_04_CPN2map_02_not_register as
select distinct format_,a.sbl_member_id,
total,Final_group,
CPN_Discount_1,CPN_Purchase_1,CPN_Barcode_1,
CPN_Discount_2,CPN_Purchase_2,CPN_Barcode_2,
CPN_Discount_3,CPN_Purchase_3,CPN_Barcode_3,
CPN_Discount_4,CPN_Purchase_4,CPN_Barcode_4
/*CPN_Discount_5,CPN_Purchase_5,CPN_Barcode_5,
CPN_Discount_6,CPN_Purchase_6,CPN_Barcode_6,
CPN_Discount_7,CPN_Purchase_7,CPN_Barcode_7,
CPN_Discount_8,CPN_Purchase_8,CPN_Barcode_8*/
from MKTCRM.Pom.TC_04_CPN2map_01_not_register a left join MKTCRM.Pom.TC_04_CPN2_all b
on a.sbl_member_id = b.sbl_member_id;*/


/*create VIEW Pom.TC_04_CPN2map_03_not_register as
select distinct a.*
from MKTCRM.Pom.TC_04_CPN2map_02_not_register a
where a.CPN_Discount_1 Is null;*/


/*create VIEW Pom.TC_04_CPN2map_04_not_register as
select distinct format_,sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, 
CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
from MKTCRM.Pom.TC_04_CPN2map_02_not_register 
WHERE sbl_member_id  not in(SELECT sbl_member_id FROM MKTCRM.Pom.TC_04_CPN2_all );*/


/*create VIEW Pom.TC_04_CPN2map_05_not_register as
select distinct a.*,
case when final_group is null then 'NR02' else 'NR02' end as fG
from MKTCRM.Pom.TC_04_CPN2map_03_not_register a;*/


/*create VIEW Pom.TC_04_CPN2map_06_not_register as
select distinct a.format_,a.SBL_Member_id,a.total,
b.Final_group,
b.CPN_Discount_1,b.CPN_Purchase_1,b.CPN_Barcode_1,
b.CPN_Discount_2,b.CPN_Purchase_2,b.CPN_Barcode_2,
b.CPN_Discount_3,b.CPN_Purchase_3,b.CPN_Barcode_3,
b.CPN_Discount_4,b.CPN_Purchase_4,b.CPN_Barcode_4
/*b.CPN_Discount_5,b.CPN_Purchase_5,b.CPN_Barcode_5,
b.CPN_Discount_6,b.CPN_Purchase_6,b.CPN_Barcode_6,
b.CPN_Discount_7,b.CPN_Purchase_7,b.CPN_Barcode_7,
b.CPN_Discount_8,b.CPN_Purchase_8,b.CPN_Barcode_8*/
from MKTCRM.Pom.TC_04_CPN2map_05_not_register a left join MKTCRM.Pom.Cpn2_tier b
on a.FG = b.Final_group;*/


/*create VIEW Pom.TC_04_CPN2map_not_register_all AS
SELECT *
FROM MKTCRM.Pom.TC_04_cpn2map_04_not_register
UNION ALL
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_06_not_register;*/

select distinct a.*, language
INTO MKTCRM.Pom.


from MKTCRM.POM.TC_04_CPN2map_not_register_all a 
left join cfhqsasdidb01.topssbl.dbo.sbl_customer b on a.sbl_member_id = b.sbl_member_id

/*Export  Not-Register group*/
