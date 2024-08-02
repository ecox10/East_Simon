/*********************
File Name: 01c_b_calcelig.do

This file assigns UI eligibility according to wages.
File taken and updated from Chetty's UI calculator. Chetty's went from 1984-1994, but I need to
update from 1993 to 2014. Also, Chetty excluded Maine, Vermont, Iowa, N. Dakota, S. Dakota, Alaska, 
Idaho, Montana, Wyoming, so I add them here.

By: Chloe East and David Simon

Inputs:
	- bpw = Base Period Wages
	- hq1w = quarterly wage 
Outputs: 
	- elig 
***********************/

gen elig=0

gen hqw=hq1w


*Alabama
replace elig = 1 if bpw>774.01 & bpw>=1.5*hqw & st==1 & nndate<19890700
replace elig = 1 if bpw>1056 & bpw>=1.5*hqw & st==1 & nndate>=19890700 & nndate<19970700
replace elig = 1 if bpw>2160 & bpw>=1.5*hqw & st==1 & nndate>=19970700 & nndate<20020100
replace elig = 1 if bpw>2136 & bpw>=1.5*hqw & st==1 & nndate>=20020100 & nndate<20050100
replace elig = 1 if bpw>2114 & bpw>=1.5*hqw & st==1 & nndate>=20050100 & nndate<20070100
replace elig = 1 if bpw>2290 & bpw>=1.5*hqw & st==1 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>2214 & bpw>=1.5*hqw & st==1 & nndate>=20080100 & nndate<20100100
replace elig = 1 if bpw>2314 & bpw>=1.5*hqw & st==1 & nndate>=20100100 


*Arizona
replace elig = 1 if hqw>=1000 & bpw>=1.5*hqw & st==2 & nndate<20040829
replace elig = 1 if hqw>=1500 & bpw>=1.5*hqw & st==2 & nndate>=20040829 & nndate<20130100
replace elig = 1 if hqw>=3042 & bpw>=1.5*hqw & st==2 & nndate>=20130100 & nndate<20140100
replace elig = 1 if hqw>=3081 & bpw>=1.5*hqw & st==2 & nndate>=20140100


*Arkansas
replace elig = 1 if bpw>=30*wba & hq2w>0 & st==3 & nndate<19910700
replace elig = 1 if bpw>=27*wba & hq2w>0 & st==3 & nndate>=19910700 & nndate<20110700
replace elig = 1 if bpw>=35*wba & hq2w>0 & st==3 & nndate>=20110700


*California
replace elig = 1 if bpw>=1200 & st==4 & nndate<19900100
replace elig = 1 if (hqw>=1200 | (hqw>=900 & bpw>=1.25*hqw)) & st==4 & nndate>=19900100 & nndate<19910100
replace elig = 1 if (hqw>=1250 | (hqw>=900 & bpw>=1.25*hqw)) & st==4 & nndate>=19910100 & nndate<19920100
replace elig = 1 if (hqw>=1300 | (hqw>=900 & bpw>=1.25*hqw)) & st==4 & nndate>=19920100 		


*Colorado
replace elig = 1 if bpw>=40*wba & st==5 & nndate<20000100
replace elig = 1 if bpw>=40*wba & bpw>=2500 & st==5 & nndate>=20000100


*Connecticut 
replace elig = 1 if bpw>=40*wba & st==6 & nndate<20050100
replace elig = 1 if bpw>=40*wba & hq2w>0 & st==6 & nndate>=20050100


*Delaware 
replace elig = 1 if bpw>=36*wba & st==7


*D.C.
replace elig = 1 if hqw>=600 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate<19850100
replace elig = 1 if hqw>=300 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate>=19850100 & nndate<19850700
replace elig = 1 if hqw>=400 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate>=19850700 & nndate<19860100
replace elig = 1 if hqw>=600 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate>=19860100 & nndate<19870700
replace elig = 1 if hqw>=400 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate>=19870700 & nndate<19880700
replace elig = 1 if hqw>=300 & bpw>=450 & bpw>=1.5*hqw & st==8 & nndate>=19880700 & nndate<19890100
replace elig = 1 if hqw>=300 & bpw>=900 & bpw>=1.5*hqw & st==8 & nndate>=19890100 & nndate<19930100
replace elig = 1 if hqw>=1300 & bpw>=1950 & bpw>1.5*hqw & st==8 & nndate>=19930100 & nndate<20010100
replace elig = 1 if hqw>=1300 & hq12sum>=1950 & bpw>1.5*hqw & st==8 & nndate>=20010100


*Florida
replace elig = 1 if bpw>=400 & st==9 & nndate<19960700
replace elig = 1 if bpw>=3400 & bpw>=1.5*hqw & st==9 & nndate>=19960700 & nndate<20020700
replace elig = 1 if bpw>=3400 & bpw>=1.5*hqw & hq2w>0 & st==9 & nndate>=20020700


*Georgia
replace elig = 1 if bpw>=413 & bpw>=1.5*hqw & st==10 & nndate<19870100
replace elig = 1 if bpw>=1.5*hqw & st==10 & nndate>=19870100 & nndate<19920100
replace elig = 1 if bpw>=40*wba & hq2w>0 & bpw>=1.5*hqw & st==10 & nndate>=19920100 & nndate<20030100
replace elig = 1 if hqw>=920 & hq12sum>=1242 & bpw>=1840 & bpw>=1.5*hqw & st==10 & nndate>=20030100 & nndate<20060700
replace elig = 1 if hqw>=924 & bpw>=1.5*hqw & hq2w>0 & bpw>=40*wba & st==10 & nndate>=20060700 & nndate<20080100
replace elig = 1 if hqw>=1232 & bpw>=1.5*hqw & hq2w>0 & bpw>=40*wba & st==10 & nndate>=20080100 & nndate<20090100
replace elig = 1 if hqw>=756 & bpw>=1.5*hqw & hq2w>0 & bpw>=40*wba & st==10 & nndate>=20090100 & nndate<20100100
replace elig = 1 if hqw>=567 & bpw>=1.5*hqw & hq12sum>=1134 & hq2w>0 & bpw>=40*wba & st==10 & nndate>=20100100 & nndate<20120100
replace elig = 1 if hqw>=924 & bpw>=1.5*hqw & hq12sum>=1760 & hq2w>0 & bpw>=40*wba & st==10 & nndate>=20120100


