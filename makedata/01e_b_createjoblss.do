*************************************************
***************** 		CREATE REGRESSION DATASET		***********************
			*************************************************
pause on

use "$samples/sipp_cleaned.dta", clear
	
keep if panel>=1996
egen double uniqueid=group(panel suid pnum female)

***************************************
*** Create definition of job loss
***************************************
for any stlemp1_yn whystop1: replace X=. if X==-1		// set 'not in universe' as missing

* Months since job loss variable
gen ym_now = ym(year, imonth)
replace enddate1=. if enddate1==-1
format enddate1 %10.0f  
bysort uniqueid: egen nval_enddate1=nvals(enddate1)
generate yr_loss = int(enddate1/10000)
generate mth_loss = int((enddate1 - yr_loss*10000)/100)
gen ym_loss = ym(yr_loss, mth_loss)
drop nval_enddate1 		// decide to use first job loss
sort uniqueid order


* Indicator for whether month of job loss is current month
gen loss = ym_loss==ym_now & ym_loss!=. & ym_now!=.	
replace loss=0 if whystop1!=1 & whystop1!=9 & whystop1!=10 & whystop1!=13		// involuntary job loss
		

*** Months since involuntary job loss: focus on 1st job loss only
bysort uniqueid: egen num_losses=total(loss)
gen temp_order_loss = 9999
replace temp_order_loss=order if loss==1
bysort uniqueid: egen order_loss=min(temp_order_loss)
replace order_loss=. if order_loss==9999
gen month_reljl = order-order_loss
replace month_reljl=. if order_loss==.
replace month_reljl=-18 if month_reljl<=-18 & month_reljl!=.
replace month_reljl=30 if month_reljl>=30 & month_reljl!=.
gen afterloss = month_reljl>0 & month_reljl!=.
replace afterloss=. if month_reljl==.
drop temp_order_loss order_loss

*** Generate variable for type of insurance in month prior to job loss
for any notown own employer: gen temp_X_prior=0
replace temp_notown_prior=1 if hiown==2 & month_reljl==-1
replace temp_own_prior=1 if (hiown==1 | hiown==3) & month_reljl==-1
replace temp_employer_prior=1 if hisrc==1 & (hiown==1 | hiown==3) & month_reljl==-1
sort uniqueid order
for any notown own employer: bysort uniqueid: egen X_prior=max(temp_X_prior)
drop temp_*

*** Start and End Dates of Job
tostring stdate1, gen(stdate12)
replace stdate12="." if stdate12=="-1"
gen str_yr = substr(stdate12, 1,4)
gen str_mo = substr(stdate12, 5,2)
gen str_da = substr(stdate12, 7,2)
	
tostring enddate1, gen(enddate12)
replace enddate12="." if enddate12=="-1"
gen end_yr = substr(enddate12, 1,4)
gen end_mo = substr(enddate12, 5,2)
gen end_da = substr(enddate12, 7,2)	
drop stdate12 enddate12
	
***************************************
* Job Info
***************************************
* hours
replace uhours=. if uhours==-8					// -8 means "hours vary"
replace uhours=0 if uhours==-1					// -1 means "not in universe"

// poverty status of household
gen hhinc_pov = hinc/hpov
gen hpov100=(hinc<hpov)  
gen hpov200=(hinc<(2*hpov))
gen hpov400=(hinc<(4*hpov))   
for any hpov100 hpov200 hpov400: replace X = . if hinc==. | hpov==.
		
rename statefip fips
rename imonth month
rename fips statefip
rename  month imonth 

// cpi  
for any  earn   hinc hearn totinc earn uiamt fs_amt tanf_amt ssi_amt ss_amt ///
ss_ch_amt h_ss_amt ssi_ch_amt ssi_st_amt h_ssi_amt  h_tanf_amt h_fs_amt ///
h_wic_amt wic_amt  hpov enrgyamt sevrpay : replace X=X*237.017/cpi

***************************************	  
// source of insurance
***************************************
gen own_hins = priv_hins==1 & (hiown==1 | hiown==3)
gen employ_hins = priv_hins==1 & hisrc==1 & (hiown==1 | hiown==3)
gen else_hins = priv_hins==1 & hiown==2
for any own employ else: replace X_hins=. if priv_hins==.
label var own_hins "Own Insurance"
label var employ_hins "Own-Employer Insurance"
label var else_hins "Someone Else Insurance"

***************************************	
// frp lunch and breakfast recode
***************************************
for any frp_lunch frp_breakf: replace X = . if X==-1
for any frp_lunch frp_breakf: replace X = 0 if X==2
for any lunch breakf: replace frp_X=0 if any_X==2 // didnt receive any school lunch
for any lunch breakf: replace frp_X=0 if any_X==-1 // not school aged kids in hhold
for any frp_lunch frp_breakf: gen X_free = (X_type==1)
for any frp_lunch frp_breakf: replace X_free = . if X_type==-1 
for any frp_lunch frp_breakf: gen X_rp = (X_type==2)
for any frp_lunch frp_breakf: replace X_rp = . if X_type==-1
for any numk_lunch numk_breakf : replace X = . if X==-1

