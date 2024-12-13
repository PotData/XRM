options dlcreatedir;
libname seg "I:\Faroh\HPT\work_file\crm_single_view";

/* Set parameter*/
/* end q - 12 month. exam end q2= 202306 first period= 202207*/

-- (table 1) -- Run 2 hr.
TRUNCATE TABLE MKTCRM.SEG.CFG_ALL;

EXEC SEG.CFG_ALL_crm;

-- Script เก่า จนถึงบรรทัดที่ประมาณ 180
/*
%let p_fm = %sysfunc(intnx(month,%sysfunc(today()),-12),yymmn6.);
%let p_fd_fm  = %sysfunc(intnx(month,%sysfunc(today()),-12),yymmddn8.);
%let p_fd_fmmm  = %sysfunc(intnx(month,%sysfunc(today()),-12),DATE9.);
%let p_lm = %sysfunc(intnx(month,%sysfunc(today()),-1),yymmn6.);
%let p_ld_lm  = %sysfunc(intnx(month,%sysfunc(today()),-1,e),yymmddn8.);
%let p_fd_lmmm  = %sysfunc(intnx(month,%sysfunc(today()),0),DATE9.);
%let p_ld_lmmm  = %sysfunc(intnx(month,%sysfunc(today()),-1,e),DATE9.);
%let p_yqlm;
%let p_fmlq;

%let yyyy_ly = %sysfunc(intnx(year,%sysfunc(today()),-1),year.);
%let yyyy_lm = %sysfunc(intnx(month,%sysfunc(today()),-1),year.);
%let yy_lm = %sysfunc(intnx(month,%sysfunc(today()),-1),year2.);
%let mm_lm = %sysfunc(intnx(month,%sysfunc(today()),-1),month.);

data _null_;
  if &mm_lm. in(3)then call symput('p_yqlm',"&yy_lm.Q1");
  if &mm_lm. in(6)then call symput('p_yqlm',"&yy_lm.Q2");
  if &mm_lm. in(9)then call symput('p_yqlm',"&yy_lm.Q3");
  if &mm_lm. in(12)then call symput('p_yqlm',"&yy_lm.Q4");
run;

data _null_;
  if &mm_lm. in(3)then call symput('p_fmlq',"&yyyy_ly.10");
  if &mm_lm. in(6)then call symput('p_fmlq',"&yyyy_lm.01");
  if &mm_lm. in(9)then call symput('p_fmlq',"&yyyy_lm.04");
  if &mm_lm. in(12)then call symput('p_fmlq',"&yyyy_lm.07");
run;


-- set new parameter to old variable
%LET FM = &p_fm.;
%LET LM = &p_lm.;
%LET FMLQ = &p_fmlq.; --FIRST MONTH OF LAST QUARTER
%LET SEGNAME = &p_yqlm.; --Year and Quater SingleView

%put "prev 12 month :&FM.";
%put "Last month:&LM.";
%put "Year and Quater SingleView:&SEGNAME.";
%put "First month of last quarter:&FMLQ.";

%let p_l2m = %sysfunc(intnx(month,%sysfunc(today()),-2),yymmn6.);
%let p_l3m = %sysfunc(intnx(month,%sysfunc(today()),-3),yymmn6.);
%let p_l4m = %sysfunc(intnx(month,%sysfunc(today()),-4),yymmn6.);
%let p_l5m = %sysfunc(intnx(month,%sysfunc(today()),-5),yymmn6.);
%let p_l6m = %sysfunc(intnx(month,%sysfunc(today()),-6),yymmn6.);
%let p_l7m = %sysfunc(intnx(month,%sysfunc(today()),-7),yymmn6.);
%let p_l8m = %sysfunc(intnx(month,%sysfunc(today()),-8),yymmn6.);
%let p_l9m = %sysfunc(intnx(month,%sysfunc(today()),-9),yymmn6.);
%let p_l10m = %sysfunc(intnx(month,%sysfunc(today()),-10),yymmn6.);
%let p_l11m = %sysfunc(intnx(month,%sysfunc(today()),-11),yymmn6.);
%let p_l12m = %sysfunc(intnx(month,%sysfunc(today()),-12),yymmn6.);

%put &p_l2m.;
%put &p_l3m.;
%put &p_l4m.;
%put &p_l5m.;
%put &p_l6m.;
%put &p_l7m.;
%put &p_l8m.;
%put &p_l9m.;
%put &p_l10m.;
%put &p_l11m.;
%put &p_l12m.;

--req. by P'TON - ignore CMK @20231212 

--12 months
--CFG(CFR, CFM,CMK)
proc sql threads;
create table seg.cfg_all (compress = yes) as
select 'CFR' as BU, &FM. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_&FM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
group by sbl_member_id;

insert into seg.cfg_all
select 'CFR' as BU, &FM. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_online_&FM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
group by sbl_member_id;

insert into seg.cfg_all
select 'CFM' as BU, &FM. as ym, sbl_member_id, count(distinct reference!!store_code) as tx, sum(sales) as total, sum(gp) as gp, sum(netsales) as net_total
from topscfm.saletrans_cfm_&FM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
group by sbl_member_id;

insert into seg.cfg_all
select 'CFR' as BU, &FM. as ym, sbl_member_id, count(distinct REFERENCE) as tx, sum(SALES) as total, sum(gp) as gp, sum(NETSALES) as net_total
from topsrst.saletrans_td_&FM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
group by sbl_member_id;
quit; 

%macro sale;
%let cym = %eval(&FM. +1); 
	%do %while (&cym. < &LM.);
		%put &cym.;
		proc sql threads;
		insert into seg.cfg_all
		select 'CFR' as BU, &cym. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
		group by sbl_member_id;

		insert into seg.cfg_all
		select 'CFM' as BU, &cym. as ym, sbl_member_id, count(distinct reference!!store_code) as tx, sum(sales) as total, sum(gp) as gp, sum(netsales) as net_total
		from topscfm.saletrans_cfm_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
		group by sbl_member_id;		

		insert into seg.cfg_all
		select 'CFR' as BU, &cym. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_online_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
		group by sbl_member_id;

		insert into seg.cfg_all
		select 'CFR' as BU, &cym. as ym, sbl_member_id, count(distinct REFERENCE) as tx, sum(SALES) as total, sum(gp) as gp, sum(NETSALES) as net_total
		from topsrst.saletrans_td_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
		group by sbl_member_id;
		quit;

		%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
	              %let cym = %eval(&cym. +89);
	              %end;
	    %else %do; %let cym = %eval(&cym. +1); %end;
	%end;
%MEND;
%sale;

-- Last month get from table daily
proc sql threads;
insert into seg.cfg_all
select 'CFR' as BU, &LM. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id;


insert into seg.cfg_all
select 'CFR' as BU, &LM. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_online_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id;


insert into seg.cfg_all
select 'CFM' as BU, &LM. as ym, sbl_member_id, count(distinct reference!!store_code) as tx, sum(sales) as total, sum(gp) as gp, sum(netsales) as net_total
from topscfm.saletrans_cfm_&LM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
group by sbl_member_id;


insert into seg.cfg_all
select 'CFR' as BU, &LM. as ym, sbl_member_id, count(distinct REFERENCE) as tx, sum(SALES) as total, sum(gp) as gp, sum(NETSALES) as net_total
from topsrst.saletrans_td_&LM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where put(trans_date,yymmn6.)="&LM."
group by sbl_member_id;
quit; 
*/


----------------------------------------------------------------------------------------------------------------------------------

-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFG_ALL มาสร้าง -> MKTCRM.SEG.CFG_ALL_BU
-- (table 2) -- Run 10 - 20 min
TRUNCATE TABLE MKTCRM.SEG.CFG_ALL_BU;

EXEC SEG.CFG_ALL_BU_crm;

-- สร้าง Rank ของแต่ละ BU
/*

proc sql threads;
create table seg.cfg_all_BU (compress = yes) as
select BU, sbl_member_id, sum(tx) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total, count(distinct ym) as mv, max(ym) as lv
from seg.cfg_all
group by BU, sbl_member_id;
quit; 

proc rank data=seg.cfg_all_BU groups=100 out=seg.cfg_all_BU;
	by BU;
	var total;
	ranks rank_total;
run; 

proc sql threads;
create table seg.cfg_all_BU (compress = yes) as
select *,
case when rank_TOTAL >= 99 then 'TOP 1%' else
case when rank_TOTAL >= 90 then 'TOP 2-10%' else
case when rank_TOTAL >= 80 then 'TOP 11-20%' else
case when rank_TOTAL >= 60 then 'TOP 21-40%' else
case when rank_TOTAL >= 40 then 'TOP 41-60%' else 
case when rank_TOTAL >= 20 then 'TOP 61-80%' else 
case when rank_TOTAL is null then 'None' else 'Bottom 20%' end end end end end end end as BU_Rank
from seg.cfg_all_BU;
quit; 

proc sql threads;
create table seg.cfg_all_BU (compress = yes) as
select *
from seg.cfg_all_BU
order by sbl_member_id, BU;
quit; 
*/


-- โค้ดเก่า
/*
proc transpose data=seg.cfg_all_BU out=seg.cfg_all_BU_T;
	by sbl_member_id;
	id BU;
	var BU_Rank;
run; 
*/




-- โค้ดใหม่
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFG_ALL_BU มาสร้าง -> MKTCRM.SEG.CFG_ALL_BU_T
-- (table 3) -- Run 2 min
-- Step 5: Transpose ข้อมูลจาก BU ให้เป็นคอลัมน์ใหม่
	 SELECT 
	    sbl_member_id,
	    'BU_Rank' AS [_NAME_],
	    [CFM], 
	    [CFR]
	INTO MKTCRM.SEG.CFG_ALL_BU_T  -- เก็บผลลัพธ์ในตารางใหม่
	FROM 
	    (SELECT sbl_member_id, BU, BU_Rank
	     FROM MKTCRM.SEG.CFG_ALL_BU) AS SourceTable
	PIVOT
	    (MAX(BU_Rank) FOR BU IN ([CFM], [CFR])) AS PivotTable;



----------------------------------------------------------------------------------------------------------------------------------

-- Recheck Data
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFG_ALL และ MKTCRM.SEG.CFG_ALL_BU  มาสร้าง -> MKTCRM.SEG.CFG_ALL_GROUP
-- (table 4)
TRUNCATE TABLE MKTCRM.SEG.CFG_ALL_GROUP;

-- ขั้นตอนที่ 1: สร้างตาราง MKTCRM.SEG.CFG_ALL_GROUP
CREATE TABLE MKTCRM.SEG.CFG_ALL_GROUP (
    sbl_member_id VARCHAR(50),              -- ค่าของ sbl_member_id
    CFG_TX float,                         -- ค่าของ CFG_TX
    CFG_Total float,                      -- ค่าของ CFG_Total
    CFG_GP float,                         -- ค่าของ CFG_GP
    CFG_NET_TOTAL float,                 -- ค่าของ CFG_NET_TOTAL
    CFG_GP_PERCENT float,                -- ค่าของ CFG_GP_PERCENT
    CFG_Month_Visit float,               -- ค่าของ CFG_Month_Visit
    CFG_Last_Visit VARCHAR(6),             -- ค่าของ CFG_Last_Visit (ปี-เดือน เช่น '202311')
    rank_total float,                    -- ค่าของ rank_total สำหรับการจัดอันดับ
    CFG_Rank VARCHAR(20),                  -- ค่าของ CFG_Rank (เช่น 'TOP 1%' หรือ 'Bottom 20%')
    CFR_TX float,                        -- ค่าของ CFR_TX
    CFR_TOTAL float,                     -- ค่าของ CFR_TOTAL
    CFR_GP float,                        -- ค่าของ CFR_GP
    CFR_NET_TOTAL float,                 -- ค่าของ CFR_NET_TOTAL
    CFR_GP_PERCENT float,                -- ค่าของ CFR_GP_PERCENT
    CFR_BASKET_SIZE float,               -- ค่าของ CFR_BASKET_SIZE
    CFR_MONTH_VISIT float,               -- ค่าของ CFR_MONTH_VISIT
    CFR_LAST_VISIT VARCHAR(6),             -- ค่าของ CFR_LAST_VISIT (ปี-เดือน)
    CFR_RANK VARCHAR(20),                  -- ค่าของ CFR_RANK
    CFM_TX float,                        -- ค่าของ CFM_TX
    CFM_TOTAL float,                     -- ค่าของ CFM_TOTAL
    CFM_GP float,                        -- ค่าของ CFM_GP
    CFM_NET_TOTAL float,                 -- ค่าของ CFM_NET_TOTAL
    CFM_GP_PERCENT float,                -- ค่าของ CFM_GP_PERCENT
    CFM_BASKET_SIZE float,               -- ค่าของ CFM_BASKET_SIZE
    CFM_MONTH_VISIT float,               -- ค่าของ CFM_MONTH_VISIT
    CFM_LAST_VISIT VARCHAR(6),             -- ค่าของ CFM_LAST_VISIT (ปี-เดือน)
    CFM_RANK VARCHAR(20)                   -- ค่าของ CFM_RANK
);

-- ขั้นตอนที่ 2: การ Insert ข้อมูลลงใน MKTCRM.SEG.CFG_ALL_GROUP จากการคำนวณ
INSERT INTO MKTCRM.SEG.CFG_ALL_GROUP (sbl_member_id, CFG_TX, CFG_Total, CFG_GP, CFG_NET_TOTAL, CFG_GP_PERCENT, CFG_Month_Visit, CFG_Last_Visit)
SELECT 
    sbl_member_id, 
    SUM(tx) AS CFG_TX, 
    SUM(total) AS CFG_Total, 
    SUM(gp) AS CFG_GP, 
    SUM(net_total) AS CFG_NET_TOTAL, 
    CASE 
        WHEN SUM(net_total) = 0 THEN NULL
        ELSE SUM(gp) / SUM(net_total)
    END AS CFG_GP_PERCENT, 
    COUNT(DISTINCT ym) AS CFG_Month_Visit, 
    MAX(ym) AS CFG_Last_Visit
FROM MKTCRM.SEG.CFG_ALL
GROUP BY sbl_member_id;

-- ขั้นตอนที่ 3: การจัดอันดับ (Rank) โดยใช้ NTILE
WITH ranked AS (
    SELECT 
        sbl_member_id,
        NTILE(100) OVER (ORDER BY CFG_Total) AS rank_total
    FROM MKTCRM.SEG.CFG_ALL_GROUP
)
UPDATE MKTCRM.SEG.CFG_ALL_GROUP
SET rank_total = ranked.rank_total
FROM ranked
WHERE MKTCRM.SEG.CFG_ALL_GROUP.sbl_member_id = ranked.sbl_member_id;

-- ขั้นตอนที่ 4: การเพิ่มคอลัมน์ CFG_Rank โดยใช้ CASE WHEN สำหรับการจัดอันดับ
UPDATE MKTCRM.SEG.CFG_ALL_GROUP
SET CFG_Rank = CASE 
        WHEN rank_total >= 99 THEN 'TOP 1%'
        WHEN rank_total >= 90 THEN 'TOP 2-10%'
        WHEN rank_total >= 80 THEN 'TOP 11-20%'
        WHEN rank_total >= 60 THEN 'TOP 21-40%'
        WHEN rank_total >= 40 THEN 'TOP 41-60%'
        WHEN rank_total >= 20 THEN 'TOP 61-80%'
        ELSE 'Bottom 20%'
    END;

-- ขั้นตอนที่ 5: การรวมข้อมูลจาก seg.cfg_all_bu สำหรับ BU ต่างๆ (CFR, CFM)
WITH cfr_data AS (
    SELECT 
        sbl_member_id, 
        tx AS CFR_TX, 
        total AS CFR_TOTAL, 
        gp AS CFR_GP, 
        net_total AS CFR_NET_TOTAL, 
        -- แก้ไขเพื่อหลีกเลี่ยงการหารด้วยศูนย์
        CASE 
            WHEN net_total = 0 THEN NULL
            ELSE gp / net_total
        END AS CFR_GP_PERCENT, 
        CASE 
            WHEN tx = 0 THEN NULL
            ELSE total / tx
        END AS CFR_BASKET_SIZE, 
        mv AS CFR_MONTH_VISIT, 
        lv AS CFR_LAST_VISIT, 
        bu_rank AS CFR_RANK
    FROM seg.cfg_all_bu
    WHERE bu = 'CFR'
),
cfm_data AS (
    SELECT 
        sbl_member_id, 
        tx AS CFM_TX, 
        total AS CFM_TOTAL, 
        gp AS CFM_GP, 
        net_total AS CFM_NET_TOTAL, 
        -- แก้ไขเพื่อหลีกเลี่ยงการหารด้วยศูนย์
        CASE 
            WHEN net_total = 0 THEN NULL
            ELSE gp / net_total
        END AS CFM_GP_PERCENT, 
        CASE 
            WHEN tx = 0 THEN NULL
            ELSE total / tx
        END AS CFM_BASKET_SIZE, 
        mv AS CFM_MONTH_VISIT, 
        lv AS CFM_LAST_VISIT, 
        bu_rank AS CFM_RANK
    FROM seg.cfg_all_bu
    WHERE bu = 'CFM'
)
UPDATE MKTCRM.SEG.CFG_ALL_GROUP 
SET
    CFR_TX = cfr_data.CFR_TX,
    CFR_TOTAL = cfr_data.CFR_TOTAL,
    CFR_GP = cfr_data.CFR_GP,
    CFR_NET_TOTAL = cfr_data.CFR_NET_TOTAL,
    CFR_GP_PERCENT = cfr_data.CFR_GP_PERCENT,
    CFR_BASKET_SIZE = cfr_data.CFR_BASKET_SIZE,
    CFR_MONTH_VISIT = cfr_data.CFR_MONTH_VISIT,
    CFR_LAST_VISIT = cfr_data.CFR_LAST_VISIT,
    CFR_RANK = cfr_data.CFR_RANK,
    CFM_TX = cfm_data.CFM_TX,
    CFM_TOTAL = cfm_data.CFM_TOTAL,
    CFM_GP = cfm_data.CFM_GP,
    CFM_NET_TOTAL = cfm_data.CFM_NET_TOTAL,
    CFM_GP_PERCENT = cfm_data.CFM_GP_PERCENT,
    CFM_BASKET_SIZE = cfm_data.CFM_BASKET_SIZE,
    CFM_MONTH_VISIT = cfm_data.CFM_MONTH_VISIT,
    CFM_LAST_VISIT = cfm_data.CFM_LAST_VISIT,
    CFM_RANK = cfm_data.CFM_RANK
FROM cfr_data
LEFT JOIN cfm_data 
    ON cfr_data.sbl_member_id = cfm_data.sbl_member_id
WHERE MKTCRM.SEG.CFG_ALL_GROUP.sbl_member_id = cfr_data.sbl_member_id;


-- โค้ดเก่า Original
/*
proc sql threads;
create table seg.cfg_all_group (compress = yes) as
select sbl_member_id, sum(tx) as CFG_TX, sum(total) as CFG_Total, sum(gp) as CFG_GP, sum(net_total) as CFG_NET_TOTAL, sum(gp)/sum(net_total) as CFG_GP_PERCENT, count(distinct ym) as CFG_Month_Visit, max(ym) as CFG_Last_Visit
from seg.cfg_all
group by sbl_member_id;
quit; 

proc rank data=seg.cfg_all_group groups=100 out=seg.cfg_all_group;
	var CFG_Total;
	ranks rank_total;
run; 

proc sql threads;
create table seg.cfg_all_group (compress = yes) as
select *,
case when rank_TOTAL >= 99 then 'TOP 1%' else
case when rank_TOTAL >= 90 then 'TOP 2-10%' else
case when rank_TOTAL >= 80 then 'TOP 11-20%' else
case when rank_TOTAL >= 60 then 'TOP 21-40%' else
case when rank_TOTAL >= 40 then 'TOP 41-60%' else 
case when rank_TOTAL >= 20 then 'TOP 61-80%' else 
case when rank_TOTAL is null then 'None' else 'Bottom 20%' end end end end end end end as CFG_Rank
from seg.cfg_all_group;
quit; 

proc sql threads;
create table seg.cfg_all_group (compress = yes) as
select a.*,
b.tx as CFR_TX, B.TOTAL AS CFR_TOTAL, B.GP AS CFR_GP, B.NET_TOTAL AS CFR_NET_TOTAL, B.GP/B.NET_TOTAL AS CFR_GP_PERCENT, B.TOTAL/B.TX AS CFR_BASKET_SIZE, B.MV AS CFR_MONTH_VISIT, B.LV AS CFR_LAST_VISIT, B.BU_RANK AS CFR_RANK,
C.tx as CFM_TX, C.TOTAL AS CFM_TOTAL, C.GP AS CFM_GP, C.NET_TOTAL AS CFM_NET_TOTAL, C.GP/C.NET_TOTAL AS CFM_GP_PERCENT, C.TOTAL/C.TX AS CFM_BASKET_SIZE, C.MV AS CFM_MONTH_VISIT, C.LV AS CFM_LAST_VISIT, C.BU_RANK AS CFM_RANK
/*req. by P'TON - ignore CMK @20231212
,D.tx as CMK_TX, D.TOTAL AS CMK_TOTAL, D.GP AS CMK_GP, D.NET_TOTAL AS CMK_NET_TOTAL, D.GP/D.NET_TOTAL AS CMK_GP_PERCENT, D.TOTAL/D.TX AS CMK_BASKET_SIZE, D.MV AS CMK_MONTH_VISIT, D.LV AS CMK_LAST_VISIT, D.BU_RANK AS CMK_RANK
*/
from seg.cfg_all_group a
left join 
(
	select sbl_member_id, tx, total, gp, net_total, mv, lv, bu_rank
	from seg.cfg_all_bu
	where BU = 'CFR'
)b on a.sbl_member_id = b.sbl_member_id
left join 
(
	select sbl_member_id, tx, total, gp, net_total, mv, lv, bu_rank
	from seg.cfg_all_bu
	where BU = 'CFM'
)c on a.sbl_member_id = c.sbl_member_id
/*req. by P'TON - ignore CMK @20231212
left join 
(
	select sbl_member_id, tx, total, gp, net_total, mv, lv, bu_rank
	from seg.cfg_all_bu
	where BU = 'CMK'
)d on a.sbl_member_id = d.sbl_member_id
*/
;
/*--------> run until here <--------*/
quit; 
/*CFR - HOME_STORE*/
*/


