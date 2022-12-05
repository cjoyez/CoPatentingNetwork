
/**Description des bases utilisées : 

 "Combined_renamed.dta"
-> Compilation de toutes les extractions Patstat. Fusion des universités et PROs selon leur nom (psn_name). Base de départ
->créé oar rename_univ.do, à partir de Harmonisation_psn_name.xls

"Cent_psn_detail_COUNTRY.dta"
-> Base avec une observation par psn_name/timeperiod pour le COUNTRY considéré Score de centralité, nombre d'applications, etc. Utilisé pour les regressions, et scores moyen (tables 2,3,4), histogramme centraltié, etc.
-> Créée par le do-file "technical_dofile.do"

"Cent_psn_COUNTRY.dta"
-> Base avec une observation par pays/timeperiod. Centralité agrégée des universités notamment.
-> Créée par le do-file "technical_dofile.do"

"Net_FRANCE_y.dta"
-> Base contenant les réseaux de co-patenting français, selon la timeperiod considérée. 
-> Créée par le do-file "technical_dofile.do" 
-> Utilisée pour les indicateurs de réseaux (table 4 notamment)
-> ouvrir en utilisant la commande nwuse et non pas use (from nwcommands)
-> Base de l'extraction Gephi pour les graphs

"C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_Sector_yearly_FRANCE.dta"
-> Créée par le do-file "technical_dofile_yearly.do" 
*/
capt log close
log using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\statdesc_yearly",replace
log on

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_FRANCE.dta",clear
twoway (connect nnodes year)
twoway (connect avgDegreeU year) (connect avgDegree year)
twoway (connect avgStrengthU year) (connect avgStrength year)
twoway (connect avgwBetwU year) (connect avgwBetw year)
twoway (connect avgCentU year) (connect avgCent year if year>=1983)

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_GERMANY.dta",clear
twoway (connect nnodes year)
twoway (connect avgDegreeU year) (connect avgDegree year)
twoway (connect avgStrengthU year) (connect avgStrength year)
twoway (connect avgwBetwU year) (connect avgwBetw year)
twoway (connect avgCentU year) (connect avgCent year if year>=1983)

append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_yearly_FRANCE.dta"
 twoway (connect avgCentU year if country=="FRANCE") (connect avgCentU year if  country=="GERMANY")


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta",clear
keep if country=="FRANCE" 

capt drop timeperiod
gen timeperiod=1
replace timeperiod=2 if year>1999
replace timeperiod=3 if year>2008

bysort timeperiod : distinct psn_name
bysort timeperiod : distinct appln_id


*drop dupplicates (same patent but registered in two techn_field)
 capt drop aay
 egen aay=group(appln_id psn_name year)
 bysort aay : keep if _n==1
 
 save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",replace

 preserve
 bysort appln_id : keep if _n==1
 tab nb_app
 restore
 
distinct appln_id
distinct psn_name
preserve
bysort psn_name : egen nbap_psn_name=nvals(appln_id)
bysort psn_name : keep if _n==1
tab nbap_psn_name
restore




use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
 gsort - cent_scale 
bysort year ( cent_sc) : gen ranky=_n
bysort year ( cent_sc) : gen maxranky=_N
gen pctile= ranky/maxranky*100
su pctile if psn_sector=="UNIVERSITY"
su pctile if psn_sector=="UNIVERSITY" & year<1999
su pctile if psn_sector=="UNIVERSITY" & year>=1999 & year<2007
su pctile if psn_sector=="UNIVERSITY" & year>=2007 


*********Tables
*Table 1
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",clear
tab techn_sector techn_field
*bysort appln_id psn_name : keep if _n==1
*egen nbappl_total= nvals(appln_id)
*bysort psn_sector : gen shareofapplication=_N/nbappl_total
*bysort psn_sector : tab shareofapplication




*table 2
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
drop _merge
merge  1:m  psn_name year using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta"
keep if _m==3
distinct psn_name
distinct appln_id

 * %share of psn_sector in sample
