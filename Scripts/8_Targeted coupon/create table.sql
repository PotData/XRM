
create VIEW Pom.TC_EXCLUSION_ITEM2  as
select distinct B.product_code, PRODUCT_ENG_DESC, B.SUBCAT_CODE, B.SUBCAT_ENG_DESC
from topsrst.dbo.B_CATEGORYCONDITION as A JOIN topsrst.dbo.D_MERCHANDISE as B on A.cat_code = B.subcat_code
where A.Conditionid = 42022
group by product_code, PRODUCT_ENG_DESC, SUBCAT_CODE, SUBCAT_ENG_DESC;

create table MKTCRM.dbo.TC_T24Q3_Card(
	DIH_BATCH_ID NVARCHAR(20), 
	REC_CREATED DATETIME, 
	REC_CREATED_BY NVARCHAR(50), 
	REC_LUPD_DATE DATETIME, 
	REC_LUPD_BY NVARCHAR(50), 
	SBL_MEMBER_ID NVARCHAR(30), 
	T1C_CARD_NO NVARCHAR(25), 
	T1C_CARD_STATUS NVARCHAR(30), 
	CREATED_DATE DATETIME, 
	MODIFICATION_DATE DATETIME, 
	LUPD_DATE DATETIME
);

create VIEW Pom.TC_Card AS
SELECT DISTINCT *
FROM topssbl.dbo.SBL_MEMBER_CARD_LIST
WHERE T1C_CARD_STATUS = 'Active'
  AND SBL_MEMBER_ID != '9999999999'
  AND SBL_Member_ID IN (
      SELECT MIN(SBL_Member_ID)  -- หรือใช้กรณีที่คุณต้องการค่าที่เฉพาะเจาะจง
      FROM topssbl.dbo.SBL_MEMBER_CARD_LIST
      WHERE T1C_CARD_STATUS = 'Active'
      GROUP BY SBL_Member_ID
  );


CREATE VIEW dbo.TC_00_saleall AS
SELECT *
FROM MKTCRM.dbo.sale01
UNION ALL
SELECT *
FROM MKTCRM.dbo.sale02
UNION ALL
SELECT *
UNION ALL
FROM MKTCRM.dbo.sale03
SELECT *
FROM MKTCRM.dbo.sale01_cfm
UNION ALL
SELECT *
FROM MKTCRM.dbo.sale02_cfm
UNION ALL
SELECT *
FROM MKTCRM.dbo.sale03_cfm;

create table MKTCRM.Pom.TC_00_saleall_T01_format (
	SBL_MEMBER_id VARCHAR(30),
	format_name VARCHAR(50),
	ref INT,
	total MONEY,
	gp MONEY,
	net_total MONEY
);


create table MKTCRM.Pom.TC_00_saleall_T02_Total (
	SBL_MEMBER_id VARCHAR(30),
	ref INT,
	total MONEY,
	gp MONEY,
	net_total MONEY
);


CREATE VIEW Pom.TC_01_cusformat_T AS
SELECT 
    SBL_MEMBER_id,
    SUM(CASE WHEN format_name = 'TOPS DAILY' THEN ref ELSE 0 END) AS daily,
    SUM(CASE WHEN format_name = 'Super Khum WS' THEN ref ELSE 0 END) AS SKW,
    SUM(CASE WHEN format_name = 'Super Khum Tambon' THEN ref ELSE 0 END) AS SKT,
    SUM(CASE WHEN (format_name NOT IN ('TOPS DAILY', 'Super Khum WS', 'Super Khum Tambon')OR format_name IS NULL) THEN ref ELSE 0 END) AS other
FROM MKTCRM.Pom.TC_00_saleall_T01_format
GROUP BY SBL_MEMBER_id;

create VIEW Pom.TC_01_cusformat_T01  as
select distinct a.*,b.[ref] ,b.total ,b.gp,b.net_total 
from MKTCRM.dbo.TC_01_cusformat_T a left join MKTCRM.dbo.TC_00_saleall_T02_Total b
on b.SBL_MEMBER_id = a.SBL_MEMBER_id;





