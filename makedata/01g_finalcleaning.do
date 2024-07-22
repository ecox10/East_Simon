
*******OVERVIEW********
*EAST and Simon: how well insured are job losers
*11/29/2023
*All final cleaning before results, generates poverty ratio bins, adjusts for under-reporting, and creates outcome variables for event study.
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
log using "$outputdata/finalcleaning.log", replace	

use "$samples/sipp_reg.dta", clear 

* limit age at time of jobloss to 25-54
keep if age_m0>=25 & age_m0<=54  


***************************************
** Gen variables that sum sources of income together 
** No adjustment for under-reporting
***************************************
* own earnings + ui   
gen plus_ui = earn + uiamt
* own earnings + ui  + h_fs_amt 
gen plus_fs = plus_ui  + h_fs_amt
* own earnings + ui  + h_tanf_amt 
gen plus_tanf = plus_fs  + h_tanf_amt  
* own earnings + ui + h_tanf_amt + h_fs_amt   + frp_lunch_value  
gen plus_frpl = h_tanf_amt + frp_lunch_value  
* own earnings + ui + h_tanf_amt + h_fs_amt  + frp_lunch_value + h_wic_amt 
gen plus_wic = plus_frpl +  wic_amt
* own earnings + ui + h_tanf_amt + h_fs_amt  + frp_lunch_value + h_wic_amt + h_ssi_amt
gen plus_ssi = plus_wic + ssi_amt    
* own earnings + ui + h_tanf_amt + h_fs_amt + frp_lunch_value + h_wic_amt + h_ssi_amt + h_ss_amt  
gen plus_ss = plus_ssi + ss_amt
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + h_ssi_amt + frp_lunch_value + h_wic_amt + energy 
gen plus_energy = plus_ss + enrgyamt 
* own earnings + sevrpay   
gen plus_sevrpay = earn + sevrpay  
   
** After Transfer Income and Poverty Variable: total cash income plus hh FS amt plus HH FRPL value plus HH energy assistance amount plus WIC amt
gen aftertrans_inc = hinc + h_fs_amt + frp_lunch_value + enrgyamt + h_wic_amt
mdesc aftertrans_inc  hinc  h_fs_amt frp_lunch_value enrgyamt
gen earn_ui = hearn + uiamt 
gen earn_transferinc = hearn + uiamt + h_fs_amt + h_tanf_amt+ h_ss_amt + h_ssi_amt + frp_lunch_value + enrgyamt + h_wic_amt

* generate poverty bins
gen hpov_t100=(aftertrans_inc<hpov)
gen hpov_t200=(aftertrans_inc<(2*hpov))
gen hpov_t400=(aftertrans_inc<(4*hpov))
for any hpov_t100 hpov_t200 hpov_t400: replace X = . if aftertrans_inc==. | hpov==.
	 
gen hpov_e100=(hearn<hpov)
gen hpov_e200=(hearn<(2*hpov))
gen hpov_e400=(hearn<(4*hpov))
for any hpov_e100 hpov_e200 hpov_e400: replace X = . if hearn==. | hpov==.

gen hpov_u100=(earn_ui<hpov)
gen hpov_transferinc100=(earn_transferinc<hpov)
	 
for any hpov_e100 hpov_e200 hpov_e400 hpov100 hpov200 hpov400 hpov_t100 hpov_t200 hpov_t400: replace X = X*100

