CREATE TABLE MKTCRM.Ton1.CP_Store_A_sales (
		period VARCHAR(6),
		SBL_MEMBER_ID VARCHAR(30),
		TRN_DTE VARCHAR(10),
		REF_KEY VARCHAR(50),
		SUBDEPT_CODE VARCHAR(4),
		SUBDEPT_ENG_DESC VARCHAR(100),
		QTY MONEY,
		TOTAL MONEY,
		NET_TOTAL MONEY, 
		GP MONEY, 
		Site VARCHAR(100)
        );
        
/*---------------------------------------  Store_A_sales_m  -------------------------------------------*/
CREATE VIEW dbo.Store_A_sales_m AS   
SELECT DISTINCT L.*
FROM MKTCRM.dbo.Store_A_sales AS L
WHERE L.sbl_member_id IS NOT NULL
AND L.sbl_member_id NOT IN ('9-014342304', '9-014223414', '9-014511211', '9-014493473', '9-014234126', '9-014651449', '9999999999');      
       
       
/*------------------------------------------  summary total ------------------------------------------------*/
	CREATE VIEW Ton1.Store_A_sales_m_sum AS
	WITH Aggregates AS (
    SELECT 
        Site,
        COUNT(DISTINCT sbl_member_id) AS tc,
        COUNT(DISTINCT ref_key) AS tx,
        SUM(QTY) AS quant,
        SUM(total) AS total,
        SUM(GP) AS gp,
        SUM(net_total) AS net_total
    FROM MKTCRM.Ton1.CP_Store_A_sales_m
    GROUP BY Site
	)
	SELECT 
    	Site,
    	tc,
    	tx,
    	quant,
    	total,
    	gp,
    	net_total,
    	total / NULLIF(tc, 0) AS spending_head,
    	total / NULLIF(tx, 0) AS basket_size,
    	tx / NULLIF(tc, 0) AS freq
	FROM Aggregates;

/*------------------------------------ MKTCRM.dbo.Store_A_SBL_f -----------------------------------------------------------*/
CREATE VIEW Ton1.CP_Store_A_SBL_f AS
select distinct A.*,
case when B.Nationality_cd not in ('THA') 
or B.Nationality_cd in ('')
Then 'Expat'
else 'Thai' end as Flag_Expat
from (select distinct Site, sbl_member_id from MKTCRM.Ton1.CP_Store_A_sales_m ) A
left join cfhqsasdidb01.topssbl.dbo.sbl_customer B
on A.sbl_member_id = B.sbl_member_id;


------------ ยุบรวมกระบวนการทั้งหมดเป็น SELECT เดียว ยุบรวม A3.Store_A_SBL_f_expat, A3.Store_A_SBL_f_expat_cd ------------------------
CREATE VIEW Ton1.CP_Store_A_SBL_f_expat_cd_c AS
SELECT 
    B.Nationality_cd,
    COUNT(DISTINCT A.sbl_member_id) AS No_id
FROM MKTCRM.Ton1.CP_Store_A_SBL_f AS A
LEFT JOIN cfhqsasdidb01.topssbl.dbo.sbl_customer AS B
    ON A.sbl_member_id = B.sbl_member_id
WHERE 
    A.Flag_Expat = 'Expat'
GROUP BY 
    B.Nationality_cd

------------------------- สร้างเปํน TABLE VIEW Store_A_SBL_f_c-------------------------------------------------------------
CREATE VIEW Ton1.CP_Store_A_SBL_f_c as
select distinct A.Flag_Expat, count(distinct sbl_member_id) as No_id
from MKTCRM.Ton1.CP_Store_A_SBL_f  A
group by Flag_Expat

    
/*--------------------------------------- Store_A_sbl_os_p  -------------------------------------------------------*/
CREATE VIEW dbo.Store_A_sbl_os_p as
           select distinct a.*,
                MARITALSTATUS   as MARITAL_STATUS,age,
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
     from MKTCRM.dbo.Store_A_sbl_os a
	 left join MKTCRM.dbo.crm_single_view_24q2 e /*edit Single view*/
     on a.sbl_member_id = e.sbl_member_id
     ;
     
