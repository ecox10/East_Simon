

			
****************************
*** 1996-2008 Surveys
****************************

pause on

foreach syear in 96 01 04 08 {

	** Extract up to last health wave available in each panel       
	if `syear'==01 local maxw 9
	if `syear'==96 | `syear'==04 local maxw 12
	if `syear'==08 local maxw 16

	** Clean each wave first
	forvalues i=1(1)`maxw' {
		di ""
		di "THIS LOOP IS FOR YEAR `syear' AND WAVE `i'"
		di ""

			use "${rawdata}/sipp`syear'_`i'.dta", clear
		
		
		if `syear'==01 | `syear'==04 | `syear'==08 {
		rename rhpov thpov 
		rename rfpov tfpov
		}
	 
		*** Keep variables of interest
	if `syear'==96 | `syear'==01{
 	keep ssuseq ssuid eentaid shhadid spanel swave srotaton srefmon rhcalmn rhcalyr tfipsst ///
				ehhnumpp rhtype whfnwgt thtotinc thearn tmthrnt rfid efnp tftotinc tfearn rsid esfnp tstotinc epppnum eppintvw ///
				wpfinwgt tage tbyear esex erace eorigin ems epnspous tptotinc tpearn rmesr rwksperm rwkesr1 rwkesr2 rwkesr3 ///
				rwkesr4 rwkesr5 rmwkwjb eeducate emax ejobcntr ersnowrk eawop eabre eptwrk eptresn elkwrk elayoff ///
				rtakjob rnotake emoonlit rmwksab rmwklkg rmhrswk eeno1 estlemp1 tsjdate1 tejdate1 ersend1 ejbhrs1 tpmsum1 ///
				tpyrate1 rpyper1 ejbind1 tjbocc1 ecntrc1 eeno2 estlemp2 tsjdate2 tejdate2 ersend2 ejbhrs2 tpmsum2 ///
				tpyrate2 rpyper2 ejbind2 tjbocc2 *01amta *01amtk thsocsec *03amta *03amtk *04amt thssi euectyp5 ///
				auectyp5 *05amt *27amt thfdstp *20amt thafdc emrtjnt emrtown tmiown rfnkids etenure ecrmth rmedcode ecdmth ///
				ehimth ehiowner ehemply ehicost ehirsn* epndad epnmom ebuscntr thpov tfpov t25amt a25amt ///
				rnklun efreelun efrerdln  eresnss1 ehotlunc  errp ///
				efsyn er25 eegyast eegyamt  rnklun /* (by Yangkeun): added additional variables */ ///
				t15amt   epubhse tmthrnt elmptyp3 egvtrnt edisabl edisprev tbmsum1 tbmsum2 
				  
				
						
	}
			

			
		
	
