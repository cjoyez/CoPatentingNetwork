clear
set more off
import excel "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\PSN_ID\Harmonisation_psn_name.xlsx", sheet("Sheet2") firstrow /*renamed only Universities, all countries*/
keep psn_name renamed 
rename renamed psn_renamed


merge m:m psn_name using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta"
drop if _m==1
replace psn_rename=psn_name if psn_rename==""
rename psn_name psn_name_ini
rename psn_rename psn_name
drop _merge
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed.dta",replace

/*
distinct psn_name if psn_sector=="UNIVERSITY"
bysort country : distinct psn_name if psn_sector=="UNIVERSITY"
bysort country timep : distinct psn_name if psn_sector=="UNIVERSITY"

bysort psn_name : egen periodmax=max(timep)
bysort psn_name : egen periodmin=min(timep)

gen disp=(periodmax!=3)


distinct psn_name if disp==1 &  psn_sector=="UNIVERSITY" & country=="FRANCE"


bro psn_name timep year  disp  if psn_sector=="UNIVERSITY" & country=="FRANCE"
sort psn_name timep


use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta",clear
distinct psn_name if psn_sector=="UNIVERSITY"
bysort country : distinct psn_name if psn_sector=="UNIVERSITY"

clear
set more off
import excel "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\PSN_ID\Harmonisation_psn_name.xlsx", sheet("Sheet2") firstrow /*renamed only Universities, all countries*/
keep psn_name renamed NUTS psn_sector
rename renamed psn_renamed 
bysort NUTS psn_sector (psn_renamed) : replace psn_rename=psn_renamed[_N] if psn_sector=="UNIVERSITY"

merge m:m psn_name using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta"
drop if _m==1
replace psn_rename=psn_name if psn_rename==""
rename psn_name psn_name_ini
rename psn_rename psn_name
drop _merge
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined_renamed2.dta",replace
distinct psn_name if psn_sector=="UNIVERSITY"
bysort country : distinct psn_name if psn_sector=="UNIVERSITY"
*/
