-- Get today's date
DECLARE @today DATE = GETDATE();

-- 1. Calculate previous months and other required values
DECLARE @p_fm CHAR(6);
DECLARE @p_fd_fm CHAR(8);
DECLARE @p_fd_fmmm DATE;
DECLARE @p_lm CHAR(6);
DECLARE @p_ld_lm CHAR(8);
DECLARE @p_fd_lmmm DATE;
DECLARE @p_ld_lmmm DATE;


-- 2. Calculate the previous 12 months
SET @p_fm = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMM');
SET @p_fd_fm = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMMdd');
SET @p_fd_fmmm = DATEADD(MONTH, -12, @today);
SET @p_lm = FORMAT(DATEADD(MONTH, -1, @today), 'yyyyMM');
SET @p_ld_lm = FORMAT(EOMONTH(DATEADD(MONTH, -1, @today), 0), 'yyyyMMdd');
SET @p_fd_lmmm = DATEADD(MONTH, 0, @today);
SET @p_ld_lmmm = FORMAT(EOMONTH(DATEADD(MONTH, -1, @today), 0), 'yyyy-MM-dd');

-- 3. Calculate year and quarter logic (based on last month)
DECLARE @yyyy_ly INT = YEAR(DATEADD(YEAR, -1, @today)); -- Previous year
DECLARE @yyyy_lm INT = YEAR(DATEADD(MONTH, -1, @today)); -- Year of last month
DECLARE @yy_lm INT = YEAR(DATEADD(MONTH, -1, @today)); -- Year of last month (2-digit format)
DECLARE @mm_lm INT = MONTH(DATEADD(MONTH, -1, @today)); -- Last month

-- 4. Determine Year and Quarter (Single View) for last month
DECLARE @p_yqlm VARCHAR(4);
IF @mm_lm IN (3) SET @p_yqlm = CONCAT(@yy_lm, 'Q1');
IF @mm_lm IN (6) SET @p_yqlm = CONCAT(@yy_lm, 'Q2');
IF @mm_lm IN (9) SET @p_yqlm = CONCAT(@yy_lm, 'Q3');
IF @mm_lm IN (12) SET @p_yqlm = CONCAT(@yy_lm, 'Q4');

-- 5. Determine the First Month of the Last Quarter
DECLARE @p_fmlq CHAR(6);
IF @mm_lm IN (3) SET @p_fmlq = CONCAT(@yyyy_ly, '10');  -- Q4: October
IF @mm_lm IN (6) SET @p_fmlq = CONCAT(@yyyy_lm, '01');  -- Q1: January
IF @mm_lm IN (9) SET @p_fmlq = CONCAT(@yyyy_lm, '04');  -- Q2: April
IF @mm_lm IN (12) SET @p_fmlq = CONCAT(@yyyy_lm, '07'); -- Q3: July

-- 6. Calculate previous months from 2 to 12 months ago
DECLARE @p_l2m CHAR(6);
DECLARE @p_l3m CHAR(6);
DECLARE @p_l4m CHAR(6);
DECLARE @p_l5m CHAR(6);
DECLARE @p_l6m CHAR(6);
DECLARE @p_l7m CHAR(6);
DECLARE @p_l8m CHAR(6);
DECLARE @p_l9m CHAR(6);
DECLARE @p_l10m CHAR(6);
DECLARE @p_l11m CHAR(6);
DECLARE @p_l12m CHAR(6);

SET @p_l2m = FORMAT(DATEADD(MONTH, -2, @today), 'yyyyMM');
SET @p_l3m = FORMAT(DATEADD(MONTH, -3, @today), 'yyyyMM');
SET @p_l4m = FORMAT(DATEADD(MONTH, -4, @today), 'yyyyMM');
SET @p_l5m = FORMAT(DATEADD(MONTH, -5, @today), 'yyyyMM');
SET @p_l6m = FORMAT(DATEADD(MONTH, -6, @today), 'yyyyMM');
SET @p_l7m = FORMAT(DATEADD(MONTH, -7, @today), 'yyyyMM');
SET @p_l8m = FORMAT(DATEADD(MONTH, -8, @today), 'yyyyMM');
SET @p_l9m = FORMAT(DATEADD(MONTH, -9, @today), 'yyyyMM');
SET @p_l10m = FORMAT(DATEADD(MONTH, -10, @today), 'yyyyMM');
SET @p_l11m = FORMAT(DATEADD(MONTH, -11, @today), 'yyyyMM');
SET @p_l12m = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMM');

