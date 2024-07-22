
*******OVERVIEW********
* This file produces produces summary statistics tables along with figures/graphs that show number of joblosses in sample, etc.  
********************


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
log using "$outputdata/summstats1.log", replace	

		
use "$samples/regfinal.dta", clear 


***************************************
*** Summary Statistics for Draft
***************************************


// overall sample
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if tenure_1year==1 & head_spouse_partner==1 & month_reljl<0 & month_reljl~=. [aw=p5wgt_m0]

// overall sample
sum earn work uhours   uiamt_ur  ss_amt_ur   h_ss_amt_ur  ssi_amt_ur    h_ssi_amt_ur  h_fs_amt_ur  h_tanf_amt_ur  ///
h_wic_amt_ur  frp_lunch_value_ur   priv_hins pub_hins any_hins hearn hinc_ur  hpov_100_ur hpov_200_ur hpov_400_ur age female black hisp college married kids_m0 year_jl ///
if tenure_1year==1 & head_spouse_partner==1 [aw=p5wgt_m0]

// Table 1 column 1: pre-period
sum d_* priv_hins pub_hins any_hins earn uiamt_ur  ss_amt_ur   ssi_amt_ur   h_ssi_amt_ur h_fs_amt_ur h_tanf_amt_ur ///
h_wic_amt_ur frp_lunch_value_ur  hpov_e100_ur hpov_100_ur hpov_t100_ur  ///
 age female black hisp college married kids_m0 ///
if tenure_1year==1 & head_spouse_partner==1 & month_reljl<0 & month_reljl~=. & all==1 [aw=p5wgt_m0]

// Table 1 column 2: post-period
sum d_* earn uiamt_ur  ss_amt_ur   ssi_amt_ur   h_ssi_amt_ur h_fs_amt_ur h_tanf_amt_ur ///
h_wic_amt_ur frp_lunch_value_ur  priv_hins pub_hins any_hins hpov_e100_ur hpov_100_ur hpov_t100_ur ///
 age female black hisp college married kids_m0 ///
if tenure_1year==1 & head_spouse_partner==1 & month_reljl>0 & month_reljl~=. [aw=p5wgt_m0]


// time of job loss
sum age female black hisp college married kids_m0 ///
if tenure_1year==1 & head_spouse_partner==1 & month_reljl==0 & month_reljl~=. [aw=p5wgt_m0]


* Table A4 column 1: demogs and time out of work, ui recipients
preserve
keep if  tenure_1year==1 & head_spouse_partner==1  & age_sm0>=25 & age_sm0<=54  &  uismp==1
sum earn age female hisp white black other lesshs hs somecol college married kids_m0 hpov_100_ur if tenure_1year==1 & head_spouse_partner==1 & month_reljl==-4 [aw=p5wgt_m0]
keep month_reljl work uniqueid p5wgt_m0 tenure_1year
drop if month_reljl<=0
gen time_work = month_reljl if work==1
bysort uniqueid: egen min_time_work = min(time_work)
sum min_time_work [aw=p5wgt_m0]
restore
				

*Table A4 column 2: demogs and time out of work, non ui recipients
preserve
keep if tenure_1year==1 & head_spouse_partner==1  & age_sm0>=25 & age_sm0<=54   & uismp==0
sum earn age female hisp white black other lesshs hs somecol college married kids_m0 hpov_100_ur if tenure_1year==1 & head_spouse_partner==1 & month_reljl==-4  [aw=p5wgt_m0]
keep month_reljl work uniqueid p5wgt_m0 tenure_1year
drop if month_reljl<=0
gen time_work = month_reljl if work==1
bysort uniqueid: egen min_time_work = min(time_work)
sum min_time_work [aw=p5wgt_m0]
restore

***********************************
*Graph A1 and A3 below
********************************


// Figure A1 : graph year of job loss
preserve
gen sum = 1
keep if month_reljl==0 &  tenure_1year==1 & head_spouse_partner==1
collapse (sum) sum [aw=p5wgt_m0] , by(year_jl)
label var sum "Number of Job Losers"
label var year_jl "Year of Job Loss"
twoway (bar sum year_jl), xlabel(1996(4)2013)  xscale(r(1996(4)2013))
graph export "$results/num_by_year_jl.pdf", replace	
restore

// Figure A3: job losers by pre job loss hh income
preserve
keep if tenure_1year==1 & head_spouse_partner==1 & month_reljl==0  
gen sum =1
collapse  (sum) sum  [aw=p5wgt_m0] , by(pov_ratio_ur)
 replace pov_ratio_ur = pov_ratio_ur*100
label var pov_ratio_ur "Poverty Ratio"
sum pov_ratio_ur
label var sum "Number of Job Losers"
twoway (bar sum pov_ratio_ur , barwidth(70))  , ///
xlabel(100(300)900)  xscale(r(100(300)900) )  
graph export "$results/samplesize_bypov_tenure_1year_all.pdf", replace	
restore