----------------------------------------------------------------------------------------------------------------------------------


-- (table 5) > Run 30 min 
-- ข้อมูลตั้งต้นใหม่ สร้าง -> MKTCRM.SEG.CFR_SGST_All

TRUNCATE TABLE MKTCRM.SEG.CFR_SGST_All;

EXEC SEG.CFR_SGST_ALL_crm;

-- โค้ดใหม่ สำหรับเปรียบเทียบ
/*
CREATE PROCEDURE SEG.CFR_SGST_ALL_crm
AS
BEGIN
    DECLARE @today DATE = GETDATE();  -- กำหนดวันที่ปัจจุบัน
    DECLARE @LM CHAR(6) = FORMAT(DATEADD(MONTH, -1, @today), 'yyyyMM');  -- เดือนล่าสุด (Last Month)
    DECLARE @FM CHAR(6) = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMM');  -- เดือนแรก (First Month)
    DECLARE @cym CHAR(6);  -- ตัวแปรสำหรับวนลูปเดือน

    -- กำหนดค่าเริ่มต้นให้ @cym เท่ากับ @FM (เริ่มจากเดือนแรก)
    SET @cym = @FM;

    -- 1. ตรวจสอบว่าตาราง MKTCRM.SEG.CFR_SGST_All มีอยู่หรือไม่ ถ้าไม่มีให้สร้างใหม่
    IF OBJECT_ID('MKTCRM.SEG.CFR_SGST_All', 'U') IS NULL
    BEGIN
        CREATE TABLE MKTCRM.SEG.CFR_SGST_All (
            ym CHAR(6),
            sbl_member_id NVARCHAR(20),
            ST_CODE CHAR(10),
            tx INT,
            total DECIMAL(18, 2)
        );
    END

    -- 2. ดำเนินการในเดือนแรก (FM)
    IF @cym = @FM
    BEGIN
        -- SQL Dynamic สำหรับ saletrans_td_@FM
        DECLARE @sql1 NVARCHAR(MAX);
        SET @sql1 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                    SELECT @cym AS ym, sbl_member_id, STORE_CODE AS ST_CODE, 
                           COUNT(DISTINCT REFERENCE) AS tx, SUM(SALES) AS total
                    FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @cym + ' a
                    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                    GROUP BY sbl_member_id, STORE_CODE';
        
        -- ส่งค่า @cym ไปยัง SQL Dynamic
        EXEC sp_executesql @sql1, N'@cym CHAR(6)', @cym;

        -- SQL Dynamic สำหรับ saletrans_@FM
        DECLARE @sql2 NVARCHAR(MAX);
        SET @sql2 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                    SELECT @cym AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                    FROM cfhqsasdidb01.topsrst.dbo.saletrans_' + @cym + ' a
                    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                    GROUP BY sbl_member_id, ST_CODE';
        
        -- ส่งค่า @cym ไปยัง SQL Dynamic
        EXEC sp_executesql @sql2, N'@cym CHAR(6)', @cym;

        -- SQL Dynamic สำหรับ saletrans_online_@FM
        DECLARE @sql3 NVARCHAR(MAX);
        SET @sql3 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                    SELECT @cym AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                    FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_' + @cym + ' a
                    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                    GROUP BY sbl_member_id, ST_CODE';
        
        -- ส่งค่า @cym ไปยัง SQL Dynamic
        EXEC sp_executesql @sql3, N'@cym CHAR(6)', @cym;
    END

    -- 3. เริ่มการวนลูปเดือนถัดไปจาก @FM + 1 ถึง @LM
    SET @cym = FORMAT(DATEADD(MONTH, 1, CAST(@FM + '01' AS DATE)), 'yyyyMM');  -- เริ่มจากเดือนถัดไปหลัง @FM

    WHILE @cym <= @LM
    BEGIN
        -- SQL Dynamic สำหรับ saletrans_@cym
        DECLARE @sql4 NVARCHAR(MAX);
        SET @sql4 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                    SELECT @cym AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                    FROM cfhqsasdidb01.topsrst.dbo.saletrans_' + @cym + ' a
                    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                    GROUP BY sbl_member_id, ST_CODE';
        
        -- ส่งค่า @cym ไปยัง SQL Dynamic
        EXEC sp_executesql @sql4, N'@cym CHAR(6)', @cym;

        -- ตรวจสอบเดือนตั้งแต่ 202107 ว่ามีข้อมูลใน saletrans_online_@cym หรือไม่
        IF @cym >= '202107'
        BEGIN
            DECLARE @sql5 NVARCHAR(MAX);
            SET @sql5 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                        SELECT @cym AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                        FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_' + @cym + ' a
                        JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                        GROUP BY sbl_member_id, ST_CODE';
            
            -- ส่งค่า @cym ไปยัง SQL Dynamic
            EXEC sp_executesql @sql5, N'@cym CHAR(6)', @cym;
        END

        -- SQL Dynamic สำหรับ saletrans_td_@cym
        DECLARE @sql6 NVARCHAR(MAX);
        SET @sql6 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                    SELECT @cym AS ym, sbl_member_id, STORE_CODE AS ST_CODE, COUNT(DISTINCT REFERENCE) AS tx, SUM(SALES) AS total
                    FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @cym + ' a
                    JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                    GROUP BY sbl_member_id, STORE_CODE';
        
        -- ส่งค่า @cym ไปยัง SQL Dynamic
        EXEC sp_executesql @sql6, N'@cym CHAR(6)', @cym;

        -- ปรับเดือนถัดไป โดยใช้ DATEADD
        SET @cym = FORMAT(DATEADD(MONTH, 1, CAST(@cym + '01' AS DATE)), 'yyyyMM');
    END;

    -- 4. เพิ่มข้อมูลจาก saletrans_daily สำหรับเดือนล่าสุด
    DECLARE @sql7 NVARCHAR(MAX);
    SET @sql7 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                SELECT @LM AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                FROM cfhqsasdidb01.topsrst.dbo.saletrans_daily a
                JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                WHERE LEFT(CONVERT(VARCHAR, a.ttm2), 6) = @LM
                GROUP BY sbl_member_id, ST_CODE';
    
    -- ส่งค่า @LM ไปยัง SQL Dynamic
    EXEC sp_executesql @sql7, N'@LM CHAR(6)', @LM;

    -- 5. เพิ่มข้อมูลจาก saletrans_online_daily สำหรับเดือนล่าสุด
    DECLARE @sql8 NVARCHAR(MAX);
    SET @sql8 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                SELECT @LM AS ym, sbl_member_id, ST_CODE, COUNT(DISTINCT ref_key) AS tx, SUM(total) AS total
                FROM cfhqsasdidb01.topsrst.dbo.saletrans_online_daily a
                JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                WHERE LEFT(CONVERT(VARCHAR, a.ttm2), 6) = @LM
                GROUP BY sbl_member_id, ST_CODE';
    
    -- ส่งค่า @LM ไปยัง SQL Dynamic
    EXEC sp_executesql @sql8, N'@LM CHAR(6)', @LM;

   
    -- 6. เพิ่มข้อมูลจาก saletrans_td_&LM สำหรับเดือนล่าสุด
    DECLARE @sql9 NVARCHAR(MAX);
    SET @sql9 = N'INSERT INTO MKTCRM.SEG.CFR_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
                SELECT @LM AS ym, sbl_member_id, STORE_CODE AS ST_CODE, COUNT(DISTINCT REFERENCE) AS tx, SUM(SALES) AS total
                FROM cfhqsasdidb01.topsrst.dbo.saletrans_td_' + @LM + ' a
                JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
                WHERE CONVERT(VARCHAR(6), a.trans_date, 112) = @LM
                GROUP BY sbl_member_id, STORE_CODE';
    
    -- ส่งค่า @LM ไปยัง SQL Dynamic
    EXEC sp_executesql @sql9, N'@LM CHAR(6)', @LM;
END;
*/


-- โค้ดเก่า Original
/*
%macro homestore;
%let cym = &FM;
	%do %while (&cym. < &LM.);

		%IF &cym. = &FM. %THEN %DO;

			PROC SQL THREADS;			
			CREATE TABLE seg.CFR_SGST_All (compress= yes) as
			select &cym. as ym, sbl_member_id, STORE_CODE as ST_CODE,count(distinct REFERENCE) as tx, sum(SALES) as total
			from topsrst.saletrans_td_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id,STORE_CODE;
			QUIT;

			PROC SQL THREADS;
			insert into seg.CFR_SGST_All
			select &cym. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
			from topsrst.saletrans_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id, ST_CODE;
			QUIT;
			
			proc sql threads;
			insert into seg.CFR_SGST_All
			select &cym. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
			from topsrst.saletrans_online_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id, ST_CODE;
			QUIT;

		%END;
		%ELSE %DO;

			PROC SQL THREADS;
			INSERT INTO seg.CFR_SGST_All
			select &cym. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
			from topsrst.saletrans_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id, ST_CODE;
			QUIT;
			/* คาดว่า ตั้งแต่ 202107 ถึงมี saletrans_online*/
			%if (&cym. >= 202107) %then %do;
				proc sql threads;
				insert into seg.CFR_SGST_All
				select &cym. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
				from topsrst.saletrans_online_&cym. a
				join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
				group by sbl_member_id, ST_CODE;
				QUIT;
			%end;
			PROC SQL THREADS;
			insert into seg.CFR_SGST_All
			select &cym. as ym, sbl_member_id, STORE_CODE as ST_CODE,count(distinct REFERENCE) as tx, sum(SALES) as total
			from topsrst.saletrans_td_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id,STORE_CODE;
			QUIT;

		%END;
		%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
	              %let cym = %eval(&cym. +89);
	              %end;
	    %else %do; %let cym = %eval(&cym. +1); %end;
	%END;
%MEND;
%homestore; 

proc sql threads;
INSERT INTO seg.CFR_SGST_All
select &LM. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
from topsrst.saletrans_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id, ST_CODE;

insert into seg.CFR_SGST_All
select &LM. as ym, sbl_member_id, ST_CODE, count(distinct ref_key) as tx, sum(total) as total
from topsrst.saletrans_online_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id, ST_CODE;

insert into seg.CFR_SGST_All
select &LM. as ym, sbl_member_id,STORE_CODE as ST_CODE,count(distinct REFERENCE) as tx, sum(SALES) as total
from topsrst.saletrans_td_&LM. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
where put(trans_date,yymmn6.)="&LM."
group by sbl_member_id,STORE_CODE;
quit; 

*/


----------------------------------------------------------------------------------------------------------------------------------

-- Recheck ข้อมูลตอนคำนวณ
-- (table 6) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFR_SGST_All สร้าง -> MKTCRM.SEG.CFR_SGST_All_2

TRUNCATE TABLE MKTCRM.SEG.CFR_SGST_ALL_2;

-- 1. ตรวจสอบว่าตาราง MKTCRM.SEG.CFR_SGST_ALL_2 มีอยู่แล้วหรือไม่
IF OBJECT_ID('MKTCRM.SEG.CFR_SGST_ALL_2', 'U') IS NULL
BEGIN
    -- สร้างตารางหากยังไม่มี
    CREATE TABLE MKTCRM.SEG.CFR_SGST_ALL_2 (
        sbl_member_id NVARCHAR(20),
        ST_CODE CHAR(20),
        tx float,
        total DECIMAL(18, 6),
        p_tx DECIMAL(18, 6),
        p_total DECIMAL(18, 6),
        idx DECIMAL(18, 6)
    );
END;

-- 2. ดึงข้อมูลและคำนวณค่า tx และ total โดยการรวมกลุ่มตาม sbl_member_id, ST_CODE
INSERT INTO MKTCRM.SEG.CFR_SGST_ALL_2 (sbl_member_id, ST_CODE, tx, total)
SELECT sbl_member_id, 
       ST_CODE, 
       SUM(tx) AS tx, 
       SUM(total) AS total
FROM MKTCRM.seg.CFR_SGST_All
GROUP BY sbl_member_id, ST_CODE;

-- 3. คำนวณเปอร์เซ็นต์ของ tx และ total สำหรับแต่ละ sbl_member_id
WITH Percentages AS (
    SELECT sbl_member_id,
           ST_CODE,
           tx, 
           total, 
           SUM(tx) OVER (PARTITION BY sbl_member_id) AS total_tx,
           SUM(total) OVER (PARTITION BY sbl_member_id) AS total_total
    FROM MKTCRM.SEG.CFR_SGST_ALL_2
)
-- Update p_tx and p_total
UPDATE c
SET c.p_tx = CASE 
                 WHEN p.total_tx = 0 THEN 0
                 ELSE p.tx / p.total_tx 
             END,
    c.p_total = CASE 
                    WHEN p.total_total = 0 THEN 0
                    ELSE p.total / p.total_total 
                END
FROM MKTCRM.SEG.CFR_SGST_ALL_2 c
JOIN Percentages p
    ON c.sbl_member_id = p.sbl_member_id
    AND c.ST_CODE = p.ST_CODE;

-- 4. คำนวณค่า idx โดยใช้ p_tx และ p_total
WITH idx_calculation AS (
    SELECT sbl_member_id, 
           ST_CODE, 
           p_tx * 0.6 + p_total * 0.4 AS idx
    FROM MKTCRM.SEG.CFR_SGST_ALL_2
)
-- Update idx
UPDATE c
SET c.idx = i.idx
FROM MKTCRM.SEG.CFR_SGST_ALL_2 c
JOIN idx_calculation i
    ON c.sbl_member_id = i.sbl_member_id
    AND c.ST_CODE = i.ST_CODE;


-- โค้ดเก่า backup
/*
proc sql threads;
create table seg.cfr_sgst_all_2 (compress = yes) as
select sbl_member_id, ST_CODE, sum(tx) as tx, sum(total) as total
from seg.CFR_SGST_All
group by sbl_member_id, ST_CODE;
QUIT; 

proc sql threads;
create table seg.cfr_sgst_all_2 (compress = yes) as
select *, tx/sum(tx) as p_tx, total/sum(total) as p_total
from seg.cfr_sgst_all_2
group by sbl_member_id;
QUIT; 

proc sql threads;
create table seg.cfr_sgst_all_2 (compress = yes) as
select *, p_tx*0.6+p_total*0.4 as idx
from seg.cfr_sgst_all_2;
/*--------> run until here <--------*/
QUIT; 
*/


----------------------------------------------------------------------------------------------------------------------------------

-- (table 7,8) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFR_SGST_All_2 สร้าง -> MKTCRM.SEG.CFR_SGST_All_3 , MKTCRM.SEG.CFR_SGST_ALL_3_SALE 

TRUNCATE TABLE MKTCRM.SEG.CFR_SGST_All_3;
TRUNCATE TABLE MKTCRM.SEG.CFR_SGST_ALL_3_SALE;

-- 1. ตรวจสอบว่าตาราง cfr_sgst_all_3 มีอยู่หรือไม่ ถ้ายังไม่มีก็สร้างใหม่
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CFR_SGST_ALL_3' AND TABLE_SCHEMA = 'SEG' AND TABLE_CATALOG = 'MKTCRM')
BEGIN
    CREATE TABLE MKTCRM.SEG.CFR_SGST_ALL_3 (
        sbl_member_id NVARCHAR(20),
        ST_CODE CHAR(20),
        tx FLOAT,
        total DECIMAL(18, 6),
        p_tx DECIMAL(18, 6),
        p_total DECIMAL(18, 6),
        idx DECIMAL(18, 6),
        rank INT -- เพิ่มคอลัมน์ rank เพื่อเก็บอันดับ
    );
END;

-- 2. นำข้อมูลจาก cfr_sgst_all_2 มาสร้างตาราง cfr_sgst_all_3
INSERT INTO MKTCRM.SEG.CFR_SGST_ALL_3 (sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx)
SELECT sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx
FROM MKTCRM.seg.cfr_sgst_all_2
ORDER BY SBL_MEMBER_ID, idx DESC;

-- 3. คำนวณอันดับ (rank) สำหรับแต่ละ SBL_MEMBER_ID ตาม idx โดยใช้ ROW_NUMBER() ผ่าน CTE
WITH RankedData AS (
    SELECT sbl_member_id, idx, -- ไม่ต้องเลือก rank ที่นี่
           ROW_NUMBER() OVER (PARTITION BY SBL_MEMBER_ID ORDER BY idx DESC) AS rank
    FROM MKTCRM.SEG.CFR_SGST_ALL_3
)
-- 4. อัปเดตตาราง cfr_sgst_all_3 โดยใช้ข้อมูลจาก CTE
UPDATE A
SET A.rank = B.rank
FROM MKTCRM.SEG.CFR_SGST_ALL_3 A
JOIN RankedData B ON A.sbl_member_id = B.sbl_member_id AND A.idx = B.idx;

-- 5. เลือกเฉพาะแถวที่ rank = 1 และอัปเดตตาราง cfr_sgst_all_3
DELETE FROM MKTCRM.SEG.CFR_SGST_ALL_3
WHERE rank != 1;

-- 6. ตรวจสอบว่าตาราง cfr_sgst_all_3_SALE มีอยู่หรือไม่ ถ้ายังไม่มีก็สร้างใหม่
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CFR_SGST_ALL_3_SALE' AND TABLE_SCHEMA = 'SEG' AND TABLE_CATALOG = 'MKTCRM')
BEGIN
    CREATE TABLE MKTCRM.SEG.CFR_SGST_ALL_3_SALE (
        sbl_member_id NVARCHAR(20),
        ST_CODE CHAR(20),
        tx FLOAT,
        total DECIMAL(18, 6),
        p_tx DECIMAL(18, 6),
        p_total DECIMAL(18, 6),
        idx DECIMAL(18, 6),
        rank INT, -- เพิ่มคอลัมน์ rank เพื่อเก็บอันดับ
        ST_MOST_SPENDING NVARCHAR(60),
        ST_MOST_SPENDING_NAME NVARCHAR(60),
        ST_MOST_SPENDING_FORMAT NVARCHAR(60),
        ST_MOST_SPENDING_LOCATION NVARCHAR(60)
    );
END;

-- 7. นำข้อมูลจาก cfr_sgst_all_2 มาสร้างตาราง cfr_sgst_all_3_SALE
INSERT INTO MKTCRM.SEG.CFR_SGST_ALL_3_SALE (sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx)
SELECT sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx
FROM MKTCRM.seg.cfr_sgst_all_2
ORDER BY SBL_MEMBER_ID, TOTAL DESC;

-- 8. คำนวณอันดับ (rank) สำหรับแต่ละ SBL_MEMBER_ID ตาม TOTAL โดยใช้ ROW_NUMBER() ผ่าน CTE
WITH RankedSaleData AS (
    SELECT sbl_member_id, total, -- ไม่ต้องเลือก rank ที่นี่
           ROW_NUMBER() OVER (PARTITION BY SBL_MEMBER_ID ORDER BY TOTAL DESC) AS rank
    FROM MKTCRM.SEG.CFR_SGST_ALL_3_SALE
)
-- 9. อัปเดตตาราง cfr_sgst_all_3_SALE โดยใช้ข้อมูลจาก CTE
UPDATE A
SET A.rank = B.rank
FROM MKTCRM.SEG.CFR_SGST_ALL_3_SALE A
JOIN RankedSaleData B ON A.sbl_member_id = B.sbl_member_id AND A.total = B.total;

-- 10. เลือกเฉพาะแถวที่ rank = 1 และอัปเดตตาราง cfr_sgst_all_3_SALE
DELETE FROM MKTCRM.SEG.CFR_SGST_ALL_3_SALE
WHERE rank != 1;

-- 11. การ JOIN cfr_sgst_all_3_SALE กับ D_STORE และอัปเดตตาราง cfr_sgst_all_3_SALE
WITH StoreData AS (
    SELECT B.STORE_CODE, B.STORE_NAME, B.STORE_FORMAT, B.STORE_LOCATION
    FROM cfhqsasdidb01.topsrst.dbo.D_STORE B
)
UPDATE A
SET A.ST_MOST_SPENDING = A.ST_CODE,
    A.ST_MOST_SPENDING_NAME = S.STORE_NAME,
    A.ST_MOST_SPENDING_FORMAT = S.STORE_FORMAT,
    A.ST_MOST_SPENDING_LOCATION = S.STORE_LOCATION
FROM MKTCRM.SEG.CFR_SGST_ALL_3_SALE A
LEFT JOIN StoreData S ON A.ST_CODE = S.STORE_CODE;