*Hawaii
replace elig = 1 if bpw>=30*wba & st==51 & nndate<19900100
replace elig = 1 if bpw>=30*wba & hq2w>0 & st==51 & nndate>=19900100 & nndate<19920100
replace elig = 1 if bpw>=26*wba & hq2w>0 & st==51 & nndate>=19920100


*Idaho
replace elig = 1 if hqw>=1144 & bpw>=1.25*hqw & hq2w>0 & st==11 & nndate<19980700
replace elig = 1 if hqw>=1326 & bpw>=1.25*hqw & hq2w>0 & st==11 & nndate>=19980700 & nndate<20030100
replace elig = 1 if hqw>=1326 & bpw>=1.25*hqw & st==11 & nndate>=20030100 & nndate<20080100
replace elig = 1 if hqw>=1508 & bpw>=1.25*hqw & st==11 & nndate>=20080100 & nndate<20090100
replace elig = 1 if hqw>=1690 & bpw>=1.25*hqw & st==11 & nndate>=20090100 & nndate<20110700
replace elig = 1 if hqw>=1872 & bpw>=1.25*hqw & st==11 & nndate>=20110700


*Illinois
replace elig = 1 if bpw>=1600 & (bpw-hqw)>=440 & st==12 & nndate<20050100
replace elig = 1 if bpw>=1600 & hqw>=1160 & (bpw-hqw)>=440 & st==12 & nndate>=20050100


*Indiana
replace elig = 1 if bpw>=1500 & bpw>=1.25*hqw & (qearn_l1+qearn_l2)>=900 & st==13 & nndate<19850700
replace elig = 1 if bpw>=2500 & bpw>=1.5*hqw & (qearn_l1+qearn_l2)>=1500 & st==13 & nndate>=19850700 & nndate<19910700
replace elig = 1 if bpw>=2500 & bpw>=1.25*hqw & (qearn_l1+qearn_l2)>=1500 & st==13 & nndate>=19910700 & nndate<19950700	
replace elig = 1 if bpw>=2750 & bpw>=1.25*hqw & (qearn_l1+qearn_l2)>=1650 & st==13 & nndate>=19950700 & nndate<20100100
replace elig = 1 if bpw>=4200 & bpw>=1.5*hqw & (qearn_l1+qearn_l2)>=2500 & st==13 & nndate>=20100100		


*Iowa
replace elig = 1 if bpw>=600 & bpw>=1.25*hqw & st==14 & nndate<19840100
replace elig = 1 if bpw>=770 & bpw>=1.25*hqw & st==14 & nndate>=19840100 & nndate<19860100
replace elig = 1 if bpw>=810 & bpw>=1.25*hqw & st==14 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=840 & bpw>=1.25*hqw & st==14 & nndate>=19870100 & nndate<19880100
replace elig = 1 if bpw>=920 & bpw>=1.25*hqw & st==14 & nndate>=19880100 & nndate<19890100
replace elig = 1 if bpw>=900 & bpw>=1.25*hqw & st==14 & nndate>=19890100 & nndate<19910100
replace elig = 1 if bpw>=960 & bpw>=1.25*hqw & st==14 & nndate>=19910100 & nndate<19920100
replace elig = 1 if bpw>=1000 & bpw>=1.25*hqw & st==14 & nndate>=19920100 & nndate<19930100
replace elig = 1 if bpw>=1030 & bpw>=1.25*hqw & st==14 & nndate>=19930100 & nndate<19940100
replace elig = 1 if bpw>=1060 & bpw>=1.25*hqw & st==14 & nndate>=19940100 & nndate<19950100
replace elig = 1 if bpw>=1090 & bpw>=1.25*hqw & st==14 & nndate>=19950100 & nndate<19960100
replace elig = 1 if bpw>=1120 & bpw>=1.25*hqw & st==14 & nndate>=19960100 & nndate<19970100
replace elig = 1 if bpw>=1150 & bpw>=1.25*hqw & st==14 & nndate>=19970100 & nndate<19980100
replace elig = 1 if bpw>=1180 & bpw>=1.25*hqw & st==14 & nndate>=19980100 & nndate<19990100
replace elig = 1 if bpw>=1210 & bpw>=1.25*hqw & st==14 & nndate>=19990100 & nndate<20010100
replace elig = 1 if bpw>=1230 & bpw>=1.25*hqw & st==14 & nndate>=20010100 & nndate<20040100
replace elig = 1 if bpw>=1300 & bpw>=1.5*hqw & st==14 & nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=1323 & bpw>=1.5*hqw & st==14 & nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=1380 & bpw>=1.5*hqw & st==14 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=1730 & bpw>=1.5*hqw & st==14 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=1790 & bpw>=1.5*hqw & st==14 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=1860 & bpw>=1.5*hqw & st==14 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=1930 & bpw>=1.5*hqw & st==14 & nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=1940 & bpw>=1.5*hqw & st==14 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=1990 & bpw>=1.5*hqw & st==14 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=2040 & bpw>=1.5*hqw & st==14 & nndate>=20130100 & nndate<20140100
replace elig = 1 if bpw>=2100 & bpw>=1.5*hqw & st==14 & nndate>=20140100


*Kansas
replace elig = 1 if bpw>=30*wba & hq2w>0 & st==15


*Kentucky
replace elig = 1 if hqw>=750 & (bpw-hqw)>=750 & bpw>=1.5*hqw & (qearn_l1+qearn_l2)>=8*wba & st==16 & nndate<20080100
replace elig = 1 if hqw>=1963 & (bpw-hqw)>=750 & bpw>=1.5*hqw & (qearn_l1+qearn_l2)>=8*wba & st==16 & nndate>=20080100 & nndate<20130100
replace elig = 1 if hqw>=2154 & (bpw-hqw)>=750 & bpw>=1.5*hqw & (qearn_l1+qearn_l2)>=8*wba & st==16 & nndate>=20130100
	

