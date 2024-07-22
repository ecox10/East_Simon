

*******OVERVIEW********
* This produces household and secondary earner results
********************


capture log close
clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently


*********************************************************************
/* DIRECTORY AND FILE NAMES: */  
clear all 

if c(username)=="chloeeast" {  		// for Chloe's computer
	global dir "/Users/chloeeast/Dropbox/"	 	 	
	global dofiles"/Users/chloeeast/Documents/GitHub/East_Simon/makedata"	 	 	
} 
else if c(username)=="Chloe" {  		// for Chloe's laptop
	global dir "/Users/Chloe/Dropbox"
} 
else if c(username)=="davidsimon" {  //for David's laptop
	global dir "/Users/davidsimon/Dropbox/Research and Referee work/papers/Under Review"
	global dofiles "/Users/davidsimon/Documents/GitHub/East_Simon/makedata"
}
else if c(username)=="elizabeth" { // Ellie's laptop
	global dir "/Users/elizabeth/Dropbox"
	global dofiles "/Users/elizabeth/Documents/GitHub/East_Simon/makedata"
}

if c(username)=="das13016" {  //for David's laptop
	global rawdata "$dir/Intergen Sipp/rawdata"
	global outputdata "C:\Users\das13016\Dropbox\Research and Referee work\papers\Under Review\Intergen Sipp\child SIPP longterm\analysis\output\JobLosers_SafetyNet"
	global samples "$dir/Intergen Sipp/child SIPP longterm/analysis/samples/JobLosers_SafetyNet/"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir\child SIPP longterm\literature\Jobloss Papers\Elira_JMP_datafiles\Data\RegData\"
	global outputlog "/Users/davidsimon/Documents/GitHub/East_Simon/logs"
	global results "$dir/Intergen Sipp/child SIPP longterm/analysis/output/JobLosers_SafetyNet/"
}
if c(username)=="chloeeast" | c(username)=="Chloe"   {
	global rawdata "$dir/rawdata"
	global rv_outputdata "/Users/chloeeast/Dropbox/child SIPP longterm/analysis/dofiles/jobloss/Aux data and setupcode/Safety Net Calculators"
	global outputdata "$dir/child SIPP longterm//analysis/samples"
	global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet/"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/RegData/"
	global outputlog "/Users/chloeeast/Documents/GitHub/East_Simon/logs"
	global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}
if c(username)=="elizabeth" {
	global rv_outputdata "$dir/child SIPP longterm/analysis/dofiles/jobloss/Aux data and setupcode/Safety Net Calculators"
	global outputdata "$dir/child SIPP longterm//analysis/samples"
	global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/RegData"
	global outputlog "/Users/elizabeth/Documents/GitHub/East_Simon/logs"
	global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}

*******
log using "$outputdata/genresults_v4.log", replace	

		
	
	use "$samples/regfinal.dta", clear 

*******************************************************************************
******* Robustness of Earnings Results 				  ******************
******* Household Income and Secondary Earner Results ******************
*******************************************************************************

* Create household income with secondary earner income
gen hinc_ur = hinc-(uiamt + h_tanf_amt + h_ss_amt + h_ssi_amt) +(uiamt_ur + h_tanf_amt_ur + h_ss_amt_ur + h_ssi_amt_ur)
sum hinc hinc_ur

gen hinc_sm0_ur = hinc_sm0-(uiamt_sm0 + h_tanf_amt_sm0 + h_ss_amt_sm0 + h_ssi_amt_sm0) +(uiamt_sm0_ur + h_tanf_amt_sm0_ur + h_ss_amt_sm0_ur + h_ssi_amt_sm0_ur)
sum hinc_sm0 hinc_sm0_ur

* add safetynet income to household earnings rather than earnings 
* hearn + meyer adjusted 
gen hearn_ur =hearn
* own earnings + ui   
gen hplus_ui_ur = hearn + uiamt_ur
* own earnings + ui  + h_fs_amt 
gen hplus_fs_ur = hplus_ui_ur  + h_fs_amt_ur
* own earnings + ui  + h_tanf_amt 
gen hplus_tanf_ur = hplus_fs_ur  + h_tanf_amt_ur
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt  
gen hplus_ss_ur = hplus_tanf_ur + ss_amt_ur  
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + h_ssi_amt 
gen hplus_ssi_ur = hplus_ss_ur + ssi_amt_ur    
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + h_ssi_amt + frp_lunch_value  
gen hplus_frpl_ur = hplus_ssi_ur + frp_lunch_value_ur  
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + h_ssi_amt + frp_lunch_value + h_wic_amt 
gen hplus_wic_ur = hplus_frpl_ur + h_wic_amt_ur 

sum hinc hearn marsp_earn


***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample ***
*** ADJUSTING FOR UNDER-REPORTING ***
*** re-estimate on household and spousal income ***
********************

estimates clear 
 
foreach y in  marsp_earn hearn hearn_ur hplus_ui_ur hplus_fs_ur hplus_tanf_ur hplus_ss_ur hplus_ssi_ur hplus_frpl_ur hplus_wic_ur { 
	eststo: xi: xtreg `y' dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y' if tenure_1year==1 & head_spouse_partner==1  & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_`y'_`b' = r(mean)
	di "ypre_`y'_`b'"
	di ypre_`y'_`b'
	estimates store `y'
}


*produces figure on spousal earnings 
coefplot (marsp_earn, label("Spousal Earnings (married)") color(black)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/marsp_earn.pdf", replace
	
*produces figure on household earnings 
coefplot (hearn, label("Household Earned Income") color(black)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/hearn.pdf", replace
		
*plot without confidence intervals	
coefplot (hearn, label("Earnings") color(black)) (hplus_ui_ur, label("+ UI") color(blue)) (hplus_fs_ur, label("+ SNAP") color(red) msymbol(square)) ///
(hplus_tanf_ur, label("+ TANF") color(orange) msymbol(triangle)) (hplus_ss_ur, label("+ SS") color(midgreen)) ///
(hplus_ssi_ur, label("+ SSI") color(dkgreen) msymbol(square)) (hplus_frpl_ur, label("+ FRPL") color(sienna) msymbol(plus)) /// 
(hplus_wic_ur, label("+ WIC") color(purple) msymbol(X)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "$results/hearn_resources_noci.pdf", replace
	
	log close
	
	