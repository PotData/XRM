CREATE PROCEDURE SEG.CFG_ALL_BU_crm
AS
BEGIN
    -- Step 1: ลบตารางทั้งหมดก่อน (ป้องกันข้อมูลซ้ำ)
    IF OBJECT_ID('MKTCRM.SEG.CFG_ALL_BU', 'U') IS NOT NULL
    BEGIN
        DROP TABLE MKTCRM.SEG.CFG_ALL_BU;
    END;

    IF OBJECT_ID('MKTCRM.SEG.CFG_ALL_BU_T', 'U') IS NOT NULL
    BEGIN
        DROP TABLE MKTCRM.SEG.CFG_ALL_BU_T;
    END;

    -- ลบ temp table ถ้ามีอยู่ก่อน
    IF OBJECT_ID('tempdb..#ranked_data', 'U') IS NOT NULL
    BEGIN
        DROP TABLE #ranked_data;
    END;

    -- Step 2: สร้างตาราง cfg_all_BU (โครงสร้างใหม่)
    CREATE TABLE MKTCRM.SEG.CFG_ALL_BU (
        BU VARCHAR(20),
        sbl_member_id NVARCHAR(20),
        tx INT,
        total DECIMAL(18,2),
        gp DECIMAL(18,2),
        net_total DECIMAL(18,2),
        mv INT,
        lv VARCHAR(20),
        rank_total INT,
        BU_Rank NVARCHAR(20)
    );

    -- Step 3: Insert ข้อมูลที่คำนวณมาแล้วจากการ group by
    INSERT INTO MKTCRM.SEG.CFG_ALL_BU (BU, sbl_member_id, tx, total, gp, net_total, mv, lv)
    SELECT 
        BU, 
        sbl_member_id, 
        SUM(tx) AS tx, 
        SUM(total) AS total, 
        SUM(gp) AS gp, 
        SUM(net_total) AS net_total, 
        COUNT(DISTINCT ym) AS mv, 
        MAX(ym) AS lv
    FROM MKTCRM.seg.cfg_all
    GROUP BY BU, sbl_member_id;

    -- Step 4: คำนวณอันดับและกำหนด BU_Rank โดยใช้ RANK() และ CASE
    WITH ranked_data AS (
        SELECT 
            BU,
            sbl_member_id,
            tx,
            total,
            gp,
            net_total,
            mv,
            lv,
            NTILE(100) OVER (PARTITION BY BU ORDER BY total DESC) AS rank_total
        FROM MKTCRM.seg.cfg_all_BU
    )

    -- สร้าง temp table ใหม่
    SELECT 
        BU,
        sbl_member_id,
        tx,
        total,
        gp,
        net_total,
        mv,
        lv,
        rank_total,
        CASE 
            WHEN rank_total >= 99 THEN 'TOP 1%' 
            WHEN rank_total >= 90 THEN 'TOP 2-10%' 
            WHEN rank_total >= 80 THEN 'TOP 11-20%' 
            WHEN rank_total >= 60 THEN 'TOP 21-40%' 
            WHEN rank_total >= 40 THEN 'TOP 41-60%' 
            WHEN rank_total >= 20 THEN 'TOP 61-80%' 
            WHEN rank_total IS NULL THEN 'None' 
            ELSE 'Bottom 20%' 
        END AS BU_Rank
    INTO #ranked_data  -- สร้าง temp table
    FROM ranked_data;

    -- Step 5: Transpose ข้อมูลจาก BU ให้เป็นคอลัมน์ใหม่
    SELECT 
        sbl_member_id,
        MAX(CASE WHEN BU = 'BU1' THEN BU_Rank ELSE 'None' END) AS BU1,
        MAX(CASE WHEN BU = 'BU2' THEN BU_Rank ELSE 'None' END) AS BU2,
        MAX(CASE WHEN BU = 'BU3' THEN BU_Rank ELSE 'None' END) AS BU3,
        MAX(CASE WHEN BU = 'BU4' THEN BU_Rank ELSE 'None' END) AS BU4
    INTO MKTCRM.SEG.CFG_ALL_BU_T  -- เก็บผลลัพธ์ในตารางใหม่
    FROM MKTCRM.SEG.CFG_ALL_BU
    GROUP BY sbl_member_id;

    -- Step 6: อัพเดท rank_total และ BU_Rank ลงในตาราง MKTCRM.seg.cfg_all_BU
    UPDATE main_table
    SET 
        main_table.rank_total = ranked_data.rank_total,  -- อัพเดท rank_total
        main_table.BU_Rank = ranked_data.BU_Rank         -- อัพเดท BU_Rank
    FROM MKTCRM.seg.cfg_all_BU AS main_table
    JOIN #ranked_data AS ranked_data
        ON main_table.sbl_member_id = ranked_data.sbl_member_id
        AND main_table.BU = ranked_data.BU;

    -- Step 7: ลบ temp table หลังจากใช้งานเสร็จ
    DROP TABLE #ranked_data;

END;