*distinct psn_name
capt drop psn_name_code
encode psn_name,gen(psn_name_code)
distinct psn_name
count
local tot=r(ndistinct)
bysort psn_sector : distinct psn_name
tab psn_sect


*% of applications

distinct appln_id
local nbaptot=r(ndistinct)
distinct  appln_id if psn_sector == "COMPANY"
local ncomp=r(ndistinct)
distinct  appln_id if psn_sector == "GOV NON-PROFIT"
local npro=r(ndistinct)
distinct  appln_id if psn_sector == "HOSPITAL"
local nh=r(ndistinct)
distinct  appln_id if psn_sector == "INDIVIDUAL"
local nind=r(ndistinct)
distinct  appln_id if psn_sector == "UNIVERSITY"
local nuniv=r(ndistinct)
distinct  appln_id if psn_sector == "foreign_UNIV"
local nfun=r(ndistinct)
distinct  appln_id if psn_sector == "foreign_company"
local nfcomp=r(ndistinct)

noi di "COMPANY : `ncomp'/`nbaptot' "
noi di "GOV NON-PROFIT : `npro'/`nbaptot' "
noi di "HOSPITAL : `nh'/`nbaptot' "
noi di "INDIVIDUAL  : `nind'/`nbaptot' "
noi di "UNIVERSITY  : `nuniv'/`nbaptot' "
noi di "foreign_UNIV  : `nfun'/`nbaptot' "
noi di "foreign_company : `nfcomp'/`nbaptot' "

forvalues  t= 1/3{
preserve
keep if timeperiod==`t'
distinct appln_id
local nbaptot=r(ndistinct)
distinct  appln_id if psn_sector == "COMPANY"
local ncomp=r(ndistinct)
distinct  appln_id if psn_sector == "GOV NON-PROFIT"
local npro=r(ndistinct)
distinct  appln_id if psn_sector == "HOSPITAL"
local nh=r(ndistinct)
distinct  appln_id if psn_sector == "INDIVIDUAL"
local nind=r(ndistinct)
distinct  appln_id if psn_sector == "UNIVERSITY"
local nuniv=r(ndistinct)
distinct  appln_id if psn_sector == "foreign_UNIV"
local nfun=r(ndistinct)
distinct  appln_id if psn_sector == "foreign_company"
local nfcomp=r(ndistinct)

noi di "COMPANY : `ncomp'/`nbaptot' "
noi di "GOV NON-PROFIT : `npro'/`nbaptot' "
noi di "HOSPITAL : `nh'/`nbaptot' "
noi di "INDIVIDUAL  : `nind'/`nbaptot' "
noi di "UNIVERSITY  : `nuniv'/`nbaptot' "
noi di "foreign_UNIV  : `nfun'/`nbaptot' "
noi di "foreign_company : `nfcomp'/`nbaptot' "
restore
}



use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",clear
keep if country_obs=="FRANCE"
count
distinct appln_id
bysort psn_sector : distinct appln_id

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
bysort psn_sector : distinct psn_name

bysort timeperiod psn_sector  : distinct psn_name




*table 3 
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
keep if timep==1
drop psn_name_code
encode psn_name,gen(psn_name_code)
distinct psn_name
count
local tot=r(ndistinct)
bysort psn_sector : distinct psn_name
tab psn_sect

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",clear
keep if country_obs=="FRANCE"
keep if timeperiod==1
count
distinct appln_id
bysort psn_sector : distinct appln_id

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
keep if timep==2
drop psn_name_code
encode psn_name,gen(psn_name_code)
distinct psn_name
count
local tot=r(ndistinct)
bysort psn_sector : distinct psn_name
tab psn_sect

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",clear
keep if country_obs=="FRANCE"
keep if timeperiod==2
count
distinct appln_id
bysort psn_sector : distinct appln_id


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
keep if timep==3
drop psn_name_code
encode psn_name,gen(psn_name_code)
distinct psn_name
count
local tot=r(ndistinct)
bysort psn_sector : distinct psn_name
tab psn_sect

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed_FRANCE.dta",clear
keep if country_obs=="FRANCE"
keep if timeperiod==3
count
distinct appln_id
bysort psn_sector : distinct appln_id