-- 7. Assigning values to new variables for use (Move this part before sp_executesql)
DECLARE @FM CHAR(6) = @p_fm;
DECLARE @LM CHAR(6) = @p_lm;
DECLARE @FMLQ CHAR(6) = @p_fmlq;
DECLARE @SEGNAME VARCHAR(4) = @p_yqlm;

-- Output the results (Print or SELECT)
-- Optional: Output the assigned variables to confirm
SELECT 
    @p_fm AS FM,
    @p_fd_fm AS FD_FM,
    @p_fd_fmmm AS FD_FMM,
  	@p_lm AS LM,
    @p_ld_lm AS LD_LM,
    @p_fd_lmmm AS FD_LMM,
    @p_ld_lmmm AS LD_LMM,
    @FMLQ AS FMLQ,
    @SEGNAME AS SEGNAME,
    @p_l2m AS L2M,
    @p_l3m AS L3M,
    @p_l4m AS L4M,
    @p_l5m AS L5M,
    @p_l6m AS L6M,
    @p_l7m AS L7M,
    @p_l8m AS L8M,
    @p_l9m AS L9M,
    @p_l10m AS L10M,
    @p_l11m AS L11M,
    @p_l12m AS L12M;
    
   
/*--------> run until here <--------*/
/*TRUNCATE TABLE MKTCRM.Ton1.SEG_CLASS_ALL;  
EXEC SEG_SC @FM, @LM;
   
INSERT INTO Ton1.SEG_CLASS_ALL (t1c_card_no, ref_key, class_cnt)
SELECT 
    t1c_card_no, 
    ref_key, 
    COUNT(DISTINCT Class_CODE) AS class_cnt
FROM cfhqsasdidb01.TOPSRST.dbo.saletrans_daily A
JOIN cfhqsasdidb01.TOPSRST.dbo.D_MERCHANDISE B 
    ON PR_CODE = product_code
WHERE 
    pr_code <> '0000030959026' 
    AND dept_id NOT IN ('07', '10', '')
    AND LEFT(ttm2, 6) = @LM
GROUP BY t1c_card_no, ref_key;



กลับไปรันที่บ้าน
SELECT 
    SBL_MEMBER_ID, 
    AVG(Class_CNT) AS Class_CNT
INTO Ton1.SEG_CLASS_PER_TX
FROM Ton1.SEG_CLASS_ALL a
JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b 
    ON a.t1c_card_no = b.t1c_card_no
GROUP BY SBL_MEMBER_ID;


/*กลับมาแก้ */
proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select A.*, B.CLASS_CNT AS CLASS_PER_TX
from seg.CRM_SINGLE_VIEW_&SEGNAME. a 
left join seg.CLASS_PER_TX b on a.SBL_MEMBER_ID = b.SBL_MEMBER_ID;
quit;*/
   
TRUNCATE TABLE MKTCRM.Ton1.SEG_SD_ALL;  
EXEC Ton1.seg_SD @FM , @LM ;

INSERT INTO SEG_SD_ALL (t1c_card_no, SUBDEPT, TX, TOTAL)
SELECT 
    t1c_card_no, 
    RTRIM(LTRIM(SUBDEPT_CODE)) + '_' + RTRIM(LTRIM(SUBDEPT_ENG_DESC)) AS SUBDEPT,
    COUNT(DISTINCT REF_KEY) AS TX, 
    SUM(TOTAL) AS TOTAL
FROM cfhqsasdidb01.TOPSRST.dbo.saletrans_daily A
LEFT JOIN cfhqsasdidb01.TOPSRST.dbo.D_MERCHANDISE B 
    ON A.PR_CODE = B.PRODUCT_CODE
WHERE LEFT(ttm2, 6) = @LM -- @LM คือค่าที่ส่งเข้ามาเป็นพารามิเตอร์
GROUP BY t1c_card_no, SUBDEPT_CODE, SUBDEPT_ENG_DESC;