-- โค้ดเก่า backup
/*
proc sql threads;
create table seg.cfr_sgst_all_3 (compress = yes) as
select *
from seg.cfr_sgst_all_2
order by SBL_MEMBER_ID, idx desc;
QUIT; 

data seg.cfr_sgst_all_3 (compress = yes);
set seg.cfr_sgst_all_3;
by sbl_member_id;
rank +1;
if first.sbl_member_id then rank = 1;
run; 

data seg.cfr_sgst_all_3 (compress = yes);
set seg.cfr_sgst_all_3;
where rank = 1;
run; 

proc sql threads;
create table seg.cfr_sgst_all_3_SALE (compress = yes) as
select *
from seg.cfr_sgst_all_2
order by SBL_MEMBER_ID, TOTAL desc;
QUIT; 

data seg.cfr_sgst_all_3_SALE (compress = yes);
set seg.cfr_sgst_all_3_SALE;
by sbl_member_id;
rank +1;
if first.sbl_member_id then rank = 1;
run; 

data seg.cfr_sgst_all_3_SALE (compress = yes);
set seg.cfr_sgst_all_3_SALE;
where rank = 1;
run; 

PROC SQL THREADS;
CREATE TABLE SEG.cfr_sgst_all_3_SALE (compress= yes) AS
SELECT A.*, A.ST_CODE AS ST_MOST_SPENDING 'ST_MOST_SPENDING', STORE_NAME AS ST_MOST_SPENDING_NAME 'ST_MOST_SPENDING_NAME', B.STORE_FORMAT AS ST_MOST_SPENDING_FORMAT 'ST_MOST_SPENDING_FORMAT', B.STORE_LOCATION AS st_most_SPENDING_location 'st_most_SPENDING_location'
FROM SEG.cfr_sgst_all_3_SALE A
LEFT JOIN TOPSRST.D_STORE B ON A.ST_CODE = B.STORE_CODE;
*/


----------------------------------------------------------------------------------------------------------------------------------

-- (table 9) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFR_SGST_All_2 สร้าง -> MKTCRM.SEG.CFR_SGST_All_3_TXN

TRUNCATE TABLE MKTCRM.SEG.CFR_SGST_ALL_3_TXN;

-- 1. สร้างตาราง cfr_sgst_all_3_TXN
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'SEG' AND TABLE_NAME = 'CFR_SGST_ALL_3_TXN')
BEGIN
	CREATE TABLE MKTCRM.SEG.CFR_SGST_ALL_3_TXN (
		sbl_member_id NVARCHAR(20),
		ST_CODE CHAR(20),
		tx FLOAT,
		total DECIMAL(18, 6),
		p_tx DECIMAL(18, 6),
		p_total DECIMAL(18, 6),
		idx DECIMAL(18, 6),
		rank INT, -- เพิ่มคอลัมน์ rank เพื่อเก็บอันดับ
		ST_MOST_FREQ NVARCHAR(50), -- เพิ่มคอลัมน์ ST_MOST_FREQ
		ST_MOST_FREQ_NAME NVARCHAR(50), -- เพิ่มคอลัมน์ ST_MOST_FREQ_NAME
		ST_MOST_FREQ_FORMAT NVARCHAR(50), -- เพิ่มคอลัมน์ ST_MOST_FREQ_FORMAT
		ST_MOST_FREQ_LOCATION NVARCHAR(50) -- เพิ่มคอลัมน์ ST_MOST_FREQ_LOCATION
	);
END;

-- 2. นำข้อมูลจาก seg.cfr_sgst_all_2 มาสร้างตาราง cfr_sgst_all_3_TXN และจัดเรียงข้อมูลตาม SBL_MEMBER_ID และ TX
INSERT INTO MKTCRM.SEG.CFR_SGST_ALL_3_TXN (sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx)
SELECT sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx
FROM MKTCRM.SEG.cfr_sgst_all_2
ORDER BY sbl_member_id, tx DESC;

-- 3. คำนวณอันดับ (rank) สำหรับแต่ละ SBL_MEMBER_ID ตาม tx โดยใช้ ROW_NUMBER()
WITH RankedData AS (
    SELECT sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx,
           ROW_NUMBER() OVER (PARTITION BY sbl_member_id ORDER BY tx DESC) AS rank
    FROM MKTCRM.SEG.CFR_SGST_ALL_3_TXN
)
-- 4. อัปเดตตาราง cfr_sgst_all_3_TXN ด้วย rank ที่คำนวณได้โดยใช้ JOIN
UPDATE A
SET A.rank = R.rank
FROM MKTCRM.SEG.CFR_SGST_ALL_3_TXN A
JOIN RankedData R
    ON A.sbl_member_id = R.sbl_member_id
    AND A.idx = R.idx;

-- 5. ลบแถวที่ไม่ใช่ rank = 1
DELETE FROM MKTCRM.SEG.CFR_SGST_ALL_3_TXN
WHERE rank != 1;

-- 6. การ JOIN cfr_sgst_all_3_TXN กับ D_STORE และอัปเดตตาราง cfr_sgst_all_3_TXN
WITH StoreData AS (
    SELECT STORE_CODE, STORE_NAME, STORE_FORMAT, STORE_LOCATION
    FROM cfhqsasdidb01.TOPSRST.dbo.D_STORE
)
UPDATE A
SET A.ST_MOST_FREQ = A.ST_CODE,
    A.ST_MOST_FREQ_NAME = S.STORE_NAME,
    A.ST_MOST_FREQ_FORMAT = S.STORE_FORMAT,
    A.ST_MOST_FREQ_LOCATION = S.STORE_LOCATION
FROM MKTCRM.SEG.CFR_SGST_ALL_3_TXN A
LEFT JOIN StoreData S ON A.ST_CODE = S.STORE_CODE;


-- โค้ดเก่า Backup
/*
proc sql threads;
create table seg.cfr_sgst_all_3_TXN (compress = yes) as
select *
from seg.cfr_sgst_all_2
order by SBL_MEMBER_ID, TX desc;
QUIT; 

data seg.cfr_sgst_all_3_TXN (compress = yes);
set seg.cfr_sgst_all_3_TXN;
by sbl_member_id;
rank +1;
if first.sbl_member_id then rank = 1;
run;

data seg.cfr_sgst_all_3_TXN (compress = yes);
set seg.cfr_sgst_all_3_TXN;
where rank = 1;
run;

PROC SQL THREADS;
CREATE TABLE SEG.cfr_sgst_all_3_TXN (compress= yes) AS
SELECT A.*, A.ST_CODE AS ST_MOST_FREQ 'ST_MOST_FREQ', STORE_NAME AS ST_MOST_FREQ_NAME 'ST_MOST_FREQ_NAME', B.STORE_FORMAT AS ST_MOST_FREQ_FORMAT 'ST_MOST_FREQ_FORMAT', B.STORE_LOCATION AS st_most_freq_location 'st_most_freq_location'
FROM SEG.cfr_sgst_all_3_TXN A
LEFT JOIN TOPSRST.D_STORE B ON A.ST_CODE = B.STORE_CODE;
QUIT;
*/


----------------------------------------------------------------------------------------------------------------------------------

-- (table 10) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFR_SGST_All_3 , MKTCRM.SEG.cfr_sgst_all_3_TX สร้าง -> MKTCRM.SEG.CFR_HS

TRUNCATE TABLE MKTCRM.SEG.CFR_HS;

-- 1. ตรวจสอบว่ามีตาราง MKTCRM.SEG.CFR_HS อยู่แล้วหรือไม่ ถ้ายังไม่มีให้สร้าง
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'SEG' AND TABLE_NAME = 'CFR_HS')
BEGIN
    -- 2. สร้างตาราง MKTCRM.SEG.CFR_HS
    CREATE TABLE MKTCRM.SEG.CFR_HS (
        sbl_memBer_id NVARCHAR(20),
        CFR_HOME_STORE_CODE CHAR(20),
        CFR_HOME_STORE NVARCHAR(50),
        CFR_HOME_STORE_FORMAT NVARCHAR(50),
        CFR_HOME_STORE_LOCATION NVARCHAR(50),
        ST_MOST_FREQ_TX NVARCHAR(50),
        ST_MOST_FREQ NVARCHAR(50),
        ST_MOST_FREQ_NAME NVARCHAR(50),
        ST_MOST_FREQ_FORMAT NVARCHAR(50),
        ST_MOST_FREQ_LOCATION NVARCHAR(50),
        ST_MOST_SPENDING_SALE DECIMAL(18, 6),
        ST_MOST_SPENDING NVARCHAR(50),
        ST_MOST_SPENDING_NAME NVARCHAR(50),
        ST_MOST_SPENDING_FORMAT NVARCHAR(50),
        ST_MOST_SPENDING_LOCATION NVARCHAR(50)
    );
END;

-- 3. ทำการ INSERT ข้อมูลจาก cfr_sgst_all_3 และ D_STORE ไปยัง MKTCRM.SEG.CFR_HS
INSERT INTO MKTCRM.SEG.CFR_HS (sbl_memBer_id, CFR_HOME_STORE_CODE, CFR_HOME_STORE, CFR_HOME_STORE_FORMAT, CFR_HOME_STORE_LOCATION)
SELECT A.sbl_memBer_id, 
       A.st_code AS CFR_HOME_STORE_CODE, 
       B.STORE_NAME AS CFR_HOME_STORE, 
       B.STORE_FORMAT AS CFR_HOME_STORE_FORMAT, 
       B.STORE_LOCATION AS CFR_HOME_STORE_LOCATION
FROM MKTCRM.SEG.CFR_SGST_ALL_3 A
LEFT JOIN cfhqsasdidb01.TOPSRST.dbo.D_STORE B ON A.ST_CODE = B.STORE_CODE;

-- 4. ทำการอัปเดตข้อมูลในตาราง MKTCRM.SEG.CFR_HS ด้วยข้อมูลจาก cfr_sgst_all_3_TXN และ cfr_sgst_all_3_SALE
UPDATE MKTCRM.SEG.CFR_HS
SET ST_MOST_FREQ_TX = B.TX,
    ST_MOST_FREQ = B.ST_MOST_FREQ,
    ST_MOST_FREQ_NAME = B.ST_MOST_FREQ_NAME,
    ST_MOST_FREQ_FORMAT = B.ST_MOST_FREQ_FORMAT,
    ST_MOST_FREQ_LOCATION = B.ST_MOST_FREQ_LOCATION,
    ST_MOST_SPENDING_SALE = C.TOTAL,
    ST_MOST_SPENDING = C.ST_MOST_SPENDING,
    ST_MOST_SPENDING_NAME = C.ST_MOST_SPENDING_NAME,
    ST_MOST_SPENDING_FORMAT = C.ST_MOST_SPENDING_FORMAT,
    ST_MOST_SPENDING_LOCATION = C.ST_MOST_SPENDING_LOCATION
FROM MKTCRM.SEG.CFR_HS A
LEFT JOIN MKTCRM.SEG.CFR_SGST_ALL_3_TXN B ON A.sbl_memBer_id = B.sbl_memBer_id
LEFT JOIN MKTCRM.SEG.CFR_SGST_ALL_3_SALE C ON A.sbl_memBer_id = C.sbl_memBer_id;


-- โค้ดเก่า BackUp
/*
PROC SQL THREADS;
CREATE TABLE SEG.CFR_HS (compress= yes) AS
SELECT A.sbl_memBer_id, a.st_code as CFR_HOME_STORE_CODE, B.STORE_NAME AS CFR_HOME_STORE, B.STORE_FORMAT AS CFR_HOME_STORE_FORMAT, B.STORE_LOCATION AS CFR_HOME_STORE_LOCATION
FROM SEG.cfr_sgst_all_3 A
LEFT JOIN TOPSRST.D_STORE B ON A.ST_CODE = B.STORE_CODE;
QUIT;

PROC SQL THREADS;
CREATE TABLE SEG.CFR_HS (compress= yes) AS
SELECT A.*, 
B.TX as ST_MOST_FREQ_TX 'ST_MOST_FREQ_TX',
B.ST_MOST_FREQ,
B.ST_MOST_FREQ_NAME,
B.ST_MOST_FREQ_FORMAT,
B.ST_MOST_FREQ_LOCATION,
C.TOTAL as ST_MOST_SPENDING_SALE 'ST_MOST_SPENDING_SALE',
C.ST_MOST_SPENDING,
C.ST_MOST_SPENDING_NAME,
C.ST_MOST_SPENDING_FORMAT,
C.ST_MOST_SPENDING_LOCATION
FROM SEG.CFR_HS A
LEFT JOIN SEG.cfr_sgst_all_3_TXN B ON A.sbl_memBer_id = B.sbl_memBer_id
LEFT JOIN SEG.cfr_sgst_all_3_SALE C ON A.sbl_memBer_id = C.sbl_memBer_id;
*/


----------------------------------------------------------------------------------------------------------------------------------


-- (table 9) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFG_ALL_GROUP , MKTCRM.SEG.CFR_HS สร้าง -> MKTCRM.SEG.CRM_SINGLE_VIEW_&SEGNAME
-- รับค่า @SEGNAME GETDATE()

-- รันแยกเป็นแต่ละ Quarter

-- ขั้นตอนที่ 1: คำนวณปีที่แล้ว และเดือนปัจจุบัน


DECLARE @today DATE = GETDATE();

DECLARE @yyyy_lm INT,      -- ปีที่แล้ว
        @yy_lm INT,         -- ปีที่แล้ว (สองหลัก)
        @mm_lm INT,         -- เดือนปัจจุบัน
        @SEGNAME NVARCHAR(10);  -- ตัวแปรที่จะเก็บค่า SEGNAME

-- คำนวณปีและเดือน
SET @yyyy_lm = YEAR(DATEADD(MONTH, -1, @today));  -- ปีที่แล้ว
SET @yy_lm = YEAR(DATEADD(MONTH, -1, @today)) % 100;  -- ปีที่แล้ว (สองหลัก)
SET @mm_lm = MONTH(DATEADD(MONTH, -1, @today));  -- เดือนปัจจุบัน

-- คำนวณ Quarter (Q1-Q4) ตามเดือน
IF @mm_lm IN (1, 2, 3) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q1';
ELSE IF @mm_lm IN (4, 5, 6) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q2';
ELSE IF @mm_lm IN (7, 8, 9) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q3';
ELSE IF @mm_lm IN (10, 11, 12) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q4';

-- แสดงผลลัพธ์ของ SEGNAME
--SELECT @SEGNAME AS SEGNAME;

-- ขั้นตอนที่ 2: เช็คว่ามีตาราง CRM_SINGLE_VIEW_&SEGNAME อยู่แล้วหรือไม่
DECLARE @sql_create NVARCHAR(MAX);
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CRM_SINGLE_VIEW_' + @SEGNAME AND schema_id = SCHEMA_ID('SEG'))
BEGIN
    -- ถ้าตารางไม่มีอยู่ในฐานข้อมูลให้สร้างใหม่
    SET @sql_create = N'
    CREATE TABLE MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' (
        --คอลัมน์ดึงมาจาก CFG_ALL_GROUP
		sbl_member_id VARCHAR(50),              -- ค่าของ sbl_member_id
	    CFG_TX float,                         -- ค่าของ CFG_TX
	    CFG_Total float,                      -- ค่าของ CFG_Total
	    CFG_GP float,                         -- ค่าของ CFG_GP
	    CFG_NET_TOTAL float,                 -- ค่าของ CFG_NET_TOTAL
	    CFG_GP_PERCENT float,                -- ค่าของ CFG_GP_PERCENT
	    CFG_Month_Visit float,               -- ค่าของ CFG_Month_Visit
	    CFG_Last_Visit VARCHAR(6),            
	    rank_total float,                    -- ค่าของ rank_total สำหรับการจัดอันดับ
	    CFG_Rank VARCHAR(20),                  -- ค่าของ CFG_Rank 
	    CFR_TX float,                        -- ค่าของ CFR_TX
	    CFR_TOTAL float,                     -- ค่าของ CFR_TOTAL
	    CFR_GP float,                        -- ค่าของ CFR_GP
	    CFR_NET_TOTAL float,                 -- ค่าของ CFR_NET_TOTAL
	    CFR_GP_PERCENT float,                -- ค่าของ CFR_GP_PERCENT
	    CFR_BASKET_SIZE float,               -- ค่าของ CFR_BASKET_SIZE
	    CFR_MONTH_VISIT float,               -- ค่าของ CFR_MONTH_VISIT
	    CFR_LAST_VISIT VARCHAR(6),             -- ค่าของ CFR_LAST_VISIT (ปี-เดือน)
	    CFR_RANK VARCHAR(20),                  -- ค่าของ CFR_RANK
	    CFM_TX float,                        -- ค่าของ CFM_TX
	    CFM_TOTAL float,                     -- ค่าของ CFM_TOTAL
	    CFM_GP float,                        -- ค่าของ CFM_GP
	    CFM_NET_TOTAL float,                 -- ค่าของ CFM_NET_TOTAL
	    CFM_GP_PERCENT float,                -- ค่าของ CFM_GP_PERCENT
	    CFM_BASKET_SIZE float,               -- ค่าของ CFM_BASKET_SIZE
	    CFM_MONTH_VISIT float,               -- ค่าของ CFM_MONTH_VISIT
	    CFM_LAST_VISIT VARCHAR(6),             -- ค่าของ CFM_LAST_VISIT (ปี-เดือน)
	    CFM_RANK VARCHAR(20),                   -- ค่าของ CFM_RANK
        
        -- คอลัมน์ที่ดึงมาจาก CFR_HS
        CFR_HOME_STORE_CODE CHAR(20),
        CFR_HOME_STORE NVARCHAR(50),
        CFR_HOME_STORE_FORMAT NVARCHAR(50),
        CFR_HOME_STORE_LOCATION NVARCHAR(50),
        ST_MOST_FREQ_TX NVARCHAR(50),
        ST_MOST_FREQ NVARCHAR(50),
        ST_MOST_FREQ_NAME NVARCHAR(50),
        ST_MOST_FREQ_FORMAT NVARCHAR(50),
        ST_MOST_FREQ_LOCATION NVARCHAR(50),
        ST_MOST_SPENDING_SALE DECIMAL(18, 6),
        ST_MOST_SPENDING NVARCHAR(50),
        ST_MOST_SPENDING_NAME NVARCHAR(50),
        ST_MOST_SPENDING_FORMAT NVARCHAR(50),
        ST_MOST_SPENDING_LOCATION NVARCHAR(50),
        Visit_group VARCHAR(20), 
       CFM_HOME_STORE_CODE CHAR(10),             -- คอลัมน์ CFM_HOME_STORE_CODE
       CFM_HOME_STORE NVARCHAR(100),            -- คอลัมน์ CFM_HOME_STORE
       CFM_HOME_STORE_FORMAT NVARCHAR(50),      -- คอลัมน์ CFM_HOME_STORE_FORMAT
       CFM_HOME_STORE_LOCATION NVARCHAR(100),   -- คอลัมน์ CFM_HOME_STORE_LOCATION
       CFG_HOME_STORE_CODE CHAR(50),             -- คอลัมน์ CFM_HOME_STORE_CODE
       CFG_HOME_STORE NVARCHAR(100),            -- คอลัมน์ CFM_HOME_STORE
       CFG_HOME_STORE_FORMAT NVARCHAR(50),      -- คอลัมน์ CFM_HOME_STORE_FORMAT
       CFG_HOME_STORE_LOCATION NVARCHAR(100),
       CFR_TOP_CUSTOMER_GP_E CHAR(50),             -- คอลัมน์ CFR_TOP_CUSTOMER_GP_E
	    Month_on_book NVARCHAR(50),                 -- คอลัมน์ Month_on_book
	    SEGMENT_GP_E NVARCHAR(50),                  -- คอลัมน์ SEGMENT_GP_E
	    SEGMENT_NO_GP_E NVARCHAR(50),               -- คอลัมน์ SEGMENT_NO_GP_E
	    CFR_COMPANY_RANK NVARCHAR(50),
	    
	    Purchasing_interval float,
	    Flag_Staff_CFG NVARCHAR(50),
	    Flag_Staff_Others NVARCHAR(50),
	    MARITALSTATUS NVARCHAR(50),
	    Age float,
	    Gender NVARCHAR(50),
	    Age_Range NVARCHAR(50),
	    Generation NVARCHAR(50),
	    Month_Of_Birth float,
	    Education_Level NVARCHAR(50),
	    HH_Income NVARCHAR(50),
	    Occupation NVARCHAR(50),
	    Customer_Type NVARCHAR(50),
	    AVG_ITEM_PER_TX float,
	    CLASS_PER_TX float,
	    S_0101_Snack float,
	    S_0102_Packaged float,
	    S_0103_Cooking float,
	    S_0105_Milk_Baby_Food float,
	    S_0106_Beverage float,
	    S_0107_Inter_Packaged float,
	    S_0108_Inter_Cooking float,
	    S_0201_Cleaning float,
	    S_0202_Home_Care float,
	    S_0203_Adult_Baby_Care float,
	    S_0205_GM float,
	    S_0206_Appliances float,
	    S_0207_Fashion float,
	    S_0208_GM_Non_FMCG float,
	    S_0401_Makeup float,
	    S_0402_Skin_Care float,
	    S_0403_Oral_Care float,
	    S_0404_Hair_Care float,
	    S_0405_Adult_Hygiene float,
	    S_0407_OTOP float,
	    S_0408_Health float,
	    S_0501_Fresh_Packaged float,
	    S_0502_Deli float,
	    S_0503_Bakery float,
	    S_0504_RTE_Deli float,
	    S_0505_Fresh_Meat float,
	    S_0506_Fresh_Seafood float,
	    S_0507_Produce float,
	    S_0508_Food_Story float,
	    S_0601_Spirits float,
	    S_0602_Wine float,
	    S_0605_Beer float,
	    S_0606_Tobacco float,
	    S_0801_Top_up float,
	    S_0901_Western_Delicacies float,
	    S_0902_Inter_Fresh_Packaged float,
	    S_0903_Segafredo float,
	    Pay_by_Cash float,
	    Pay_by_credit float,
	    Pay_by_Voucher float,
	    Pay_by_Point float,
	    Pay_by_Mobile float,
	    Pay_by_E_Payment float,
	    tx_KTC float,
	    tx_KBANK float,
	    tx_CENTRAL float,
	    tx_JCB float,
	    tx_CITIBANK float,
	    tx_SCB float,
	    tx_BBL float,
	    tx_KRUNGSRI float,
	    tx_SIMPLE float,
	    tx_CUPC float,
	    tx_UOB float,
	    tx_TMB float,
	    tx_INTER float,
	    tx_KRUNGSRIFIRSTCHOICE float,
	    tx_AEON float,
	    tx_TBANK float,
	    tx_AMEX float,
	    tx_DINERS float,
	    b2s float,
	    cds float,
	    CFM float,
	    COL float,
	    HWS float,
	    OFM float,
	    PWB float,
	    RBS float,
	    SSP float,
	    cc_tx float,
	    cc_total float,
	    cc_gp float,
	    cc_net_total float,
	    tol_tx float,
	    tol_total float,
	    tol_gp float,
	    tol_net_total float,
	    tol_month_visit float,
	    S_Saturday float,
	    S_Sunday float,
	    S_Tuesday float,
	    S_Wednesday float,
	    S_Friday float,
	    S_Monday float,
	    S_Thursday float,
	    S_10_00___13_59 float,
	    S_14_00___16_59 float,
	    S_17_00___19_59 float,
	    S_After_20_00 float,
	    S_Before_10_00 float,
	    S_Weekend float,
	    S_Weekday float,
	    S_WeekdayBefore_10_00 float,
	    S_Weekday10_00___13_59 float,
	    S_Weekday14_00___16_59 float,
	    S_Weekday17_00___19_59 float,
	    S_WeekdayAfter_20_00 float,
	    S_WeekendBefore_10_00 float,
	    S_Weekend10_00___13_59 float,
	    S_Weekend14_00___16_59 float,
	    S_Weekend17_00___19_59 float,
	    S_WeekendAfter_20_00 float,
	    CFR_TOTAL_E float,
	    CFR_GP_E float,
	    CFR_NET_TOTAL_E float,
	    FLAG_REDEEM NVARCHAR(50),
	    FLAG_CREDIT_CARD NVARCHAR(50),
	    bu_register NVARCHAR(50),
	    dateofbirth NVARCHAR(50),
	    declared_gender NVARCHAR(50),
	    declared_marital_status NVARCHAR(50),
	    is_cg_expat NVARCHAR(50),
	    member_number NVARCHAR(50),
	    member_status NVARCHAR(50),
	    nationality NVARCHAR(50),
	    registerdate NVARCHAR(50),
	    share_card_flag NVARCHAR(50),
	    the1_app_user NVARCHAR(50),
	    the1_inter NVARCHAR(50),
	    have_kids NVARCHAR(50),
	    kids_stage NVARCHAR(50),
	    address_province NVARCHAR(50),
	    address_zipcode NVARCHAR(50),
	    most_visit_location NVARCHAR(50),
	    most_visit_province NVARCHAR(50),
	    most_visit_subregion NVARCHAR(50),
	    most_freq_creditcard_bank NVARCHAR(50),
	    most_freq_creditcard_face NVARCHAR(50),
	    payment_segment NVARCHAR(50),
	    creditcard_the1_face NVARCHAR(50),
	    online_cg_spending_l1y NVARCHAR(50),
	    beauty_luxury_segment NVARCHAR(50),
	    beauty_segment NVARCHAR(50),
	    fashion_luxury_segment NVARCHAR(50),
	    food_healthy_flag NVARCHAR(50),
	    food_luxury_segment NVARCHAR(50),
	    electronics_luxury_segment NVARCHAR(50),
	    point_lover_segment NVARCHAR(50),
	    tierpointbalance NVARCHAR(50),
	    consent_flag NVARCHAR(50),
	    is_active_cfr_l1y NVARCHAR(50),
	    is_address NVARCHAR(50),
	    is_address_cfr NVARCHAR(50),
	    is_call_cfr NVARCHAR(50),
	    is_cfr_line NVARCHAR(50),
	    is_email NVARCHAR(50),
	    is_email_cfr NVARCHAR(50),
	    is_send_sms_eng NVARCHAR(50),
	    is_send_sms_eng_cfr NVARCHAR(50),
	    is_send_sms_thai NVARCHAR(50),
	    is_send_sms_thai_cfr NVARCHAR(50),
	    is_the1_line NVARCHAR(50),
	    iscall NVARCHAR(50),
	    line_the1_latest_linked_date NVARCHAR(50),
	    app_active NVARCHAR(50),
	    app_redeem NVARCHAR(50),
	    have_dolfin_app NVARCHAR(50),
	    online_affinity_segment NVARCHAR(50),
	    cg_ranking_2018 NVARCHAR(50),
	    cg_ranking_2019 NVARCHAR(50),
	    cg_ranking_2020 NVARCHAR(50),
	    cg_ranking_2021 NVARCHAR(50),
	    cg_ranking_2022 NVARCHAR(50),
	    cg_ranking_2023 NVARCHAR(50),
	    wealth_segment NVARCHAR(50),
	    cfr_main_competitor NVARCHAR(50),
	    cfr_main_competitor_type NVARCHAR(50),
	    cfr_ranking_2018 NVARCHAR(50),
	    cfr_ranking_2019 NVARCHAR(50),
	    cfr_ranking_2020 NVARCHAR(50),
	    cfr_ranking_2021 NVARCHAR(50),
	    cfr_ranking_2022 NVARCHAR(50),
	    cfr_ranking_2023 NVARCHAR(50),
	    cfr_share_of_wallet_q1 NVARCHAR(50),
	    cfr_share_of_wallet_q2 NVARCHAR(50),
	    cfr_share_of_wallet_q3 NVARCHAR(50),
	    cfr_share_of_wallet_q4 NVARCHAR(50),
	    have_cfr_app NVARCHAR(50),
	    coffee_segment NVARCHAR(50),
	    dining_luxury_segment NVARCHAR(50),
	    healthy_lifestyle_preferred NVARCHAR(50),
	    home_cooking_flag NVARCHAR(50),
	    liquor_drinker NVARCHAR(50),
	    pet_lover_segment NVARCHAR(50),
	    have_car NVARCHAR(50),
	    beauty_discount_sensitivity NVARCHAR(50),
	    fashion_discount_sensitivity NVARCHAR(50),
	    food_grocery_discount_sensitivit NVARCHAR(50),
	    home_electronics_discount_sensit NVARCHAR(50),
	    home_grocery_discount_sensitivit NVARCHAR(50),
	    kids_discount_sensitivity NVARCHAR(50)
	    );
    ';
    EXEC sp_executesql @sql_create;