***************************************		
** Spousal and Own Earnings and Labor Supply in 1st Survey Month
***************************************
replace hpov = hpov/12 if panel==1996
foreach x in hinc hearn hpov earn work uhours uiamt h_tanf_amt  h_ss_amt  h_ssi_amt  {
	gen temp=`x' if wave==1 & refmth==1 
	bysort uniqueid: egen `x'_sm0=max(temp)
	drop temp
}

***************************************
** Kids in 1st Survey Month
***************************************
foreach x in kids  {
	gen temp=`x' if wave==1 & refmth==1 
	bysort uniqueid: egen `x'_sm0=max(temp)
	drop temp
}

***************************************	 
// reporting rates from Meyer, Mok, and Sullivan 2015
***************************************
for any tanf snap ssdi ssi ui: gen X_rr_dol = .	
for any tanf snap ssdi ssi ui frpl wic: gen X_rr_p = .	
replace tanf_rr_dol=0.849 if year==1995
replace tanf_rr_dol=0.793 if year==1996
replace tanf_rr_dol=0.913 if year==1997
replace tanf_rr_dol=0.706 if year==1998
replace tanf_rr_dol=0.598 if year==1999
replace tanf_rr_dol=0.621 if year==2000
replace tanf_rr_dol=0.584 if year==2001
replace tanf_rr_dol=0.56 if year==2002
replace tanf_rr_dol=0.532 if year==2003
replace tanf_rr_dol=0.618 if year==2004
replace tanf_rr_dol=0.61 if year==2005
replace tanf_rr_dol=0.628 if year==2006
replace tanf_rr_dol=0.685 if year==2007
replace tanf_rr_dol=0.817 if year==2008
replace tanf_rr_dol=0.745 if year==2009
replace tanf_rr_dol=0.64 if year==2010
replace tanf_rr_dol=0.677 if year==2011
replace tanf_rr_dol=0.677 if year==2012
replace tanf_rr_dol=0.677 if year==2013
replace tanf_rr_dol=0.677 if year==2014
replace tanf_rr_p=0.814 if year==1995
replace tanf_rr_p=0.772 if year==1996
replace tanf_rr_p=0.794 if year==1997
replace tanf_rr_p=0.769 if year==1998
replace tanf_rr_p=0.713 if year==1999
replace tanf_rr_p=0.717 if year==2000
replace tanf_rr_p=0.697 if year==2001
replace tanf_rr_p=0.62 if year==2002
replace tanf_rr_p=0.642 if year==2003
replace tanf_rr_p=0.756 if year==2004
replace tanf_rr_p=0.766 if year==2005
replace tanf_rr_p=0.783 if year==2006
replace tanf_rr_p=0.822 if year==2007
replace tanf_rr_p=0.931 if year==2008
replace tanf_rr_p=0.887 if year==2009
replace tanf_rr_p=0.785 if year==2010
replace tanf_rr_p=0.807 if year==2011
replace tanf_rr_p=0.769 if year==2012
replace tanf_rr_p=0.769 if year==2013
replace tanf_rr_p=0.769 if year==2014

replace snap_rr_dol=0.785 if year==1995
replace snap_rr_dol=0.786 if year==1996
replace snap_rr_dol=0.778 if year==1997
replace snap_rr_dol=0.786 if year==1998
replace snap_rr_dol=0.771 if year==1999
replace snap_rr_dol=0.806 if year==2000
replace snap_rr_dol=0.885 if year==2001
replace snap_rr_dol=1.061 if year==2002
replace snap_rr_dol=0.8 if year==2003
replace snap_rr_dol=0.804 if year==2004
replace snap_rr_dol=0.794 if year==2005
replace snap_rr_dol=0.822 if year==2006
replace snap_rr_dol=0.784 if year==2007
replace snap_rr_dol=0.825 if year==2008
replace snap_rr_dol=0.812 if year==2009
replace snap_rr_dol=0.807 if year==2010
replace snap_rr_dol=0.793 if year==2011
replace snap_rr_dol=0.792 if year==2012
replace snap_rr_dol=0.792 if year==2013
replace snap_rr_dol=0.792 if year==2014
replace snap_rr_p=0.768 if year==1995
replace snap_rr_p=0.809 if year==1996
replace snap_rr_p=0.848 if year==1997
replace snap_rr_p=0.852 if year==1998
replace snap_rr_p=0.845 if year==1999
replace snap_rr_p=0.839 if year==2000
replace snap_rr_p=0.887 if year==2001
replace snap_rr_p=0.874 if year==2002
replace snap_rr_p=0.845 if year==2003
replace snap_rr_p=0.837 if year==2004
replace snap_rr_p=0.846 if year==2005
replace snap_rr_p=0.846 if year==2006
replace snap_rr_p=0.828 if year==2007
replace snap_rr_p=0.803 if year==2008
replace snap_rr_p=0.839 if year==2009
replace snap_rr_p=0.806 if year==2010
replace snap_rr_p=0.797 if year==2011
replace snap_rr_p=0.813 if year==2012
replace snap_rr_p=0.813 if year==2013
replace snap_rr_p=0.813 if year==2014

