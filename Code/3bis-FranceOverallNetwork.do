
*FRANCE OVERALL for gephi
set more off
nwclear
clear matrix
mata mata clear
set maxvar 6200
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta",clear
capt drop timeperiod
gen timeperiod=1
replace timeperiod=2 if year>1999
replace timeperiod=3 if year>2008
save,replace
keep if country_obs=="FRANCE"

tab psn_sector

bysort psn_name : egen nban_psn=nvals(year)
bysort psn_name : egen nbapp_psn=nvals(appln_id)

distinct appln_id
distinct psn_name
bysort timeperiod : distinct psn_name
tab nban_psn
tab nbapp_psn
distinct appln_id
distinct psn_name
distinct appln_id if nb_applicants>1 & nb_applicants<.

distinct appln_id
distinct appln_id if nb_applicants>1 & nb_applicants<.
distinct psn_name if nb_applicants>1 & nb_applicants<.

 distinct psn_name
 tab psn_sector
bysort timeperiod : distinct psn_name

drop if psn_name==""
encode psn_name,gen(psn_name_code)

bysort  psn_sector : distinct appln_id
bysort  psn_sector : distinct psn_name
tab psn_sector 


distinct psn_name
distinct psn_name if psn_sector=="UNIVERSITY"

distinct appln_id
local nbappln=r(ndistinct)
 nw_projection, x(psn_name_code) y(appln_id)
 gen initial_rank_network=_n
 nwrename network test
 decode psn_name_code,gen(psn_name)
 
 nwdegree
 nwdrop if _degree==0
 drop if _degree==0
  nwsummarize
 local nnodes=r(nodes)

nwdegree
gen nnodes= r(N)
nwdegree,valued

nwANND, 
nwANND,valued 

nwcomponents,lgc
nwdrop if _lgc!=1

nwevcent
run "C:\ado\plus\n\nwwevcent.do"
nwwevcent
putmata _wevcent,replace
putmata _evcent,replace

drop if _lgc!=1
getmata _evcent,replace force
getmata _wevcent,replace force

drop if psn_name_code==.

gen cent=_wevcent
egen cent_total=total(cent)
gen cent_scale=cent/cent_total*100
su cent_scale



nwsummarize


keep _* psn_name_code  psn_name _degree nnodes _strength cent cent_total cent_scale  initial_rank_network
nwbetween
drop if psn_name==""

merge m:m psn_name using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta"
keep if _m==3
keep if country_obs=="FRANCE"



bysort psn_name : egen nbapp_psn=nvals(appln_id)
gen grant=(granted=="Y")
bysort psn_name : egen nbapp_granted_psn=nvals(appln_id) if grant==1
bysort psn_name (grant) : replace nbapp_granted_psn=nbapp_granted_psn[_N]
gen sh_granted_psn=nbapp_granted_psn/nbapp_psn
bysort psn_name : egen div_techn=nvals(techn_sector) 

bysort  psn_name : egen pat_econvalue=mean(docdb_family_size)
bysort  psn_name : egen pat_quality=mean(nb_citing_docdb_fam)
bysort  psn_name : egen pat_volume=mean(nbapp_psn)
bysort  psn_name : egen pat_innov=mean(sh_granted_psn)
bysort psn_name : egen pat_divtechn=nvals(techn_field) 


egen nbapp_tot=nvals(appln_id)
bysort  psn_name : gen sh_nbapp=nbapp_psn/nbapp_tot



bysort psn_name : keep if _n==1

su cent_scale
su cent_scale if psn_sector=="UNIVERSITY"

histogram cent_scale

  keep _* _betw initial_rank_network timeperiod year pat_econvalue sh_nbapp pat_quality pat_volume pat_innov pat_divtechn nbapp_psn nbapp_psn nbapp_granted_psn sh_granted_psn NUTS nuts_label  psn_name_code psn_sector psn_name _degree nnodes _strength cent cent_total cent_scale div_techn country source docdb_family_size nb_citing_docdb_fam
 count
 capt drop _1* _2* _3* _4* _5* _6* _7* _8* _9*

 nwsummarize


 gsort - cent_scale
 gen rank_cent=_n
 bro if psn_sector=="UNIVERSITY"
 egen nbtotappUniv = total(nbapp_psn) if psn_sector=="UNIVERSITY"
 egen sh_nbapp_Univ = total(sh_nbapp) if psn_sector=="UNIVERSITY"

 drop if _degree==0

 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_timeperiod`y'_detail_FRANCE.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_timeperiod`y'_detail_FRANCE.dta",clear
 nwdrop if _degree==0
 sort initial_rank_network
 nwtoedge,  fromvar(psn_name) tovar(psn_name)

order from to test
keep from to test
rename from Source
rename to Target
rename test Weight
nwrename test net`y'_FRANCE
drop if Weight==0
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\edgelist_psn_name_`y'_FRANCE.csv", replace


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_timeperiod`y'_detail_FRANCE.dta",clear
rename psn_name Id
gen centralityGephi=ln(_wevcent*100)
su centrality
local min=r(min)
replace centralityGephi=centralityGephi-`min'
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\nodelist_psn_name_`y'_FRANCE.csv",   replace

 
