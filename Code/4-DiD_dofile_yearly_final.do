
set more off
capt log close
log using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\DiD_PSMDID",replace
log on

use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_FRANCE_yearly.dta",clear
drop psn_name_code
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Cent_psn_detail_GERMANY_yearly.dta"
drop psn_name_code
encode psn_name,gen(psn_name_code)
encode NUTS,gen(NUTS_code)
drop NUTS



gen time1=.
replace time1=0 if timeperiod==1
replace time1=1 if timeperiod==2

gen time2=.
replace time2=0 if timeperiod==2
replace time2=1 if timeperiod==3
 recast int time1
 recast int time2
 
capt drop treated
gen treated=.
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="UNIVERSITY" & country_obs!="FRANCE"

capt drop treated_alt
gen treated_alt1=.
replace treated_alt1=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated_alt1=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"

bysort year country_obs: egen nbUniv_y_c=nvals(psn_name) if psn_sector=="UNIVERSITY"
bysort year country_obs (nbUniv_y_c): replace nbUniv_y_c=nbUniv_y_c[1] if nbUniv_y_c==. 
replace nbUniv_y_c=0 if nbUniv_y_c==.

*Passer les variables de controle en log
gen lcent_sc=ln((cent_sc*100)+1)
gen lcent=ln(cent+1)
gen lpat_econvalue=ln(pat_econvalue+1)
gen lpat_quality=ln(pat_quality+1)
gen lpat_volume=ln(pat_volume+1)
gen lpat_divtechn=ln(pat_divtechn+1)
gen lnbUniv=ln(nbUniv+1)



gen tokeep=0
replace tokeep=1 if country=="FRANCE" & psn_sector=="UNIVERSITY"
replace tokeep=1 if country=="FRANCE" & psn_sector=="GOV NON-PROFIT"
replace tokeep=1 if country=="GERMANY" & psn_sector=="UNIVERSITY"
keep if tokeep==1
bysort psn_name_code year : gen nrep2=_N
tab nrep2
bro if nrep2==1
sort psn_name_code year
bro if nrep2==1
bro if nrep2==2
drop if psn_name=="UNIVERSITE DE RENNES 1" & country=="GERMANY"




****Diff in Diff

preserve /*Fr U vs Fr PRO TIME1*/
xtset psn_name_code year
keep if year<2008
keep if country=="FRANCE"
capt drop treated
gen treated=. 
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band')    /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diff.tex",ctitle("DiD","PROs 1999")   tex replace
restore 

*
preserve /*Fr U vs DE U TIME1*/
xtset psn_name_code year
keep if year<2008
keep if psn_sector=="UNIVERSITY"
gen treatment1=. 
replace treatment1=0 if psn_sector=="UNIVERSITY"
replace treatment1=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>1999 & year<2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
tab treated psn_sector
tab treated country
tab treated treatment1
tab year if treatment1==0 & treated==1
tab psn_sector if treatment1==0 & treated==1
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band')    /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diff.tex", ctitle("","German U. 1999")   tex
restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if country=="FRANCE"
capt drop treated
gen treated=. /*Fr U vs Fr PRO*/
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band')/* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diff.tex", ctitle("","PROs 2007")     tex
restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if psn_sector=="UNIVERSITY"
gen treatment2=. /*Fr U vs DE U*/
replace treatment2=0 if psn_sector=="UNIVERSITY"
replace treatment2=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}

tab treated year
tab treated psn_sector
tab treated country
tab treated treatment2
tab year if treatment2==0 & treated==1
tab psn_sector if treatment2==0 & treated==1
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band')    /* * */
noi outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diff.tex", ctitle("","German U. 2007") tex
restore 



****PSM matching
*epanechnikov kernel function with bandwidth parameter using Silverman's (1986) rule of thumb method
*
preserve
xtset psn_name_code year
keep if year<2008
keep if country=="FRANCE"
capt drop treated
gen treated=. /*Fr U vs Fr PRO*/
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSM.tex",ctitle("DiD PSM","PROs 1999")   tex replace
restore 

