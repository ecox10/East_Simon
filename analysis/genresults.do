

*******OVERVIEW********
* This file produces the main event study figures and tables as well as the underlying numbers for difference-in-difference results. 
*******************


capture log close
clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently

net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern

*********************************************************************
/* DIRECTORY AND FILE NAMES: */  

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
log using "$outputdata/genresults_v5.log", replace	

		
	
	use "$samples/regfinal.dta", clear 


	
*******************************************************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample and Subgroups ***
*** Adjust for Under-Reporting ***
*******************************************************************************

	
*************************
* Figure 1 Own Earnings, Spouse Earnings and Household Earnings. 
*************************	


foreach b in all  {  
 estimates clear 
 
foreach y in earn marsp_earn hearn { 
	eststo: xi: xtreg `y' dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
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

	
*produces change in dollar amt with own earnings

coefplot (earn, label("Job Loser's Own Earnings") color(black) ciopts(lcol(black)))  (marsp_earn, label("Spousal Earnings") color(gs9) msymbol(triangle) ciopts(lcol(dimgray))) (hearn, label("Total Household Earnings") color(gray) msymbol(square)  ciopts(lcol(dimgray)))  , ///
vertical keep(dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/earnhh_`b'_ur_earnonly.pdf", replace
	
}
*stop



**************************
* Figure 2 and Table A3 household resources
****************************


foreach b in all   {

 estimates clear 
	
* produces the results for whethe received benefits from each program instead of benefit amount
foreach y in   uiamt  h_fs_amt h_tanf_amt frp_lunch_value h_wic_amt ssi_amt ss_amt {  
	eststo: xi: xtreg d_`y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
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

*table A3 
	esttab  using "$results/d_hhresources_`b'.tex", mtitles("UI" "SNAP" "TANF" "FRPL" "WIC" "SSI" "SS" "Energy" ) ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) ///
	se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
	eststo clear



* figure 2 with confidence intervals
coefplot  (d_uiamt, label("Any UI") color(blue)) (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted  
	graph export "$results/d_hhresources_`b'_ur.png", replace
	
* figure 2 withOUT confidence intervals
coefplot  (d_uiamt, label("Any UI") color(blue)) (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted noci  ylabel(0(10)80) yscale(range(0(10)50)) 
	graph export "$results/d_hhresources_`b'_noci_ur.png", replace 
	
	
	
* figure 2b with confidence intervals
coefplot (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted 
	graph export "$results/d_hhresources_`b'_noui_ur.png", replace 
	
* figure 2b withOUT confidence intervals
coefplot (d_h_fs_amt, label("Any SNAP") color(red) msymbol(square)) ///
(d_h_tanf_amt, label("Any TANF") color(orange) msymbol(triangle)) (d_frp_lunch_value, label("Any FRPL") color(midgreen) ) ///
 ( d_h_wic_amt, label("Any WIC") color(dkgreen) msymbol(square)) (  d_ssi_amt, label("Any SSI") color(sienna)) ///
 (d_ss_amt, label("Any SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Receipt") omitted noci   ylabel(0(2.5)10) yscale(range(0(2.5)10))
	graph export "$results/d_hhresources_`b'_noui_noci_ur.png", replace 
	
*produces the DD version of figure 2
foreach y in   uiamt h_fs_amt h_tanf_amt frp_lunch_value h_wic_amt ssi_amt ss_amt { 
	eststo: xi: xtreg d_`y'_ur post ///
	i.age i.year_m imonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum d_`y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/d_hhresources_dd_`b'_ur.tex", mtitles("UI" "SNAP" "TANF" "FRPL" "WIC" "SSI" "SS"  "Energy"  ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0)) 
	eststo clear
	
	
	
	}	
	
	
*************************
*Figure 3, Figure A4, & Table A2 -  Event study in resources.  
*************************	


foreach b in all tenure_6mo_m0 tenure_18mo_m0  balance_1224 {  
 estimates clear 
 
 if "`b'"~="tenure_6mo_m0" {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
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

  

*This produces a table version of figure 3, Table A2
	esttab  using "$results/hhresources_`b'_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus FRPL" "Plus WIC" "Plus SSI" "Plus SS" "Plus Energy") ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0))
	eststo clear

	
	
*produces change in dollar amt with own earnings
coefplot (earn, label("Earnings") color(black)) , ///
vertical keep(dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "$results/earn_`b'_ur.png", replace
	
	
*figure 3 without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3200(1000)500)) 
	graph export "$results/hhresources_`b'_noci_ur.png", replace

	
  
}

*************************
* Figure 4 (all panels): Event study by layoff period
*************************

gen layoff9697 = 1 if year_m0 >= 1996 & year_m0 <= 1997
gen layoff0405 = 1 if year_m0 >= 2004 & year_m0 <= 2005


foreach layoffperiod in  layoff9697 layoff01 layoff0405 layoff0809 {
foreach b in all   {  
 estimates clear 
 
 if "`b'"~="tenure_6mo_m0" & "`layoffperiod'"~="layoff01" {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & `layoffperiod' == 1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
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
 
 if "`b'"~="tenure_6mo_m0" & "`layoffperiod'"=="layoff01" {
foreach y in  earn plus_ui plus_fs plus_tanf plus_frpl plus_wic plus_ssi plus_ss { 
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.imonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & `layoffperiod' == 1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
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
 
	
* without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500))
	graph export "$results/hhresources_`b'_noci_ur_`layoffperiod'.png", replace
	
	}
	}
	
*******************************************************************************
*** Difference-in-differences: Estimates of Safety Net Program Value, 1 YEAR JOB TENURE - SIPP ***
***
*** Full Sample and Subgroups ***
*** Adjust for Under-Reporting ***
*******************************************************************************

****************************
*  Figure 5 - table results by poverty ratio and other heterogeneity, adjusting for under-reporting Meyer
****************************
	//  (the main adjustment method for under-reporting)
	
foreach b in  all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur hpov_sm0_800900_ur hpov_sm0_9001000_ur hpov_sm0_1000_ur { 
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

	
	
*******************************************************************************
*** POVERTY RESULTS***
*** 
*** ADJUSTED FOR UNDER-REPORTING ***
*******************************************************************************


*************************
* Figure 6 and Table A5-  household poverty with and without safety net. 
*************************	


foreach b in    all {  
 estimates clear 
 
foreach y in hpov_e100 hpov_t100 {  
	eststo: xi: xtreg `y'_ur dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18 ///
	i.age i.yearmonth  if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y'_ur if month_reljl==0 & e(sample)==1
	estadd scalar njl = r(N)
	sum `y'_ur if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	sum `y'_ur if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	scalar ypre_`y'_ur_`b' = r(mean)
	di "ypre_`y'_ur_`b'"
	di ypre_`y'_ur_`b'
	estimates store `y'
}

* table A5
	esttab  using "$results/hh_pov`b'_ur.tex", replace ///
	 keep(  dumspell2 dumspell3 dumspell4   dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	mtitles("Earned Income" "Cash Income $+$ Near-Cash Transfers") ///
	mgroups("$<$100\%", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span erepeat(\cmidrule(lr){@span})) ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0)) 
	eststo clear
	
* figure 6 with no ci	
coefplot  (hpov_e100, label("Household Earned Income / Poverty Threshold") color(black)  ) ///
(hpov_t100, label("Household Cash and Near-Cash Income / Poverty Threshold") color(gray)   msymbol(triangle)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change") legend(pos(6)) omitted   noci  ///
ylabel(0(10)30)  yscale(r(0(10)30))
	graph export "$results/hh_pov_et_`b'_noci_ur.pdf", replace

}

	
log close

	