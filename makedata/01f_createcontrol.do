/*********************
File Name: 01f_createcontrol.do

This file cleans the dataset of the control group, non job losers

By: Chloe East and David Simon

Inputs: controlsetup.dta
Outputs: control_never.dta
***********************/

use "${outdata}/controlsetup.dta", replace

drop statefip_m0 kids_m0 year_m0
drop trend
gen trend=year_m-1995

replace month_reljl=-3 if loser==0
drop uniqueid 
egen double uniqueid=group(panel suid pnum female)
	



***************** From create jobloss - Prepares never job losers for regression *****************

gen earn_any=(earn>0)


label var earn "Earned Income - Indiv"
label var earn_any "Any Earned Income - Indiv"
label var uiamt "UI Income - Indiv"
label var priv_hins "Private HI - Indiv"
label var any_hins "Any HI - Indiv"
label var pub_hins "Public HI - Indiv"
label var ss_amt "SS Income - Indiv"
label var ss_amt "SS Income - Hhold"
label var ssi_amt "SSI Income - Indiv"
label var ssi_st_amt "SSI State Income - Indiv"
label var h_ssi_amt "SSI Income - Hhold"
label var fs_amt "SNAP Income - Indiv"
label var h_fs_amt "SNAP Income - Hhold"
label var tanf_amt "TANF Income - Indiv"
label var h_tanf_amt "TANF Income - Hhold"
label var wic_amt "WIC Income - Indiv"
label var frp_lunch  "Kids Receive FRP Lunch"
label var hinc "Total Income - Hhold"
label var hearn "Total Earnings - Hhold"
label var hpov100 "Hhold Below Poverty"
label var hpov200 "Hhold Below 200% Poverty"
label var hpov400 "Hhold Below 400% Poverty"


*quickly recode living in public housing for regressions
replace pubhsing = . if pubhsing==-1
replace pubhsing = (pubhsing==1) if missing(pubhsing)~=1
tab pubhsing, missing

replace getsbrnt = . if getsbrnt==-1
replace getsbrnt = (getsbrnt==1) if missing(getsbrnt)~=1
gen d_housing = (pubhsing==1 | getsbrnt==1)
replace d_housing =d_housing*100


***************************************
*** Impute FRPL Values  
***************************************
gen frp_lunch_rp_v = . 
replace frp_lunch_rp_v = 1.7125 if year_m<=1998
replace frp_lunch_rp_v = 1.75 if year_m==1999
replace frp_lunch_rp_v = 1.79 if year_m==2000
replace frp_lunch_rp_v = 1.86 if year_m==2001
replace frp_lunch_rp_v = 1.91 if year_m==2002
replace frp_lunch_rp_v = 1.96 if year_m==2003
replace frp_lunch_rp_v = 2.01 if year_m==2004
replace frp_lunch_rp_v = 2.09 if year_m==2005
replace frp_lunch_rp_v = 2.17 if year_m==2006
replace frp_lunch_rp_v = 2.24 if year_m==2007
replace frp_lunch_rp_v = 2.34 if year_m==2008
replace frp_lunch_rp_v = 2.45 if year_m==2009
replace frp_lunch_rp_v = 2.49 if year_m==2010
replace frp_lunch_rp_v = 2.54 if year_m==2011
replace frp_lunch_rp_v = 2.63 if year_m==2012
replace frp_lunch_rp_v = 2.7 if year_m==2013
replace frp_lunch_rp_v = 2.75 if year_m==2014

gen frp_lunch_free_v = . 
replace frp_lunch_free_v = 2.1125 if year_m<=1998
replace frp_lunch_free_v = 2.15 if year_m==1999
replace frp_lunch_free_v = 2.19 if year_m==2000
replace frp_lunch_free_v = 2.26 if year_m==2001
replace frp_lunch_free_v = 2.31 if year_m==2002
replace frp_lunch_free_v = 2.36 if year_m==2003
replace frp_lunch_free_v = 2.41 if year_m==2004
replace frp_lunch_free_v = 2.49 if year_m==2005
replace frp_lunch_free_v = 2.57 if year_m==2006
replace frp_lunch_free_v = 2.64 if year_m==2007
replace frp_lunch_free_v = 2.74 if year_m==2008
replace frp_lunch_free_v = 2.85 if year_m==2009
replace frp_lunch_free_v = 2.89 if year_m==2010
replace frp_lunch_free_v = 2.94 if year_m==2011
replace frp_lunch_free_v = 3.03 if year_m==2012
replace frp_lunch_free_v = 3.1 if year_m==2013
replace frp_lunch_free_v = 3.15 if year_m==2014