*Lousiana
replace elig = 1 if bpw>=300 & bpw>=1.5*hqw & st==17 & nndate<19880100
replace elig = 1 if bpw>=1000 & bpw>=1.5*hqw & st==17 & nndate>=19880100 & nndate<19960100
replace elig = 1 if bpw>=1200 & bpw>=1.5*hqw & st==17 & nndate>=19960100


*Maine
replace elig = 1 if bpw>=1687 & hqw>=((2/7)*1687) & (bpw-hqw)>=((2/7)*1687) & st==18 & ///
	nndate<19840100
replace elig = 1 if bpw>=1806 & hqw>=((2/6)*1806) & (bpw-hqw)>=((2/6)*1806) & st==18 & ///
	nndate>=19840100 & nndate<19850100
replace elig = 1 if bpw>=1894 & hqw>=((2/6)*1894) & (bpw-hqw)>=((2/6)*1894) & st==18 & ///
	nndate>=19850100 & nndate<19860100
replace elig = 1 if bpw>=1685 & hqw>=((2/6)*1685) & (bpw-hqw)>=((2/6)*1685) & st==18 & ///
	nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=1760 & hqw>=((2/6)*1760) & (bpw-hqw)>=((2/6)*1760) & st==18 & ///
	nndate>=19870100 & nndate<19880100
replace elig = 1 if bpw>=1865 & hqw>=((2/6)*1865) & (bpw-hqw)>=((2/6)*1865) & st==18 & ///
	nndate>=19880100 & nndate<19890100
replace elig = 1 if bpw>=1976 & hqw>=((2/6)*1976) & (bpw-hqw)>=((2/6)*1976) & st==18 & ///
	nndate>=19890100 & nndate<19900100
replace elig = 1 if bpw>=2081 & hqw>=((2/6)*2081) & (bpw-hqw)>=((2/6)*2081) & st==18 & ///
	nndate>=19900100 & nndate<19910100
replace elig = 1 if bpw>=2176 & hqw>=((2/6)*2176) & (bpw-hqw)>=((2/6)*2176) & st==18 & ///
	nndate>=19910100 & nndate<19920100
replace elig = 1 if bpw>=2287 & hqw>=((2/6)*2287) & (bpw-hqw)>=((2/6)*2287) & st==18 & ///
	nndate>=19920100 & nndate<19930100	
replace elig = 1 if bpw>=6*avweekwage & hqw>=(2*avweekwage) & st==18 & nndate>=19930100 & ///
	nndate<20010100
replace elig = 1 if bpw>=3120 & hqw>=((2/6)*3120) & (bpw-hqw)>=((2/6)*3120) & st==18 & ///
	nndate>=20010100 & nndate<20040100
replace elig = 1 if bpw>=3367 & hqw>=((2/6)*3367) & (bpw-hqw)>=((2/6)*3367) & st==18 & ///
	nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=3487 & hqw>=((2/6)*3487) & (bpw-hqw)>=((2/6)*3487) & st==18 & ///
	nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=3612 & hqw>=((2/6)*3612) & (bpw-hqw)>=((2/6)*3612) & st==18 & ///
	nndate>=20060100 & nndate<20080100
replace elig = 1 if bpw>=3828 & hqw>=((2/6)*3828) & (bpw-hqw)>=((2/6)*3828) & st==18 & ///
	nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=3977 & hqw>=((2/6)*3977) & (bpw-hqw)>=((2/6)*3977) & st==18 & ///
	nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=4112 & hqw>=((2/6)*4112) & (bpw-hqw)>=((2/6)*4112) & st==18 & ///
	nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=4148 & hqw>=((2/6)*4148) & (bpw-hqw)>=((2/6)*4148) & st==18 & ///
	nndate>=20110100 & nndate<20130100
replace elig = 1 if bpw>=4307 & hqw>=((2/6)*4307) & (bpw-hqw)>=((2/6)*4307) & st==18 & ///
	nndate>=20130100 & nndate<20140100
replace elig = 1 if bpw>=4372 & hqw>=((2/6)*4372) & (bpw-hqw)>=((2/6)*4372) & st==18 & ///
	nndate>=20140100
	

*Maryland
replace elig = 1 if hqw>=576.01 & bpw>=1.5*hqw & hq2w>0 & st==19 & nndate<20050100
replace elig = 1 if hqw>=576.01 & bpw>=1.5*hqw & st==19 & nndate>=20050100 & nndate<20120304
replace elig = 1 if hqw>=1776 & bpw>=1.5*hqw & st==19 & nndate>=20120304


*Massachusetts
replace elig = 1 if bpw>=1200 & bpw>=wba*30 & st==20 & nndate<19920700
replace elig = 1 if bpw>=1800 & bpw>=wba*30 & st==20 & nndate>=19920700 & nndate<19940100
replace elig = 1 if bpw>=2400 & bpw>=wba*30 & st==20 & nndate>=19940100 & nndate<19950100
replace elig = 1 if bpw>=2000 & bpw>=wba*30 & st==20 & nndate>=19950100 & nndate<20010100
replace elig = 1 if bpw>=2700 & bpw>=wba*30 & st==20 & nndate>=20010100 & nndate<20020700
replace elig = 1 if bpw>=3000 & bpw>=wba*30 & st==20 & nndate>=20020700 & nndate<20080100
replace elig = 1 if bpw>=3300 & bpw>=wba*30 & st==20 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=3500 & bpw>=wba*30 & st==20 & nndate>=20090100


