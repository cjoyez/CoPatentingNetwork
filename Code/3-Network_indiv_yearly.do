*********FRANCE
*By year
nwclear
clear matrix
set more off
mata mata clear
set maxvar 12000
set matsize 1100
mata matcentU=J(40,1,.)
mata matcentC=J(40,1,.)
mata matcentPRO=J(40,1,.)
mata matnodes=J(40,1,.)
mata matappln=J(40,1,.)
mata matrankU1=J(40,1,.)
mata matrankUavg=J(40,1,.)
mata matrankUmed=J(40,1,.)
mata matnbU=J(40,1,.)
mata matnbPRO=J(40,1,.)
mata matsdcentU=J(40,1,.)
mata matpqualU=J(40,1,.)
mata matpquantU=J(40,1,.)
mata matpdivU=J(40,1,.)
mata matpinnovU=J(40,1,.)
mata matpvalueU=J(40,1,.)
mata matshappU=J(40,1,.)
mata mattotappU=J(40,1,.)

mata nbnodes=J(40,1,.)
mata avgDegree=J(40,1,.)
mata avgDegreeU=J(40,1,.)
mata avgStrength=J(40,1,.)
mata avgStrengthU=J(40,1,.)
mata avgCent=J(40,1,.)
mata avgCentU=J(40,1,.)
mata avgCentPRO=J(40,1,.)
mata avgwBetw=J(40,1,.)
mata avgwBetwU=J(40,1,.)
mata avgwBetwPRO=J(40,1,.)
mata year=J(40,1,.)
mata avgCentinc=J(40,1,.)
mata avgCentUinc=J(40,1,.)
mata agCent=J(40,1,.)
mata agCentU=J(40,1,.)
mata agCentPRO=J(40,1,.)


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta",clear

*drop dupplicates (same patent but registered in two techn_field)
 capt drop aay
 egen aay=group(appln_id psn_name year)
 bysort aay : keep if _n==1
 
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

