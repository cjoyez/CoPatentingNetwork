*Final
set more off
clear
mata mata clear
clear matrix
nwclear

*Initial Datasets : 
	*Patastats Extractions .xls in 1
	*name harmonization.xls in 2

*Stata packages required
	*Publically available 
		*ssc install egenmore
		*ssc install distinct
		*nwcommands by Thomas Grund https://nwcommands.wordpress.com/
	*Several own developped
		*ssc install nw_projection
		*ssc install nwANND
		*nwwevcent
	

do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\1-combinePatstatExtracts.do" 
do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\2-rename.do" 
do  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\3-Network_indiv_yearly.do" 
do  "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\3bis-FranceOverallNetwork.do" 
do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\4-DiD_dofile_yearly_final.do"
do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\5-DiD_dofile_yearly_final_between.do"
do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\6-aggregatedNetworks_graph.do" 
do "C:\Users\cjoyez\Desktop\Gredeg\Isabel Patstat\newdata\output\revision_nov22\7-DescriptiveStats_yearly.do"
