 CREATE TABLE MKTCRM.Ton1.CFR_CP_sale_m  (
            period VARCHAR(7),
            st_code VARCHAR(5),
            store_name VARCHAR(100),
            store_format2  VARCHAR(50),
            store_location VARCHAR(5),
            sbl_member_id VARCHAR(30), 
            Tx INT,
            quant MONEY,
            total MONEY, 
            net_total MONEY,
            gp MONEY    
);

/*------------------------------------- sale_m_storecode_sum -------------------------------------------------*/
CREATE VIEW dbo.sale_m_storecode_sum AS
 WITH SalesData AS (
    SELECT 
        st_code, 
        store_format2, 
        store_name, 
        store_location,
        COUNT(DISTINCT sbl_member_id) AS tc,
        SUM(tx) AS tx, 
        SUM(quant) AS quant, 
        SUM(total) AS total, 
        SUM(GP) AS gp, 
        SUM(net_total) AS net_total
    FROM MKTCRM.dbo.sale_m
    GROUP BY st_code, store_format2, store_name, store_location
)
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    tc,
    tx,
    quant,
    total,
    gp,
    net_total,
    (tx * 1.0) / NULLIF(tc, 0) AS freq, -- หาค่าเฉลี่ยความถี่การซื้อ (tx / tc)
    (total * 1.0) / NULLIF(tc, 0) AS spending_head_month, -- หาค่าเฉลี่ยการใช้จ่ายต่อคน
    (total * 1.0) / NULLIF(tx, 0) AS basket_size -- หาค่าขนาดตะกร้าสินค้า (total / tx)
FROM SalesData;


/*------------------------------------- sale_m_storeformat_sum -------------------------------------------------*/
CREATE VIEW dbo.sale_m_storeformat_sum AS
WITH AggregatedData AS (
    SELECT 
        store_format2, 
        CONCAT('_', store_format2) AS store_name, 
        store_location,
        COUNT(DISTINCT sbl_member_id) AS tc,
        SUM(tx) AS total_tx, 
        SUM(quant) AS total_quant, 
        SUM(total) AS total_sales, 
        SUM(GP) AS total_gp, 
        SUM(net_total) AS total_net_total
    FROM 
        MKTCRM.dbo.sale_m
    GROUP BY 
        store_format2, CONCAT('_', store_format2), store_location
)
SELECT 
    store_format2, 
    store_name, 
    store_location,
    tc,
    total_tx, 
    total_quant, 
    total_sales, 
    total_gp, 
    total_net_total,
    (total_tx / tc) AS freq,
    (total_sales / tc) AS spending_head_month,
    (total_sales / total_tx) AS basket_size
FROM 
    AggregatedData;

   
   
/*----------------------------------------- CFH --------------------------------------------------------*/
  -- ยุบรวม CFH , TM , TFF
CREATE VIEW dbo.storecode_sbl_p AS
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
    MKTCRM.dbo.sale_m a
LEFT JOIN TOPSCRM.dbo.Olympic_CFM_202409 b ON a.sbl_member_id = b.sbl_member_Id /*edit olympic*/
LEFT JOIN MKTCRM.dbo.crm_single_view_24q2 e ON a.SBL_Member_ID = e.SBL_Member_ID /*edit Single view*/
WHERE 
    store_format2 IN ('Central Food Hall', 'TOPS MARKET', 'TOPS Fine Food', 'TOPS DAILY');
       

/*-------------------------------------------- B2.sale_m Month 1-3 --------------------------------*/
 CREATE TABLE MKTCRM.dbo.B2_sale_m (
            period VARCHAR(7),
            st_code VARCHAR(5),
            store_name VARCHAR(100),
            store_format2  VARCHAR(50),
            store_location VARCHAR(5),
            sbl_member_id VARCHAR(30),
            subdept_code VARCHAR(5), 
            subdept_eng_desc VARCHAR(100),
            tx INT,
            quant MONEY,
            total MONEY, 
            net_total MONEY,
            gp MONEY    
);

 /*Penetration by store code*/