CREATE VIEW POM.TC_01_cusformat_T01_WS_top1 AS
SELECT DISTINCT 
    a.*,
    CASE 
        WHEN b.Segment_GP_E = 'Healthy & Premium Fresh' THEN a.SBL_MEMBER_id 
        ELSE NULL 
    END AS TOP1
FROM 
    MKTCRM.Pom.TC_01_cusformat_T01 a
LEFT JOIN 
    MKTCRM.dbo.crm_single_view_2409  b 
ON 
    a.SBL_MEMBER_id = b.SBL_MEMBER_ID
WHERE 
    a.SBL_MEMBER_id NOT IN ('9-014342304', '9-014223414', '9-014511211', '9-014493473', '9-014234126', '9-014651449');
   

create view Pom.TC_Whole_sale_ AS
select distinct SBL_Member_id, Segment_GP_E
from MKTCRM.dbo.crm_single_view_2409 
where Segment_GP_E = 'Wholesale';



CREATE TABLE T24Q3._02_cus_ AS
WITH formatted_data AS (
    SELECT 
        a.*,
        CASE 
            WHEN (a.SKT > a.daily AND a.SKT > a.other AND a.SKT > a.SKW) THEN '' 
            WHEN a.wholesale IS NOT NULL THEN 'Whole_sale'
            WHEN a.SKW IS NOT NULL AND a.daily IS NULL AND a.other IS NULL THEN 'SKW'
            WHEN a.SKW >= a.daily AND a.other IS NULL THEN 'SKW'
            WHEN a.SKW < a.daily AND a.other IS NULL THEN 'Daily'
            WHEN a.other IS NOT NULL AND a.TOP1 IS NOT NULL THEN 'Normal_TOP1%'
            WHEN a.other IS NOT NULL AND a.TOP1 IS NULL THEN 'Normal'
            WHEN a.daily IS NOT NULL AND a.SKW IS NULL AND a.other IS NULL THEN 'Daily'
            ELSE NULL 
        END AS format_,

        CASE 
            WHEN a.total >= 5000 THEN '00_>=5000'
            WHEN a.total >= 4000 AND a.total < 5000 THEN '01_4000-4999'
            WHEN a.total >= 3000 AND a.total < 4000 THEN '02_3000-3999'
            WHEN a.total < 3000 THEN '03_<3000'
            ELSE NULL 
        END AS Sale_group,

        a.SBL_MEMBER_id, 
        a.ref, 
        a.total, 
        a.gp, 
        a.net_total
    FROM 
        MKTCRM.dbo.TC_01_cusformat_T01_WS_top1 AS a
)

SELECT 
    format_, 
    Sale_group, 
    SBL_MEMBER_id, 
    ref, 
    total, 
    gp, 
    net_total
FROM 
    formatted_data
WHERE 
    format_ IS NOT NULL
ORDER BY 
    total DESC;

   
create VIEW POM.TC_Register_voucher as  /*อย่าลืมอัปเดตเป็นของใหม่*/
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

from MKTCRM.Pom.REGISTER_P_TIK   /*อย่าลืมอัปเดตเป็นของใหม่*/
order by Voucher_Count desc;