gen frp_lunch_value = 0
replace frp_lunch_value = frp_lunch_rp_v*numk_lunch*22 if frp_lunch_rp==1
replace frp_lunch_value = frp_lunch_free_v*numk_lunch*22 if frp_lunch_free==1
sum frp_lunch_value frp_lunch_free_v frp_lunch_rp_v numk_lunch frp_lunch_free frp_lunch_rp 
gen d_frp_lunch_value = (frp_lunch_value>0 & frp_lunch_value~=.)
replace d_frp_lunch_value = . if frp_lunch_value==.
replace d_frp_lunch_value = d_frp_lunch_value*100
	
// cpi
for any frp_lunch_value : replace X=X*237.017/cpi

sort hhid year_m wave imonth

label var earn "Earned Income - Indiv"
label var earn_any "Any Earned Income - Indiv"
label var uiamt "UI Income - Indiv"
label var priv_hins "Private HI - Indiv"
label var any_hins "Any HI - Indiv"
label var pub_hins "Public HI - Indiv"
label var ss_amt "SS Income - Indiv"
label var ss_amt "SS Income - Hhold"
label var ssi_amt "SSI Income - Indiv"
label var ssi_st_amt "SSI State Income - Indiv"
label var h_ssi_amt "SSI Income - Hhold"
label var fs_amt "SNAP Income - Indiv"
label var h_fs_amt "SNAP Income - Hhold"
label var tanf_amt "TANF Income - Indiv"
label var h_tanf_amt "TANF Income - Hhold"
label var wic_amt "WIC Income - Indiv"
label var frp_lunch  "Kids Receive FRP Lunch"
label var hinc "Total Income - Hhold"
label var hearn "Total Earnings - Hhold"
label var hpov100 "Hhold Below Poverty"
label var hpov200 "Hhold Below 200% Poverty"
label var hpov400 "Hhold Below 400% Poverty"

*create year quarter of job loss and year quarter obsered 
gen year_jl = year_m if month_reljl==0
list year_jl in 1/10
bysort uniqueid: egen max_year_jl = max(year_jl)
rename year_jl year_jl_m
rename max_year_jl year_jl

* Create month in which spell occurred 
tab month_reljl, m
for any max min: bysort uniqueid: egen X_month_reljl=X(month_reljl)
drop if month_reljl<-12 | month_reljl>=24
tab month_reljl, m

gen month_reljl_temp = month_reljl
replace month_reljl_temp=22 if month_reljl_temp==23
forvalues i=-12(2)20 {
	replace month_reljl_temp=`i' if month_reljl_temp==`i'+1
}
		 
*since control group all dumspells zero except three periods before, which will be dropped anyways...
for num 1/18: gen dumspellX=0
for num 1/18: gen sim_spellX=sim_repl_sipp*dumspellX
	
sum month_reljl_temp month_reljl if dumspell6==1
drop dumspell5 sim_spell5		// drop two months before job loss, so everything becomes relative to that
cap drop jobloss
gen jobloss=month_reljl>=0
for any kids_m statefip_m year_m: egen Xloss=group(X jobloss)

gen post=month_reljl>=0 & month_reljl!=.
replace post=. if month_reljl==.
gen sim_post=0
replace sim_post=sim_repl_sipp if month_reljl>=0
label var sim_post "R-rate * Loss"


// match ages in admin data
foreach x in age {
	gen temp=`x' if month_reljl==0
	bysort uniqueid: egen `x'_m0=max(temp)
	drop temp
}
	
// generate tenure at sm0
foreach x in p5wgt tenure_1year2{
	gen temp=`x' if wave==1 & refmth==1 
	bysort uniqueid: egen `x'_sm0=max(temp)
	drop temp
}		
	
keep if age_sm0>=25 & age_sm0<=54

***************************************
*** Set Event Time
***************************************


gen dumspell5 =0		
cap drop jobloss
gen jobloss=month_reljl>=0

label var dumspell1 "-12"
label var dumspell2 "-10"
label var dumspell3 "-8"
label var dumspell4 "-6"
label var dumspell5 "-4"
label var dumspell6 "-2"
label var dumspell7 "0"
label var dumspell8 "2"
label var dumspell9 "4"
label var dumspell10 "6"
label var dumspell11 "8"
label var dumspell12 "10"
label var dumspell13 "12"
label var dumspell14 "14"
label var dumspell15 "16"
label var dumspell16 "18"
label var dumspell17 "20"
label var dumspell18 "22"

gen all=1


* create year and month fixed effects
gen double yearmonth = year_m*100 + imonth

sum yearmonth year_m imonth

gen agesq = age^2

***************************************
*** Adjust for under-reporting ***
***************************************
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

********************
*First control group: never displaced, 24 to 55 when first observed, one year job tenure when first observed.
***************
keep if tenure_1year2_sm0==1
keep if head_spouse_partner==1

rename earn_any any

*** Set Omitted Periods
replace dumspell5 = 0
replace dumspell1 = 0

save "${outdata}/control_never.dta", replace 