*Michigan
replace elig = 1 if bpw>=2010 & st==21 & nndate<19930100
replace elig = 1 if bpw>=1340 & st==21 & nndate>=19930100 & nndate<19970100
replace elig = 1 if bpw>=2010 & st==21 & nndate>=19970100 & nndate<19980100
replace elig = 1 if bpw>=3090 & st==21 & nndate>=19980100 & nndate<20010100
replace elig = 1 if bpw>=3219 & bpw>=1.5*hqw & st==21 & nndate>=20010100 & nndate<20020100
replace elig = 1 if hqw>=1998 & bpw>=1.5*hqw & st==21 & nndate>=20020100 & nndate<20050100
replace elig = 1 if hqw>=1976 & bpw>=1.5*hqw & st==21 & nndate>=20050100 & nndate<20070100
replace elig = 1 if hqw>=1998 & bpw>=1.5*hqw & st==21 & nndate>=20070100 & nndate<20070400
replace elig = 1 if hqw>=2697 & bpw>=1.5*hqw & st==21 & nndate>=20070400 & nndate<20080600
replace elig = 1 if hqw>=2774 & bpw>=1.5*hqw & st==21 & nndate>=20080600 & nndate<20090100
replace elig = 1 if hqw>=2871 & bpw>=1.5*hqw & st==21 & nndate>=20090100 & nndate<20150400
replace elig = 1 if hqw>=3152 & bpw>=1.5*hqw & st==21 & nndate>=20150400


*Minnesota
replace elig = 1 if bpw>=1211 & st==22 & nndate<19840700
replace elig = 1 if bpw>=1305 & st==22 & nndate>=19840700 & nndate<19850100
replace elig = 1 if bpw>=1415 & st==22 & nndate>=19850100 & nndate<19860100
replace elig = 1 if bpw>=1485 & st==22 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=1545 & st==22 & nndate>=1987010 & nndate<19880100
replace elig = 1 if bpw>=1250 & bpw>=1.25*hqw & st==22 & nndate>=19880100 & nndate<19880700
replace elig = 1 if hqw>=1000 & bpw>=1.25*hqw & st==22 & nndate>=19880700 & nndate<20020100
replace elig = 1 if hqw>=1000 & (bpw-hqw)>=250 & st==22 & nndate>=20020100 & nndate<20130100
replace elig = 1 if bpw>=2500 & st==22 & nndate>=20130100 & nndate<20140100
replace elig = 1 if bpw>=2600 & st==22 & nndate>=20140100 & nndate<20150100
replace elig = 1 if bpw>=2400 & bpw>=0.053*avweekwage*52 & st==22 & nndate>=20150100


*Mississippi
replace elig = 1 if bpw>=40*wba & hqw>=480 & hq2w>0 & st==23 & nndate<19850100
replace elig = 1 if bpw>=40*wba & hqw>=780 & hq2w>0 & st==23 & nndate>=19850100


*Missouri
replace elig = 1 if bpw>=30*wba & hqw>=300 & hq2w>0 & st==24 & nndate<19850100
replace elig = 1 if hqw>=300 & bpw>=1.5*hqw & hq2w>0 & st==24 & nndate>=19850100 & nndate<19870100
replace elig = 1 if hqw>=500 & bpw>=1.5*hqw & hq2w>0 & st==24 & nndate>=19870100 & nndate<19890100
replace elig = 1 if hqw>=750 & bpw>=1.5*hqw & hq2w>0 & st==24 & nndate>=19890100 & nndate<19910100
replace elig = 1 if hqw>=1000 & bpw>=1.5*hqw & hq2w>0 & st==24 & nndate>=19910100 & nndate<20030100
replace elig = 1 if hqw>=1000 & bpw>=1.5*hqw & st==24 & nndate>=20030100 & nndate<20050100
replace elig = 1 if hqw>=1200 & bpw>=1.5*hqw & st==24 & nndate>=20050100 & nndate<20060100
replace elig = 1 if hqw>=1300 & bpw>=1.5*hqw & st==24 & nndate>=20060100 & nndate<20070100
replace elig = 1 if hqw>=1400 & bpw>=1.5*hqw & st==24 & nndate>=20070100 & nndate<20080100
replace elig = 1 if hqw>=1500 & bpw>=1.5*hqw & st==24 & nndate>=20080100


*Montana
replace elig = 1 if bpw>=1000 & st==25 & nndate<19880100
replace elig = 1 if bpw>=1098 & st==25 & nndate>=19880100 & nndate<19890100
replace elig = 1 if bpw>=1123 & st==25 & nndate>=19890100 & nndate<19900100
replace elig = 1 if bpw>=1157 & st==25 & nndate>=19900100 & nndate<19910100
replace elig = 1 if bpw>=1176 & bpw>=1.5*hqw & st==25 & nndate>=19910100 & nndate<19920100
replace elig = 1 if bpw>=1207 & bpw>=1.5*hqw & st==25 & nndate>=19920100 & nndate<19930100
replace elig = 1 if bpw>=1240 & bpw>=1.5*hqw & st==25 & nndate>=19930100 & nndate<19940100
replace elig = 1 if bpw>=1273 & bpw>=1.5*hqw & st==25 & nndate>=19940100 & nndate<19950100
replace elig = 1 if bpw>=1307 & bpw>=1.5*hqw & st==25 & nndate>=19950100 & nndate<19960100
replace elig = 1 if bpw>=1340 & bpw>=1.5*hqw & st==25 & nndate>=19960100 & nndate<19980100
replace elig = 1 if bpw>=1373 & bpw>=1.5*hqw & st==25 & nndate>=19980100 & nndate<19990100
replace elig = 1 if bpw>=1407 & bpw>=1.5*hqw & st==25 & nndate>=19990100 & nndate<20000100
replace elig = 1 if bpw>=1440 & bpw>=1.5*hqw & st==25 & nndate>=20000100 & nndate<20020100
replace elig = 1 if bpw>=1597 & bpw>=1.5*hqw & st==25 & nndate>=20020100 & nndate<20040100
replace elig = 1 if bpw>=1773 & bpw>=1.5*hqw & st==25 & nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=3948 & bpw>=1.5*hqw & st==25 & nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=5000 & bpw>=1.5*hqw & st==25 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=1982 & bpw>=1.5*hqw & st==25 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=2087 & bpw>=1.5*hqw & st==25 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=2200 & bpw>=1.5*hqw & st==25 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=2277 & bpw>=1.5*hqw & st==25 & nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=2305 & bpw>=1.5*hqw & st==25 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=2363 & bpw>=1.5*hqw & st==25 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=2445 & bpw>=1.5*hqw & st==25 & nndate>=20130100 & nndate<20140100
replace elig = 1 if bpw>=2540 & bpw>=1.5*hqw & st==25 & nndate>=20140100