// UI elig by pre job loss hh income
preserve
keep if tenure_1year==1 & head_spouse_partner==1 & month_reljl==0  
gen sum = 1
sum elig both_elig   [aw=p5wgt_m0]
collapse (sum) uiamt sum (mean) elig both_elig   [aw=p5wgt_m0] , by(pov_ratio_ur)
 replace pov_ratio_ur = pov_ratio_ur*100
label var pov_ratio_ur "Poverty Ratio"
sum pov_ratio_ur
sum both_elig
bysort pov_ratio_ur: sum elig both_elig
label define poverty 100 "Below 100" 200 "100-199" 300 "200-299" 400 "300-399" 500 "400-499" ///
600 "500-599" 700 "600-699" 800 "700-799" 900 "800+"
label values pov_ratio_ur poverty
tab pov_ratio_ur
graph bar elig both_elig, over(pov_ratio_ur) ///
legend(label(1 "Income Only") label(2 "Income & Self-Emp")) ///
b1title("Poverty Ratio")   
graph export "$results/uielig_bypov_tenure_1year_all.pdf", replace
restore

preserve
keep if tenure_1year==1 & head_spouse_partner==1 & month_reljl==2  
gen sum = 1
collapse (sum) uiamt sum (mean) elig both_elig   [aw=p5wgt_m0] , by(pov_ratio_ur)
 replace pov_ratio_ur = pov_ratio_ur*100
label var pov_ratio_ur "Poverty Ratio"
sum pov_ratio_ur
gen amt_per_elig = uiamt/(sum*both_elig)
sum uiamt sum
label var amt_per_elig "Avg. UI Benefit Amount Among Eligible"
graph bar amt_per_elig, over(pov_ratio_ur) ///
ytitle("Avg. UI Benefit Amount Among Eligible") ///
b1title("Poverty Ratio")   
graph export "$results/uiamt_bypov_tenure_1year_all.pdf", replace	
restore

log close


 log using "$outputdata/tab5.log", replace	


*********************************************************************************
*****THESE NUMBERS ARE BENEFIT AMOUNTS IN in TABLE 1**********************

// average amount received by participants
foreach y in  earn uiamt  h_fs_amt h_tanf_amt frp_lunch_value h_wic_amt ssi_amt ss_amt { 
summ `y'_ur if `y'>0 & `y'~=. & tenure_1year==1 & head_spouse_partner==1 & month_reljl>0 & month_reljl~=. [aw=p5wgt_m0]
}
*****************************************************************************

log close

log using "$outputdata/summstats2.log", replace	

*****************
*FIgure A2 panel (a) Results Below
***********************

// average receipt by hh pov pre/post
preserve
keep if tenure_1year==1 & head_spouse_partner==1 & month_reljl<0 & month_reljl~=. 
sum d_uiamt d_h_fs_amt d_h_tanf_amt pub_hins frp_lunch d_h_wic_amt d_ssi_amt d_ss_amt d_enrgyamt [aw=p5wgt_m0]
collapse (rawsum) all  (mean) d_uiamt d_h_fs_amt d_h_tanf_amt pub_hins d_ss_amt d_ssi_amt frp_lunch d_h_wic_amt d_enrgyamt [aw=p5wgt_m0] , by(pov_ratio_ur)
 label var d_uiamt "% with Any UI Receipt in 2 Years Post Job Loss"
 replace pov_ratio_ur = pov_ratio_ur*100
label var pov_ratio_ur "Poverty Ratio"
twoway (line d_uiamt pov_ratio_ur,  color(blue) lwidth(medthick) yaxis(2)) (line d_h_fs_amt pov_ratio_ur, color(red) lpattern(dash) lwidth(medthick) yaxis(2)) ///
 (line d_h_tanf_amt pov_ratio_ur, color(orange) lpattern(longdash_dot) lwidth(medthick) yaxis(2)) (line frp_lunch pov_ratio_ur, color(midgreen) lpattern(dot) lwidth(medthick) yaxis(2)) (line d_h_wic_amt  pov_ratio_ur, color(dkgreen) lpattern(longdash) lwidth(medthick) yaxis(2)) ///
 (line  d_ssi_amt  pov_ratio_ur, color(sienna) lpattern(dash_dot) lwidth(medthick) yaxis(2)) (line  d_ss_amt pov_ratio_ur, color(purple) lpattern(shortdash) lwidth(medthick) yaxis(2)) ///
  , ///
xlabel(100(300)1000)  xscale(r(100(300)1000) ) ///
legend(label(1 "UI") label(2 "SNAP") label(3 "TANF") label(4 "FRPL") label(5 "WIC")  label(6 "SSI") label(7 "SS")  ) ///
 ytitle("Fraction Received Ever in 12 Months Before Job Loss", axis(2)) 
