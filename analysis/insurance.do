/*********************
File Name: insurance.do

This produces insurance results here for all job losers, adults, and children. Produces results
in the paper:
"The safety net and job loss: How much insurance do public programs provide?" 

By: Chloe East and David Simon

Inputs: regfinal.dta
Outputs: loserins_all_noci.png, kidins_all_noci.png, Adultins_all_noci.png, hearesults_ddpov_`hpovbin'_ur.csv (underlying numbers for DiD figures)
***********************/

clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently

use "${outdata}/regfinal.dta", clear 

	
*******************************************************************************
*** Event Study: Dynamics of health insurance , 1 YEAR JOB TENURE - SIPP ***
*** 
*** Full Sample and Subgroups ***
*******************************************************************************

*job loser insurance variables:
*	any children hins: anyk_any_hins, anyk_pub_hins, anyk_priv_hins
*	any adult hins: anyA_any_hins anyA_priv_hins anyA_pub_hins
for any any_hins_ur priv_hins pub_hins_ur anyA_any_hins_ur anyA_pub_hins_ur anyA_priv_hins anyk_any_hins_ur anyk_pub_hins_ur anyk_priv_hins: replace X =X*100

********************************************
* Figure 8 panel (a) - event study, change in insurance coverage, job loser.
********************************************
foreach b in all  { 
 estimates clear 
 
foreach y in any_hins_ur pub_hins_ur priv_hins  { 

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


coefplot (any_hins_ur, label("Any Insurance") color(black))  (pub_hins_ur, label("Any Public Insurance") color(blue) msymbol(square)) (priv_hins, label("Any Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Insurance Coverage") yscale(range(0 10)) ylabel(-20(5)10) omitted
	graph export "${results}/loserins_`b'.png", replace

coefplot (any_hins_ur, label("Any Insurance") color(black))  (pub_hins_ur, label("Any Public Insurance") color(blue) msymbol(square)) (priv_hins, label("Any Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Coverage") yscale(range(0 10)) ylabel(-20(5)10) omitted noci
	graph export "${results}/loserins_`b'_noci.png", replace
	
}

********************************************
* Figure A11 panel (a) - event study, change in insurance coverage, any adult in hh.
********************************************

foreach b in all  { 
 
foreach y in anyA_any_hins_ur anyA_pub_hins_ur anyA_priv_hins  { 


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
	
coefplot (anyA_any_hins_ur, label("Any Adult Insured") color(black)) (anyA_pub_hins_ur, label("Any Adult Public Insurance") color(blue) msymbol(square)) (anyA_priv_hins, label("Any Adult Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Coverage, Any Adult") omitted yscale(range(0 10)) ylabel(-20(5)10)
	graph export "${results}/Adultins_`b'.png", replace
	
coefplot (anyA_any_hins_ur, label("Any Adult Insured") color(black)) (anyA_pub_hins_ur, label("Any Adult Public Insurance") color(blue) msymbol(square)) (anyA_priv_hins, label("Any Adult Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Coverage, Any Adult") omitted noci yscale(range(0 10)) ylabel(-20(5)10)
	graph export "${results}/Adultins_`b'_noci.png", replace

}

********************************************
* Figure A11 panel (b) - event study, change in insurance coverage, any Child in hh.
********************************************

foreach b in all  { 
 
foreach y in anyk_any_hins_ur anyk_pub_hins_ur anyk_priv_hins   { 


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
coefplot (anyk_any_hins_ur, label("Any Kid Insured") color(black)) (anyk_pub_hins_ur, label("Any Kid Public Insurance") color(blue) msymbol(square)) (anyk_priv_hins, label("Any Kid Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Coverage, Any Kid") omitted yscale(range(0 10)) ylabel(-20(5)10)
	graph export "${results}/kidins_`b'.png", replace
	
coefplot (anyk_any_hins_ur, label("Any Kid Insured") color(black)) (anyk_pub_hins_ur, label("Any Kid Public Insurance") color(blue) msymbol(square)) (anyk_priv_hins, label("Any Kid Private Insurance") color(red) msymbol(T)), ///
vertical keep( dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Percentage Point Change in Coverage, Any Kid") omitted noci yscale(range(0 10)) ylabel(-20(5)10)
	graph export "${results}/kidins_`b'_noci.png", replace
}

	*This produces a table version of figures 8 & A11, which is table A6
	esttab  using "${results}/insurance_all.tex", 	mgroups("Job Loser" "All Adults" "All Kids", pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span erepeat(\cmidrule(lr){@span})) ///
	mtitles("Any" "Public" "Private" "Any" "Public" "Private" "Any" "Public" "Private") ///
	replace keep(  dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0)) 

	
*******************************************************************************
*** Difference-in-differences: Estimates of Health Insurance, 1 YEAR JOB TENURE - SIPP ***
***
*** Full Sample and Subgroups ***
*******************************************************************************
	
********************************************	
**Figure 8 panel (b) and A11 panel (c) (d) - now health insurance by poverty rate: any adult / any children
********************************************

foreach b in all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur {
 estimates clear 
foreach y in    priv_hins pub_hins_ur anyA_priv_hins anyA_pub_hins_ur anyk_priv_hins anyk_pub_hins_ur  { /* priv_hins pub_hins any_hins anyk_priv_hins anyA_priv_hins*/
	eststo: xi: xtreg `y' post ///
	i.age i.yearmonth  if tenure_1year==1 & head_spouse_partner==1 & `b'==1  [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	}
	esttab  using "${results}/hearesults_ddpov_`b'_ur.csv", mtitles("any private" "any public"   "any adult private" "any adult public" "any kid private" "any kid public" ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear
	
	}
	
	
	

	