if `syear' ==04 | `syear'==08 {
keep ssuseq ssuid eentaid shhadid spanel swave srotaton srefmon rhcalmn rhcalyr tfipsst ///
				ehhnumpp rhtype whfnwgt thtotinc thearn tmthrnt rfid efnp tftotinc tfearn rsid esfnp tstotinc epppnum eppintvw ///
				wpfinwgt tage tbyear esex erace eorigin ems epnspous tptotinc tpearn rmesr rwksperm rwkesr1 rwkesr2 rwkesr3 ///
				rwkesr4 rwkesr5 rmwkwjb eeducate emax ejobcntr ersnowrk eawop eabre eptwrk eptresn elkwrk elayoff ///
				rtakjob rnotake emoonlit rmwksab rmwklkg rmhrswk eeno1 estlemp1 tsjdate1 tejdate1 ersend1 ejbhrs1 tpmsum1 ///
				tpyrate1 rpyper1 ejbind1 tjbocc1 ecntrc1 eeno2 estlemp2 tsjdate2 tejdate2 ersend2 ejbhrs2 tpmsum2 ///
				tpyrate2 rpyper2 ejbind2 tjbocc2 *01amta *01amtk thsocsec *03amta *03amtk *04amt thssi euectyp5 ///
				auectyp5 *05amt *27amt thfdstp *20amt thafdc emrtjnt emrtown tmiown rfnkids etenure ecrmth rmedcode ecdmth ///
				ehimth ehiowner ehemply ehicost ehirsn* epndad epnmom ebuscntr thpov tfpov t25amt a25amt ///
				rnklun efreelun efrerdln  efreebrk efrerdbk eresnss1 ehotlunc ebrkfst errp ///
				efsyn er25 eegyast eegyamt rnkbrk rnklun /* (by Yangkeun): added additional variables */ ///
				t15amt epaothr5  epubhse tmthrnt elmptyp3 egvtrnt epubhstp edisabl edisprev   tbmsum1 tbmsum2 
				}				
				
		*** Rename variables
			foreach x in suid panel wave {
			rename s`x' `x'
			}
			rename eentaid entry
			rename ssuseq suseqnum                  
			rename srotaton rot     
			rename shhadid addid    
			rename srefmon refmth           
			rename rhcalmn mth              
			rename rhcalyr year             
			rename tfipsst statefip         
			rename ehhnumpp hnp             
			rename rhtype htype             
			rename whfnwgt hwgt             
			rename thtotinc hinc            
			rename thpov hpov            
			rename tfpov fpov            
			rename thearn hearn             
			rename tmthrnt phrent           
			rename rfid famid               
			rename efnp fnp         
			rename tftotinc finc            
			rename tfearn fearn             
			rename rsid subfid              
			rename esfnp snp                
			rename tstotinc sinc
			rename epppnum pnum
			rename eppintvw intvw
			rename wpfinwgt p5wgt
			rename tage age
			foreach x in sex race ms {
				rename e`x' `x'
			}
			rename tbyear brthyr
			rename eorigin ethncty
			rename epnspous pnsp
			rename tptotinc totinc
			rename tpearn earn
			rename rmesr esr
			rename rwksperm wks
			forvalues x=1(1)5 {
				rename rwkesr`x' wesr`x'
			}
			rename rmwkwjb wksjob
			rename eeducate higrade
			rename ejobcntr numjobs
			rename ebuscntr numbus
			rename ersnowrk whynotwork
			rename eawop fullweekout_yn
			rename eabre whyabsent
			rename eptwrk less35_yn
			rename eptresn whyless35
			rename elkwrk lookwork_yn
			rename elayoff layoff_yn
			rename rtakjob takjob_yn
			rename emoonlit moonlit_yn
			rename rmwksab wksabs
			rename rmwklkg wkslok
			rename rmhrswk uhrs_code
			rename ecntrc1 union_yn
			foreach x in 1 2 {
				rename estlemp`x' stlemp`x'_yn
				rename tsjdate`x' stdate`x'
				rename tejdate`x' enddate`x'
				rename ersend`x' whystop`x'
				rename ejbhrs`x' uhours`x'
				rename tpmsum`x' ws`x'amt
				rename tpyrate`x' ws`x'hrwg
				rename rpyper`x' ws`x'freqpay
				rename ejbind`x' ws`x'ind
				rename tjbocc`x' ws`x'occ
			}

			*** Welfare/Insurance program participation and $$
			rename t01amta ss_amt                           // SS-Own
			rename a01amta ss_amt_flag

			rename t01amtk ss_ch_amt                        // SS-Child
			rename a01amtk ss_ch_amt_flag
			rename thsocsec h_ss_amt

			rename t03amta ssi_amt                          // SSI-Own
			rename a03amta ssi_amt_flag

			rename t03amtk ssi_ch_amt                       // SSI-Child
			rename a03amtk ssi_ch_amt_flag

			rename t04amt ssi_st_amt                        // SSI-State-Own
			rename a04amt ssi_st_amt_flag
			rename thssi h_ssi_amt

			rename euectyp5 ui_yn                           // UI
			rename auectyp5 ui_flag
			rename t05amt uiamt
			rename a05amt uiamt_flag

			rename t27amt fs_amt                            // Food Stamps
			rename a27amt fs_amt_flag
			rename thfdstp h_fs_amt

			rename t20amt tanf_amt                  // Public Assistance
			rename a20amt tanf_amt_flag
			rename thafdc h_tanf_amt
			
			rename t25amt wic_amt					// WIC
			rename a25amt wic_amt_flag

			rename rnklun numk_lunch
			rename ehotlunc any_lunch
			rename efreelun frp_lunch
			rename efrerdln frp_lunch_type				// free or reduced price lunch or breakfast
			cap rename rnkbrk numk_breakf
			cap rename ebrkfst  any_breakf
			cap rename efreebrk frp_breakf
			cap rename efrerdbk frp_breakf_type

			
			rename eresnss1 reason_ssa      		// reason for receiving SSA income (to flag SSDI)
			
			
			rename emrtjnt mtg_yn
			rename emrtown ownmtg_yn
			rename tmiown intpd_mtg
			rename rfnkids nkidshl
			rename etenure hownstat
			rename ecrmth carecov
			rename rmedcode medcode
			rename ecdmth caidcov
			rename ehimth hiind
			rename ehiowner hiown 
			rename ehemply hisrc 
			rename ehicost hipay
						
			rename efsyn getfs
			rename er25 getwic
			rename eegyast getenrgy
			rename eegyamt enrgyamt
			rename t15amt sevrpay
			rename elmptyp3 othrlump
			
			rename epubhse pubhsing
			rename egvtrnt getsbrnt
			
			
			* Disability Variables 
			rename edisabl worklimit_disa
			rename edisprev workprevent_disa
			for any worklimit_disa workprevent_disa: replace X = 0 if X ==2
			for any worklimit_disa workprevent_disa: replace X = . if X ==-1
			
				
	
		    

		* household identifier
			gen strpanel = string(panel)
			gen strshhadid = string(addid)
		  gen hhid = strpanel+suid+ "0" +strshhadid		
		
		 * Fix merging variables
		 for any addid suid pnum entry: capture qui destring X, replace
		 replace pnum = 1000*entry+pnum
		 
		 *** Recode binary vars
		 replace sex=sex-1
		 label define sexlabel 0 M 1 F
		 label values sex sexlabel
		 
			for any fullweekout_yn less35_yn lookwork_yn layoff_yn takjob_yn moonlit_yn ///
				stlemp1_yn union_yn stlemp2_yn ui_yn mtg_yn ownmtg_yn: replace X=. if X==-1 \ replace X=-(X-2)

			label define yesno 0 no 1 yes
			for any fullweekout_yn less35_yn lookwork_yn layoff_yn takjob_yn moonlit_yn ///
				stlemp1_yn union_yn stlemp2_yn ui_yn mtg_yn ownmtg_yn: label values X yesno
				
		* gen hhold level WIC amount received
		browse hhid panel wave mth errp wic_amt
		bysort hhid panel wave mth: egen h_wic_amt=total(wic_amt)

		
						 
		 tempfile temp`syear'w`i'
		 save `temp`syear'w`i'', replace
	}


	*** Append waves together
	use `temp`syear'w1', clear
	forvalues i=2(1)`maxw' {
		 append using `temp`syear'w`i''
	}       

	compress
	save "$outputdata/sipp_annual`syear'", replace
}
