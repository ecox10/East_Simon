/*********************
File Name: specrobust.do

This performs a variety of robustness checks. Robustness to main specificaitons: 1) Heterogeneity of results by kids/no kids, ui/no ui, etc., 2) no fe, 3) no adjustment to underreporting, 4) alternate under-reporting rates. Produces results
in the paper:
"The safety net and job loss: How much insurance do public programs provide?" 

By: Chloe East and David Simon

Inputs: regfinal.dta
Outputs: hhresources_dd_`group'_ur.tex, hhresources_all_nofe_noci_ur.png, hhresources_all_noci.png, 
hhresources_dd_`hpovbin'_ur.tex
***********************/

clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently

*robustness to specification

use "${outdata}/regfinal.dta", clear 

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
	esttab  using "${results}/hhresources_dd_`b'_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
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
	graph export "${results}/hhresources_`b'_nofe_ur.pdf", replace
	
*figure A10 (a) without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "${results}/hhresources_`b'_nofe_noci_ur.png", replace
	
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
	graph export "${results}/earn_`b'.pdf", replace
	
	coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted
	graph export "${results}/hhresources_`b'.png", replace
	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "${results}/hhresources_`b'_noci.png", replace

	esttab  using "${results}/hhresources_`b'.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus FRPL" "Plus WIC"  "Plus SSI"  "Plus SS" "Plus Energy") ///
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
	esttab  using "${results}/hhresources_dd_`b'_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
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
	esttab  using "${results}/hhresources_dd_`b'_99p_ur.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
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
	esttab  using "${results}/hhresources_dd_`b'.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus SS" "Plus SSI" "Plus FRPL" "Plus WIC") ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
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
	

use "${outdata}/regfinal_temp.dta", clear 

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
	graph export "${results}/earn_`b'_templ.png", replace
	
	coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted
	graph export "${results}/hhresources_`b'_templ.png", replace
	
*figure  without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3200(1000)500)) 
	graph export "${results}/hhresources_`b'_noci_templ.png", replace

	esttab  using "${results}/hhresources_`b'_templ.tex", mtitles("Earnings" "Plus UI" "Plus SNAP" "Plus TANF" "Plus FRPL" "Plus WIC" "Plus SSI" "Plus SS" "Plus Energy") ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))

	
eststo clear
}

