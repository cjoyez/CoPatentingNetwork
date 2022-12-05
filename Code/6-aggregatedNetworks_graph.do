*Network of aggregated psn_sector and not psn_name

*********FRANCE
*By year
nwclear
set more off
mata mata clear
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
mata matnbactor=J(40,1,.)


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
keep if country_obs=="FRANCE"


tab psn_sector

bysort psn_name : egen nban_psn=nvals(year)
bysort psn_name : egen nbapp_psn=nvals(appln_id)

distinct appln_id
distinct psn_name
tab psn_sector
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
encode psn_sector,gen(psn_sector_code)

 forvalues y=1979(1)2018{
*local y=1983
local n=`y'-1978
preserve
keep if year==`y' | year==`y'-1
distinct year 

distinct psn_name
local nbactor=r(ndistinct)
mata matnbactor[`n',]=`nbactor'
distinct psn_name if psn_sector=="UNIVERSITY"

distinct appln_id
local nbappln=r(ndistinct)
mata matappln[`n',]=`nbappln'
 nw_fromlist test,node( psn_sector_code ) id( appln_id )
 decode psn_sector_code,gen(psn_sector) 
 nwdegree
 nwdrop if _degree==0
 drop if _degree==0
  nwsummarize
 local nnodes=r(nodes)
 mata matnodes[`n',]=`nnodes'

nwdegree
gen nnodes= r(N)
nwdegree,valued
gen cent =(_degree/nnodes)^0.5*_strength^0.5
egen cent_total=total(cent)
gen cent_scale=cent/cent_total*100

nwcomponents,lgc
nwdrop if _lgc!=1
drop if _lgc!=1
nwevcent
run "C:\ado\plus\n\nwwevcent.do"
nwwevcent

capt drop cent*
gen cent=_wevcent
egen cent_total=total(cent)
gen cent_scale=cent/cent_total*100
su cent_scale
nwsummarize
nwbetween


  keep  psn_sector   _degree nnodes _strength cent cent_total cent_scale _b
drop if psn_sector==""

merge m:m psn_sector using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta"
keep if _m==3
keep if country_obs=="FRANCE"
keep if year==`y'

bysort psn_sector : egen nbapp_psn_sector=nvals(appln_id)
gen grant=(granted=="Y")
bysort psn_name : egen nbapp_granted_psn_sector=nvals(appln_id) if grant==1
bysort psn_name (grant) : replace nbapp_granted_psn_sector=nbapp_granted_psn_sector[_N]
gen sh_granted_psn_sector=nbapp_granted_psn_sector/nbapp_psn_sector
bysort psn_sector : egen div_techn=nvals(techn_sector) 

bysort  psn_sector : egen pat_econvalue=mean(docdb_family_size)
bysort  psn_sector : egen pat_quality=mean(nb_citing_docdb_fam)
bysort  psn_sector : egen pat_volume=mean(nbapp_psn)
bysort  psn_sector : egen pat_innov=mean(sh_granted_psn)
bysort psn_sector : egen pat_divtechn=nvals(techn_field) 


egen nbapp_tot=nvals(appln_id)
bysort  psn_sector : gen sh_nbapp=nbapp_psn_sector/nbapp_tot



bysort psn_name : keep if _n==1
  keep year timeperiod pat_econvalue sh_nbapp pat_quality pat_volume pat_innov pat_divtechn nbapp_psn nbapp_psn nbapp_granted_psn sh_granted_psn NUTS nuts_label   psn_sector  _degree nnodes _strength cent cent_total cent_scale div_techn country source docdb_family_size nb_citing_docdb_fam
 count
 nwsummarize


 gsort - cent_scale
 gen rank_cent=_n
 bro if psn_sector=="UNIVERSITY"
 egen nbtotappUniv = total(nbapp_psn) if psn_sector=="UNIVERSITY"
 egen sh_nbapp_Univ = total(sh_nbapp) if psn_sector=="UNIVERSITY"

 drop if _degree==0

 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_FRANCE.dta",replace
nwdrop if _degree==0
 nwtoedge,  fromvar(psn_sector) tovar(psn_sector)

order from to test
keep from to test
rename from Source
rename to Target
rename test Weight
nwrename test net`y'_FRANCE

export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\edgelist_Sector_`y'_FRANCE.csv", replace


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_FRANCE.dta",clear
gen Id= psn_sector
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\nodelist_Sector_`y'_FRANCE.csv",   replace

 
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
 
  count if  psn_sector=="GOV NON-PROFIT"
 local nbPRO=r(N)
 mata matnbPRO[`n',]=`nbPRO'

 
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


restore
}


clear
set obs 40
gen year=1978+_n

gen nnodes=.
mata st_store(.,"nnodes",matnodes)
gen nbactor=.
mata st_store(.,"nbactor",matnbactor)
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

gen country_obs="FRANCE"

save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta"

nwclear
 forvalues y=1979(1)2018{
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_FRANCE.dta"
}
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_detail_FRANCE_yearly.dta",replace

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_detail_FRANCE_yearly.dta",clear
count

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta",clear
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
mata matnbactor=J(40,1,.)

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


drop if psn_sector=="UNKNOWN"
replace psn_sector="UNIVERSITY" if psn_sector=="GOV NON-PROFIT UNIVERSITY" &  person_ctry_code=="DE" 
replace psn_sector="nonGE_UNIV" if psn_sector=="UNIVERSITY" &  person_ctry_code!="DE" 
tab psn_sector
count
keep if psn_sector=="COMPANY" | psn_sector=="GOV NON-PROFIT" |  psn_sector=="HOSPITAL"   |  psn_sector=="INDIVIDUAL"  |  psn_sector=="UNIVERSITY" |   psn_sector=="nonGE_UNIV" 
count
bysort psn_name : egen nban_psn=nvals(year)
bysort psn_name : egen nbapp_psn=nvals(appln_id)

distinct psn_name
bysort timeperiod : distinct psn_name
tab nban_psn
tab nbapp_psn

 distinct psn_name
 tab psn_sector
bysort timeperiod : distinct psn_name

drop if psn_name==""
encode psn_name,gen(psn_name_code)
encode psn_sector,gen(psn_sector_code)
 forvalues y=1979(1)2018{
local n=`y'-1978
preserve
keep if year==`y' | year==`y'-1
distinct year 

distinct psn_name
local nbactor=r(ndistinct)
mata matnbactor[`n',]=`nbactor'
distinct psn_name if psn_sector=="UNIVERSITY"

distinct appln_id
local nbappln=r(ndistinct)
mata matappln[`n',]=`nbappln'
 nw_fromlist test,node( psn_sector_code ) id( appln_id )
 decode psn_sector_code,gen(psn_sector)
 *nwplot, label(psn_name)
 
 nwdegree
 nwdrop if _degree==0
 drop if _degree==0
  nwsummarize
 local nnodes=r(nodes)
 mata matnodes[`n',]=`nnodes'

nwdegree
gen nnodes= r(N)
nwdegree,valued
gen cent =(_degree/nnodes)^0.5*_strength^0.5
egen cent_total=total(cent)
gen cent_scale=cent/cent_total*100

nwcomponents,lgc
nwdrop if _lgc!=1
drop if _lgc!=1
nwevcent
run "C:\ado\plus\n\nwwevcent.do"
nwwevcent

capt drop cent*
gen cent=_wevcent
egen cent_total=total(cent)
gen cent_scale=cent/cent_total*100
su cent_scale
nwsummarize

nwbetween


  keep  psn_sector   _degree nnodes _strength cent cent_total cent_scale 
drop if psn_sector==""

merge m:m psn_sector using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta"
keep if _m==3
keep if country_obs=="GERMANY"
keep if year==`y'
bysort psn_sector : egen nbapp_psn_sector=nvals(appln_id)
gen grant=(granted=="Y")
bysort psn_name : egen nbapp_granted_psn_sector=nvals(appln_id) if grant==1
bysort psn_name (grant) : replace nbapp_granted_psn_sector=nbapp_granted_psn_sector[_N]
gen sh_granted_psn_sector=nbapp_granted_psn_sector/nbapp_psn_sector
bysort psn_sector : egen div_techn=nvals(techn_sector) 

bysort  psn_sector : egen pat_econvalue=mean(docdb_family_size)
bysort  psn_sector : egen pat_quality=mean(nb_citing_docdb_fam)
bysort  psn_sector : egen pat_volume=mean(nbapp_psn)
bysort  psn_sector : egen pat_innov=mean(sh_granted_psn)
bysort psn_sector : egen pat_divtechn=nvals(techn_field) 


egen nbapp_tot=nvals(appln_id)
bysort  psn_sector : gen sh_nbapp=nbapp_psn_sector/nbapp_tot

egen nbUniv=nvals(psn_name) if  psn_sector=="UNIVERSITY"

bysort psn_name : keep if _n==1
  keep year nbUniv timeperiod pat_econvalue sh_nbapp pat_quality pat_volume pat_innov pat_divtechn nbapp_psn nbapp_psn nbapp_granted_psn sh_granted_psn NUTS nuts_label   psn_sector  _degree nnodes _strength cent cent_total cent_scale div_techn country source docdb_family_size nb_citing_docdb_fam
 count
 nwsummarize


 gsort - cent_scale
 gen rank_cent=_n
 bro if psn_sector=="UNIVERSITY"
 egen nbtotappUniv = total(nbapp_psn) if psn_sector=="UNIVERSITY"
 egen sh_nbapp_Univ = total(sh_nbapp) if psn_sector=="UNIVERSITY"

 drop if _degree==0

 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_GERMANY.dta",replace
nwdrop if _degree==0
 nwtoedge,  fromvar(psn_sector) tovar(psn_sector)

order from to test
keep from to test
rename from Source
rename to Target
rename test Weight
nwrename test net`y'_GERMANY

export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\edgelist_Sector_`y'_GERMANY.csv", replace


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_GERMANY.dta",clear
gen Id= psn_sector
export delimited "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\nodelist_Sector_`y'_GERMANY.csv",   replace

 
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
 
 count if  psn_sector=="GOV NON-PROFIT"
 local nbPRO=r(N)
 mata matnbPRO[`n',]=`nbPRO'

 

 
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


restore
}


clear
set obs 40
gen year=1978+_n

gen nnodes=.
mata st_store(.,"nnodes",matnodes)
gen nbactor=.
mata st_store(.,"nbactor",matnbactor)
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

gen country_obs="GERMANY"

save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_GERMANY.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_GERMANY.dta",clear

nwclear
 forvalues y=1979(1)2018{
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_year`y'_Sector_GERMANY.dta"
}
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_detail_GERMANY_yearly.dta",replace

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_detail_GERMANY_yearly.dta",clear
count

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_GERMANY.dta",clear
count


mata matcentControl1=J(40,1,.)
mata matcentControl1_IT=J(40,1,.)
mata matcentControl1_DE=J(40,1,.)
mata matnbU_DE=J(40,1,.)
mata matnbU_IT=J(40,1,.)

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_detail_GERMANY_yearly.dta",clear

 forvalues y=1979(1)2018{
local n=`y'-1978
su cent_scale  if  psn_sector=="UNIVERSITY" &  year>=`y' & year<`y'+1
local m=r(mean)
mata matcentControl1[`n',]=`m'
su cent_scale  if  psn_sector=="UNIVERSITY" &  year>=`y' & year<`y'+1
local m=r(mean)
mata matcentControl1[`n',]=`m'
su cent_scale  if  psn_sector=="UNIVERSITY" &  year>=`y' & year<`y'+1
local m=r(mean)
mata matcentControl1[`n',]=`m'

su cent_scale  if  psn_sector=="UNIVERSITY" &  year>=`y' & year<`y'+1 & country_obs=="GERMANY"
local m=r(mean)
mata matcentControl1_DE[`n',]=`m'
su cent_scale  if  psn_sector=="UNIVERSITY" &  year>=`y' & year<`y'+1 & country_obs=="GERMANY"
local m=r(mean)
mata matcentControl1_DE[`n',]=`m'
su cent_scale  if  psn_sector=="UNIVERSITY" & year>=`y' & year<`y'+1 & country_obs=="GERMANY"
local m=r(mean)
mata matcentControl1_DE[`n',]=`m'
su nbU if year>=`y' & year<`y'+1 & country_obs=="GERMANY"
local nu=r(mean)
mata matnbU_DE[`n',]=`nu'
}
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta",clear
capt drop cent_control*
capt drop nbU_DE
gen cent_control=.
mata st_store(.,"cent_control",matcentControl1)
gen cent_control_IT=.
mata st_store(.,"cent_control_IT",matcentControl1_IT)
gen cent_control_DE=.
mata st_store(.,"cent_control_DE",matcentControl1_DE)
gen nbU_DE=.
mata st_store(.,"nbU_DE",matnbU_DE)
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta",replace
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta",clear

twoway (connect centralityU year) (connect cent_control_IT year)   (connect cent_control_DE year) (connect cent_control year)
****
twoway (connect centralityU year, xline(1999) xline(2007)) (connect cent_control year)
****

twoway (connect centralityU year, xline(1999) xline(2007)) (connect centralityPRO year)
*
twoway (connect centralityU year, xline(1999) xline(2007)) (connect cent_control_DE year)

twoway (connect centralityU year, xline(1999) xline(2007)) (connect cent_control_DE year) (connect centralityPRO year)


gen mcentU=centralityU/nbUniv
gen mcentPRO=centralityPRO/nbPRO 

twoway (connect mcentU year, xline(1999) xline(2007)) (connect mcentPRO year)
gen mcentU_DE=cent_control_DE/nbU_DE
twoway (connect mcentU year, xline(1999) xline(2007)) (connect mcentU_DE year)

twoway (connect centralityU year if year<2008, xline(1999)) (connect centralityPRO year if year<2008) 
twoway (connect centralityU year if year>=1999, xline(2007)) (connect centralityPRO year if year>=1999) 

twoway (connect centralityU year if year<2008, xline(1999)) (connect cent_control_DE year if year<2008) 
twoway (connect centralityU year if year>=1999, xline(2007)) (connect cent_control_DE year if year>=1999) 

twoway (connect mcentU year if year<2008, xline(1999)) (connect mcentPRO year if year<2008) /**/
twoway (connect mcentU year if year>=1999, xline(2007)) (connect mcentPRO year if year>=1999) 


gen diff_DE=cent_control_DE-centralityU
gen diff_pro=centralityPRO-centralityU

tab year diff_DE
table year,c(mean centralityU  mean cent_control mean diff_DE)

twoway (connect diff_DE year, xline(1999) xline(2007)) (connect diff_pro year)  

