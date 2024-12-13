options dlcreatedir;
libname seg "I:\Faroh\HPT\work_file\crm_single_view";

/* Set parameter*/
/* end q - 12 month. exam end q2= 202306 first period= 202207*/

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


/* set new parameter to old variable*/
%LET FM = &p_fm.;
%LET LM = &p_lm.;
%LET FMLQ = &p_fmlq.; /*FIRST MONTH OF LAST QUARTER*/
%LET SEGNAME = &p_yqlm.; /*Year and Quater SingleView*/

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

/*req. by P'TON - ignore CMK @20231212 */


/*12 months*/
/*CFG(CFR, CFM,CMK)*/
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

/* Last month get from table daily*/
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


/*sumary*/
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

proc transpose data=seg.cfg_all_BU out=seg.cfg_all_BU_T;
	by sbl_member_id;
	id BU;
	var BU_Rank;
run; 

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

/*--------> run until here <--------*/
QUIT; 

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
ST_MOST_FREQ,
ST_MOST_FREQ_NAME,
ST_MOST_FREQ_FORMAT,
ST_MOST_FREQ_LOCATION,
C.TOTAL as ST_MOST_SPENDING_SALE 'ST_MOST_SPENDING_SALE',
ST_MOST_SPENDING,
ST_MOST_SPENDING_NAME,
ST_MOST_SPENDING_FORMAT,
ST_MOST_SPENDING_LOCATION
FROM SEG.CFR_HS A
LEFT JOIN SEG.cfr_sgst_all_3_TXN B ON A.sbl_memBer_id = B.sbl_memBer_id
LEFT JOIN SEG.cfr_sgst_all_3_SALE C ON A.sbl_memBer_id = C.sbl_memBer_id;

/*--------> run until here <--------*/
QUIT;

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

/*--------> run until here <--------*/
%homestore; 

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

PROC SQL THREADS;
CREATE TABLE SEG.CFM_HS (compress= yes) AS
SELECT A.sbl_memBer_id, a.st_code as CFM_HOME_STORE_CODE, STRIP(B.STORE_NAME)!!"_"!!STRIP(A.ST_CODE) AS CFM_HOME_STORE, 
CASE WHEN B.STORE_FORMAT='Building' THEN 'Family Mart' ELSE B.STORE_FORMAT END AS CFM_HOME_STORE_FORMAT, B.STORE_LOCATION AS CFM_HOME_STORE_LOCATION
FROM SEG.CFM_SGST_All_3 A
LEFT JOIN TOPSCFM.STORE_MASTER B ON A.ST_CODE = B.STORE_CODE;
QUIT; 

PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *
FROM seg.CRM_SINGLE_VIEW_&SEGNAME. A
LEFT JOIN SEG.CFM_HS B ON A.sbl_memBer_id = B.sbl_memBer_id;
QUIT; 



/*CFG - HOME_STORE*/
PROC SQL THREADS;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (compress= yes) AS
SELECT *,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_CODE else CFM_HOME_STORE_CODE end as CFG_HOME_STORE_CODE,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE else CFM_HOME_STORE end as CFG_HOME_STORE,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_FORMAT else CFM_HOME_STORE_FORMAT end as CFG_HOME_STORE_FORMAT,
case when (CFR_TX*0.6)+(CFR_TOTAL*0.4) >= (CFM_TX*0.6)+(CFM_TOTAL*0.4) then CFR_HOME_STORE_LOCATION else CFM_HOME_STORE_LOCATION end as CFG_HOME_STORE_LOCATION
FROM seg.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT; 



/*CFR TOTAL_E*/
proc sql threads;
create table seg.exclusion_item (compress = yes) as
select distinct a.*
from topsrst.d_merchandise a
join topsrst.b_categorycondition b on a.subcat_code = b.cat_code
where ConditionID=42022;
quit; 

proc sql threads;
create table seg.CFR_ALL_E (compress = yes) as
select 'CFR' as BU, &fm. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total_E, sum(gp) as gp_E, sum(net_total) as net_total_E
from topsrst.saletrans_&fm. a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
WHERE PR_CODE NOT IN (SELECT PRODUCT_CODE FROM seg.exclusion_item)
group by sbl_member_id;
quit; 

%macro sale;
%let cym = %eval(&FM. +1);

	%do %while (&cym. < &lm.);
		%put &cym.;

		proc sql threads;
		insert into seg.CFR_ALL_E
		select 'CFR' as BU, &cym. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
		from topsrst.saletrans_&cym. a
		join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
		WHERE PR_CODE NOT IN (SELECT PRODUCT_CODE FROM seg.exclusion_item)
		group by sbl_member_id;

		%if (&cym. >= &FM.) %then %do;
			proc sql threads;
			insert into seg.CFR_ALL_E
			select 'CFR' as BU, &cym. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
			from topsrst.saletrans_online_&cym. a
			join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
			WHERE PR_CODE NOT IN (SELECT PRODUCT_CODE FROM seg.exclusion_item)
			group by sbl_member_id;
		%end;

		%if %sysfunc(MOD(&cym.,100))+1 > 12 %then %do;
	              %let cym = %eval(&cym. +89);
	              %end;
	    %else %do; %let cym = %eval(&cym. +1); %end;
	%end;


%MEND;

/*--------> run until here <--------*/
%sale;

proc sql threads;
insert into seg.CFR_ALL_E
select 'CFR' as BU, &lm. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
WHERE PR_CODE NOT IN (SELECT PRODUCT_CODE FROM seg.exclusion_item)
and substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id;

insert into seg.CFR_ALL_E
select 'CFR' as BU, &lm. as ym, sbl_member_id, count(distinct ref_key) as tx, sum(total) as total, sum(gp) as gp, sum(net_total) as net_total
from topsrst.saletrans_online_daily a
join topssbl.sbl_member_card_list b on a.t1c_card_no = b.t1c_card_no
WHERE PR_CODE NOT IN (SELECT PRODUCT_CODE FROM seg.exclusion_item)
and substr(put(ttm2,8.),1,6)="&LM."
group by sbl_member_id;
;quit; 

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

PROC SQL threads;
CREATE TABLE seg.CRM_SINGLE_VIEW_&SEGNAME. (COMPRESS = YES) AS
SELECT 
CASE WHEN SBL_MEMBER_ID IN (SELECT sbl_member_id FROM CRM.CRM_SINGLE_VIEW_20Q2 WHERE CFR_COMPANY_RANK = 'Wholesale') THEN 'Wholesale' ELSE
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
CASE WHEN SBL_MEMBER_ID IN (SELECT sbl_member_id FROM CRM.ws_20q2) THEN 'Wholesale' ELSE CFR_RANK END AS CFR_COMPANY_RANK
FROM seg.CRM_SINGLE_VIEW_&SEGNAME.;
QUIT; 

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