graph export "$results/mean_eversafnet_bypov_tenure_1year_all_pre.pdf", replace	
twoway (line d_h_fs_amt pov_ratio_ur, color(red) lpattern(dash) yaxis(2)) ///
 (line d_h_tanf_amt pov_ratio_ur, color(orange) lpattern(longdash_dot) lwidth(vthick) yaxis(2)) (line d_ssi_amt pov_ratio_ur, color(midgreen) lpattern(dot) lwidth(thick) yaxis(2)) (line  frp_lunch pov_ratio_ur, color(dkgreen) lpattern(longdash) lwidth(thick) yaxis(2)) ///
 (line  d_h_wic_amt pov_ratio_ur, color(sienna) lpattern(dash_dot) lwidth(medthick) yaxis(2)) (line  d_ss_amt pov_ratio_ur, color(purple) lpattern(shortdash) lwidth(medthick) yaxis(2)) ///
 , ///
xlabel(100(300)1000)  xscale(r(100(300)1000) ) ///
 legend(label(1 "SNAP") label(2 "TANF") label(3 "FRPL") label(4 "WIC")  label(5 "SSI") label(6 "SS")  ) ///
 ytitle("Fraction Ever Received", axis(2)) 
graph export "$results/mean_eversafnet_bypov_tenure_1year_all_pre_noui.pdf", replace	
restore


preserve
keep if tenure_1year==1 & head_spouse_partner==1 
drop post
gen post = (month_reljl>0 & month_reljl~=. )
replace post = . if month_reljl==0
drop if post==.
foreach var in d_uiamt d_h_fs_amt d_h_tanf_amt pub_hins d_ss_amt d_ssi_amt frp_lunch d_h_wic_amt d_enrgyamt {
bysort uniqueid: egen max_`var'_post = mean(`var') if post==1
}
foreach var in d_uiamt d_h_fs_amt d_h_tanf_amt pub_hins d_ss_amt d_ssi_amt frp_lunch d_h_wic_amt d_enrgyamt {
bysort uniqueid: egen max_`var'_pre = mean(`var') if post==0
}
sum max_*

collapse (rawsum) all (mean) max_*_post max_*_pre [aw=p5wgt_m0] , by(pov_ratio_ur )
 replace pov_ratio_ur = pov_ratio_ur*100
label var pov_ratio_ur "Poverty Ratio"
foreach var in d_uiamt d_h_fs_amt d_h_tanf_amt pub_hins d_ss_amt d_ssi_amt frp_lunch d_h_wic_amt d_enrgyamt {
gen diff_`var' = max_`var'_post - max_`var'_pre
}
sum

*****************
* Figure A2 panel (b)
*****************
twoway (line diff_d_uiamt pov_ratio_ur,  color(blue) lwidth(medthick) yaxis(2)) (line diff_d_h_fs_amt pov_ratio_ur, color(red) lpattern(dash) lwidth(medthick) yaxis(2)) ///
 (line diff_d_h_tanf_amt pov_ratio_ur, color(orange) lpattern(longdash_dot) lwidth(medthick) yaxis(2)) (line diff_frp_lunch pov_ratio_ur, color(midgreen)  lpattern(dot) lwidth(medthick) yaxis(2)) (line diff_d_h_wic_amt  pov_ratio_ur, color(dkgreen) lpattern(longdash) lwidth(medthick) yaxis(2)) ///
 (line   diff_d_ssi_amt pov_ratio_ur , color(sienna) lpattern(dash_dot) lwidth(medthick) yaxis(2)) (line  diff_d_ss_amt pov_ratio_ur, color(purple) lpattern(shortdash) lwidth(medthick) yaxis(2)) ///
 , ///
xlabel(100(300)1000)  xscale(r(100(300)1000) ) ///
legend(label(1 "UI") label(2 "SNAP") label(3 "TANF") label(4 "FRPL") label(5 "WIC")  label(6 "SSI") label(7 "SS")   ) ///
 ytitle("Change in Receipt From Pre to Post Job Loss", axis(2)) 
graph export "$results/mean_changesafnet_bypov_tenure_1year_all.pdf", replace		
restore


*******END figure A2 results*************

*** Tab sample size by month relative to job loss
preserve
keep if tenure_1year==1 & head_spouse_partner==1  
gen sum =1
collapse  (sum) sum  [aw=p5wgt_m0] , by(month_reljl)
label var sum "Num Job Losers"
label var month_reljl "Month Relative to Job Loss"
twoway (bar sum month_reljl  )  , ///
xlabel(-12(6)24)  xscale(r(-12(6)24) )  legend(label(1 "Num Job Losers")) 
graph export "$results/samplesize_bymonth_reljl_tenure_1year_all.pdf", replace
restore

*** Average Duration of Out of Work 
preserve
keep if  head_spouse_partner==1 
keep month_reljl work uniqueid p5wgt_m0 tenure_1year
drop if month_reljl<=0
gen time_work = month_reljl if work==1
bysort uniqueid: egen min_time_work = min(time_work)
sum [aw=p5wgt_m0]
sum if tenure_1year==1 [aw=p5wgt_m0]
restore


log close
