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