END
ELSE
BEGIN
    PRINT 'Table CRM_SINGLE_VIEW_' + @SEGNAME + ' already exists.';
END


-- ขั้นตอนที่ 3: Insert ข้อมูลจาก SEG.CFG_ALL_GROUP
DECLARE @sql_insert NVARCHAR(MAX);
SET @sql_insert = N'
INSERT INTO MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' (
    sbl_member_id, 
    CFG_TX, 
    CFG_TOTAL, 
    CFG_GP, 
    CFG_NET_TOTAL, 
    CFG_GP_PERCENT, 
    CFG_Month_Visit, 
    CFG_Last_Visit, 
    rank_total, 
    CFG_Rank, 
    CFR_TX, 
    CFR_TOTAL, 
    CFR_GP, 
    CFR_NET_TOTAL, 
    CFR_GP_PERCENT, 
    CFR_BASKET_SIZE, 
    CFR_MONTH_VISIT, 
    CFR_LAST_VISIT, 
    CFR_RANK, 
    CFM_TX, 
    CFM_TOTAL, 
    CFM_GP, 
    CFM_NET_TOTAL, 
    CFM_GP_PERCENT, 
    CFM_BASKET_SIZE, 
    CFM_MONTH_VISIT, 
    CFM_LAST_VISIT, 
    CFM_RANK
)
SELECT sbl_member_id, 
       CFG_TX, 
       CFG_TOTAL, 
       CFG_GP, 
       CFG_NET_TOTAL, 
       CFG_GP_PERCENT, 
       CFG_Month_Visit, 
       CFG_Last_Visit, 
       rank_total, 
       CFG_Rank, 
       CFR_TX, 
       CFR_TOTAL, 
       CFR_GP, 
       CFR_NET_TOTAL, 
       CFR_GP_PERCENT, 
       CFR_BASKET_SIZE, 
       CFR_MONTH_VISIT, 
       CFR_LAST_VISIT, 
       CFR_RANK, 
       CFM_TX, 
       CFM_TOTAL, 
       CFM_GP, 
       CFM_NET_TOTAL, 
       CFM_GP_PERCENT, 
       CFM_BASKET_SIZE, 
       CFM_MONTH_VISIT, 
       CFM_LAST_VISIT, 
       CFM_RANK
FROM MKTCRM.SEG.CFG_ALL_GROUP;
';
EXEC sp_executesql @sql_insert;

-- ขั้นตอนที่ 4: ลบคอลัมน์ rank_total
DECLARE @sql_drop_column NVARCHAR(MAX);
SET @sql_drop_column = N'
ALTER TABLE MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + '
DROP COLUMN rank_total;
';
EXEC sp_executesql @sql_drop_column;

-- ขั้นตอนที่ 5: JOIN ข้อมูลจาก MKTCRM.SEG.CFR_HS
DECLARE @sql_update_cfr NVARCHAR(MAX);
SET @sql_update_cfr = N'
UPDATE A
SET A.CFR_HOME_STORE_CODE = B.CFR_HOME_STORE_CODE,
    A.CFR_HOME_STORE = B.CFR_HOME_STORE,
    A.CFR_HOME_STORE_FORMAT = B.CFR_HOME_STORE_FORMAT,
    A.CFR_HOME_STORE_LOCATION = B.CFR_HOME_STORE_LOCATION,
    A.ST_MOST_FREQ_TX = B.ST_MOST_FREQ_TX,
    A.ST_MOST_FREQ = B.ST_MOST_FREQ,
    A.ST_MOST_FREQ_NAME = B.ST_MOST_FREQ_NAME,
    A.ST_MOST_FREQ_FORMAT = B.ST_MOST_FREQ_FORMAT,
    A.ST_MOST_FREQ_LOCATION = B.ST_MOST_FREQ_LOCATION,
    A.ST_MOST_SPENDING_SALE = B.ST_MOST_SPENDING_SALE,
    A.ST_MOST_SPENDING = B.ST_MOST_SPENDING,
    A.ST_MOST_SPENDING_NAME = B.ST_MOST_SPENDING_NAME,
    A.ST_MOST_SPENDING_FORMAT = B.ST_MOST_SPENDING_FORMAT,
    A.ST_MOST_SPENDING_LOCATION = B.ST_MOST_SPENDING_LOCATION
FROM MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' A
LEFT JOIN MKTCRM.SEG.CFR_HS B
    ON A.sbl_member_id = B.sbl_member_id;
';
EXEC sp_executesql @sql_update_cfr;

