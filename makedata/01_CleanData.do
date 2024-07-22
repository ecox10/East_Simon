/*********************
File Name: 01_CleanData.do
Purpose: This do file cleans the raw data and generate datasets for regression
Created by: Chloe East
Inputs: 01a_state_controls.do, 01b_create_pu_sipp.do
Outputs: sipp_annual`syear'".dta, sipp_cleaned.dta, regfinal.dta

***********************/

if c(username)=="das13016"{

cd "/Users/das13016/Documents/GitHub/JobLosers_SafetyNet/makedata/"
}

if c(username)=="chloeeast"{

cd "/Users/chloeeast/Documents/GitHub/JobLosers_SafetyNet/makedata"	
}

if c(username)=="elizabeth"{
	cd "/Users/elizabeth/Documents/GitHub/JobLosers_SafetyNet/makedata"
} 

do 00_master_setup.do

log using "$outputlog/01_CleanData_`today'.log", replace

*****
*Create state control data sets, once this is run once, don't need to run again
do "${dofiles}/01a_state_controls.do"

********************************************************************************
*****************************   SIPP DATASETS   ********************************
********************************************************************************

******************************************************
*****************EXTRACT/CLEAN SIPP DATASETS***********************
******************************************************
*inputs: raw data downloaded from NBER
*output: sipp_annual*

** this keeps the variables we want from each data set and renames and recodes a few of them, then appends the waves from each year together 

if c(username)=="chloeeast" | c(username)=="Chloe" | c(username)=="davidsimon"  | c(username)=="elizabeth" {
do "${dofiles}/01b_extract_sipp.do"
}



******************************************************
**********CREATE ADULT VARIABLES FOR JOBLOSS PAPERS***************
* this includes jobloss related variables, demographic variables, income variables 
* keep only working age adults, append state data on 
* keep only relevant variables for all adults
******************************************************
*inputs: sipp_annual*
*output: spell_*', sipp_cleaned.dta
do "${dofiles}/01c_createunemp.do"


			******************************************************
***************** 		CREATE child insurance DATASET		***********************
* this starts with spell panel SIPP data sets, keeps only kids, cleans up kid health insurance variables & just keeps those
			******************************************************
*inputs spell_*
*outputs: chyeaout.dta
do "${dofiles}/01d_childinsurance.do"


			******************************************************
***************** 		CALCULATE ALTERNATE UI UNDER-REPORTING RATES		***********************
* this uses IRS numbers from Larrimore, et al. and uses these numbers to calculate under-reporting rates by income centile
			******************************************************
*inputs: sipp_cleaned.dta, LMS-UI-data.xlsx
*outputs: SIPP_respondent_reporting.dta, SIPP_dollars_reporting.dta,  
do "${dofiles}/01e_a_generate_rr_centiles.do"


*************************************************
*****************CREATE Regression DATASET***********************
* keeps only job losers and cleans up variables related to job loss
*************************************************
*inputs:  sipp_cleaned.dta, chyeaout.dta
*outputs: sipp_reg.dta
do "${dofiles}/01e_b_createjoblss.do"

*create control
do "${dofiles}/01f_createcontrol.do"

*inputs: sipp_reg.dta
*outputs:regfinal.dta
do "${dofiles}/01g_finalcleaning.do"



log close
