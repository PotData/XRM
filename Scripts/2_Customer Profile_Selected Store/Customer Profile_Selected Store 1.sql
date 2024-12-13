--ลบข้อมูลในตาราง
TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sales ;
--TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_202408;

--*****
/*Customer Profile - Selected Store - Example for Atore A*/
--***** Change Store code if needed (Procedures:EXECUTE_SALE_TRANS_ALL) /
EXEC Ton1.CP_Store_A '202408', ' ''540'' ', '20240801', '20240831';
EXEC Ton1.CP_Store_A '202409', ' ''540'' ', '20240901', '20240930';
EXEC Ton1.CP_Store_A '202410', ' ''540'' ', '20241001', '20241031';



/*-------------------------------------------- mapping member -----------------------------------------------*/
/*CREATE VIEW [Ton1].[CP_Store_A_sales_m] AS   
SELECT DISTINCT L.*
FROM MKTCRM.Ton1.CP_Store_A_sales L
WHERE L.sbl_member_id IS NOT NULL
AND L.sbl_member_id NOT IN ('9-014342304', '9-014223414', '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999');*/

/*---------------------------------------- summary by period -----------------------------------------------*/
/*CREATE View Ton1.CP_Store_A_sales_m_period as
	select distinct period, Site,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx, 
				sum(QTY) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total,
				sum(total)/count(distinct sbl_member_id) as spending_head,
				sum(total)/count(distinct ref_key) as basket_size,
				CAST(COUNT(DISTINCT ref_key) AS FLOAT) / CAST(COUNT(DISTINCT sbl_member_id) AS FLOAT) AS freq -- ทศนิยม
	from Ton1.CP_Store_A_sales_m
	group by period, Site;*/


/* summary total */
/*create View Ton1.CP_Store_A_sales_m_sum1 as
	select distinct Site, 
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx, 
				sum(QTY) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from Ton1.CP_Store_A_sales_m
	group by Site;*/

TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sales_m_sum;
INSERT INTO MKTCRM.Ton1.CP_Store_A_sales_m_sum
(Site, tc, tx, quant, total, gp, net_total, spending_head, basket_size, freq)
SELECT 
    a.Site, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total,
    AVG(1.0*b.spending_head) AS spending_head,
    AVG(1.0*b.basket_size) AS basket_size,
    CAST(AVG(b.freq) AS FLOAT) AS freq  
INTO Ton1.CP_Store_A_sales_m_sum
FROM MKTCRM.Ton1.CP_Store_A_sales_m_sum1 a
FULL OUTER JOIN MKTCRM.Ton1.CP_Store_A_sales_m_period b ON a.Site = b.Site
GROUP BY  a.Site, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total;
   


/*------------------------------- Olympic All Segment CFG FY23 --------------------------------------------*/
-- ยุบ A3.Store_A_sbl ใน MKTCRM.Ton1.CP_Store_A_sbl_os ดึงข้อมูล MKTCRM.Ton1.CP_olympic_24q2
--**** edit olympic
TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sbl_os;
INSERT INTO MKTCRM.Ton1.CP_Store_A_sbl_os
(Site, sbl_member_id, olympic_cfg)
SELECT DISTINCT a.*, b.hm_segment AS olympic_cfg
FROM  
  (SELECT DISTINCT Site, sbl_member_id FROM MKTCRM.Ton1.CP_Store_A_sales_m) a
LEFT JOIN MKTCRM.dbo.olympic_cfg_fy23_new2 b
  ON a.sbl_member_id = b.sbl_member_Id;