*Nebraska
replace elig = 1 if bpw>=600 & hqw>=200 & hq2w>=200 & st==26 & nndate<19870700
replace elig = 1 if bpw>=1200 & hqw>=400 & hq2w>=400 & st==26 & nndate>=19870700 & nndate<19990100
replace elig = 1 if bpw>=1600 & hqw>=800 & hq2w>=800 & st==26 & nndate>=19990100 & nndate<20060100
replace elig = 1 if bpw>=2500 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=2592 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=2651 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=2781 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=2761 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=2807 & hqw>=800 & hq2w>=800 & st==26 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=3770 & hqw>=1850 & hq2w>=800 & st==26 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=3962 & hqw>=1850 & hq2w>=800 & st==26 & nndate>=20130100 & nndate<20140100
replace elig = 1 if bpw>=4026 & hqw>=1850 & hq2w>=800 & st==26 & nndate>=20140100 & nndate<20150100
replace elig = 1 if bpw>=4095 & hqw>=1850 & hq2w>=800 & st==26 & nndate>=20150100


*Nevada
replace elig = 1 if bpw>563 & bpw>=1.5*hqw & st==27 & nndate<19850100
replace elig = 1 if bpw>600 & bpw>=1.5*hqw & st==27 & nndate>=19850100


*New Hampshire
replace elig=1 if bpw>=1700 & hqw>800 & st==28 & nndate<19860100
replace elig=1 if bpw>=2600 & hqw>1000 & st==28 & nndate>=19860100 & nndate<19870700
replace elig=1 if bpw>=2800 & hqw>1000 & hq2w>=1000 & st==28 & nndate>=19870700 & nndate<19890700
replace elig=1 if bpw>=2800 & hqw>1100 & hq2w>=1100 & st==28 & nndate>=19890700 & nndate<19900700
replace elig=1 if bpw>=2800 & hqw>1200 & hq2w>=1200 & st==28 & nndate>=19900700 & nndate<20010100
replace elig=1 if bpw>=2800 & hqw>1400 & hq2w>=1400 & st==28 & nndate>=20010100 


*New Jersey
replace elig = 1 if bpw>=2200 & st==29 & nndate<19850100
replace elig = 1 if bpw>=1020 & st==29 & nndate>=19850100 & nndate<19860100
replace elig = 1 if bpw>=1520 & st==29 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=1620 & st==29 & nndate>=19870100 & nndate<19890100
replace elig = 1 if bpw>=1720 & st==29 & nndate>=19890100 & nndate<19900100
replace elig = 1 if bpw>=1980 & st==29 & nndate>=19900100 & nndate<19910100
replace elig = 1 if bpw>=2060 & st==29 & nndate>=19910100 & nndate<19920100
replace elig = 1 if bpw>=2200 & st==29 & nndate>=19920100 & nndate<19930100
replace elig = 1 if bpw>=2300 & st==29 & nndate>=19930100 & nndate<19940100
replace elig = 1 if bpw>=2460 & st==29 & nndate>=19940100 & nndate<20040100
replace elig = 1 if bpw>=2060 & st==29 & nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=2460 & st==29 & nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=2560 & st==29 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=2860 & st==29 & nndate>=20070100 & nndate<20090100
replace elig = 1 if bpw>=2872 & st==29 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=2900 & st==29 & nndate>=20100100 


*New Mexico
replace elig = 1 if bpw>=921 & bpw>=1.25*hqw & st==30 & nndate<19850100
replace elig = 1 if bpw>=975 & bpw>=1.25*hqw & st==30 & nndate>=19850100 & nndate<19860100
replace elig = 1 if bpw>=1004 & bpw>=1.25*hqw & st==30 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=1031 & bpw>=1.25*hqw & st==30 & nndate>=19870100 & nndate<19890100
replace elig = 1 if bpw>=1079 & bpw>=1.25*hqw & st==30 & nndate>=19890100 & nndate<19900100
replace elig = 1 if bpw>=1109 & bpw>=1.25*hqw & st==30 & nndate>=19900100 & nndate<19910100
replace elig = 1 if bpw>=1151 & bpw>=1.25*hqw & st==30 & nndate>=19910100 & nndate<19920100
replace elig = 1 if bpw>=1203 & bpw>=1.25*hqw & st==30 & nndate>=19920100 & nndate<19930100
replace elig = 1 if bpw>=1235 & bpw>=1.25*hqw & st==30 & nndate>=19930100 & nndate<19940100
replace elig = 1 if bpw>=1268 & bpw>=1.25*hqw & st==30 & nndate>=19940100 & nndate<19950100
replace elig = 1 if bpw>=1333 & bpw>=1.25*hqw & st==30 & nndate>=19950100 & nndate<19960100
replace elig = 1 if bpw>=1365 & bpw>=1.25*hqw & st==30 & nndate>=19960100 & nndate<19970100
replace elig = 1 if bpw>=1398 & bpw>=1.25*hqw & st==30 & nndate>=19970100 & nndate<19980100
replace elig = 1 if bpw>=1430 & bpw>=1.25*hqw & st==30 & nndate>=19980100 & nndate<19990100
replace elig = 1 if bpw>=1495 & bpw>=1.25*hqw & st==30 & nndate>=19990100 & nndate<20010100
replace elig = 1 if hqw>=1324 & hq2w>0 & st==30 & nndate>=20010100 & nndate<20020100
replace elig = 1 if hqw>=1372.8 & hq2w>0 & st==30 & nndate>=20020100 & nndate<20030100
replace elig = 1 if hqw>=1420 & hq2w>0 & st==30 & nndate>=20030100 & nndate<20040100
replace elig = 1 if hqw>=1439 & hq2w>0 & st==30 & nndate>=20040100 & nndate<20050100
replace elig = 1 if hqw>=1482 & hq2w>0 & st==30 & nndate>=20050100 & nndate<20060100
replace elig = 1 if hqw>=1548 & hq2w>0 & st==30 & nndate>=20060100 & nndate<20080100
replace elig = 1 if hqw>=1604 & hq2w>0 & st==30 & nndate>=20080100 & nndate<20090100
replace elig = 1 if hqw>=1629 & hq2w>0 & st==30 & nndate>=20090100 & nndate<20100100
replace elig = 1 if hqw>=1539 & hq2w>0 & st==30 & nndate>=20100100 & nndate<20110100
replace elig = 1 if hqw>=1750 & hq2w>0 & st==30 & nndate>=20110100 & nndate<20120100
replace elig = 1 if hqw>=1798 & hq2w>0 & st==30 & nndate>=20120100 & nndate<20130100
replace elig = 1 if hqw>=1847 & hq2w>0 & st==30 & nndate>=20130100 & nndate<20140100
replace elig = 1 if hqw>=1823 & hq2w>0 & st==30 & nndate>=20140100 & nndate<20150100
replace elig = 1 if hqw>=1871 & hq2w>0 & st==30 & nndate>=20150100