/*-------------------------- Store_A_sbl_os_p_profile  -------------------------------------------------------------*/
  /*  create table MKTCRM.dbo.Store_A_sbl_os_p_profile(
	Type VARCHAR(30),
	detail_Type VARCHAR(30),
	SBL_Member_id INT
	);*/
create VIEW dbo.Store_A_sbl_os_p_profile AS    
SELECT 
    Site,
    'Age_Range' AS Type,
    Age_Range AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Age_Range
UNION ALL
SELECT 
     Site,
     'Generation' AS Type,
     Generation AS detail_Type,
     COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Generation
UNION ALL
SELECT 
      Site,
      'MARITAL_STATUS' AS Type,
      MARITAL_STATUS AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, MARITAL_STATUS
UNION ALL
SELECT 
      Site,
      'Gender' AS Type,
      Gender AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Gender
UNION ALL
SELECT 
     Site,
     'Occupation' AS Type,
     Occupation AS detail_Type,
     COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Occupation
UNION ALL
SELECT 
      Site,
      'Education' AS Type,
      Education_Level AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Education_Level
UNION ALL
SELECT 
      Site,
      'Monthlyincome' AS Type,
      Mthly_Income AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Mthly_Income
UNION ALL
SELECT 
      Site,
      'CUSTOMER_TYPE' AS Type,
      Customer_Type AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Customer_Type
UNION ALL
SELECT 
      Site,
      'segment' AS Type,
      segment AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, segment
UNION ALL
SELECT 
      Site,
      'WEALTH_SCORE' AS Type,
      WEALTH_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, WEALTH_SEGMENT
UNION ALL
SELECT 
      Site,
      'FOOD_LUXURY' AS Type,
      FOOD_LUXURY_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, FOOD_LUXURY_SEGMENT
UNION ALL
SELECT 
      Site,
      'BEAUTY_SEGMENT' AS Type,
      BEAUTY_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, BEAUTY_SEGMENT
UNION ALL
SELECT 
      Site,
      'BEAUTY_LUXURY_SEGMENT' AS Type,
      BEAUTY_LUXURY_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, BEAUTY_LUXURY_SEGMENT
UNION ALL
SELECT 
      Site,
      'CFR_COMPANY_RANK' AS Type,
      CFR_COMPANY_RANK AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, CFR_COMPANY_RANK
UNION ALL
SELECT 
      Site,
      'CFG_Rank' AS Type,
      CFG_Rank AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, CFG_Rank
UNION ALL
SELECT 
      Site,
      'ELECTRONICS_LUXURY_SEGMENT' AS Type,
      ELECTRONICS_LUXURY_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, ELECTRONICS_LUXURY_SEGMENT
UNION ALL
SELECT 
      Site,
      'FASHION_LUXURY_SEGMENT' AS Type,
      FASHION_LUXURY_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, FASHION_LUXURY_SEGMENT
UNION ALL
SELECT 
      Site,
      'PAYMENT_SEGMENT' AS Type,
      PAYMENT_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, PAYMENT_SEGMENT
UNION ALL
SELECT 
      Site,
      'KIDS_STAGE' AS Type,
      KIDS_STAGE AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, KIDS_STAGE
UNION ALL
SELECT 
      Site,
      'POINT_LOVER_SEGMENT' AS Type,
      POINT_LOVER_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, POINT_LOVER_SEGMENT
UNION ALL
SELECT 
      Site,
      'PET_LOVER_SEGMENT' AS Type,
      PET_LOVER_SEGMENT AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, PET_LOVER_SEGMENT
UNION ALL
SELECT 
      Site,
      'Flag_Omni_Channel' AS Type,
      Flag_Omni_Channel AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, Flag_Omni_Channel
UNION ALL
SELECT 
      Site,
      'olympic_cfg' AS Type,
      olympic_cfg AS detail_Type,
      COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM MKTCRM.dbo.Store_A_sbl_os_p a
GROUP BY Site, olympic_cfg;


/*----------------------------------------------- Penetration ----------------------------*/
	create VIEW dbo.Store_A_sales_m_subdept as
	select distinct Site, subdept_code, subdept_eng_desc,
				count(distinct sbl_member_id) as tc,
				count(distinct ref_key) as tx, 
				sum(QTY) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from MKTCRM.dbo.Store_A_sales_m
	group by Site, subdept_code, subdept_eng_desc;