/*------------------------------------- Map Profile  ------------------------------------------------------ */
/* สร้างเปํน TABLE VIEW MKTCRM.Ton1.CP_Store_A_sbl_os_p  ดึงข้อมูลมาจาก crm_single_view_24q2*/
--**** edit Single view
TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sbl_os_p; 
INSERT INTO MKTCRM.Ton1.CP_Store_A_sbl_os_p
(Site, sbl_member_id, olympic_cfg, MARITAL_STATUS, age, Age_Range, Gender, Education_Level, MTHLY_INCOME, customer_type, segment, CFR_COMPANY_RANK, CG_RANKING_2023, CFG_Rank, Generation, KIDS_STAGE, Occupation, BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT, FOOD_LUXURY_SEGMENT, PAYMENT_SEGMENT, PET_LOVER_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel)
select distinct a.*, MARITALSTATUS as MARITAL_STATUS,age,
       case 
           when age is null Then '99_Unknown'
           when (age >= 0 and age <18) then  '00_<18'
           when age <25 then  '01_18-24'
       else Age_Range 
       end as Age_Range,
       case
           when Gender = 'F' then '01_Female'
           when Gender = 'M' then '02_Male'
       else '00_Other' 
       end as Gender,
       Education_Level,
       HH_Income as MTHLY_INCOME,
       customer_type,
       CONCAT(FORMAT(SEGMENT_no_gp_e, '00'), '_', segment_gp_e) AS segment,
       CFR_COMPANY_RANK,
       CG_RANKING_2023,
       CFG_Rank,
       Generation,
       KIDS_STAGE,
       Occupation,
       BEAUTY_LUXURY_SEGMENT,
       BEAUTY_SEGMENT,
       ELECTRONICS_LUXURY_SEGMENT,
       FASHION_LUXURY_SEGMENT,
       FOOD_LUXURY_SEGMENT,
       PAYMENT_SEGMENT,
       PET_LOVER_SEGMENT,
       POINT_LOVER_SEGMENT,
       WEALTH_SEGMENT,
       Flag_Omni_Channel 
from MKTCRM.Ton1.CP_Store_A_sbl_os a
left join MKTCRM.dbo.crm_single_view_2409 e /*edit Single view*/
on a.sbl_member_id = e.sbl_member_id;


TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sbl_os_p_profile
EXEC Ton1.CP_execute_S 'Age_Range','Age_Range';
EXEC Ton1.CP_execute_S 'Generation','Generation';
EXEC Ton1.CP_execute_S 'MARITAL_STATUS','MARITAL_STATUS';
EXEC Ton1.CP_execute_S 'Gender','Gender';
EXEC Ton1.CP_execute_S 'Occupation','Occupation';
EXEC Ton1.CP_execute_S 'Education','Education_Level';
EXEC Ton1.CP_execute_S 'Monthlyincome','Mthly_Income';
EXEC Ton1.CP_execute_S 'CUSTOMER_TYPE','Customer_Type';
EXEC Ton1.CP_execute_S 'segment','segment';
EXEC Ton1.CP_execute_S 'WEALTH_SCORE','WEALTH_SEGMENT';
EXEC Ton1.CP_execute_S 'FOOD_LUXURY','FOOD_LUXURY_SEGMENT';
EXEC Ton1.CP_execute_S 'BEAUTY_SEGMENT','BEAUTY_SEGMENT';
EXEC Ton1.CP_execute_S 'BEAUTY_LUXURY_SEGMENT','BEAUTY_LUXURY_SEGMENT';
EXEC Ton1.CP_execute_S 'CFR_COMPANY_RANK','CFR_COMPANY_RANK';
EXEC Ton1.CP_execute_S 'CFG_Rank','CFG_Rank';
EXEC Ton1.CP_execute_S 'ELECTRONICS_LUXURY_SEGMENT','ELECTRONICS_LUXURY_SEGMENT';
EXEC Ton1.CP_execute_S 'FASHION_LUXURY_SEGMENT','FASHION_LUXURY_SEGMENT';
EXEC Ton1.CP_execute_S 'PAYMENT_SEGMENT','PAYMENT_SEGMENT';
EXEC Ton1.CP_execute_S 'KIDS_STAGE','KIDS_STAGE';
EXEC Ton1.CP_execute_S 'POINT_LOVER_SEGMENT','POINT_LOVER_SEGMENT';
EXEC Ton1.CP_execute_S 'PET_LOVER_SEGMENT','PET_LOVER_SEGMENT';
EXEC Ton1.CP_execute_S 'Flag_Omni_Channel','Flag_Omni_Channel';
EXEC Ton1.CP_execute_S 'olympic_cfg','olympic_cfg';

SELECT  type, detail_type, SBL_Member_id
FROM MKTCRM.Ton1.CP_Store_A_sbl_os_p_profile;