CREATE TABLE SEG.SD_ALL_ (COMPRESS = YES) AS
/*รันแล้ว แก้ insert into  */
SELECT SBL_MEMBER_ID, SUBDEPT, SUM(TX) AS TX, SUM(TOTAL) AS TOTAL
INTO MKTCRM.Ton1.SEG_SD_ALL_
FROM MKTCRM.Ton1.SEG_SD_ALL a
join cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
GROUP BY SBL_MEMBER_ID, SUBDEPT;

TRUNCATE TABLE MKTCRM.Ton1.SEG_CC_ALL; 
EXEC Ton1.SEG.SALE_PROCEDURE @FM , @LM ;

INSERT INTO Ton1.SEG_CC_ALL (t1c_card_no, cc_no)
SELECT t1c_card_no, cc_no
FROM cfhqsasdidb01.TOPSRST.dbo.saletrans_daily
WHERE t1c_card_no IS NOT NULL
  AND cc_no IS NOT NULL
  AND LEFT(cc_no, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
  AND LEFT(ttm2, 6) = @LM;

 
create table seg.cc_all_cust (compress = yes) as 

select distinct SBL_MEMBER_ID
INTO MKTCRM.Ton1.SEG_cc_all_cust 
from  SEG.CC_ALL A
JOIN TOPSSBL.SBL_MEMBER_CARD_lIST B ON A.t1c_card_no = B.t1c_card_no;

/*--------> run until here <--------*/

CREATE TABLE seg.pos_media AS

SELECT a.*, b.sbl_member_id
INTO Ton1.SEG_pos_media
FROM cfhqsasdidb01.topsrst.dbo.pos_payment_media a
LEFT JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b 
  ON a.card_no = b.t1c_card_no
WHERE a.trans_date BETWEEN @p_fd_fm AND @p_ld_lm
  AND a.card_no IS NOT NULL;

CREATE TABLE seg.pos_payment AS

SELECT 
    sbl_member_id, 
    rcpt_no, 
    store_id, 
    trans_date, 
    media_name, 
    LEFT(TRIM(media_no), 6) AS card_range, 
    pay_amt
INTO Ton1.SEG_pos_payment
FROM Ton1.SEG_pos_media
WHERE sbl_member_id IS NOT NULL;



CREATE TABLE seg.pos_payment_notcash AS

SELECT 
    a.sbl_member_id,
    a.media_name,
    a.card_range,
    CONCAT(TRIM(a.STORE_ID), '_', TRIM(a.RCPT_NO), '_', TRIM(a.trans_date)) AS REF_KEY,
    SUM(a.pay_amt) AS pay_amt,
    b.tender_group,
    c.bank
INTO  Ton1.SEG_pos_payment_notcash    
FROM seg.pos_payment a
LEFT JOIN crm.TENDER_JUN19 b ON a.media_name = b.tender
LEFT JOIN seg.crm_master_credit_card c 
    ON TRY_CAST(a.card_range AS INT) BETWEEN c.start_2 AND c.end_2
WHERE a.media_name <> 'CASH'
GROUP BY 
    a.sbl_member_id, 
    a.media_name, 
    a.card_range, 
    CONCAT(TRIM(a.STORE_ID), '_', TRIM(a.RCPT_NO), '_', TRIM(a.trans_date))
;


CREATE TABLE seg.pos_paCRMmentt AS
SELECT 
    sbl_member_id, 
    ref_key, 
    tender_group, 
    bank, 
    pay_amt,
    CASE 
        WHEN ref_key IN (SELECT ref_key FROM seg.tx_all) THEN 'Y' 
        ELSE 'N' 
    END AS Flag_Exst_Saletran
FROM (
    SELECT 
        sbl_member_id, 
        ref_key, 
        tender_group, 
        bank, 
        pay_amt
    FROM seg.pos_payment_notcash
    UNION ALL
    SELECT 
        sbl_member_id, 
        ref_key, 
        'Cash' AS tender_group, 
        '' AS bank, 
        pay_amt
    FROM seg.pos_payment_cash
) AS combined_data;

SELECT TOP 5 *
FROM MKTTRADEKTCRM.Ton1.CFR_CP_B2_sale_m



 