replace ssdi_rr_dol=0.847 if year==1995
replace ssdi_rr_dol=0.844 if year==1996
replace ssdi_rr_dol=0.87 if year==1997
replace ssdi_rr_dol=1.128 if year==1998
replace ssdi_rr_dol=1.62 if year==1999
replace ssdi_rr_dol=1.087 if year==2000
replace ssdi_rr_dol=0.821 if year==2001
replace ssdi_rr_dol=0.793 if year==2002
replace ssdi_rr_dol=0.833 if year==2003
replace ssdi_rr_dol=0.854 if year==2004
replace ssdi_rr_dol=0.847 if year==2005
replace ssdi_rr_dol=0.86 if year==2006
replace ssdi_rr_dol=0.852 if year==2007
replace ssdi_rr_dol=0.846 if year==2008
replace ssdi_rr_dol=0.828 if year==2009
replace ssdi_rr_dol=0.826 if year==2010
replace ssdi_rr_dol=0.839 if year==2011
replace ssdi_rr_dol=0.82 if year==2012
replace ssdi_rr_dol=0.82 if year==2013
replace ssdi_rr_dol=0.82 if year==2014
replace ssdi_rr_p=0.847 if year==1995
replace ssdi_rr_p=0.844 if year==1996
replace ssdi_rr_p=0.87 if year==1997
replace ssdi_rr_p=1.128 if year==1998
replace ssdi_rr_p=1.62 if year==1999
replace ssdi_rr_p=1.087 if year==2000
replace ssdi_rr_p=0.821 if year==2001
replace ssdi_rr_p=0.793 if year==2002
replace ssdi_rr_p=0.833 if year==2003
replace ssdi_rr_p=0.854 if year==2004
replace ssdi_rr_p=0.847 if year==2005
replace ssdi_rr_p=0.86 if year==2006
replace ssdi_rr_p=0.852 if year==2007
replace ssdi_rr_p=0.846 if year==2008
replace ssdi_rr_p=0.828 if year==2009
replace ssdi_rr_p=0.826 if year==2010
replace ssdi_rr_p=0.839 if year==2011
replace ssdi_rr_p=0.82 if year==2012
replace ssdi_rr_p=0.82 if year==2013
replace ssdi_rr_p=0.82 if year==2014

replace ssi_rr_dol=0.817 if year==1995
replace ssi_rr_dol=0.936 if year==1996
replace ssi_rr_dol=0.987 if year==1997
replace ssi_rr_dol=0.968 if year==1998
replace ssi_rr_dol=0.965 if year==1999
replace ssi_rr_dol=1.047 if year==2000
replace ssi_rr_dol=1.051 if year==2001
replace ssi_rr_dol=1.063 if year==2002
replace ssi_rr_dol=1.083 if year==2003
replace ssi_rr_dol=1.117 if year==2004
replace ssi_rr_dol=1.253 if year==2005
replace ssi_rr_dol=1.256 if year==2006
replace ssi_rr_dol=1.278 if year==2007
replace ssi_rr_dol=1.057 if year==2008
replace ssi_rr_dol=1.16 if year==2009
replace ssi_rr_dol=1.21 if year==2010
replace ssi_rr_dol=1.286 if year==2011
replace ssi_rr_dol=1.275 if year==2012
replace ssi_rr_dol=1.275 if year==2013
replace ssi_rr_dol=1.275 if year==2014
replace ssi_rr_p=0.817 if year==1995
replace ssi_rr_p=0.936 if year==1996
replace ssi_rr_p=0.987 if year==1997
replace ssi_rr_p=0.968 if year==1998
replace ssi_rr_p=0.965 if year==1999
replace ssi_rr_p=1.047 if year==2000
replace ssi_rr_p=1.051 if year==2001
replace ssi_rr_p=1.063 if year==2002
replace ssi_rr_p=1.083 if year==2003
replace ssi_rr_p=1.117 if year==2004
replace ssi_rr_p=1.253 if year==2005
replace ssi_rr_p=1.256 if year==2006
replace ssi_rr_p=1.278 if year==2007
replace ssi_rr_p=1.057 if year==2008
replace ssi_rr_p=1.16 if year==2009
replace ssi_rr_p=1.21 if year==2010
replace ssi_rr_p=1.286 if year==2011
replace ssi_rr_p=1.275 if year==2012
replace ssi_rr_p=1.275 if year==2013
replace ssi_rr_p=1.275 if year==2014


