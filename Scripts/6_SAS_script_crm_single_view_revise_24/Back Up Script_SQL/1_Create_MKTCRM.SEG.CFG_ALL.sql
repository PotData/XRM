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

-- 10. Create the table MKTCRM.SEG.CFG_ALL
-- Create the table structure first
CREATE TABLE MKTCRM.SEG.CFG_ALL (
    BU VARCHAR(10),
    ym CHAR(6),
    sbl_member_id VARCHAR(20), 
    tx INT,
    total DECIMAL(20, 4), 
    gp DECIMAL(20, 4), 
    net_total DECIMAL(20, 4)
);

-- 11. Prepare the dynamic SQL for insertion
DECLARE @sql NVARCHAR(MAX);

-- สร้าง MKTCRM.SEG.CFG_ALL

	-- Insert from 'saletrans'
	SET @sql = N'INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
				SELECT ''CFR'' as BU, @FM AS ym, sbl_member_id,  COUNT(DISTINCT ref_key) AS tx, 
					SUM(COALESCE(a.total, 0)) AS total, 
					SUM(COALESCE(a.gp, 0)) as gp,
					SUM(COALESCE(a.net_total, 0)) as net_total
				FROM cfhqsasdidb01.topsrst.dbo.saletrans_' + @FM + ' a
				JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
				group by sbl_member_id;';
	EXEC sp_executesql @sql, N'@FM CHAR(6)', @FM;
	
	
	-- Insert from 'saletrans_online'
	SET @sql = N'INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	            SELECT ''CFR'' AS BU, @FM AS ym, sbl_member_id, COUNT(DISTINCT ref_key) AS tx, 
	                   SUM(COALESCE(total, 0)) AS total, 
	                   SUM(COALESCE(gp, 0)) AS gp, 
	                   SUM(COALESCE(net_total, 0)) AS net_total
	            FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_' + @FM + ' a
	            JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	            GROUP BY sbl_member_id;';
	EXEC sp_executesql @sql, N'@FM CHAR(6)', @FM;


	
	-- Insert from 'saletrans_cfm'
	SET @sql = N'INSERT INTOMKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	            SELECT ''CFM'' AS BU, @FM AS ym, sbl_member_id,  COUNT(DISTINCT CONCAT(a.reference, a.store_code)) AS tx, 
	                   SUM(COALESCE(a.sales, 0)) AS total, 
	                   SUM(COALESCE(a.gp, 0)) AS gp, 
	                   SUM(COALESCE(a.netsales, 0)) AS net_total
	            FROM cfhqsasdidb01.topscfm.dbo.saletrans_cfm_' + @FM + ' a
	            JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	            GROUP BY sbl_member_id;';
	EXEC sp_executesql @sql, N'@FM CHAR(6)', @FM;

	
	-- Insert from 'saletrans_td'
	SET @sql = N'INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	            SELECT ''CFR'' AS BU, @FM AS ym, sbl_member_id, COUNT(DISTINCT REFERENCE) AS tx, 
	                   SUM(COALESCE(SALES, 0)) AS total, 
	                   SUM(COALESCE(gp, 0)) AS gp, 
	                   SUM(COALESCE(NETSALES, 0)) AS net_total
	            FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @FM + ' a
	            JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	            GROUP BY sbl_member_id;';
	EXEC sp_executesql @sql, N'@FM CHAR(6)', @FM;



-- บรรทัดที่ 103
-- Start the loop for months from @FM + 1 to @LM
DECLARE @cym CHAR(6);
SET @cym = FORMAT(DATEADD(MONTH, 1, CAST(@FM + '01' AS DATE)), 'yyyyMM');