CREATE TABLE T24Q3._02_cus_contact AS
SELECT 
    format_,
    Sale_group,
    
    /* Checking the validity of home address and setting 'IsAddress' */
    CASE 
        WHEN HOME_ADDR_ISVALID = 'N' THEN 'Y'
        WHEN HOME_ADDR_ISVALID = 'Y' THEN 'N' 
        ELSE NULL 
    END AS IsAddress,
    
    /* Directly selecting the mobile phone status */
    IS_MOBILEPHONE AS IsMobilePhone,

    /* Determining language preference based on conditions */
    CASE 
        WHEN b.language IS NULL AND (b.FIRST_TH_NAME IS NULL OR 
            LEFT(b.FIRST_TH_NAME, 1) IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')) 
            THEN 'EN' 
        WHEN b.language IS NULL THEN 'TH' 
        ELSE UPPER(language) 
    END AS language,

    /* Selecting additional customer details */
    a.SBL_MEMBER_id, 
    a.ref, 
    a.total, 
    a.gp, 
    a.net_total

FROM 
    MKTCRM.dbo.test_TC_02_cus_ AS a
LEFT JOIN 
    topssbl.dbo.sbl_customer AS b 
ON 
    a.SBL_MEMBER_id = b.SBL_MEMBER_ID


SELECT SBL_MEMBER_ID, Final_Group, t1c_card_no, CPN_Purchase_1, CPN_Discount_1, CPN_BARCODE_1, CPN_Purchase_2, CPN_Discount_2, CPN_BARCODE_2, CPN_Purchase_3, CPN_Discount_3, CPN_BARCODE_3, CPN_Purchase_4, CPN_Discount_4, CPN_BARCODE_4, CPN_Purchase_5, CPN_Discount_5, CPN_BARCODE_5, CPN_Purchase_6, CPN_Discount_6, CPN_BARCODE_6, CPN_Purchase_7, CPN_Discount_7, CPN_BARCODE_7, CPN_Purchase_8, CPN_Discount_8, CPN_BARCODE_8, Flag_Line_Registered
FROM MKTCRM.dbo.crm_final_targeted_24q3_20240919;


create view dbo.TC_04_CPN2_all as
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

from MKTCRM.dbo.crm_final_targeted_24q3_20240919 a  /*****อย่าลืมเปลี่ยนข้อมูล**/
/*left join barcode b on Final_Group = GROUP*/;




CREATE VIEW Pom.TC_04_CPN2map_02_register AS
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
WHERE b.CPN_Discount_1 IS NULL;


create VIEW POM.TC_02_cus_  as
select distinct format_,Sale_group,SBL_MEMBER_id,ref,total,gp,net_total
from MKTCRM.POM.TC_01_cusformat_t02
where format_ IS NOT null;


create VIEW Pom.TC_02_cus_contact  as
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
left join topssbl.dbo.sbl_customer b on a.SBL_Member_id = b.SBL_Member_ID;


CREATE VIEW Pom.TC_02_cus_contact_  AS
SELECT 
    a.format_,
    a.Sale_group,
    CASE 
        WHEN b.HOME_ADDR_ISVALID = 'N' THEN 'Y'
        WHEN b.HOME_ADDR_ISVALID = 'Y' THEN 'N'
        ELSE NULL
    END AS IsAddress,
    b.IS_MOBILEPHONE AS IsMobilePhone,
    CASE 
    WHEN b.language IS NULL 
         AND (FIRST_TH_NAME IS NULL 
              OR SUBSTRING(FIRST_TH_NAME, 1, 1) IN ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))
    THEN 'EN'
    WHEN b.language IS NULL 
    THEN 'TH'
    ELSE UPPER(b.language) 
END AS language,
    a.SBL_MEMBER_id,
    a.ref,
    a.total,
    a.gp,
    a.net_total,
    
    CASE 
        WHEN a.net_total = 0 OR (a.gp / a.net_total) < 0 THEN 'GP<0%'
        ELSE 'GP>=0%'
    END AS Gp_group
FROM 
    MKTCRM.POM.TC_02_cus_ AS a
LEFT JOIN 
    topssbl.dbo.sbl_customer AS b 
ON 
    a.SBL_Member_id = b.SBL_Member_ID
ORDER BY 
    a.total DESC;
   

create VIEW Pom.TC_04_CPN2_all as
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
/*left join barcode b on Final_Group = GROUP*/;
quit;



CREATE VIEW Pom.TC_04_CPN2map_01_register AS
SELECT DISTINCT 
    a.SBL_Member_Id AS SBL_Member_Id, a.T1C_card_no, a.Previous_Balance, a.Auto_redeem, a.Total_point_voucher, 
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
FROM 
    MKTCRM.Pom.TC_Register_voucher a 
LEFT JOIN 
    MKTCRM.Pom.TC_04_CPN2_all b 
ON 
    a.SBL_Member_Id = b.SBL_Member_Id;

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
ON a.SBL_Member_ID = b.SBL_Member_ID;



