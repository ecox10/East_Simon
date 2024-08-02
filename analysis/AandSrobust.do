/*********************
File Name: AandSrobust.do

This file conducts Abraham and Sun results in
"The safety net and job loss: How much insurance do public programs provide?" 

By: Chloe East and David Simon

Inputs: regfinal.dta
Outputs: ASresources__noci_ur.png
***********************/

clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently

*install modern scheme
net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern

*must install abraham and sun estimator to running
net install github, from("https://haghish.github.io/github/")
github install lsun20/eventstudyinteract
	
*******************************************************************************
******* Produce Figure ***
*******************************************************************************

use "${outdata}/regfinal.dta", clear 
	
***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample and Subgroups ***
*** Abraham and SUN ********
*** Adjust for Under-Reporting ***
***************************************

* within individuals an indicator for age at treatment?
sort uniqueid month_reljl
bysort uniqueid: gen cohort1 = age if month_reljl==0. /* ym_now */
bysort uniqueid: egen cohort = min(cohort1)
 
* define late treated as treated in the last ages of the sample (50 or later)
gen control = cohort>=50
drop if age>=50 // drop if ym_now>635

order uniqueid month_reljl cohort1 cohort age	
sum uniqueid

****************************
* Figure A10 (b)
****************************

foreach b in  all  {   
  estimates clear 

foreach y in  earn_ur plus_ui_ur plus_fs_ur plus_tanf_ur plus_frpl_ur plus_wic_ur plus_ssi_ur plus_ss_ur  { 

	eststo:eventstudyinteract `y' dumspell1 dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18  if tenure_1year==1 & head_spouse_partner==1 & all==1 /*`b'*/ [pw=p5wgt_m0], vce(cluster uniqueid) absorb(uniqueid age) covariates(i.yearmonth) cohort(cohort) control_cohort(control)


	estadd scalar ymean = r(mean)
    matrix `y' = e(b_iw)
}

}
	
*produces figure : outcome is earnings
coefplot (matrix(earn_ur), label("Earnings") color(black)) , ///
vertical ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "${results}/ASearn_`b'_ur.pdf", replace
	
*figure without confidence intervals	
coefplot (matrix(earn_ur), label("Earnings") color(black)) (matrix(plus_ui_ur), label("+ UI") color(blue)) (matrix(plus_fs_ur), label("+ SNAP") color(red) msymbol(square)) ///
(matrix(plus_tanf_ur), label("+ TANF") color(orange) msymbol(triangle)) (matrix(plus_frpl_ur), label("+ FRPL") color(midgreen)) ///
(matrix(plus_wic_ur ), label("+ WIC") color(dkgreen) msymbol(square)) (matrix(plus_ssi_ur ), label("+ SSI") color(sienna)) /// 
(matrix( plus_ss_ur), label("+ SS") color(purple) msymbol(plus)) , ///
vertical ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "${results}/ASresources_`b'_noci_ur.png", replace