-- Loop through months and insert data
WHILE @cym <= @LM
	BEGIN
	    -- Prepare dynamic SQL for 'saletrans' for the month @cym
	    SET @sql = N'INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	                SELECT ''CFR'' AS BU, @cym AS ym, sbl_member_id, COUNT(DISTINCT ref_key) AS tx, 
	                       SUM(COALESCE(total, 0)) AS total, 
	                       SUM(COALESCE(gp, 0)) AS gp, 
	                       SUM(COALESCE(net_total, 0)) AS net_total
	                FROM cfhqsasdidb01.topsrst.dbo.saletrans_' + @cym + ' a
	                JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	                GROUP BY sbl_member_id;';
	    
	    -- Execute the dynamic SQL for 'saletrans' table
	    EXEC sp_executesql @sql, N'@cym CHAR(6)', @cym;
	
		
	    -- Insert from 'saletrans_cfm'
	    SET @sql = N'
	        INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	        SELECT ''CFM'' AS BU, @cym AS ym, sbl_member_id, 
	               COUNT(DISTINCT CONCAT(a.reference, a.store_code)) AS tx, 
	               SUM(COALESCE(a.sales, 0)) AS total, 
	               SUM(COALESCE(a.gp, 0)) AS gp, 
	               SUM(COALESCE(a.netsales, 0)) AS net_total
	        FROM cfhqsasdidb01.topscfm.dbo.saletrans_cfm_' + @cym + ' a
	        JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	        GROUP BY sbl_member_id;';
	    EXEC sp_executesql @sql, N'@cym CHAR(6)', @cym;
	
	    -- Insert from 'saletrans_online'
	    SET @sql = N'
	        INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	        SELECT ''CFR'' AS BU, @cym AS ym, sbl_member_id, 
	               COUNT(DISTINCT a.ref_key) AS tx, 
	               SUM(COALESCE(a.total, 0)) AS total, 
	               SUM(COALESCE(a.gp, 0)) AS gp, 
	               SUM(COALESCE(a.net_total, 0)) AS net_total
	        FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_' + @cym + ' a
	        JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	        GROUP BY sbl_member_id;';
	    EXEC sp_executesql @sql, N'@cym CHAR(6)', @cym;
	
	    -- Insert from 'saletrans_td'
	    SET @sql = N'
	        INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
	        SELECT ''CFR'' AS BU, @cym AS ym, sbl_member_id, 
	               COUNT(DISTINCT a.REFERENCE) AS tx, 
	               SUM(COALESCE(a.SALES, 0)) AS total, 
	               SUM(COALESCE(a.gp, 0)) AS gp, 
	               SUM(COALESCE(a.NETSALES, 0)) AS net_total
	        FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @cym + ' a
	        JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
	        GROUP BY sbl_member_id;';
	    EXEC sp_executesql @sql, N'@cym CHAR(6)', @cym; 
	   
	-- Move to the next month
	SET @cym = FORMAT(DATEADD(MONTH, 1, CAST(@cym + '01' AS DATE)), 'yyyyMM');
END	   
	   
-- Last month get from table daily
-- Insert from 'saletrans_daily'
SET @sql = N'
    INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
    SELECT ''CFR'' AS BU, @LM AS ym, sbl_member_id, COUNT(DISTINCT ref_key) AS tx, 
           SUM(COALESCE(total, 0)) AS total, 
           SUM(COALESCE(gp, 0)) AS gp, 
           SUM(COALESCE(net_total, 0)) AS net_total
    FROM cfhqsasdidb01.topsrst.dbo.saletrans_daily a
    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
    WHERE FORMAT(a.ttm2, ''yyyyMM'') = @LM
    GROUP BY sbl_member_id;';
EXEC sp_executesql @sql, N'@LM CHAR(6)', @LM;

-- 2. Insert from 'saletrans_online_daily'
SET @sql = N'
    INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
    SELECT ''CFR'' AS BU, @LM AS ym, sbl_member_id, COUNT(DISTINCT ref_key) AS tx, 
           SUM(COALESCE(total, 0)) AS total, 
           SUM(COALESCE(gp, 0)) AS gp, 
           SUM(COALESCE(net_total, 0)) AS net_total
    FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_daily a
    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
    WHERE FORMAT(a.ttm2, ''yyyyMM'') = @LM
    GROUP BY sbl_member_id;';
EXEC sp_executesql @sql, N'@LM CHAR(6)', @LM;

-- 3. Insert from 'saletrans_cfm'
SET @sql = N'
    INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
    SELECT ''CFM'' AS BU, @LM AS ym, sbl_member_id, COUNT(DISTINCT CONCAT(reference, store_code)) AS tx, 
           SUM(COALESCE(sales, 0)) AS total, 
           SUM(COALESCE(gp, 0)) AS gp, 
           SUM(COALESCE(netsales, 0)) AS net_total
    FROM cfhqsasdidb01.topscfm.dbo.saletrans_cfm_' + @LM + ' a
    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
    GROUP BY sbl_member_id;';
EXEC sp_executesql @sql, N'@LM CHAR(6)', @LM;

-- 4. Insert from 'saletrans_td'
SET @sql = N'
    INSERT INTO MKTCRM.SEG.CFG_ALL (BU, ym, sbl_member_id, tx, total, gp, net_total)
    SELECT ''CFR'' AS BU, @LM AS ym, sbl_member_id, COUNT(DISTINCT REFERENCE) AS tx, 
           SUM(COALESCE(SALES, 0)) AS total, 
           SUM(COALESCE(gp, 0)) AS gp, 
           SUM(COALESCE(NETSALES, 0)) AS net_total
    FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @LM + ' a
    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
    WHERE FORMAT(a.trans_date, ''yyyyMM'') = @LM
    GROUP BY sbl_member_id;';
EXEC sp_executesql @sql, N'@LM CHAR(6)', @LM;	   
	   
	  
END;