create VIEW Pom.TC_04_CPN2map_04_register as
select distinct a.*,
case when final_group is null then 'R02' else 'R02' end as fG
from MKTCRM.Pom.TC_04_CPN2map_02_register a;



create VIEW POM.TC_04_CPN2map_05_register as
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
on a.fG = b.Final_Group ;


CREATE VIEW  Pom.TC_04_CPN2map_register_all AS
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_03_register
UNION ALL
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_05_register;


-- สร้างตาราง T24Q3._04_CPN2map_register_all ด้วยการรวมข้อมูลจากตารางต่าง ๆ
CREATE VIEW dbo.TC_04_CPN2map_register_all AS
SELECT DISTINCT 
    a.*, 
    b.format_ AS format_,
    c.language AS language,
    'register' AS group_name
FROM (
    -- รวมข้อมูลจากตาราง T24Q3._04_CPN2map_03_register และ T24Q3._04_CPN2map_05_register
    SELECT * FROM MKTCRM.dbo.TC_04_CPN2map_03_register
    UNION ALL
    SELECT * FROM MKTCRM.dbo.TC_04_CPN2map_05_register
) AS a
LEFT JOIN MKTCRM.dbo.TC_02_cus_contact_ AS b
    ON a.sbl_member_id = b.sbl_member_id
LEFT JOIN topssbl.dbo.sbl_customer AS c
    ON a.sbl_member_id = c.sbl_member_id;


create VIEW Pom.TC_04_CPN2map_01_not_register  as
select distinct format_,sbl_member_id,total
from  MKTCRM.Pom.TC_02_cus_contact_ a 
where total >=4000
and a.SBL_Member_id not in (select SBL_MEMBER_ID from MKTCRM.Pom.TC_04_CPN2map_register_all)
group by format_,sbl_member_id,total;



create VIEW Pom.TC_04_CPN2map_02_not_register as
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
on a.sbl_member_id = b.sbl_member_id


create VIEW Pom.TC_04_CPN2map_03_not_register as
select distinct a.*
from MKTCRM.Pom.TC_04_CPN2map_02_not_register a
where a.CPN_Discount_1 Is null;


from MKTCRM.dbo.TC_04_CPN2map_02_not_register a  join MKTCRM.dbo.TC_04_CPN2_all b
on a.sbl_member_id = b.sbl_member_id;



create VIEW Pom.TC_04_CPN2map_05_not_register as
select distinct a.*,
case when final_group is null then 'NR02' else 'NR02' end as fG
from MKTCRM.Pom.TC_04_CPN2map_03_not_register a;


create VIEW Pom.TC_04_CPN2map_06_not_register as
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
on a.FG = b.Final_group;


create VIEW Pom.TC_04_CPN2map_04_not_register as
select distinct format_,sbl_member_id, total, Final_group, CPN_Discount_1, CPN_Purchase_1, 
CPN_Barcode_1, CPN_Discount_2, CPN_Purchase_2, CPN_Barcode_2, CPN_Discount_3, CPN_Purchase_3, CPN_Barcode_3, CPN_Discount_4, CPN_Purchase_4, CPN_Barcode_4
from MKTCRM.Pom.TC_04_CPN2map_02_not_register 
WHERE sbl_member_id  not in(SELECT sbl_member_id FROM MKTCRM.Pom.TC_04_CPN2_all );



create VIEW Pom.TC_04_CPN2map_not_register_all AS
SELECT *
FROM MKTCRM.Pom.TC_04_cpn2map_04_not_register
UNION ALL
SELECT *
FROM MKTCRM.Pom.TC_04_CPN2map_06_not_register



create VIEW dbo.TC_04_CPN2map_not_register_all  as
select distinct a.*, language
from MKTCRM.dbo.TC_04_CPN2map_not_register_all a left join topssbl.dbo.sbl_customer b on a.sbl_member_id = b.sbl_member_id




CREATE VIEW Pom.TC_01_cusformat_T02 AS
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
ON a.SBL_MEMBER_id = b.SBL_Member_id ;

