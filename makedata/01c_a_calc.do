/*
***********************
File created on 05/03/2013
Last Updated: 04/01/2017


This do file assigns each person a UI benefit based on their wage and, in some states, their number
of kids. It does so by matching the wage to a state-specific benefit schedule, which has a min, a 
max, and a slope (benefits = a*wage) in between the min and max. The max and mins are taken from the
data file uilaws_updated, which EK contracted by merging the uilaws.dta from RC and DB as well as
information regarding max and mins from Gruber's wba.do file.

To construct the lawassing_complete.do file, EK used the folloing sources:
	- For years 1967-1984, EK used the relevant code in wba.do, Gruber's original code (from 
	Patricia Anderson). 
	- For years 1984-2000 she used the lawassign.do file that is publicly avaiable from Chetty.
	- For years 2000-2007 she used David Brown's code (student of Gruber).

She clearly marked where each piece of the code is coming from, for future references. JG, RC and
DB stand for code from Jon Gruber, Raj Chetty of David Brown.

On 09/03/2013, we decided to ignore the allowance for non-working spouses in Illinois. In reality
other states have also allowances for non-working spouses (which Chetty and Gruber did not model), 
so keeping just Illinois seems inconsistent. Moreover, spousal labor supply is responsive to 
replacement rates, so we may have issue of endogeneity.

***
NOTES REGARDING PROGRAM:

input variables used:
	- wg = weekly wage
		- use monthly earnings on job 1, over weeks in month
	- annwg = annual earnings
		- use earnings on job 1 for the wave times three
	- hq1w = quarterly wage? 		// EK adds this. Note: on Chetty's code it appears are average 
									of last two quarters. CHECK this variable.	
	- children = number of kids
	- tao = tax rate (calculated in program tax.do)
	- mardum = dummy for being married
	- tti = total family income for year
	- nndate = year, month, day date
	- state = state number

output variables created:
	- wba - weekly UI benefit
	- min - minimum benefit
	- max - maximum benefit
	- wba_at - after-tax UI benefit
	- repl_at - after-tax replacement rate
	
***
BEFORE RUNNING THIS PROGRAM:
Must have the PSID merged with the uilaws_complete.dta (or uilaws_orig_grubchetty.dta if want to 
add just original data)

-------------------------------------------------------------------- 
*/

if c(username)=="davidsimon"{

global outputdata "$dir/Intergen Sipp/child SIPP longterm/analysis/samples/JobLosers_SafetyNet/"
}

if c(username)=="chloeeast"{

global outputdata "$dir/child SIPP longterm//analysis/samples/JobLosers_SafetyNet"
}

cd "$outputdata"
net from "https://www.nber.org/stata"
net describe taxsim32
net install taxsim32




	   **********************************************
***************** USE CODES FROM JG, RC and DB*****************
	   **********************************************
*Note: if not otherwise indicated, code comes from JG	

sum qearn_l1 qearn_l2, d
gen hq12sum = hq1w+hq2w
gen hq13sum = bpw*(3/4)
gen wg = annwg/52

replace min=0 if min==.		// RC does this
replace max=0 if max==.

