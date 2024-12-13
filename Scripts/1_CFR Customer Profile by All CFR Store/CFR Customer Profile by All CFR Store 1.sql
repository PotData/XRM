/*DELETE ALL*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_sale_m;
/*DeleteByCondition*/
DELETE FROM MKTCRM.Ton1.CFR_CP_sale_m
WHERE period IN ('202406');


EXEC Ton1.CFR_CP_sale_m_yyyymm '202401';
EXEC Ton1.CFR_CP_sale_m_yyyymm '202402';
EXEC Ton1.CFR_CP_sale_m_yyyymm '202403';
EXEC Ton1.CFR_CP_sale_m_yyyymm '202404';
EXEC Ton1.CFR_CP_sale_m_yyyymm '202405';
EXEC Ton1.CFR_CP_sale_m_yyyymm '202406';


/*CREATE VIEW Ton1.CFR_CP_sale_m_period_storecode as
	select distinct period, st_code, store_format2, store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total,
				sum(total*1.0)/count(distinct sbl_member_id) as spending_head_month,
				sum(total*1.0)/sum(tx) as basket_size,
				sum(tx*1.0)/count(distinct sbl_member_id) as freq
	from MKTCRM.Ton1.CFR_CP_sale_m
	group by period, st_code, store_format2, store_name, store_location;*/


/*CREATE VIEW Ton1.CFR_CP_sale_m_storecode_sum1 as
	select distinct st_code, store_format2, store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from MKTCRM.Ton1.CFR_CP_sale_m
	group by st_code, store_format2, store_name, store_location;*/

TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_sale_m_storecode_sum;
INSERT INTO MKTCRM.Ton1.CFR_CP_sale_m_storecode_sum
(st_code, store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT 
    COALESCE(a.st_code, b.st_code) AS st_code,
    COALESCE(a.store_format2, b.store_format2) AS store_format2,
    COALESCE(a.store_name, b.store_name) AS store_name,
    COALESCE(a.store_location, b.store_location) AS store_location,
    a.tc, a.tx, a.quant, a.total, a.gp, a.net_total,
    AVG(b.freq) AS freq,
    AVG(b.spending_head_month) AS spending_head_month,
    AVG(b.basket_size) AS basket_size  
FROM 
    MKTCRM.Ton1.CFR_CP_sale_m_storecode_sum1 AS a
FULL OUTER JOIN 
    MKTCRM.Ton1.CFR_CP_sale_m_period_storecode AS b
ON 
    a.st_code = b.st_code 
    AND a.store_format2 = b.store_format2 
    AND a.store_name = b.store_name
    AND a.store_location = b.store_location
GROUP BY 
    COALESCE(a.st_code, b.st_code), COALESCE(a.store_format2, b.store_format2), COALESCE(a.store_name, b.store_name),
    COALESCE(a.store_location, b.store_location), a.tc, a.tx, a.quant, a.total, a.gp, a.net_total;

   

/*----------------------------------------- by store format & location --------------------------------------------------*/
/*CREATE VIEW Ton1.CFR_CP_sale_m_period_storeformat as
	select distinct period, store_format2, CONCAT('_', store_format2) as store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total,
				1.0*sum(total)/count(distinct sbl_member_id) as spending_head_month,
				1.0*sum(total)/sum(tx) as basket_size,
				1.0*sum(tx)/count(distinct sbl_member_id) as freq
	from MKTCRM.Ton1.CFR_CP_sale_m
	group by period, store_format2, CONCAT('_', store_format2), store_location;*/


/*CREATE view Ton1.CFR_CP_sale_m_storeformat_sum1 as
 	select distinct store_format2, CONCAT('_', store_format2) as store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from MKTCRM.Ton1.CFR_CP_sale_m 
	group by store_format2, CONCAT('_', store_format2), store_location;*/


TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_sale_m_storeformat_sum;
INSERT INTO MKTCRM.Ton1.CFR_CP_sale_m_storeformat_sum
(store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT 
    COALESCE(a.store_format2, b.store_format2) AS store_format2,
    COALESCE(a.store_name, b.store_name) AS store_name,
    COALESCE(a.store_location, b.store_location) AS store_location,
 	a.tc, a.tx, a.quant, a.total, a.gp, a.net_total,
 	avg(b.freq) as freq,
	avg(b.spending_head_month) as spending_head_month,
	avg(b.basket_size) as basket_size
FROM 
    MKTCRM.Ton1.CFR_CP_sale_m_storeformat_sum1 a
FULL OUTER JOIN 
    MKTCRM.Ton1.CFR_CP_sale_m_period_storeformat AS b ON a.store_format2 = b.store_format2 
    AND a.store_name = b.store_name
    AND a.store_location = b.store_location
GROUP BY COALESCE(a.store_format2, b.store_format2),
    COALESCE(a.store_name, b.store_name) ,
    COALESCE(a.store_location, b.store_location) ,
 	a.tc, a.tx, a.quant, a.total, a.gp, a.net_total;




/*combine*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_sale_m_summary;
INSERT INTO MKTCRM.Ton1.CFR_CP_sale_m_summary
(store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size
FROM (
    SELECT store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size
    FROM MKTCRM.Ton1.CFR_CP_sale_m_storecode_sum
    UNION ALL
    SELECT store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size
    FROM MKTCRM.Ton1.CFR_CP_sale_m_storeformat_sum
) AS combined_data;



/*mapping Profile*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_storecode_sbl_p;
INSERT INTO MKTCRM.Ton1.CFR_CP_storecode_sbl_p
(st_code, store_format2, store_name, store_location, sbl_member_id, olympic_segment, MARITAL_STATUS, age, Age_Range, Gender, Education_Level, MTHLY_INCOME, segment, CFR_COMPANY_RANK, CFG_Rank, Customer_Type, Generation, KIDS_STAGE, Occupation, BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT, FOOD_LUXURY_SEGMENT, PAYMENT_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel)
   SELECT DISTINCT 
    st_code, 
    store_format2, 
    store_name, 
    store_location, 
    a.sbl_member_id,
    CASE 
        WHEN olympic_segment = 'Diamond' THEN '01_Diamond'
        WHEN olympic_segment = 'Platinum' THEN '02_Platinum'
        WHEN olympic_segment = 'Gold' THEN '03_Gold'
        WHEN olympic_segment = 'Silver' THEN '04_Silver'
        WHEN olympic_segment = 'Bronze' THEN '05_Bronze'
        ELSE '99_Other'
    END AS olympic_segment, 
    MARITALSTATUS AS MARITAL_STATUS,
    age,
    CASE 
        WHEN age IS NULL THEN '99_Unknown'
        WHEN (age >= 0 AND age < 18) THEN '00_<18'
        WHEN age < 25 THEN '01_18-24'
        ELSE Age_Range 
    END AS Age_Range,
    CASE 
        WHEN Gender = 'F' THEN '01_Female'
        WHEN Gender = 'M' THEN '02_Male'
        ELSE '99_Other' 
    END AS Gender,
    CASE 
        WHEN Education_Level = 'Primary School' THEN '01_Primary School'
        WHEN Education_Level = 'Secondary School' THEN '02_Secondary School'
        WHEN Education_Level = 'College' THEN '03_College'
        WHEN Education_Level = 'Bachelor Degree' THEN '04_Bachelor Degree'
        WHEN Education_Level = 'Master Degree' THEN '05_Master Degree'
        WHEN Education_Level = 'Doctorate' THEN '06_Doctorate'
        ELSE '99_Other'
    END AS Education_Level,
    HH_Income AS MTHLY_INCOME,
    CONCAT(CAST(SEGMENT_no_gp_e AS VARCHAR(2)), '_', segment_gp_e) AS segment,
    CASE 
        WHEN CFR_COMPANY_RANK = 'TOP 1%' THEN '01_TOP 1%'
        WHEN CFR_COMPANY_RANK = 'TOP 2-10%' THEN '02_TOP 2-10%'
        WHEN CFR_COMPANY_RANK = 'TOP 11-20%' THEN '03_TOP 11-20%'
        WHEN CFR_COMPANY_RANK = 'TOP 21-40%' THEN '04_TOP 21-40%'
        WHEN CFR_COMPANY_RANK = 'TOP 41-60%' THEN '05_TOP 41-60%'
        WHEN CFR_COMPANY_RANK = 'TOP 61-80%' THEN '06_TOP 61-80%'
        WHEN CFR_COMPANY_RANK = 'Bottom 20%' THEN '07_Bottom 20%'
        WHEN CFR_COMPANY_RANK = 'Wholesale' THEN '08_Wholesale'
        ELSE '99_Other'
    END AS CFR_COMPANY_RANK,
    CASE 
        WHEN CFG_Rank = 'TOP 1%' THEN '01_TOP 1%'
        WHEN CFG_Rank = 'TOP 2-10%' THEN '02_TOP 2-10%'
        WHEN CFG_Rank = 'TOP 11-20%' THEN '03_TOP 11-20%'
        WHEN CFG_Rank = 'TOP 21-40%' THEN '04_TOP 21-40%'
        WHEN CFG_Rank = 'TOP 41-60%' THEN '05_TOP 41-60%'
        WHEN CFG_Rank = 'TOP 61-80%' THEN '06_TOP 61-80%'
        WHEN CFG_Rank = 'Bottom 20%' THEN '07_Bottom 20%'
        ELSE '99_Other'
    END AS CFG_Rank,
    Customer_Type,
    Generation,
    KIDS_STAGE,
    Occupation,
    CASE 
        WHEN BEAUTY_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN BEAUTY_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
        WHEN BEAUTY_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN BEAUTY_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN BEAUTY_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS BEAUTY_LUXURY_SEGMENT,
    BEAUTY_SEGMENT,
    CASE 
        WHEN ELECTRONICS_LUXURY_SEGMENT = 'LUXURY' THEN '01_LUXURY'
        WHEN ELECTRONICS_LUXURY_SEGMENT = 'UPPER MASS' THEN '02_UPPER MASS'
        WHEN ELECTRONICS_LUXURY_SEGMENT = 'MASS' THEN '03_MASS'
        ELSE '99_Other'
    END AS ELECTRONICS_LUXURY_SEGMENT,
    CASE 
        WHEN FASHION_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN FASHION_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
        WHEN FASHION_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN FASHION_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN FASHION_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS FASHION_LUXURY_SEGMENT,
  CASE 
        WHEN FOOD_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN FOOD_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
     WHEN FOOD_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN FOOD_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN FOOD_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS FOOD_LUXURY_SEGMENT,
    PAYMENT_SEGMENT,
    CASE 
        WHEN POINT_LOVER_SEGMENT = 'LOW' THEN '01_Low'
        WHEN POINT_LOVER_SEGMENT = 'MID' THEN '02_Mid'
        WHEN POINT_LOVER_SEGMENT = 'HIGH' THEN '03_High' 
        ELSE POINT_LOVER_SEGMENT 
    END AS POINT_LOVER_SEGMENT,
    WEALTH_SEGMENT,
    Flag_Omni_Channel
FROM 
    MKTCRM.Ton1.CFR_CP_sale_m  a
LEFT JOIN TOPSCRM.dbo.OLYMPIC_CFG_BY_BANNER b ON a.sbl_member_id = b.sbl_member_Id /*edit olympic*/
LEFT JOIN MKTCRM.dbo.crm_single_view_2409 e ON a.SBL_Member_ID = e.SBL_Member_ID /*edit Single view*/
WHERE 
    store_format2 IN ('Central Food Hall', 'TOPS MARKET', 'TOPS Fine Food', 'TOPS DAILY')
	AND DATA_PERIOD = '24Q2'   ;


/*table view*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_storecode_sbl_p_profile;
EXEC Ton1.CFR_CP_execute_S 'Age_Range','Age_Range';
EXEC Ton1.CFR_CP_execute_S 'Generation','Generation';
EXEC Ton1.CFR_CP_execute_S 'Marital_Status','MARITAL_STATUS';
EXEC Ton1.CFR_CP_execute_S 'Gender','Gender';
EXEC Ton1.CFR_CP_execute_S 'Occupation','Occupation';
EXEC Ton1.CFR_CP_execute_S 'Education','Education_Level';
EXEC Ton1.CFR_CP_execute_S 'Monthly_income','Mthly_Income';
EXEC Ton1.CFR_CP_execute_S 'Customer_Type','Customer_Type';
EXEC Ton1.CFR_CP_execute_S 'Segment','segment';
EXEC Ton1.CFR_CP_execute_S 'Wealth_Score','WEALTH_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Food_Luxury','FOOD_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Beauty_Segment','BEAUTY_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Beauty_Luxury_Segment','BEAUTY_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'CFR_Company_Rank','CFR_COMPANY_RANK';
EXEC Ton1.CFR_CP_execute_S 'CFG_Rank','CFG_Rank';
EXEC Ton1.CFR_CP_execute_S 'Electronics_Luxury_Segment','ELECTRONICS_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Fashion_Luxury_Segment','FASHION_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Payment_Segment','PAYMENT_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Kids_Stage','KIDS_STAGE';
EXEC Ton1.CFR_CP_execute_S 'Point_Lover_Segment','POINT_LOVER_SEGMENT';
EXEC Ton1.CFR_CP_execute_S 'Flag_Omni_Channel','Flag_Omni_Channel';
EXEC Ton1.CFR_CP_execute_S 'Olympic_Segment','olympic_segment';


TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_storecode_sbl_p_profile_2;
INSERT INTO MKTCRM.Ton1.CFR_CP_storecode_sbl_p_profile_2
(st_code, store_format2, store_name, store_location, [type], detail_type, SBL_Member_id)
select *
from MKTCRM.Ton1.CFR_CP_storecode_sbl_p_profile
where  [type] is not null 
		and detail_type is not null
		and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN',  '_');

		
/*by store format & location*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_storeformat_sbl_p;
INSERT INTO MKTCRM.Ton1.CFR_CP_storeformat_sbl_p
(store_format2, store_name, store_location, sbl_member_id, olympic_segment, MARITAL_STATUS, age, Age_Range, Gender, Education_Level, MTHLY_INCOME, segment, CFR_COMPANY_RANK, CFG_Rank, Generation, Occupation, CUSTOMER_TYPE, BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT, FOOD_LUXURY_SEGMENT, KIDS_STAGE, PAYMENT_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel)	
SELECT DISTINCT 
    store_format2, CONCAT('_', store_format2) AS store_name, store_location, sbl_member_id, olympic_segment, MARITAL_STATUS, 
    age, Age_Range, Gender, Education_Level, MTHLY_INCOME, segment, CFR_COMPANY_RANK, CFG_Rank, Generation, 
    Occupation, CUSTOMER_TYPE, BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT,
    FOOD_LUXURY_SEGMENT, KIDS_STAGE, PAYMENT_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel
FROM MKTCRM.Ton1.CFR_CP_storecode_sbl_p;
	

TRUNCATE TABLE  MKTCRM.Ton1.CFR_CP_storeformat_sbl_p_profile;
EXEC Ton1.CFR_CP_execute_storeformat 'Age_Range','Age_Range';
EXEC Ton1.CFR_CP_execute_storeformat 'Generation','Generation';
EXEC Ton1.CFR_CP_execute_storeformat 'Marital_Status','MARITAL_STATUS';
EXEC Ton1.CFR_CP_execute_storeformat 'Gender','Gender';
EXEC Ton1.CFR_CP_execute_storeformat 'Occupation','Occupation';
EXEC Ton1.CFR_CP_execute_storeformat 'Education','Education_Level';
EXEC Ton1.CFR_CP_execute_storeformat 'Monthly_income', 'Mthly_Income';
EXEC Ton1.CFR_CP_execute_storeformat 'Customer_Type', 'Customer_Type';
EXEC Ton1.CFR_CP_execute_storeformat 'Segment', 'segment';
EXEC Ton1.CFR_CP_execute_storeformat 'Wealth_Score', 'WEALTH_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Food_Luxury', 'FOOD_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Beauty_Segment', 'BEAUTY_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Beauty_Luxury_Segment', 'BEAUTY_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'CFR_Company_Rank', 'CFR_COMPANY_RANK';
EXEC Ton1.CFR_CP_execute_storeformat 'CFG_Rank','CFG_Rank';
EXEC Ton1.CFR_CP_execute_storeformat 'Electronics_Luxury_Segment', 'ELECTRONICS_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Fashion_Luxury_Segment', 'FASHION_LUXURY_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Payment_Segment', 'PAYMENT_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Kids_Stage','KIDS_STAGE';
EXEC Ton1.CFR_CP_execute_storeformat 'Point_Lover_Segment','POINT_LOVER_SEGMENT';
EXEC Ton1.CFR_CP_execute_storeformat 'Flag_Omni_Channel', 'Flag_Omni_Channel';
EXEC Ton1.CFR_CP_execute_storeformat 'Olympic_Segment','olympic_segment';


TRUNCATE TABLE  Ton1.CFR_CP_storeformat_sbl_p_profile_2; 
INSERT INTO MKTCRM.Ton1.CFR_CP_storeformat_sbl_p_profile_2
(st_code, store_format2, store_name, store_location, [type], detail_type, SBL_Member_id)
select *
from MKTCRM.Ton1.CFR_CP_storeformat_sbl_p_profile
where type is not null 
			and detail_type is not null
			and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN', '_');


/*combine*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_profile_summary;
INSERT INTO MKTCRM.Ton1.CFR_CP_profile_summary
(st_code, store_format2, store_name, store_location, [Type], detail_Type, SBL_Member_id)
SELECT *
FROM (
    SELECT *
    FROM MKTCRM.Ton1.CFR_CP_storecode_sbl_p_profile_2

    UNION ALL

    SELECT *
    FROM MKTCRM.Ton1.CFR_CP_storeformat_sbl_p_profile_2
) AS combined_data;


/*by store format*/
SELECT store_format2, [Type], detail_Type, SBL_Member_id
FROM MKTCRM.Ton1.CFR_CP_storeformat_sbl_p2_profile;

/*-- Ton1.CFR_CP_storeformat_sbl_p2_profile_2 source

create VIEW Ton1.CFR_CP_storeformat_sbl_p2_profile_2  as
select *
from MKTCRM.Ton1.CFR_CP_storeformat_sbl_p2_profile
where type is not null 
		and detail_type is not null
		and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN', '_')
	;*/


/*mapping home address*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_sale_m_sbl_hmaddr;
INSERT INTO MKTCRM.Ton1.CFR_CP_sale_m_sbl_hmaddr
(st_code, store_format2, store_name, store_location, home_subdistrict, home_district, home_city, tc, tx, quant, total, gp, net_total)
SELECT 
    st_code, store_format2, store_name, store_location, b.home_subdistrict, b.home_district, b.home_city,
    COUNT(DISTINCT a.sbl_member_id) AS tc,      
    SUM(a.tx) AS tx,                             
    SUM(a.quant) AS quant,                       
    SUM(a.total) AS total,                       
    SUM(a.GP) AS gp,                             
    SUM(a.net_total) AS net_total     
FROM 
    MKTCRM.Ton1.CFR_CP_sale_m AS a
LEFT JOIN 
    cfhqsasdidb01.topssbl.dbo.sbl_customer AS b
ON 
    a.sbl_member_id = b.sbl_member_id
GROUP BY 
    st_code, store_format2, store_name, store_location, b.home_subdistrict, b.home_district, b.home_city;

/*-------------------------------------------------------------------------------------------------------------------*/
/*DELETE ALL*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_B2_sale_m;
/*DeleteByCondition*/
DELETE FROM MKTCRM.Ton1.CFR_CP_B2_sale_m
WHERE period IN ('202406');


EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202401'
EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202402'
EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202403'
EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202404'
EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202405'
EXEC Ton1.CFR_CP_b2_store_m_yyyymm '202406'



/*Penetration by store code*/
/*table view*/
SELECT st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc, tc
FROM MKTCRM.Ton1.CFR_CP_sale_m_subdept_st_code;


SELECT store_format2, store_location, tc
FROM MKTCRM.Ton1.CFR_CP_sale_m_ccard;

/*Penetration by store format & location*/
SELECT st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc, tc
FROM MKTCRM.Ton1.CFR_CP_sale_m_subdept_st_format;

/*Combine*/
TRUNCATE TABLE MKTCRM.Ton1.CFR_CP_subdept_summary;

INSERT INTO MKTCRM.Ton1.CFR_CP_subdept_summary
(st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc, tc)
SELECT *
FROM (
    SELECT *
    FROM  MKTCRM.Ton1.CFR_CP_sale_m_subdept_st_code

    UNION ALL

    SELECT *
    FROM  MKTCRM.Ton1.CFR_CP_sale_m_subdept_st_format
) AS combined_data;
