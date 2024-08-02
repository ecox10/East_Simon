/*********************
File Name: cntresults.do

This file uses a sample of job losers and non job losers to produce the results for the control group in the paper. This file combines the sample of job losers and never job losers, and then performs the event study analysis for Appendix D. Produces results
in the paper:
"The safety net and job loss: How much insurance do public programs provide?" 

By: Chloe East and David Simon

Inputs: regfinal.dta, control_never.dta 
Outputs: ctr_hhresources_all_noci_ur.png
***********************/

clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently

net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern


***************************************
*** Combine Samples ***
***************************************

use "${outdata}/regfinal.dta", clear 

*before combinging samples gaurentee everyone in the treated group has a distinct uniqueid to control group
drop uniqueid


*now append never losers
gen treat=1
append using "${outdata}/control_never.dta"
drop uniqueid

egen double uniqueid=group(panel suid pnum female)

* fill in as needed for m0 with sm0 for control group. 
replace tenure_1year=tenure_1year2_sm0 if loser==0

gen year=year_m

***************************************
*** Event Study: Dynamics of Income Around Jobloss Income Sources Summed Together (separate from UI generosity), 1 YEAR JOB TENURE - SIPP ***
*** Full Sample ***
*** Adjusted for underreporting ***
***************************************

set more off 

********************
**** Figure D1 ***
********************
foreach b in all  { 
 estimates clear 
 
foreach y in  earn plus_ui plus_fs plus_tanf   plus_frpl plus_wic plus_ssi plus_ss { 
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



esttab  using "${results}/ctr_hhresources_`b'.tex", mtitles("UI" "SNAP" "TANF" "FRPL" "WIC" "SSI" "SS"  "Energy" ) ///
	replace keep( dumspell2 dumspell3 dumspell4 dumspell6  dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18) ///
	se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean njl N, labels ("Mean Y Before Job Loss" "N-Job Losers" "N-Observations") fmt(2 0 0))
	eststo clear


*produces figure: outcome is earnings
coefplot (earn, label("Earnings") color(black)) , ///
vertical keep(dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Change in Dollar Amount") omitted
	graph export "${results}/ctr_earn_`b'_ur.pdf", replace
	
* without confidence intervals	
coefplot (earn, label("Earnings") color(black)) (plus_ui, label("+ UI") color(blue)) (plus_fs, label("+ SNAP") color(red) msymbol(square)) ///
(plus_tanf, label("+ TANF") color(orange) msymbol(triangle)) (plus_frpl, label("+ FRPL") color(midgreen)) ///
(plus_wic , label("+ WIC") color(dkgreen) msymbol(square)) (plus_ssi , label("+ SSI") color(sienna)) /// 
( plus_ss, label("+ SS") color(purple) msymbol(plus)) , ///
vertical keep(dumspell2 dumspell3 dumspell4 dumspell5 dumspell6 dumspell7 dumspell8 dumspell9 dumspell10 dumspell11 dumspell12 dumspell13 dumspell14 dumspell15 dumspell16 dumspell17 dumspell18)  ///
xtitle("Month Relative to Job Loss") ytitle("Dollar Amount") omitted noci  ylabel(-3000(1000)500)  yscale(r(-3000(1000)500)) 
	graph export "${results}/ctr_hhresources_`b'_noci_ur.png", replace


	}
	