***************************************
** Earnings, HH Income Percentiles
***************************************
foreach var in hinc earn {
forvalues n = 10(10)90 {
egen `var'_p`n' = pctile(`var'_sm0)  if tenure_1year==1 & head_spouse_partner==1, p(`n')
}
egen `var'_p0 = min(earn_sm0)  if tenure_1year==1 & head_spouse_partner==1 
egen `var'_p100 = max(earn_sm0)  if tenure_1year==1 & head_spouse_partner==1 

gen `var'_pctiles = . 
forvalues n = 10(10)100 {
local n2 = `n'/10
local n3 = `n' - 10
replace `var'_pctiles = `n2' if `var'_sm0>=`var'_p`n3' & `var'_sm0<`var'_p`n' & `var'_sm0~=.
}
replace `var'_pctiles = 10 if `var'_sm0==`var'_p100
tab `var'_pctiles  if tenure_1year==1 & head_spouse_partner==1 , m
mdesc `var'_sm0  if tenure_1year==1 & head_spouse_partner==1

sum `var'_sm0 `var'_p20 `var'_p40 `var'_p60 `var'_p80 `var'_p100

gen `var'_quintiles = 1 if  `var'_sm0<`var'_p20 & `var'_sm0~=. & tenure_1year==1 & head_spouse_partner==1
replace `var'_quintiles = 2 if  `var'_sm0>=`var'_p20 & `var'_sm0<`var'_p40 & `var'_sm0~=.  & tenure_1year==1 & head_spouse_partner==1
replace `var'_quintiles = 3 if  `var'_sm0>=`var'_p40 & `var'_sm0<`var'_p60 & `var'_sm0~=.  & tenure_1year==1 & head_spouse_partner==1
replace `var'_quintiles = 4 if  `var'_sm0>=`var'_p60 & `var'_sm0<`var'_p80 & `var'_sm0~=.  & tenure_1year==1 & head_spouse_partner==1
replace `var'_quintiles = 5 if  `var'_sm0>=`var'_p80 & `var'_sm0<=`var'_p100 & `var'_sm0~=.  & tenure_1year==1 & head_spouse_partner==1
tab `var'_quintiles, gen(`var'_quintiles)
sum `var'_quintiles*
}

gen any_earn = (earn>0 & earn~=.)

***************************************
** HH Inc/Pov Ratio (neither of these are cpi adjusted)
***************************************
gen hpov_sm0_100 = (hinc_sm0<hpov_sm0  )
gen hpov_sm0_100200 = (hinc_sm0>=hpov_sm0 & hinc_sm0<(2*hpov_sm0)  )
gen hpov_sm0_200300 = (hinc_sm0>=(2*hpov_sm0) & hinc_sm0<(3*hpov_sm0) )
gen hpov_sm0_300400 = (hinc_sm0>=(3*hpov_sm0) & hinc_sm0<(4*hpov_sm0) )
gen hpov_sm0_400500 = (hinc_sm0>=(4*hpov_sm0) & hinc_sm0<(5*hpov_sm0) )
gen hpov_sm0_500600 = (hinc_sm0>=(5*hpov_sm0) & hinc_sm0<(6*hpov_sm0) )
gen hpov_sm0_600700 = (hinc_sm0>=(6*hpov_sm0) & hinc_sm0<(7*hpov_sm0)  )
gen hpov_sm0_700800 = (hinc_sm0>=(7*hpov_sm0) & hinc_sm0<(8*hpov_sm0)  )
gen hpov_sm0_800 = (hinc_sm0>=(8*hpov_sm0)  )
for any hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800: replace X = . if hpov_sm0==.
gen pov_ratio= 1 if hpov_sm0_100==1
replace pov_ratio=2 if hpov_sm0_100200==1
replace pov_ratio=3 if hpov_sm0_200300==1
replace pov_ratio=4 if hpov_sm0_300400==1
replace pov_ratio=5 if hpov_sm0_400500==1
replace pov_ratio=6 if hpov_sm0_500600==1
replace pov_ratio=7 if hpov_sm0_600700==1
replace pov_ratio=8 if hpov_sm0_700800==1
replace pov_ratio=9 if hpov_sm0_800==1

***************************************
** Get quintiles/pov for spouse
***************************************
foreach var in hinc earn {
forvalues q = 1/5 {
gen `var'_quintiles`q'_s = `var'_quintiles`q' if married_sm0==0
gen `var'_quintiles`q'_m = `var'_quintiles`q' if married_sm0==1
}
}
for any hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800: gen X_s = X if married_sm0==0
for any hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800: gen X_m = X if married_sm0==1


***************************************
** Define recessions
***************************************
gen month_m0 = imonth if month_reljl == 0
sort uniqueid month_m0 
bysort uniqueid: replace month_m0 = month_m0[1]

gen layoff01 = 1 if year_m0 == 2001 & month_m0 >= 3 & month_m0 <= 11 
gen layoff0809 = 1 if (year_m0 == 2007 & month_m0 == 12) | year_m0 == 2008 | (year_m0 == 2009 & month_m0 <= 6)

gen recession = 0 
replace recession = 1 if layoff01 == 1 | layoff0809 == 1
gen notrecession = 0 
replace notrecession = 1 if recession != 1


***************************************
** Get UI and eligibility
***************************************
// code up eligibility variables 
gen nself_employed_pre=(self_employed_pre==0)
sum elig nself_employed_pre if month_reljl==0 [aw=p5wgt_m0]
tab elig nself_employed_pre if month_reljl==0 [aw=p5wgt_m0], m
gen both_elig =0
replace both_elig =1 if elig==1 & nself_employed_pre==1

// if received UI before job loss 
gen flagpreui = (uiamt>0 & month_reljl<0)
bysort uniqueid: egen max_flagpreui=max(flagpreui)


// rates of eligibility by household poverty
foreach b in all hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800 { 
sum elig both_elig if month_reljl==0 & `b'==1 & tenure_1year==1  & head_spouse_partner==1 [aw=p5wgt_m0]
}

