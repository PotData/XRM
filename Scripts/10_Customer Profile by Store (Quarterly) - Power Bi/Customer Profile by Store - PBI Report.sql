/*Customer Profile by Store - Report on Power BI*/


/*Map Sales*/
/*by Store Code*/
/*Month 7-9*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m;

EXEC Ton1.CPS_BI_sale_m_yyyymm '202407';
EXEC Ton1.CPS_BI_sale_m_yyyymm '202408';
EXEC Ton1.CPS_BI_sale_m_yyyymm '202409';
EXEC Ton1.CPS_BI_sale_m_CFM_yyyymm '202407';
EXEC Ton1.CPS_BI_sale_m_CFM_yyyymm '202408';
EXEC Ton1.CPS_BI_sale_m_CFM_yyyymm '202409';


/*table summary*/
/*by store*/
/*	create VIEW Ton1.CPS_BI_sale_m_period_storecode as
	select distinct period, st_code, store_format2, store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(gp) as gp, 
				sum(net_total) as net_total,
				sum(total*1.0)/count(distinct sbl_member_id) as spending_head_month,
				sum(total*1.0)/sum(tx) as basket_size,
				sum(tx*1.0)/count(distinct sbl_member_id) as freq
	from Ton1.CPS_BI_sale_m
	group by period, st_code, store_format2, store_name, store_location;*/


/*	create view Ton1.CPS_BI_sale_m_storecode_sum1 as
	select distinct st_code, store_format2, store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from Ton1.CPS_BI_sale_m
	group by st_code, store_format2, store_name, store_location;*/

TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m_storecode_sum;
INSERT INTO MKTCRM.Ton1.CPS_BI_sale_m_storecode_sum
(st_code, store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT 
    a.st_code, a.store_format2, a.store_name, a.store_location, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total,
    AVG(b.freq) AS freq,
    AVG(b.spending_head_month) AS spending_head_month,
    AVG(b.basket_size) AS basket_size 
FROM Ton1.CPS_BI_sale_m_storecode_sum1 a
FULL OUTER JOIN Ton1.CPS_BI_sale_m_period_storecode b
ON a.st_code = b.st_code
   AND a.store_format2 = b.store_format2
   AND a.store_name = b.store_name
   AND a.store_location = b.store_location
GROUP BY 
    a.st_code, a.store_format2, a.store_name, a.store_location, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total;



/*by store format & location*/
/*CREATE VIEW Ton1.CPS_BI_sale_m_period_storeformat AS
SELECT DISTINCT period, store_format2, CONCAT('_', store_format2) AS store_name, store_location,COUNT(DISTINCT sbl_member_id) AS tc,
    SUM(tx) AS tx, 
    SUM(quant) AS quant, 
    SUM(total) AS total, 
    SUM(GP) AS gp, 
    SUM(net_total) AS net_total,
    SUM(total * 1.0) / COUNT(DISTINCT sbl_member_id) AS spending_head_month,
    SUM(total * 1.0) / SUM(tx) AS basket_size,
    SUM(tx * 1.0) / COUNT(DISTINCT sbl_member_id) AS freq
FROM Ton1.CPS_BI_sale_m
GROUP BY period, store_format2, CONCAT('_', store_format2), store_location;*/


/*	create View Ton1.CPS_BI_sale_m_storeformat_sum1 as
	select distinct store_format2, CONCAT('_', store_format2) as store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from Ton1.CPS_BI_sale_m
	group by store_format2, CONCAT('_', store_format2), store_location;*/

TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m_storeformat_sum;
INSERT INTO MKTCRM.Ton1.CPS_BI_sale_m_storeformat_sum
(store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT a.store_format2, a.store_name, a.store_location, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total,
	avg(b.freq) as freq,
	avg(b.spending_head_month) as spending_head_month,
	avg(b.basket_size) as basket_size
FROM Ton1.CPS_BI_sale_m_storeformat_sum1 a
FULL OUTER JOIN Ton1.CPS_BI_sale_m_period_storeformat b
ON a.store_format2 = b.store_format2
   AND a.store_name = b.store_name
   AND a.store_location = b.store_location
GROUP BY a.store_format2, a.store_name, a.store_location, a.tc, a.tx, a.quant, a.total, a.gp, a.net_total;


/*combine*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m_summary;
INSERT INTO MKTCRM.Ton1.CPS_BI_sale_m_summary
(store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size)
SELECT store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size
FROM Ton1.CPS_BI_sale_m_storecode_sum
UNION ALL
SELECT store_format2, store_name, store_location, tc, tx, quant, total, gp, net_total, freq, spending_head_month, basket_size
FROM Ton1.CPS_BI_sale_m_storeformat_sum;



/*mapping Profile*/
/*	create VIEW Ton1.CPS_BI_storecode_sbl as
	select distinct st_code, store_format2, store_name, store_location, sbl_member_id
	from Ton1.CPS_BI_sale_m;*/

/*CFH*//*TM*//*TFF*//*CFM*/
/*	create VIEW Ton1.CPS_BI_storecode_sbl_cfh as
	select distinct st_code, store_format2, store_name, store_location, a.sbl_member_id, olympic_segment
	from Ton1.CPS_BI_storecode_sbl as a
	left join cfhqsasdidb01.topscrm.dbo.OLYMPIC_CFG_BY_BANNER as b /*edit olympic*/
	on a.sbl_member_id = b.sbl_member_Id
	where store_format2 in ('Central Food Hall','TOPS MARKET','TOPS Fine Food','CFM')
	and b.data_period in ('24Q3')
	and b.store_format in ('Central Food Hall','TOPS MARKET','Family Mart');*/

TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_storecode_sbl_p;
INSERT INTO MKTCRM.Ton1.CPS_BI_storecode_sbl_p
(st_code, store_format2, store_name, store_location, sbl_member_id, olympic_segment, MARITAL_STATUS, age, Age_Range, Gender, Education_Level, MTHLY_INCOME, segment, CFR_COMPANY_RANK, CFG_Rank, Customer_Type, Generation, KIDS_STAGE, Occupation, BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT, FOOD_LUXURY_SEGMENT, PAYMENT_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel)
SELECT DISTINCT 
    a.st_code, a.store_format2, a.store_name, a.store_location, a.sbl_member_id,
    CASE 
        WHEN olympic_segment = 'Diamond' THEN '01_Diamond'
        WHEN olympic_segment = 'Platinum' THEN '02_Platinum'
        WHEN olympic_segment = 'Gold' THEN '03_Gold'
        WHEN olympic_segment = 'Silver' THEN '04_Silver'
        WHEN olympic_segment = 'Bronze' THEN '05_Bronze'
        ELSE '99_Other'
    END AS olympic_segment, 
    e.MARITALSTATUS AS MARITAL_STATUS,e.age,
    CASE 
        WHEN e.age IS NULL THEN '99_Unknown'
        WHEN e.age >= 0 AND e.age < 18 THEN '00_<18'
        WHEN e.age < 25 THEN '01_18-24'
        ELSE e.Age_Range 
    END AS Age_Range,
    CASE 
        WHEN e.Gender = 'F' THEN '01_Female'
        WHEN e.Gender = 'M' THEN '02_Male'
        ELSE '99_Other' 
    END AS Gender,
    CASE 
        WHEN e.Education_Level = 'Primary School' THEN '01_Primary School'
        WHEN e.Education_Level = 'Secondary School' THEN '02_Secondary School'
        WHEN e.Education_Level = 'College' THEN '03_College'
        WHEN e.Education_Level = 'Bachelor Degree' THEN '04_Bachelor Degree'
        WHEN e.Education_Level = 'Master Degree' THEN '05_Master Degree'
        WHEN e.Education_Level = 'Doctorate' THEN '06_Doctorate'
        ELSE '99_Other'
    END AS Education_Level,
    e.HH_Income AS MTHLY_INCOME,
    CAST(e.SEGMENT_no_gp_e AS VARCHAR(2)) + '_' + e.segment_gp_e AS segment,
    CASE 
        WHEN e.CFR_COMPANY_RANK = 'TOP 1%' THEN '01_TOP 1%'
        WHEN e.CFR_COMPANY_RANK = 'TOP 2-10%' THEN '02_TOP 2-10%'
        WHEN e.CFR_COMPANY_RANK = 'TOP 11-20%' THEN '03_TOP 11-20%'
        WHEN e.CFR_COMPANY_RANK = 'TOP 21-40%' THEN '04_TOP 21-40%'
        WHEN e.CFR_COMPANY_RANK = 'TOP 41-60%' THEN '05_TOP 41-60%'
        WHEN e.CFR_COMPANY_RANK = 'TOP 61-80%' THEN '06_TOP 61-80%'
        WHEN e.CFR_COMPANY_RANK = 'Bottom 20%' THEN '07_Bottom 20%'
        WHEN e.CFR_COMPANY_RANK = 'Wholesale' THEN '08_Wholesale'
        ELSE '99_Other'
    END AS CFR_COMPANY_RANK,
    CASE 
        WHEN e.CFG_Rank = 'TOP 1%' THEN '01_TOP 1%'
        WHEN e.CFG_Rank = 'TOP 2-10%' THEN '02_TOP 2-10%'
        WHEN e.CFG_Rank = 'TOP 11-20%' THEN '03_TOP 11-20%'
        WHEN e.CFG_Rank = 'TOP 21-40%' THEN '04_TOP 21-40%'
        WHEN e.CFG_Rank = 'TOP 41-60%' THEN '05_TOP 41-60%'
        WHEN e.CFG_Rank = 'TOP 61-80%' THEN '06_TOP 61-80%'
        WHEN e.CFG_Rank = 'Bottom 20%' THEN '07_Bottom 20%'
        ELSE '99_Other'
    END AS CFG_Rank, 
    e.Customer_Type, e.Generation, e.KIDS_STAGE, e.Occupation,
    CASE 
        WHEN e.BEAUTY_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN e.BEAUTY_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
        WHEN e.BEAUTY_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN e.BEAUTY_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN e.BEAUTY_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS BEAUTY_LUXURY_SEGMENT,
    e.BEAUTY_SEGMENT,
    CASE 
        WHEN e.ELECTRONICS_LUXURY_SEGMENT = 'LUXURY' THEN '01_LUXURY'
        WHEN e.ELECTRONICS_LUXURY_SEGMENT = 'UPPER MASS' THEN '02_UPPER MASS'
        WHEN e.ELECTRONICS_LUXURY_SEGMENT = 'MASS' THEN '03_MASS'
        ELSE '99_Other'
    END AS ELECTRONICS_LUXURY_SEGMENT,
    CASE 
        WHEN e.FASHION_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN e.FASHION_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
        WHEN e.FASHION_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN e.FASHION_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN e.FASHION_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS FASHION_LUXURY_SEGMENT,
    CASE 
        WHEN e.FOOD_LUXURY_SEGMENT = 'SUPER LUXURY' THEN '01_SUPER LUXURY'
        WHEN e.FOOD_LUXURY_SEGMENT = 'LUXURY' THEN '02_LUXURY'
        WHEN e.FOOD_LUXURY_SEGMENT = 'ACCESSIBLE LUXURY' THEN '03_ACCESSIBLE LUXURY'
        WHEN e.FOOD_LUXURY_SEGMENT = 'UPPER MASS' THEN '04_UPPER MASS'
        WHEN e.FOOD_LUXURY_SEGMENT = 'MASS' THEN '05_MASS'
        ELSE '99_Other'
    END AS FOOD_LUXURY_SEGMENT,
    e.PAYMENT_SEGMENT,
    CASE 
        WHEN e.POINT_LOVER_SEGMENT = 'LOW' THEN '01_Low'
        WHEN e.POINT_LOVER_SEGMENT = 'MID' THEN '02_Mid'
        WHEN e.POINT_LOVER_SEGMENT = 'HIGH' THEN '03_High'
        ELSE e.POINT_LOVER_SEGMENT 
    END AS POINT_LOVER_SEGMENT,
    e.WEALTH_SEGMENT, e.Flag_Omni_Channel
FROM Ton1.CPS_BI_storecode_sbl_cfh AS a
LEFT JOIN MKTCRM.dbo.crm_single_view_2409 AS e
    ON a.SBL_Member_ID = e.SBL_Member_ID;



/*by store*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_storecode_sbl_p_profile
EXEC Ton1.CPS_BI_execute_s 'Age_Range','Age_Range';
EXEC Ton1.CPS_BI_execute_s 'Generation','Generation';
EXEC Ton1.CPS_BI_execute_s 'Marital_Status','MARITAL_STATUS';
EXEC Ton1.CPS_BI_execute_s 'Gender','Gender';
EXEC Ton1.CPS_BI_execute_s 'Occupation','Occupation';
EXEC Ton1.CPS_BI_execute_s 'Education','Education_Level';
EXEC Ton1.CPS_BI_execute_s 'Monthly_income','Mthly_Income';
EXEC Ton1.CPS_BI_execute_s 'Customer_Type','Customer_Type';
EXEC Ton1.CPS_BI_execute_s 'Segment','segment';
EXEC Ton1.CPS_BI_execute_s 'Wealth_Score','WEALTH_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Food_Luxury','FOOD_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Beauty_Segment','BEAUTY_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Beauty_Luxury_Segment','BEAUTY_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'CFR_Company_Rank','CFR_COMPANY_RANK';
EXEC Ton1.CPS_BI_execute_s 'CFG_Rank','CFG_Rank';
EXEC Ton1.CPS_BI_execute_s 'Electronics_Luxury_Segment','ELECTRONICS_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Fashion_Luxury_Segment','FASHION_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Payment_Segment','PAYMENT_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Kids_Stage','KIDS_STAGE';
EXEC Ton1.CPS_BI_execute_s 'Point_Lover_Segment','POINT_LOVER_SEGMENT';
EXEC Ton1.CPS_BI_execute_s 'Flag_Omni_Channel','Flag_Omni_Channel';
EXEC Ton1.CPS_BI_execute_s 'Olympic_Segment','olympic_segment';



/*create view Ton1.CPS_BI_storecode_sbl_p_profile_2  as
select *
from Ton1.CPS_BI_storecode_sbl_p_profile
where type is not null 
	and detail_type is not null
	and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN',  '_');*/




/*by store format & location*/
/*CREATE view Ton1.CPS_BI_storeformat_sbl_p AS
SELECT DISTINCT 
    store_format2, ('_' + store_format2) AS store_name,  store_location, sbl_member_id, 
    olympic_segment, MARITAL_STATUS, age, Age_Range, Gender, Education_Level, MTHLY_INCOME,
    segment, CFR_COMPANY_RANK, CFG_Rank, Generation, KIDS_STAGE, Occupation, CUSTOMER_TYPE,
    BEAUTY_LUXURY_SEGMENT, BEAUTY_SEGMENT, ELECTRONICS_LUXURY_SEGMENT, FASHION_LUXURY_SEGMENT,
    FOOD_LUXURY_SEGMENT, PAYMENT_SEGMENT, POINT_LOVER_SEGMENT, WEALTH_SEGMENT, Flag_Omni_Channel
FROM Ton1.CPS_BI_storecode_sbl_p;*/

TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_storeformat_sbl_p_profile ;
EXEC Ton1.CPS_BI_execute_storeformat 'Age_Range', 'Age_Range';
EXEC Ton1.CPS_BI_execute_storeformat 'Generation','Generation';
EXEC Ton1.CPS_BI_execute_storeformat 'Marital_Status','MARITAL_STATUS';
EXEC Ton1.CPS_BI_execute_storeformat 'Gender','Gender';
EXEC Ton1.CPS_BI_execute_storeformat 'Occupation','Occupation';
EXEC Ton1.CPS_BI_execute_storeformat 'Education','Education_Level';
EXEC Ton1.CPS_BI_execute_storeformat 'Monthly_income','Mthly_Income';
EXEC Ton1.CPS_BI_execute_storeformat 'Customer_Type','Customer_Type';
EXEC Ton1.CPS_BI_execute_storeformat 'Segment','segment';
EXEC Ton1.CPS_BI_execute_storeformat 'Wealth_Score','WEALTH_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Food_Luxury','FOOD_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Beauty_Segment','BEAUTY_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Beauty_Luxury_Segment','BEAUTY_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'CFR_Company_Rank','CFR_COMPANY_RANK';
EXEC Ton1.CPS_BI_execute_storeformat 'CFG_Rank','CFG_Rank';
EXEC Ton1.CPS_BI_execute_storeformat 'Electronics_Luxury_Segment','ELECTRONICS_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Fashion_Luxury_Segment','FASHION_LUXURY_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Payment_Segment','PAYMENT_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Kids_Stage','KIDS_STAGE';
EXEC Ton1.CPS_BI_execute_storeformat 'Point_Lover_Segment','POINT_LOVER_SEGMENT';
EXEC Ton1.CPS_BI_execute_storeformat 'Flag_Omni_Channel','Flag_Omni_Channel';
EXEC Ton1.CPS_BI_execute_storeformat 'Olympic_Segment','olympic_segment';




	create VIEW Ton1.CPS_BI_storeformat_sbl_p_profile_2 as
	select *
	from Ton1.CPS_BI_storeformat_sbl_p_profile
	where type is not null 
				and detail_type is not null
				and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN', '_');


/*combine*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_profile_summary;
INSERT INTO MKTCRM.Ton1.CPS_BI_profile_summary
(st_code, store_format2, store_name, store_location, [Type], detail_Type, SBL_Member_id)
SELECT *
FROM Ton1.CPS_BI_storecode_sbl_p_profile_2
UNION ALL
SELECT *
FROM Ton1.CPS_BI_storeformat_sbl_p_profile_2;




/*mapping home address*/
	--create VIEW Ton1.CPS_BI_sale_m_sbl as
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m_sbl;
INSERT INTO MKTCRM.Ton1.CPS_BI_sale_m_sbl
(st_code, store_format2, store_name, store_location, sbl_member_id, home_subdistrict, home_district, home_city, tx, quant, total, gp, net_total)
select distinct st_code, store_format2, store_name, store_location,	a.sbl_member_id,
				b.home_subdistrict, b.home_district, b.home_city,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total		
from Ton1.CPS_BI_sale_m as a
left join cfhqsasdidb01.topssbl.dbo.sbl_customer as b
on a.sbl_member_id = b.sbl_member_id
group by st_code, store_format2, store_name, store_location, a.sbl_member_id, b.home_subdistrict, b.home_district, b.home_city;


TRUNCATE TABLE MKTCRM.Ton1.CPS_BI_sale_m_sbl_hmaddr;
INSERT INTO MKTCRM.Ton1.CPS_BI_sale_m_sbl_hmaddr
(st_code, store_format2, store_name, store_location, home_subdistrict, home_district, home_city, tc, tx, quant, total, gp, net_total)
select distinct st_code, store_format2, store_name, store_location, home_subdistrict, home_district, home_city,
							count(distinct sbl_member_id) as tc,
							sum(tx) as tx, 
							sum(quant) as quant, 
							sum(total)as total, 
							sum(GP) as gp, 
							sum(net_total) as net_total
from Ton1.CPS_BI_sale_m_sbl
group by st_code, store_format2, store_name, store_location, home_subdistrict, home_district, home_city;



/*-------------------------------------------------------------------------------------------------------------------*/

/*Month 1-3*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI2_sale_m;
EXEC Ton1.CPS_BI2_sale_m_yyyymm '202407';
EXEC Ton1.CPS_BI2_sale_m_yyyymm '202408';
EXEC Ton1.CPS_BI2_sale_m_yyyymm '202409';
EXEC Ton1.CPS_BI2_storecfm_m_yyyymm '202407';
EXEC Ton1.CPS_BI2_storecfm_m_yyyymm '202408';
EXEC Ton1.CPS_BI2_storecfm_m_yyyymm '202409';


/*Penetration by store code*/
TRUNCATE TABLE MKTCRM.Ton1.CPS_BI2_sale_m_subdept_st_code;
INSERT INTO MKTCRM.Ton1.CPS_BI2_sale_m_subdept_st_code
(st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc, tc)
select distinct st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc,
	 count(distinct sbl_member_id) as tc 
from Ton1.CPS_BI2_sale_m
group by st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc;


TRUNCATE TABLE MKTCRM.Ton1.CPS_BI2_sale_m_ccard;
INSERT INTO MKTCRM.Ton1.CPS_BI2_sale_m_ccard
(store_format2, store_location, tc)
select distinct store_format2, store_location,
		count(distinct sbl_member_id) as tc
INTO Ton1.CPS_BI2_sale_m_ccard
from  Ton1.CPS_BI2_sale_m
group by store_format2, store_location;


/*Penetration by store format & location*/
TRUNCATE TABLE Ton1.CPS_BI2_sale_m_subdept_st_format;
INSERT INTO MKTCRM.Ton1.CPS_BI2_sale_m_subdept_st_format
(st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc, tc)
select distinct 
    '' as st_code, 
    ('_' + store_format2) as store_name, 
    store_format2, 
    store_location, 
    subdept_code, 
    subdept_eng_desc,
    count(distinct sbl_member_id) as tc
INTO Ton1.CPS_BI2_sale_m_subdept_st_format
from Ton1.CPS_BI2_sale_m
group by 
    ('_' + store_format2), store_format2, store_location,  subdept_code, subdept_eng_desc;


/*Combine*/
CREATE VIEW Ton1.CPS_BI2_subdept_summary AS
SELECT * 
FROM Ton1.CPS_BI2_sale_m_subdept_st_code
UNION ALL
SELECT * 
FROM Ton1.CPS_BI2_sale_m_subdept_st_format;