*
preserve
xtset psn_name_code year
keep if year<2008
keep if psn_sector=="UNIVERSITY"
*capt drop treated
gen treatment1=. /*Fr U vs DE U*/
replace treatment1=0 if psn_sector=="UNIVERSITY"
replace treatment1=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>1999 & year<2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
tab treated psn_sector
tab treated country
tab treated treatment1
tab year if treatment1==0 & treated==1
tab psn_sector if treatment1==0 & treated==1
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq) bw(`band') k id(psn_name_code) kt(gaussian) report /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSM.tex",ctitle("","German U. 1999")  tex 

restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if country=="FRANCE"
capt drop treated
gen treated=. /*Fr U vs Fr PRO*/
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSM.tex",ctitle("","PROs 2007") tex 

restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if psn_sector=="UNIVERSITY"
*capt drop treated
gen treatment2=. /*Fr U vs DE U*/
replace treatment2=0 if psn_sector=="UNIVERSITY"
replace treatment2=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}

tab treated year
tab treated psn_sector
tab treated country
tab treated treatment2
tab year if treatment2==0 & treated==1
tab psn_sector if treatment2==0 & treated==1
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report /* * */
 outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSM.tex",ctitle("","German U. 2007") tex 

restore 




**** PSM DID common support

*epanechnikov kernel function with bandwidth parameter using Silverman's (1986) rule of thumb method
*
preserve
xtset psn_name_code year
keep if year<2008
keep if country=="FRANCE"
capt drop treated
gen treated=. /*Fr U vs Fr PRO*/
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report support /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSMcs.tex",ctitle("PSM DiD common support","PROs 1999")   tex replace

restore 

*
preserve
xtset psn_name_code year
keep if year<2008
keep if psn_sector=="UNIVERSITY"
*capt drop treated
gen treatment1=. /*Fr U vs DE U*/
replace treatment1=0 if psn_sector=="UNIVERSITY"
replace treatment1=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>1999 & year<2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
tab treated psn_sector
tab treated country
tab treated treatment1
tab year if treatment1==0 & treated==1
tab psn_sector if treatment1==0 & treated==1
diff lcent_sc, t(treated) p(time1) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq) bw(`band') k id(psn_name_code) kt(gaussian) report support /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSMcs.tex",ctitle("","German U. 1999")   tex 

restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if country=="FRANCE"
capt drop treated
gen treated=. /*Fr U vs Fr PRO*/
replace treated=1 if psn_sector=="UNIVERSITY" & country_obs=="FRANCE"
replace treated=0 if psn_sector=="GOV NON-PROFIT"  & country_obs=="FRANCE"
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report support /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSMcs.tex", ctitle("","PROs 2007")   tex 

restore 

*
preserve
xtset psn_name_code year
keep if year>1999
keep if psn_sector=="UNIVERSITY"
*capt drop treated
gen treatment2=. /*Fr U vs DE U*/
replace treatment2=0 if psn_sector=="UNIVERSITY"
replace treatment2=1 if psn_sector=="UNIVERSITY" & country=="FRANCE" & year>2008
su lcent_sc ,de
local sd =r(sd)
local irange= (r(p75)-r(p25))/1.34
if `sd'<`irange'{
	local band=`sd'
}
else{
	local band=`irange'
}

tab treated year
tab treated psn_sector
tab treated country
tab treated treatment2
tab year if treatment2==0 & treated==1
tab psn_sector if treatment2==0 & treated==1
di "bandwith : " `band'
diff lcent_sc, t(treated) p(time2) cov(nbapp_psn sh_granted_psn pat* shpathq)  addcov(nbapp_psn sh_granted_psn pat* shpathq)  bw(`band') k id(psn_name_code) kt(gaussian) report support /* * */
outreg2 using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\reg_nov22_diffPSMcs.tex", ctitle("","German U. 2007")   tex 

restore 
log close