*New York
replace elig = 1 if bpw>=800 & st==31 & nndate<19840100
replace elig = 1 if bpw>=1340 & st==31 & nndate>=19840100 & nndate<19840700 
replace elig = 1 if bpw>=1200 & st==31 & nndate>=19840700 & nndate<20000100 
replace elig = 1 if hqw>=1600 & bpw>=1.5*hqw & hq2w>0 & st==31 & nndate>=20000100 & nndate<20030100 
replace elig = 1 if hqw>=1600 & bpw>=1.5*hqw & st==31 & nndate>=20030100 & nndate<20140100
replace elig = 1 if hqw>=1700 & bpw>=1.5*hqw & st==31 & nndate>=20140100 & nndate<20150100
replace elig = 1 if hqw>=1900 & bpw>=1.5*hqw & st==31 & nndate>=20150100


*North Carolina
replace elig = 1 if bpw>=1368 & st==32 & nndate<19850100
replace elig = 1 if bpw>=1675 & st==32 & nndate>=19850100 & nndate<19870100
replace elig = 1 if bpw>=1849 & st==32 & nndate>=19870100 & nndate<19880100
replace elig = 1 if bpw>=1945 & st==32 & nndate>=19880100 & nndate<19890100
replace elig = 1 if bpw>=2052 & st==32 & nndate>=19890100 & nndate<19910100
replace elig = 1 if bpw>=2324 & st==32 & nndate>=19910100 & nndate<20010100
replace elig = 1 if bpw>=565 & bpw>=1.5*hqw & st==32 & nndate>=20010100 & nndate<20020700
replace elig = 1 if bpw>=3586 & hq2w>0 & st==32 & nndate>=20020700 & nndate<20040100
replace elig = 1 if bpw>=3749 & hq2w>0 & st==32 & nndate>=20040100 & nndate<20070100
replace elig = 1 if bpw>=4113 & hq2w>0 & st==32 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=4291 & hq2w>0 & st==32 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=4455 & hq2w>0 & st==32 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=4551 & hq2w>0 & st==32 & nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=4558 & hq2w>0 & st==32 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=4706 & hq2w>0 & st==32 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=4816 & hq2w>0 & st==32 & nndate>=20130100


*North Dakota
replace elig = 1 if bpw>=1880 & st==33 & nndate<19840100
replace elig = 1 if bpw>=2340 & st==33 & nndate>=19840100 & nndate<19880100
replace elig = 1 if bpw>=2795 & st==33 & bpw>=1.5*hqw & nndate>=19880101


*Ohio
replace elig = 1 if bpw>=400 & hq2w>0 & st==34 & nndate<19840100
replace elig = 1 if bpw>=1702 & hq2w>0 & st==34 & nndate>=19840100 & nndate<19900100
replace elig = 1 if bpw>=20*.275*avweekwage & hq2w>0 & st==34 & nndate>=19900100 & nndate<20010100
replace elig = 1 if bpw>=2640 & hq2w>0 & st==34 & nndate>=20010100 & nndate<20040100
replace elig = 1 if bpw>=3520 & hq2w>0 & st==34 & nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=3720 & hq2w>0 & st==34 & nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=3840 & hq2w>0 & st==34 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=4000 & hq2w>0 & st==34 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=4120 & hq2w>0 & st==34 & nndate>=20080100 & nndate<20100100
replace elig = 1 if bpw>=4260 & hq2w>0 & st==34 & nndate>=20100100 & nndate<20110100
replace elig = 1 if bpw>=4300 & hq2w>0 & st==34 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=4400 & hq2w>0 & st==34 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=4600 & hq2w>0 & st==34 & nndate>=20130100


*Oklahoma
replace elig = 1 if bpw>=1000 & bpw>=1.5*hqw & st==35 & nndate<19840100
replace elig = 1 if bpw>=3000 & bpw>=1.5*hqw & st==35 & nndate>=19840100 & nndate<19860100
replace elig = 1 if bpw>=3560 & bpw>=1.5*hqw & st==35 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=3640 & bpw>=1.5*hqw & st==35 & nndate>=19870100 & nndate<19920100
replace elig = 1 if bpw>=4040 & bpw>=1.5*hqw & st==35 & nndate>=19920100 & nndate<19940100
replace elig = 1 if bpw>=4160 & bpw>=1.5*hqw & st==35 & nndate>=19940100 & nndate<19950100
replace elig = 1 if bpw>=4280 & bpw>=1.5*hqw & st==35 & nndate>=19950100 & nndate<19960100
replace elig = 1 if bpw>=1500 & bpw>=1.5*hqw & st==35 & nndate>=19960100


*Oregon
replace elig = 1 if bpw>=1000 & bpw>=1.5*hqw & st==36


*Pennsylvania
replace elig = 1 if hqw>=800 & bpw>=1320 & (bpw-hqw)>=0.2*bpw & st==37 & nndate<20130100
replace elig = 1 if hqw>=1688 & bpw>=3391 & (bpw-hqw)>=0.495*bpw & st==37 & nndate>=20130100