create VIEW dbo.sale_m_subdept_st_code as
select distinct st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc,
						count(distinct sbl_member_id) as tc
	from MKTCRM.dbo.B2_sale_m 
	group by st_code, store_name, store_format2, store_location, subdept_code, subdept_eng_desc;



	create VIEW dbo.sale_m_ccard as
	select distinct store_format2, store_location,
						count(distinct sbl_member_id) as tc
	from MKTCRM.dbo.B2_sale_m 
	group by store_format2, store_location;


/*Penetration by store format & location*/
	create VIEW dbo.sale_m_subdept_st_format as
	SELECT DISTINCT 
    '' AS st_code, 
    CONCAT('_', store_format2) AS store_name,  -- แทน catt("_", store_format2) ด้วย CONCAT('_', store_format2)
    store_format2, 
    store_location, 
    subdept_code, 
    subdept_eng_desc,
    COUNT(DISTINCT sbl_member_id) AS tc
FROM MKTCRM.dbo.B2_sale_m 
GROUP BY 
    CONCAT('_', store_format2), store_format2, store_location, subdept_code, subdept_eng_desc;


/*Combine*/
create VIEW dbo.subdept_summary AS
SELECT * 
FROM MKTCRM.dbo.sale_m_subdept_st_code
UNION ALL
SELECT * 
FROM MKTCRM.dbo.sale_m_subdept_st_format;


/*----------------------------------------- storecode_sbl_p_profile ----------------------------------------------------*/
create VIEW dbo.storecode_sbl_p_profile  as
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Age_Range' AS Type, 
    Age_Range AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Age_Range
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Generation' AS Type, 
    Generation AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Generation
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Marital_Status' AS Type, 
    MARITAL_STATUS AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, MARITAL_STATUS 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Gender' AS Type, 
    Gender AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Gender  
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Occupation' AS Type, 
    Occupation AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Occupation
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Education' AS Type, 
    Education_Level AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Education_Level 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Monthly_income' AS Type, 
    Mthly_Income AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Mthly_Income 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Customer_Type' AS Type, 
    Customer_Type AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Customer_Type
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Segment' AS Type, 
    segment AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, segment 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Wealth_Score' AS Type, 
    WEALTH_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, WEALTH_SEGMENT
UNION ALL
SELECT
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Food_Luxury' AS Type, 
    FOOD_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, FOOD_LUXURY_SEGMENT
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Beauty_Segment' AS Type, 
    BEAUTY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, BEAUTY_SEGMENT 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Beauty_Luxury_Segment' AS Type, 
    BEAUTY_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, BEAUTY_LUXURY_SEGMENT
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'CFR_Company_Rank' AS Type, 
    CFR_COMPANY_RANK AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, CFR_COMPANY_RANK    
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'CFG_Rank' AS Type, 
    CFG_Rank AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, CFG_Rank 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Electronics_Luxury_Segment' AS Type, 
    ELECTRONICS_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, ELECTRONICS_LUXURY_SEGMENT
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Fashion_Luxury_Segment' AS Type, 
    FASHION_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, FASHION_LUXURY_SEGMENT
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Payment_Segment' AS Type, 
    PAYMENT_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, PAYMENT_SEGMENT
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Kids_Stage' AS Type, 
    KIDS_STAGE AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, KIDS_STAGE 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Point_Lover_Segment' AS Type, 
    POINT_LOVER_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, POINT_LOVER_SEGMENT 
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Flag_Omni_Channel' AS Type, 
    Flag_Omni_Channel AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, Flag_Omni_Channel    
UNION ALL 
SELECT 
    st_code, 
    store_format2, 
    store_name, 
    store_location,
    'Olympic_Segment' AS Type, 
    olympic_segment AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p AS a
GROUP BY 
    st_code, store_format2, store_name, store_location, olympic_segment ;
 
   
/*--------------------------------------------------------------------------------------------------*/   
CREATE VIEW dbo.storeformat_sbl_p_profile  as  
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Age_Range' AS Type,
    Age_Range AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Age_Range
UNION ALL 
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Generation' AS Type,
    Generation AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Generation