forvalues y=1979(1)2018{
*local y=2005
local n=`y'-1978
preserve
keep if year==`y' | year==`y'-1

distinct psn_name
distinct psn_name if psn_sector=="UNIVERSITY"

distinct appln_id
local nbappln=r(ndistinct)
mata matappln[`n',]=`nbappln'
 nw_projection, x(psn_name_code) y(appln_id)
 nwrename network test
capt drop initial_ranking_network
 gen initial_ranking_network=_n 
 
 decode psn_name_code,gen(psn_name)
 
 nwdegree
 nwdrop if _degree==0
 drop if _degree==0
  nwsummarize
 local nnodes=r(nodes)
 mata matnodes[`n',]=`nnodes'

nwdegree
gen nnodes= r(N)
nwdegree,valued
nwANND, 
nwANND,valued 

nwcomponents,lgc
*drop if _lgc!=1
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
egen cent_max=max(cent)
gen cent_scale=cent/cent_max
*gen cent_scale=cent/cent_total*100
su cent_scale
nwsummarize



  keep  psn_name_code _* psn_name _degree nnodes _strength cent cent_total cent_scale ini* 
  nwbetween
  gen between_sort=_n
drop if psn_name==""

merge m:m psn_name using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta"
keep if _m==3
keep if country_obs=="FRANCE"
keep if year==`y' | year==`y'-1




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

capture xtile qcite=nb_citing_docdb_fam,nq(5)
gen highqualitypatent=.
capture replace highqualitypatent=1 if qcite==5
capture replace highqualitypatent=0 if qcite<5 
replace highqualitypatent=0 if highqualitypatent==.

bysort  psn_name : egen nbpathq=total(highqualitypatent)
gen shpathq=nbpathq/nbapp_psn


egen nbapp_tot=nvals(appln_id)
bysort  psn_name : gen sh_nbapp=nbapp_psn/nbapp_tot



bysort psn_name : keep if _n==1

su cent_scale
su cent_scale if psn_sector=="UNIVERSITY"


  keep _* between_sort _bet  shpathq nbpathq  ini*  timeperiod year pat_econvalue sh_nbapp pat_quality pat_volume pat_innov pat_divtechn nbapp_psn nbapp_psn nbapp_granted_psn sh_granted_psn NUTS nuts_label  psn_name_code psn_sector psn_name _degree nnodes _strength cent cent_total cent_scale div_techn country source docdb_family_size nb_citing_docdb_fam
 count
 nwsummarize
 forvalues v=1/9{
 	capture drop _`v'*
 }



 gsort - cent_scale
 gen rank_cent=_n
 sort initial
 *bro if psn_sector=="UNIVERSITY"
 egen nbtotappUniv = total(nbapp_psn) if psn_sector=="UNIVERSITY"
 egen sh_nbapp_Univ = total(sh_nbapp) if psn_sector=="UNIVERSITY"

 count

sort initial
capt drop _merge
 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_FRANCE.dta",replace
 nwtoedge,  fromvar(psn_name) tovar(psn_name)
 drop if test==0 /*netsis doesn't allow empty edges*/
 replace test=1/test /*weights express distance, not proximity or frequency of path */
capture mata mata drop betw
capture mata mata drop betw_w
netsis _from _to, measure(betweenness) name(betw) label(psn_name)
netsis _from _to, measure(betweenness) name(betw_w) weight(test)
mata betw
mata betw_w
clear
 getmata betw,replace
getmata betw_w,replace
rename betw _between

 merge m:m  _between using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_FRANCE.dta"
 sort initial

 corr _between  betw_w
 su _between  betw_w

 sort initial
 
 *store final network description
 count
  local nbnodes=r(N)
 mata nbnodes[`n',]=`nbnodes'
 
 su _degree,de
 local md=r(mean)
mata avgDegree[`n',]=`md'

 su _degree if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgDegreeU[`n',]=`md'

 su _strength,de
 local md=r(mean)
mata avgStrength[`n',]=`md'

 su _strength if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgStrengthU[`n',]=`md'



gen lcent_scale=ln(cent_scale)
 su cent_scale ,de
 local md=r(mean)
mata avgCent[`n',]=`md'

 su cent_scale if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgCentU[`n',]=`md'

 su cent_scale if psn_sector=="GOV NON-PROFIT",de
 local md=r(mean)
mata avgCentPRO[`n',]=`md'

gen lbetw_w=ln(betw_w)
 su lbetw_w 
 local md=r(mean)
mata avgwBetw[`n',]=`md'

 su lbetw_w if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgwBetwU[`n',]=`md'

 su lbetw_w if psn_sector=="GOV NON-PROFIT",de
 local md=r(mean)
mata avgwBetwPRO[`n',]=`md'




 egen TOTcent_scale=total(cent_scale)
 su TOTcent_scale
 local md=r(mean)
mata agCent[`n',]=`md'

 egen TOTcent_scaleU=total(cent_scale) if psn_sector=="UNIVERSITY"
 su TOTcent_scaleU
 local md=r(mean)
mata agCentU[`n',]=`md'

 egen TOTcent_scalePRO=total(cent_scale) if psn_sector=="GOV NON-PROFIT"
 su TOTcent_scalePRO
 local md=r(mean)
mata agCentPRO[`n',]=`md'


mata year[`n',]=`y'

 drop if _degree==0
 replace year=`y'
 sort initial

save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_FRANCE.dta",replace
sort initial
 nwtoedge,  fromvar(psn_name) tovar(psn_name)
order from to test
keep from to test
rename from Source
rename to Target
rename test Weight
nwrename test net`y'_FRANCE

export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\edgelist_psn_name_`y'_FRANCE.csv", replace


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_FRANCE.dta",clear
rename psn_name Id
gen centralityGephi=ln(_wevcent*100)
su centrality
local min=r(min)
replace centralityGephi=centralityGephi-`min'
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\nodelist_psn_name_`y'_FRANCE.csv",   replace

 
 su rank if  psn_sector=="UNIVERSITY"
 local rank1=r(min)
 mata matrankU1[`n',]=`rank1'
local rankavg=r(mean)
 mata matrankUavg[`n',]=`rankavg'
 
  su rank if  psn_sector=="UNIVERSITY",de
 local rankmed=r(p50)
 mata matrankUmed[`n',]=`rankmed'
 
 count if  psn_sector=="UNIVERSITY"
 local nbU=r(N)
 mata matnbU[`n',]=`nbU'

 
su cent_scale  if  psn_sector=="UNIVERSITY"
local cent=r(mean)
mata matcentU[`n',]=`cent'
su cent_scale  if  psn_sector=="UNIVERSITY"
local sd=r(sd)
mata matsdcentU[`n',]=`sd'
su cent_scale if  psn_sector=="COMPANY"
local cent=r(mean)
mata matcentC[`n',]=`cent'

su cent_scale if psn_sector=="GOV NON-PROFIT" | psn_sector=="foreign_UNIV" 
local cent=r(mean)
mata matcentPRO[`n',]=`cent'


su pat_econvalue if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpvalueU[`n',]=`f'
su pat_quality if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpqualU[`n',]=`f'
su pat_volume if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpquantU[`n',]=`f'
su pat_innov if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpinnovU[`n',]=`f'
su pat_divtechn if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpdivU[`n',]=`f'

su sh_nbapp_Univ
local f=r(mean)
mata matshappU[`n',]=`f'

su nbtotappUniv
local f=r(mean)
mata mattotappU[`n',]=`f'

capture nwdrop _all

restore
}
clear
set obs 40
*gen year=_n+1978
gen year=.
mata st_store(.,"year",year)
gen timeperiod=1 if year<=1999
replace timeperiod=2 if year>1999 & year<=2007
replace timeperiod=3 if year>2007
gen nnodes=.
mata st_store(.,"nnodes",matnodes)
gen avgDegree=.
mata st_store(.,"avgDegree",avgDegree)
gen avgDegreeU=.
mata st_store(.,"avgDegreeU",avgDegreeU)

gen avgStrength=.
mata st_store(.,"avgStrength",avgStrength)
gen avgStrengthU=.
mata st_store(.,"avgStrengthU",avgStrengthU)

gen avgCent=.
mata st_store(.,"avgCent",avgCent)
gen avgCentU=.
mata st_store(.,"avgCentU",avgCentU)
gen avgCentPRO=.
mata st_store(.,"avgCentPRO",avgCentPRO)

gen avgwBetw=.
mata st_store(.,"avgwBetw",avgwBetw)
gen avgwBetwU=.
mata st_store(.,"avgwBetwU",avgwBetwU)
gen avgwBetwPRO=.
mata st_store(.,"avgwBetwPRO",avgwBetwPRO)

gen avgCentinc=.
mata st_store(.,"avgCentinc",avgCentinc)
gen avgCentUinc=.
mata st_store(.,"avgCentUinc",avgCentUinc)

gen agCent=.
mata st_store(.,"agCent",agCent)
gen agCentU=.
mata st_store(.,"agCentU",agCentU)
gen agCentPRO=.
mata st_store(.,"agCentPRO",agCentPRO)


twoway (connect avgCentU year) (connect avgCent year)

twoway (connect avgCentU year) (connect avgCent year)
twoway (connect avgCentU year) (connect avgCentPRO year)

twoway (connect avgCentUinc year) (connect avgCentinc year)
twoway (connect agCentU year) (connect agCent year)
twoway (connect agCentU year) (connect agCentPRO year)

/*
gen nappln_id=.
mata st_store(.,"nappln_id",matappln)
gen centralityU=.
mata st_store(.,"centralityU",matcentU)
gen centralityComp=.
mata st_store(.,"centralityComp",matcentC)
gen centralityPRO=.
mata st_store(.,"centralityPRO",matcentPRO)
gen rankU1=.
mata st_store(.,"rankU1",matrankU1)
gen rankUavg=.
mata st_store(.,"rankUavg",matrankUavg)
gen rankUmed=.
mata st_store(.,"rankUmed",matrankUmed)
gen nbUniv=.
mata st_store(.,"nbUniv",matnbU)
gen nbPRO=.
mata st_store(.,"nbPRO",matnbPRO)
gen sdcentU=.
mata st_store(.,"sdcentU",matsdcentU)
gen pat_econvalueU=.
mata st_store(.,"pat_econvalueU",matpvalueU)
gen pat_qualityU=.
mata st_store(.,"pat_qualityU",matpqualU)
gen pat_quantityU=.
mata st_store(.,"pat_quantityU",matpquantU)
gen pat_innovU=.
mata st_store(.,"pat_innovU",matpinnovU)
gen pat_diversityU=.
mata st_store(.,"pat_diversityU",matpdivU)
gen sh_app_U=.
mata st_store(.,"sh_app_U",matshappU)
gen tot_app_U=.
mata st_store(.,"tot_app_U",mattotappU)
*/
gen country_obs="FRANCE"


save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_FRANCE.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_FRANCE.dta"

nwclear
 forvalues y=1979(1)2018{
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_FRANCE.dta"
}
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",replace

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
count

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_FRANCE.dta",clear
count


***************************************

*******GERMANY 
*By time period
nwclear
set more off
mata matcentU=J(40,1,.)
mata matcentC=J(40,1,.)
mata matcentPRO=J(40,1,.)

mata matnodes=J(40,1,.)
mata matappln=J(40,1,.)
mata matrankU1=J(40,1,.)
mata matrankUavg=J(40,1,.)
mata matrankUmed=J(40,1,.)
mata matnbU=J(40,1,.)
mata matnbPRO=J(40,1,.)
mata matsdcentU=J(40,1,.)
mata matpqualU=J(40,1,.)
mata matpquantU=J(40,1,.)
mata matpdivU=J(40,1,.)
mata matpinnovU=J(40,1,.)
mata matpvalueU=J(40,1,.)
mata matshappU=J(40,1,.)
mata mattotappU=J(40,1,.)

mata nbnodes=J(40,1,.)
mata avgDegree=J(40,1,.)
mata avgDegreeU=J(40,1,.)
mata avgStrength=J(40,1,.)
mata avgStrengthU=J(40,1,.)
mata avgCent=J(40,1,.)
mata avgCentU=J(40,1,.)
mata avgCentPRO=J(40,1,.)
mata avgwBetw=J(40,1,.)
mata avgwBetwU=J(40,1,.)
mata avgwBetwPRO=J(40,1,.)
mata year=J(40,1,.)
mata avgCentinc=J(40,1,.)
mata avgCentUinc=J(40,1,.)
mata agCent=J(40,1,.)
mata agCentU=J(40,1,.)
mata agCentPRO=J(40,1,.)



use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta",clear
*drop dupplicates 
 capt drop aay
 egen aay=group(appln_id psn_name year)
 bysort aay : keep if _n==1
 
capt drop timeperiod
gen timeperiod=1
replace timeperiod=2 if year>1999
replace timeperiod=3 if year>2008
save,replace
keep if country_obs=="GERMANY"


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

forvalues y=1979(1)2018{
*local y=2013
local n=`y'-1978
preserve
keep if year==`y' | year==`y'-1

distinct psn_name
distinct psn_name if psn_sector=="UNIVERSITY"

distinct appln_id
local nbappln=r(ndistinct)
mata matappln[`n',]=`nbappln'
 nw_projection, x(psn_name_code) y(appln_id)
 nwrename network test
 capt drop initial_ranking_network
  gen initial_ranking_network=_n

 
 decode psn_name_code,gen(psn_name)
 
 nwdegree
 nwdrop if _degree==0
 drop if _degree==0
  nwsummarize
 local nnodes=r(nodes)
 mata matnodes[`n',]=`nnodes'

nwdegree
gen nnodes= r(N)
nwdegree,valued
nwANND, 
nwANND,valued 

nwcomponents,lgc
*drop if _lgc!=1
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


  keep  psn_name_code _* psn_name _degree nnodes _strength cent cent_total cent_scale  initial_ranking_network
  nwbetween
drop if psn_name==""

merge m:m psn_name using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta"
keep if _m==3
keep if country_obs=="GERMANY"
keep if year==`y' | year==`y'-1



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



capture xtile qcite=nb_citing_docdb_fam,nq(5)
gen highqualitypatent=.
capture replace highqualitypatent=1 if qcite==5
capture replace highqualitypatent=0 if qcite<5 
replace highqualitypatent=0 if highqualitypatent==.


bysort  psn_name : egen nbpathq=total(highqualitypatent)
gen shpathq=nbpathq/nbapp_psn


egen nbapp_tot=nvals(appln_id)
bysort  psn_name : gen sh_nbapp=nbapp_psn/nbapp_tot



bysort psn_name : keep if _n==1

su cent_scale
su cent_scale if psn_sector=="UNIVERSITY"


  keep _* _bet  shpathq nbpathq  initial_ranking_network timeperiod year pat_econvalue sh_nbapp pat_quality pat_volume pat_innov pat_divtechn nbapp_psn nbapp_psn nbapp_granted_psn sh_granted_psn NUTS nuts_label  psn_name_code psn_sector psn_name _degree nnodes _strength cent cent_total cent_scale div_techn country source docdb_family_size nb_citing_docdb_fam
 count
 nwsummarize
 forvalues v=1/9{
 noi di "_`v'"
 	capture drop _`v'*
 }



 gsort - cent_scale
 gen rank_cent=_n
 *bro if psn_sector=="UNIVERSITY"
 egen nbtotappUniv = total(nbapp_psn) if psn_sector=="UNIVERSITY"
 egen sh_nbapp_Univ = total(sh_nbapp) if psn_sector=="UNIVERSITY"


capt drop _merge
sort initial_ranking

 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_GERMANY.dta",replace
nwdrop if _degree==0
sort initial_ranking
 nwtoedge,  fromvar(psn_name) tovar(psn_name)
 drop if test==0 /*netsis doesn't allow empty edges*/
 replace test=1/test /*weights express distance, not proximity or frequency of path */
capture mata mata drop betw
capture mata mata drop betw_w
netsis _from _to, measure(betweenness) name(betw) label(psn_name)
netsis _from _to, measure(betweenness) name(betw_w) weight(test)
mata betw
mata betw_w
clear
 getmata betw,replace
getmata betw_w,replace
rename betw _between

nwsummarize
count
 merge m:m  _between using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_GERMANY.dta"
 sort initial
 count 
 distinct psn_name

 corr _between  betw_w
 su _between  betw_w

 sort initial
 
 *store final network description
 count
  local nbnodes=r(N)
 mata nbnodes[`n',]=`nbnodes'
 
 su _degree,de
 local md=r(mean)
mata avgDegree[`n',]=`md'

 su _degree if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgDegreeU[`n',]=`md'

 su _strength,de
 local md=r(mean)
mata avgStrength[`n',]=`md'

 su _strength if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgStrengthU[`n',]=`md'



gen lcent_scale=ln(cent_scale)
 su cent_scale ,de
 local md=r(mean)
mata avgCent[`n',]=`md'

 su cent_scale if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgCentU[`n',]=`md'

 su cent_scale if psn_sector=="GOV NON-PROFIT",de
 local md=r(mean)
mata avgCentPRO[`n',]=`md'

gen lbetw_w=ln(betw_w)
 su lbetw_w 
 local md=r(mean)
mata avgwBetw[`n',]=`md'

 su lbetw_w if psn_sector=="UNIVERSITY",de
 local md=r(mean)
mata avgwBetwU[`n',]=`md'

 su lbetw_w if psn_sector=="GOV NON-PROFIT",de
 local md=r(mean)
mata avgwBetwPRO[`n',]=`md'



 egen TOTcent_scale=total(cent_scale)
 su TOTcent_scale
 local md=r(mean)
mata agCent[`n',]=`md'

 egen TOTcent_scaleU=total(cent_scale) if psn_sector=="UNIVERSITY"
 su TOTcent_scaleU
 local md=r(mean)
mata agCentU[`n',]=`md'

 egen TOTcent_scalePRO=total(cent_scale) if psn_sector=="GOV NON-PROFIT"
 su TOTcent_scalePRO
 local md=r(mean)
mata agCentPRO[`n',]=`md'

mata year[`n',]=`y'

 drop if _degree==0
 replace year=`y'
 sort initial

save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_GERMANY.dta",replace
sort initial
 nwtoedge,  fromvar(psn_name) tovar(psn_name)
order from to test
keep from to test
rename from Source
rename to Target
rename test Weight
nwrename test net`y'_FRANCE

export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\edgelist_psn_name_`y'_GERMANY.csv", replace

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_GERMANY.dta",clear
rename psn_name Id
gen centralityGephi=ln(_wevcent*100)
su centrality
local min=r(min)
replace centralityGephi=centralityGephi-`min'
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\nodelist_psn_name_`y'_GERMANY.csv",   replace

 
 
 su rank if  psn_sector=="UNIVERSITY"
 local rank1=r(min)
 mata matrankU1[`n',]=`rank1'
local rankavg=r(mean)
 mata matrankUavg[`n',]=`rankavg'
 
  su rank if  psn_sector=="UNIVERSITY",de
 local rankmed=r(p50)
 mata matrankUmed[`n',]=`rankmed'
 
 count if  psn_sector=="UNIVERSITY"
 local nbU=r(N)
 mata matnbU[`n',]=`nbU'

 
su cent_scale  if  psn_sector=="UNIVERSITY"
local cent=r(mean)
mata matcentU[`n',]=`cent'
su cent_scale  if  psn_sector=="UNIVERSITY"
local sd=r(sd)
mata matsdcentU[`n',]=`sd'
su cent_scale if  psn_sector=="COMPANY"
local cent=r(mean)
mata matcentC[`n',]=`cent'

su cent_scale if psn_sector=="GOV NON-PROFIT" | psn_sector=="foreign_UNIV" 
local cent=r(mean)
mata matcentPRO[`n',]=`cent'


su pat_econvalue if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpvalueU[`n',]=`f'
su pat_quality if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpqualU[`n',]=`f'
su pat_volume if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpquantU[`n',]=`f'
su pat_innov if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpinnovU[`n',]=`f'
su pat_divtechn if  psn_sector=="UNIVERSITY"
local f=r(mean)
mata matpdivU[`n',]=`f'

su sh_nbapp_Univ
local f=r(mean)
mata matshappU[`n',]=`f'

su nbtotappUniv
local f=r(mean)
mata mattotappU[`n',]=`f'

capture nwdrop _all

restore
}
clear
set obs 40
*gen year=_n+1978
gen year=.
mata st_store(.,"year",year)
gen timeperiod=1 if year<=1999
replace timeperiod=2 if year>1999 & year<=2007
replace timeperiod=3 if year>2007
gen nnodes=.
mata st_store(.,"nnodes",matnodes)
gen avgDegree=.
mata st_store(.,"avgDegree",avgDegree)
gen avgDegreeU=.
mata st_store(.,"avgDegreeU",avgDegreeU)

gen avgStrength=.
mata st_store(.,"avgStrength",avgStrength)
gen avgStrengthU=.
mata st_store(.,"avgStrengthU",avgStrengthU)

gen avgCent=.
mata st_store(.,"avgCent",avgCent)
gen avgCentU=.
mata st_store(.,"avgCentU",avgCentU)
gen avgCentPRO=.
mata st_store(.,"avgCentPRO",avgCentPRO)

gen avgwBetw=.
mata st_store(.,"avgwBetw",avgwBetw)
gen avgwBetwU=.
mata st_store(.,"avgwBetwU",avgwBetwU)
gen avgwBetwPRO=.
mata st_store(.,"avgwBetwPRO",avgwBetwPRO)

gen avgCentinc=.
mata st_store(.,"avgCentinc",avgCentinc)
gen avgCentUinc=.
mata st_store(.,"avgCentUinc",avgCentUinc)

gen agCent=.
mata st_store(.,"agCent",agCent)
gen agCentU=.
mata st_store(.,"agCentU",agCentU)
gen agCentPRO=.
mata st_store(.,"agCentPRO",agCentPRO)


twoway (connect avgCentU year) (connect avgCent year)

twoway (connect avgCentU year) (connect avgCent year)
twoway (connect avgCentU year) (connect avgCentPRO year)

twoway (connect avgCentUinc year) (connect avgCentinc year)
twoway (connect agCentU year) (connect agCent year)
twoway (connect agCentU year) (connect agCentPRO year)

/*
gen nappln_id=.
mata st_store(.,"nappln_id",matappln)
gen centralityU=.
mata st_store(.,"centralityU",matcentU)
gen centralityComp=.
mata st_store(.,"centralityComp",matcentC)
gen centralityPRO=.
mata st_store(.,"centralityPRO",matcentPRO)
gen rankU1=.
mata st_store(.,"rankU1",matrankU1)
gen rankUavg=.
mata st_store(.,"rankUavg",matrankUavg)
gen rankUmed=.
mata st_store(.,"rankUmed",matrankUmed)
gen nbUniv=.
mata st_store(.,"nbUniv",matnbU)
gen nbPRO=.
mata st_store(.,"nbPRO",matnbPRO)
gen sdcentU=.
mata st_store(.,"sdcentU",matsdcentU)
gen pat_econvalueU=.
mata st_store(.,"pat_econvalueU",matpvalueU)
gen pat_qualityU=.
mata st_store(.,"pat_qualityU",matpqualU)
gen pat_quantityU=.
mata st_store(.,"pat_quantityU",matpquantU)
gen pat_innovU=.
mata st_store(.,"pat_innovU",matpinnovU)
gen pat_diversityU=.
mata st_store(.,"pat_diversityU",matpdivU)
gen sh_app_U=.
mata st_store(.,"sh_app_U",matshappU)
gen tot_app_U=.
mata st_store(.,"tot_app_U",mattotappU)
*/

gen country_obs="GERMANY"


save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_GERMANY.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_GERMANY.dta"

nwclear
 forvalues y=1979(1)2018{
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_detail_GERMANY.dta"
}
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_GERMANY_yearly.dta",replace

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_GERMANY_yearly.dta",clear
count

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_GERMANY.dta",clear
count


