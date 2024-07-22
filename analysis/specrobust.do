

*******OVERVIEW********
* This performs a variety of robustness checks. Robustness to main specificaitons: 1) robustness to balance and tenure assumptions 2) robustness to no FE 3) results WITHOUT under-reporting 4) results using Larrimore under-reporting rates...
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
	global dofiles"/Users/chloeeast/Documents/GitHub/JobLosers_SafetyNet/makedata"	 	 	
} 
else if c(username)=="Chloe" {  		// for Chloe's laptop
	global dir "/Users/Chloe/Dropbox"
} 
else if c(username)=="davidsimon" {  //for David's laptop
	global dir "/Users/davidsimon/Dropbox/Research and Referee work/papers/Under Review"
	global dofiles "/Users/davidsimon/Documents/GitHub/JobLosers_SafetyNet/makedata"
}
else if c(username)=="elizabeth" { // Ellie's laptop
	global dir "/Users/elizabeth/Dropbox"
	global dofiles "/Users/elizabeth/Documents/GitHub/JobLosers_SafetyNet/makedata"
}

if c(username)=="das13016" {  //for David's laptop
	global rawdata "$dir/Intergen Sipp/rawdata"
	global outputdata "C:\Users\das13016\Dropbox\Research and Referee work\papers\Under Review\Intergen Sipp\child SIPP longterm\analysis\output\JobLosers_SafetyNet"
	global samples "$dir/Intergen Sipp/child SIPP longterm/analysis/samples/JobLosers_SafetyNet/"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir\child SIPP longterm\literature\Jobloss Papers\Elira_JMP_datafiles\Data\RegData\"
	global outputlog "/Users/davidsimon/Documents/GitHub/JobLosers_SafetyNet/logs"
	global results "$dir/Intergen Sipp/child SIPP longterm/analysis/output/JobLosers_SafetyNet/"
}
if c(username)=="chloeeast" | c(username)=="Chloe"   {
	global rawdata "$dir/rawdata"
	global rv_outputdata "/Users/chloeeast/Dropbox/child SIPP longterm/analysis/dofiles/jobloss/Aux data and setupcode/Safety Net Calculators"
	global outputdata "$dir/child SIPP longterm//analysis/samples"
	global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet/"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/RegData/"
	global outputlog "/Users/chloeeast/Documents/GitHub/JobLosers_SafetyNet/logs"
	global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}
if c(username)=="elizabeth" {
	global rv_outputdata "$dir/child SIPP longterm/analysis/dofiles/jobloss/Aux data and setupcode/Safety Net Calculators"
	global outputdata "$dir/child SIPP longterm//analysis/samples"
	global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
	global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
	global ek_outputdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/RegData"
	global outputlog "/Users/elizabeth/Documents/GitHub/JobLosers_SafetyNet/logs"
	global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}

*******
log using "$outputdata/specrobust.log", replace	

*robustness to specification

use "$samples/regfinal.dta", clear 
	
	
	
*******************************************************************************
******* Robustness of Figure 2: Safetynet participation event studies. ***
*******************************************************************************

***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample and Subgroups ***
*** Adjust for Under-Reporting ***
***************************************

