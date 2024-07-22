/*Master program: East, Simon: Using the SIPP to look impacts on safety net income
Created by: Chloe East
Created on: 8/10/21

*/


*front matter
macro drop _all
clear all
set more off
capture log close
set seed 03021981

local today : di %tdCY.N.D date("$S_DATE", "DMY")



*********************************************************************;
/* DIRECTORY AND FILE NAMES: */  
clear all 



	if c(username)=="chloeeast" {  		// for Chloe's computer
			global dir "/Users/chloeeast/Dropbox"	 	 	
			global dofiles "/Users/chloeeast/Documents/GitHub/East_Simon/makedata"	 	 	
		} 
		else{ 
			if c(username)=="Chloe" {  		// for Chloe's laptop
			global dir "/Users/Chloe/Dropbox"
	 	 	*global dofiles "****Chloe to fill in with github path"
			} 
		else 
			if c(username)=="das13016" {  //for David's laptop
			global dir "\Users\das13016\Dropbox\Research and Referee work\papers\Under Review"
			global dofiles "/Users/das13016/Documents/GitHub/East_Simon/makedata"
			}
		else if c(username)=="elizabeth" {
			global dir "/Users/elizabeth/Dropbox"
			global dofiles "/Users/elizabeth/Documents/GitHub/East_Simon/makedata"
		}
			} 

if c(username)=="das13016"  {
global rawdata "$dir/rawdata"
global outputdata "$dir\child SIPP longterm\analysis\samples"
global samples "$dir/Intergen Sipp/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
global ek_rawdata "$dir\child SIPP longterm\literature\Jobloss Papers\Elira_JMP_datafiles\Data\Raw\StateYear"
global ek_outputdata "$dir\Intergen Sipp\child SIPP longterm\literature\Jobloss Papers\Elira_JMP_datafiles\Data\RegData"
global rv_outputdata "$dir/child SIPP longterm/analysis/dofiles/Jobloss/Aux data and setupcode/Safety Net Calculators/"
global outputlog "/Users/das13016/Documents/GitHub/East_Simon/logs"
global joblessnessdir "C:\Users\das13016\Dropbox\Research and Referee work\papers\Under Review\Intergen Sipp\child SIPP longterm\analysis\samples"
global results  "C:\Users\das13016\Dropbox\Research and Referee work\papers\Under Review\Intergen Sipp\child SIPP longterm\analysis\output\JobLosers_SafetyNet"

}

if c(username)=="chloeeast" | c(username)=="Chloe"   {
global rawdata "$dir/rawdata"
global outputdata "$dir/child SIPP longterm//analysis/samples/JobLosers_SafetyNet"
global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
global ek_outputdata "C:\Users\das13016\Dropbox\Research and Referee work\papers\Under Review\Intergen Sipp\child SIPP longterm\literature\Jobloss Papers\Elira_JMP_datafiles\Data\RegData"
global rv_outputdata "$dir/child SIPP longterm/analysis/dofiles/Jobloss/Aux data and setupcode/Safety Net Calculators"
global outputlog "/Users/chloeeast/Documents/GitHub/East_Simon/logs"
global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}

if c(username)=="elizabeth"   {
global rawdata "$dir/rawdata"
global joblessnessdir "$dir/child SIPP longterm/analysis/samples"
global outputdata "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
global samples "$dir/child SIPP longterm/analysis/samples/JobLosers_SafetyNet"
global ek_rawdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/Raw/StateYear"
global ek_outputdata "$dir/child SIPP longterm/literature/Jobloss Papers/Elira_JMP_datafiles/Data/RegData"
global rv_outputdata "$dir/child SIPP longterm/analysis/dofiles/Jobloss/Aux data and setupcode/Safety Net Calculators"
global outputlog "/Users/elizabeth/Documents/GitHub/East_Simon/logs"
global results "$dir/child SIPP longterm/analysis/output/JobLosers_SafetyNet"
}

#delimit ;