UNION ALL 
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Marital_Status' AS Type,
    MARITAL_STATUS AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, MARITAL_STATUS
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Gender' AS Type,
    Gender AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Gender   
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Occupation' AS Type,
    Occupation AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Occupation
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Education' AS Type,
    Education_Level AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Education_Level     
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Monthly_income' AS Type,
    Mthly_Income AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Mthly_Income 
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Customer_Type' AS Type,
    Customer_Type AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Customer_Type
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Segment' AS Type,
    segment AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, segment
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Wealth_Score' AS Type,
    WEALTH_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, WEALTH_SEGMENT  
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Food_Luxury' AS Type,
    FOOD_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, FOOD_LUXURY_SEGMENT  
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Beauty_Segment' AS Type,
    BEAUTY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, BEAUTY_SEGMENT    
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Beauty_Luxury_Segment' AS Type,
    BEAUTY_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, BEAUTY_LUXURY_SEGMENT     
 UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'CFR_Company_Rank' AS Type,
    CFR_COMPANY_RANK AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, CFR_COMPANY_RANK      
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'CFG_Rank' AS Type,
    CFG_Rank AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, CFG_Rank     
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Electronics_Luxury_Segment' AS Type,
    ELECTRONICS_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, ELECTRONICS_LUXURY_SEGMENT    
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Fashion_Luxury_Segment' AS Type,
    FASHION_LUXURY_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, FASHION_LUXURY_SEGMENT    
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Payment_Segment' AS Type,
    PAYMENT_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, PAYMENT_SEGMENT      
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Kids_Stage' AS Type,
    KIDS_STAGE AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, KIDS_STAGE      
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Point_Lover_Segment' AS Type,
    POINT_LOVER_SEGMENT AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, POINT_LOVER_SEGMENT
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Flag_Omni_Channel' AS Type,
    Flag_Omni_Channel AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, Flag_Omni_Channel    
UNION ALL    
SELECT 
    NULL AS st_code,  -- แทนที่ "" ด้วย NULL หรือค่าที่ต้องการ
    store_format2, 
    CONCAT('_', store_format2) AS store_name, 
    store_location,
    'Olympic_Segment' AS Type,
    olympic_segment AS detail_Type,
    COUNT(DISTINCT a.SBL_Member_id) AS SBL_Member_id
FROM 
    MKTCRM.dbo.storecode_sbl_p  a
GROUP BY 
    store_format2, CONCAT('_', store_format2), store_location, olympic_segment;     
    
   
   
/*--------------------------------- profile_summary  ----------------------------------------------*/  
create VIEW dbo.profile_summary  as
select *
from MKTCRM.dbo.storecode_sbl_p_profile
where type is not null 
and detail_type is not null
and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN',  '_')
UNION ALL 
select *
from MKTCRM.dbo.storeformat_sbl_p_profile
where type is not null 
and detail_type is not null
and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN', '_')

   
/*--------------------------------- storeformat_sbl_p2_profile  ----------------------------------------------*/  
create VIEW dbo.storeformat_sbl_p2_profile  as
select store_format2,
	   'Age_Range' as Type,
		Age_Range as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Age_Range
UNION ALL 
select store_format2,
	   'Generation' as Type,
		Generation as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Generation
UNION ALL 
select store_format2,
	   'Marital_Status' as Type,
		MARITAL_STATUS as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,MARITAL_STATUS
UNION ALL 
select store_format2,
	   'Gender' as Type,
		Gender as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Gender
UNION ALL 
select store_format2,
	   'Occupation' as Type,
		Occupation as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Occupation
UNION ALL 
select store_format2,
	   'Education' as Type,
		Education_Level as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Education_Level
UNION ALL 
select store_format2,
	   'Monthly_income' as Type,
		Mthly_Income as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Mthly_Income
UNION ALL 
select store_format2,
	   'Customer_Type' as Type,
		Customer_Type as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Customer_Type
UNION ALL 
select store_format2,
	   'Segment' as Type,
		segment as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,segment
UNION ALL 
select store_format2,
	   'Wealth_Score' as Type,
		WEALTH_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,WEALTH_SEGMENT
UNION ALL 
select store_format2,
	   'Food_Luxury' as Type,
		FOOD_LUXURY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,FOOD_LUXURY_SEGMENT
UNION ALL 
select store_format2,
	   'Beauty_Segment' as Type,
		BEAUTY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,BEAUTY_SEGMENT
UNION ALL 
select store_format2,
	   'Beauty_Luxury_Segment' as Type,
		BEAUTY_LUXURY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,BEAUTY_LUXURY_SEGMENT