****************************
*1) linear time trend:
****************************
foreach b in all   {

 estimates clear 
	
* produces the results for whethe received benefits from each program instead of benefit amount
foreach y in   uiamt  h_fs_amt h_tanf_amt frp_lunch_value h_wic_amt ssi_amt ss_amt {  
	eststo: xi: xtreg d_`y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_`y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_`y'_`b' = r(mean)
	di "ypre_`y'_`b'"
	di ypre_`y'_`b'
	estimates store d_`y'
}


* withOUT confidence intervals
coefplot  (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep(dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted noci   ylabel(0(2.5)10) yscale(range(0(2.5)10))
	graph export "$results/d_hhresources_`b'_noui_noci_ur_lineart.pdf", replace 
	

	* with confidence intervals
coefplot  (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep(dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted   ylabel(0(2.5)10) yscale(range(0(2.5)10))
	graph export "$results/d_hhresources_`b'_noui_ci_ur_lineart.pdf", replace 
	

	
	
	}	

****************************	
* 2) balance 
****************************

foreach b in balance_1224   {

 estimates clear 
	
* produces the results for whethe received benefits from each program instead of benefit amount
foreach y in   uiamt  h_fs_amt h_tanf_amt frp_lunch_value h_wic_amt ssi_amt ss_amt   {  
	eststo: xi: xtreg d_`y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_`y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar `y'_`b' = r(mean)
	di "ypre_`y'_`b'"
	di `y'_`b'
	estimates store d_`y'
}


*  withOUT confidence intervals
coefplot  (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted noci   ylabel(0(2.5)10) yscale(range(0(2.5)10))
	graph export "$results/d_hhresources_`b'_noui_noci_ur.pdf", replace 
	

	* with confidence intervals
coefplot  (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted   ylabel(0(2.5)10) yscale(range(0(2.5)10))
	graph export "$results/d_hhresources_`b'_noui_ci_ur.pdf", replace 
	

	
	
	}	

************************************************************
*** Difference-in-differences Robustness: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
*** 
*** ADJUSTED FOR UNDER-REPORTING ***
*** STRATIFYING THE FULL SAMPLE ***
****************************	

****************************
* Figure A5 and A6: Produces underlying numbers for the figures
****************************
	
foreach b in  all uismp nouismp recession notrecession white black hisp anykids_sm0 nokids_sm0 earn_quintiles1 earn_quintiles2 earn_quintiles3  earn_quintiles4 earn_quintiles5  { 
 estimates clear 
	eststo clear
foreach y in  earn uiamt  h_fs_amt h_tanf_amt ss_amt ssi_amt frp_lunch_value h_wic_amt  { 
	eststo: xi: xtreg `y'_ur post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}	
	
************************************************************
*** No Fixed Effects ROBUSTNESS *********
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together 
*** 	(separate from UI generosity), 1 YEAR JOB TENURE - SIPP 
*** ADJUSTED FOR UNDER-REPORTING *********
************************************************************	

****************************
* Figure A10 (a)
****************************

estimates clear 

foreach b in  all {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: reg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	  if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0],  vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl==0 & month_reljl~=.
	
	estadd scalar ymean = r(mean)
	estimates store `y'

}

	
*figure A10	(a)
	coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted
	graph export "$results/hhresources_`b'_nofe_ur.pdf", replace
	
*figure A10 (a) without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "$results/hhresources_`b'_nofe_noci_ur.png", replace
	
}





************************************************************
******* UNDER REPORTING ROBUSTNESS *********
************************************************************

***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample ***
*** WITHOUT ADJUSTING FOR UNDER-REPORTING ***
***************************************

	
****************************
* Figure A9 
****************************

foreach b in all { 

 estimates clear 

foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y' dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	 i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	estimates store `y'


}


*produces figure: outcome is earnings
coefplot (earn, label("Earnings") color(black)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/earn_`b'.pdf", replace
	
	coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted
	graph export "$results/hhresources_`b'.png", replace
	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "$results/hhresources_`b'_noci.png", replace

	esttab  using "$results/hhresources_`b'.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus FRPL" "Plus WIC"  "Plus SSI"  "Plus SS" "Plus Energy") ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))

	
eststo clear
}

*******************************************************************************
*** Difference-in-differences: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
***
*** Full Sample ***
*** WITH ALTERNATE ADJUSTMENT FOR UNDER-REPORTING ***
*** using Larrimore, Mortenson, and Splinter 2022 ***
*** Produces underlying numbers for figure ***
*************************************** 

* authors calculations for UI
gen uiamt_irs_ur=uiamt/ui_rr_dol_irs
replace uiamt_irs_ur = 0 if uiamt_irs_ur == . 
gen uiamt_sm0_irs_ur=uiamt_sm0/ui_rr_dol_irs
	
* splinter based household income adjusted for under-reporting
gen hinc_irs_ur = hinc-(uiamt + h_tanf_amt + h_ss_amt + h_ssi_amt) +(uiamt_irs_ur + h_tanf_amt_ur + h_ss_amt_ur + h_ssi_amt_ur)
sum hinc hinc_ur

gen hinc_sm0_irs_ur = hinc_sm0-(uiamt_sm0 + h_tanf_amt_sm0 + h_ss_amt_sm0 + h_ssi_amt_sm0) +(uiamt_sm0_irs_ur + h_tanf_amt_sm0_ur + h_ss_amt_sm0_ur + h_ssi_amt_sm0_ur)
sum hinc_sm0 hinc_sm0_irs_ur

gen aftertrans_inc_irs_ur = hinc_irs_ur + h_fs_amt_ur + frp_lunch_value_ur  + h_wic_amt_ur // splinter based

****************************
* Plot of ui amount using different under-reporting adjustment methods
****************************
preserve 
keep if year_m >= 1999

gen f3_wgt = p5wgt/1000000000

bysort pov_ratio_ur: egen meyer = sum(uiamt_ur * f3_wgt) 
bysort pov_ratio_ur: egen splinter = sum(uiamt_irs_ur * f3_wgt) 
bysort pov_ratio_ur: egen unadjusted = sum(uiamt * f3_wgt)

collapse meyer splinter unadjusted, by(pov_ratio_ur)

graph bar meyer splinter unadjusted, over(pov_ratio_ur) ///
scheme(plotplainblind) ///
ytitle("UI Amount (billions)") ///
b1title("Poverty Ratio") ///
legend(position(6) order(1 "Meyer" 2 "Splinter" 3 "Unadjusted") rows(1))
graph export "$results/Meyer_v_Splinter_UIbypov.png", replace

restore 


****************************
* Figure A8 panel (b) - alternate reporting adjustment based on larrimore et al. 2023
****************************
		
preserve
keep if year_m >= 1999	// splinter rates start in 1999
gen all_irs_ur = 1
rename hpov_sm0_100_ur hpov_sm0_100_irs_ur // we want to use the same bins but with different names
rename hpov_sm0_100200_ur hpov_sm0_100200_irs_ur
rename hpov_sm0_200300_ur hpov_sm0_200300_irs_ur
rename hpov_sm0_300400_ur hpov_sm0_300400_irs_ur
rename hpov_sm0_400500_ur hpov_sm0_400500_irs_ur
rename hpov_sm0_500600_ur hpov_sm0_500600_irs_ur
rename hpov_sm0_600700_ur hpov_sm0_600700_irs_ur
rename hpov_sm0_700800_ur hpov_sm0_700800_irs_ur
rename hpov_sm0_800pl_ur hpov_sm0_800_irs_ur

* Figure A8 panel (b)
foreach b in all_irs hpov_sm0_100_irs_ur hpov_sm0_100200_irs_ur hpov_sm0_200300_irs_ur hpov_sm0_300400_irs_ur hpov_sm0_400500_irs_ur hpov_sm0_500600_irs_ur hpov_sm0_600700_irs_ur hpov_sm0_700800_irs_ur hpov_sm0_800_irs_ur { 
 estimates clear 
	eststo clear
foreach y in  earn uiamt_irs  h_fs_amt h_tanf_amt ss_amt ssi_amt frp_lunch_value h_wic_amt  { 
	eststo: xi: xtreg `y'_ur post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}
	
restore


*******************************************************************************
*** Difference-in-differences: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
***
*** Years 1999+ ***
*** ADJUSTED FOR UNDERREPORTING ***
*** using Meyer rates ***
*** Produces underlying numbers for figure ***
*************************************** 


****************************
* Figure A8 (a) ***
****************************

* The original diff-in-diff results using ONLY 1999+ to match Larimore sample
foreach b in  all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur hpov_sm0_800900_ur hpov_sm0_9001000_ur hpov_sm0_1000_ur { 
 estimates clear 
	eststo clear
foreach y in  earn uiamt  h_fs_amt h_tanf_amt ss_amt ssi_amt frp_lunch_value h_wic_amt  { 
	eststo: xi: xtreg `y'_ur post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & year_m >= 1999 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_99p_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}	


*******************************************************************************
*** Difference-in-differences: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
***
*** Full Sample ***
*** NO ADJUSTMENT FOR UNDER-REPORTING ***
*** Produces underlying numbers for figure ***
*************************************** 


****************************
* Figure A10
****************************

	foreach b in all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur hpov_sm0_800900_ur hpov_sm0_9001000_ur hpov_sm0_1000_ur { 
	eststo clear
foreach y in  earn uiamt  h_fs_amt h_tanf_amt ss_amt ssi_amt frp_lunch h_wic_amt enrgyamt { 
	eststo: xi: xtreg `y' post ///
	 i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
}
	esttab  using "$results/hhresources_dd_`b'.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
	eststo clear
}

	
**********************************************************
******* Check work requirements: ABAWDs
**********************************************************
	
* Add ABAWD information
merge m:m statefip_m0 year_m using "$samples/ABAWD_Waivers.dta" // non-matches are before 1997
keep if _merge == 3
	
* calculate abawd and subject to wr variable 
gen disabled = 1 if h_ss_amt > 0 // say if they receive ssdi they are disabled instead of self-reported
	
gen kids_pre = 1 if kids_m > 0 & month_reljl == -1 // calculates values at -1 event time
gen age_pre = age 
replace age_pre = . if month_reljl != -1
gen disabled_pre = disabled if month_reljl == -1
	
sort uniqueid kids_pre // replaces all values with a uniqueid with the value at -1 event time
bysort uniqueid: replace kids_pre = kids_pre[1]
sort uniqueid age_pre
bysort uniqueid: replace age_pre=age_pre[1]
sort uniqueid disabled_pre
bysort uniqueid: replace disabled_pre=disabled_pre[1]
		
gen abawd = 1 if age_pre>=18 & age_pre<=50 & kids_pre!=1 & disabled_pre != 1 
	
gen subject_to_wr = 1 if abawd == 1 & approved == 0 & month_reljl == -1 // mechanically this is only abawds
sort uniqueid subject_to_wr
bysort uniqueid: replace subject_to_wr=subject_to_wr[1]
	
***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** SPLITING SAMPLE BY WHETHER SUBJECT TO ABAWD REQ ***
*** WITHOUT ADJUSTING FOR UNDER-REPORTING ***
*** Produces underlying numbers for figure ***
***************************************

	
	forvalues ab = 0(1)2 {
		preserve 
		if `ab' == 0 {
			keep if subject_to_wr != 1 
			keep if abawd == 1
			local i = "nwr"
		}
		if `ab' == 1 {
			keep if subject_to_wr == 1 
			keep if abawd == 1
			local i = "wr"
		}
		if `ab' == 2 {
			keep if abawd != 1 
			local i = "nabawd"
		}
		
		foreach b in all {  
			estimates clear 
				foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
		
			eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 	dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
			i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
			sum `y' if month_reljl==0 & e(sample)==1
			estadd scalar njl = r(N)
			sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
			estadd scalar ymean = r(mean)
			sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
			scalar ypre_`y'_`b' = r(mean)
			di "ypre_`y'_`b'"
			di ypre_`y'_`b'
			estimates store `y'
	
		}
			* plot (all programs)
			coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
			vertical keep(dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
			xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
			graph export "$results/hhresources_`b'_noci_`i'_ur.png", replace
		}
		restore 
	}
	
**********************************************************
******* Check results on ages 50-55
**********************************************************

***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP *** 
*** SAMPLE AGED 50-55 ***
*** ADJUSTING FOR UNDER-REPORTING ***
***************************************

foreach b in all   {  
 estimates clear 
 
 if "`b'"~="tenure_6mo_m0" {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & age_m0 < 50 & age_m0 <= 55  [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_`y'_`b' = r(mean)
	di "ypre_`y'_`b'"
	di ypre_`y'_`b'
	estimates store `y'

}
 }
 
  if "`b'"=="tenure_6mo_m0" {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if  head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_`y'_`b' = r(mean)
	di "ypre_`y'_`b'"
	di ypre_`y'_`b'
	estimates store `y'

}
 }
	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "$results/hhresources_`b'_noci_ur_ages50-55.pdf", replace
	
	}

*******************************************************************************
*** Difference-in-differences: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
***
*** SAMPLE AGED 50-55 ***
*** ADJUSTED FOR UNDERREPORTING ***
*** PRODUCES UNDERLYING NUMBERS ***
***************************************

foreach b in  all  { 
 estimates clear 
	eststo clear
foreach y in earn uiamt_ur h_fs_amt h_tanf_amt ss_amt ssi_amt frp_lunch_value h_wic_amt { 
	eststo: xi: xtreg `y' post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & age_m0 >= 50 & age_m0 <= 55 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_50_55_ur.tex", mtitles( "Earnings" "UI" "SNAP" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}		
		
	
	
********************************************************
**********Robustness to Adding in temporary Job Losers************
*************************************************

***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample (WITH temp layoffs) ***
*** WITHOUT ADJUSTING FOR UNDER-REPORTING ***
***************************************
	

use "$samples/regfinal_temp.dta", clear 

foreach b in all { 

 estimates clear 

foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	 i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y' if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	estimates store `y'


}


coefplot (earn, label("Earnings") color(black)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/earn_`b'_templ.png", replace
	
	coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted
	graph export "$results/hhresources_`b'_templ.png", replace
	
*figure  without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3200(1000)500)) 
	graph export "$results/hhresources_`b'_noci_templ.png", replace

	esttab  using "$results/hhresources_`b'_templ.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus FRPL" "Plus WIC" "Plus SSI" "Plus SS" "Plus Energy") ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))

	
eststo clear
}

