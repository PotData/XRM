
create table MKTCRM.dbo.NL_All_Prem_TY_f  as
select A.*,

case when total_ty <1500 then 'T1_<1500' 
when total_ty >=1500 then 'T2_>=1500'
end as Tx_range,

case when A.sbl_member_id is not null 
and sbl_member_id not in ('9-014342304','9-014223414','9-014511211','9-014493473','9-014234126','9-014651449','9999999999')
Then '01_Member' else '02_Non_member' end as Flag_member

from MKTCRM.dbo.[SC.NL_All_Prem_TY] as A

TRUNCATE Table

EXEC SC_NL_All_Prem_TY_f ;