clear
foreach C in De Fr It {
	foreach S in Univ GovNon {
		forvalues n=1/8{
		capture import excel "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\\`C'`S'`n'.xlsx", firstrow
		capture save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\\`C'`S'`n'.dta",replace
		count
		clear
		}
	}
}

clear
foreach C in De Fr It {
noi di "`C'"
	foreach S in Univ GovNon {
	 noi di "`S'" 
	 clear
		capture forvalues n=1/8{
		  noi di "`n'"
		 append using  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\\`C'`S'`n'.dta"
		}
		gen year=appln_filing_year
		gen country_obs=""
		replace country_obs="FRANCE" if "`C'"=="Fr"
		replace country_obs="GERMANY" if "`C'"=="De"
		replace country_obs="ITALY" if "`C'"=="It"
		gen source_obs="`C'`S'"
		save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\\`C'`S'_all.dta",replace
	}
}


clear
foreach C in De Fr It {
noi di "`C'"
	foreach S in Univ GovNon {
	 noi di "`S'"
	append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\\`C'`S'_all.dta"

		}
	}
save "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\New_all.dta",replace
clear
use "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\New_all.dta"
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\Dataset_ALL - ALLYEARS_FOREIGN.dta" /*initial 2 only GE and IT collaborations with firms*/
append using "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\Dataset_ALL - ALLYEARS.dta" /*initial 1 only Fr collaborations with firms*/

drop if psn_sector=="UNKNOWN"
replace psn_sector="UNIVERSITY" if psn_sector=="GOV NON-PROFIT UNIVERSITY" &  person_ctry_code=="FR" & country_obs=="FRANCE"
replace psn_sector="HOSPITAL" if psn_sector=="COMPANY HOSPITAL"
replace psn_sector="UNIVERSITY" if psn_sector=="GOV NON-PROFIT UNIVERSITY"
replace psn_sector="UNIVERSITY" if psn_sector=="COMPANY UNIVERSITY"

replace psn_sector="foreign_UNIV" if psn_sector=="UNIVERSITY" &  person_ctry_code!="FR" & country_obs=="FRANCE"
replace psn_sector="foreign_UNIV" if psn_sector=="UNIVERSITY" &   person_ctry_code!="IT" & country_obs=="ITALY"
replace psn_sector="foreign_UNIV" if psn_sector=="UNIVERSITY" &  person_ctry_code!="DE" & country_obs=="GERMANY"

replace psn_sector="GOV NON-PROFIT" if psn_sector=="COMPANY GOV NON-PROFIT"

replace psn_sector="foreign_company" if psn_sector=="COMPANY" &  person_ctry_code!="FR" & country_obs=="FRANCE"
replace psn_sector="foreign_company" if psn_sector=="COMPANY" &   person_ctry_code!="IT" & country_obs=="ITALY"
replace psn_sector="foreign_company" if psn_sector=="COMPANY" &  person_ctry_code!="DE" & country_obs=="GERMANY"

tab psn_sector


duplicates tag appln_id appln_auth appln_nr appln_filing_year psn_name techn_field country_obs,gen(duplicate)
tab dup
tab dup source
tab nb_app source
distinct appln_id
bro if dup>0
tab dup if appln_id==16606442
bysort appln_id : gen dupabove=(dup>0)
bro if dupabove==1
tab duplic
bysort appln_id appln_auth appln_nr appln_filing_year psn_name techn_field country_obs : replace duplic=0 if _n==1
tab duplic
distinct appln_id
drop if duplic>0
distinct appln_id
save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta",replace
use  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta",clear
distinct appln_id
*keep if year>=1983
*bysort appln_id: egen nbapplicant2=nvals(psn_name)
drop if nb_app<2
tab nb_app
save  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\Combined.dta",replace