********************************************************
**********SS Robustness************
*************************************************

*******************************************************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Tables exploring SS robustness to balance and fe
*** Full Sample and Subgroups ***
*** Adjust for Under-Reporting ***
*******************************************************************************


****************************
* Just ss
****************************

foreach b in all layoff0809  {

 estimates clear 
	
* produces the results for whethe received benefits from each program instead of benefit amount
foreach y in   ss_amt   {  
* baseline
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_baseline

	* no fe
	eststo: xi: reg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0],  vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_ur
	
	* balance,  fe
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & balance_1224 == 1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_ur
	}	
	
	
*table A3 
	esttab  using "$results/hhresources_`b'_ss_balancefe.tex", posthead(" \hline \\\\[-1ex] &\multicolumn{3}{c}{\centering SS} \\\cmidrule(lr){2-4} \\  &\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}\\  \hline \\\\[-1ex] ") ///
	replace keep(dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) ///
	se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nomtitles nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
	eststo clear

	
	
	}	

	
****************************
* all other programs
****************************

foreach b in all layoff0809  {

 estimates clear 
	
* produces the results for whethe received benefits from each program instead of benefit amount
foreach y in   uiamt  h_fs_amt h_tanf_amt ssi_amt frp_lunch_value h_wic_amt   {  
* baseline
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_baseline

	* no fe
	eststo: xi: reg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0],  vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_ur
	
	* balance,  fe
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & balance_1224 == 1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum ss_amt if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum d_ss_amt if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_ss_amt_`b' = r(mean)
	di "ypre_ss_amt_`b'"
	di ypre_ss_amt_`b'
	estimates store `y'_ur
	}	
	
	
*table A3 
	esttab  using "$results/hhresources_`b'_othprog_fe.tex", posthead(" \hline \\\\[-1ex] &\multicolumn{3}{c}{\centering UI}&\multicolumn{3}{c}{\centering SNAP}&\multicolumn{3}{c}{\centering TANF} &\multicolumn{3}{c}{\centering SSI} &\multicolumn{3}{c}{\centering FRPL} &\multicolumn{3}{c}{\centering WIC}\\\cmidrule(lr){2-4}\cmidrule(lr){5-7}\cmidrule(lr){8-10}\cmidrule(lr){11-13}\cmidrule(lr){14-16}\cmidrule(lr){17-19} \\  &\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}&\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}&\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}&\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}&\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}&\multicolumn{1}{c}{Baseline}&\multicolumn{1}{c}{No FE}&\multicolumn{1}{c}{Balanced}\\  \hline \\\\[-1ex] ") ///
	replace keep(dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) ///
	se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nomtitles nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
	eststo clear

	
	
	}	



	
	log close
