/*********************
File Name: 01_CleanData.do

This do file cleans the raw data and generate datasets for results for
"The safety net and job loss: How much insurance do public programs provide?" 

By: Chloe East and David Simon

Inputs: sipp`syear'_`wave'.dta, ek_data
Outputs: sipp_annual`syear'".dta, sipp_cleaned.dta, regfinal.dta
***********************/

global makedata "" // dir for contents of East_Simon/makedata
global rawdata "" // dir for contents of East_Simon/data/rawdata
global ek_data "" // this is the directory for Elira Kuka's UI data (link in readme)  
global lms_data "" // directory for Larrimore, et al.'s IRS UI data (link in readme)
global outdata "" // dir for contents of East_Simon/data/outdata
global underreporting "" // dir for contents of East_Simon/data/underreporting
global results ""

*****
*Create state control data sets, once this is run once, don't need to run again
do "${makedata}/01a_state_controls.do"

********************************************************************************
*****************************   SIPP DATASETS   ********************************
********************************************************************************

******************************************************
*****************EXTRACT/CLEAN SIPP DATASETS***********************
******************************************************
*inputs: raw data downloaded from NBER
*output: sipp_annual*

** this keeps the variables we want from each data set and renames and recodes a few of them, then appends the waves from each year together 

do "${makedata}/01b_extract_sipp.do"

******************************************************
**********CREATE ADULT VARIABLES FOR JOBLOSS PAPERS
* this includes jobloss related variables, demographic variables, income variables 
* keep only working age adults, append state data on 
* keep only relevant variables for all adults
******************************************************
*inputs: sipp_annual*
*output: spell_*', sipp_cleaned.dta
do "${makedata}/01c_createunemp.do"


******************************************************
***************** 		CREATE child insurance DATASET		
* this starts with spell panel SIPP data sets, keeps only kids, cleans up kid health insurance variables & just keeps those
******************************************************
*inputs spell_*
*outputs: chyeaout.dta
do "${makedata}/01d_childinsurance.do"


******************************************************
***************** 		CALCULATE ALTERNATE UI UNDER-REPORTING RATES	
* this uses IRS numbers from Larrimore, et al. and uses these numbers to calculate under-reporting rates by income centile
******************************************************
*inputs: sipp_cleaned.dta, LMS-UI-data.xlsx
*outputs: SIPP_respondent_reporting.dta, SIPP_dollars_reporting.dta,  
do "${makedata}/01e_a_generate_rr_centiles.do"


*************************************************
*****************CREATE Regression DATASET
* keeps only job losers and cleans up variables related to job loss
*************************************************
*inputs:  sipp_cleaned.dta, chyeaout.dta
*outputs: sipp_reg.dta
do "${makedata}/01e_b_createjoblss.do"

* inputs: controlsetup.dta
* outputs:  control_never.dta
do "${makedata}/01f_createcontrol.do" //create control

*inputs: sipp_reg.dta
*outputs:regfinal.dta
do "${makedata}/01g_finalcleaning.do"



