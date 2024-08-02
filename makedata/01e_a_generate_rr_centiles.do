/*********************
File Name: 01e_a_generate_rr_centiles.do

Generate universal income centiles and save them by year and incid
Pieces taken from:
* Jeff Larrimore, Jacob Mortenson, and David Splinter

By: Chloe East and David Simon

Inputs: LMS-UI-data.xlsx (from Larrimore et al. replication package), sipp_cleaned.dta
Outputs: SIPP_centiles.dta, SIPP_respondent_reporting.dta, SIPP_dollars_reporting.dta
***********************/

**** read and format IRS data ****
clear
import excel "${lms_data}/LMS-UI-data.xlsx", sheet(Imputations) cellrange(A5:F2204) // From LMS data (see readme)
rename A inc_centile
rename B taxyr
rename C ui_sum
rename D ui_n
rename E ui_mean
rename F ui_sd
rename taxyr year

save "${lms_data}/IRS_centile_ui.dta", replace

**** create a dummy file with income bins so that there are no gaps in output ****
clear
set obs 501
gen incunemp_bin = 100*(_n - 1)
gen asecwt = 1
gen incunemp = 1
gen temp = 1
gen year = 0
tempfile dummy
save `dummy'

**** Set up the SIPP data ****
use "${outdata}/sipp_cleaned", clear // making centiles directly off of cleaned analysis data
keep if age>=16

* subtract uiamt from hinc to get modified market income 
gen hinc_minusui = hinc - uiamt
replace hinc_minusui = . if hinc == .
replace hinc_minusui = 0 if hinc == 0 

*Equal-split income between spouses
gen split_tu_totalinc = hinc_minusui
replace split_tu_totalinc = hinc_minusui/2 if ms == 1 | ms == 2

**** calculate UI ****
egen double incid=group(suid pnum)
gen anyui_bymth = uiamt>0
egen anyui_count = total(anyui_bymth), by(incid year)
gen anyui = anyui_count>0

save "${outdata}/temp.dta", replace

**** Create centiles ****

foreach yr in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {

	preserve 
	keep if year == `yr'
	
	*Determine how many people and recipients in each centile
	* keep only one record that a person in a household received UI that year
	sort incid year 
	by incid year: gen record_count = _n
	keep if record_count == 1

	*centiles on the only 1 obs per household
	local centiles = 100
	gen rand1 = runiform()
	sort year split_tu_totalinc rand1
	by year: gen double runningwgt = sum(p5wgt)
	by year: egen double totalwgt = total(p5wgt)
	gen inc_centile = runningwgt/totalwgt
	replace inc_centile = ceil(inc_centile*`centiles')
	drop runningwgt totalwgt

	tempfile temp`yr'
	save `temp`yr'', replace	
	
	restore
}

* append together
use `temp1995', clear
foreach yr in 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	append using `temp`yr''
}

* save inc_centiles by income id so we can use the same centiles everywhere
collapse anyui, by(incid inc_centile year)
outsheet incid inc_centile year using "${underreporting}/SIPP_centiles.csv", comma replace

* dta
import delimited "${underreporting}/SIPP_centiles.csv", clear 
save "${underreporting}/SIPP_centiles.dta", replace 

*==============================*
**** Create reporting rates ****
use "${outdata}/temp.dta", clear

* add centiles
sort incid year 
joinby incid year using "${underreporting}/SIPP_centiles.dta", unmatched(master) _merge(centile_merge)
preserve

* for participation keep only 1st record
sort incid year 
by incid year: gen record_count = _n
keep if record_count == 1

* Add IRS data
sort year inc_centile
drop _merge
merge m:1 year inc_centile using "${lms_data}/IRS_centile_ui.dta"
drop _merge 
keep if year >= 1999

* calculate number participants in each centile
sort year inc_centile
gen temp = anyui * p5wgt
by year inc_centile: egen double ui_n_sipp_raw = total(temp)
drop temp
by year inc_centile: egen double sipp_n = total(p5wgt)

**** participation ****
by year inc_centile: gen sipp_part_reporting = ui_n_sipp_raw/ui_n 

collapse ui_n_sipp_raw ui_n sipp_part_reporting, by(year inc_centile)
rename ui_n_sipp_raw sipp_ui_recipients
rename ui_n IRS_ui_recipients

* save csv of reporting rate
outsheet inc_centile year sipp_ui_recipients IRS_ui_recipients sipp_part_reporting using "${underreporting}/SIPP_respondent_reporting.csv", comma replace

restore 

**** dollars **** 

* Add IRS data
sort year inc_centile
drop _merge
merge m:1 year inc_centile using "${lms_data}/IRS_centile_ui.dta"
drop _merge 
keep if year >= 1999

* calculate dollars
sort year inc_centile
gen temp = uiamt * p5wgt
by year inc_centile: egen double centile_ui_dollars_sipp = total(temp)
drop temp

by year inc_centile: gen sipp_dollars_reporting = centile_ui_dollars_sipp/ui_sum 


collapse centile_ui_dollars_sipp ui_sum sipp_dollars_reporting, by(year inc_centile)
rename centile_ui_dollars_sipp sipp_ui_dollars 
rename ui_sum IRS_ui_dollars

* save csv of reporting rate
outsheet inc_centile year sipp_ui_dollars IRS_ui_dollars sipp_dollars_reporting using "${underreporting}/SIPP_dollars_reporting.csv", comma replace

cap erase "${outdata}/temp.dta"

**** Make dta's ****

* participation 
import delimited "${underreporting}/SIPP_respondent_reporting.csv", clear 
save "${underreporting}/SIPP_respondent_reporting.dta", replace 

* dollars 
import delimited "${underreporting}/SIPP_dollars_reporting.csv", clear 
save "${underreporting}/SIPP_dollars_reporting.dta", replace 