***************************************
*** Adjust for under-reporting ***
***************************************
gen d_uiamt_ur = d_uiamt/ui_rr_dol
gen d_h_fs_amt_ur = d_h_fs_amt/snap_rr_p
gen d_h_tanf_amt_ur = d_h_tanf_amt/tanf_rr_p
gen d_ss_amt_ur = d_ss_amt/ssdi_rr_p
gen d_ssi_amt_ur = d_ssi_amt/ssi_rr_p
gen d_frp_lunch_value_ur = d_frp_lunch_value/frpl_rr_p
gen d_h_wic_amt_ur = d_h_wic_amt/wic_rr_p

gen uiamt_ur=uiamt/ui_rr_dol
gen h_fs_amt_ur=h_fs_amt/snap_rr_dol
gen h_tanf_amt_ur=h_tanf_amt/tanf_rr_dol
gen ss_amt_ur=ss_amt/ssdi_rr_dol
gen ssi_amt_ur=ssi_amt/ssi_rr_dol
gen h_ss_amt_ur=h_ss_amt/ssdi_rr_dol
gen h_ssi_amt_ur=h_ssi_amt/ssi_rr_dol
gen frp_lunch_value_ur=frp_lunch_value/frpl_rr_p
gen h_wic_amt_ur=h_wic_amt/wic_rr_p

gen uiamt_sm0_ur=uiamt_sm0/ui_rr_dol
gen h_tanf_amt_sm0_ur=h_tanf_amt_sm0/tanf_rr_dol
gen h_ss_amt_sm0_ur=h_ss_amt_sm0/ssdi_rr_dol
gen h_ssi_amt_sm0_ur=h_ssi_amt_sm0/ssi_rr_dol

gen pub_hins_rr = 0.89 if year_m<2002
replace pub_hins_rr = 0.80 if year_m>=2002
 
for any pub_hins anyA_pub_hins anyk_pub_hins: gen X_ur = X/pub_hins_rr 

gen any_hins_ur = any_hins - pub_hins + pub_hins_ur
gen anyA_any_hins_ur = anyA_any_hins - anyA_pub_hins + anyA_pub_hins_ur
gen anyk_any_hins_ur = anyk_any_hins - anyk_pub_hins + anyk_pub_hins_ur

