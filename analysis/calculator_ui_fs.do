*=================================
*  UI and SNAP Calculators 
* Updated by EC: 4/5/2024
*=================================
* This file uses the final reg dataset created in 01h_finalcleaning.do to calculate estimated 
* UI and SNAP benefit amounts to assess policy implications. 

net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern

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

*=================================
*  UI Calculator 
*=================================

use "$samples/regfinal.dta", clear 

* calculate repeat job losers
gen repeat_loser = loss if loss > 0 & month_reljl > 0 // only keeps the 1's after 1st job loss (will be 1's and .'s)
sort uniqueid repeat_loser // sorts by uniqueid and puts 1's indicating a second job loss first
bysort uniqueid: replace repeat_loser = repeat_loser[1] // replaces all values for a uniqueid with 1st sorted value (1 if they had a second job loss)

* Calculate who had UI after 99 weeks (this is about 23 months)
gen ui_weeks_99 =  1 if uiamt_ur > 0 & month_reljl == 23
sort uniqueid ui_weeks_99 
bysort uniqueid: replace ui_weeks_99 = ui_weeks_99[1] 

* calculate eligible at -1
gen elig_m0 = elig if month_reljl == -1
sort uniqueid elig_m0
bysort uniqueid: replace elig_m0 = elig_m0[1] 

* find state and month of jobloss 
gen fips_m0 = statefip_m if month_reljl == 0
sort uniqueid fips_m0
bysort uniqueid: replace fips_m0 = fips_m0[1]
* need to add year_m0 for the obs I created
bysort uniqueid: replace year_m0 = year_m0[1] 

* Add weeks of UI benefit data 
preserve 
use "$dir/child SIPP longterm/analysis/dofiles/jobloss/Aux data and setupcode/Safety Net Calculators/Rothstein_Valetta_UI_Weeks_Calc/eui_state_08-14.dta", clear
rename fips fips_m0 
rename year year_m0
rename month month_m0
tempfile eui
save `eui', replace
restore 

merge m:1 fips_m0 year_m0 month_m0 using `eui', force
drop if _merge == 2 // don't drop non merges in master, we want before the year 2000
drop _merge

* calculate total months ui relative to jobloss
gen ui_months = ceil(ui_weeks/4.28) 
replace ui_months = 6 if year_m0 < 2000 

* generate monthly UI 
* calculate wba at event time 
gen wba_m0 = wba if month_reljl == -1 
sort uniqueid wba_m0 // replaces all values with a uniqueid with the value at -1 event time
bysort uniqueid: replace wba_m0 = wba_m0[1] if month_reljl >= 1 & month_reljl < ui_months + 1
replace wba_m0 = 0 if month_reljl < 1 | month_reljl >= ui_months + 1 // adding lag to account for fact that people get UI at et 1

* generate monthly benefit amount
gen mba_m0 = (wba_m0 / 7) * 31 if month_m0 == 1 | month_m0 == 3 | month_m0 == 5 | month_m0 == 7 | month_m0 == 8 | month_m0 == 10 | month_m0 == 12 
replace mba_m0 = (wba_m0 / 7) * 30 if month_m0 == 4 | month_m0 == 6 | month_m0 == 9 | month_m0 == 11
replace mba_m0 = (wba_m0 / 7) * 29 if month_m0 == 2

* define calculated UI (if they are eligible and not self employed)
gen sim_ui = 0
replace sim_ui = mba_m0 if elig_m0 == 1 & self_employed_pre == 0
replace sim_ui = 0 if elig_m0 == 0 | self_employed_pre == 1 

* get calculated UI without eligibility restrictions
gen sim_ui_allelig = mba_m0

* generate some new post variables 
gen post0=month_reljl>0 & month_reljl <= 2 & month_reljl!=.
replace post0=. if month_reljl==.

gen post1=month_reljl>2 & month_reljl < 22 & month_reljl!=.
replace post1=. if month_reljl==.

gen post2=month_reljl>=22 & month_reljl!=.
replace post2=. if month_reljl==.

*** some tabs / counts ****
replace repeat_loser = 0 if repeat_loser != 1
replace ui_weeks_99 = 0 if ui_weeks_99 != 1

unique uniqueid if repeat_loser == 1 & ui_weeks_99 == 1
unique uniqueid if repeat_loser == 1

tab repeat_loser if month_reljl == 0 // adding "if month_reljl == 0" selects job losers (note this number matches # unique joblosers)
tab repeat_loser if ui_weeks_99 == 1 & month_reljl == 0	