*Rhode Island
replace elig = 1 if bpw>=4020 & st==38 & nndate<19870100
replace elig = 1 if bpw>=4260 & st==38 & nndate>=19870100 & nndate<19870700
replace elig = 1 if bpw>=4380 & st==38 & nndate>=19870700 & nndate<19880700
replace elig = 1 if bpw>=4800 & st==38 & nndate>=19880700 & nndate<19900100
replace elig = 1 if bpw>=1700 & hqw>=850 & bpw>=1.5*hqw & st==38 & nndate>=19900100 & nndate<19920100
replace elig = 1 if hqw>=890 & bpw>=1780 & bpw>=1.5*hqw & st==38 & nndate>=19920100 & nndate<19960100
replace elig = 1 if hqw>=950 & bpw>=1900 & bpw>=1.5*hqw & st==38 & nndate>=19960100 & nndate<19970100
replace elig = 1 if hqw>=1030 & bpw>=2060 & bpw>=1.5*hqw & st==38 & nndate>=19970100 & nndate<20000100 
replace elig = 1 if hqw>=1130 & bpw>=2260 & bpw>=1.5*hqw & st==38 & nndate>=20000100 & nndate<20010100
replace elig = 1 if hqw>=1230 & bpw>=2460 & bpw>=1.5*hqw & st==38 & nndate>=20010100 & nndate<20040100
replace elig = 1 if hqw>=1350 & bpw>=2700 & bpw>=1.5*hqw & st==38 & nndate>=20040100 & nndate<20070100
replace elig = 1 if hqw>=1480 & bpw>=2960 & bpw>=1.5*hqw & st==38 & nndate>=20070100 & nndate<20130100
replace elig = 1 if hqw>=1550 & bpw>=3100 & bpw>=1.5*hqw & st==38 & nndate>=20130100

*South Carolina
replace elig = 1 if hqw>=450 & bpw>=1.5*hqw & bpw>=900 & st==39 & nndate<20110100
replace elig = 1 if hqw>=1092 & bpw>=1.5*hqw & bpw>=4455 & st==39 & nndate>=20110100


*South Dakota
replace elig = 1 if hqw>=728 & (bpw-hqw)>=20*wba & st==40


*Tennessee
replace elig = 1 if bpw>=40*wba & hqw>754 & (bpw-hqw)>=6*wba & st==41 & nndate<19890700
replace elig = 1 if bpw>=40*wba & hqw>780 & ((bpw-hqw)>=6*wba | (bpw-hqw)>=900) & st==41 & nndate>=19890700


*Texas
replace elig = 1 if bpw>=1013 & st==42 & nndate<19850100
replace elig = 1 if bpw>=1050 & st==42 & nndate>=19850100 & nndate<19860100
replace elig = 1 if bpw>=500 & st==42 & nndate>=19860100 & nndate<19880100
replace elig = 1 if bpw>=37*wba & st==42 & nndate>=19880100 & nndate<20010100 
replace elig = 1 if bpw>=37*wba & hq2w>0 & st==42 & nndate>=20010100 


*Utah 
replace elig = 1 if bpw>=1200 & bpw>=1.5*hqw & st==43 & nndate<19850100
replace elig = 1 if bpw>=1300 & bpw>=1.5*hqw & st==43 & nndate>=19850100 & nndate<19860100 
replace elig = 1 if bpw>=1400 & bpw>=1.5*hqw & st==43 & nndate>=19860100 & nndate<19890100
replace elig = 1 if bpw>=1500 & bpw>=1.5*hqw & st==43 & nndate>=19890100 & nndate<19940100
replace elig = 1 if bpw>=1900 & bpw>=1.5*hqw & st==43 & nndate>=19940100 & nndate<20010100
replace elig = 1 if bpw>=2300 & bpw>=1.5*hqw & st==43 & nndate>=20010100 & nndate<20040100
replace elig = 1 if bpw>=2500 & bpw>=1.5*hqw & st==43 & nndate>=20040100 & nndate<20060100
replace elig = 1 if bpw>=2600 & bpw>=1.5*hqw & st==43 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=2800 & bpw>=1.5*hqw & st==43 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=2900 & bpw>=1.5*hqw & st==43 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=3000 & bpw>=1.5*hqw & st==43 & nndate>=20090100 & nndate<20100100
replace elig = 1 if bpw>=3100 & bpw>=1.5*hqw & st==43 & nndate>=20100100 & nndate<20120100
replace elig = 1 if bpw>=3200 & bpw>=1.5*hqw & st==43 & nndate>=20120100 & nndate<20130100
replace elig = 1 if bpw>=3300 & bpw>=1.5*hqw & st==43 & nndate>=20130100 & nndate<20150100
replace elig = 1 if bpw>=3400 & bpw>=1.5*hqw & st==43 & nndate>=20150100