replace ui_rr_dol=0.722 if year==1995
replace ui_rr_dol=0.61 if year==1996
replace ui_rr_dol=0.583 if year==1997
replace ui_rr_dol=0.537 if year==1998
replace ui_rr_dol=0.558 if year==1999
replace ui_rr_dol=0.684 if year==2000
replace ui_rr_dol=0.593 if year==2001
replace ui_rr_dol=0.53 if year==2002
replace ui_rr_dol=0.574 if year==2003
replace ui_rr_dol=0.676 if year==2004
replace ui_rr_dol=0.65 if year==2005
replace ui_rr_dol=0.62 if year==2006
replace ui_rr_dol=0.586 if year==2007
replace ui_rr_dol=0.676 if year==2008
replace ui_rr_dol=0.561 if year==2009
replace ui_rr_dol=0.597 if year==2010
replace ui_rr_dol=0.589 if year==2011
replace ui_rr_dol=0.616 if year==2012
replace ui_rr_dol=0.616 if year==2013
replace ui_rr_dol=0.616 if year==2014


replace frpl_rr_p=1.242 if year==1995
replace frpl_rr_p=1.123 if year==1996
replace frpl_rr_p=1.11 if year==1997
replace frpl_rr_p=1.106 if year==1998
replace frpl_rr_p=1.105 if year==1999
replace frpl_rr_p=1.152 if year==2000
replace frpl_rr_p=1.16 if year==2001
replace frpl_rr_p=1.152 if year==2002
replace frpl_rr_p=1.115 if year==2003
replace frpl_rr_p=1.162 if year==2004
replace frpl_rr_p=1.142 if year==2005
replace frpl_rr_p=1.148 if year==2006
replace frpl_rr_p=1.11 if year==2007
replace frpl_rr_p=1.138 if year==2008
replace frpl_rr_p=1.141 if year==2009
replace frpl_rr_p=1.138 if year==2010
replace frpl_rr_p=1.136 if year==2011
replace frpl_rr_p=1.145 if year==2012
replace frpl_rr_p=1.145 if year==2013
replace frpl_rr_p=1.145 if year==2014

replace wic_rr_p=0.605 if year==1995
replace wic_rr_p=0.778 if year==1996
replace wic_rr_p=0.753 if year==1997
replace wic_rr_p=0.726 if year==1998
replace wic_rr_p=0.715 if year==1999
replace wic_rr_p=0.696 if year==2000
replace wic_rr_p=0.788 if year==2001
replace wic_rr_p=0.8 if year==2002
replace wic_rr_p=0.767 if year==2003
replace wic_rr_p=0.773 if year==2004
replace wic_rr_p=0.793 if year==2005
replace wic_rr_p=0.795 if year==2006
replace wic_rr_p=0.778 if year==2007
replace wic_rr_p=0.788 if year==2008
replace wic_rr_p=0.865 if year==2009
replace wic_rr_p=0.88 if year==2010
replace wic_rr_p=0.872 if year==2011
replace wic_rr_p=0.846 if year==2012
replace wic_rr_p=0.846 if year==2013
replace wic_rr_p=0.846 if year==2014

***************************************	
// reporting rates derived using Larrimore, Mortenson, and Splinter 2022
// authors calculations
***************************************
* add centiles
egen double incid=group(suid pnum)
joinby incid year using "$joblessnessdir/SIPP_centiles.dta", unmatched(master) _merge(centile_merge)
	
* add reporting rates 
joinby inc_centile year using "$results/SIPP_respondent_reporting.dta", unmatched(master) _merge(resp_merge)
joinby inc_centile year using "$results/SIPP_dollars_reporting.dta", unmatched(master) _merge(dollar_merge)
	
rename sipp_part_reporting ui_rr_p_irs
rename sipp_dollars_reporting ui_rr_dol_irs
	
	
***************************
*** Controls
***************************
sort uniqueid order

*** Weights, state, kid and year of unemployment and UI weeks available based on year/month of job loss
foreach x in p5wgt statefip kids year  errp{
	gen temp=`x' if month_reljl==0
	bysort uniqueid: egen `x'_m0=max(temp)
	drop temp
}
for any statefip kids year : rename X X_m
for any statefip kids year : rename X_m0 X
	
** Self Employed and Temp Layoff -1 to -2 months before job loss
foreach x in templayoff self_employed   {
	gen temp=`x' if month_reljl==-1 | month_reljl==-2
	bysort uniqueid: egen `x'_pre=max(temp)
	drop temp
}

	
** Marital Status and Spouse Earn 12m and 6m before unemployment	
foreach x in married    {
	gen temp=`x' if month_reljl==-12
	bysort uniqueid: egen `x'_m12=max(temp)
	drop temp
}
	