*TABLE 4 :
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
gen cent_direct=_degree^.5*_strength^.5
capt drop _between_sc
bysort timep : egen _between_total=total(_between)
gen _between_scale=_between/_between_total*100
capt drop psn_name_code
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_GERMANY_yearly.dta"
capt drop psn_name_code
*append using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_ITALY.dta"
*drop psn_name_code
encode psn_name,gen(psn_name_code)
*drop cent_sc
*drop cent
*gen cent=wevcent
*gen cent_scale=wevcent_sc
capt drop rank_cent
gen ini_order=_n
gsort  timeperiod country_obs  - cent_scale 
by timeperiod country_obs : gen rank_cent=_n
sort ini_order
drop ini_order
*table 4 : nb nddes
	bysort  timep : tab psn_sector if country_obs=="FRANCE"
*table 4 : average centrality
	bysort  timep : su cent_sc if country_obs=="FRANCE"
	bysort psn_sector timep : su cent_sc if country_obs=="FRANCE".	
	bysort psn_sector timep : su _between_scale if country_obs=="FRANCE"
* table 4 : top ranked universities
sort rank
	bro psn_name  timeperiod country_obs   cent_sc  rank  if country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==1
	count if rank<=50 & country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==1
	bro psn_name  timeperiod country_obs   cent_sc  rank  if country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==2
	count if rank<=50 & country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==2
	bro psn_name  timeperiod country_obs   cent_sc  rank  if country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==3
	count if rank<=50 & country_obs=="FRANCE" & psn_sector=="UNIVERSITY" & timep==3

	*Extensive and intensive margins
tab timeperiod nbtotappUniv if  country_obs=="FRANCE"
/*
*Network analysis
nwclear
nwuse "C:\Users\cjoyez\Desktop\Gredeg\Isabel_Patstat\Net_FRANCE_1",clear
nwset
nwsummarize
nwStrengthcent
nwdisparity
nwgeodesic
nwclear 
nwuse "C:\Users\cjoyez\Desktop\Gredeg\Isabel_Patstat\Net_FRANCE_2",clear
nwset
nwsummarize
nwStrengthcent
nwdisparity
nwgeodesic
nwclear 
nwuse "C:\Users\cjoyez\Desktop\Gredeg\Isabel_Patstat\Net_FRANCE_3",clear
nwset
nwsummarize
nwStrengthcent
nwdisparity
nwgeodesic
*/


******Figures 
*Histogram concentration 
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE.dta",clear
drop psn_name_code
bysort year country_obs: egen nbUniv_y_c=nvals(psn_name) if psn_sector=="UNIVERSITY"
bysort year country_obs (nbUniv_y_c): replace nbUniv_y_c=nbUniv_y_c[1] if nbUniv_y_c==. 
replace nbUniv_y_c=0 if nbUniv_y_c==.

*Passer les variables de controle en log
su cent_sc,de
gen lcent_sc=ln((cent_sc)+1)
gen lcent=ln(cent+1)
gen lpat_econvalue=ln(pat_econvalue+1)
gen lpat_quality=ln(pat_quality+1)
gen lpat_volume=ln(pat_volume+1)
gen lpat_divtechn=ln(pat_divtechn+1)
gen lnbUniv=ln(nbUniv+1)
histogram lcent_sc ,bin(50) freq

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE.dta",clear
gen lcent_sc=ln(cent_sc)
histogram lcent_sc ,bin(50) freq
log off
log close
*Histogram concentration 
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
gen lcent_sc=ln(cent_sc)
histogram lcent_sc ,bin(50) freq
*log off
*log close