/*----------------------------------------------- Penetration -----------------------------------------------*/
/*สร้างเปํน TABLE VIEW MKTCRM.Ton1.CP_Store_A_sales_m_subdept */
	TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_sales_m_subdept;
	INSERT INTO MKTCRM.Ton1.CP_Store_A_sales_m_subdept
	(Site, subdept_code, subdept_eng_desc, tc, tx, quant, total, gp, net_total)
	select distinct Site, subdept_code, subdept_eng_desc,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx, 
				sum(QTY) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	INTO MKTCRM.Ton1.CP_Store_A_sales_m_subdept
	from MKTCRM.Ton1.CP_Store_A_sales_m
	group by Site, subdept_code, subdept_eng_desc;
/*------------------------------------------------------Tx - All - G--------------------------------------------*/
TRUNCATE TABLE MKTCRM.Ton1.CP_sales_gtx;
INSERT INTO MKTCRM.Ton1.CP_sales_gtx
(tx, quant, total, gp, net_total)
select count(distinct ref_key) as tx, 
	    sum(QTY) as quant, 
		sum(total)as total, 
		sum(GP) as gp, 
		sum(net_total) as net_total
INTO MKTCRM.Ton1.CP_sales_gtx				
from  MKTCRM.Ton1.CP_Store_A_sales_m;

/*------------------------------------------Group by Customers------------------------------------------------*/
/*create VIEW Ton1.CP_sales_m_g as
	select distinct Site, sbl_member_id,
				count(distinct ref_key) as tx, 
				sum(QTY) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from CP_Store_A_sales_m
	group by Site, sbl_member_id
	;*/

/*create VIEW Ton1.CP_sales_m_g_f as 
	select a.*, home_subdistrict, home_district, home_city
	from  MKTCRM.Ton1.CP_sales_m_g as a
	left join cfhqsasdidb01.topssbl.dbo.SBL_CUSTOMER as b
	on a.sbl_member_id = b.sbl_member_Id;*/


/*create VIEW Ton1.CP_sales_m_g_f_c as
	select distinct home_subdistrict,
                count (distinct sbl_member_id) as No_id,
				sum(tx) as tx, 
				sum(total)as total, 
				sum(net_total) as net_total,
				sum(GP) as gp 
	from MKTCRM.Ton1.CP_sales_m_g_f
	group by home_subdistrict;*/

TRUNCATE TABLE MKTCRM.Ton1.CP_sales_m_g_f_cok;
INSERT INTO MKTCRM.Ton1.CP_sales_m_g_f_cok
(No_id, tx, total, net_total, gp)
select count (distinct sbl_member_id) as No_id,
			sum(tx) as tx, 
			sum(total)as total, 
			sum(net_total) as net_total,
			sum(GP) as gp 			
from MKTCRM.Ton1.CP_sales_m_g_f;
 /*------------------------------------------------- Map expat ----------------------------------------------*/
/*CREATE VIEW Ton1.CP_Store_A_SBL_f AS
select distinct A.*,Nationality_cd,
case when B.Nationality_cd not in ('THA') 
or B.Nationality_cd is null
Then 'Expat'
else 'Thai' end as Flag_Expat
from (select distinct Site, sbl_member_id from MKTCRM.Ton1.CP_Store_A_sales_m ) A
left join cfhqsasdidb01.topssbl.dbo.sbl_customer B
on A.sbl_member_id = B.sbl_member_id;*/


-- dbo.Store_A_SBL_f_expat_cd_c ยุบรวม A3.Store_A_SBL_f_expat, A3.Store_A_SBL_f_expat_cd
TRUNCATE TABLE MKTCRM.Ton1.CP_Store_A_SBL_f_c;
INSERT INTO MKTCRM.Ton1.CP_Store_A_SBL_f_c (Flag_Expat, No_id)
SELECT 
    B.Nationality_cd,
    COUNT(DISTINCT A.sbl_member_id) AS No_id
FROM MKTCRM.Ton1.CP_Store_A_SBL_f AS A
LEFT JOIN cfhqsasdidb01.topssbl.dbo.sbl_customer AS B
    ON A.sbl_member_id = B.sbl_member_id
WHERE 
    A.Flag_Expat = 'Expat'
GROUP BY 
    B.Nationality_cd;
   

TRUNCATE TABLE  MKTCRM.Ton1.CP_Store_A_SBL_f_c;
INSERT INTO MKTCRM.Ton1.CP_Store_A_SBL_f_c
(Flag_Expat, No_id)
select distinct A.Flag_Expat, count(distinct sbl_member_id) as No_id
from MKTCRM.Ton1.CP_Store_A_SBL_f  A
group by Flag_Expat;