foreach x in married   {
	gen temp=`x' if month_reljl==-6
	bysort uniqueid: egen `x'_m6=max(temp)
	drop temp
}
	
** Marital Status and Head/Spouse/Partner Status and Disabled Status in 1st Survey Month
foreach x in age married  errp worklimit_disa workprevent_disa  {
	gen temp=`x' if wave==1 & refmth==1 
	bysort uniqueid: egen `x'_sm0=max(temp)
	drop temp
}
	
	
** Flag Heads/Spouses/Partners in first survey month
gen head_spouse_sm0 = (errp_sm0==1 | errp_sm0==2 | errp_sm0==3)
gen head_spouse_partner_sm0 = (errp_sm0==1 | errp_sm0==2 | errp_sm0==3 | errp_sm0==10)
gen head_spouse = (errp==1 | errp==2 | errp==3)
gen head_spouse_partner = (errp==1 | errp==2 | errp==3 | errp==10)
	
***************************************
* Clean spousal earnings
* spouse_earn  only for married is below 
***************************************		

// spousal info OF reference persion based on errp of 3					
gen spouse_earn_f =.
gen spouse_earn = earn if errp_sm0==3  // spouse
bysort hhid panel wave refmth: egen max_spouse_earn=mean(spouse_earn)
bysort hhid panel wave refmth: egen max_spouse_earn1=max(spouse_earn)
bysort hhid panel wave refmth: egen max_spouse_earn2=min(spouse_earn)
replace max_spouse_earn=. if max_spouse_earn!=max_spouse_earn1 
replace max_spouse_earn=. if max_spouse_earn!=max_spouse_earn2 
drop max_spouse_earn1 max_spouse_earn2
replace spouse_earn_f =max_spouse_earn if errp_sm0==1 | errp_sm0==2 
		
drop spouse_earn max_spouse_earn
		
// spousal info OF reference person based on errp of 1 or 2
// ie this is info of reference person if spouse is the job loser
gen spouse_earn = earn if errp_sm0==1 
replace spouse_earn = earn if errp_sm0==2 
bysort hhid panel wave refmth: egen max_spouse_earn = max(spouse_earn)
bysort hhid panel wave refmth: egen max_spouse_earn1=max(spouse_earn)
bysort hhid panel wave refmth: egen max_spouse_earn2=min(spouse_earn)
replace max_spouse_earn=. if max_spouse_earn!=max_spouse_earn1 
replace max_spouse_earn=. if max_spouse_earn!=max_spouse_earn2 
drop max_spouse_earn1 max_spouse_earn2	
// here take the variable that is assigned to the reference person that has their spousal info (info for errp of 3 or 10)
// then fill in values that are assigned to the SPOUSE for the reference person (info for errp of 1 or 2)
replace spouse_earn_f =max_spouse_earn if errp_sm0==3 
drop spouse_earn max_spouse_earn
rename spouse_earn_f marsp_earn   /*here we distinguish final naming between married spouses and spoues and partners*/

sort panel hhid wave refmth

gen nadult_sm0 = 1 if wave==1 & refmth==1 & age>=18
replace nadult_sm0 = 0 if nadult_sm0==.

***************************************
* code insurance values for adults in household 
***************************************
foreach x in any_hins pub_hins priv_hins{
bysort hhid year_m wave imonth: egen anyA_`x' = max(`x') 
}

*create indicator for no kid having insurance in a household at a wave/month
foreach x in any_hins pub_hins priv_hins{
by hhid year_m wave imonth: egen noA1_`x' = min(`x')
gen noA_`x'= noA1_`x'==0
drop noA1_`x'
}

*create indicator for number with insurance
foreach x in any_hins pub_hins priv_hins{
by hhid year_m wave imonth: egen numA_`x' = total(`x')
}

foreach x in any_hins pub_hins priv_hins{
bysort hhid  year_m wave imonth: gen portA0_`x' = (numA_`x'/nadult_sm0)
}

*create proportion out of current kids in household
by hhid year_m wave imonth: egen numA_all =count(pnum) 
foreach x in any_hins pub_hins priv_hins{
bysort hhid year_m wave imonth: gen portA_`x' = (numA_`x'/numA_all)
}

*now merge in children
sort hhid year_m wave imonth
cap drop _merge
merge m:1 hhid year_m wave imonth using "$samples/chyeaout.dta"

tab _merge
drop if _merge==2
drop _merge

