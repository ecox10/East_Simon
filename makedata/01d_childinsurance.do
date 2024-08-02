******************************************************
***************** 		CREATE child insurance DATASET		***********************
			******************************************************
			
			*** Append data and clean
***********************

use "${outdata}/sipp_cleaned_temp.dta", clear

keep if statefip<60 & statefip!=.

sort panel hhid wave refmth

gen kid_sm0 = 1 if wave==1 & refmth==1 & age<18
replace kid_sm0 = 0 if kid_sm0==.

*should put the number of kids in base period on every one in household

by panel hhid: egen nkids_sm0= total(kid_sm0) 
drop kid_sm0

*** Fix demographics
drop if kids==.
drop if ed==.
drop if mardum==.

* One race variable
cap drop race
gen race=1 if white==1
replace race=2 if black==1 
replace race=3 if hisp==1 
replace race=4 if other==1
drop if race==.

* Sex
gen female = sex==1
drop if sex==.
drop sex

** HIIND / MCAID: 0 or -1 NA, 1 Y, 2 N
for any hiind caidcov: replace X=. if (X==2 & panel<1996) | ((X==0 | X==-1) & panel>=1996)
for any hiind caidcov: replace X=0 if X==2 & panel>=1996
rename hiind priv_hins
label var priv_hins "Private Health Insurance"
label var caidcov "Medicaid"

*** MCARE / Hospital Stays 0 or -1 NA, 1 Y, 2 N
for any carecov: replace X=. if X==0 | X==-1
for any carecov: replace X=0 if X==2
label var carecov "Medicare"

*** Generate any insurance
gen any_hins = priv_hins==1 | carecov==1 | caidcov==1
replace any_hins=. if priv_hins==. & carecov==. & caidcov==.

gen pub_hins = carecov==1 | caidcov==1
replace pub_hins=. if carecov==. & caidcov==.
label var pub_hins "Medicare/Medicaid"

*create indicator for any kid having insurance / private /public
foreach x in any_hins pub_hins priv_hins {
drop if `x'==.
	}

foreach x in any_hins pub_hins priv_hins{
bysort hhid  year wave mth: egen anyk_`x' = max(`x') 
}

*create indicator for no kid having insurance in a household at a wave/month
foreach x in any_hins pub_hins priv_hins{
by hhid year wave mth: egen nok1_`x' = min(`x')
gen nok_`x'= nok1_`x'==0
drop nok1_`x'
}

*create indicator for number with insurance
foreach x in any_hins pub_hins priv_hins{
by hhid year wave mth: egen numk_`x' = total(`x')
}

foreach x in any_hins pub_hins priv_hins{
bysort hhid  year wave mth: gen portk0_`x' = (numk_`x'/nkids_sm0)
}

*create proportion out of current kids in household
by hhid year wave mth: egen numk_all =count(pnum) 

foreach x in any_hins pub_hins priv_hins{
bysort hhid year wave mth: gen portk_`x' = (numk_`x'/numk_all)
}
 order hhid year wave mth pnum age any_hins anyk_any_hins nok_any_hins portk_any_hins

keep pnum hhid panel wave year mth priv_hins carecov pub_hins any_hins portk0_any_hins  ///
portk0_pub_hins portk0_priv_hins  portk_any_hins portk_pub_hins portk_priv_hins ///
nok_any_hins nok_pub_hins nok_priv_hins anyk_any_hins anyk_pub_hins anyk_priv_hins 

* now collapse down to the household year month level
sort hhid year wave mth
collapse portk0_any_hins portk0_pub_hins portk0_priv_hins  portk_any_hins portk_pub_hins ///
 portk_priv_hins nok_any_hins nok_pub_hins nok_priv_hins anyk_any_hins anyk_pub_hins ///
 anyk_priv_hins, by(hhid wave year mth) 

rename year year_m
rename mth imonth

sort hhid year_m wave imonth


save "${outdata}/chyeaout.dta", replace
