CREATE PROCEDURE ALL_TY_1_INSERT
     -- ตัวแปรเก็บชื่อของตารางต้นทาง
    @yyyymm_StarDate NVARCHAR(8),
    @yyyymm_EndDate NVARCHAR(8)         -- ตัวแปรเก็บเดือนและปีในรูปแบบ yyyymm
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);  -- ตัวแปรเก็บคำสั่ง SQL แบบไดนามิก
   	DECLARE @StartDate NVARCHAR(8);
    DECLARE @EndDate NVARCHAR(8);
    
   	SET @StartDate = @yyyymm_StarDate;
    SET @EndDate = @yyyymm_EndDate;
   

    -- สร้างคำสั่ง SQL แบบไดนามิกสำหรับ INSERT INTO
    SET @SQL = N'
    INSERT INTO MKTCRM.dbo.ALL_TY_1 (
        STORE_ID, SBL_MEMBER_ID, REF_KEY, quant, TOTAL, NET_TOTAL, GP, STORE_FORMAT, STORE_NAME, TTM2
    )
    SELECT 
		store_id,
		sbl_member_id,
		REF_key,
		sum(QUANT) as quant, 
		Sum(TOTAL) as total, 
		sum(NET_TOTAL) as net_total, 
		sum(GP) as gp,
		store_format,
		STORE_NAME,TTM2 
	from MKTCRM.dbo.All_2023
	where TTM2 between ''' + @StartDate + ''' AND ''' + @EndDate + ''' /*ระบุ period ที่จะ compare*/
	group by  store_id,sbl_member_id,REF_key,store_format,STORE_NAME,TTM2;';

    -- รันคำสั่ง SQL ที่สร้างขึ้น
    EXEC sp_executesql @SQL;
END;