***************************************
** Flag 1st Survey Month Individual Report not being married or not head/spouse/partner
***************************************
sort uniqueid wave refmth 
bysort uniqueid: gen counter = _n
*browse uniqueid wave refmth counter
gen married_counter = counter if married==1
gen nmarried_counter = counter if married==0
bysort uniqueid: egen min_married_counter = min(married_counter)
bysort uniqueid: egen min_nmarried_counter = min(nmarried_counter)
gen head_spouse_partner_counter = counter if head_spouse_partner==1
gen nhead_spouse_partner = counter if head_spouse_partner==0
bysort uniqueid: egen min_head_spouse_partner_counter = min(head_spouse_partner_counter)
bysort uniqueid: egen min_nhead_spouse_partner_counter = min(nhead_spouse_partner)
gen head_spouse_counter = counter if head_spouse==1
gen nhead_spouse = counter if head_spouse==0
bysort uniqueid: egen min_head_spouse_counter = min(head_spouse_counter)
bysort uniqueid: egen min_nhead_spouse_counter = min(nhead_spouse)
	
***************************************	
* Construct Sample of Job Losers w various job tenure 
***************************************
for any str_mo str_da str_yr end_mo end_da end_yr: destring X, gen(X_n)
gen date_start=mdy(str_mo_n,str_da_n,str_yr_n)
gen date_start2=mdy(str_mo_n,1,str_yr_n)
gen date_int=mdy(imonth,1,year_m)
gen date_end=mdy(end_mo_n,end_da_n,end_yr_n)
gen tenure=date_end-date_start
format date_start date_end %dM_d,_CY
gen tenure_1year = (tenure>365 & tenure~=.)
gen tenure_6mo = (tenure>182 & tenure~=.)
gen tenure_9mo = (tenure>273 & tenure~=.)
gen tenure_3mo = (tenure>91 & tenure~=.)
gen tenure_18mo = (tenure>547 & tenure~=.)
gen tenure_2year = (tenure>730 & tenure~=.)
foreach x in tenure_2year tenure_18mo tenure_3mo tenure_9mo tenure_6mo tenure_1year {
	gen temp=`x' if month_reljl==0
	bysort uniqueid: egen `x'_m0=max(temp)
	drop temp
}
		
	
sort uniqueid month_reljl
drop tenure_1year 
rename tenure_1year_m0 tenure_1year

gen tenure2=date_int-date_start2
gen tenure_1year2 = (tenure2>365 & tenure2~=.)
bysort uniqueid: egen loser=total(loss)
replace loser=1 if loser>1 & loser!=.
replace tenure_1year2 = tenure_1year if loser==1

	
***************************************	
* Simulated instruments
***************************************
merge m:1 kids year statefip using "$ek_outputdata/instrument_sipp_y", gen(instm) keepus(sim_repl_sipp*)
	
drop if instm==2 // edited, merge==1 is non job loosers, keep these for now.
drop instm	
label var sim_repl_sipp "Sim. R-Rate"
for any statefip kids year: rename X X_m0
gen trend=year_m-1995
for any urate avweekwage: gen Xsq=X*X
for any urate avweekwage: gen Xcu=X*X*X


***************************************	
// Summary statistics
***************************************
sum loser earn age female hisp white black other lesshs hs somecol college married kids_sm0  if  head_spouse_partner==1 & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54  [aw=p5wgt]
sum loser earn age female hisp white black other lesshs hs somecol college married kids_sm0  if tenure_1year2==1 & head_spouse_partner==1  & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54   [aw=p5wgt]
	
sum loser earn age female hisp white black other lesshs hs somecol college married kids_sm0  if  head_spouse_partner==1 & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1  [aw=p5wgt]
sum loser earn age female hisp white black other lesshs hs somecol college married kids_sm0  if tenure_1year2==1 & head_spouse_partner==1  & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1  [aw=p5wgt]

pause
	
*save never losers here for running in 01f_createcontrol	
save "$samples/summstats.dta", replace 

use "$samples/summstats.dta", clear 

	
***************************************
***TABLE A1 REPLICATION *******
***************************************
* log file that outputs summary stats
cap log close

log using "$outputlog/summtab1_`today'.log", replace


* column 1 : All job losers 
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if  head_spouse_partner==1 & month_reljl==-4 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1 & loser==1 [aw=p5wgt]

*column 2: job losers with tenure		
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if tenure_1year==1 & head_spouse_partner==1  & month_reljl==-4 & age_sm0>=25 & age_sm0<=54  & templayoff_pre~=1 & loser==1 [aw=p5wgt]

*column 3: All workers 
sum  earn age female hisp white black other lesshs hs somecol college married kids_sm0  if  head_spouse_partner==1 & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1  [aw=p5wgt]
	
*column 4: all workers with tenure: 
sum  earn age female hisp white black other lesshs hs somecol college married kids_sm0  if tenure_1year2==1 & head_spouse_partner==1  & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1  [aw=p5wgt]
***********************************

***************************************
*** Save Dataset for Control *******
***************************************
preserve
	