*** Generate marital status variable  (1 for single, 2 for joint, 3 for head of household.
	
gen mstat=.
replace mstat=1 if married==0 & kids==0
replace mstat=2 if married==1
replace mstat=1 if married==0 & kids>0

* Generate dependents variable
gen depx=kids
rename state stateold
gen state=0

for any annwg bpw hq1w hq2w qearn_l1 qearn_l2: replace X=0 if X==.

	* For TAXSIM Calculator
	gen pwages = annwg
	
	gen id = _n
	preserve 
	keep id year state mstat pwages 
	taxsim35, replace
	sort id 
	tempfile taxsimtemp 
	save `taxsimtemp', replace 
	restore 
	
	sort id 
	merge id using `taxsimtemp'
	
	gen tao = fiitax/annwg
	replace tao=0 if tao==.
	
	

	drop state
	rename stateold state
	
	if c(username)=="davidsimon"{

cd "/Users/davidsimon/Documents/GitHub/JobLosers_SafetyNet/makedata/"
}

if c(username)=="chloeeast"{

cd "/Users/chloeeast/Documents/GitHub/JobLosers_SafetyNet/makedata"	
}

cd "$outputdata"
	
	
gen wba=.

// Alabama
replace wba = (1/24)*(hq12sum)/2 if st==1  /*note average together the sum of the two ways of calculating quarterly earnings, divide by 24?  must be state slope? */
replace wba=(1/26)*(hq12sum)/2 if st==1 & nndate>=20060100		// Enacted 4/18


// Arizona
replace wba=(1/25)*hq1w if st==2


// Arkansas
replace wba=(1/52)*hq12sum if st==3
replace wba=(1/26)*hq1w if st==3 & nndate>19910700


// California
*680101-760101
replace wba=25 if st==4 & nndate<19760101 & 13*wg<598
replace wba=25+(1/28)*(hq1w-598) if st==4 & nndate<19760101 & hq1w>=598 & hq1w<1438
replace wba=56+(1/30)*(hq1w-1438) if st==4 & nndate<19760101 & hq1w>=1438 & hq1w<1588

replace wba=61+(1/40)*(hq1w-1588) if st==4 & nndate<19720701 & hq1w>=1588
replace wba=65 if st==4 & nndate<19720701 & hq1w>=1748
replace wba=min(61+(1/40)*(hq1w-1588),75) if st==4 & nndate>=19720701 & nndate<19730700 & hq1w>=1588
replace wba=min(61+(1/40)*(hq1w-1588),90) if st==4 & nndate>=19730700 & nndate<19760101 & hq1w>=1588

*760101-800101
replace wba=30 if st==4 & nndate>=19760101 & nndate<19800100 & hq1w<738
replace wba=31+(1/28)*(hq1w-738) if st==4 & nndate>=19760101 & nndate<19800100 & hq1w>=738 & hq1w<1438
replace wba=56+(1/30)*(hq1w-1438) if st==4 & nndate>=19760101 & nndate<19800100 & hq1w>=1438 & hq1w<1588
replace wba=61+(1/40)*(hq1w-1588) if st==4 & nndate>=19760101 & nndate<19800100 & hq1w>=1588 & hq1w<3308
replace wba=104 if st==4 & nndate>=19760101 & nndate<19800100 & hq1w>=3308

*1/80-4/81
replace wba=30 if st==4 & nndate>=19800100 & nndate<19810500 & hq1w<689
replace wba=31+(1/31)*(hq1w-689) if st==4 & nndate>=19800100 & nndate<19810500 & hq1w>=689 & hq1w<2000
replace wba=74+(1/43)*(hq1w-2000) if st==4 & nndate>=19800100 & nndate<19810500 & hq1w>=2000 & hq1w<3000
replace wba=97+(1/50)*(hq1w-3000) if st==4 & nndate>=19800100 & nndate<19810500 & hq1w>=3000 & hq1w<4160
replace wba=120 if st==4 & nndate>=19800100 & nndate<19810500 & hq1w>=4160

*5/81-12/81
replace wba=30 if st==4 & nndate>=19810500 & nndate<19820100 & hq1w<689
replace wba=31+(1/31)*(hq1w-689) if st==4 & nndate>=19810500 & nndate<19820100 & hq1w>=689 & hq1w<2000
replace wba=74+(1/38)*(hq1w-2000) if st==4 & nndate>=19810500 & nndate<19820100 & hq1w>=2000 & hq1w<3000
replace wba=100+(1/50)*(hq1w-3000) if st==4 & nndate>=19810500 & nndate<19820100 & hq1w>=3000 & hq1w<4511
replace wba=130 if st==4 & nndate>=19810500 & nndate<19820100 & hq1w>=4511

*82
replace wba=30 if st==4 & nndate>=19820100 & nndate<19830100 & hq1w<689
replace wba=31+(1/29)*(hq1w-689) if st==4 & nndate>=19820100 & nndate<19830100 & hq1w>=689 & hq1w<2000
replace wba=76+(1/38)*(hq1w-2000) if st==4 & nndate>=19820100 & nndate<19830100 & hq1w>=2000 & hq1w<3000
replace wba=102+(1/48)*(hq1w-3000) if st==4 & nndate>=19820100 & nndate<19830100 & hq1w>=3000 & hq1w<4641
replace wba=136 if st==4 & nndate>=19820100 & nndate<19830100 & hq1w>=4641

*830101-900101
replace wba=30 if st==4 & nndate>=19830100 & nndate<19900100 & hq1w<689
replace wba=31+(1/30)*(hq1w-689) if st==4 & nndate>=19830100 & nndate<19900100 & hq1w>=689 & hq1w<2000
replace wba=75+(1/37)*(hq1w-2000) if st==4 & nndate>=19830100 & nndate<19900100 & hq1w>=2000 & hq1w<3000
replace wba=102+(1/45)*(hq1w-3000) if st==4 & nndate>=19830100 & nndate<19900100 & hq1w>=3000 & hq1w<4000
replace wba=124+(1/37)*(hq1w-4000) if st==4 & nndate>=19830100 & nndate<19900100 & hq1w>=4000 & hq1w<5533
replace wba=166 if st==4 & nndate>=19830100 & nndate<19900100 & hq1w>=5533

*900101+
replace wba=40 if st==4 & nndate>=19900100 & nndate<19920100 & hq1w<949
replace wba=40+(0.0338)*(hq1w-949) if st==4 & nndate>=19900100 & nndate<19920100 & hq1w>=949 & hq1w<1976
replace wba=75+(0.0265)*(hq1w-1976) if st==4 & nndate>=19900100 & nndate<19920100 & hq1w>=1976 & hq1w<3029
replace wba=102+(0.0217)*(hq1w-3029) if st==4 & nndate>=19900100 & nndate<19920100 & hq1w>=3029 & hq1w<4043   
replace wba=124+(0.027)*(hq1w-4043) if st==4 & nndate>=19900100 & nndate<19920100 & hq1w>=4043 & hq1w<4967
replace wba=min(0.39*(hq1w/13),max) if st==4 & nndate>=19900100 & nndate<19920100 & hq1w>=4967

*Note: Use CA law for 1992-2001
local cutoff_ls 949 975 1001 1027 1053 1079 1118 1144 1170 1196 1222 1248 1287 1313 1339 ///
	1365 1404 1430 1456 1495 1521 1547 1586 1612 1638 1677 1703 1742 1768 1807 1833 1872 ///
	1898 1937 1976 2002 2041 2067 2106 2145 2171 2210 2249 2288 2327 2353 2392 2431 2470 ///
	2509 2548 2587 2626 2665 2704 2743 2782 2821 2860 2899 2938 2990 3029 3068 3107 3159 ///
	3198 3237 3289 3328 3380 3419 3471 3510 3562 3601 3653 3705 3744 3796 3848 3900 3939 ///
	3991 4043 4080 4117 4154 4191 4228 4265 4302 4339 4376 4413 4450 4487 4524 4561 4598 ///
	4635 4672 4709 4746 4783 4820 4857 4894 4931 4967
	
forvalues i=0/110 {

	if `i'==0 {
		replace wba=40 if hq1w<949 & st==4 & nndate>=19920100 & nndate<20020100
	}
	else if `i'>0 & `i'<110 {
		local j=`i'+1
		local lb: word `i' of `cutoff_ls'
		local ub: word `j' of `cutoff_ls'
		replace wba=40+`i' if hq1w>=`lb' & hq1w<`ub' & st==4 & nndate>=19920100 & nndate<20020100
	}
	else {
		replace wba=0.39*hq1w/13 if hq1w>=4967 & st==4 & nndate>=19920100 & nndate<20020100
	}
}

*Note: EK used Lalumia's numbers for this
local cutoff_ls 949 975 1001 1027 1053 1079 1118 1144 1170 1196 1222 1248 1287 1313 ///
	1339 1365 1404 1430 1456 1495 1521 1547 1586 1612 1638 1677 1703 1742 1768 1807 ///
	1833 1872 1898 1937 1976 2002 2041 2067 2106 2145 2171 2210 2249 2288 2327 2353 ///
	2392 2431 2470 2509 2548 2587 2626 2665 2704 2743 2782
	
forvalues i=0/57 {

	if `i'==0 {
		replace wba = 40 if hq1w<949 & st==4 & nndate>=20020100 & nndate<20030100
	}
	else if `i'>0 & `i'<57 {
		local j=`i'+1
		local lb: word `i' of `cutoff_ls'
		local ub: word `j' of `cutoff_ls'
		replace wba=40+`i' if hq1w>=`lb' & hq1w<`ub' & st==4 & nndate>=20020100 & nndate<20030100
	}
	else {
		replace wba=0.45*hq1w/13 if hq1w>=2782 & st==4 & nndate>=20020100 & nndate<20030100
	}
}

*Note: from Jan 03 onwards it is from 1/23 to 1/26 
local cutoff_ls 949 975 1001 1027 1053 1079 1118 1144 1170 1196 1222 1248 1287 1313 ///
	1339 1365 1404 1430 1456 1495 1521 1547 1586 1612 1638 1677 1703 1742 1768 1807 ///
	1833

forvalues i=0/31 {

	if `i'==0 {
		replace wba = 40 if hq1w<949 & st==4 & nndate>=20030100
	}
	else if `i'>0 & `i'<31 {
		local j=`i'+1
		local lb: word `i' of `cutoff_ls'
		local ub: word `j' of `cutoff_ls' & st==4 & nndate>=20030100
		replace wba=40+`i' if hq1w>=`lb' & hq1w<`ub' & st==4 & nndate>=20030100
	}
	else {
		replace wba=0.5*hq1w/13 if hq1w>=1833 & st==4 & nndate>=20030100
	}
}


// Colorado
replace wba=.6*(1/26)*hq12sum if st==5


// Connecticut
replace wba=(1/26)*hq1w if st==6
replace wba=(1/52)*hq12sum if st==6 & nndate>=19940100
replace wba=min if st==6 & wba<=min
replace wba=max if st==6 & wba>=max

replace wba=wba+min(5*children,30) if st==6 & wba>min & wba<max & nndate<19690101 
replace wba=wba+min(5*children,35) if st==6 & wba>min & wba<max & nndate>=19690101 & nndate<19691001
replace wba=wba+min(5*children,38) if st==6 & wba>min & wba<max & nndate>=19691001 & nndate<19710100
replace wba=wba+min(5*children,.5*wba) if st==6 & wba>min & wba<max	& nndate>=19710100 & nndate<19810100
replace wba=wba+min(10*children,.5*wba) if st==6 & wba>min & wba<max & nndate>=19810100 & nndate<19850100
replace wba=wba+min(10*children,.5*wba,50) if st==6 & wba>min & wba<max & nndate>=19850100 & nndate<20000100
replace wba=wba+min(15*children,wba,75) if st==6 & wba>min & wba<max & nndate>=20000100			// EK adds this


// Delaware
replace wba=(1/25)*hq1w if st==7 & nndate<19750715
replace wba=(1/26)*hq1w if st==7 & nndate>=19750715 & nndate<19840100
replace wba=(1/78)*hq13sum if st==7 & nndate>=19840100 & nndate<19870100
replace wba=(1/46)*hq12sum if st==7 & nndate>=19880100


// District of Columbia
replace wba=(1/23)*hq1w if st==8 & nndate<19930700
replace wba=(1/26)*hq1w if st==8 & nndate>=19930700
replace wba=wba+min(children,3) if st==8 & nndate<19850100
replace wba=wba+min(5*children,20) if st==8 & nndate>=19850100 & nndate<19980100
replace wba=wba+min(15*children,0.5*wba,50) if st==8 & nndate>=20090700 & nndate<20110100


// Florida
replace wba=0.5*wg if st==9 & nndate<19960700
replace wba=(1/26)*hq1w if st==9 & nndate>=19960700


// Georgia
replace wba=(1/50)*hq12sum if st==10 & nndate<19970700
replace wba=(1/48)*hq12sum if st==10 & nndate>=19970700 & nndate<20020700  		// RC and EK
replace wba=(1/46)*hq12sum if st==10 & nndate>=20020700 & nndate<20060700		// EK
replace wba=(1/44)*hq12sum if st==10 & nndate>=20060700 & nndate<20080100		// EK
replace wba=(1/42)*hq12sum if st==10 & nndate>=20080100							// EK


// Idaho
replace wba=(1/26)*hq1w if st==11


// Illinois
*-750706
replace wba=0 if st==12 & nndate<19750706 & hq1w<200
replace wba=10+(1/20)*(hq1w-200) if st==12 & nndate<19750706 & hq1w>=200 & hq1w<548
replace wba=min(28+(1/33)*(hq1w-548),max) if st==12 & nndate<19720206 & hq1w>=548
replace wba=28+(1/33)*(hq1w-548) if st==12 & nndate>=19720206 & nndate<19750706 & hq1w>=548 & hq1w<1274
replace wba=min(50+(1/26)*(hq1w-1274),max) if st==12 & nndate>=19720206 & nndate<19750706 & hq1w>=1274

*750706-onwards
replace wba=(1/2)*(1/26)*hq12sum if st==12 & nndate>=19750706 & nndate<19830401
replace wba=0.67*(1/26)*hq12sum if st==12 & children>0 & nndate>=19750706 & nndate<19830401

replace wba=.48*(1/26)*hq12sum if st==12 & nndate>=19830401 & nndate<19880100
replace wba=0.624*(1/26)*hq12sum if st==12 & children>0 & nndate>=19830401 & nndate<19880100

replace wba = .49*(1/26)*hq12sum if st==12 & nndate>=19880100 & nndate<19930100
replace wba = .64*(1/26)*hq12sum if st==12 & children>0 & nndate>=19880100 & nndate<19930100
replace wba = .643*(1/26)*hq12sum if st==12 & children>0 & nndate>=19910100 & nndate<19920100

replace wba = .495*(1/26)*hq12sum if st==12 & nndate>=19930100						 // EK confirms these
replace wba = .655*(1/26)*hq12sum if st==12 & children>0 & nndate>=19930100

*Jan 2004 and following
	// EK looked at various documents for this. In 2013, for non-working spouses the allowance is 9% of 
	// the wage, while for children it is around 17%. It is hard to get this info for previous years, but
	// EK thinks it should be like this most years. In another document: "The dependent child allowance 
	// rate with respect to each benefit year beginning in calendar year 2011 may not be greater than 
	// 17.4%. For calendar years 2012 and 2013, the dependent allowance rate is 17.0%"
replace wba=0.48*(1/26)*hq12sum if st==12 & nndate>=20040100 & nndate<20090100	// DB
replace wba=(0.48+.174)*(1/26)*hq12sum if st==12 & children>0 & nndate>=20040100 & nndate<20090100 	// EK

replace wba=0.47*(1/26)*hq12sum if st==12 & nndate>=20090100						// EK
replace wba=(0.47+.174)*(1/26)*hq12sum if st==12 & children>0 & nndate>=20090100 & nndate<20120100 	// EK
replace wba=(0.47+.172)*(1/26)*hq12sum if st==12 & children>0 & nndate>=20120100						// EK


// Indiana
replace wba=(1/25)*hq1w if st==13 & nndate<19780102
replace wba=.043*hq1w if st==13 & nndate>=19780102 & nndate<19910700
replace wba = 0.05*min(hq1w,1000) + 0.04*max(hq1w-1000,0) if st==13 & nndate>=19910700 & nndate<19950700	// EK
replace wba = 0.05*min(hq1w,1750) + 0.04*max(hq1w-1750,0) if st==13 & nndate>=19950700 & nndate<19980700	// EK
replace wba = 0.05*min(hq1w,2000) + 0.04*max(hq1w-2000,0) if st==13 & nndate>=19980700 & nndate<20120700						// EK
replace wba = 0.47*(hq1w/13) if st==13 & nndate>=20120700						// EK


// Iowa: following Levine for later years
replace wba=(1/22)*hq1w if st==14 & nndate<19720102
replace wba=(1/20)*hq1w if st==14 & nndate>=19720102 & nndate<19790701

replace wba=(1/23)*hq1w if st==14 & children==0 & nndate>=19790701 
replace wba=(1/22)*hq1w if st==14 & children==1 & nndate>=19790701 
replace wba=(1/21)*hq1w if st==14 & children==2 & nndate>=19790701 
replace wba=(1/20)*hq1w if st==14 & children==3 & nndate>=19790701 
replace wba=(1/19)*hq1w if st==14 & children>=4 & nndate>=19790701 


// Kansas
replace wba=(1/25)*hq1w if st==15 & nndate<19790701
replace wba=.0425*hq1w if st==15 & nndate>=19790701


// Kentucky
replace wba=(1/25)*hq1w if st==16 & nndate<19730107
replace wba=(1/23)*hq1w if st==16 & nndate>=19730107 & nndate<19820700
replace wba=.01185*annwg if st==16 & nndate>=19820700 & nndate<19990100
replace wba=.01235*annwg if st==16 & nndate>=19990100 & nndate<20010100		// EK
replace wba=.013078*annwg if st==16 & nndate>=20010100 & nndate<20120100	// EK
replace wba=.011923*annwg if st==16 & nndate>=20120100						// EK


// Louisiana
replace wba=(1/20)*hq1w if st==17 & wg<875 & nndate<19880700
replace wba=(1/25)*hq1w if st==17 & wg>=875 & nndate<19880700
replace wba=(1/25)*(1/4)*annwg if st==17 & nndate>=19880700 & nndate<20090700

replace wba=(1/25)*(1/4)*annwg*1.05*1.32 if st==17 & nndate>=20090700				// EK. Weird
replace wba=(1/25)*(1/4)*annwg*1.05*1.15 if st==17 & nndate>=20100100				// EK. Weird


// Maine
replace wba=(1/25)*hq1w if st==18 & nndate<19700104
replace wba=(1/22)*hq1w if st==18 & nndate>=19700104 & nndate<20020100
replace wba=(1/22)*(hq12sum/2) if st==18 & nndate>=20020100

replace wba=wba+min(5*children,.5*wba) if st==18 & nndate>=19760105 & nndate<19890700
replace wba=wba+min(10*children,.5*wba) if st==18 & nndate>=19890700


// Maryland
replace wba=(1/24)*hq1w if st==19

replace wba=wba+min(2*children,8) if st==19 & nndate<=19680707
replace wba=wba+min(3*children,12) if st==19 & nndate>=19680707 & nndate<=19870100
replace wba=wba+min(4*children,16) if st==19 & nndate>=19870100 & nndate<19870700
replace wba=wba+min(6*children,24) if st==19 & nndate>=19870700 & nndate<19880700
replace wba=wba+min(8*children,32) if st==19 & nndate>=19880700 & nndate<19890700
replace wba=wba+min(8*children,40) if st==19 & nndate>=19890700


// Massachusetts
replace wba =(1/26)*hq1w if st==20
replace wba = 14 if st==20 & hq1w<300 & nndate>19730101
replace wba = 14 + (1/22)*(hq1w - 300) if st==20 & hq1w>=300 & hq1w<542 & nndate>19730101
replace wba = 25 + (1/42)*(hq1w - 542) if st==20 & hq1w>=542 & hq1w<858 & nndate>19730101
replace wba=(1/26)*hq1w if st==20 & hq1w>=858 & nndate>19730101 
replace wba=0.5*wg if st==20 & hq1w>=858 & nndate>=20010100		// EK			

replace wba=wba+min(6*children,wg) if st==20 & nndate<19700701
replace wba=wba+min(6*children,(1/2)*wba) if st==20 & nndate>=19700701 & nndate<=19870309
replace wba=wba+min(15*children,(1/2)*wba) if st==20 & nndate>=19870309 & nndate<=19880100
replace wba=wba+min(25*children,(1/2)*wba) if st==20 & nndate>=19880100 


// Michigan
replace wba=.6*wg if st==21 & nndate<19810301
replace wba=wba+(76-46)*children/4 if st==21 & nndate<19700510
replace wba=wba+(87-53)*children/4 if st==21 & nndate>=19700510 & nndate<19720131
replace wba=wba+(92-56)*children/4 if st==21 & nndate>=19720131 & nndate<19740609
replace wba=wba+(106-67)*children/4 if st==21 & nndate>=19740609 & nndate<19750608
replace wba=wba+(136-97)*children/4 if st==21 & nndate>=19750701 & nndate<19810301

replace wba=.7*(1-tao)*wg if st==21 & nndate>=19870100 & nndate<19950100		// EK
replace wba=.67*(1-tao)*wg if st==21 & nndate>=19950100 & nndate<20010100		// EK
replace wba= .041*hq1w + min(6*children,30) if st==21 & nndate>=20010100		// EK


// Minnesota
replace wba=.5*wg if st==22 & nndate<19750707
replace wba=.62*wg if st==22 & nndate>=19750707 & nndate<19760105
replace wba=.6*wg if wg<85 & st==22 & nndate>=19760105 & nndate<19880100
replace wba=.6*85+.4*(wg-85) if wg>=85 & wg<170 & st==22 & nndate>=19760105 & nndate<19880100
replace wba=.6*85+.4*85+.5*(wg-170) if wg>=170 & st==22 & nndate>=19760105 & nndate<19880100
replace wba = 1/26*hq1w if st==22 & nndate>=19880100


// Mississippi
replace wba=(1/26)*hq1w if st==23


// Missouri
replace wba=(1/25)*hq1w if st==24 & nndate<19750107
replace wba=(1/20)*hq1w if st==24 & nndate>=19750107 & nndate<19800100
replace wba=.045*hq1w if st==24 & nndate>=19800100 & nndate<19980700		// DB
replace wba=.040*hq1w if st==24 & nndate>=19980700 & nndate<20060100		// DB
replace wba=0.0375*hq1w if st==24 & nndate>=20060100 & nndate<20070100	// DB
replace wba=.040*hq1w if st==24 & nndate>=20070100						// DB


// Montana
replace wba=(1/26)*hq1w if st==25 & nndate<19860700
replace wba=.49*wg if st==25 & nndate>=19860700 & nndate<19910700
replace wba=.019*hq12sum if st==25 & nndate>=19910700


// Nebraska
replace wba=12+max(.04*(hq1w-200),0) if st==26 & nndate<20010100		// DB	
replace wba=.5*wg if st==26 & nndate>=20010100							// DB	


// Nevada
replace wba=(1/25)*hq1w if st==27
replace wba=min if st==27 & wba<=min
replace wba=max if st==27 & wba>=max
replace wba=wba+min(5*children,20,.06*13*wg) if st==27 & nndate<19710704


// New Hampshire
*-770903
replace wba=0 if annwg<600 & st==28 & nndate<19770903
replace wba=min(54,13+.009*(annwg-600)) if st==28 & nndate<19691005 & annwg>=600
replace wba=min(60,13+.009*(annwg-600)) if st==28 & nndate>=19691005 & nndate<19710701		//Da: possible mistake? mising "annwg>=600"
replace wba=min(75,14+.011*(annwg-600)) if st==28 & nndate>=19710701 & nndate<19730700 & annwg>=600
replace wba=min(80,14+.011*(annwg-600)) if st==28 & nndate>=19730700 & nndate<19750401 & annwg>=600
replace wba=min(95,14+.011*(annwg-600)) if st==28 & nndate>=19750401 & nndate<19770903 & annwg>=600

*Levine
*770903-810901
replace wba=0 if st==28 & nndate>=19770903 & nndate<19830700 & annwg<1200
replace wba=min(21+.011*(annwg-1200),102) if st==28 & nndate>=19770903 & nndate<19790901 & annwg>=1200
replace wba=min(21+.01*(annwg-1200),114) if st==28 & nndate>=19790901 & nndate<19830700 & annwg>=1200

*810901-830701
replace wba=0 if st==28 & nndate>=19810901 & nndate<19830700 & annwg<1700
replace wba=26+.01*(annwg-1700) if st==28 & nndate>=19810901 & nndate<19830700 & annwg>=1700 & annwg<10500
replace wba=min(114+.003*(annwg-10500),132) if st==28 & nndate>=19810901 & nndate<19830700 & annwg>=10500

*830701-850901
replace wba=0 if st==28 & nndate>=19830700 & nndate<19850901 & annwg<1700
replace wba=26+.01*(annwg-1700) if st==28 & nndate>=19830700 & nndate<19850901 & annwg>=1700 & annwg<10500
replace wba=min(114+.003*(annwg-10500),141) if st==28 & nndate>=19830700 & nndate<19850901 & annwg>=10500

*850901-870701
replace wba=0 if st==28 & nndate>=19850901 & nndate<19870700 & annwg<2600
replace wba=36+.01*(annwg-2600) if st==28 & nndate>=19850901 & nndate<19870700 & annwg>=2600 & annwg<10500
replace wba=min(114+.003*(annwg-10500),150) if st==28 & nndate>=19850901 & nndate<19870700 & annwg>=10500

*870701-890702
replace wba=0 if st==28 & nndate>=19870700 & annwg<2800
replace wba=39+.0103*(annwg-2800) if st==28 & nndate>=19870700 & nndate<19890700 & annwg>=2800 & annwg<9500
replace wba=108+.006*(annwg-9500) if st==28 & nndate>=19870700 & nndate<19890700 & annwg>=9500 & annwg<11500
replace wba=min(120+.003*(annwg-11500),156) if st==28 & nndate>=19870700 & nndate<19890700 & annwg>=11500

*890702-910630
replace wba=0 if st==28 & nndate>=19890700 & nndate<19910630 & annwg<2800
replace wba=35+.0117*(annwg-2800) if st==28 & nndate>=19890700 & nndate<19910630 & annwg>=2800 & annwg<9500
replace wba=108+.006*(annwg-9500) if st==28 & nndate>=19890700 & nndate<19910630 & annwg>=9500 & annwg<11500
replace wba=120+.003*(annwg-11500) if st==28 & nndate>=19890700 & nndate<19910630 & annwg>=11500 & annwg<15500
replace wba=min(132+.004*(annwg-15500),162) if st==28 & nndate>=19890700 & nndate<19900100 & annwg>=15500
replace wba=132+.004*(annwg-15500) if st==28 & nndate>=19900100 & nndate<19910630 & annwg>=15500 & annwg<21500
replace wba=min(156+.006*(annwg-21500),168) if st==28 & nndate>=19900100 & nndate<19910630 & annwg>=21500

*910630-920329
replace wba=0 if st==28 & nndate>=19910630 & nndate<19920329 & annwg<2800
replace wba=34+.0116*(annwg-2800) if st==28 & nndate>=19910630 & nndate<19920329 & annwg>=2800 & annwg<9500
replace wba=min(108+.0045*(annwg-9500),179) if st==28 & nndate>=19910630 & nndate<19920329 & annwg>=9500

*920329-current
// EK gathers this info from Jan 1992 laws: wba=0.8 to 1.4 % of annual wages. Min is 32, max is 188.
	// In July 1993 the max goes up to 196, and wba=0.8 to 1.1%. In later years, max increases. In July
	// 1997 wba=1.0 to 1.1%. From then on it is always the same, just the mins and maxs change. EK looked
	// at current benefit table, and it actually it between 1.1 and 1.0%, without any precise pattern.

replace wba=0.008*annwg if st==28 & nndate>=19900100 	// EK: eligibility (should do this for all states?)
replace wba=0.01*annwg if st==28 & nndate>=19970700


// New Jersey: depending on Levine for post '85 - also, state source says no change from '85 to '94
replace wba=(2/3)*wg if st==29 & nndate<19850100
replace wba=.6*wg if st==29 & nndate>=19850100
replace wba = max if wba>max & st==29
replace wba = min if wba<min & st==29

replace wba=min(wba+.07*wg,max) if children==1 & st==29 & nndate>=19850100
replace wba=min(wba+.11*wg,max) if children==2 & st==29 & nndate>=19850100
replace wba=min(wba+.15*wg,max) if children>=3 & st==29 & nndate>=19850100


// New Mexico
replace wba=(1/26)*hq1w if st==30 & nndate<20030700						// DB
replace wba=0.525*hq1w/13 if st==30 & nndate>=20030700 & nndate<20050100		// EK
replace wba=0.50*hq1w/13 if st==30 & nndate>=20050100 & nndate<20050700 		// EK
replace wba=0.525*hq1w/13 if st==30 & nndate>=20050700 & nndate<20070700 		// EK
replace wba=0.535*hq1w/13 if st==30 & nndate>=20070700 & nndate<20090700		// EK
replace wba=0.6*hq1w/13 if st==30 & nndate>=20090700 & nndate<20100700			// EK
replace wba=0.535*hq1w/13 if st==30 & nndate>=20100700							// EK

replace min=58 + min(15*children,15) if st==30 & nndate>=20040100 & nndate<20050100
replace min=57 + min(15*children,16) if st==30 & nndate>=20050100 & nndate<20050700
replace min=60 + min(15*children,15) if st==30 & nndate>=20050700 & nndate<20060100
replace min=62 + min(15*children,13) if st==30 & nndate>=20060100 & nndate<20070100
replace min=65 + min(25*children,0.5*65) if st==30 & nndate>=20070100 & nndate<20070700
replace min=62 + min(25*children,0.5*62) if st==30 & nndate>=20070700 & nndate<20080100

replace max=290 + min(15*children,60) if st==30 & nndate>=20040100 & nndate<20050100
replace max=300 + min(15*children,50) if st==30 & nndate>=20050100 & nndate<20050700
replace max=300 + min(15*children,60) if st==30 & nndate>=20050700 & nndate<20060100
replace max=312 + min(15*children,48) if st==30 & nndate>=20060100 & nndate<20070100
replace max=326 + min(15*children,60) if st==30 & nndate>=20070100 & nndate<20070100
replace max=332 + min(25*children,100) if st==30 & nndate>=20070700

replace wba=max if wba>max & st==30
replace wba=min if wba<min & st==30

replace wba = wba+min(15*children,60) if st==30 & wba>min & wba<max & nndate>=20040100 & nndate<20070100
replace wba = wba+min(25*children,100) if st==30 & wba>min & wba<max & nndate>=20070100 & nndate<20110700
replace wba = wba+min(25*children,50) if st==30 & wba>min & wba<max & nndate>=20110700


// New York: note that there is a separate schedule before 680902, but I didn't bother putting it in since I really only use 69+
replace wba = 20 if st==31 & wg<31 & nndate<19870100
replace wba = 21 if st==31 & wg>=31 & wg<33 & nndate<19870100
replace wba = 22 if st==31 & wg>=33 & wg<35 & nndate<19870100
replace wba = 23 if st==31 & wg>=35 & wg<37 & nndate<19870100
replace wba = 24 if st==31 & wg>=37 & wg<39 & nndate<19870100
replace wba = 25 if st==31 & wg>=39 & wg<42 & nndate<19870100
replace wba = 26 if st==31 & wg>=42 & wg<44 & nndate<19870100
replace wba = 27 if st==31 & wg>=44 & wg<47 & nndate<19870100
replace wba = 28 if st==31 & wg>=47 & wg<49 & nndate<19870100
replace wba = 29 if st==31 & wg>=49 & wg<52 & nndate<19870100
replace wba = 30 if st==31 & wg>=52 & wg<55 & nndate<19870100
replace wba = 31 if st==31 & wg>=55 & wg<58 & nndate<19870100
replace wba = 32 if st==31 & wg>=58 & wg<61 & nndate<19870100
replace wba = 33 if st==31 & wg>=61 & wg<64 & nndate<19870100
replace wba = 34 if st==31 & wg>=64 & wg<67 & nndate<19870100
replace wba = 35 if st==31 & wg>=67 & wg<70 & nndate<19870100
replace wba = 36 if st==31 & wg>=70 & wg<73 & nndate<19870100
replace wba = 1/2*wg if st==31 & wg>=73 & nndate<19870100

replace wba=.5*wg if st==31 & nndate>=19870100 & nndate<20000100	// EK
replace wba=(1/26)*hq1w if st==31 & nndate>=20000100 & nndate<20150100 & hq1w>=3575	// EK
replace wba=(1/25)*hq1w if st==31 & nndate>=20000100 & nndate<20150100 & hq1w<3575	// EK
replace wba=(1/26)*hq1w if st==31 & nndate>=20150100 & hq1w>=4000	// EK
replace wba=(1/25)*hq1w if st==31 & nndate>=20150100 & hq1w<4000	// EK


// North Carolina
replace wba = 12 if annwg<650 & st==32 & nndate<19690801
replace wba = 14 if annwg>=650 & annwg<750 & st==32 & nndate<19690801
replace wba = 16 + (annwg-750)/100 if annwg>=750 & annwg<2350 & st==32 & nndate<19690801
replace wba = 32 if annwg>=2350 & annwg<2600 & st==32 & nndate<19690801
replace wba = 34 if annwg>=2600 & annwg<3000 & st==32 & nndate<19690801
replace wba = 36 if annwg>=3000 & annwg<3400 & st==32 & nndate<19690801
replace wba = 38 if annwg>=3400 & annwg<3800 & st==32 & nndate<19690801
replace wba = 40 if annwg>=4200 & annwg<4200 & st==32 & nndate<19690801
replace wba = 42 if annwg>=4200 & st==32 & nndate<19690801

replace wba = 12 if annwg<650 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 14 if annwg>=650 & annwg<750 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 16 + 2*(annwg-750)/100 if annwg>=750 & annwg<1150 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 24 if annwg>=1150 & annwg<1300 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 26 if annwg>=1300 & annwg<1450 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 28 if annwg>=1450 & annwg<1600 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 30 if annwg>=1600 & annwg<1800 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 32 if annwg>=1800 & annwg<2000 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 34 if annwg>=2000 & annwg<2200 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 36 if annwg>=2200 & annwg<2500 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 38 if annwg>=2500 & annwg<2800 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 40 if annwg>=2800 & annwg<3100 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 42 if annwg>=3100 & annwg<3400 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 44 if annwg>=3400 & annwg<3800 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 46 if annwg>=3800 & annwg<4200 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 48 if annwg>=4200 & annwg<4600 & st==32 & nndate>=19690801 & nndate<19740801
replace wba = 50 if annwg>=4600 & st==32 & nndate>=19690801 & nndate<19740801

replace wba = (1/52)*hq12sum if st==32 & nndate>=19740801 & nndate<19950100
replace wba = 1/26*hq1w if st==32 & nndate>=19950100


// North Dakota
replace wba=(1/26)*hq1w if st==33 & nndate<19870700							// EK.
replace wba=(1/65)*hq12sum if st==33 & nndate>=19870700 & nndate<19880700	// EK. 2 highest quarters
replace wba=(1/65)*(hq12sum + 0.5*hq2w)  if st==33 & nndate>=19880700		// 1/65 of (2 highest quarters + 0.5 of third quarter)


// Ohio
replace wba=(1/2)*wg if st==34


// Oklahoma
replace wba=(1/26)*hq1w if st==35 & nndate<19780102
replace wba=(1/25)*hq1w if st==35 & nndate>=19780102
replace wba=(1/23)*hq1w if st==35 & nndate>=19980700			// RC


// Oregon
replace wba=.0125*annwg if st==36


// Pennsylvania: No info pre-Levine - assume that ratio is constant at 0.537, which is average from '78-'81
		   // data from '90 onwards shows that structure didn't change post-Levine
replace min = min - min(5*children,8) if st==37 & nndate>=19720101	// We added this in uilaws, so subtract it here to follow Levine
replace max = max - min(5*children,8) if st==37 & nndate>=19720101
	   
replace wba = 0.537*wg if st==37 & nndate<19780101
replace wba = min if wba<min & st==37 & nndate<19780101
replace wba = min if st==37 & nndate>=19780101 & nndate<19810100 & hq1w<263
replace wba = min+(1/25)*(hq1w-263) if st==37 & nndate>=19720101 & nndate<19810100 & hq1w>=263
replace wba = min if st==37 & nndate>=19810100 & hq1w<813
replace wba = min+(1/25)*(hq1w-813) if st==37 & nndate>=19810100 & hq1w>=813
replace wba = max if wba>max & st==37
replace wba=wba+ min(5+(children-1)*3,8) if children>0 & st==37 & nndate>=19720101


// Rhode Island
replace wba=.55*wg if st==38 & nndate<19880100
replace wba=.6*wg if st==38 & nndate>=19880100 & nndate<19900100
replace wba=.0462*hq1w if st==38 & nndate>=19900100
replace wba=.0438*hq1w if st==38 & nndate>=20120700
replace wba=.0415*hq1w if st==38 & nndate>=20130700
replace wba=.0385*hq1w if st==38 & nndate>=20140700

replace wba = wba + min(3*children,12) if st==38 & nndate<19680707
replace wba = wba + min(5*children,20) if st==38 & nndate>=19680707 & nndate<19860100
replace wba = wba + min(children,5)*max(5,.05*wba) if st==38 & nndate>=19860100 & nndate<19880100
replace wba = wba + min(children,5)*max(10,.05*wba) if st==38 & nndate>=19880100 & nndate<20110100
replace wba = wba + min(min(children,5)*max(15,.05*wba),50,.25*wba) if st==38 & nndate>=20110100


// South Carolina
replace wba=(1/26)*hq1w if st==39


// South Dakota
replace wba=(1/22)*hq1w if st==40 & nndate<19810701
replace wba=(1/26)*hq1w if st==40 & nndate>=19810701


// Tennessee
replace wba=(1/26)*hq1w if st==41 & nndate<19800701

*7/80-6/83
replace wba=20 if st==41 & nndate>=19800701 & nndate<19830700 & hq1w<494
replace wba=20+(1/26)*(hq1w-494) if st==41 & nndate>=19800701 & nndate<19830700 & hq1w>=494 & hq1w<1820
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19800701 & nndate<19830700 & hq1w>=1820 & hq1w<3420
replace wba=110 if st==41 & nndate>=19800701 & nndate<19830700 & hq1w>=3420

*7/83-7/1/89
replace wba=30 if st==41 & nndate>=19830700 & nndate<19890700 & hq1w<754
replace wba=30+(1/26)*(hq1w-754) if st==41 & nndate>=19830700 & nndate<19890700 & hq1w>=754 & hq1w<1820

replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19830700 & nndate<19840100 & hq1w>=1820 & hq1w<3420
replace wba=110 if st==41 & nndate>=19830700 & nndate<19840100 & hq1w>=3420
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19840100 & nndate<19850101 & hq1w>=1820 & hq1w<3620
replace wba=115 if st==41 & nndate>=19840100 & nndate<19850101 & hq1w>=3620
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19850101 & nndate<19860700 & hq1w>=1820 & hq1w<3820
replace wba=120 if st==41 & nndate>=19850101 & nndate<19860700 & hq1w>=3820
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19860700 & nndate<19870100 & hq1w>=1820 & hq1w<4020
replace wba=125 if st==41 & nndate>=19860700 & nndate<19870100 & hq1w>=4020
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19870100 & nndate<19870700 & hq1w>=1820 & hq1w<4220
replace wba=130 if st==41 & nndate>=19870100 & nndate<19870700 & hq1w>=4220
replace wba=70+(1/40)*(hq1w-1820) if st==41 & nndate>=19870700 & nndate<19890700 & hq1w>=1820 & hq1w<4820
replace wba=145 if st==41 & nndate>=19870700 & nndate<19890700 & hq1w>=4820

*7/2/89-7/5/92
replace wba=30 if st==41 & nndate>=19890700 & nndate<19920700 & hq1w<780
replace wba=30+(1/26)*(hq1w-780) if st==41 & nndate>=19890700 & nndate<19920700 & hq1w>=780 & hq1w<1846

replace wba=71+(1/37)*(hq1w-1846) if st==41 & nndate>=19890700 & nndate<19900100 & hq1w>=1846 & hq1w<4991
replace wba=155 if st==41 & nndate>=19890700 & nndate<19900100 & hq1w>=4991
replace wba=71+(1/37)*(hq1w-1846) if st==41 & nndate>=19900100 & nndate<19900700 & hq1w>=1846 & hq1w<5176
replace wba=160 if st==41 & nndate>=19900100 & nndate<19900700 & hq1w>=5176
replace wba=71+(1/34)*(hq1w-1846) if st==41 & nndate>=19900700 & nndate<19910100 & hq1w>=1846 & hq1w<4906
replace wba=160 if st==41 & nndate>=19900700 & nndate<19910100 & hq1w>=4906
replace wba=71+(1/34)*(hq1w-1846) if st==41 & nndate>=19910100 & nndate<19910700 & hq1w>=1846 & hq1w<5076
replace wba=165 if st==41 & nndate>=19910100 & nndate<19910700 & hq1w>=5076
replace wba=71+(1/28)*(hq1w-1846) if st==41 & nndate>=19910700 & nndate<19920700 & hq1w>=1846 & hq1w<4506
replace wba=165 if st==41 & nndate>=19910700 & nndate<19920700 & hq1w>=4506

*7/5/92+
replace wba=30 if st==41 & nndate>=19920700 & hq1w<780

replace wba=30+(1/26)*(hq1w-780) if st==41 & nndate>=19920700 & nndate<19930700 & hq1w>=780 & hq1w<4420
replace wba=170 if st==41 & nndate>=19920700 & nndate<19930700 & hq1w>=4420
replace wba=30+(1/26)*(hq1w-780) if st==41 & nndate>=19930700 & nndate<19940700 & hq1w>=780 & hq1w<4810
replace wba=185 if st==41 & nndate>=19930700 & nndate<19940700 & hq1w>=4810
replace wba=30+(1/26)*(hq1w-780) if st==41 & nndate>=19940700 & hq1w>=780 & hq1w<5200
replace wba=200 if st==41 & nndate>=19940700 & hq1w>=5200

*EK adds this, as formula seems way easier than what JG shows here.
replace wba=(1/26)*hq12sum/2 if st==41 & nndate>=19940700					// Average of 2 highest quarters
replace wba = wba + min(10*children,50) if st==41 & nndate>=20100700


// Texas
replace wba=(1/25)*hq1w if st==42


// Utah
replace wba=(1/26)*hq1w if st==43
replace wba=wba-5 if st==43 & nndate>=20110100		// EK added this


// Vermont
replace wba=(1/2)*wg if st==44 & nndate<19880100
replace wba= (1/45)*hq12sum if st==44 & nndate>=19880100


// Virginia
replace wba=(1/50)*hq12sum if st==45			// 1/50 of sum of 2 highest quarters


// Washington
replace wba=.04*(hq12sum/2) if st==46 & nndate<20050100					// EK
replace wba=.01*annwg if st==46 & nndate>=20050100 & nndate<20050700 	// EK
replace wba=.0385*hq12sum/2 if st==46 & nndate>=20050700				// EK. April 24, 2005


// West Virginia
replace wba = 0  if annwg<700 & st==47 & nndate<=19740701
replace wba = 12 if annwg>=700 & annwg<800 & st==47 & nndate<=19740700
replace wba = 13 if annwg>=800 & annwg<900 & st==47 & nndate<=19740700
replace wba = 14 if annwg>=900 & annwg<1000 & st==47 & nndate<=19740700
replace wba = 15 if annwg>=1000 & annwg<1150 & st==47 & nndate<=19740700
replace wba = 16 + (annwg-1150)/150 if annwg>=1150 & annwg<2500 & st==47 & nndate<=19740700
replace wba = 0.001*annwg if annwg>=2500 & annwg<3200 & st==47 & nndate<=19740700
replace wba = 32 + (annwg-3200)/150 if annwg>=3200 & st==47 & nndate<=19740700

replace wba = 0  if annwg<700 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 14 if annwg>=700 & annwg<800 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 15 if annwg>=800 & annwg<900 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 16 if annwg>=900 & annwg<1000 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 17 if annwg>=1000 & annwg<1150 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 18 + (annwg-1150)/150 if annwg>=1150 & annwg<2500 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = (0.001*annwg + 2) if annwg>=2500 & annwg<3200 & st==47 & nndate>=19740701 & nndate<=19780701
replace wba = 34 + (annwg-3200)/150 if annwg>=3200 & st==47 & nndate>=19740701 & nndate<=19780701

replace wba = 0  if annwg<1150 & st==47 & nndate>=19780701 & nndate<=19850700
replace wba = 18 + (annwg-1150)/150 if annwg>=1150 & annwg<2500 & st==47 & nndate>=19780701 & nndate<=19850700
replace wba = (0.001*annwg + 2) if annwg>=2500 & annwg<3200 & st==47 &  nndate>=19780701 & nndate<=19850700
replace wba = 35 + 1.59*((annwg-3200)/150) if annwg>=3200 & st==47 & nndate>=19780701 & nndate<=19830700
replace wba = 35 + 1.58*((annwg-3200)/150) if annwg>=3200 & st==47 & nndate>=19830700 & nndate<=19850700

replace wba =.01*annwg if st==47 & nndate>=19850700			// EK
replace wba =.55*(annwg/52) if st==47 & nndate>=20110700	// EK. Document says median wage instead of annwg


// Wisconsin
replace wba=(1/2)*wg if st==48 & nndate<19890700
replace wba=.04*(hq1w) if st==48 & nndate>=19890700


// Wyoming
replace wba=(1/25)*hq1w if st==49


// Alaska : Not in SIPP
replace wba = min(annwg*0.023,750*0.023) + max(.011*(annwg-750),0) + min(5*children,wba,25) if st==50 & ///
	nndate<19730700
replace wba = min(annwg*0.023,750*0.023) + max(.011*(annwg-750),0) + min(10*children,30) if st==50 & ///
	nndate>=19730700 & nndate<19810100
replace wba = min(annwg*0.034,1000*0.034) + max(.009*(annwg-1000),0) + min(24*children,72) if st==50 & ///
	nndate>=19810100 & nndate<19830100
replace wba = min(annwg*0.034,1000*0.034) + max(.01*(annwg-1000),0) + min(24*children,72) if st==50 & ///
	nndate>=19830100 & nndate<19850100
replace wba = min(annwg*0.04,1000*0.04) + max(.0095*(annwg-1000),0) + min(24*children,72) if st==50 & ///
	nndate>=19850100 & nndate<19940100
replace wba = min(annwg*0.04,1000*0.04) + max(.009*(annwg-1000),0) + min(24*children,72) if st==50 & ///
	nndate>=19940100 & nndate<20090100	
replace wba = min(annwg*0.04,2500*0.04) + max(.009*(annwg-2500),0) + min(24*children,72) if st==50 & ///
	nndate>=20090100 & nndate<20130100	
replace wba = min(annwg*0.02,2500*0.02) + max(.009*(annwg-2500),0) + min(24*children,72) if st==50 & ///
	nndate>=20130100			

// Hawaii
replace wba=(1/25)*hq1w if st==51 & nndate<19920100
replace wba=(1/21)*hq1w if st==51 & nndate>=19920100


forvalues i=1/51{
	
	if `i'==4 {		// California
	replace wba = max if wba>=max & st==`i' & nndate>=19920100
	replace wba = min if wba<=min & st==`i' & nndate>=19920100
	}
	else if `i'==6 | `i'==27 | `i'==29 | `i'==30 | `i'==37 {		// Connecticut, Nevada, New Jersey, New Mexico, Pennsylvania
	continue
	}
	else if `i'==41 {		// Tennessee
	replace wba = max if wba>=max & st==`i' & (nndate<19800701 | nndate>=19940700)
	replace wba = min if wba<=min & st==`i' & (nndate<19800701 | nndate>=19940700)
	}
	else {
	replace wba=max if wba>max & st==`i'
	replace wba=min if wba<min & st==`i'
	}
}

******************************
*** ARRA BENEFIT INCREASE
******************************
replace wba=wba+25 if nndate>=20090200 & nndate<=20100700