-- ขั้นตอนที่ 6: คำนวณค่า Visit_group และอัพเดต
DECLARE @sql_update_group NVARCHAR(MAX);
SET @sql_update_group = N'
UPDATE MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + '
SET Visit_group = 
    CASE 
        WHEN sbl_member_id IN (SELECT sbl_member_id FROM MKTCRM.SEG.CFG_ALL_BU WHERE BU = ''CFR'')
        AND sbl_member_id IN (SELECT sbl_member_id FROM MKTCRM.SEG.CFG_ALL_BU WHERE BU = ''CFM'') THEN ''All CFG''
        WHEN sbl_member_id IN (SELECT sbl_member_id FROM MKTCRM.SEG.CFG_ALL_BU WHERE BU = ''CFR'') THEN ''CFR''
        WHEN sbl_member_id IN (SELECT sbl_member_id FROM MKTCRM.SEG.CFG_ALL_BU WHERE BU = ''CFM'') THEN ''CFM''
        ELSE ''''
    END;
';
EXEC sp_executesql @sql_update_group;


-- โค้ดเก่า BackUp
/*
proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *
FROM SEG.CFG_ALL_GROUP;
QUIT; 

proc sql;
alter table seg.CRM_SINGLE_VIEW_&SEGNAME. drop column rank_total;
quit;

PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.CFR_HS B ON A.sbl_memBer_id = B.sbl_memBer_id;
QUIT; 


/*req. by P'TON - ignore CMK @20231212
proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select sbl_member_id, 
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CMK') then 'All CFG' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM') then 'CFRxCFM' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CMK') then 'CFRxCMK' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CMK')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM') then 'CFMxCMK' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR') then 'CFR' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM') then 'CFM' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CMK') then 'CMK' else '' end end end end end end end as Visit_group, *
from seg.CRM_SINGLE_VIEW_&SEGNAME.;
quit;
*/

/* new req. by P'TON - ignore CMK @20231212*/
proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select sbl_member_id, 
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR')
and sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM') then 'All CFG'	else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFR') then 'CFR' else
case when sbl_member_id in (select sbl_member_id from seg.cfg_all_BU where BU = 'CFM') then 'CFM' else ''
end	end end as Visit_group,*
from seg.CRM_SINGLE_VIEW_&SEGNAME.;
quit;

*/


----------------------------------------------------------------------------------------------------------------------------------


TRUNCATE TABLE MKTCRM.SEG.CFM_SGST_All ;

-- (table 10) 
-- ข้อมูลตั้งต้นใหม่ สร้าง -> MKTCRM.SEG.CFM_SGST_All

-- Get today's date
DECLARE @today DATE = GETDATE();

-- 1. Calculate previous months and other required values
DECLARE @p_fm CHAR(6);
DECLARE @p_lm CHAR(6);

-- 2. Calculate the previous 12 months
SET @p_fm = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMM');
SET @p_lm = FORMAT(DATEADD(MONTH, -1, @today), 'yyyyMM');

-- 3. Assigning values to new variables for use
DECLARE @FM CHAR(6) = @p_fm;
DECLARE @LM CHAR(6) = @p_lm;
DECLARE @cym CHAR(6);  -- This will be used to iterate through months
SET @cym = @FM;

-- 4. Step 1: Create the table (only once, before starting the loop)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CFM_SGST_All')
BEGIN
    EXEC sp_executesql N'
        CREATE TABLE MKTCRM.SEG.CFM_SGST_All (
            ym CHAR(6),
            sbl_member_id VARCHAR(20),
            ST_CODE VARCHAR(50),
            tx float,
            total DECIMAL(18, 4)
        );
    ';
END

-- 5. Step 2: Loop to insert data for each month
WHILE CAST(@cym AS INT) <= CAST(@LM AS INT)
BEGIN
    -- Dynamic SQL for the INSERT statement
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO MKTCRM.SEG.CFM_SGST_All (ym, sbl_member_id, ST_CODE, tx, total)
        SELECT @cym AS ym, sbl_member_id, STORE_CODE AS ST_CODE,
            COUNT(DISTINCT REFERENCE) AS tx, SUM(SALES) AS total
        FROM cfhqsasdidb01.topsCFM.dbo.saletrans_CFM_' + @cym + ' a
        JOIN cfhqsasdidb01.topssbl.dbo.sbl_member_card_list b ON a.t1c_card_no = b.t1c_card_no
        GROUP BY sbl_member_id, STORE_CODE;
    ';

    -- Execute dynamic SQL
    EXEC sp_executesql @sql, N'@cym CHAR(6)', @cym;

    -- Increment month and handle year transition
    IF CAST(SUBSTRING(@cym, 5, 2) AS INT) + 1 > 12
    BEGIN
        SET @cym = CAST(CAST(SUBSTRING(@cym, 1, 4) AS INT) + 1 AS CHAR(4)) + '01';
    END
    ELSE
    BEGIN
        SET @cym = CAST(CAST(SUBSTRING(@cym, 1, 4) AS INT) AS CHAR(4)) + 
            RIGHT('00' + CAST(CAST(SUBSTRING(@cym, 5, 2) AS INT) + 1 AS VARCHAR(2)), 2);
    END
END;


-- โค้ดเก่า BackUp
/*
/*CFM - HOME_STORE*/
%macro homestore;
%let cym = &FM;
	%do %while (&cym. <= &LM.);

		%IF &cym. = &FM. %THEN %DO;

			PROC SQL THREADS;
			CREATE TABLE seg.CFM_SGST_All (compress= yes) as
			select &cym. as ym, sbl_member_id, STORE_CODE AS ST_CODE, count(distinct REFERENCE!!STORE_CODE) as tx, sum(SALES) as total
			from TOPSCFM.saletrans_CFM_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id, ST_CODE;
			QUIT;

		%END;
		%ELSE %DO;

			PROC SQL THREADS;
			INSERT INTO seg.CFM_SGST_All
			select &cym. as ym, sbl_member_id, STORE_CODE AS ST_CODE, count(distinct REFERENCE!!STORE_CODE) as tx, sum(SALES) as total
			from TOPSCFM.saletrans_CFM_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			group by sbl_member_id, ST_CODE;
			QUIT;

		%END;
		%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
	              %let cym = %eval(&cym. +89);
	              %end;
	    %else %do; %let cym = %eval(&cym. +1); %end;
	%END;
%MEND;
*/


----------------------------------------------------------------------------------------------------------------------------------

-- (table 11) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFM_SGST_All สร้าง -> MKTCRM.SEG.CFM_SGST_All_2

TRUNCATE TABLE MKTCRM.SEG.CFM_SGST_All_2 ;

-- ขั้นตอนที่ 1: ตรวจสอบว่าตาราง MKTCRM.SEG.CFM_SGST_All_2 มีอยู่แล้วหรือไม่
IF OBJECT_ID('MKTCRM.SEG.CFM_SGST_All_2', 'U') IS NULL
BEGIN
    -- สร้างตารางหากยังไม่มี
    CREATE TABLE MKTCRM.SEG.CFM_SGST_All_2 (
        sbl_member_id NVARCHAR(20),
        ST_CODE CHAR(10),
        tx float,
        total DECIMAL(18, 4),
        p_tx DECIMAL(18, 4),  -- คอลัมน์สำหรับ p_tx
        p_total DECIMAL(18, 4), -- คอลัมน์สำหรับ p_total
        idx DECIMAL(18, 4)  -- คอลัมน์สำหรับ idx
    );
END;

-- ขั้นตอนที่ 2: คำนวณรวมค่า tx และ total ตาม sbl_member_id และ ST_CODE แล้ว INSERT
INSERT INTO MKTCRM.SEG.CFM_SGST_All_2 (sbl_member_id, ST_CODE, tx, total)
SELECT sbl_member_id, 
       ST_CODE, 
       SUM(tx) AS tx, 
       SUM(total) AS total
FROM MKTCRM.seg.CFM_SGST_All
GROUP BY sbl_member_id, ST_CODE;

-- ขั้นตอนที่ 3: คำนวณ p_tx และ p_total โดยใช้ SUM() OVER และ JOIN กับตารางที่สร้างขึ้น
WITH p_tx_total AS (
    SELECT 
        sbl_member_id,
        SUM(tx) AS total_tx,
        SUM(total) AS total_sum
    FROM MKTCRM.SEG.CFM_SGST_All_2
    GROUP BY sbl_member_id
)
-- Update p_tx and p_total
UPDATE c
SET 
    c.p_tx = CASE 
                 WHEN p.total_tx = 0 THEN 0
                 ELSE c.tx / p.total_tx 
             END,
    c.p_total = CASE 
                    WHEN p.total_sum = 0 THEN 0
                    ELSE c.total / p.total_sum 
                END
FROM MKTCRM.SEG.CFM_SGST_All_2 c
JOIN p_tx_total p
    ON c.sbl_member_id = p.sbl_member_id;

-- ขั้นตอนที่ 4: คำนวณค่า idx โดยใช้ p_tx และ p_total
WITH idx_calculation AS (
    SELECT sbl_member_id, 
           ST_CODE, 
           p_tx * 0.6 + p_total * 0.4 AS idx
    FROM MKTCRM.SEG.CFM_SGST_All_2
)
-- Update idx
UPDATE c
SET c.idx = i.idx
FROM MKTCRM.SEG.CFM_SGST_All_2 c
JOIN idx_calculation i
    ON c.sbl_member_id = i.sbl_member_id
    AND c.ST_CODE = i.ST_CODE;



-- โค้ดเก่า BackUp
/*
proc sql threads;
create table seg.CFM_SGST_All_2 (compress = yes) as
select sbl_member_id, ST_CODE, sum(tx) as tx, sum(total) as total
from seg.CFM_SGST_All
group by sbl_member_id, ST_CODE;
QUIT; 

proc sql threads;
create table seg.CFM_SGST_All_2 (compress = yes) as
select *, tx/sum(tx) as p_tx, total/sum(total) as p_total
from seg.CFM_SGST_All_2
group by sbl_member_id;
QUIT; 

proc sql threads;
create table seg.CFM_SGST_All_2 (compress = yes) as
select *, p_tx*0.6+p_total*0.4 as idx
from seg.CFM_SGST_All_2;
QUIT; 
*/

----------------------------------------------------------------------------------------------------------------------------------


-- (table 12) 
-- ใช้ข้อมูลจากตาราง MKTCRM.SEG.CFM_SGST_All_2 สร้าง -> MKTCRM.SEG.CFM_SGST_All_3

-- 1. ตรวจสอบว่าตาราง CFM_SGST_All_3 มีอยู่แล้วหรือไม่ ถ้าไม่มีก็สร้าง
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CFM_SGST_All_3' AND TABLE_SCHEMA = 'SEG' AND TABLE_CATALOG = 'MKTCRM')
BEGIN
    CREATE TABLE MKTCRM.SEG.CFM_SGST_All_3 (
        sbl_member_id NVARCHAR(20),
        ST_CODE CHAR(10),
        tx float,
        total DECIMAL(18, 2),
        p_tx DECIMAL(18, 4),
        p_total DECIMAL(18, 4),
        idx DECIMAL(18, 4),
        rank INT  -- เพิ่มคอลัมน์ rank เพื่อเก็บอันดับ
    );
END;

-- 2. คัดลอกข้อมูลจาก CFM_SGST_All_2 มายัง CFM_SGST_All_3 และจัดเรียงตาม sbl_member_id, idx
INSERT INTO MKTCRM.SEG.CFM_SGST_All_3 (sbl_member_id, ST_CODE, tx, total, p_tx, p_total, idx)
SELECT sbl_member_id, 
       ST_CODE, 
       tx, 
       total, 
       p_tx, 
       p_total, 
       idx
FROM MKTCRM.seg.CFM_SGST_All_2
ORDER BY sbl_member_id, idx DESC;

-- 3. ใช้ ROW_NUMBER() เพื่อคำนวณอันดับ (rank) และจัดลำดับตาม sbl_member_id และ idx
WITH RankedData AS (
    SELECT sbl_member_id, 
           ST_CODE, 
           tx, 
           total, 
           p_tx, 
           p_total, 
           idx,
           ROW_NUMBER() OVER (PARTITION BY sbl_member_id ORDER BY idx DESC) AS rank
    FROM MKTCRM.SEG.CFM_SGST_All_3
)
-- 4. อัปเดตตาราง CFM_SGST_All_3 โดยใช้ข้อมูลจาก CTE
UPDATE A
SET A.rank = B.rank
FROM MKTCRM.SEG.CFM_SGST_All_3 A
JOIN RankedData B 
    ON A.sbl_member_id = B.sbl_member_id
    AND A.idx = B.idx;

-- 5. เลือกเฉพาะแถวที่ rank = 1 และอัปเดตตาราง CFM_SGST_All_3
DELETE FROM MKTCRM.SEG.CFM_SGST_All_3
WHERE rank != 1;

-- โค้ดเก่า BackUp
/*
proc sql threads;
create table seg.CFM_SGST_All_3 (compress = yes) as
select *
from seg.CFM_SGST_All_2
order by SBL_MEMBER_ID, idx desc;
QUIT; 


data seg.CFM_SGST_All_3 (compress = yes);
set seg.CFM_SGST_All_3;
by sbl_member_id;
rank +1;
if first.sbl_member_id then rank = 1;
run; 

data seg.CFM_SGST_All_3 (compress = yes);
set seg.CFM_SGST_All_3;
where rank = 1;
run; 
*/

----------------------------------------------------------------------------------------------------------------------------------



-- (table 13) 
-- ใช้ข้อมูลจากตาราง  MKTCRM.SEG.CFM_SGST_All_3 สร้าง -> MKTCRM.SEG.CFM_HS

-- 1. ตรวจสอบว่าตาราง MKTCRM.SEG.CFM_HS มีอยู่แล้วหรือไม่ ถ้าไม่มีก็สร้างใหม่
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CFM_HS' AND TABLE_SCHEMA = 'MKTCRM.SEG')
BEGIN
    CREATE TABLE MKTCRM.SEG.CFM_HS (
        sbl_member_id NVARCHAR(20),
        CFM_HOME_STORE_CODE CHAR(10),
        CFM_HOME_STORE NVARCHAR(100),
        CFM_HOME_STORE_FORMAT NVARCHAR(50),
        CFM_HOME_STORE_LOCATION NVARCHAR(100)
    );
END;

-- 2. นำข้อมูลจาก CFM_SGST_All_3 มาสร้างข้อมูลใน CFM_HS
INSERT INTO MKTCRM.SEG.CFM_HS (sbl_member_id, CFM_HOME_STORE_CODE, CFM_HOME_STORE, CFM_HOME_STORE_FORMAT, CFM_HOME_STORE_LOCATION)
SELECT 
    A.sbl_member_id, 
    A.st_code AS CFM_HOME_STORE_CODE, 
    LTRIM(RTRIM(B.STORE_NAME)) + '_' + LTRIM(RTRIM(A.ST_CODE)) AS CFM_HOME_STORE,  -- ใช้ LTRIM(RTRIM) แทน STRIP
    CASE 
        WHEN B.STORE_FORMAT = 'Building' THEN 'Family Mart' 
        ELSE B.STORE_FORMAT 
    END AS CFM_HOME_STORE_FORMAT,
    B.STORE_LOCATION AS CFM_HOME_STORE_LOCATION
FROM 
    MKTCRM.SEG.CFM_SGST_All_3 A
LEFT JOIN 
    cfhqsasdidb01.TOPSCFM.dbo.STORE_MASTER B 
ON 
    A.ST_CODE = B.STORE_CODE;


-- โค้ดเก่า BackUp
/*
PROC SQL THREADS;
CREATE TABLE SEG.CFM_HS (compress= yes) AS
SELECT A.sbl_memBer_id, a.st_code as CFM_HOME_STORE_CODE, STRIP(B.STORE_NAME)!!"_"!!STRIP(A.ST_CODE) AS CFM_HOME_STORE, 
CASE WHEN B.STORE_FORMAT='Building' THEN 'Family Mart' ELSE B.STORE_FORMAT END AS CFM_HOME_STORE_FORMAT, B.STORE_LOCATION AS CFM_HOME_STORE_LOCATION
FROM SEG.CFM_SGST_All_3 A
LEFT JOIN TOPSCFM.STORE_MASTER B ON A.ST_CODE = B.STORE_CODE;
QUIT; 
*/


----------------------------------------------------------------------------------------------------------------------------------


-- (อัพเดทข้อมูลเข้าไปที่ตาราง MKTCRM.SEG.CRM_SINGLE_VIEW_&SEGNAME) 
-- ใช้ข้อมูลจากตาราง  MKTCRM.SEG.CFM_HS

-- ขั้นตอนที่ 1: คำนวณปีที่แล้ว และเดือนปัจจุบัน

DECLARE @today DATE = GETDATE();

DECLARE @yyyy_lm INT,      -- ปีที่แล้ว
        @yy_lm INT,         -- ปีที่แล้ว (สองหลัก)
        @mm_lm INT,         -- เดือนปัจจุบัน
        @SEGNAME NVARCHAR(10);  -- ตัวแปรที่จะเก็บค่า SEGNAME

-- คำนวณปีและเดือน
SET @yyyy_lm = YEAR(DATEADD(MONTH, -1, @today));  -- ปีที่แล้ว
SET @yy_lm = YEAR(DATEADD(MONTH, -1, @today)) % 100;  -- ปีที่แล้ว (สองหลัก)
SET @mm_lm = MONTH(DATEADD(MONTH, -1, @today));  -- เดือนปัจจุบัน

-- คำนวณ Quarter (Q1-Q4) ตามเดือน
IF @mm_lm IN (1, 2, 3) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q1';
ELSE IF @mm_lm IN (4, 5, 6) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q2';
ELSE IF @mm_lm IN (7, 8, 9) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q3';
ELSE IF @mm_lm IN (10, 11, 12) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q4';

-- แสดงผลลัพธ์ของ SEGNAME
SELECT @SEGNAME AS SEGNAME;



-- ขั้นตอนที่ 2: JOIN ข้อมูลจาก MKTCRM.SEG.CFM_HS
DECLARE @sql_update_cfm_hs NVARCHAR(MAX);
SET @sql_update_cfm_hs = N'
UPDATE A
SET
	A.CFM_HOME_STORE_CODE = B.CFM_HOME_STORE_CODE,             
    A.CFM_HOME_STORE = B.CFM_HOME_STORE,            
    A.CFM_HOME_STORE_FORMAT = B.CFM_HOME_STORE_FORMAT,      
    A.CFM_HOME_STORE_LOCATION = B.CFM_HOME_STORE_LOCATION 
FROM MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' A
LEFT JOIN MKTCRM.SEG.CFM_HS B
    ON A.sbl_member_id = B.sbl_member_id;
';
EXEC sp_executesql @sql_update_cfm_hs;



-- ขั้นตอนที่ 3: update table
DECLARE @sql_update_cfg_home NVARCHAR(MAX);
SET @sql_update_cfg_home = N'
UPDATE A
SET 
    A.CFG_HOME_STORE_CODE = CASE 
                              WHEN (A.CFR_TX * 0.6) + (A.CFR_TOTAL * 0.4) >= (A.CFM_TX * 0.6) + (A.CFM_TOTAL * 0.4) 
                              THEN A.CFR_HOME_STORE_CODE 
                              ELSE A.CFM_HOME_STORE_CODE 
                             END,
    A.CFG_HOME_STORE = CASE 
                        WHEN (A.CFR_TX * 0.6) + (A.CFR_TOTAL * 0.4) >= (A.CFM_TX * 0.6) + (A.CFM_TOTAL * 0.4) 
                        THEN A.CFR_HOME_STORE 
                        ELSE A.CFM_HOME_STORE 
                       END,
    A.CFG_HOME_STORE_FORMAT = CASE 
                                WHEN (A.CFR_TX * 0.6) + (A.CFR_TOTAL * 0.4) >= (A.CFM_TX * 0.6) + (A.CFM_TOTAL * 0.4) 
                                THEN A.CFR_HOME_STORE_FORMAT 
                                ELSE A.CFM_HOME_STORE_FORMAT 
                               END,
    A.CFG_HOME_STORE_LOCATION = CASE 
                                  WHEN (A.CFR_TX * 0.6) + (A.CFR_TOTAL * 0.4) >= (A.CFM_TX * 0.6) + (A.CFM_TOTAL * 0.4) 
                                  THEN A.CFR_HOME_STORE_LOCATION 
                                  ELSE A.CFM_HOME_STORE_LOCATION 
                                 END
FROM MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' AS A;';

-- ใช้ EXEC sp_executesql เพื่อรันคำสั่ง SQL ที่สร้างขึ้น
EXEC sp_executesql @sql_update_cfg_home;


--โค้ดเก่า Backup
/*
PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.CFM_HS B ON A.sbl_memBer_id = B.sbl_memBer_id;
QUIT; 
*/

/*
-- CFG - HOME_STORE
PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_CODE else CFM_HOME_STORE_CODE end as CFG_HOME_STORE_CODE,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE else CFM_HOME_STORE end as CFG_HOME_STORE,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_FORMAT else CFM_HOME_STORE_FORMAT end as CFG_HOME_STORE_FORMAT,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_LOCATION else CFM_HOME_STORE_LOCATION end as CFG_HOME_STORE_LOCATION
FROM seg.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT; 
*/



----------------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE MKTCRM.SEG.exclusion_item ;

-- (table 14) 
-- ข้อมูลตั้งต้นใหม่ สร้าง -> MKTCRM.SEG.exclusion_item

/*
CREATE TABLE MKTCRM.SEG.exclusion_item (
    PRODUCT_CODE NVARCHAR(50),
    PRODUCT_ENG_DESC NVARCHAR(255),
    DEPT_ID NVARCHAR(50),
    DEPT_ENG_DESC NVARCHAR(255),
    DEPT_THAI_DESC NVARCHAR(255),
    SUBDEPT_ID NVARCHAR(50),
    SUBDEPT_ENG_DESC NVARCHAR(255),
    SUBDEPT_THAI_DESC NVARCHAR(255),
    CLASS_ID NVARCHAR(50),
    CLASS_ENG_DESC NVARCHAR(255),
    CLASS_THAI_DESC NVARCHAR(255),
    CAT_ID NVARCHAR(50),
    CAT_ENG_DESC NVARCHAR(255),
    CAT_THAI_DESC NVARCHAR(255),
    SUBCAT_ID NVARCHAR(50),
    SUBCAT_ENG_DESC NVARCHAR(255),
    SUBCAT_THAI_DESC NVARCHAR(255),
    BRAND_CODE NVARCHAR(50),
    BRAND_ENG_NAME NVARCHAR(255),
    SUPPLIER_CODE NVARCHAR(50),
    SUPPLIER_ENG_NAME NVARCHAR(255),
    INTF_DATE DATE,
    SUBDEPT_CODE NVARCHAR(50),
    CLASS_CODE NVARCHAR(50),
    CAT_CODE NVARCHAR(50),
    SUBCAT_CODE NVARCHAR(50),
    PRODUCT_THAI_DESC NVARCHAR(255),
    SUPPLIER_NAME_THAI NVARCHAR(255),
    UDA_49 NVARCHAR(255)
);
*/
INSERT INTO MKTCRM.SEG.exclusion_item (
    PRODUCT_CODE,
    PRODUCT_ENG_DESC,
    DEPT_ID,
    DEPT_ENG_DESC,
    DEPT_THAI_DESC,
    SUBDEPT_ID,
    SUBDEPT_ENG_DESC,
    SUBDEPT_THAI_DESC,
    CLASS_ID,
    CLASS_ENG_DESC,
    CLASS_THAI_DESC,
    CAT_ID,
    CAT_ENG_DESC,
    CAT_THAI_DESC,
    SUBCAT_ID,
    SUBCAT_ENG_DESC,
    SUBCAT_THAI_DESC,
    BRAND_CODE,
    BRAND_ENG_NAME,
    SUPPLIER_CODE,
    SUPPLIER_ENG_NAME,
    INTF_DATE,
    SUBDEPT_CODE,
    CLASS_CODE,
    CAT_CODE,
    SUBCAT_CODE,
    PRODUCT_THAI_DESC,
    SUPPLIER_NAME_THAI,
    UDA_49
)
SELECT DISTINCT 
    a.PRODUCT_CODE,
    a.PRODUCT_ENG_DESC,
    a.DEPT_ID,
    a.DEPT_ENG_DESC,
    a.DEPT_THAI_DESC,
    a.SUBDEPT_ID,
    a.SUBDEPT_ENG_DESC,
    a.SUBDEPT_THAI_DESC,
    a.CLASS_ID,
    a.CLASS_ENG_DESC,
    a.CLASS_THAI_DESC,
    a.CAT_ID,
    a.CAT_ENG_DESC,
    a.CAT_THAI_DESC,
    a.SUBCAT_ID,
    a.SUBCAT_ENG_DESC,
    a.SUBCAT_THAI_DESC,
    a.BRAND_CODE,
    a.BRAND_ENG_NAME,
    a.SUPPLIER_CODE,
    a.SUPPLIER_ENG_NAME,
    a.INTF_DATE,
    a.SUBDEPT_CODE,
    a.CLASS_CODE,
    a.CAT_CODE,
    a.SUBCAT_CODE,
    a.PRODUCT_THAI_DESC,
    a.SUPPLIER_NAME_THAI,
    a.UDA_49
FROM cfhqsasdidb01.topsrst.dbo.d_merchandise a
JOIN cfhqsasdidb01.topsrst.dbo.b_categorycondition b 
    ON a.subcat_code = b.cat_code
WHERE b.ConditionID = 42022;



-- โค้ดเก่า Backup
/*CFR TOTAL_E*/
/*
proc sql threads;
create table MKTCRM.SEG.exclusion_item (compress = yes) as
select distinct a.*
from cfhqsasdidb01.topsrst.dbo.d_merchandise a
join cfhqsasdidb01.topsrst.dbo.b_categorycondition b on a.subcat_code = b.cat_code
where ConditionID=42022;
quit; 
*/

----------------------------------------------------------------------------------------------------------------------------------

-- P' Pam Created
TRUNCATE TABLE seg.CFR_ALL_E;
EXEC SEG.sale @fm, @lm;





proc sql threads;
create table seg.CFR_ALL_E_2 (compress = yes) as
select sbl_member_id, sum(total_E) as total_E, sum(gp_E) as gp_E, sum(net_total_E) as net_total_E
from seg.CFR_ALL_E 
group by sbl_member_id;
;quit; 

proc rank data=seg.CFR_ALL_E_2 groups=100 out=seg.CFR_ALL_E_2;
	var GP_E;
	ranks rankS_GP_E;
run; 

proc sql threads;
alter table seg.CFR_ALL_E_2 drop column TOP_CUSTOMER_GP_E;
create table seg.CFR_ALL_E_2 (compress = yes) as
select *,
case when rankS_GP_E >= 99 then 'TOP 1%' else
case when rankS_GP_E >= 90 then 'TOP 2-10%' else
case when rankS_GP_E >= 80 then 'TOP 11-20%' else
case when rankS_GP_E >= 60 then 'TOP 21-40%' else
case when rankS_GP_E >= 40 then 'TOP 41-60%' else 
case when rankS_GP_E >= 20 then 'TOP 61-80%' else 
case when rankS_GP_E is null then 'None' else 'Bottom 20%' end end end end end end end as TOP_CUSTOMER_GP_E
from seg.CFR_ALL_E_2
;
quit; 



----------------------------------------------------------------------------------------------------------------------------------

DECLARE @today DATE = GETDATE();

DECLARE @yyyy_lm INT,      -- ปีที่แล้ว
        @yy_lm INT,         -- ปีที่แล้ว (สองหลัก)
        @mm_lm INT,         -- เดือนปัจจุบัน
        @SEGNAME NVARCHAR(10),  -- ตัวแปรที่จะเก็บค่า SEGNAME
        @p_fd_lmmm DATE,
        @p_fm CHAR(6),
        @p_lm CHAR(6);

-- คำนวณปีและเดือน
SET @yyyy_lm = YEAR(DATEADD(MONTH, -1, @today));  -- ปีที่แล้ว
SET @yy_lm = YEAR(DATEADD(MONTH, -1, @today)) % 100;  -- ปีที่แล้ว (สองหลัก)
SET @mm_lm = MONTH(DATEADD(MONTH, -1, @today));  -- เดือนปัจจุบัน
SET @p_fd_lmmm = DATEADD(MONTH, 0, @today); -- Calculate the previous 12 months
SET @p_fm = FORMAT(DATEADD(MONTH, -12, @today), 'yyyyMM');
SET @p_lm = FORMAT(DATEADD(MONTH, -1, @today), 'yyyyMM');


-- คำนวณ Quarter (Q1-Q4) ตามเดือน
IF @mm_lm IN (1, 2, 3) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q1';
ELSE IF @mm_lm IN (4, 5, 6) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q2';
ELSE IF @mm_lm IN (7, 8, 9) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q3';
ELSE IF @mm_lm IN (10, 11, 12) 
    SET @SEGNAME = CAST(@yy_lm AS VARCHAR(2)) + 'Q4';

-- แสดงผลลัพธ์ของ SEGNAME
SELECT @SEGNAME AS SEGNAME;


-- Determine Year and Quarter (Single View) for last month
DECLARE @p_yqlm VARCHAR(4);
IF @mm_lm IN (3) SET @p_yqlm = CONCAT(@yy_lm, 'Q1');
IF @mm_lm IN (6) SET @p_yqlm = CONCAT(@yy_lm, 'Q2');
IF @mm_lm IN (9) SET @p_yqlm = CONCAT(@yy_lm, 'Q3');
IF @mm_lm IN (12) SET @p_yqlm = CONCAT(@yy_lm, 'Q4');

-- Determine the First Month of the Last Quarter
DECLARE @p_fmlq CHAR(6);
IF @mm_lm IN (3) SET @p_fmlq = CONCAT(@yyyy_lm, '10');  -- Q4: October
IF @mm_lm IN (6) SET @p_fmlq = CONCAT(@yyyy_lm, '01');  -- Q1: January
IF @mm_lm IN (9) SET @p_fmlq = CONCAT(@yyyy_lm, '04');  -- Q2: April
IF @mm_lm IN (12) SET @p_fmlq = CONCAT(@yyyy_lm, '07'); -- Q3: July

-- Assigning values to new variables for use (Move this part before sp_executesql)
DECLARE @FM CHAR(6) = @p_fm;
DECLARE @LM CHAR(6) = @p_lm;
DECLARE @FMLQ CHAR(6) = @p_fmlq;



-- ขั้นตอนที่ 3: JOIN ข้อมูลจาก MKTCRM.SEG.CFR_ALL_E_2
DECLARE @sql_update_single_view_2 NVARCHAR(MAX);
SET @sql_update_single_view_2 = N'
UPDATE A
SET
	A.CFR_TOP_CUSTOMER_GP_E = B.TOP_CUSTOMER_GP_E            
FROM MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' A
LEFT JOIN cfhqsasdidb01.MKTCRM.SEG.CFR_ALL_E_2 B
    ON A.sbl_member_id = B.sbl_member_id;
';
EXEC sp_executesql @sql_update_single_view_2;

-- ขั้นตอนที่ 4: JOIN ข้อมูลจาก cfhqsasdidb01.TOPSSBL.dbo.SBL_CUSTOMER
DECLARE @sql_update_single_view_3 NVARCHAR(MAX);
SET @sql_update_single_view_3 = N'
UPDATE A
SET
    A.Month_on_book = DATEDIFF(MONTH, CAST(B.REGISTER_DATE AS DATE), CAST(''' + CONVERT(VARCHAR, @p_fd_lmmm, 112) + ''' AS DATE))
FROM MKTCRM.SEG.CRM_SINGLE_VIEW_' + @SEGNAME + ' A
LEFT JOIN cfhqsasdidb01.TOPSSBL.dbo.SBL_CUSTOMER B
    ON A.sbl_member_id = B.sbl_member_id;
';
EXEC sp_executesql @sql_update_single_view_3;

--------------------------------------------------------------------



/*
proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select a.*, TOP_CUSTOMER_GP_E as CFR_TOP_CUSTOMER_GP_E
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.cfr_all_e_2 b on a.sbl_member_id = b.sbl_member_id;
quit;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select a.*, INTCK('MONTH', DATEPART(REGISTER_DATE), "&p_fd_lmmm."d) as Month_on_book
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN TOPSSBL.SBL_CUSTOMER B ON A.sbl_member_id = b.sbl_member_id
;
QUIT;
*/


PROC SQL threads;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES) AS
SELECT 
CASE WHEN SBL_MEMBER_ID IN (SELECT sbl_member_id FROM MKTCRM.SEG.CRM_SINGLE_VIEW_20Q2 WHERE CFR_COMPANY_RANK = 'Wholesale') THEN 'Wholesale' ELSE
/*Regular*/
CASE WHEN CFR_TOP_CUSTOMER_GP_E = 'TOP 1%' AND CFR_MONTH_VISIT >= 10 AND CFR_LAST_VISIT >= &FMLQ. THEN 'Healthy & Premium Fresh' ELSE
CASE WHEN CFR_TOP_CUSTOMER_GP_E = 'TOP 2-10%' AND CFR_MONTH_VISIT >= 10 AND CFR_LAST_VISIT >= &FMLQ. THEN 'Family Focus' ELSE
CASE WHEN CFR_TOP_CUSTOMER_GP_E = 'TOP 11-20%' AND CFR_MONTH_VISIT >= 10 AND CFR_LAST_VISIT >= &FMLQ. THEN 'Budget Conscious' ELSE
CASE WHEN CFR_TOP_CUSTOMER_GP_E NOT IN ('TOP 1%','TOP 2-10%','TOP 11-20%') AND CFR_MONTH_VISIT >= 10 AND CFR_LAST_VISIT >= &FMLQ. THEN 'Promotion Hunter' ELSE
/*Repertoire*/
CASE WHEN CFR_TOP_CUSTOMER_GP_E IN ('TOP 1%','TOP 2-10%','TOP 11-20%') AND CFR_MONTH_VISIT BETWEEN 1 AND 9 AND CFR_LAST_VISIT >= &FMLQ. AND Month_on_book >= 12 THEN 'Premium Repertoire' ELSE
CASE WHEN CFR_TOP_CUSTOMER_GP_E NOT IN ('TOP 1%','TOP 2-10%','TOP 11-20%') AND CFR_MONTH_VISIT BETWEEN 1 AND 9 AND CFR_LAST_VISIT >= &FMLQ. AND Month_on_book >= 12 THEN 'Repertoire' ELSE
/*New & Lost*/
CASE WHEN CFR_TOP_CUSTOMER_GP_E IS NOT NULL AND CFR_MONTH_VISIT BETWEEN 1 AND 9 AND CFR_LAST_VISIT >= &FMLQ. AND Month_on_book < 12 THEN 'Newcomer' ELSE
CASE WHEN CFR_TOP_CUSTOMER_GP_E IS NOT NULL AND CFR_MONTH_VISIT BETWEEN 1 AND 9 AND CFR_LAST_VISIT < &FMLQ. THEN 'Lapsed' ELSE '' END END END END END END END END END AS SEGMENT_GP_E, *
FROM seg.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT; 



proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress=yes) as
select 
case when SEGMENT_GP_E ='Healthy & Premium Fresh' then 1 else
case when SEGMENT_GP_E ='Family Focus' then 2 else
case when SEGMENT_GP_E ='Budget Conscious' then 3 else
case when SEGMENT_GP_E ='Promotion Hunter' then 4 else
case when SEGMENT_GP_E ='Premium Repertoire' then 5 else
case when SEGMENT_GP_E ='Repertoire' then 6 else
case when SEGMENT_GP_E ='Newcomer' then 7 else
case when SEGMENT_GP_E ='Lapsed' then 8 else
case when SEGMENT_GP_E = 'Wholesale' then 9 else .
end end end end end end end end end as SEGMENT_NO_GP_E,*
from seg.CRM_SINGLE_VIEW_&SEGNAME.;
/*--------> run until here <--------*/
quit;

PROC SQL threads;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES) AS
SELECT *,
CASE WHEN SBL_MEMBER_ID IN (SELECT sbl_member_id FROM MKTCRM.SEG.ws_20q2) THEN 'Wholesale' ELSE CFR_RANK END AS CFR_COMPANY_RANK
FROM seg.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT; 



----------------------------------------------------------------------------------------------------------------------------------



%macro tx;
%let cym = &FM;
%do %while (&cym. < &LM.);
	%IF &cym. = &FM. %THEN %DO;
		proc sql threads;
		create table seg.cust_tx_all (compress = yes) as 
		select DISTINCT T1C_CARD_NO, TTM
		from TOPSRST.SALETRANS_&CYM.;
		quit;

	%END;
	%ELSE %DO;

		proc sql threads;
		insert into seg.cust_tx_all
		select DISTINCT T1C_CARD_NO, TTM
		from TOPSRST.SALETRANS_&CYM.;
		quit;

	%END;

	%if (&cym. >= 202107) %then %do;
		proc sql threads;
		insert into seg.cust_tx_all
		select DISTINCT T1C_CARD_NO, TTM
		from TOPSRST.SALETRANS_ONLINE_&CYM.;
		quit;
	%end;


	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
%tx; 

proc sql threads;
insert into seg.cust_tx_all
select DISTINCT T1C_CARD_NO, TTM
from TOPSRST.saletrans_daily
WHERE substr(put(ttm2,8.),1,6)="&LM.";
quit;

proc sql threads;
create table seg.cust_tx_all_time (compress = yes) as
select distinct sbl_member_id, ttm
from seg.cust_tx_all A
JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO;
quit;  

proc sql threads;
create table seg.cust_tx_all_time (compress = yes) as
select *, datepart(ttm) as dp format date9.
from seg.cust_tx_all_time
where sbl_member_id is not null;
quit;  

proc sql threads;
create table seg.cust_tx_all_time (compress = yes) as
select distinct sbl_member_id, dp
from seg.cust_tx_all_time;
quit;  

proc sql threads;
alter table seg.cust_tx_all_time drop column intv;

/*--------> run until here <--------*/
quit;  

data seg.cust_tx_all_time(compress = yes);
set seg.cust_tx_all_time;
by sbl_member_id;
intv = dif(dp);
if first.sbl_member_id then intv = .;
run;  

PROC SQL;
   CREATE TABLE seg.cust_tx_all_time (compress = yes) AS 
   SELECT t1.SBL_MEMBER_ID, AVG(t1.intv) AS Purchasing_interval
      FROM SEG.CUST_TX_ALL_TIME t1
      GROUP BY t1.SBL_MEMBER_ID;
QUIT;  


----------------------------------------------------------------------------------------------------------------------------------


PROC SQL threads;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES) AS
SELECT a.*, Purchasing_interval
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.cust_tx_all_time b on a.SBL_MEMBER_ID = b.SBL_MEMBER_ID;
QUIT; 

PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES) AS
SELECT A.*, 
case when A.SBL_MEMBER_ID in (select sbl_member_id from TOPSsbl.SBL_MAP_HR_EXISTING where sbl_member_id is not null and Bu_ID in ('CFR','CFG','CMK','CFG')) then 'Y' else 'N' end as Flag_Staff_CFG,
case when A.SBL_MEMBER_ID in (select sbl_member_id from TOPSSBL.SBL_MAP_HR_EXISTING where sbl_member_id is not null and Bu_ID not in ('CFR','CFG','CMK','CFG')) then 'Y' else 'N' end as Flag_Staff_Others,
INTCK('MONTH', DATEPART(REGISTER_DATE), "&p_fd_lmmm."d) as Month_on_book,
CASE WHEN MARITAL_STATUS = '1' THEN 'Single' ELSE
CASE WHEN MARITAL_STATUS = '2' THEN 'Married' ELSE 'Other' end end as MARITALSTATUS,
INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) as Age,
Sex as Gender 'Gender',
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) < 15 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then '00_<15' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) between 15 and 24 then '01_15-24' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) between 25 and 34 then '02_25-34' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) between 35 and 44 then '03_35-44' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) between 45 and 54 then '04_45-54' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) between 55 and 64 then '05_55-64' else
case when INTCK('YEAR', DATEPART(DOB), "&p_fd_lmmm."d) BETWEEN 65 AND 80 then '06_>=65' else '99_Unknown' end end end end end end end as Age_Range,
case when year(datepart(DOB)) <= 1900 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Lost Generation' else
case when year(datepart(DOB)) between 1901 and 1924 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Great Generation' else
case when year(datepart(DOB)) between 1925 and 1945 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Silent Generation' else
case when year(datepart(DOB)) between 1946 and 1964 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Baby Boomer' else
case when year(datepart(DOB)) between 1965 and 1979 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Generation X' else
case when year(datepart(DOB)) between 1980 and 1996 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Generation Y' else
case when year(datepart(DOB)) >= 1997 and DOB is not null and DOB > '01JAN1900:00:00:00'DT then 'Generation Z' else 'Unknown' end end end end end end end as Generation,
month(datepart(DOB)) as Month_Of_Birth,
CASE WHEN b.Education_Level = '1' THEN 'Primary School' ELSE
CASE WHEN b.Education_Level = '2' THEN 'Secondary School' ELSE
CASE WHEN b.Education_Level = '3' THEN 'College' ELSE
CASE WHEN b.Education_Level = '4' THEN 'Bachelor Degree' ELSE
CASE WHEN b.Education_Level = '5' THEN 'Master Degree' ELSE
CASE WHEN b.Education_Level = '6' THEN 'Doctorate' ELSE 'Unknown' END END END END END END AS Education_Level,
CASE WHEN MTHLY_INCOME_RANGE = '1' THEN '01_Less than 10,000' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '2' THEN '02_10,000-14,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '3' THEN '03_15,000-24,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '4' THEN '04_25,000-34,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '5' THEN '05_35,000-49,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '6' THEN '06_50,000-69,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '7' THEN '07_70,000-99,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '8' THEN '08_100,000-299,999' ELSE
CASE WHEN MTHLY_INCOME_RANGE = '9' THEN '09_More than 300,000' ELSE 'Unknown' END END END END END END END END END AS HH_Income,
Work_Type_Group as Occupation 'Occupation',
b.Customer_Type
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join topssbl.sbl_customer b on a.SBL_MEMBER_ID = b.sbl_member_id
left join crm.SBL_MASTER_WORK_TYPE c on b.work_type = c.id;
quit;  

%macro tx;
%let cym = &FM;
%do %while (&cym. < &LM.);
	%IF &cym. = &FM. %THEN %DO;
		proc sql threads;
		create table seg.cust_pr_all (compress = yes) as 
		select T1C_CARD_NO, ref_key,COUNT(DISTINCT pr_code) AS PR_CNT
		from TOPSRST.SALETRANS_&CYM.
		where pr_code ^= '0000030959026'
		GROUP BY T1C_CARD_NO, ref_key;
		quit;

	%END;
	%ELSE %DO;

		proc sql threads;
		insert into seg.cust_pr_all
		select T1C_CARD_NO, ref_key,COUNT(DISTINCT pr_code) AS PR_CNT
		from TOPSRST.SALETRANS_&CYM.
		where pr_code ^= '0000030959026'
		GROUP BY T1C_CARD_NO, ref_key;
		quit;

	%END;

	%if (&cym. >= 202107) %then %do;
		proc sql threads;
		insert into seg.cust_pr_all
		select T1C_CARD_NO, ref_key,COUNT(DISTINCT pr_code) AS PR_CNT
		from TOPSRST.SALETRANS_ONLINE_&CYM.
		where pr_code ^= '0000030959026'
		GROUP BY T1C_CARD_NO, ref_key;
		quit;
	%end;

	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
%tx; 

proc sql threads;
insert into seg.cust_pr_all
select T1C_CARD_NO, ref_key,COUNT(DISTINCT pr_code) AS PR_CNT
from TOPSRST.saletrans_daily
where pr_code ^= '0000030959026'
and substr(put(ttm2,8.),1,6)="&LM."
GROUP BY T1C_CARD_NO, ref_key;
quit;

proc sql threads;
create table seg.pr_all (compress = yes) as
select sbl_member_id, mean(pr_cnt) as AVG_ITEM_PER_TX
from seg.cust_pr_all a
join topssbl.sbl_member_card_list b on a.T1C_CARD_NO = b.T1C_CARD_NO
group by sbl_member_id
;
quit;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select a.*, AVG_ITEM_PER_TX
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.pr_all b on a.sbl_member_id = b.sbl_member_id;

/*--------> run until here <--------*/
quit;



----------------------------------------------------------------------------------------------------------------------------------------

%macro SC;
%let cym = &FM;
%do %while (&cym. < &LM.);

	%IF &cym. = &FM. %THEN %DO;

		PROC SQL THREADS;
		CREATE TABLE SEG.CLASS_ALL (COMPRESS = YES) AS
		SELECT t1c_card_no, ref_key, count(Distinct Class_CODE) as class_cnt
		FROM TOPSRST.SALETRANS_&CYM. A
		JOIN TOPSRST.D_MERCHANDISE B ON PR_CODE = product_code
		where pr_code ^= '0000030959026' and dept_id not in ('07','10','')
		group by t1c_card_no, ref_key
		;
		QUIT;
	
	%END;
	%ELSE %DO;

		PROC SQL THREADS;
		INSERT INTO SEG.CLASS_ALL
		SELECT t1c_card_no, ref_key, count(Distinct Class_CODE) as class_cnt
		FROM TOPSRST.SALETRANS_&CYM. A
		JOIN TOPSRST.D_MERCHANDISE B ON PR_CODE = product_code
		where pr_code ^= '0000030959026' and dept_id not in ('07','10','')
		group by t1c_card_no, ref_key;
		QUIT;

	%END;

	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;
%END;

%MEND; 
%SC;
PROC SQL THREADS;
INSERT INTO SEG.CLASS_ALL
SELECT t1c_card_no, ref_key, count(Distinct Class_CODE) as class_cnt
FROM TOPSRST.saletrans_daily A
JOIN TOPSRST.D_MERCHANDISE B ON PR_CODE = product_code
where pr_code ^= '0000030959026' and dept_id not in ('07','10','')
and substr(put(ttm2,8.),1,6)="&LM."
group by t1c_card_no, ref_key;
QUIT;

PROC SQL THREADS;
CREATE TABLE SEG.CLASS_PER_TX (COMPRESS = YES) AS
SELECT SBL_MEMBER_ID, MEAN(Class_CNT) AS Class_CNT
FROM SEG.CLASS_ALL a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
GROUP BY SBL_MEMBER_ID;
QUIT;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select A.*, B.CLASS_CNT AS CLASS_PER_TX
from seg.CRM_SINGLE_VIEW_&SEGNAME. a 
left join seg.CLASS_PER_TX b on a.SBL_MEMBER_ID = b.SBL_MEMBER_ID;
quit;

%macro SD;
%let cym = &FM;
%do %while (&cym. < &LM.);

	%IF &cym. = &FM. %THEN %DO;
		PROC SQL THREADS;
		CREATE TABLE SEG.SD_ALL (COMPRESS = YES) AS
		SELECT t1c_card_no, STRIP(SUBDEPT_CODE)!!"_"!!STRIP(SUBDEPT_ENG_DESC) AS SUBDEPT, COUNT(DISTINCT REF_KEY) AS TX, SUM(TOTAL) AS TOTAL
		FROM TOPSRST.SALETRANS_&CYM. A
		LEFT JOIN TOPSRST.D_MERCHANDISE B ON A.PR_CODE =B.PRODUCT_CODE
		GROUP BY t1c_card_no, SUBDEPT;
		QUIT;
	%END;
	%ELSE %DO;
		PROC SQL THREADS;
		INSERT INTO SEG.SD_ALL
		SELECT t1c_card_no, STRIP(SUBDEPT_CODE)!!"_"!!STRIP(SUBDEPT_ENG_DESC) AS SUBDEPT, COUNT(DISTINCT REF_KEY) AS TX, SUM(TOTAL) AS TOTAL
		FROM TOPSRST.SALETRANS_&CYM. A
		LEFT JOIN TOPSRST.D_MERCHANDISE B ON A.PR_CODE =B.PRODUCT_CODE
		GROUP BY t1c_card_no, SUBDEPT;
		QUIT;
	%END;

	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;
%END;

%MEND;
%SD;
PROC SQL THREADS;
INSERT INTO SEG.SD_ALL
SELECT t1c_card_no, STRIP(SUBDEPT_CODE)!!"_"!!STRIP(SUBDEPT_ENG_DESC) AS SUBDEPT, COUNT(DISTINCT REF_KEY) AS TX, SUM(TOTAL) AS TOTAL
FROM TOPSRST.saletrans_daily A
LEFT JOIN TOPSRST.D_MERCHANDISE B ON A.PR_CODE =B.PRODUCT_CODE
where substr(put(ttm2,8.),1,6)="&LM."
GROUP BY t1c_card_no, SUBDEPT;
QUIT;

PROC SQL THREADS;
CREATE TABLE SEG.SD_ALL_ (COMPRESS = YES) AS
SELECT SBL_MEMBER_ID, SUBDEPT, SUM(TX) AS TX, SUM(TOTAL) AS TOTAL
FROM SEG.SD_ALL a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
GROUP BY SBL_MEMBER_ID, SUBDEPT;
QUIT;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes eoc=no) as
select *
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join 
(
	select SBL_MEMBER_ID,		
	sum(case when subdept = '0101_Snack' then total else 0 end) as S_0101_Snack,
	sum(case when subdept = '0102_Packaged' then total else 0 end) as S_0102_Packaged,
	sum(case when subdept = '0103_Cooking' then total else 0 end) as S_0103_Cooking,
	sum(case when subdept = '0105_Milk & Baby Food' then total else 0 end) as S_0105_Milk_Baby_Food,
	sum(case when subdept = '0106_Beverage' then total else 0 end) as S_0106_Beverage,
	sum(case when subdept = '0107_Inter Packaged' then total else 0 end) as S_0107_Inter_Packaged,
	sum(case when subdept = '0108_Inter Cooking' then total else 0 end) as S_0108_Inter_Cooking,
	sum(case when subdept = '0201_Cleaning' then total else 0 end) as S_0201_Cleaning,
	sum(case when subdept = '0202_Home Care' then total else 0 end) as S_0202_Home_Care,
	sum(case when subdept = '0203_Adult & Baby Care' then total else 0 end) as S_0203_Adult_Baby_Care,
	sum(case when subdept = '0205_GM' then total else 0 end) as S_0205_GM,
	sum(case when subdept = '0206_Appliances' then total else 0 end) as S_0206_Appliances,
	sum(case when subdept = '0207_Fashion' then total else 0 end) as S_0207_Fashion,
	sum(case when subdept = '0208_GM/Non FMCG' then total else 0 end) as S_0208_GM_Non_FMCG,
	sum(case when subdept = '0401_Makeup' then total else 0 end) as S_0401_Makeup,
	sum(case when subdept = '0402_Skin Care' then total else 0 end) as S_0402_Skin_Care,
	sum(case when subdept = '0403_Oral Care' then total else 0 end) as S_0403_Oral_Care,
	sum(case when subdept = '0404_Hair Care' then total else 0 end) as S_0404_Hair_Care,
	sum(case when subdept = '0405_Adult Hygiene' then total else 0 end) as S_0405_Adult_Hygiene,
	sum(case when subdept = '0407_OTOP' then total else 0 end) as S_0407_OTOP,
	sum(case when subdept = '0408_Health' then total else 0 end) as S_0408_Health,
	sum(case when subdept = '0501_Fresh Packaged' then total else 0 end) as S_0501_Fresh_Packaged,
	sum(case when subdept = '0502_Deli' then total else 0 end) as S_0502_Deli,
	sum(case when subdept = '0503_Bakery' then total else 0 end) as S_0503_Bakery,
	sum(case when subdept = '0504_RTE-Deli' then total else 0 end) as S_0504_RTE_Deli,
	sum(case when subdept = '0505_Fresh Meat' then total else 0 end) as S_0505_Fresh_Meat,
	sum(case when subdept = '0506_Fresh Seafood' then total else 0 end) as S_0506_Fresh_Seafood,
	sum(case when subdept = '0507_Produce' then total else 0 end) as S_0507_Produce,
	sum(case when subdept = '0508_Food Story' then total else 0 end) as S_0508_Food_Story,
	sum(case when subdept = '0601_Spirits' then total else 0 end) as S_0601_Spirits,
	sum(case when subdept = '0602_Wine' then total else 0 end) as S_0602_Wine,
	sum(case when subdept = '0605_Beer' then total else 0 end) as S_0605_Beer,
	sum(case when subdept = '0606_Tobacco' then total else 0 end) as S_0606_Tobacco,
	sum(case when subdept = '0801_Top up' then total else 0 end) as S_0801_Top_up,
	sum(case when subdept = '0901_Western Delicacies' then total else 0 end) as S_0901_Western_Delicacies,
	sum(case when subdept = '0902_International Fresh Packaged' then total else 0 end) as S_0902_Inter_Fresh_Packaged,
	sum(case when subdept = '0903_Segafredo Zanetti Espresso' then total else 0 end) as S_0903_Segafredo
	from seg.sd_all_
	group by SBL_MEMBER_ID
)b on a.SBL_MEMBER_ID = b.SBL_MEMBER_ID;

/*--------> run until here <--------*/
quit;

%macro sale;
%let cym = &FM.;
%do %while (&cym. < &LM.);
	%IF &cym. = &FM. %THEN %DO;

		proc sql threads;
		create table SEG.CC_ALL (compress= yes) as
		select t1c_card_no, cc_no
		from TOPSRST.SALETRANS_&cym.
		where t1c_card_no is not null and cc_no is not null and substr(cc_no,1,1) in ('1','2','3','4','5','6','7','8','9','0');
		quit;
	%END;
	%ELSE %DO;

		proc sql threads;
		INSERT INTO SEG.CC_ALL
		select t1c_card_no, cc_no
		from TOPSRST.SALETRANS_&cym.
		where t1c_card_no is not null and cc_no is not null and substr(cc_no,1,1) in ('1','2','3','4','5','6','7','8','9','0');
		quit;

	%END;

	%IF &CYM >= 202107 %THEN %DO;

		proc sql threads;
		INSERT INTO SEG.CC_ALL
		select t1c_card_no, cc_no
		from TOPSRST.SALETRANS_ONLINE_&cym.
		where t1c_card_no is not null and cc_no is not null and substr(cc_no,1,1) in ('1','2','3','4','5','6','7','8','9','0');
		quit;

	%END;


	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
options mPrint;
%sale;
proc sql threads;
INSERT INTO SEG.CC_ALL
select t1c_card_no, cc_no
from TOPSRST.saletrans_daily
where t1c_card_no is not null and cc_no is not null and substr(cc_no,1,1) in ('1','2','3','4','5','6','7','8','9','0')
and substr(put(ttm2,8.),1,6)="&LM.";
quit;

proc sql;
create table seg.cc_all_cust (compress = yes) as 
select distinct SBL_MEMBER_ID
from  SEG.CC_ALL A
JOIN TOPSSBL.SBL_MEMBER_CARD_lIST B ON A.t1c_card_no = B.t1c_card_no
;

/*--------> run until here <--------*/
quit;

proc sql threads;
create table seg.pos_media (compress = yes) as
select *
from topsrst.pos_payment_media
where trans_date between "&p_fd_fm." and "&p_ld_lm." and card_no is not null
;
quit;

proc sql threads;
create table seg.pos_media (compress = yes) as
select a.*, sbl_member_id
from seg.pos_media a
left join topssbl.sbl_member_card_list b on a.card_no = b.t1c_card_no
;
quit;

proc sql threads;
create table seg.pos_payment (compress = yes) as
select sbl_member_id, rcpt_no, store_id, trans_date, media_name, strip(substr(media_no,1,6)) as card_range, pay_amt
from seg.pos_media
where sbl_member_id is not null
;
quit;

proc sql threads;
create table seg.pos_payment_cash (compress = yes) as
select *
from seg.pos_payment
where media_name = 'CASH';
quit;

proc sql threads;
create table seg.pos_payment_notcash (compress = yes) as
select *, strip(STORE_ID)!!"_"!!strip(RCPT_NO)!!"_"!!strip(trans_date) as REF_KEY
from seg.pos_payment
where media_name ^= 'CASH' ;
quit;

proc sql threads;
create table seg.pos_payment_notcash (compress = yes) as
select sbl_member_id, media_name, card_range, REF_KEY, sum(pay_amt) as pay_amt
from seg.pos_payment_notcash
group by sbl_member_id, media_name, card_range, REF_KEY;
quit;

proc sql threads;
create table seg.crm_master_credit_card (compress = yes) as
select *, input(start, 6.) as start_2, input(end, 6.) as end_2
from crm.crm_master_credit_card;
quit;

proc sql threads;
create table seg.pos_payment_notcash (compress = yes) as
select a.*, tender_group, input(a.card_range, 6.) as card_range_2
from seg.pos_payment_notcash a
left join crm.TENDER_JUN19 b on a.media_name = b.tender
;
quit;

proc sql threads;
create table seg.pos_payment_notcash (compress = yes) as
select a.*, bank
from seg.pos_payment_notcash a
left join seg.crm_master_credit_card b on card_range_2 between start_2 and end_2;
quit;

proc sql threads;
create table seg.POS_PAYMENT_CASH (compress = yes) as
select *, strip(STORE_ID)!!"_"!!strip(RCPT_NO)!!"_"!!strip(trans_date) as REF_KEY
from seg.POS_PAYMENT_CASH;
quit;

proc sql threads;
create table seg.pos_paymentt (compress = yes) as
select sbl_member_id, ref_key, tender_group, bank, pay_amt
from seg.pos_payment_notcash
union all
select sbl_member_id, ref_key, 'Cash' as tender_group, '' as bank, pay_amt
from seg.pos_payment_cash;
/*------------> run until here <-----------------*/
quit;

%macro tx;
%let cym = &FM;
%do %while (&cym. < &LM.);
	%IF &cym. = &FM. %THEN %DO;
		proc sql threads;
		create table seg.tx_all (compress = yes) as 
		select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_&cym.
		group by REF_KEY;
		quit;

	%END;
	%ELSE %DO;

		proc sql threads;
		insert into seg.tx_all
		select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_&cym.
		group by REF_KEY;
		quit;

	%END;
	%IF &CYM >= 202107 %THEN %DO;

		proc sql threads;
		insert into seg.tx_all
		select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_ONLINE_&cym.
		group by REF_KEY;
		quit;

	%END;


	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
options mPrint;
%tx;
proc sql threads;
insert into seg.tx_all
select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_daily
where substr(put(ttm2,8.),1,6)="&LM."
group by REF_KEY;

insert into seg.tx_all
select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_online_daily
where substr(put(ttm2,8.),1,6)="&LM."
group by REF_KEY;
quit;

proc sql threads;
create table seg.pos_paymentt (compress = yes) as
select *, case when REF_KEY in (select REF_KEY from seg.tx_all) then 'Y' else 'N' end as Flag_Exst_Saletran
from seg.pos_paymentt;
quit;
/********************--------------->>>>>*/
proc sql threads;
create table seg.pos_payment_summary (compress = yes) as
select sbl_member_id, tender_group, bank, sum(pay_amt) as pay_amt, count(distinct ref_key) as tx
from seg.pos_paymentt
where Flag_Exst_Saletran = 'Y'
group by sbl_member_id, tender_group, bank;
quit;

proc sql threads;
create table seg.pos_payment_summary_tendor (compress = yes) as
select sbl_member_id, tender_group, sum(pay_amt) as pay_amt, count(distinct ref_key) as tx
from seg.pos_paymentt
where Flag_Exst_Saletran = 'Y'
group by sbl_member_id, tender_group;
quit;

proc sql threads;
create table seg.pos_payment_summary_tendor (compress = yes) as
select a.*, pay_amt/b.CFR_Total as P_Total
from seg.pos_payment_summary_tendor a
left join seg.CRM_SINGLE_VIEW_&SEGNAME. b on a.sbl_member_id = b.sbl_member_id;
quit;

proc transpose data=seg.pos_payment_summary_tendor out=seg.pos_payment_summary_tendor_;
	by sbl_member_id;
	id Tender_Group;
	var pay_amt;
run;

proc sql threads;
alter table seg.CRM_SINGLE_VIEW_&SEGNAME. drop column Pay_by_Cash, Pay_by_credit, Pay_by_Voucher, Pay_by_Point, Pay_by_Mobile, Pay_by_E_Payment;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes) as
select a.*, Cash as Pay_by_Cash, Credit as Pay_by_credit, 'Gift Card/Gift  Voucher'n as Pay_by_Voucher, Point as Pay_by_Point, Moblie_payment as Pay_by_Mobile, E_payment as Pay_by_E_Payment
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.pos_payment_summary_tendor_ b on a.sbl_member_id = b.sbl_member_id;
quit;

%macro sale;
%let cym = &FM.;

%do %while (&cym. < &LM.);

	%IF &cym. = &FM. %THEN %DO;

		proc sql threads;
		create table seg.dt_all (compress = yes) as 
		select ST_CODE, SBL_MEMBER_ID, case when weekday(datepart(ttm)) in (1,7) then 'Weekend' else 'Weekday' end as TRANS_WEEK, 
		case when weekday(datepart(ttm)) = 1 then 'Sunday' else
		case when weekday(datepart(ttm)) = 2 then 'Monday' else
		case when weekday(datepart(ttm)) = 3 then 'Tuesday' else
		case when weekday(datepart(ttm)) = 4 then 'Wednesday' else
		case when weekday(datepart(ttm)) = 5 then 'Thursday' else
		case when weekday(datepart(ttm)) = 6 then 'Friday' else
		case when weekday(datepart(ttm)) = 7 then 'Saturday' else '' end end end end end end end as TRAN_DAYOFWEEK, 
		case when timepart(ttm) between '00:00:00't and '09:59:59't and ttm is not null then 'Before 10.00' else
		case when timepart(ttm) between '10:00:00't and '13:59:59't and ttm is not null then '10.00 - 13.59' else 
		case when timepart(ttm) between '14:00:00't and '16:59:59't and ttm is not null then '14.00 - 16.59' else
		case when timepart(ttm) between '17:00:00't and '19:59:59't and ttm is not null then '17.00 - 19.59' else 
		case when timepart(ttm) between '18:00:00't and '23:59:59't and ttm is not null then 'After 20.00' else 'Unknown' end end end end end as TRANS_TIME,
		count(distinct ref_key) as tx, 
		sum(total) as total 
		from topsrst.saletrans_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_No = b.t1c_card_No
		where weekday(datepart(ttm)) between 1 and 7 and SBL_MEMBER_ID is not null
		group by ST_cODE, SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;
		quit;

	%end;
	%ELSE %DO;
		proc sql threads;
		insert into seg.dt_all
		select ST_cODE, SBL_MEMBER_ID, case when weekday(datepart(ttm)) in (1,7) then 'Weekend' else 'Weekday' end as TRANS_WEEK, 
		case when weekday(datepart(ttm)) = 1 then 'Sunday' else
		case when weekday(datepart(ttm)) = 2 then 'Monday' else
		case when weekday(datepart(ttm)) = 3 then 'Tuesday' else
		case when weekday(datepart(ttm)) = 4 then 'Wednesday' else
		case when weekday(datepart(ttm)) = 5 then 'Thursday' else
		case when weekday(datepart(ttm)) = 6 then 'Friday' else
		case when weekday(datepart(ttm)) = 7 then 'Saturday' else '' end end end end end end end as TRAN_DAYOFWEEK, 
		case when timepart(ttm) between '00:00:00't and '09:59:59't and ttm is not null then 'Before 10.00' else
		case when timepart(ttm) between '10:00:00't and '13:59:59't and ttm is not null then '10.00 - 13.59' else 
		case when timepart(ttm) between '14:00:00't and '16:59:59't and ttm is not null then '14.00 - 16.59' else
		case when timepart(ttm) between '17:00:00't and '19:59:59't and ttm is not null then '17.00 - 19.59' else 
		case when timepart(ttm) between '18:00:00't and '23:59:59't and ttm is not null then 'After 20.00' else 'Unknown' end end end end end as TRANS_TIME,
		count(distinct ref_key) as tx, 
		sum(total) as total 
		from topsrst.saletrans_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_No = b.t1c_card_No
		where SBL_MEMBER_ID is not null and weekday(datepart(ttm)) between 1 and 7
		group by ST_cODE, SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;
		quit;

	%end;

	%IF &cym. >= 202107 %THEN %DO;

		proc sql threads;
		insert into seg.dt_all
		select ST_cODE, SBL_MEMBER_ID, case when weekday(datepart(ttm)) in (1,7) then 'Weekend' else 'Weekday' end as TRANS_WEEK, 
		case when weekday(datepart(ttm)) = 1 then 'Sunday' else
		case when weekday(datepart(ttm)) = 2 then 'Monday' else
		case when weekday(datepart(ttm)) = 3 then 'Tuesday' else
		case when weekday(datepart(ttm)) = 4 then 'Wednesday' else
		case when weekday(datepart(ttm)) = 5 then 'Thursday' else
		case when weekday(datepart(ttm)) = 6 then 'Friday' else
		case when weekday(datepart(ttm)) = 7 then 'Saturday' else '' end end end end end end end as TRAN_DAYOFWEEK, 
		case when timepart(ttm) between '00:00:00't and '09:59:59't and ttm is not null then 'Before 10.00' else
		case when timepart(ttm) between '10:00:00't and '13:59:59't and ttm is not null then '10.00 - 13.59' else 
		case when timepart(ttm) between '14:00:00't and '16:59:59't and ttm is not null then '14.00 - 16.59' else
		case when timepart(ttm) between '17:00:00't and '19:59:59't and ttm is not null then '17.00 - 19.59' else 
		case when timepart(ttm) between '18:00:00't and '23:59:59't and ttm is not null then 'After 20.00' else 'Unknown' end end end end end as TRANS_TIME,
		count(distinct ref_key) as tx, 
		sum(total) as total 
		from topsrst.saletrans_ONLINE_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_No = b.t1c_card_No
		where SBL_MEMBER_ID is not null and weekday(datepart(ttm)) between 1 and 7
		group by ST_cODE, SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;
		quit;


	%END;

	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
%sale;
proc sql threads;
insert into seg.tx_all
select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_daily
where substr(put(ttm2,8.),1,6)="&LM."
group by REF_KEY;

insert into seg.tx_all
select REF_KEY, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_online_daily
where substr(put(ttm2,8.),1,6)="&LM."
group by REF_KEY;
quit;

proc sql threads;
insert into seg.dt_all
select ST_cODE, SBL_MEMBER_ID, case when weekday(datepart(ttm)) in (1,7) then 'Weekend' else 'Weekday' end as TRANS_WEEK, 
case when weekday(datepart(ttm)) = 1 then 'Sunday' else
case when weekday(datepart(ttm)) = 2 then 'Monday' else
case when weekday(datepart(ttm)) = 3 then 'Tuesday' else
case when weekday(datepart(ttm)) = 4 then 'Wednesday' else
case when weekday(datepart(ttm)) = 5 then 'Thursday' else
case when weekday(datepart(ttm)) = 6 then 'Friday' else
case when weekday(datepart(ttm)) = 7 then 'Saturday' else '' end end end end end end end as TRAN_DAYOFWEEK, 
case when timepart(ttm) between '00:00:00't and '09:59:59't and ttm is not null then 'Before 10.00' else
case when timepart(ttm) between '10:00:00't and '13:59:59't and ttm is not null then '10.00 - 13.59' else 
case when timepart(ttm) between '14:00:00't and '16:59:59't and ttm is not null then '14.00 - 16.59' else
case when timepart(ttm) between '17:00:00't and '19:59:59't and ttm is not null then '17.00 - 19.59' else 
case when timepart(ttm) between '18:00:00't and '23:59:59't and ttm is not null then 'After 20.00' else 'Unknown' end end end end end as TRANS_TIME,
count(distinct ref_key) as tx, 
sum(total) as total 
from topsrst.saletrans_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_No = b.t1c_card_No
where SBL_MEMBER_ID is not null and weekday(datepart(ttm)) between 1 and 7
and substr(put(ttm2,8.),1,6)="&LM."
group by ST_cODE, SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;


insert into seg.dt_all
select ST_cODE, SBL_MEMBER_ID, case when weekday(datepart(ttm)) in (1,7) then 'Weekend' else 'Weekday' end as TRANS_WEEK, 
case when weekday(datepart(ttm)) = 1 then 'Sunday' else
case when weekday(datepart(ttm)) = 2 then 'Monday' else
case when weekday(datepart(ttm)) = 3 then 'Tuesday' else
case when weekday(datepart(ttm)) = 4 then 'Wednesday' else
case when weekday(datepart(ttm)) = 5 then 'Thursday' else
case when weekday(datepart(ttm)) = 6 then 'Friday' else
case when weekday(datepart(ttm)) = 7 then 'Saturday' else '' end end end end end end end as TRAN_DAYOFWEEK, 
case when timepart(ttm) between '00:00:00't and '09:59:59't and ttm is not null then 'Before 10.00' else
case when timepart(ttm) between '10:00:00't and '13:59:59't and ttm is not null then '10.00 - 13.59' else 
case when timepart(ttm) between '14:00:00't and '16:59:59't and ttm is not null then '14.00 - 16.59' else
case when timepart(ttm) between '17:00:00't and '19:59:59't and ttm is not null then '17.00 - 19.59' else 
case when timepart(ttm) between '18:00:00't and '23:59:59't and ttm is not null then 'After 20.00' else 'Unknown' end end end end end as TRANS_TIME,
count(distinct ref_key) as tx, 
sum(total) as total 
from topsrst.saletrans_online_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_No = b.t1c_card_No
where SBL_MEMBER_ID is not null and weekday(datepart(ttm)) between 1 and 7
and substr(put(ttm2,8.),1,6)="&LM."
group by ST_cODE, SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;
/*-------------> run until here <----------------*/
quit;

proc sql threads;
create table seg.dt_all (compress = yes) as 
select SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME, sum(tx) as tx, sum(total) as total
from seg.dt_all
group by SBL_MEMBER_ID, TRANS_WEEK, TRAN_DAYOFWEEK, TRANS_TIME;
quit;

proc sql threads;
create table seg.dt_all_wde (compress = yes) as 
select SBL_MEMBER_ID, TRANS_WEEK, sum(total) as total
from seg.dt_all
group by SBL_MEMBER_ID, TRANS_WEEK;
quit;

proc transpose data=seg.dt_all_wde out=seg.dt_all_wde (drop=_name_ _label_) prefix=S_;
	by SBL_MEMBER_ID;
	id TRANS_WEEK;
	var total;
run;

proc sql;
create table seg.dt_all_dow (compress = yes) as 
select SBL_MEMBER_ID, TRAN_DAYOFWEEK, sum(total) as total
from seg.dt_all
group by SBL_MEMBER_ID, TRAN_DAYOFWEEK;
quit;

proc transpose data=seg.dt_all_dow out=seg.dt_all_dow (drop=_name_ _label_) prefix=S_;
	by SBL_MEMBER_ID;
	id TRAN_DAYOFWEEK;
	var total;
run;

proc sql;
create table seg.dt_all_tod (compress = yes) as 
select SBL_MEMBER_ID, TRANS_TIME, sum(total) as total
from seg.dt_all
group by SBL_MEMBER_ID, TRANS_TIME;
quit;

proc transpose data=seg.dt_all_tod out=seg.dt_all_tod (drop=_name_ _label_) prefix=S_;
	by SBL_MEMBER_ID;
	id TRANS_TIME;
	var total;
run;

proc sql;
create table seg.dt_all_wtod (compress = yes) as 
select SBL_MEMBER_ID, TRANS_WEEK, TRANS_TIME, sum(total) as total
from seg.dt_all
group by SBL_MEMBER_ID, TRANS_WEEK, TRANS_TIME;
quit;

proc transpose data=seg.dt_all_wtod out=seg.dt_all_wtod (drop=_name_ _label_) prefix=S_;
	by SBL_MEMBER_ID;
	id TRANS_WEEK TRANS_TIME;
	var total;
run;

PROC SQL THREADS;
alter table seg.CRM_SINGLE_VIEW_&SEGNAME. drop column S_10_00___13_59,S_14_00___16_59,S_17_00___19_59,
S_After_20_00,S_Before_10_00,S_WeekdayBefore_10_00,S_Weekday10_00___13_59,S_Weekday14_00___16_59,S_Weekday17_00___19_59,
S_WeekdayAfter_20_00,S_WeekendBefore_10_00,S_Weekend10_00___13_59,S_Weekend14_00___16_59,S_Weekend17_00___19_59,S_WeekendAfter_20_00,
S_Saturday,S_Sunday,S_Thursday,S_Friday,S_Monday,S_Wednesday,S_Tuesday,S_weekday,S_Weekend;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES EOC=NO) AS
SELECT A.*, 
C.*,
'S_10.00 - 13.59'n  as S_10_00___13_59,
'S_14.00 - 16.59'n  as S_14_00___16_59,
'S_17.00 - 19.59'n  as S_17_00___19_59,
'S_After 20.00'n  as S_After_20_00,
'S_Before 10.00'n  as S_Before_10_00,
E.*,
'S_Weekday10.00 - 13.59'n  as S_WeekdayBefore_10_00,
'S_Weekday14.00 - 16.59'n  as S_Weekday10_00___13_59,
'S_Weekday17.00 - 19.59'n  as S_Weekday14_00___16_59,
'S_WeekdayAfter 20.00'n  as S_Weekday17_00___19_59,
'S_WeekdayBefore 10.00'n  as S_WeekdayAfter_20_00,
'S_Weekend10.00 - 13.59'n  as S_WeekendBefore_10_00,
'S_Weekend14.00 - 16.59'n  as S_Weekend10_00___13_59,
'S_Weekend17.00 - 19.59'n  as S_Weekend14_00___16_59,
'S_WeekendBefore 10.00'n  as S_Weekend17_00___19_59,
'S_WeekendAfter 20.00'n  as S_WeekendAfter_20_00
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.Dt_all_dow C ON A.SBL_MEMBER_ID = C.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_tod D ON A.SBL_MEMBER_ID = D.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_wde E ON A.SBL_MEMBER_ID = E.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_wtod F ON A.SBL_MEMBER_ID = F.SBL_MEMBER_ID;
QUIT;

proc sql threads;
create table seg.cc_all_tx (compress = yes) as 
select SBL_MEMBER_ID, bank, sum(tx) as tx, sum(pay_amt) as total
from seg.pos_payment_summary
where Tender_Group = 'Credit'
group by SBL_MEMBER_ID, bank;
quit;

proc transpose data=seg.cc_all_tx out=seg.cc_all_tx (drop=_name_ _label_) prefix=tx_;
	by SBL_MEMBER_ID;
	id bank;
	var tx;
run;

PROC SQL THREADS;
CREATE TABLE SEG.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES EOC=NO) AS
SELECT A.*, b.*
FROM SEG.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.CC_ALL_TX B ON A.SBL_MEMBER_ID = B.SBL_MEMBER_ID;
quit;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress  =yes) as
select a.*, B2S, CDS, CFM, COL, HWS, OFM, PWB, RBS, SSP
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join 
(
	select sbl_member_id, max(B2S) as b2s, max(CDS) as cds, max(CFM) as CFM, max(CGO) as COL, max(HWS) as HWS,
	max(OFM) as OFM, max(PWB) as PWB, max(RBS) as RBS, max(SSP) as SSP
	from TOPSSBL.SBL_CUSTOMER_BU
	where YEARMONTH >= "&FM."
	group by sbl_member_id 
)b on a.SBL_MEMBER_ID = b.sbl_member_id;
quit;

proc sql threads;
create table seg.cc_all_detail (compress = yes) as
select *
from seg.pos_paymentt
where Tender_Group = 'Credit' and Flag_Exst_Saletran = 'Y'
;
quit;

proc sql threads;
create table seg.cc_all_detail (compress = yes) as
select a.*, 
a.pay_amt as cc_total,
a.pay_amt/b.total*gp as cc_gp,
a.pay_amt/b.total*net_total as cc_net_total
from seg.cc_all_detail a
left join seg.tx_all  b on a.ref_key = b.ref_key;
quit;

proc sql threads;
create table seg.cc_all_detail_1 (compress = yes) as
select sbl_member_id, count(Distinct ref_key) as cc_tx, sum(cc_total) as cc_total, sum(cc_gp) as cc_gp, sum(cc_net_total) as cc_net_total
from seg.cc_all_detail
group by sbl_member_id;
quit;

proc sql threads;
create table SEG.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) as
select *
from SEG.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.cc_all_detail_1 b on a.sbl_member_id = b.sbl_member_id;
quit;

%macro sale;
%let cym = &FM.;

%do %while (&cym. < &LM.);

	%IF &cym. = &FM. %THEN %DO;

		PROC SQL THREADS;
		CREATE TABLE seg.TSOL_All (compress= yes) as
		SELECT &CYM. AS YM, SBL_MEMBER_ID, count(distinct REF_KEY) as REF_A, sum(total) as TOTAL_A, sum(GP) as GP_A, sum(net_total) as NET_TOTAL_A
		FROM TOPSRST.SALETRANS_&CYM. A
		JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO
		WHERE substr(reference, 1,3) in ('071','701','072','073','074','075','076','077','078','079','701')  OR ST_CODE = '432'
		GROUP BY SBL_MEMBER_ID;
		QUIT;

	%end;
	%ELSE %DO;
		PROC SQL THREADS;
		INSERT INTO seg.TSOL_All
		SELECT &CYM. AS YM, SBL_MEMBER_ID, count(distinct REF_KEY) as REF_A, sum(total) as TOTAL_A, sum(GP) as GP_A, sum(net_total) as NET_TOTAL_A
		FROM TOPSRST.SALETRANS_&CYM. A
		JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO
		WHERE substr(reference, 1,3) in ('071','701','072','073','074','075','076','077','078','079','701') OR ST_CODE = '432'
		GROUP BY SBL_MEMBER_ID;
		QUIT;

	%end;

	%IF &cym. >= 202107 %THEN %DO;

		PROC SQL THREADS;
		INSERT INTO seg.TSOL_All
		SELECT &CYM. AS YM, SBL_MEMBER_ID, count(distinct REF_KEY) as REF_A, sum(total) as TOTAL_A, sum(GP) as GP_A, sum(net_total) as NET_TOTAL_A
		FROM TOPSRST.SALETRANS_ONLINE_&CYM. A
		JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO
		GROUP BY SBL_MEMBER_ID;
		QUIT;

	%END;

	%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
              %let cym = %eval(&cym. +89);
              %end;
    %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%MEND;
%sale;
PROC SQL THREADS;
INSERT INTO seg.TSOL_All
SELECT &lm. AS YM, SBL_MEMBER_ID, count(distinct REF_KEY) as REF_A, sum(total) as TOTAL_A, sum(GP) as GP_A, sum(net_total) as NET_TOTAL_A
FROM TOPSRST.saletrans_daily A
JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO
WHERE substr(reference, 1,3) in ('071','701','072','073','074','075','076','077','078','079','701') OR ST_CODE = '432'
and substr(put(ttm2,8.),1,6)="&LM."
GROUP BY SBL_MEMBER_ID;

INSERT INTO seg.TSOL_All
SELECT &lm. AS YM, SBL_MEMBER_ID, count(distinct REF_KEY) as REF_A, sum(total) as TOTAL_A, sum(GP) as GP_A, sum(net_total) as NET_TOTAL_A
FROM TOPSRST.saletrans_online_daily A
JOIN TOPSSBL.SBL_MEMBER_CARD_LIST B ON A.T1C_CARD_NO = B.T1C_CARD_NO
WHERE substr(put(ttm2,8.),1,6)="&LM."
GROUP BY SBL_MEMBER_ID;

QUIT;


proc sql threads;
create table seg.TSOL_All (compress= yes) as
SELECT SBL_MEMBER_ID, sum(REF_A) as REF_A, sum(TOTAL_A) as TOTAL_A, sum(GP_A) as GP_A, sum(NET_TOTAL_A) as NET_TOTAL_A, count(distinct ym) as mv, max(ym)as lv
FROM seg.tsol_all
GROUP BY SBL_MEMBER_ID;
QUIT;

proc sql threads;
create table seg.CRM_SINGLE_VIEW_&SEGNAME. (compress  =yes) as
select a.*, 
b.ref_a as tol_tx, b.total_a as tol_total, b.gp_a as tol_gp, b.net_total_a as tol_net_total, b.mv as tol_month_visit
from seg.CRM_SINGLE_VIEW_&SEGNAME. a
left join seg.tsol_all b on a.SBL_MEMBER_ID = b.SBL_MEMBER_ID;
quit;

/* boss comment 20230831 เพราะตอนรัน 23Q2 มัน error และ table ที่ create ไม่ได้ใช้งานต่อที่ code อื่นๆ
PROC SQL THREADS;
CREATE TABLE SEG.CRM_SINGLE_VIEWs2_&SEGNAME. (COMPRESS = YES) AS
SELECT *,
case when tol_tx > 0 then 'Y' else 'N' end as Flag_TSOL_ACCOUNT,
case when sbl_member_id in (select sbl_member_id from crm.LINE_REGISTERED_CFR_202206) then 'Y' else 'N' end as Flag_Line_TOPS,
case when TOL_TX > 0 and CFR_Tx ^= TOL_TX then 'CFR Omni-Channel' else
case when TOL_tx > 0 and CFR_Tx = TOL_tx then 'CFR Online Only' else 
case when segment_no_gp_e ^= . then 'CFR Offline Only' else '' end end end as Flag_Omni_Channel
from SEG.CRM_SINGLE_VIEWs_&SEGNAME.;
quit;
*/

PROC SQL THREADS;
alter table SEG.CRM_SINGLE_VIEW_&SEGNAME. drop column S_10_00___13_59,S_14_00___16_59,S_17_00___19_59,
S_After_20_00,S_Before_10_00,S_WeekdayBefore_10_00,S_Weekday10_00___13_59,S_Weekday14_00___16_59,S_Weekday17_00___19_59,
S_WeekdayAfter_20_00,S_WeekendBefore_10_00,S_Weekend10_00___13_59,S_Weekend14_00___16_59,S_Weekend17_00___19_59,S_WeekendAfter_20_00,
S_Saturday,S_Sunday,S_Thursday,S_Friday,S_Monday,S_Wednesday,S_Tuesday,S_weekday,S_Weekend;
CREATE TABLE SEG.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES EOC=NO) AS
SELECT A.*, 
C.*,
'S_10.00 - 13.59'n  as S_10_00___13_59,
'S_14.00 - 16.59'n  as S_14_00___16_59,
'S_17.00 - 19.59'n  as S_17_00___19_59,
'S_After 20.00'n  as S_After_20_00,
'S_Before 10.00'n  as S_Before_10_00,
E.*,
'S_Weekday10.00 - 13.59'n  as S_WeekdayBefore_10_00,
'S_Weekday14.00 - 16.59'n  as S_Weekday10_00___13_59,
'S_Weekday17.00 - 19.59'n  as S_Weekday14_00___16_59,
'S_WeekdayAfter 20.00'n  as S_Weekday17_00___19_59,
'S_WeekdayBefore 10.00'n  as S_WeekdayAfter_20_00,
'S_Weekend10.00 - 13.59'n  as S_WeekendBefore_10_00,
'S_Weekend14.00 - 16.59'n  as S_Weekend10_00___13_59,
'S_Weekend17.00 - 19.59'n  as S_Weekend14_00___16_59,
'S_WeekendBefore 10.00'n  as S_Weekend17_00___19_59,
'S_WeekendAfter 20.00'n  as S_WeekendAfter_20_00
FROM SEG.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.Dt_all_dow C ON A.SBL_MEMBER_ID = C.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_tod D ON A.SBL_MEMBER_ID = D.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_wde E ON A.SBL_MEMBER_ID = E.SBL_MEMBER_ID
LEFT JOIN SEG.Dt_all_wtod F ON A.SBL_MEMBER_ID = F.SBL_MEMBER_ID;
QUIT;

PROC SQL THREADS;
CREATE TABLE SEG.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES EOC=NO) AS
SELECT A.*, b.total_e as CFR_TOTAL_E, b.gp_e as CFR_GP_E, b.net_total_e as CFR_NET_TOTAL_E
FROM SEG.CRM_SINGLE_VIEW_&SEGNAME. A
left join seg.CFR_ALL_E_2 b on a.sbl_member_id = b.sbl_member_id;
;quit;

PROC SQL threads;
CREATE TABLE SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT *,
CASE WHEN Pay_by_point > 0 THEN 'Y' ELSE 'N' END AS FLAG_REDEEM,
CASE WHEN Pay_by_Credit > 0 THEN 'Y' ELSE 'N' END AS FLAG_CREDIT_CARD
FROM SEG.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT;


/*Begin_Left_Join_1*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 	a.*,
b.bu_register,
b.dateofbirth,
b.declared_gender,
b.declared_marital_status,
b.is_cg_expat
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_2*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT a.*,
b.member_number,
b.member_status,
b.nationality,
b.registerdate,
b.share_card_flag
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_3*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT a.*,
      b.the1_app_user,
b.the1_inter,
b.have_kids,
b.kids_stage,
b.address_province
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_4*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT a.*,
b.address_zipcode,
b.most_visit_location,
b.most_visit_province,
b.most_visit_subregion,
b.most_freq_creditcard_bank
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;

 
/*Begin_Left_Join_5*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT a.* ,
b.most_freq_creditcard_face,
b.payment_segment,
b.creditcard_the1_face,
b.online_cg_spending_l1y,
b.beauty_luxury_segment
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_6*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT a.*,
b.beauty_segment,
b.fashion_luxury_segment,
b.food_healthy_flag,
b.food_luxury_segment,
b.electronics_luxury_segment
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_7*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
 	a.*,
b.point_lover_segment,
b.tierpointbalance,
b.consent_flag,
b.is_active_cfr_l1y,
b.is_address
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_8*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.is_address_cfr,
b.is_call_cfr,
b.is_cfr_line,
b.is_email,
b.is_email_cfr
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;

/*Begin_Left_Join_9*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.is_send_sms_eng,
b.is_send_sms_eng_cfr,
b.is_send_sms_thai,
b.is_send_sms_thai_cfr,
b.is_the1_line
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;

/*Begin_Left_Join_10*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.iscall,
b.line_the1_latest_linked_date,
b.app_active,
b.app_redeem,
b.have_dolfin_app

from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_11*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
	a.*,
b.online_affinity_segment,
b.cg_ranking_2018,
b.cg_ranking_2019,
b.cg_ranking_2020,
b.cg_ranking_2021,
b.cg_ranking_2022,
b.cg_ranking_2023
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;
/*next*/

/*Begin_Left_Join_12*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.wealth_segment,
b.cfr_main_competitor,
b.cfr_main_competitor_type,
b.cfr_ranking_2018,
b.cfr_ranking_2019
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_13*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.cfr_ranking_2020,
b.cfr_ranking_2021,
b.cfr_ranking_2022,
b.cfr_ranking_2023,
b.cfr_share_of_wallet_q1,
b.cfr_share_of_wallet_q2,
b.cfr_share_of_wallet_q3
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;
/*next*/
/*Begin_Left_Join_14*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.cfr_share_of_wallet_q4,
b.have_cfr_app,
b.coffee_segment,
b.dining_luxury_segment,
b.healthy_lifestyle_preferred
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_15*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.home_cooking_flag,
b.liquor_drinker,
b.pet_lover_segment,
b.have_car,
b.beauty_discount_sensitivity
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;
quit;


/*Begin_Left_Join_16*/
proc sql threads;
create table SEG.CRM_SINGLE_VIEWS_&SEGNAME. (COMPRESS = YES) AS
SELECT 
      a.*,
b.fashion_discount_sensitivity,
b.food_grocery_discount_sensitivit,
b.home_electronics_discount_sensit,
b.home_grocery_discount_sensitivit,
b.kids_discount_sensitivity
from seg.CRM_SINGLE_VIEWS_&SEGNAME. a
left join topscrm.VW_SVOC_ShareBU b on a.sbl_member_id = b.member_number;

/*-------------> run until here <----------------*/
quit;



/*data SEG.CRM_SINGLE_VIEW_test_&SEGNAME. (compress=yes);*/
/*set CRM.CRM_SINGLE_VIEW_&SEGNAME.;*/
/*run;*/


/*This path for accumulate report*/
%macro c;
%let cym = &FM.;
%do %while (&cym. <= &LM.);
	  %IF &cym. = &LM. %THEN %DO; 
	      proc sql threads;
	      create table tmp as
	      select t1c_card_no, ref_key, pr_code, total, gp, net_total,
	      CasE WHEN pr_code in (select product_code from TOPSRST.D_Merchandise where class_code in ('010102','010103','010104','080102','080103','080104')) THEN 'Snack' ELSE
	      CAsE WHEN pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0401','0402','0403','0404','0407','0408')) THEN 'HBC' ELSE
	      case when pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0507')) then 'Produce' else
	      case when pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0903','0502','0503','0504','0508')) then 'Food Destination' else '' end end end end as FLAG_4ROOM
	      from topsrst.saletrans_daily
	      where (pr_code in (select product_code from TOPSRST.D_Merchandise where class_code in ('010102','010103','010104','080102','080103','080104'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0401','0402','0403','0404','0407','0408'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0507'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0903','0502','0503','0504','0508')))
	      and t1c_card_no is not null
		  and substr(put(ttm2,8.),1,6)="&LM."
	      ;
	      quit;
	%end;
	%else %do;
		  proc sql threads;
	      create table tmp as
	      select t1c_card_no, ref_key, pr_code, total, gp, net_total,
	      CasE WHEN pr_code in (select product_code from TOPSRST.D_Merchandise where class_code in ('010102','010103','010104','080102','080103','080104')) THEN 'Snack' ELSE
	      CAsE WHEN pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0401','0402','0403','0404','0407','0408')) THEN 'HBC' ELSE
	      case when pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0507')) then 'Produce' else
	      case when pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0903','0502','0503','0504','0508')) then 'Food Destination' else '' end end end end as FLAG_4ROOM
	      from topsrst.saletrans_&cym.
	      where (pr_code in (select product_code from TOPSRST.D_Merchandise where class_code in ('010102','010103','010104','080102','080103','080104'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0401','0402','0403','0404','0407','0408'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0507'))
	      or pr_code in (select product_code from TOPSRST.D_Merchandise where subdept_code in ('0903','0502','0503','0504','0508')))
	      and t1c_card_no is not null
	      ;
	      quit;
    %end;
	PROC SQL THREADS;
	CREATE TABLE seg.snack_&cym. (compress = yes) as
	SELECT SBL_MEMBER_ID, COUNT(DISTINCT ref_key) AS TX, SUM(TOTAL) AS TOTAL, SUM(GP) AS GP, SUM(NET_TOTAL) AS NET_TOTAL
	FROM tmp a
	join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
	WHERE Flag_4ROOM = 'Snack'
	GROUP BY SBL_MEMBER_ID;
	QUIT;

	PROC SQL THREADS;
	CREATE TABLE seg.HBC_&cym. (compress = yes) as
	SELECT SBL_MEMBER_ID, COUNT(DISTINCT ref_key) AS TX, SUM(TOTAL) AS TOTAL, SUM(GP) AS GP, SUM(NET_TOTAL) AS NET_TOTAL
	FROM tmp a
	join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
	WHERE Flag_4ROOM = 'HBC'
	GROUP BY SBL_MEMBER_ID;
	QUIT;

	PROC SQL THREADS;
	CREATE TABLE seg.Produce_&cym. (compress = yes) as
	SELECT SBL_MEMBER_ID, COUNT(DISTINCT ref_key) AS TX, SUM(TOTAL) AS TOTAL, SUM(GP) AS GP, SUM(NET_TOTAL) AS NET_TOTAL
	FROM tmp a
	join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
	WHERE Flag_4ROOM = 'Produce'
	GROUP BY SBL_MEMBER_ID;
	QUIT;

	PROC SQL THREADS;
	CREATE TABLE seg.FD_&cym. (compress = yes) as
	SELECT SBL_MEMBER_ID, COUNT(DISTINCT ref_key) AS TX, SUM(TOTAL) AS TOTAL, SUM(GP) AS GP, SUM(NET_TOTAL) AS NET_TOTAL
	FROM tmp a
	join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
	WHERE Flag_4ROOM = 'Food Destination'
	GROUP BY SBL_MEMBER_ID;
	QUIT;

      %if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
                    %let cym = %eval(&cym. +89);
                    %end;
          %else %do; %let cym = %eval(&cym. +1); %end;

%end;
%mend;
%c;

%MACRO CAT(X);
DATA SEG.&X._ALL (COMPRESS = YES);
SET SEG.&X._&p_lm. 
SEG.&X._&p_l2m.
SEG.&X._&p_l3m.
SEG.&X._&p_l4m.
SEG.&X._&p_l5m.
SEG.&X._&p_l6m.
SEG.&X._&p_l7m.
SEG.&X._&p_l8m.
SEG.&X._&p_l9m.
SEG.&X._&p_l10m.
SEG.&X._&p_l11m.
SEG.&X._&p_l12m.
;
run;

PROC SQL THREADS;
CREATE TABLE SEG.&X._ALL (compress = yes) as
SELECT SBL_MEMBER_ID, SUM(TX) AS TX, SUM(TOTAL) AS TOTAL, SUM(GP) AS GP, SUM(NET_TOTAL) AS NET_TOTAL
FROM SEG.&X._ALL
GROUP BY SBL_MEMBER_ID;
QUIT;
%MEND;
%CAT(Snack);
%CAT(HBC);
%CAT(Produce);
%CAT(FD);

PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEWS_&SEGNAME._TMP (compress = yes) as
SELECT A.*,
B.TX AS TX_SNACK, B.TOTAL AS TOTAL_SNACK, B.GP AS GP_SNACK, B.NET_TOTAL AS NET_TOTAL_SNACK,
C.TX AS TX_HBC, C.TOTAL AS TOTAL_HBC, C.GP AS GP_HBC, C.NET_TOTAL AS NET_TOTAL_HBC,
D.TX AS TX_PRODUCE, D.TOTAL AS TOTAL_PRODUCE, D.GP AS GP_PRODUCE, D.NET_TOTAL AS NET_TOTAL_PRODUCE,
E.TX AS TX_FD, E.TOTAL AS TOTAL_FD, E.GP AS GP_FD, E.NET_TOTAL AS NET_TOTAL_FD
FROM seg.CRM_SINGLE_VIEWS_&SEGNAME. A
LEFT JOIN SEG.SNACK_ALL B ON A.SBL_MEMBER_ID = b.SBL_MEMBER_ID
LEFT JOIN SEG.HBC_ALL C ON A.SBL_MEMBER_ID = C.SBL_MEMBER_ID
LEFT JOIN SEG.PRODUCE_ALL D ON A.SBL_MEMBER_ID = D.SBL_MEMBER_ID
LEFT JOIN SEG.FD_ALL E ON A.SBL_MEMBER_ID = E.SBL_MEMBER_ID;
QUIT;
/*Add Flag_Omni_Channel*/



PROC SQL THREADS;
CREATE TABLE seg.OMNI_CHANNEL_&SEGNAME. (compress = yes) as
SELECT sbl_member_id, 
max(TRANS_DATE) as last_vist,
sum(case when Channel = 'Offline' then TOTAL else 0 end) as TOTAL_Offline,
sum(case when Channel = 'Offline' then NET_TOTAL else 0 end) as NET_TOTAL_Offline,
sum(case when Channel = 'Offline' then TRANS else 0 end) as TRANS_Offline,
sum(case when Channel = 'Offline' then GP else 0 end) as GP_Offline,
sum(case when Channel = 'Offline' then QUANTITY else 0 end) as QUANTITY_Offline,
sum(case when Channel = 'Online' then TOTAL else 0 end) as TOTAL_Online,
sum(case when Channel = 'Online' then NET_TOTAL else 0 end) as NET_TOTAL_Online,
sum(case when Channel = 'Online' then TRANS else 0 end) as TRANS_Online,
sum(case when Channel = 'Online' then GP else 0 end) as GP_Online,
sum(case when Channel = 'Online' then QUANTITY else 0 end) as QUANTITY_Online
FROM TOPSCRM.SALES_SUMMARY_REPORT
WHERE Flag_member='Member'
and TRANS_DATE BETWEEN "&p_fd_fmmm."d and "&p_ld_lmmm."d
GROUP BY sbl_member_id;
QUIT;



PROC SQL THREADS;
CREATE TABLE seg.OMNI_CHANNEL_&SEGNAME. (compress = yes) as
SELECT 
*,
TOTAL_Offline+TOTAL_Online as TOTAL_Omni,
NET_TOTAL_Offline+NET_TOTAL_Online as NET_TOTAL_Omni,
TRANS_Offline+TRANS_Online as TRANS_Omni,
GP_Offline+GP_Online as GP_Omni,
QUANTITY_Offline+QUANTITY_Online as QUANTITY_Omni,
case when (TRANS_Offline > 0) and (TRANS_Online > 0) then 'Omni'
	 when (TRANS_Offline > 0) and (TRANS_Online is null ) then 'Offline'
	 when (TRANS_Offline is null) and (TRANS_Online>0) then 'Online' else 'Offline' end as Channel,
case when (TRANS_Offline > 0) and (TRANS_Online > 0) then 'Y' else 'N' end as Omni_channel
FROM seg.OMNI_CHANNEL_&SEGNAME.;
QUIT;


PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEWS_&SEGNAME._TMP_OMNI (compress = yes) as
SELECT A.*, 
B.Channel as Flag_Omni_Channel
FROM seg.CRM_SINGLE_VIEWS_&SEGNAME._TMP A
LEFT JOIN seg.OMNI_CHANNEL_&SEGNAME. B ON A.SBL_MEMBER_ID = B.SBL_MEMBER_ID;
QUIT;
/* Run Oat*/ 
data CRM.CRM_SINGLE_VIEW_&SEGNAME. (compress = yes);
set seg.CRM_SINGLE_VIEWS_&SEGNAME._TMP_OMNI;
run;