keep if loser==0
save "$samples/controlsetup.dta", replace
	
restore

keep if loser==1

***************************************
** Program Participation Variables
***************************************
for any ss_amt ssi_amt h_ss_amt h_ssi_amt h_wic_amt uiamt h_fs_amt h_tanf_amt sevrpay enrgyamt: gen d_X=(X>0 & X~=.)
for any ss_amt ssi_amt h_ss_amt h_ssi_amt h_wic_amt uiamt h_fs_amt h_tanf_amt sevrpay enrgyamt: replace d_X=. if X==.
for any ss_amt ssi_amt h_ss_amt h_ssi_amt h_wic_amt uiamt h_fs_amt h_tanf_amt sevrpay enrgyamt: replace d_X=d_X*100
replace frp_lunch = frp_lunch*100

***************************************
*ever ui receipt
***************************************
sort uniqueid month_reljl
by uniqueid: egen uismp_temp = max(d_uiamt) if month_reljl>0
replace uismp_temp = 0 if uismp_temp==.
by uniqueid: egen uismp = max(uismp_temp)
order uniqueid month_reljl d_uiamt uismp_temp uismp
replace uismp=1 if uismp==100
drop uismp_temp 
gen nouismp = (uismp==0)


*number of job losers by ui
tab uismp if tenure_1year==1 & head_spouse_partner==1  & month_reljl==-4 & age_sm0>=24 & age_sm0<=55  & templayoff_pre~=1 & loser==1 , missing 


* job losers who get ui
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  hpov100  if tenure_1year==1 & head_spouse_partner==1  & month_reljl==-4 & age_sm0>=25 & age_sm0<=54  & templayoff_pre~=1 & loser==1  & uismp==1 [aw=p5wgt]
		
* job losers who dont get ui
sum earn age female hisp white black other lesshs hs somecol college married kids_m0 hpov100 if tenure_1year==1 & head_spouse_partner==1  & month_reljl==-4 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1 & loser==1 & uismp~=1 [aw=p5wgt]


log close

***************************************
*** Other Summary Statistics *******
***************************************
log using "$outputlog/01_CleanData_part2_`today'.log", replace
   
* Keep only those with at least one spell
keep if loser==1
		
// match ages in admin data
foreach x in age {
	gen temp=`x' if month_reljl==0
	bysort uniqueid: egen `x'_m0=max(temp)
	drop temp
}	
		
*****************************	
// Summary statistics
***************************************
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if  head_spouse_partner==1 & wave==1 & refmth==1 & age_sm0>=24 & age_sm0<=55  [aw=p5wgt]
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if tenure_1year==1 & head_spouse_partner==1  & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54   [aw=p5wgt]
	
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if  head_spouse_partner==1 & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54 & templayoff_pre~=1  [aw=p5wgt]
sum earn age female hisp white black other lesshs hs somecol college married kids_m0  if tenure_1year==1 & head_spouse_partner==1  & wave==1 & refmth==1 & age_sm0>=25 & age_sm0<=54  & templayoff_pre~=1  [aw=p5wgt]
pause

***************************************	
* Create month in which spell occurred 
***************************************
tab month_reljl, m
for any max min: bysort uniqueid: egen X_month_reljl=X(month_reljl)
drop if month_reljl<-12 | month_reljl>=24
tab month_reljl, m

gen month_reljl_temp = month_reljl
replace month_reljl_temp=22 if month_reljl_temp==23
forvalues i=-12(2)20 {
	replace month_reljl_temp=`i' if month_reljl_temp==`i'+1
}
tab month_reljl_temp month_reljl
		 
tab month_reljl_temp, gen(dumspell)
for num 1/18: gen sim_spellX=sim_repl_sipp*dumspellX
	
sum month_reljl_temp month_reljl if dumspell6==1
cap drop jobloss
gen jobloss=month_reljl>=0
for any kids_m statefip_m year_m: egen Xloss=group(X jobloss)

gen post=month_reljl>0 & month_reljl!=.
replace post=. if month_reljl==.
gen sim_post=0
replace sim_post=sim_repl_sipp if month_reljl>=0
label var sim_post "R-rate * Loss"
	
***Added below to create control
gen earn_any=(earn>0)

***************************************
* Labels 
***************************************
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

***************************************
*quickly recode living in public housing for regressions and getsbrnt "getting subsidy"
***************************************
replace pubhsing = . if pubhsing==-1
replace pubhsing = (pubhsing==1) if missing(pubhsing)~=1
tab pubhsing, missing

*note, this excludes those living in public housing
replace getsbrnt = . if getsbrnt==-1
replace getsbrnt = (getsbrnt==1) if missing(getsbrnt)~=1
tab getsbrnt, missing
gen d_housing = (pubhsing==1 | getsbrnt==1)
replace d_housing =d_housing*100
sum d_housing
mdesc d_housing