**************************	
* Figure 7 panel (b) - results in tex table
***************************
foreach b in  all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur  { 
 estimates clear 
	eststo clear
foreach y in earn uiamt_ur sim_ui sim_ui_allelig h_fs_amt_ur h_tanf_amt_ur ss_amt_ur ssi_amt_ur frp_lunch_value_ur h_wic_amt_ur { 
	eststo: xi: xtreg `y' post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_sim_UI_ur.tex", mtitles( "Earnings" "UI" "Sim UI" "Sim UI - all eligible" "SNAP" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}	
	
* calculated UI results - first 2 months and last 2 months
foreach b in  all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur  { 
 estimates clear 
	eststo clear
foreach y in earn uiamt_ur sim_ui sim_ui_allelig h_fs_amt_ur h_tanf_amt_ur ss_amt_ur ssi_amt_ur frp_lunch_value_ur h_wic_amt_ur { 
	eststo: xi: xtreg `y' post0 post1 post2 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=.
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_sim_UI_2mo_ur.tex", mtitles( "Earnings" "UI" "Sim UI" "Sim UI - all eligible" "SNAP" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post0) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))	
	
	esttab  using "$results/hhresources_dd_`b'_sim_UI_22mo_ur.tex", mtitles( "Earnings" "UI" "Sim UI" "Sim UI - all eligible" "SNAP" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post2) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}	
	
	
*=================================
*  SNAP Calculator 
*=================================
*** calculate SNAP amounts 
* modified procedure from https://www.cbpp.org/research/food-assistance/a-quick-guide-to-snap-eligibility-and-benefits 
* with adjustments to use benefit amounts from Tara Watson at brookings

use "$samples/regfinal.dta", clear 

* step 1: estimate snap eligibility using the poverty ratio
gen fs_eligible = (hinc<1.3*hpov)

* step 2: merge in brookings snap data by year and family size 
	* continental us
preserve 

import excel "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023.xlsx", clear firstrow ///
sheet("snap continental us")
rename snapfiscalyearfiscalyearX year_m 
rename familysize hnp

save "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023.dta", replace 
restore 

merge m:1 year_m hnp using "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023.dta"
drop if _merge != 3

	* ak and hi
preserve 

import excel "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023.xlsx", clear firstrow ///
sheet("snap ak hi")
rename snapfiscalyearfiscalyearX year_m 
rename familysize hnp
rename stfip statefip_m
rename standarddeduction standarddeduction_akhi

* drop 1986 duplicate - this year isn't in the sipp data so this shouldn't matter 
duplicates drop year_m hnp statefip_m, force

save "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023_akhi.dta", replace 
restore 

drop _merge
merge m:1 year_m hnp statefip_m using "/Users/elizabeth/Dropbox/Other Stuff for Chloe/Jobloss/snap_parameters_1980-2023_updated2023_akhi.dta"


* step 3: subtract standard adjustment from gross income
gen inc_st_deduction = hinc - standarddeduction if statefip_m != 2 & statefip_m != 15
replace inc_st_deduction = hinc-standarddeduction_akhi if statefip_m == 2 | statefip_m == 15

* subtract earnings deduction (20% of earnings)
gen earn_deduc = 0.2*hearn
gen inc_st_earn_deduc = inc_st_deduction - earn_deduc

* step 4: subtract shelter deduction (this is net income)
* https://www.fns.usda.gov/snap/allotment/COLA
gen shelter_deduction = 388 if year_m <= 2005 & statefip_m != 2 & statefip_m != 15 // 2005 is earliest year
replace shelter_deduction = 620 if year_m <= 2005 & statefip_m == 2 
replace shelter_deduction = 523 if year_m <= 2005 & statefip_m == 15

replace shelter_deduction = 400 if year_m == 2006 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 640 if year_m == 2006 & statefip_m == 2 
replace shelter_deduction = 539 if year_m == 2006 & statefip_m == 15

replace shelter_deduction = 417 if year_m == 2007 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 666 if year_m == 2007 & statefip_m == 2 
replace shelter_deduction = 562 if year_m == 2007 & statefip_m == 15

replace shelter_deduction = 431 if year_m == 2008 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 689 if year_m == 2008 & statefip_m == 2 
replace shelter_deduction = 581 if year_m == 2008 & statefip_m == 15

replace shelter_deduction = 446 if year_m == 2009 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 713 if year_m == 2009 & statefip_m == 2 
replace shelter_deduction = 601 if year_m == 2009 & statefip_m == 15

replace shelter_deduction = 459 if year_m == 2010 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 733 if year_m == 2010 & statefip_m == 2 
replace shelter_deduction = 618 if year_m == 2010 & statefip_m == 15

replace shelter_deduction = 458 if year_m == 2011 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 732 if year_m == 2011 & statefip_m == 2 
replace shelter_deduction = 617 if year_m == 2011 & statefip_m == 15

replace shelter_deduction = 459 if year_m == 2012 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 734 if year_m == 2012 & statefip_m == 2 
replace shelter_deduction = 619 if year_m == 2012 & statefip_m == 15

replace shelter_deduction = 469 if year_m == 2013 & statefip_m != 2 & statefip_m != 15
replace shelter_deduction = 749 if year_m == 2013 & statefip_m == 2 
replace shelter_deduction = 632 if year_m == 2013 & statefip_m == 15

gen net_income = inc_st_earn_deduc - shelter_deduction

* step 5: calculate family's expected contribution to food 
gen e_fam_cont = net_income*0.3
replace e_fam_cont = 0 if e_fam_cont < 0

* step 6: get estimated SNAP benefit amounts 
gen sim_snap = 0
replace sim_snap = maximumfoodstampbenefit - e_fam_cont if fs_eligible == 1 
replace sim_snap = maximumfoodstampbenefit if sim_snap > maximumfoodstampbenefit & fs_eligible == 1
replace sim_snap = minimumfoodstampbenefit if sim_snap < minimumfoodstampbenefit & fs_eligible == 1 & minimumfoodstampbenefit != .
replace sim_snap = 0 if sim_snap < 0

* assign max benefits 
gen fs_max = 0
replace fs_max = maximumfoodstampbenefit if fs_eligible == 1 & post == 1
replace fs_max = sim_snap if fs_eligible == 1 & post != 1
   
 * generate some new post variables 
gen post0=month_reljl>0 & month_reljl <= 2 & month_reljl!=.
replace post0=. if month_reljl==.

gen post1=month_reljl>2 & month_reljl < 22 & month_reljl!=.
replace post1=. if month_reljl==.

gen post2=month_reljl>=22 & month_reljl!=.
replace post2=. if month_reljl==.

**************************	
* Figure 7 panel (b) - tex table 
**************************	
foreach b in all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur { 
 estimates clear 
	eststo clear
foreach y in earn h_fs_amt_ur sim_snap fs_max uiamt_ur h_tanf_amt_ur ss_amt_ur ssi_amt_ur frp_lunch_value_ur h_wic_amt_ur { 
	eststo: xi: xtreg `y' post ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=. 
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_sim_SNAP_ur.tex", mtitles("Earnings" "SNAP" "Sim SNAP" "Sim SNAP - max benefits" "UI" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post ) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear	
	}	
	
* calculated SNAP results - first 2 months and last 2 months
foreach b in all hpov_sm0_100_ur hpov_sm0_100200_ur hpov_sm0_200300_ur hpov_sm0_300400_ur hpov_sm0_400500_ur hpov_sm0_500600_ur hpov_sm0_600700_ur hpov_sm0_700800_ur hpov_sm0_800pl_ur { 
 estimates clear 
	eststo clear
foreach y in earn h_fs_amt_ur sim_snap fs_max uiamt_ur h_tanf_amt_ur ss_amt_ur ssi_amt_ur frp_lunch_value_ur h_wic_amt_ur { 
	eststo: xi: xtreg `y' post0 post1 post2 ///
	i.age i.yearmonth if tenure_1year==1 & head_spouse_partner==1 & `b'==1 [pw=p5wgt_m0], fe vce(cluster uniqueid)	
	sum `y' if tenure_1year==1 & head_spouse_partner==1 & `b'==1 & month_reljl<0 & month_reljl~=. 
	estadd scalar ymean = r(mean)
}
	esttab  using "$results/hhresources_dd_`b'_sim_SNAP_2mo_ur.tex", mtitles("Earnings" "SNAP" "Sim SNAP" "Sim SNAP - max benefits" "UI" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post0 ) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	
	esttab  using "$results/hhresources_dd_`b'_sim_SNAP_22mo_ur.tex", mtitles("Earnings" "SNAP" "Sim SNAP" "Sim SNAP - max benefits" "UI" "TANF" "SS" "SSI" "FRPL" "WIC"  "Energy"  ) ///
	replace keep( post2 ) se(3) b(3) label star(* 0.10 ** 0.05 *** 0.01) nonum nonotes noconstant ///
	stats(ymean N, labels ("Mean Y Before Job Loss" "Observations") fmt(2 0))
	eststo clear
	}
	