*Vermont
replace elig = 1 if bpw>=700 & st==44 & nndate<19880100
replace elig = 1 if hqw>=1000 & bpw>=1.4*hqw & st==44 & nndate>=19880100 & nndate<19900700
replace elig = 1 if hqw>=1027 & bpw>=1.4*hqw & st==44 & nndate>=19900700 & nndate<19920100
replace elig = 1 if hqw>=1054 & bpw>=1.4*hqw & st==44 & nndate>=19920100 & nndate<19920700
replace elig = 1 if hqw>=1163 & bpw>=1.4*hqw & st==44 & nndate>=19920700 & nndate<19960700
replace elig = 1 if hqw>=1231 & bpw>=1.4*hqw & st==44 & nndate>=19960700 & nndate<19980100
replace elig = 1 if hqw>=1299 & bpw>=1.4*hqw & st==44 & nndate>=19980100 & nndate<20010100
replace elig = 1 if hqw>=1571 & bpw>=1.5*hqw & st==44 & nndate>=20010100 & nndate<20020700
replace elig = 1 if hqw>=1707 & bpw>=1.4*hqw & st==44 & nndate>=20020700 & nndate<20050700
replace elig = 1 if hqw>=1844 & bpw>=1.4*hqw & st==44 & nndate>=20050700 & nndate<20060700
replace elig = 1 if hqw>=1912 & bpw>=1.4*hqw & st==44 & nndate>=20060700 & nndate<20070700
replace elig = 1 if hqw>=1981 & bpw>=1.4*hqw & st==44 & nndate>=20070700 & nndate<20080700
replace elig = 1 if hqw>=2058 & bpw>=1.4*hqw & st==44 & nndate>=20080700 & nndate<20090700
replace elig = 1 if hqw>=2099 & bpw>=1.4*hqw & st==44 & nndate>=20090700 & nndate<20110100
replace elig = 1 if hqw>=2203 & bpw>=1.4*hqw & st==44 & nndate>=20110100 & nndate<20120700
replace elig = 1 if hqw>=2227 & bpw>=1.4*hqw & st==44 & nndate>=20120700 & nndate<20130700
replace elig = 1 if hqw>=2312 & bpw>=1.4*hqw & st==44 & nndate>=20130700 & nndate<20140700
replace elig = 1 if hqw>=2351 & bpw>=1.4*hqw & st==44 & nndate>=20140700


*Virginia
replace elig = 1 if bpw>=50*wba & hq2w>0 & st==45


*Washington
replace elig = 1 if bpw>=1237  & st==46 & nndate<19860100
replace elig = 1 if bpw>=1300 & st==46 & nndate>=19860100 & nndate<19870100
replace elig = 1 if bpw>=1325 & st==46 & nndate>=19870100 & nndate<19880101
replace elig = 1 if bpw>=1564 & st==46 & nndate>=19880101 & nndate<19910100
replace elig = 1 if bpw>=2890 & st==46 & nndate>=19910100 & nndate<19960100
replace elig = 1 if bpw>=3332 & st==46 & nndate>=19960100 & nndate<20000100
replace elig = 1 if bpw>=4420 & st==46 & nndate>=20000100 & nndate<20010100
replace elig = 1 if bpw>=4569.6 & st==46 & nndate>=20010100 & nndate<20020100
replace elig = 1 if bpw>=4692 & st==46 & nndate>=20020100 & nndate<20030100
replace elig = 1 if bpw>=4766.8 & st==46 & nndate>=20030100 & nndate<20040100
replace elig = 1 if bpw>=4868.8 & st==46 & nndate>=20040100 & nndate<20050100
replace elig = 1 if bpw>=4998 & st==46 & nndate>=20050100 & nndate<20060100
replace elig = 1 if bpw>=5188.4 & st==46 & nndate>=20060100 & nndate<20070100
replace elig = 1 if bpw>=5392.4 & st==46 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=5487.6 & st==46 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=5814 & st==46 & nndate>=20090100 & nndate<20110100
replace elig = 1 if bpw>=5895.6 & st==46 & nndate>=20110100 & nndate<20120100
replace elig = 1 if bpw>=6147.2 & st==46 & nndate>=20120100


*West Virginia
replace elig = 1 if bpw>=1150 & hq2w>0 & st==47 & nndate<19850700
replace elig = 1 if bpw>=2200 & hq2w>0 & st==47 & nndate>=19850700


*Wisconsin
replace elig = 1 if bpw>=1080.15 & st==48 & nndate<19840100
replace elig = 1 if bpw>=2106  & st==48 & nndate>=19840100 & nndate<19860100
replace elig = 1 if bpw>=2223  & st==48 & nndate>=19860100 & nndate<19880100
replace elig = 1 if bpw>=1258  & st==48 & nndate>=19880100 & nndate<19890700
replace elig = 1 if bpw>=40*wba & (bpw-hqw)>=13*wba & st==48 & nndate>=19890700 & nndate<19900100
replace elig = 1 if bpw>=34*wba & (bpw-hqw)>=10*wba & st==48 & nndate>=19900100 & nndate<19920100
replace elig = 1 if bpw>=30*wba & (bpw-hqw)>=8*wba & st==48 & nndate>=19920100 & nndate<19970100
replace elig = 1 if bpw>=30*wba & (bpw-hqw)>=7*wba & st==48 & nndate>=19970100 & nndate<20000100
replace elig = 1 if bpw>=30*wba & (bpw-hqw)>=4*wba & st==48 & nndate>=20000100 & nndate<20080700
replace elig = 1 if bpw>=35*wba & (bpw-hqw)>=4*wba & st==48 & nndate>=20080700


*Wyoming
replace elig = 1 if hqw>=600 & bpw>=1.6*hqw & st==49 & nndate<19840700
replace elig = 1 if hqw>=600 & bpw>=960 & st==49 & nndate>=19840700 & nndate<19860100
replace elig = 1 if hqw>=712.5 & bpw>=1440 & st==49 & nndate>=19860100 & nndate<19880700
replace elig = 1 if hqw>=712.5 & bpw>=1440 & bpw>=1.6*hqw & st==49 & nndate>=19880700 & nndate<19900100 
replace elig = 1 if bpw>=avweekwage*52*.08 & bpw>=1.4*hqw & st==49 & nndate>=19900100 & nndate<20010100
replace elig = 1 if bpw>=716 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20010100 & nndate<20020100
replace elig = 1 if bpw>=2100 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20020100 & nndate<20040100
replace elig = 1 if bpw>=2200 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20040100 & nndate<20070100
replace elig = 1 if bpw>=2600 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20070100 & nndate<20080100
replace elig = 1 if bpw>=2900 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20080100 & nndate<20090100
replace elig = 1 if bpw>=3100 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20090100 & nndate<20130100
replace elig = 1 if bpw>=3450 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20090100 & nndate<20140100
replace elig = 1 if bpw>=3550 & hq2w>0 & bpw>=1.4*hqw & st==49 & nndate>=20140100


*Alaska
replace elig = 1 if bpw>=1000 & hq2w>0 & st==50 & nndate<20090100
replace elig = 1 if bpw>=2500 & hq2w>0 & st==50 & nndate>=20090100