***************************************
*** Construct Different Partilly and Fully Balanced Samples of Job Losers  
***************************************
gen balance_pre12post24 = (max_month_reljl>=23 & max_month_reljl ~=. & min_month_reljl<=-12 & min_month_reljl ~=.)
gen balance_pre12 = (min_month_reljl<=-12 & min_month_reljl ~=.)
gen balance_pre12post12 = (max_month_reljl>=12 & max_month_reljl ~=. & min_month_reljl<=-12 & min_month_reljl ~=.)
gen balance_pre6 = (min_month_reljl<=-6 & min_month_reljl ~=.)

tab balance_pre12post24, m 
tab balance_pre12, m 
tab balance_pre6, m 
tab balance_pre12post12, m 


***************************************
*** Summary Statistics to Check against NBER version of Elira's paper
***************************************
sum age female black hisp college married  kids_m0  uiamt any_hins priv_hins pub_hins [aw=p5wgt_m0]


***************************************
*** Additional Summary Statistics and Cleaning
***************************************

sum age female black hisp college married kids_m0   if month_reljl==0 [aw=p5wgt_m0]
sum age female black hisp college married kids_m0   if tenure_1year==1 & month_reljl==0 [aw=p5wgt_m0]

// check missing oservations
mdesc work uiamt priv_hins any_hins pub_hins ss_amt  h_ss_amt ssi_amt  ssi_st_amt h_ssi_amt fs_amt tanf_amt ///
wic_amt frp_lunch  hinc hearn hpov100 hpov200 hpov400

pause

drop if work==. // observations just from policy data and not merged into SIPP

rename head_spouse head_spouse_current  
rename head_spouse_partner head_spouse_partner_current

rename head_spouse_sm0 head_spouse
rename head_spouse_partner_sm0 head_spouse_partner

gen all = 1

** Flag whether 1st job loss happens at least 6 months after start of survey for individual
gen counter_jl = counter if month_reljl==0
bysort uniqueid: egen max_counter_jl=max(counter_jl)

tab max_counter_jl  if tenure_1year==1 & head_spouse_partner==1 [aw=p5wgt_m0], m
tab max_counter_jl  if tenure_1year==1 & head_spouse_partner==1 & married_sm0==1 [aw=p5wgt_m0], m

** Tab how many people married in first survey month become unmarried before jobloss
cap drop flag
gen flag=(min_nmarried_counter<max_counter_jl & min_nmarried_counter~=. & max_counter_jl~=.) // dummy for whether not married before jobloss 
cap drop flag
gen flag=(married==0 & married~=.) // dummy for whether EVER not married
bysort uniqueid: egen max_flag = max(flag)
sum  max_flag  if married_sm0==1 & tenure_1year==1 & head_spouse_partner==1 & month_reljl==0  [aw=p5wgt_m0]
sum  max_flag  if  tenure_1year==1 & head_spouse_partner==1 & month_reljl==0    [aw=p5wgt_m0]

tab married_sm0 if  tenure_1year==1 & head_spouse_partner==1  [aw=p5wgt_m0]

** Tab how many people head/spouse in first survey month become not head/spouse before jobloss
cap drop flag
gen flag=(min_nhead_spouse_partner_counter<max_counter_jl & min_nhead_spouse_partner_counter~=. & max_counter_jl~=.) // whether not head/spouse BEFORE job loss
sum flag min_nhead_spouse_partner_counter max_counter_jl if married_sm0==1 & tenure_1year==1 & head_spouse_partner==1  [aw=p5wgt_m0]
sum flag min_nhead_spouse_partner_counter max_counter_jl if  tenure_1year==1 & head_spouse_partner==1  [aw=p5wgt_m0]
cap drop flag max_flag
gen flag=(head_spouse_partner_current==0 & head_spouse_partner_current~=.) // dummy for whether EVER not head or spouse
bysort uniqueid: egen max_flag = max(flag)
sum max_flag   if married_sm0==1 & tenure_1year==1 & head_spouse_partner==1 & month_reljl==0   [aw=p5wgt_m0]
sum max_flag   if  tenure_1year==1 & head_spouse_partner==1  & month_reljl==0  [aw=p5wgt_m0]

* Tab how many people in sample by disability type
gen nodisa = ((worklimit_disa_sm0==0))
rename worklimit_disa_sm0 workl_dis_sm0
sum nodisa  workl_dis_sm0 workprevent_disa_sm0 if  tenure_1year==1 & head_spouse_partner==1  & month_reljl==0  [aw=p5wgt_m0]

gen year_jl = year_m if month_reljl==0
bysort uniqueid: egen max_year_jl = max(year_jl)
drop year_jl
rename max_year_jl year_jl




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

save "$samples/sipp_reg.dta", replace 
	
log close 
