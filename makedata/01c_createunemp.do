******************************************************
***************** 		CREATE UNEMPLOYMENT VARIABLES		***********************
			******************************************************

 
foreach syear in 96 01 04 08 {  
	di ""
	di "THIS LOOP IS FOR YEAR `syear'"
	di ""
				 
	use "${outdata}/sipp_annual`syear'", clear
	capture qui destring suid, replace
	capture qui destring addid, replace
	

		 
	*** Create samples of interest
	sort suid pnum sex wave year mth

	* First see to drop those that by mistake seem to be same individuals
	bysort suid pnum sex: gen diff_byear=brthyr-brthyr[_n+1]
	bysort suid pnum sex: gen diff_age=age-age[_n+1]
	gen mistake=1
	bysort suid pnum sex: replace mistake=0 if (diff_byear>=-1 & diff_byear<=1) | diff_byear==.
	bysort suid pnum sex: egen temp=max(mistake)
	replace mistake=temp
	drop if mistake==1
	drop temp
	
	* Create order variable
	sort suid pnum sex wave year mth
	bysort suid pnum sex: gen order=_n

	* Create LFP variables. Categories are: 1 job all month; 2 job all month, absent 1+ weeks (no layoff), 
	// 3 job all month, absent 1+ weeks (layoff); 4 job 1+ weeks (no layoff); 5 job 1+ weeks (layoff); 6 no job (layoff); 
	// 7 no job (some layoff), 8 no job (no layoff)
	sort suid pnum sex wave year mth
	replace esr=. if esr==-1 | esr==0
	gen nlf = esr==8        
	gen work = esr==1 | esr==2              
	gen nowork = esr==3 | esr==4 | esr==5 | esr==6 | esr==7 | esr==8
	gen unempl = esr==3 | esr==5 | esr==6 | esr==7
	for any nlf work nowork unempl: replace X=. if esr==.

	* Self-employed     
	gen self_employed = numbus>=1 & numbus!=.
	replace self_employed=. if esr==.
	replace self_employed = 1 if work==1 & (ws1amt==0 | ws1amt==.)       // drop self-employed

	by suid pnum sex: egen perc_semployed=mean(self_employed)

	** Create job separation variable
	sort suid pnum sex order
	gen jobsep=0
	by suid pnum sex: replace jobsep = work[_n-1]==1 & nowork==1
	by suid pnum sex: egen jobsep_num=sum(jobsep)

	** Create job loss variable: separation and at least one week on layoff/looking for work
	gen jobloss=0
	by suid pnum sex: replace jobloss = work[_n-1]==1 & unempl==1 //& self_employed[_n-1]!=1          

	by suid pnum sex: egen jobloss_num=sum(jobloss)
	gen jobloser=jobloss_num>0

	* Create spell number
	* Spell number numbers job losses in order of them happening over time
	* Periods are flagged as the months the indiv in unemployed after a jobloss AND the months the indiv is working before
	* that specific job loss
	* here jobloss is just defined as a transition from work to unemp, not conditional on reason
	gen spell=.
	sort suid pnum sex jobloss order
	by suid pnum sex jobloss: replace spell = _n if jobloss==1
	sort suid pnum sex order
	by suid pnum sex: replace spell=spell[_n-1] if jobloss!=1 & unempl==1
	by suid pnum sex: replace spell=spell[_n+1] if jobloss[_n+1]==1 & work==1
	forvalues i=1/60 {
		qui replace spell = spell[_n+1] if suid==suid[_n+1] & pnum==pnum[_n+1] & ///
			order==order[_n+1]-1 & work==1 & work[_n+1]==1 in 1/l

	}       
	replace spell=0 if spell==. & jobloser==0   // 0 means never spell, missing means spell has ended

	* Create variables of lagged work status
	sort suid pnum sex order
	for any 1 2 3 4 5 6 7 8 9 10 11: bysort suid pnum sex: gen esr_lX = esr[_n-X]

	*** Other eliminations
	* Drop repeats
	sort suid pnum wave refmth
	drop if suid==suid[_n-1] & pnum==pnum[_n-1] & panel==panel[_n-1] & wave==wave[_n-1] & refmth==refmth[_n-1]

	*** OLD EXCLUSIONS from JACULLEN
	* Getting rid of anyone not there for at least 3 months
	gen index=1
	egen temp=sum(index), by (suid pnum sex) 
	gen mthpres3 = temp>=3
	drop index temp

	* Now sorting according to month and locating first 3 consecutive months where individual is
		//work, defined as esr = 1, ws1amt>0, and no selfemp. 
	gen mthwrk3=0
	replace mthwrk3=1 if esr==1 & ws1amt>=0 & ws1amt~=.
	
	sort suid pnum sex order
	replace mthwrk=mthwrk3[_n-1]+1 if suid==suid[_n-1] & pnum==pnum[_n-1] & mthwrk3[_n-1]>0 & ///
		 mthwrk3>0 in 2/l
	qui by suid pnum: replace mthwrk3=0 if mthwrk3==1 & mthwrk3[_n+2]~=3
	qui by suid pnum: replace mthwrk3=0 if mthwrk3==2 & mthwrk3[_n+1]~=3
	qui by suid pnum: replace mthwrk3=0 if mthwrk3~=1
	replace mthwrk3=mthwrk3[_n-1] if mthwrk3[_n-1]>0 & suid==suid[_n-1] & pnum==pnum[_n-1] in 2/l

	*** JOB SEPARATION VARIABLES
	* Define UI receipt (during any point in spell) variable
	sort suid pnum sex order
	gen ui_yn2 = (uiamt>0 & uiamt!=.) | (suid==suid[_n+1] & pnum==pnum[_n+1] & unempl==1 & ///
		 unempl[_n+1]==1 & spell==spell[_n+1] & uiamt[_n+1]>0 & uiamt[_n+1]!=.)
	sort suid pnum sex spell order
	by suid pnum sex spell: egen uireceipt=sum(ui_yn)
	replace uireceipt=uireceipt>0

	* Identify temporary layoffs (by esr==3 at ANY point in spell)
	by suid pnum sex spell: egen templayoff=sum(esr==3)
	replace templayoff=templayoff>0

	* Identify people that were laid off
	gen layoff=0
	replace layoff=1 if whystop1==1
	by suid pnum sex spell: egen temp=max(layoff)
	replace layoff=temp
	drop temp

	* Identify people that retired/school/housewife
	gen retother=0
	replace retother=1 if (whystop1==2 | whystop1==3 | whystop1==4 | whystop1==7 | whystop1==14) 
	by suid pnum sex spell: egen temp=max(retother)
	replace retother=temp
	drop temp

	*** GENERATE NEW VARIABLES
	* Months in sample
	sort suid pnum sex wave year mth
	gen mark=1
	by suid pnum: egen mthsinsamp = sum(mark)
	drop mark

	* Kids
	rename nkidshl kids
	replace kids=4 if kids>4 & kids!=.
	gen children = kids

	* Education
		gen ed=higrade
		replace ed=1 if ed==31
		replace ed=3 if ed==32
		replace ed=5 if ed==33
		replace ed=7 if ed==34
		replace ed=ed-26 if ed>34 & ed<=38
		replace ed=12 if ed==39 | ed==40
		replace ed=13 if ed>=41 & ed<=43
		replace ed=16 if ed==44
		replace ed=18 if ed>44
		drop higrade
      

	* Marital dummy and other indicators
	gen mardum=0 
	replace mardum=1 if ms==1 | ms==2
	replace mardum=. if ms==.
	
	
	if panel>=1996 & panel<2004{ 
	gen hisp = (ethncty>=20 & ethncty<=28 )
	}
		else {
		gen hisp= (ethncty==1) 
		}
		
	tab hisp, missing


	gen white = race==1 & hisp==0
	gen black = race==2 & hisp==0
	gen other = race>2 & hisp==0
	

	gen fulltime = uhours1[_n-1]>35

	***************************************
	*** VARIABLES FOR UI CALCULATOR. Borrowed from Chetty
	***************************************
	* Generate calendar qtr indicator
	gen calqtr=0
	replace calqtr=1 if mth>=1 & mth<=3
	replace calqtr=2 if mth>=4 & mth<=6
	replace calqtr=3 if mth>=7 & mth<=9
	replace calqtr=4 if mth>=10 & mth<=12
	label var calqtr "calendar quarter"

	* Generate quarter in sample (calendar quarter #1-8 for each obs so we can collapse)
	gen count=1
	sort suid pnum panel wave refmth
	replace count=count[_n-1]+1 if suid==suid[_n-1] & pnum==pnum[_n-1] in 2/l

	gen mark=1
	egen check=sum(mark), by (suid pnum panel year calqtr)
	gen qtr=1 if count==1
	replace qtr=0 if count==1 & check<3
	drop check mark

	gen mark=0
	replace mark=1 if qtr~=.
	replace mark=1 if suid==suid[_n-1] & pnum==pnum[_n-1] & panel==panel[_n-1] & calqtr~=calqtr[_n-1] in 2/l

	sort suid pnum panel mark count
	qui by suid pnum panel: replace qtr=qtr[_n-1]+1 if mark==1 & mark[_n-1]==1
	drop mark
	sort suid pnum panel count
	replace qtr=qtr[_n-1] if qtr==.
	label var qtr "quarter in sample"

	***CREATE QUARTERLY WAGE HISTORY AND DEFINE INPUTS FOR UI LAWS ///
		  //-own earnings, total income spouse total income, and family total income are all computed nominal wages
	*Note: use info only from ws1 for own earn because 2nd job is usually job gotten after unemp ends
	preserve
	egen qearn=sum(ws1amt+ws2amt), by (suid pnum qtr)
	egen ws1qearn=sum(ws1amt), by (suid pnum qtr)
	egen fqinc=sum(finc), by (suid pnum qtr)
	egen qwks = sum(wks), by (suid pnum qtr)

	* Generate 3-month sums if agent loses job before calendar quarter of info
	gen mark=0
	replace mark=1 if count<4
	egen temp1=sum(ws1amt+ws2amt), by (suid pnum panel mark)
	egen temp2=sum(finc), by (suid pnum panel mark)
	egen temp4=sum(wks), by (suid pnum panel mark)
	replace qearn=temp1 if qtr==0
	replace fqinc=temp2 if qtr==0
	replace qwks=temp4 if qtr==0
	drop temp1 temp2 temp4 mark count

	collapse (mean) qearn ws1qearn fqinc qwks, by (suid pnum qtr)
	
	
	
	********
	****HERE IS WHERE WE CONSTRUCT ANNUAL WAGES< USEFUL FOR TAXSIM

	* Generate lagged quarterly wages
	for num 1/5: qui by suid pnum: gen qearn_lX=qearn[_n-X] 
	for num 1/5: qui by suid pnum: gen ws1qearn_lX=ws1qearn[_n-X] 
	for num 1/5: qui by suid pnum: gen qwks_lX=qwks[_n-X] 

	* Compute base period wage, but ignore the lag when data limits it
	gen bpw=4*qearn_l1 if qtr<=2
	replace bpw=2*(qearn_l1+qearn_l2) if qtr==3
	replace bpw=(4/3)*(qearn_l1+qearn_l2+qearn_l3) if qtr==4
	replace bpw=(qearn_l1+qearn_l2+qearn_l3+qearn_l4) if qtr==5
	replace bpw=(qearn_l2+qearn_l3+qearn_l4+qearn_l5) if qtr>=6
	gen annwg=bpw if qtr<=4
	replace annwg=(qearn_l1+qearn_l2+qearn_l3+qearn_l4) if qtr>=5

	gen hq1w=qearn_l1 if qtr<=2
	replace hq1w=max(qearn_l1,qearn_l2) if qtr==3
	replace hq1w=max(qearn_l1,qearn_l2,qearn_l3) if qtr==4
	replace hq1w=max(qearn_l1,qearn_l2,qearn_l3,qearn_l4) if qtr>=5

	gen hq2w=qearn_l1 if qtr<=2
	replace hq2w=min(qearn_l1,qearn_l2) if qtr==3
	replace hq2w=max((qearn_l1<hq1w)*qearn_l1, (qearn_l2<hq1w)*qearn_l2, (qearn_l3<hq1w)*qearn_l3) if qtr==4
	replace hq2w=max((qearn_l1<hq1w)*qearn_l1, (qearn_l2<hq1w)*qearn_l2, (qearn_l3<hq1w)*qearn_l3, ///
		(qearn_l4<hq1w)*qearn_l4) if qtr>=5

	gen cv_earn=sqrt(((qearn_l1-bpw/4)^2+(qearn_l2-bpw/4)^2)/2)/(bpw/4) if qtr==3
	replace cv_earn=sqrt(((qearn_l1-bpw/4)^2+(qearn_l2-bpw/4)^2+(qearn_l3-bpw/4)^2)/3)/(bpw/4) if qtr==4
	replace cv_earn=sqrt(((qearn_l1-bpw/4)^2+(qearn_l2-bpw/4)^2+(qearn_l3-bpw/4)^2+(qearn_l4-bpw/4)^2)/4) ///
		/(bpw/4) if qtr>=5

	* Generate annual family info
	for num 1/4: qui by suid pnum: gen fqinc_lX=fqinc[_n-X] 
	gen fanninc=4*fqinc_l1 if qtr<=2
	replace fanninc=2*(fqinc_l1+fqinc_l2) if qtr==3
	replace fanninc=(4/3)*(fqinc_l1+fqinc_l2+fqinc_l3) if qtr==4
	replace fanninc=(fqinc_l1+fqinc_l2+fqinc_l3+fqinc_l4) if qtr>=5

	keep suid pnum qtr fanninc qearn_l* ws1qearn_l* qwks_l* bpw hq1w hq2w annwg cv_earn
	tempfile unemp`syear'
	save `unemp`syear'', replace
	restore

	* Merge back
	sort suid pnum qtr
	merge suid pnum qtr using `unemp`syear''
	drop _merge

	sort suid pnum year mth

	gen othuiamt=.
	rename uhours1 uhours

if `syear'==96 | `syear'==01{
				
	keep suid addid famid pnum entry panel wave mth year refmth qtr statefip p5wgt age sex white hisp black other ethncty  ///
		mardum   ed hnp fnp kids hinc hearn finc fearn totinc earn earn qearn_l* bpw hq1w hq2w annwg cv_earn fanninc  ///
		spell mthwrk3 mthpres3 templayoff uhour* qwks_l* unempl nowork work nlf esr esr_l* layoff retother order  ///
		joblos* jobsep* whystop1 ui_yn* uireceipt uiamt* whynot* *_amt* ws1qearn_l*     ///
		 stdate1 enddate1 stlemp1_yn eeno1 numbus hiown  hisrc ///
		   htype hiind caidcov carecov  hpov fpov ///
		   h_wic_amt wic_amt wic_amt_flag reason_ssa numk_lunch any_lunch frp_lunch_type   ///
		   frp_lunch  any_lunch  errp hhid  ///
		   getfs getwic getenrgy enrgyamt   sevrpay othrlump pubhsing getsbrnt phrent ///
		   worklimit_disa workprevent_disa children self_employed
}


if `syear' ==04 | `syear'==08 {
	keep suid addid famid pnum entry panel wave mth year refmth qtr statefip p5wgt age sex white hisp black other ethncty  ///
		mardum   ed hnp fnp kids hinc hearn finc fearn totinc earn earn qearn_l* bpw hq1w hq2w annwg cv_earn fanninc  ///
		spell mthwrk3 mthpres3 templayoff uhour* qwks_l* unempl nowork work nlf esr esr_l* layoff retother order  ///
		joblos* jobsep* whystop1 ui_yn* uireceipt uiamt* whynot* *_amt* ws1qearn_l*     ///
		 stdate1 enddate1 stlemp1_yn eeno1 numbus hiown  hisrc ///
		   htype hiind caidcov carecov  hpov fpov ///
		   h_wic_amt wic_amt wic_amt_flag reason_ssa numk_lunch any_lunch frp_lunch_type numk_breakf frp_breakf_type ///
		   frp_lunch frp_breakf any_lunch any_breakf errp hhid  ///
		   getfs getwic getenrgy enrgyamt   sevrpay othrlump pubhsing getsbrnt  epaothr5 epubhstp phrent ///
		   worklimit_disa workprevent_disa children self_employed
}
		
	

	compress
	tempfile spell_`syear'
	save `spell_`syear'', replace
}

***********************
*** Append data and clean
***********************
use `spell_96', clear
foreach syear in 01 04 08 {
	append using `spell_`syear''
}

save "${outdata}/sipp_cleaned_temp.dta", replace

******************************************************
***************** 		CREATE adult DATASET		***********************
			******************************************************

use "${outdata}/sipp_cleaned_temp.dta", clear

keep if statefip<60 & statefip!=.

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

* Age
drop if age<18 | age>64
gen agegr=.
replace agegr=1 if age>=18 & age<25
for any 2 3 4 5 6 7 8: replace agegr=X if age>=20+X*5-5 & age<20+X*5
replace agegr=8 if age>=55


* Marital status
rename mardum married

* Education
replace ed=. if ed==-1
gen edgr=1 if ed<=11
replace edgr=2 if ed==12 
replace edgr=3 if ed>=13 & ed<=15
replace edgr=4 if ed>=16
drop if ed==.
tab edgr, g(educ)
gen college = edgr==4
gen lesshs = edgr==1
gen hs = edgr==2
gen somecol = edgr==3




*************************************
*** Add other state-year variables
*************************************
sort statefip
merge m:1 statefip using "${outdata}/statecodes_all.dta"
keep if _merge==3
drop _merge

*** Merge UI max and mins
gen nndate=year*10000+1*100 if mth<7
replace nndate=year*10000+7*100 if mth>=7

sort year nndate statefip
merge m:1 nndate statefip kids using "${ek_data}/uilaws_updated.dta"
keep if _merge==3
drop _merge	


*** State controls and variables
merge m:1 year statefip using "${outdata}/state_data", gen(statem)
keep if year>=1990
keep if statem==3
drop statem

for any max min annwg: gen X_cpi = X*2.37017/cpi
label var max_cpi "Max"
label var min_cpi "Min"
rename mth imonth

*** HIIND / MCAID: 0 or -1 NA, 1 Y, 2 N
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

capture drop _I*

** do this BEFORE CPI ADJUSTEMENT
do "${makedata}/01c_a_calc.do"
do "${makedata}/01c_b_calcelig.do"



compress
save "${outdata}/sipp_cleaned.dta", replace