UNION ALL 
select store_format2,
	   'CFR_Company_Rank' as Type,
		CFR_COMPANY_RANK as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,CFR_COMPANY_RANK
UNION ALL 
select store_format2,
	   'CFG_Rank' as Type,
		CFG_Rank as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,CFG_Rank
UNION ALL 
select store_format2,
	   'Electronics_Luxury_Segment' as Type,
		ELECTRONICS_LUXURY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,ELECTRONICS_LUXURY_SEGMENT
UNION ALL 
select store_format2,
	   'Fashion_Luxury_Segment' as Type,
		FASHION_LUXURY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,FASHION_LUXURY_SEGMENT
UNION ALL 
select store_format2,
	   'Payment_Segment' as Type,
		FASHION_LUXURY_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,FASHION_LUXURY_SEGMENT
UNION ALL 
select store_format2,
	   'Kids_Stage' as Type,
		KIDS_STAGE as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,KIDS_STAGE
UNION ALL 
select store_format2,
	   'Point_Lover_Segment' as Type,
		POINT_LOVER_SEGMENT as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,POINT_LOVER_SEGMENT
UNION ALL 
select store_format2,
	   'Flag_Omni_Channel' as Type,
		Flag_Omni_Channel as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,Flag_Omni_Channel
UNION ALL 
select store_format2,
	   'Olympic_Segment' as Type,
		olympic_segment as detail_Type,
        count(distinct a.SBL_Member_id) as SBL_Member_id
from MKTCRM.dbo.storecode_sbl_p  a
group by store_format2,olympic_segment;


create VIEW dbo.storeformat_sbl_p2_profile_2  as
select *
from MKTCRM.dbo.storeformat_sbl_p2_profile
where type is not null 
and detail_type is not null
and detail_type not in ('._', 'Other', '99_Unknown', 'C.UNKNOWN', 'N/A',  'Unknown', '99_Other', 'D.UNKNOWN', '_')







	create VIEW dbo.sale_m_period_storeformat as
	select distinct period, store_format2, CONCAT('_', store_format2) as store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total,
				sum(total)/count(distinct sbl_member_id) as spending_head_month,
				sum(total)/sum(tx) as basket_size,
				sum(tx)/count(distinct sbl_member_id) as freq
	from MKTCRM.dbo.sale_m
	group by period, store_format2, CONCAT('_', store_format2), store_location;



	select distinct period, st_code, store_format2, store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total,
				AVG(sum(total)/count(distinct sbl_member_id)) as spending_head_month,
				AVG(sum(total)/sum(tx)) as basket_size,
				AVG(sum(tx)/count(distinct sbl_member_id)) as freq
	from MKTCRM.dbo.sale_m
	group by period, st_code, store_format2, store_name, store_location
	
	
	
SELECT 
    COALESCE(a.store_format2, b.store_format2) AS store_format2,
    COALESCE(CONCAT('_', a.store_format2), CONCAT('_', b.store_format2)) AS store_name,
    COALESCE(a.store_location, b.store_location) AS store_location,
    -- ระบุคอลัมน์ที่ต้องการจากทั้งสองตาราง เช่น:
    count(distinct a.sbl_member_id) as tc,
	sum(a.tx) as tx, 
	sum(a.quant) as quant, 
	sum(a.total)as total, 
	sum(a.GP) as gp, 
	sum(a.net_total) as net_total,
	avg(freq) as freq,
	avg(spending_head_month) as spending_head_month,
	avg(basket_size) as basket_size
	
FROM 
    MKTCRM.dbo.sale_m AS a
FULL OUTER JOIN 
    MKTCRM.dbo.sale_m_period_storeformat AS b
ON 
    a.store_format2 = b.store_format2 
    AND a.store_name = b.store_name 
    AND a.store_location = b.store_location
group by store_format2, store_name, store_location;





	create view dbo.sale_m_storeformat_sum1 as
 	select distinct store_format2, CONCAT('_', store_format2) as store_name, store_location,
				count(distinct sbl_member_id) as tc,
				sum(tx) as tx, 
				sum(quant) as quant, 
				sum(total)as total, 
				sum(GP) as gp, 
				sum(net_total) as net_total
	from MKTCRM.dbo.sale_m
	group by store_format2, CONCAT('_', store_format2), store_location;