***************************************
** Gen variables that sum sources of income together 
** Adjusted for under-reporting
***************************************
gen earn_ur =earn
* own earnings + ui   
gen plus_ui_ur = earn + uiamt_ur
* own earnings + ui  + h_fs_amt 
gen plus_fs_ur = plus_ui_ur  + h_fs_amt_ur
* own earnings + ui  + h_tanf_amt 
gen plus_tanf_ur = plus_fs_ur  + h_tanf_amt_ur 
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt  + frp_lunch_value  
gen plus_frpl_ur = plus_tanf_ur + frp_lunch_value_ur  
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt  + frp_lunch_value + h_wic_amt 
gen plus_wic_ur = plus_frpl_ur + h_wic_amt_ur 
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + frp_lunch_value + h_wic_amt  + h_ssi_amt 
gen plus_ssi_ur = plus_wic_ur + ssi_amt_ur   
* own earnings + ui + h_tanf_amt + h_fs_amt  + h_ss_amt + h_ssi_amt + frp_lunch_value + h_wic_amt + h_ss_amt  
gen plus_ss_ur = plus_ssi_ur + ss_amt_ur  
   
 
** Household Cash Income Adjusted for Under-reporting
gen hinc_ur = hinc-(uiamt + h_tanf_amt + h_ss_amt + h_ssi_amt) +(uiamt_ur + h_tanf_amt_ur + h_ss_amt_ur + h_ssi_amt_ur)
sum hinc hinc_ur

gen hinc_sm0_ur = hinc_sm0-(uiamt_sm0 + h_tanf_amt_sm0 + h_ss_amt_sm0 + h_ssi_amt_sm0) +(uiamt_sm0_ur + h_tanf_amt_sm0_ur + h_ss_amt_sm0_ur + h_ssi_amt_sm0_ur)
sum hinc_sm0 hinc_sm0_ur

