/*********************
File Name: 01a_state_controls.do

This file creates state_data.dta that is an input to the later analysis data.

By: Chloe East and David Simon

Inputs: ek_data (Kuka UI data)
Outputs: state_data.dta
***********************/
	
**********************
*** PREPARE DATA
**********************
*** Prepare Simulate Replacement Rates -- these come straight from Elira's JMP so may want to redo with our sample
use "${ek_data}/instrument_sipp_y.dta", clear	// from Kuka UI data (see readme)
merge 1:1 year statefip kids using "${ek_data}/uilaws_updated_sim.dta" // from Kuka UI data (see readme)
keep if _merge==3
drop _merge

bysort statefip year: egen st_max=max(max)
bysort statefip year: egen st_min=min(min)


* Collapse at state-year (it was by state-year-kids before)
collapse (mean) sim_repl_sipp wba st_max max  st_min min st [aw=p5wgt], by(statefip year)
for any sim_repl_sipp wba: rename X st_X
for any min max: rename X st_ave_X
keep if year>=1990 & year<=2015
tempfile replrates
save `replrates', replace

*** Prepare UI benefits data			
use "${ek_data}/uibens_7113.dta", clear // from Kuka UI data (see readme)

* Generate extended and emergency benefits
gen st_extended=fedstebbenefitspaid>0 & fedstebbenefitspaid!=.
gen fed_emerg=emerbenefitspaid>0 & emerbenefitspaid!=.
keep if year>=1990 & year<=2015 

rename month intmo


tempfile uibens	
save `uibens', replace

*** Prepare children's Medicaid/CHIP
use  "${ek_data}/st_child_med_8814.dta", replace // from Kuka UI data (see readme)
rename  childthresh pregnthresh
append using "${ek_data}/st_preg_med_8714.dta" // from Kuka UI data (see readme)
replace age=-1 if age==.
rename pregnthresh medthresh

collapse (mean) medthresh, by(stfips year)
keep if year>=1990 & year<=2015 
tempfile medicaid
save `medicaid', replace

**********************
*** CLEAN UK CPT DATA
**********************
*** Input unemployment rates
* Input Urate/Pop
use "${ek_data}/ukcpr_welfare_8015.dta", clear // from Kuka UI data (see readme)
drop if statefip>56 | statefip==43

* Input CPI to create real values
merge m:1 year using "${ek_data}/cpi_6717.dta", gen(cpim) // from Kuka UI data (see readme)
drop if cpim!=3
drop cpim

* Unemployment rate
rename unemploymentrate urate
replace urate=urate/100			// Divide by 100 to make the coefficients larger

* Epop (note this is all population)
gen epop = employment / population

* Minimum wage
egen minwage=rowmax(federalmin statemin)

* AFDC Max
rename afdctanfbenefitfor4personfamily afdcmax4

* State GDP
rename grossstatepro gsp

* Transform in real values
replace gsp=gsp*237.017/cpi													// Millions, 2015$ real 
for any afdcmax4 minwage: replace X=X*2.37017/cpi				// 100s, 2015$ real 
keep urate epop gsp year statefip population minwage afdcmax4 cpi

* Create lags and growth rates
sort statefip year
for any 1 2: bysort statefip: gen urate_lagX=urate[_n-X] if year==year[_n-X]+X	
keep if year>=1990 & year<=2015 

**********************
*** MERGE GENEROSITY DATA
**********************
*** Merge Simulate Replacement Rates 
merge 1:1 statefip year	 using `replrates'
drop _merge
rename statefip stfips
for any st_max st_min st_ave_max st_ave_min: replace X=X*2.37017/cpi			// 100s, 2015$ real 


*** Medicaid/SCHIP = Average for pregnant women and children 0-16
merge 1:1 stfips year using `medicaid'
drop _merge
keep if year>=1990 & year<=2015 

*** Welfare reform
merge 1:1 stfips year using  "${ek_data}/st_welfreform_8813.dta" // from Kuka UI data (see readme)
drop _merge
keep if year>=1990 & year<=2015 
replace reform=0 if year>=2013

*** EITC
rename stfips statefip
merge m:1 statefip year using  "${ek_data}/eitc_vals_8415.dta" // from Kuka UI data (see readme)
drop _merge
keep if year>=1990 & year<=2015

**********************
*** MERGE SPENDING DATA
**********************
*** Add welfare spending here (data in thousands)
merge 1:1 statefip year using "${ek_data}/welf_spend_6815.dta", keepus(snap eitc tanf medicaid retdi) gen(m_welf) // from Kuka UI data (see readme)
drop if m_welf==2
drop m_welf
keep if year>=1990 & year<=2015


* CPI for all spending
foreach x in snap eitc tanf medicaid retdi {
	replace `x'_spend = `x'_spend*237.017/cpi 
	gen `x'_pop=`x'_spend/population
}

*** Add UI data (in Thousands)
merge 1:1 statefip year using "${ek_data}/eta_uifunds_3816.dta" // from Kuka UI data (see readme)
drop ui_wage ui_aww ui_rr ui_high_co state
sort statefip year
keep if year>=1990 & year<=2015
rename ui_benefits_paid ui_benefits


* Fix UI
for any ui_benefits ui_net_reserves: replace X=X*237.017/cpi
for any ui_benefits ui_net_reserves: gen X_pop=X/population

* Lags
for any 1 2: bysort statefip: gen ui_netres_lagX_pop=ui_net_reserves_pop[_n-X]
drop if _merge==2
keep if year>=1990 & year<=2015
drop _merge

*** Merge wages
merge 1:1 statefip year using "${ek_data}/state_weeklywages.dta", gen(stwages) // from Kuka UI data (see readme)
replace avweekwage=avweekwage*2.37017/cpi	

**********************
*** LABEL ALL NEW VARIABLES
**********************
label var cpi "CPI"

for any 1 2: label var urate_lagX "X Lag Unemployment Rate"
label var urate "Unemployment Rate"
label var avweekwage "Average Weekly Wage (\\$2015, 100s)"
label var population "Population"
label var epop "Employment Rate"
label var gsp "Gross State Product (\\$2015, Millions)"

label var st_max "St Max UI Benefit (\\$2015, 100s)"
label var st_min "St Min UI Benefit (\\$2015, 100s)"
label var st_ave_max "St Ave Max UI Benefit (\\$2015, 100s)"
label var st_ave_min "St Ave Min UI Benefit (\\$2015, 100s)"
label var st_sim_repl "State Simulated Replacement Rate"
label var st_wba "St Simulated WBA (\\$2015, 100s)"

label var ui_benefits "State UI Benefits"
label var ui_net_reserves "State UI Net Reserves"
label var ui_benefits_pop "State UI Benefits/Population"
label var ui_net_reserves_pop "State UI Net Reserves/Population"
label var ui_netres_lag1_pop "1 Lag (UI Net Reserves/Population)"
label var ui_netres_lag2_pop "2 Lag (UI Net Reserves/Population)"

label var medthresh "Mean Medicaid Pov Threshold"
label var reform "Welfare Reform Indicator"
label var minwage "Minimum Wage (\\$2015, 100s)"
label var eitc_val "State EITC (Percent Federal)"
label var afdcmax4 "AFDC Max Benefits (\\$2015, 100s)"

label var snap_pop "FS Spending/Population"
label var tanf_pop "AFDC Spending/Population"
label var medicaid_pop "Medicaid Spending/Population"
label var retdi_pop "SS Spending/Population"
label var eitc_pop "EITC Spending/Population"

drop if year<1990
save "${outdata}/state_data.dta", replace

 
