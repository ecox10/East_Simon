/**************************************************************
***** Overview *****
This file uses TAXSIM to estimate monthly EITC values and estimate a difference model showing the response of EITC to job loss. This uses the main analysis sample and creates the results found in Appendix C.
**************************************************************/

clear all
cap clear matrix
cap clear mata
set matsize 10000
set maxvar 30000
set more off, permanently
cap log close

*program inputs
net from "http://www.nber.org/stata"
net describe taxsim35
 net install taxsim35
 
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
			
			
log using "$outputdata/taxsimeitc_des_v3.log", replace	


use "$samples/regfinal.dta", clear 

* new age restruction
sum age_m0
		keep if age_m0>=25 & age_m0<=54  
sum age_m0

			************************************************
***************** 	CREATE INSTRUMENT_SIPP_XX DATASETS  ***********************
			*************************************************
*****
* Step one: Estimate annual wages from monthly in SIPP			

* Generate post indicator 
generate positivity =-1
replace positivity = 1 if month_reljl >= 0 
generate count_pre = positivity<0
generate count_post = positivity>=0
sort uniqueid

by uniqueid: gen count_presum = sum(count_pre) 
by uniqueid: gen count_postsum = sum(count_post)

* Calculate spousal earnings in 1st month of pre and post	
for any earn marsp_earn: replace X=(X*cpi)/237.01

rename marsp_earn spearn
foreach var in earn spearn{

by uniqueid: egen `var'_premean = mean(`var') if count_pre==1
by uniqueid: egen `var'_postmean = mean(`var') if count_post==1 
order uniqueid positivity count_pre count_post earn earn_premean earn_postmean month_reljl

gen `var'ave = `var'_premean if count_pre==1
replace `var'ave = `var'_postmean if count_post==1
}

order count_presum count_postsum
keep if count_presum ==1 | count_postsum ==1 

drop pwages // drops from previous usage of TAXSIM

* annualizes the average earnings over the pre-period
gen pwages = earnave*12 

order uniqueid earnave earn_premean earn_postmean spearnave count_presum count_postsum pwage

gen swages = spearnave*12
replace swages=0 if swages==.
gen year = year_m

*****
* Step two: Prepare other TAXSIM variables and run TAXSIM

drop year_mloss
drop year
gen year= year_m
tab married_sm0, missing
drop mstat
gen mstat = 1 if married_sm0==0
replace mstat=2 if married_sm0==1
drop depx
gen depx= kids_m
gen dep17=kids_m
gen dep18=kids_m
drop if mstat==.


sort statefip_m0
merge m:1 statefip_m0 using "$samples/statecw.dta"
rename state statename
rename statefoi state
drop _merge

*taxsim outputs to current directory, change to samples for now
cd "$samples"

* create taxsimoid
drop taxsimid
gen taxsimid=_n
order uniqueid taxsimid

* Run TAXSIM
preserve 
sort taxsimid

keep taxsimid mstat year pwages swages state  dep18 dep17 depx
taxsim35, full 
use taxsim_out.dta, replace
sort taxsimid

save taxsim_out.dta, replace

* predict EITC
restore

sort taxsimid 

merge taxsimid using taxsim_out.dta
rename v25 fed_eitc
rename v39 state_eitc

sum fed_eitc state_eitc

drop v*

gen toteitc= fed_eitc + state_eitc
replace toteitc = toteitc/12 // make monthly

* deflate total eitc 
for any toteitc fed_eitc state_eitc : replace X=X*237.017/cpi

*save intermediate file for regression 
save "$samples/eitcregs_v4.dta", replace

*****
* Step three: Final prepping of variables for event study 

use "$samples/eitcregs_v4.dta", clear

*for table 1 calculate pre and post job loss
sum toteitc if post==0 [aw=p5wgt_m0]
sum toteitc if post==1 [aw=p5wgt_m0]

*******************************************************************************
*** Difference-in-differences: Estimates of EITC, 1 YEAR JOB TENURE  ***
***
*** Full Sample and Subgroups ***
*******************************************************************************
foreach y in toteitc { 
foreach b in all hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600  hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800 { 
	eststo: xi: xtreg `y' post ///
	i.yearmonth i.age if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
	}

esttab  using "$results/eitc_`y'.tex", mtitles("All" "0 to 100" "100 to 200" "200 to 300" "300 to 400" "400 to 500" "500 to 600" "600 to 700" "700 to 800" "800pl" ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0)) 

	
		esttab  using "$results/eitc_`y'.csv", mtitles("All" "0 to 100" "100 to 200" "200 to 300" "300 to 400" "400 to 500" "500 to 600" "600 to 700" "700 to 800" "800pl" ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0)) 
	eststo clear
}
	
*stats for table 2
sum toteitc if tenure_1year==1 & head_spouse_partner==1 & all==1 & month_reljl<0 & month_reljl~=.
sum toteitc if tenure_1year==1 & head_spouse_partner==1 & all==1 & month_reljl>=0 & month_reljl~=.

log close