** After Transfer Income and Poverty Variable (adjusted for under-reporting: total cash income plus hh FS amt plus HH FRPL value plus HH energy assistance amount plus WIC amt
gen aftertrans_inc_ur = hinc_ur + h_fs_amt_ur + frp_lunch_value_ur  + h_wic_amt_ur 
gen earn_ui_ur = hearn + uiamt_ur 
gen earn_transferinc_ur = hearn + uiamt_ur + h_fs_amt_ur + h_tanf_amt_ur+ h_ss_amt_ur + h_ssi_amt_ur + frp_lunch_value_ur  + h_wic_amt_ur

gen hpov_t100_ur=(aftertrans_inc_ur<hpov)
gen hpov_t200_ur=(aftertrans_inc_ur<(2*hpov))
gen hpov_t400_ur=(aftertrans_inc_ur<(4*hpov))
for any hpov_t100_ur hpov_t200_ur hpov_t400_ur: replace X = . if aftertrans_inc_ur==. | hpov==.
	 
gen hpov_e100_ur=(hearn<hpov)
gen hpov_e200_ur=(hearn<(2*hpov))
gen hpov_e400_ur=(hearn<(4*hpov))
for any hpov_e100_ur hpov_e200_ur hpov_e400_ur: replace X = . if hearn==. | hpov==.

gen hpov_100_ur=(hinc_ur<hpov)
gen hpov_200_ur=(hinc_ur<(2*hpov))
gen hpov_400_ur=(hinc_ur<(4*hpov))
for any hpov_100_ur hpov_200_ur hpov_400_ur: replace X = . if hinc_ur==. | hpov==.

gen hpov_u100_ur=(earn_ui_ur<hpov)
gen hpov_transferinc100_ur=(earn_transferinc_ur<hpov)
	 
for any hpov_e100_ur hpov_e200_ur hpov_e400_ur hpov_100_ur hpov_200_ur hpov_400_ur hpov_t100_ur hpov_t200_ur hpov_t400_ur hpov_u100_ur hpov_transferinc100_ur: replace X = X*100

***************************************
** HH Inc/Pov Ratio - Adjusted for under-reporting
***************************************
gen hpov_sm0_100_ur = (hinc_sm0_ur<hpov_sm0  )
gen hpov_sm0_100200_ur = (hinc_sm0_ur>=hpov_sm0 & hinc_sm0_ur<(2*hpov_sm0)  )
gen hpov_sm0_200300_ur = (hinc_sm0_ur>=(2*hpov_sm0) & hinc_sm0_ur<(3*hpov_sm0) )
gen hpov_sm0_300400_ur = (hinc_sm0_ur>=(3*hpov_sm0) & hinc_sm0_ur<(4*hpov_sm0) )
gen hpov_sm0_400500_ur = (hinc_sm0_ur>=(4*hpov_sm0) & hinc_sm0_ur<(5*hpov_sm0) )
gen hpov_sm0_500600_ur = (hinc_sm0_ur>=(5*hpov_sm0) & hinc_sm0_ur<(6*hpov_sm0) )
gen hpov_sm0_600700_ur = (hinc_sm0_ur>=(6*hpov_sm0) & hinc_sm0_ur<(7*hpov_sm0)  )
gen hpov_sm0_700800_ur = (hinc_sm0_ur>=(7*hpov_sm0) & hinc_sm0_ur<(8*hpov_sm0)  )
gen hpov_sm0_800900_ur = (hinc_sm0_ur>=(8*hpov_sm0)  & hinc_sm0_ur<(9*hpov_sm0)   )
gen hpov_sm0_9001000_ur = (hinc_sm0_ur>=(9*hpov_sm0)  & hinc_sm0_ur<(10*hpov_sm0)   )
gen hpov_sm0_1000_ur = (hinc_sm0_ur>=(10*hpov_sm0)  & hinc_sm0_ur~=.   )
gen hpov_sm0_800pl_ur = (hinc_sm0_ur>=(8*hpov_sm0)  & hinc_sm0_ur~=.   )

for any hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800900 hpov_sm0_9001000 hpov_sm0_1000: replace X_ur = . if hpov_sm0==.
gen pov_ratio_ur= 1 if hpov_sm0_100_ur==1
replace pov_ratio_ur=2 if hpov_sm0_100200_ur==1
replace pov_ratio_ur=3 if hpov_sm0_200300_ur==1
replace pov_ratio_ur=4 if hpov_sm0_300400_ur==1
replace pov_ratio_ur=5 if hpov_sm0_400500_ur==1
replace pov_ratio_ur=6 if hpov_sm0_500600_ur==1
replace pov_ratio_ur=7 if hpov_sm0_600700_ur==1
replace pov_ratio_ur=8 if hpov_sm0_700800_ur==1
replace pov_ratio_ur=9 if hpov_sm0_800pl_ur == 1 

***************************************
* Handle temp layoffs
***************************************
sum templayoff templayoff_pre
bysort uniqueid: egen templayoffever = max(templayoff)
order uniqueid month_reljl templayoff templayoffever templayoff_pre
drop if templayoff_pre==1

***************************************
** Create a few misc items
***************************************
* month year fixed effects
gen double yearmonth = year_m*100 + imonth
gen agesq = age^2

* drop those who receive UI before job loss
drop if max_flagpreui==1

* edits to balanced variable
rename balance_pre12post24 balance_1224
for any balance_1224: replace X = 0 if tenure_1year!=1

* some indicators
gen male=(female==0)
gen anykids_sm0=(kids_sm0>0 & kids_sm0~=.)
gen nokids_sm0=(kids_sm0==0)
gen single=(married==0)
gen single_sm0=(married_sm0==0)

* check sample size of poverty variables and other sample restrictions
mdesc all hpov_sm0_100 hpov_sm0_100200 hpov_sm0_200300 hpov_sm0_300400 hpov_sm0_400500 hpov_sm0_500600 hpov_sm0_600700 hpov_sm0_700800 hpov_sm0_800 if tenure_1year==1 & head_spouse_partner==1
mdesc anykids_sm0 nokids_sm0 earn_quintiles1 earn_quintiles2 earn_quintiles3 earn_quintiles4 earn_quintiles5 ///
uismp nouismp recession notrecession if tenure_1year==1 & head_spouse_partner==1

xtset uniqueid order  

***************************************
*** Set up event study, Set Omitted Periods
***************************************
replace dumspell5 = 0
replace dumspell1 = 0

label var dumspell1 " -12"
label var dumspell2 " -10"
label var dumspell3 " -8"
label var dumspell4 " -6"
label var dumspell5 " -4"
label var dumspell6 " -2"
label var dumspell7 " 0"
label var dumspell8 " 2"
label var dumspell9 " 4"
label var dumspell10 " 6"
label var dumspell11 " 8"
label var dumspell12 " 10"
label var dumspell13 " 12"
label var dumspell14 " 14"
label var dumspell15 " 16"
label var dumspell16 " 18"
label var dumspell17 " 20"
label var dumspell18 " 22"


save "$samples/regfinal.dta", replace 
	
	
log close
