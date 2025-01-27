cd "G:/.shortcut-targets-by-id/1Q3GyXgC2nVFMrZfGl4tcth9boAGj0oKm/WHO-PEN/Phase 1/10_Data/"

do "0_macros.do"


*TODO: add controlled variables

/* special missings:
    .r = refused in specific question
    .q = refused in previous question resulting in skipping current question

    .d = don't know in specific question
    .c = don't know in previous question resulting in skipping current question

    .s = skip pattern caused by answer to previous question

    .m = is missing by mistake because of programming or technical issue

    v2023-01-09: removed enumerator specific refusals/nonresponse. If needed, look at previous do-file version.
*/

**** Individual level data ****
/*
import excel "$raw/WHO-PENScale_Questionnaire_11.11.2022_-_all_versions_-_False_-_${fileindiv}.xlsx", sheet("WHO-PEN@Scale Questionnaire ...") firstrow clear

    do "$lbls/Lbl_Indivlvl.do"
    numlabel, add
    destring, replace

    save "$raw/IndivImported", replace
*/
    use "$raw/IndivImported", clear
    rename  i_hhid hhid

    

****************************************************************************************************************************************************************
**************************************************************** PRE-SCREENING *********************************************************************************
****************************************************************************************************************************************************************


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx BASIC CLEANING xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    * indicator for different versions
        gen screenday = substr(si19, 9,2)
        gen screenmonth = substr(si19, 6,2)
        destring screenday screenmonth, replace

        gen version = ""
        * up to Friday 4.11.2022 version 1
        replace version = "v1" if screenmonth < 11
        replace version = "v1" if screenmonth == 11 & screenday <= 4
        * up to Friday 11.11.2022 version 2
        replace version = "v2" if screenmonth == 11 & screenday > 4 & screenday <= 11
        * up to ??
        replace version = "v3" if screenmonth == 11 & screenday > 11 & screenday <= .
        replace version = "v3" if screenmonth == 12 
        tab version,m

    * renaming and dropping variables not needed
        rename (i_si12 i_ss2) (i_enumid name)

        drop i_hhidcheck The_household_IDs_do_and_enter_c

    * duplicates 
        * tag duplicates
        replace name = subinstr(name, " ", "", .)
        duplicates tag hhid name, gen(d)
        tab d,m
        sort hhid name
        br if d>0

    * find out if the duplicates results from several visits
        gen consent = (i_si13==1)
        bysort hhid name: gen sumconsent = sum(consent)
        by hhid name: replace sumconsent = sumconsent[_N]
        
        br hhid name consent sumconsent i_si13xx if d > 1

        gen ok = .
        replace ok = 1 if d>1 & sumconsent == 0 // visited several times, never interviewed
        replace ok = 1 if d == 1 & sumconsent == 1 // visited twice, interviewed once
        drop if ok == 1 & i_si13 != 1
        duplicates tag hhid name, gen(d2) // check that those with several visits are now no duplicates anymore
        tab d2 if ok == 1 & i_si13 == 1,m
        replace d = 0 if ok == 1 & i_si13 == 1 // replace original duplicate variable
        drop ok d2

    * correct names:
        replace name = "JB" if hhid == "11-10-MM21-05" & ss7 == 1
        replace name = "KJB" if hhid == "11-10-MM21-05" & ss7 == 2
        replace name = "MH" if hhid == "13-10-FM10-20" & age_calc2 == 68
        replace name = "SBM" if hhid == "13-10-TD17-05" & age_calc2 == 74
        replace name = "SS2" if hhid == "17-10-HM16-07" & ss7 == 2 & name == "SS"
        replace name = "SPD" if hhid == "24-10-NF19-01" & ss7 == 2 & name == "JD"
        replace name = "HM" if hhid == "12-10-SD08-02" & name == "SM"
        replace name = "ND" if hhid == "13-10-SD08-08" & name == "NM"
        replace name = "JM" if hhid == "13-10-SD08-08" & name == "DM"
        replace name = "N.P.S" if hhid == "16-10-MM21-02" & age_calc2 == 40
        replace name = "N.S.S" if hhid == "16-10-MM21-02" & age_calc2 == 49
        replace name = "TF" if hhid == "22-10-FM15-03" & ss7 == .
        replace name = "NS" if hhid == "25-10-FM10-04" & name == "TS" & ss7 == 1
        replace name = "SM" if hhid == "28-10-MS03-01" & age_calc2 == 65
        replace name = "GS" if hhid == "28-10-NS07-12" & age_calc2 == 67 // not sure about this one though
        replace name = "30-10-HM16-02" if hhid == "30-10-HM16-02" & age_calc2 == 46
        replace name = "P.M" if hhid == "31-10-SD12-12" & age_calc2 == 40
        replace name = "LG" if hhid == "28-10-HM16-01" & age_calc2 == 44
        replace name = "BM" if hhid == "03-11-PM13-07" & ss7 == 2 & name == "03-11-PM13-07"
        replace name = "MM" if hhid == "03-11-PM13-07" & ss7 == 1 & name == "03-11-PM13-07"
        replace name = "MSM" if hhid == "01-12-MS03-03" & ss9 == 40
        replace name = "MV" if hhid == "01-12-MS03-03" & ss9 == 75
        replace name = "MM" if hhid == "04-11-TD17-07" & age_calc2 == 84 & name == "JZ"
        replace name = "GN" if hhid == "06-11-MM21-02" & ss9 == 42
        replace name = "IN" if hhid == "06-11-MM21-02" & ss9 == 61
        replace name = "LN" if hhid == "07-11-FM15-05" & age_calc2 == 45 & name == "VN"
        replace name = "PM" if hhid == "09-11-MS03-01" & ss7 == 1
        replace name = "DZ1" if hhid == "13-11-SD12-10" & ss7 == 2
        replace name = "SS" if hhid == "14-11-MM21-05" & ss9 == 53
        replace name = "SM" if hhid == "14-11-MM21-05" & ss9 == 77
        replace name = "MNH" if hhid == "16-11-MS03-08" & ss7 == 1
        replace name = "DN" if hhid == "16-11-PN06-02" & age_calc2 == 62
        replace name = "VH" if hhid == "16-11-SD08-09" & ss9 == 58
        replace name = "DM" if hhid == "20-11-CD14-01" & name == "LM" & age_calc2 == 68
        replace name = "DG" if hhid == "20-11-SG09-04" & name == "DSS" & age_calc2 == 54
        replace name = "MNM" if hhid == "21-11-HM16-01" & name == "MM" & age_calc2 == 63
        replace name = "SPS" if hhid == "21-11-HM16-03" & name == "SS" & age_calc2 == 62
        replace name = "Tl" if hhid == "21-11-NS07-08" & name == "NS" & age_calc2 == 61
        replace name = "SNZ" if hhid == "23-11-MS03-07" & ss9 == 50
        replace name = "AM" if hhid == "27-11-FM15-06" & age_calc2 == 66
        replace name = "S.E.M" if hhid == "02-12-MM21-08" & ss9 == 50
        replace name = "SN" if hhid == "05-12-NK05-04" & age_calc2 == 48
        replace name = "JM" if hhid == "05-12-NM28-05" & age_calc2 == 62
        replace name = "BM" if hhid == "06-12-HM16-05" & age_calc2 == 40
        replace name = "PS" if hhid == "07-12-NM28-04" & age_calc2 == 40
        replace name = "S.T.M" if hhid == "08-12-MM21-08" & ss9 == 42
        replace name = "Lk" if hhid == "08-12-NS07-05" & age_calc2 == 45
        replace name = "Lk" if hhid == "05-12-HM16-06" & age_calc2 == 53

        drop if name == "YM" & hhid == "23-10-MM24-04" & fbg == 4.7 // this really seems to be the same person with two different FBG levels. I am keeping the one with more data
        drop if name == "DT" & hhid == "07-11-NM04-02" & m9  == 5.3 // this really seems to be the same person but I don't understand why she once has HbA1c and once refused.
        drop if name == "TF" & hhid == "22-10-FM15-03" & screeningconsent == 2 // this person probably refused first but then agreed to participate in the survey
        drop if name == "MM" & hhid == "09-11-NS07-01" & m3s == 133 // seems to be same person but one interview is incomplete
        * this one probably belongs to another HH:
        replace name = "??" if hhid == "21-10-TT23-04" & ss9 == . & name == "MN"
        * wrong birth date inserted accidentally and second entry generated
        drop if hhid == "11-10-NF19-05" & age_calc2 == 33
        drop if hhid == "07-12-NF19-04" & age_calc2 == 0

    * wrong HH IDs:
        replace hhid = "11-10-TN18-05" if hhid == "11-10-TN18-07" & name == "EMS"
        replace hhid = "17-10-SD08-02" if hhid == "12-10-SD08-02" & name == "FS"
        replace hhid = "11-10-SD08-03" if hhid == "12-10-SD08-03" & name == "TM"
        replace hhid = "11-10-SD08-05" if hhid == "12-10-SD08-03" & name == "SN"
        replace hhid = "11-10-SD08-06" if hhid == "12-10-SD08-06" & name == "TN"
        replace hhid = "23-10-SD08-03" if hhid == "12-10-SD08-06" & name == "LM"
        replace hhid = "12-10-SG09-12" if hhid == "12-10-SG09-09" & name == "SK"
        replace hhid = "14-10-FM10-03" if hhid == "13-10-FM10-03" & name == "VV"
        replace hhid = "14-10-FM10-03" if hhid == "13-10-FM10-03" & name == "S.N"
        replace hhid = "12-10-SD08-05" if hhid == "13-10-SD08-05" & name == "SM"
        replace hhid = "12-10-SD08-09" if hhid == "13-10-SD08-08" & name == "DZ"
        replace hhid = "13-10-CD14-05" if hhid == "14-10-CD14-05" & name == "ZN"
        replace hhid = "13-10-SD08-06" if hhid == "14-10-SD08-06" & name == "MN"
        replace hhid = "15-10-SD08-06" if hhid == "14-10-SD08-06" & name == "KG"
        replace hhid = "14-10-CD14-04" if hhid == "15-10-CD14-04" & name == "EM"
        replace hhid = "14-10-CD14-04" if hhid == "15-10-CD14-04" & name == "MM"
        replace hhid = "17-10-TN18-02" if hhid == "16-10-TN18-03" & name == "KLN"
        replace hhid = "19-10-MS03-12" if hhid == "19-10-MS03-13" & name == "MD"
        replace hhid = "21-10-MS03-20" if hhid == "21-10-MS03-03" & name == "ZD"
        replace hhid = "22-10-SG09-07" if hhid == "22-10-SG09-06" & name == "SLM"
        replace hhid = "23-10-NS07-02" if hhid == "23-10-NS07-08" & name == "TS"
        replace hhid = "23-10-TT23-02" if hhid == "23-10-TT23-01" & name == "DN"
        replace hhid = "29-10-MM24-07" if hhid == "29-10-MM24-06" & name == "NM" & age_calc2 == 71
        replace hhid = "22-11-HM16-04" if hhid == "22-11-HM16-08" & name == "JD" & age_calc2 == 48
        replace hhid = "30-10-MM21-10" if hhid == "30-11-MM21-10" & name == "P.D" & ss9 == 78
        replace name = "PD" if hhid == "30-10-MM21-10" & name == "P.D" & ss9 == 78
        
        drop d
        duplicates tag hhid name, gen(d)
        tab d,m
        sort hhid name

        br hhid name ss7 ss8 ss9 age_calc2 if d>0 & i_si13 == 1
        br hhid name ss7 ss8 ss9 age_calc2 if hhid == "05-12-HM16-06"

        drop d
        *! 31-10-MM24-01, 04-11-FM10-02, 18-11-HM16-11, 20-11-NS07-01, 06-12-HM16-02, 07-12-NM28-03, 07-12-SM25-07, 08-12-CD14-01, 08-12-CD14-02
        *! 08-12-NM28-05
            *! are a duplicates both in the individual level data as well as in the HH roster. Probably two different households.

        *!  02-12-NM28-02, 02-12-NM28-05 have duplicates but are not in roster

        *! 18-11-HM16-04, 05-12-HM16-06 this household is bigger than in the roster and has one name duplicate

        *! 06-12-HM16-05 DOB and clin_htn of the duplicates are not the same 


    * Enumerator information
        * correct enumerator IDs
        gen temp = regexs(0) if(regexm(i_enumid, "[A-Z][A-Z][0-9][0-9]"))
        replace temp = i_enumid if temp == ""
        replace temp = subinstr(temp, " ", "", .)
        tab temp,m
        replace temp = "HM16" if temp == "Hm16"
        replace temp = "TN18" if temp == "TN"
        replace temp = "SD12" if temp == "Sd12"
        replace temp = "HM16" if temp == "HM"
        replace temp = "TT23" if temp == "Tt23"
        replace temp = "MM21" if inlist(hhid, "03-12-MM21-02","09-12-MM21-06") & temp == "MM"
        replace temp = "MM21" if inlist(hhid, "03-12-MM21-02","09-12-MM21-06") & temp == "MM2"
        replace temp = "MS03" if inlist(hhid,"25-10-MS03-05","02-12-MS03-07","16-11-MS03-11","21-11-MS03-01","24-11-MS03-04","25-11-MS03-02","05-12-MS03-06","09-12-MS03-04") ///
            & temp == "M"
        replace temp = "SD08" if hhid == "14-11-SD08-06" & temp == "Sd"
        replace temp = "FM15" if hhid == "06-11-FM15-01" & temp == "F"
        replace temp = "FM15" if hhid == "26-11-FM15-04" & temp == "GM"
        replace temp = "FM15" if hhid == "22-11-SM25-03" & temp == "LN"
        replace temp = "MS03" if hhid == "24-11-MS03-11" & temp == "NS"
        replace temp = "NF19" if temp == "5004041100428"
        replace temp = "SM36" if hhid == "19-11-SM36-03"
        replace temp = "SM36" if temp == "BM36"
        *! this variable is not entirely clean yet. There are still some "singles", which might be because
        *! a replacement did the interview

        rename i_enumid i_enumid_orig
        rename temp i_enumid

        * Enumerator indicator for filtering
        bysort i_enumid: gen enum_n = 1 if _n == 1

        * number of individuals per enumerator
        bysort i_enumid: egen indivnum = count(hhid)
        sort indivnum
        br i_enumid indivnum if enum_n == 1


    * reason for not interviewing
        tab i_si13,m
        tab i_si13xx,m

        gen temp = subinstr(i_si13xx, " ", "", .)

        gen reason = ""
            replace reason = "Refused" if inlist(temp, "FamilytoldusthattheyhavealltheequipmenttotestBPandbloodsugar,theydoiteverynowandthen,sotheyrefusedtobetestedorinterviewed")
            replace reason = "Refused" if inlist(temp, "Refusedtoparticipatefurther..","ParticipantRefused","ParticipantRefused","Refused,saidshetestedathospitalyersterday")
            replace reason = "Refused" if inlist(temp, "Participantrefused","Refusetocontinuewiththesuvery","Sherefused,shesaidshewilldoitataclinicinMatsapha","Participantrefused")
            replace reason = "Refused" if inlist(temp, "Participantranaway(Herefused)","Participantrefusedtocontinuewiththeinterview..","Participantrefusedtocontinuewithinterview")
            replace reason = "Refused" if inlist(temp, "Thehouseholdmemberrefusedtobescreenedyetshehadinitiallyagreed","Refused","Refusal","Husbandrefusedtoparticipateintheinterview,hesaidheisnotinterested,anddidnothearanythingaboutthestudyfromcommunityleaders.")
            replace reason = "Refused" if inlist(temp, "Refused,can'tparticipateanymore.","Theparticipantrefused","Refusedtoparticipate","Refusedtocontinuewithinterview")
            replace reason = "Refused" if inlist(temp, "Participantrefusedtoparticipatefurtherwiththequestionnaire..","Refusedtoparticipateinthesurvey,statedthathedoesnotbelieveinmodernmedicine,andwasnottoldofusbycommunityleaders")
            replace reason = "Refused" if inlist(temp, "Refusedtotest","NolongerrecognizesthegovernmentofEswatini.","Idothetesteveryafter3months","Householdmembernotfoundandwhencalledherefusedtotestsaidheisaherbalist")
            replace reason = "Refused" if inlist(temp, "Amatraditionalhealer","Phobiaofneedles","Notinterested","Nolongerinterested","Notwillinganymore","Participantrefusal")
            replace reason = "Refused" if inlist(temp, "Recentlywenttotheclinicforscreening","ParticipantRefusal","Partisansrefused","Householdmembernolongerwillingtobescreened","Participantnotlongerwillingtobetested")
            replace reason = "Refused" if inlist(temp, "Refusedtoparticipatefurther","Herefused","Notinterestedwithtestingbecauseshehasaccesstoservicesattheclinic","HusbandRefused,toparticipateinthesurvey")
            replace reason = "Refused" if inlist(temp, "REFUSAL","Changedhermindandrefused","Participantnotpickingupandhasblockedus","EligibleParticipantrefusedtopartakeinthesurvey")
            replace reason = "Refused" if inlist(temp, "Sherefusedtocontinuewiththesurvey,shesaidshewillcontinueiftherewasmedication","Wehadsetanappointmentwithher,sheknewthatwewerecomingbutnowsheisignoringourcalls.")
            replace reason = "Refused" if inlist(temp, "Refusedscreeningandinterview","Refusedinterviewandscreening","ParticipantnotavailableforHbA1Ctesting","Notavailableforscreening")
            replace reason = "Refused" if inlist(temp, "Refusedscreening","Participantnotavailableforscreening","RefusedHbA1CscreeningafterahighFBS","Alreadytestedintheclinic","Notinterestedanymore.")
            replace reason = "Refused" if inlist(temp, "Notinterested.","Refusedtobescreened.","Refusedbecausehebecamebusy.","Refusinginterviewbecauseheisbusy","RefusedHBa1Ctest","Participantrefusedtobetested")
            replace reason = "Refused" if inlist(temp, "Testedattheclinic","Alreadytestedattheclinic","Refusal,hasBPandFBsmachines","Participantnownotwillingtoparticipate","Participantnotwillingtobetested")
            replace reason = "Refused" if inlist(temp, "Refusal.Theyhavemonitoringmachines","Alreadytestedattheclinic","Refusedtodothescreening,nolongercomfortable","Refusedbecausesheisgoingaway.")
            replace reason = "Refused" if inlist(temp, "Heisveryoldandprimitiveandveryreluctanttobetested","Participantnotwillingtoparticipate","Sheisreluctanttobetestedanddoesn'twanttobetestedanymore")
            replace reason = "Refused" if inlist(temp, "Participantnolongerwillingtobetested","Participantfromclinicwherehewasscreenedfordiabetesandhypertension","Sherefusedtoparticipate","Idon'twanttoparticipate")
            replace reason = "Refused" if inlist(temp, "Theparticipantisnotavailableforthisstudy","Herefusedtobepartofthestudy","OnlywantedanHIVtest.Testconducted,result:negative","Shefelttestingwillnothelpherinanyway.")
            replace reason = "Refused" if inlist(temp, "Nomoreinterestedbecausetherearenopills.","Refusedtocontinuewiththequestionaire","refusal","Refusedagainsthisreligiousbeliefs")
            replace reason = "Refused" if inlist(temp, "Participantwasnotpresentduringsampling,thewifegaveconsentasheadofhouse.Thehusbanddeniedconsentingatindivlevel","Participantrefusedtocontinue","Herefusedtobepartofthestudy.")
            replace reason = "Refused" if inlist(temp, "Saidhavetorushtochurchearlythanusualanddoesn'twanttobepartofthisercercise","Refusedtobeprickedwithneedle","Ranawaydoesn'twanttogettested.")
            replace reason = "Refused" if inlist(temp, "Rushingtochurchandnolongerinterested","NolongerinterestedbecauseafraidtoknowtestresultsofDiabetesandHypertension","Politicalissues","She'snolongerinterested")
            replace reason = "Refused" if inlist(temp, "Heranaway","Participantrefusedscreeningandinterview","Refusedparticipating","RefusalwillscreentomorrowatMbabaneGovernmentHospital","Refusedtotestbecauseherhusbandtoldhernotto")
            replace reason = "Refused" if inlist(temp, "Idon'thavetimeforyou","Idon'twant","Ialreadytested","Nomoreinterestedtocontinuewiththequestionnairebecausetherearenodrugs.","Notinterestedanymore")
            replace reason = "Refused" if inlist(temp, "Refuseandl","Sherefused.Shesaidshehashermachinesinherhousehold","Refusedtoparticipatebecausesuddenlywenttochurchatnightandnevercamebackinthemorning")


        replace reason = "Not present" if inlist(temp, "Notavailable","Notavailable,thirdvisit","Goneforextendedperiods","Unavailable","Goneforanextendedperiodoftime","Goneforwork")
            replace reason = "Not present" if inlist(temp, "Sheisawayvisitingdistantfamilyfriends.","Noavailable(admittedtohospital)","Notavailablewenttovisithergranddaughter(leftyesterday)")
            replace reason = "Not present" if inlist(temp, "Goneforanextendedperiod","Wasnotathomeafterthethirdvisit","Notavailablefora2weeks","Participantrefusestoparticipate(travelingtoSouthAfrica)")
            replace reason = "Not present" if inlist(temp, "Nolongeravailableduefamilymatters","Notavailablebecauseofpersonalreasons","Notavailableduetopersonalreasons","Nolongeravailable")
            replace reason = "Not present" if inlist(temp, "UnavailablewenttoDurban","Unavailableforamonth","Hewasinahurryandwillbeawayforanextendedperiod.","Gonetosouthafrica")
            replace reason = "Not present" if inlist(temp, "Notavailablefor2weeks","Awayfromhomeforthenext4weeks","Workingoddhours","Awayformorethanoneweek","Shesnomorestayingatthesearea")
            replace reason = "Not present" if inlist(temp, "She'snotathomeforalongtimenow","Heisrelocated","Sheleftthecountryafter2weeks","She'snotinthisplaceformorethanamonth")
            replace reason = "Not present" if inlist(temp, "Absentforamonth","HeisinSouthAfricaforayear","Particpantabsentformorethanaweek","Participantsabsentformorethanaweek")
            replace reason = "Not present" if inlist(temp, "Householdmembersabsentformorethanaweek","Participantnolongeravailable","Participantnotavailableformorethanaweek","Participantnothome")
            replace reason = "Not present" if inlist(temp, "Participantisnotavailableandwillbeawayfor6days","Shewillbeawayfromhomeforaweek.","Wenthomefortheweekend","Participantabsentformorethanaweek")
            replace reason = "Not present" if inlist(temp, "Participantnotavailableattimeofvisitdespiteappointment","HeishomeinMozambique","Absentmorethanaweek","Heownsaforhire,uhlalaesteshini.Heisataximan.")
            replace reason = "Not present" if inlist(temp, "Absent","Shewasfetchedbyherhusband","Stillawayafter3visits","Notavailablemorethanaweek","Participantnotavailablefortheappointment")
            replace reason = "Not present" if inlist(temp, "Goneonavacation","Participantnotavailablefortheoppointed","Solousesibhedlela,admittedatmbabanegovernmenthospital","Unavailableattimeofappointment.")
            replace reason = "Not present" if inlist(temp, "Willnotbehomeforthenext3weeks,leavingthisafternoon","WasnotathomeduringthissecondVisit","Participantnotavailableforthenext2weeks")
            replace reason = "Not present" if inlist(temp, "Goneonvacation","Awayforthepast3weeksfamilymembersdon'tknowwhenshe'llbeback","Wasnotathomeanwillbeawayforanotherweek")
            replace reason = "Not present" if inlist(temp, "Householdmembernotfound","Notfound","Notfoundafter3rdvisit","Notfound","Goingawayforthewholeweek","Sheisgoingawayandwon'tbeavailablefor30days.")
            replace reason = "Not present" if inlist(temp, "CanceledappointmenthewenttoSouthAfricaforafuneralandwillbebackin12days","WentawayandcomingbackinDecember","Wentawayandcomingbackin3weeks")
            replace reason = "Not present" if inlist(temp, "Goingawayforalongtime","Awayformonths","Absentformorethanaweek","Hospitalized","Absentduringcheckups","Participantnotavailableafterall3visits")
            replace reason = "Not present" if inlist(temp, "Unavailableforalongtime,foundajobinanotherarea","GonetoSouthAfrica","Participantnotfoundandwillbeabsentforsometime","Notavailableattimeofvisitdespiteappointmentbeingmade.")
            replace reason = "Not present" if inlist(temp, "Notavailableformorethan2weeks.","Awayforaperiodoftime","Nothome","Atwork","Nothomerushedforpersonalappointments","Participantnotfoundformorethanaweek","Heisadmittedathospital")
            replace reason = "Not present" if inlist(temp, "Heisatwork","Heisawayfromhomeforwork","ParticipantRelocated","Worksoddhours","Participateisavailableforalongerperiodoftime","Participantnotavailableasperappointment")
            replace reason = "Not present" if inlist(temp, "Participantwenttothehospital","Notavailableasperappointment","Notavailableasperourappointment","Hesaidheisnolongerinterestedinparticipating")
            replace reason = "Not present" if inlist(temp, "Notavailableonsecondvisit","Nitavailableon3rdvisit","Notavailableonsecondvisit","Notavailableforscreeningandinterview","Notavailableonsecondvisitforscreeningandinterview")
            replace reason = "Not present" if inlist(temp, "Shelefthome,willbebackafter3weeks","Participantnotavailableonthirdvisit","Participantnotavailableforthethirdvisit","Worksawayfromhome,leftforworkthismorning,willbebacknextmonthend")
            replace reason = "Not present" if inlist(temp, "Sheisrushingout,andwillbeupsetfor2weeks","Wenttoafuneral","Notavailableafterallvisits","Wentearlyforworkandcomingbackaftertwoweeks","Becamebusyandgoingawayfor4dayswithwife.")
            replace reason = "Not present" if inlist(temp, "Suddenlybecamebusyandgoingaway.","Notavailableduetounknownreasons","Doesnotrespondwhenwecall")
            replace reason = "Not present" if inlist(temp, "Gonetotakecareofanemergency","Participantisnotavailableforextendedperiod","Participantnotavailableafterallvisits")
            replace reason = "Not present" if inlist(temp, "Disappeared","Alreadyleft","Notfoundathome","Beencalledbylabadzala","Leftforwork","Participantleftforwork")
            replace reason = "Not present" if inlist(temp, "DoneFBSwentforavisitlater","Goneforavisittocomebackon17/10/22","Busywithwork","Heisnotavailable,hewenttoafuneral.")
            replace reason = "Not present" if inlist(temp, "Shehasalreadyhadbreakfast","Notavailableattimeofvisit","Notavailableattimeofvisit,wenttoafuneral.","Hehadwasintoxicated,postponed")
            replace reason = "Not present" if inlist(temp, "NotavailableTtimeofvisit.","Stillnotavailable.","Participantnotavailable","Heisnotathome","Heisnotavailable")
            replace reason = "Not present" if inlist(temp, "NotAvailable","Hadtorushsomewhere","Inahurryhadreceivedacallfromwork.","Ambusy","Notpickingupcalls","Awayforawhile","She'sawayfromhomeforamonth")
            replace reason = "Not present" if inlist(temp, "Participantlefttheplace","Notavailableathome","Notavailableonappointmentday","Heisnotathome,theysaidhewenttothehospital.","Notavailableonappointmentday")
            replace reason = "Not present" if inlist(temp, "Notavailableandphoneisoff","Notathomeatallvisits","Participantwenttochurchonappointmentday","HHmembernotavailable","Participantunavailable")
            replace reason = "Not present" if inlist(temp, "Emergency,shewenttoJohannesburg","Participantwasnotfoundathomebecausesheletftotheclinicearlyinthemorningfollowingfallingverysickthepreviousnight")

        replace reason = "Unable" if inlist(temp, "Sheisverysick","Hesaidhewon'tbeabletodothetests","Incapacitated","Sheisincapacitated,failedcognitiveability","Physicallydisabled")
            replace reason = "Unable" if inlist(temp, "Incapacitated,cannotmove,see,norhear.Thusincompetentingivingconsenttocontinuewiththetestingandinterview")
            replace reason = "Unable" if inlist(temp, "Hearingimpairment","Verysick","Mentalhealthissue","Bedriddenandsick","Physicallychallenged","Notcompetent")
            replace reason = "Unable" if inlist(temp, "Sheisverysickandcan'tcooperate","Notcompetentenough","Participantisill","Participantisillandbedridden","Incompetent")
            replace reason = "Unable" if inlist(temp, "Foundhimintoxicated.","She'sdrunk","Incompetent,hasahearingproblem","Participantwashitbystrokeandcannotindependentlyparticipateinthestudy")
            replace reason = "Unable" if inlist(temp, "Participantnotmentallystable","Participantisincompetent","Physicallyunable","Incompetent,mentallychallenged")
            replace reason = "Unable" if inlist(temp, "Incompetentmentallydisturbed","Notmentallystable","Participantwasfoundcriticallysickonthedayofscreeningandshewasimmediatelytakenbythefamilytothehospital")
        
        replace reason = "not eligible" if inlist(temp, "Ineligible","Participantwasenteredtwiceandhasbeeninterviewedunderhousehold29-10-LM22-02","Participantnoteligible","Liedaboutherage")
        replace reason = "Other test related" if inlist(temp, "Participantalreadyhadsomethingtoeat","Hb1Acunavailable","Haveeaten","Alreadyate")
    
        br temp if reason == "" & temp != ""
    */
    * confirmation of age resulted in 3 individuals being below 40
        tab elig_age2,m
        drop if elig_age2 == 0
        drop elig_age2

    *export excel using "$temp/individual_only1visit.xlsx", firstrow(variables) nolabel replace
    
    * merge with blinded study arm info
    *merge m:1 hhid using "$clean/blinding_2022-03-01"

    * for now, I drop those without a sucessful merge
    *drop if _merge != 3
    *drop _merge


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx REFUSALS - SCREENING xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    * no individual interview rate (reason: any):
        * this is the non-response rate
        count if hhid != "" 
        scalar total = r(N)
        count if i_si13 == 2 // i_si13: "Will you screen and interview ${i_ss2}?"
        scalar noii = r(N)
        di noii/total
        gen iinonrrate = (noii/total)*100
        lab var iinonrrate "individual interview non-response (any reason)"


    * no individual interview rate (reason: refusal):
        * this is the refusal rate (subset of noiirate)
        count if hhid != "" 
        count if reason == "Refused"
        scalar iirefusal = r(N)
        di iirefusal/total
        gen iirefusalrate = (iirefusal/total)*100
        lab var iirefusalrate "individual interview non-response (refusal)"

   

    * only keep those for whom the survey was started
        keep if i_si13 == 1

    * refusals of screening 
        count if hhid != "" 
        scalar total2 = r(N)
        count if screeningconsent == 2 
        scalar screfusal = r(N)
        di screfusal/total2
        gen screfusalrate = (screfusal/total2)*100
        lab var screfusalrate "screening interview non-response (refusal)"

    * Overall non-response (either individual interview or screening)
        gen ovnonrrate = ((screfusal+noii)/total)*100
        tab ovnonrrate,m
        lab var ovnonrrate "Overall non-response (either individual interview or screening)"


    * Overall refusal (either individual interview or screening)
        gen ovrefusalrate = ((screfusal+iirefusal)/total)*100
        tab ovrefusalrate,m
        lab var ovrefusalrate "Overall refusal (either individual interview or screening)"

        drop if screeningconsent == 2
        drop screeningconsentinfo screeningconsent screeningconsentsign screeningconsentsign_URL READ_First_I_woul_e_currently_pr READ_First_I_woul_to_confirm_you

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx AGE & clin_htn xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    * sex 
        tab ss7,m // has no missings
        gen female = (ss7==2) 
        lab var female "Respondent is female (ss7)"
        lab def female 0 "0.Male" 1 "1.Female"
        lab val female female

    * age
        tab ss9,m
        gen age = age_calc2
        replace age = ss9 if age == . 
        tab age,m // has no missings
        lab var age "Respondent's age (age_calc2, ss9)"

    * drop pregnant women
        * those who DK, are assumed to not be pregnant (n=3)
        tab ss10 ss7,m
        drop if ss10 == 1 // 4 observations dropped
        drop note_pregnant ss10

****************************************************************************************************************************************************************
****************************************************************** SCREENING ***********************************************************************************
****************************************************************************************************************************************************************

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx DISEASE HISTORY Xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    ** Previous BP measurement and htn diagnosis
        * in the newly generated variables, DKs and Refusals will be included as 0. 
        
        * replace don't knows with .d and refusals with .r in self-reported HTN variables
            forv q = 1/3 {
                replace hbp`q' = .r if hbp`q' == 88
                replace hbp`q' = .d if hbp`q' == 77
            }
            lab def yn12 1 "1.Yes" 2 "2.No" //.d ".d.Don't know" .c ".c.Prev. .d skip" .r ".r.Refused" .q ".q.Prev. .r skip"
            lab def yn01 0 "0.No" 1 "1.Yes" //.d ".d.Don't know" .c ".c.Prev. .d skip" .r ".r.Refused" .q ".q.Prev. .r skip"
        
        * ever had blood pressure measured
            tab hbp1, m
        * new ever measured variable
            gen h_ms = (hbp1==1) if hbp1 < . // recode 2 to 0
            replace h_ms = hbp1 if hbp1 >= . // transfer missings
            replace h_ms = 0 if inlist(hbp1, .d,.r) // Don't know and refused are set to 0. 
            lab var h_ms "Ever had BP measured (hbp1)"
            lab val hbp1 yn12
            lab val h_ms yn01
            tab hbp1 h_ms,m
       
        * ever diagnosed with hypertension
            tab hbp2,m
            replace hbp2 = .s if hbp1 == 2 // skip if never measured BP
            replace hbp2 = .q if hbp1 == .r // answer to hbp1 was refuse
            replace hbp2 = .c if hbp1 == .d // answer to hbp1 was DK
        * new diagnosis variable
            gen h_told = (hbp2==1) if hbp2 < . // recode 2 to 0
            replace h_told = hbp2 if hbp2 >= . // transfer missings
            replace h_told = 0 if h_told == .s // never measured BP
            replace h_told = 0 if inlist(h_told, .d,.c,.r,.q) // Don't know and refused are set to 0. 
            lab var h_told "Ever was diagnosed with HTN (hbp2)"
            lab val hbp2 yn12
            lab val h_told yn01
            tab hbp2 h_told ,m

        * currently takes hypertension medication
            tab hbp3,m    
            replace hbp3 = .s if inlist(2,hbp1,hbp2) // skip if never measured BP or never diagnosed
            replace hbp3 = .q if inlist(hbp2, .r,.q) // answer to hbp1 or hbp2 was refuse
            replace hbp3 = .c if inlist(hbp2, .d,.c) // answer to hbp1 or hbp2 was DK
            replace hbp3 = 2 if inlist(hbp8x, "Has never been initiated ","Not in care","Not in care ") // consistency correction with later answers
        * new medication variable
            gen h_med = (hbp3==1) if hbp3 < . // recode 2 to 0
            replace h_med = hbp3 if hbp3 >= . // transfer missings
            replace h_med = 0 if h_med == .s // never measured BP and never diagnosed
            replace h_med = 0 if inlist(h_med, .d,.c,.r,.q) // Don't know and refused are set to 0. 
            lab var h_med "Currently takes HTN medication (hbp3)"
            lab val hbp3 yn12
            lab val h_med yn01
            tab hbp3 h_med,m
    
    ** Previous BG measurement and diabetes diagnosis
        * in the newly generated variables, DKs and Refusals will be included as 0. 
        
        * replace don't knows with .d and refusals with .r
            forv q = 1/4 {
                replace hd`q' = .r if hd`q' == 88
                replace hd`q' = .d if hd`q' == 77
            }
            
        * ever had blood sugar measured
            tab hd1, m
        * new ever measured variable
            gen dm_ms = (hd1==1) if hd1 < . // recode 2 to 0
            replace dm_ms = hd1 if hd1 >= . // transfer missings
            replace dm_ms = 0 if inlist(dm_ms, .d,.r)  // Don't know and refused are set to 0. 
            lab var dm_ms "Ever had BG measured (hd1)"
            lab val hd1 yn12
            lab val dm_ms yn01
            tab hd1 dm_ms,m
   
        * ever diagnosed with diabetes
            tab hd2,m
            replace hd2 = .s if hd1 == 2 // skip if never measured BG
            replace hd2 = .q if hd1 == .r // answer to hd1 was refuse
            replace hd2 = .c if hd1 == .d // answer to hd1 was DK
        * new diagnosis variable
            gen dm_told = (hd2==1) if hd2 < . // recode 2 to 0
            replace dm_told = hd2 if hd2 >= . // transfer missings
            replace dm_told = 0 if dm_told == .s // never measured BG
            replace dm_told = 0 if inlist(dm_told, .d,.c,.r,.q)  // Don't know and refused are set to 0. 
            lab var dm_told "Ever was diagnosed with Dm (hd2)"
            lab val hd2 yn12
            lab val dm_told yn01
            tab hd2 dm_told,m

        * currently takes oral diabetes medication
            tab hd3,m    
            replace hd3 = .s if inlist(2, hd1,hd2) // skip if never measured BG or never diagnosed
            replace hd3 = .q if inlist(hd2, .r,.q) // answer to hd1 or hd2 was refuse
            replace hd3 = .c if inlist(hd2, .d,.c) // answer to hd1 or hd2 was DK
            replace hd3 = 2 if inlist(hd10x, "Not in care") // consistency correction with later answers
        * new oral medication variable
            gen dm_omed = (hd3==1) if hd3 < . // recode 2 to 0
            replace dm_omed = hd3 if hd3 >= . // transfer missings
            replace dm_omed = 0 if dm_omed == .s // never measured BG and never diagnosed
            replace dm_omed = 0 if inlist(dm_omed, .d,.c,.r,.q)  // Don't know and refused are set to 0. 
            lab var dm_omed "Currently takes oral DM medication (hd3)"
            lab val hd3 yn12
            lab val dm_omed yn01
            tab hd3 dm_omed,m

        * currently takes insulin
            tab hd4,m    
            replace hd4 = .s if inlist(2, hd1,hd2) // skip if never measured BG or never diagnosed
            replace hd4 = .q if inlist(hd2, .r,.q)  // answer to hd1 or hd2 was refuse
            replace hd4 = .c if inlist(hd2, .d,.c)  // answer to hd1 or hd2 was DK
            replace hd4 = 2 if inlist(hd10x, "Not in care") // consistency correction with later answers
        * new insulin variable
            gen dm_insulin = (hd4==1) if hd4 < . // recode 2 to 0
            replace dm_insulin = hd4 if hd4 >= . // transfer missings
            replace dm_insulin = 0 if dm_insulin == .s // never measured BG and never diagnosed
            replace dm_insulin = 0 if inlist(dm_insulin, .d,.c,.r,.q)  // Don't know and refused are set to 0. 
            lab var dm_insulin "Currently takes insulin (hd4)"
            lab val hd3 yn12
            lab val dm_insulin yn01
            tab hd4 dm_insulin,m

        * currently takes oral medication or insulin 
            gen dm_anymed = (dm_omed == 1 | dm_insulin == 1) if dm_omed < . | dm_insulin < .
            lab var dm_anymed "Currently takes oral DM medication or insulin (hd3,hd4)"
            lab val dm_anymed yn01
            tab dm_anymed,m
            tab dm_anymed dm_omed,m
            tab dm_anymed dm_insulin,m

        * has been diagnosed with pre-diabetes
            tab hd6,m
            replace hd6 = .d if hd6 == 77
            replace hd6 = .s if hd1 == 2 // never measured
            replace hd6 = .s if hd2 == 1 // diagnosed with diabetes
            replace hd6 = .c if inlist(.d, hd1,hd2) // DK whether diagnosed with diabetes

        * new prediabetes diagnosis variable
            gen pd_told = (hd6==1) if hd6 < . // recode 2 to 0
            replace pd_told = hd6 if hd6 >= . // transfer missing values
            replace pd_told = 0 if inlist(pd_told, .s, .d, .c,.r,.q) // DK, refused, and never measured are recoded to "No"
            replace pd_told = .s if hd2 == 1 // previous diabetes diagnosis does not rule out ever diagnosed with pre-diabetes --> .s is kept
            replace pd_told = .m if version == "v1" & pd_told == . // was moved to eligibility assessment only in version 2
            lab var pd_told "Ever diagnosed with prediabetes (hd6)"
            lab val pd_told yn01
            tab hd6 pd_told,m

           lab val elig_htn yn01
           lab val elig_dm yn01
           lab val elig_ncd yn01
           lab val elig_syn yn01




*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx MEASUREMENTS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    ** blood pressure measurements
    * correct consent variable if both measurements have been refused
        replace m0 = 2 if m3s == 888 & m4s == 888 // they also have 888 in diastolic

        forv m = 3/5 {
            replace m`m's = .r if m`m's == 888  // refusal systolic
            replace m`m'd = .r if m`m'd == 888  // refusal diastolic
            replace m`m's = .q if m0 == 2 // no consent systolic
            replace m`m'd = .q if m0 == 2 // no consent diastolic
        }
        *? 10 people refused the second measurement. What shall we do with them? All of them have elig_htn == 1

        tab elig_htn if m5s == .,m
        * the upper limit for the calculation of average blood pressure was accidentally set to 240 instead
        * of 300, which is the limit for the individual measurements. Thus, four observations have a missing
        * value in average systolic blood pressure. All of them were interviewed anyway because they had a high
        *diastolic blood pressure. Thus, no data were lost. 
        replace m5s = (m3s+m4s)/2 if m5s == .
        tab m5s,m
        tab m5d,m

    * new variables for average blood pressure values
        gen sbp_avg = m5s
        lab var sbp_avg "Average systolic blood pressure (m5s)"
        gen dbp_avg = m5d
        lab var dbp_avg "Average diastolic blood pressure (m5d)"

    * person has high BP
        gen highbp = 1 if (m5s>=140 & m5s<.) | (m5d>=90 & m5d<.)
        replace highbp = 0 if m5s < 140 & m5d < 90
        replace highbp = .r if m5s == .r
        replace highbp = .q if m5s == .q
        lab var highbp "BP of >=140/90 (m5s, m5d)"
        lab val highbp yn01
        tab highbp,m

        drop READ_Your_blood_pr_ons_such_as_a READ_Your_blood_pr_your_blood_pr READ_Your_blood_pr_continues_to_ READ_Your_blood_pr_or_a_formal_c    

    * person has high BP or reports previous htn diagnosis
        gen clin_htn = 0 if highbp == 0 & h_told == 0
        replace clin_htn = 1 if highbp == 1 | h_told == 1
        replace clin_htn = .q if inlist(highbp, .q,.r)
        lab var clin_htn "Has clinical hypertension (high BP or previous diagnosis) (m5s,m5d,hbp2)"
        lab val clin_htn yn01

    ** fasting blood glucose measurements:
    * fasting status and consent
        tab m6,m // consent BG measurement
        replace m6 = 2 if fbg == 888 & m9 == 888 // individuals refused both BG measurements despite having given consent
        tab fast,m // has eaten before = 1; this is a counter-intuitive variable name --> rename it
        rename fast ate
        replace ate = .q if m6 == 2
        lab var ate "Individual ate/drank something in past 12 hours (fast)"
        tab fbg ate,m // is only measured for those who did not eat
        tab m9 ate,m // is measured independent of prior eating

    * fasting blood glucose
        replace fbg = .s if ate == 1 // is only measured for those who did not eat
        replace fbg = .r if fbg == 888 // refused fbg measurement
        replace fbg = .q if m6 == 2 // did not give consent for BG measurements
        tab fbg,m
        lab var fbg "Fasting blood glucose test result (fbg)"
        *? What would be sensible upper limits for FBG?
        
    * person has elevated fasting blood glucose (5.56-7 mmol) - prediabetes
        gen elevfbg = 1 if fbg >= 5.56 & fbg <= 7 // fbg between 5.56 and 7
        replace elevfbg = 0 if fbg < 5.56 | (fbg > 7 & fbg < .) // fbg higher/lower than that range
        replace elevfbg = .s if fbg == .s // has eaten --> no fbg measurement
        replace elevfbg = .q if inlist(fbg, .r,.q) // refused fbg measurement
        lab var elevfbg "Individual has pre-diabetes (fbg)"
        lab val elevfbg yn01
        tab elevfbg,m

    * person has high fasting blood glucose (>7 mmol) - diabetes
        gen highfbg = 1 if fbg > 7 & fbg < . // fbg larger than 7
        replace highfbg = 0 if fbg <= 7 // fbg 7 or less
        replace highfbg = .s if fbg == .s // has eaten --> no fbg measurement
        replace highfbg = .q if inlist(fbg, .r,.q) // refused fbg measurement
        lab var highfbg "Individual has diabetes (fbg)"
        lab val highfbg yn01
        tab highfbg,m

    * person has elevated or high fasting blood glucose (>5.56 mmol) - prediabetes or diabetes
        gen highelevfbg = 1 if elevfbg == 1 | highfbg == 1
        replace highelevfbg = 0 if elevfbg == 0 & highfbg == 0
        replace highelevfbg = .s if fbg == .s // has eaten --> no fbg measurement
        replace highelevfbg = .q if inlist(fbg, .r,.q) // refused fbg measurement
        lab var highelevfbg "Individual has pre-diabetes or diabetes (fbg)"
        lab val highelevfbg yn01
        tab highelevfbg,m

    ** HbA1c measurement
        * version 1 relevance: ${fbg}>=5.56 or ${fast}='1'
        * version 2 relevance: ${fbg}>=5.56 or ${fast}='1' or ${hd2} = '1' or ${hd6} = '1'
        tab m9,m
        replace m9 = .s if fbg < 5.56 & version == "v1" // low FBG reading --> no HbA1c necessary
        replace m9 = .m if m9 >= . & fbg < 5.56 & (hd2 == 1) & version == "v1" // n=13;
                        // low FBG reading --> no HbA1c necessary BUT should have been done because of previous diabetes diagnosis
        replace m9 = .m if m9 >= . & fbg < 5.56 & (hd6 == 1) & version == "v1" // n=2
                        // low FBG reading --> no HbA1c necessary BUT should have been done because of previous pre-diabetes diagnosis
        replace m9 = .s if fbg < 5.56 & hd2 != 1 & hd3 != 1 & inlist(version, "v2", "v3") // low FBG reading and no previous diagnosis --> no HbA1c necessary
        replace m9 = .q if m6 == 2 // refused BG measurements
        replace m9 = .r if inlist(m9, 888,8888) // refused HbA1c measurement
        tab m9,m 
        gen hba1c = m9
        lab var hba1c "HbA1c test result (m9)"
        *? What would be sensible upper limits for FBG?
        
    * person has elevated HbA1c (5.7-6.4%) - prediabetes
        gen elevhba1c = 1 if m9 >= 5.7 & m9 <= 6.4 // HbA1c between 5.7 and 6.4
        replace elevhba1c = 0 if m9 < 5.7 | (m9 > 6.4 & m9 < .) // HbA1c higher/lower than that range
        replace elevhba1c = .s if m9 == .s // low FBG reading --> no HbA1c necessary
        replace elevhba1c = .q if inlist(m9, .r,.q) // refused all BG or only HbA1c measurements
        replace elevhba1c = .m if m9 == .m // missing by accident
        lab var elevhba1c "Individual has pre-diabetes (m9)"
        lab val elevhba1c yn01
        tab elevhba1c,m

    * person has high HbA1c (>6.4%) - diabetes
        gen highhba1c = 1 if m9 > 6.4 & m9 < . // HbA1c of more than 6.4
        replace highhba1c = 0 if m9 <= 6.4 // HbA1c of 6.4 or less
        replace highhba1c = .s if m9 == .s // low FBG reading --> no HbA1c necessary
        replace highhba1c = .q if inlist(m9, .r,.q) // refused all BG or only HbA1c measurements
        replace highhba1c = .m if m9 == .m // missing by accident
        lab var highhba1c "Individual has diabetes (m9)"
        lab val highhba1c yn01
        tab highhba1c,m

    * person has elevated or high HbA1c - prediabetes or diabetes
        gen highelevhba1c = 1 if elevhba1c == 1 | highhba1c == 1
        replace highelevhba1c = 0 if elevhba1c == 0 & highhba1c == 0
        replace highelevhba1c = .s if m9 == .s // low FBG reading --> no HbA1c necessary
        replace highelevhba1c = .q if inlist(m9, .r,.q) // refused all BG or only HbA1c measurements
        replace highelevhba1c = .m if m9 == .m // missing by accident
        lab var highelevhba1c "Individual has pre-diabetes or diabetes (m9)"
        lab val highelevhba1c yn01
        tab highelevhba1c,m

    * people with high FBG but low HbA1c (i.e. those that probably did not fast but said they did)
        count if highelevhba1c < . 
        scalar highelevhba1c_N = r(N)
        count if highelevfbg == 1 & highelevhba1c == 0
        scalar lowhba1c_n = r(N)
        di lowhba1c_n/highelevhba1c_N

        drop fbgelev fbgnormal READ_Your_blood_gl_blood_glucose READ_Your_blood_gl_ons_such_as_a BF READ_Your_blood_gl_level_This_is READ_Your_blood_gl_linic_for_a_c elig_ncd_note elig_syn_note

    * person has high BG or reports previous DM diagnosis
        gen clin_dm = 0 if (highfbg == 0 | highhba1c == 0) & dm_told == 0
        replace clin_dm = 1 if (highhba1c == 1) | dm_told == 1
        replace clin_dm = .q if highhba1c == .q & clin_dm == .
        lab var clin_dm "Has clinical diabetes (high HbA1c or previous diagnosis) (fbg,m9,hd2)"
        lab val clin_dm yn01

    * person has elevated BG or reports previous pre-DM diagnosis
        gen clin_pd = 0 if (elevfbg == 0 | elevhba1c == 0) & pd_told == 0
        replace clin_pd = 1 if (elevhba1c == 1 | pd_told == 1)
        replace clin_pd = 0 if clin_dm == 1
        replace clin_pd = .m if pd_told == .m & clin_pd == .
        replace clin_pd = .q if  elevhba1c == .q & clin_pd == .
        lab var clin_pd "Has clinical prediabetes (elevated HbA1c or previous diagnosis) (fbg,m9,hd6)"
        lab val clin_pd yn01

    * person has hypertension and diabetes
        gen clin_htndm = 0 if clin_htn == 0 | clin_dm == 0
        replace clin_htndm = 1 if clin_htn == 1 & clin_dm == 1
        replace clin_htndm = .q if clin_htn == .q | clin_dm == .q
        lab var clin_htndm "Has diabetes and hypertension (clin_dm, clin_htn)"
        lab val clin_htndm yn01

    * person has no hypertension or diabetes
        gen no_htndm = 1 if clin_htn == 1 | clin_dm == 1
        replace no_htndm = 0 if clin_htn == 0 | clin_dm == 0
        replace no_htndm = .q if clin_htn == .q | clin_dm == .q
        lab var no_htndm "Has no diabetes or hypertension (clin_dm, clin_htn)"
        lab var no_htndm yn01



    ** syndemics interview
        tab elig_syn,m
        tab syn_sel,m
        replace syn_sel = .s if elig_syn == 0 // was not eligible for syndemics interview
        replace syn_sel = .s if syn_required == 1 // syndemics interview in HH was already conducted
        replace syn_sel = .q if m0 == 2 | m6 == 2 // no consent for either BP or BG measurement
        *replace syn_sel = .q if m5s == .q | m5d == .q | (inlist(fbg, .q,.r) & inlist(m9, .q,.r))
        replace syn_sel = .m if m9 == .m
        drop syn_yes syn_no syn_done
        lab val syn_sel yn01
        tab syn_sel,m

****************************************************************************************************************************************************************
************************************************************* EXTENDED ASSESSMENT ******************************************************************************
****************************************************************************************************************************************************************

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx REFUSALS - EXTENDED ASSESSMENT xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    * refusals of extended interview (NCD extended interview)
        * those who did not continue the interview among those who were eligible bc of NCDs
        count if hhid != "" & ext_consent < . & elig_ncd == 1
        scalar totalintNCD = r(N)
        count if ext_consent == 2  & elig_ncd == 1
        scalar refusalintNCD = r(N)
        di refusalintNCD/totalintNCD
        gen refusalinterviewrateNCD = (refusalintNCD/totalintNCD)*100
        lab var refusalinterviewrateNCD "refusals of extended interview (NCD extended interview)"

    * refusals of extended interview (Syndemics extended interview)
        * those who did not continue the interview among those who were eligible for syndemics
        count if hhid != "" & ext_consent < . & syn_sel == 1
        scalar totalintsyn = r(N)
        count if ext_consent == 2 & syn_sel == 1
        scalar refusalintsyn = r(N)
        di refusalintsyn/totalintsyn
        gen refusalinterviewratesyn = (refusalintsyn/totalintsyn)*100
        lab var refusalinterviewratesyn "refusals of extended interview (Syndemics extended interview)"

    * drop individuals that did not consent to extended interview:
        keep if ext_consent == 1

    *eligible bc of diabetes: 1530
        count if elig_dm == 1
    *eligible bc of hypertension: 3820
        count if elig_htn == 1
    * eligible bc of both diabetes and hypertension: 1064
        count if elig_dm == 1 & elig_htn == 1
    * eligible bc of syndemics: 718
        count if syn_sel == 1


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx SOCIO-DEMOGRPAHICS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    

    * marital status
        tab ps1,m
        replace ps1 = .r if ps1 == 88 // answer to ps1 was refused
    * new marital status variable
        gen marital = ps1
        lab var marital "Marital status (ps1)"
        lab copy ps1 marit
        lab val marital marit
        tab ps1 marital,m

    * origin
        tab ps3,m // has no missings
    * new origin variable
        gen swazi = (ps3==1)  // recode 2 to 0
        lab var swazi "Swazi origin (ps3)"
        lab def swa 0 "Non-Swazi" 1 "Swazi"
        lab val swazi swa
        tab ps3 swazi,m

    * stayed in community for at least three months    
        tab ps4n,m
        replace ps4n = .r if ps4n == 88 // answer to ps4n was refused

        * drop those that stayed in community for less than three months:
        drop if ps4n == 2 | ps4n == .r // 1 person refused
        drop ps4n
        *? think about when to drop them. I would drop them at the very beginning and not
        *? include them in response rate?

    * education
        tab ps7,m
        replace ps7 = .d if ps7 == 77 // answer to ps7 was don't know
        replace ps7 = .r if ps7 == 88 // answer to ps7 was refused
        * new education variable
        gen educ = ps7
        lab var educ "Highest completed level of education (ps7)"
        lab copy ps7 ed
        lab val educ ed
        tab educ ps7,m

    * main work status
        tab ps9,m
        replace ps9 = .r if ps9 == 99 // answer to ps9 was refused
        * new work variable
        gen work = ps9
        lab var work "Main working activity in past 12 months (ps9)"
        lab copy ps9 wrk
        lab val work wrk
        tab ps9 work,m


        * for protocol: (has high measurement or reports diagnosis)
        count if elevhba1c == 1 | hd6 == 1
        count if highhba1c == 1 | dm_told == 1
        count if highbp == 1 | h_told == 1



*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx HYPERTENSION - CARE HISTORY xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    
    ** details on hypertension diagnosis
        * diagnosed in past 12 months
            tab hbp5n,m
            replace hbp5n = .d if hbp5n == 77 // answer to hbp5n was DK
            replace hbp5n = .s if inlist(2, hbp1,hbp2) // never had BP measured or was never diagnosed
            replace hbp5n = .c if inlist(.d, hbp1,hbp2) // answer to hbp1 or hbp2 was DK
            tab hbp5n,m

        * new htn diagnosis in past 12 months variable
            gen h_told12 = (hbp5n==1) if hbp5n < . // recode 2 to 0
            replace h_told12 = hbp5n if hbp5n >= . // transfer missing values
            replace h_told12 = 0 if inlist(h_told12, .s, .d, .c,.r,.q) // DK and refused are recoded to "No"
            lab var h_told12 "Was diagnosed with hypertension in past 12 months (hbp5n)"
            lab val h_told12 yn01
            tab hbp5n h_told12,m

        * location of diagnosis
            tab hbp6,m
            tab hbp6x
            tab hbp5n if hbp6 == .,m
            replace hbp6 = .s if inlist(2, hbp1,hbp2,hbp5n) // never had BP measured, was never diagnosed, or was diagnosed more than 12 months ago
            replace hbp6 = .c if inlist(.d, hbp1,hbp2,hbp5n) // answer to hbp1, hbp2 or hbp5n was DK
            replace hbp6 = 334 if hbp6x == "South africa"
            * new code for private doctor and pharmacy
            replace hbp6 = 444 if inlist(hbp6x,"Dr Jonathan ")
            replace hbp6 = 445 if inlist(hbp6x, "Pharmacy ")
            replace hbp6x = "" if hbp6 < 99998
            tab hbp6_name,m
            replace hbp6_name = ".s" if hbp6 == .s
            replace hbp6_name = ".c" if hbp6 == .c
                        *TODO: Send clinic list (with all clinics) to CHAI and ask them to categorize into primary, secondary, and tertiary facilities
                        *TODO: Send hbp6x list to CHAI to check if they fit in any of our clinic codes.

        * ever taken medication
            tab hbp7,m
            replace hbp7 = .d if hbp7 == 77 // answer to hbp7 was DK
            replace hbp7 = 2 if inlist(hbp8x, "Has never been initiated ","Not in care","Not in care ") // indicated later that never initiated treatment
            replace hbp7 = .s if hbp3 == 1 // reported currently taking mediation
            replace hbp7 = .s if inlist(2, hbp1,hbp2) // never had BP measured or was never diagnosed
            replace hbp7 = .c if inlist(.d, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was DK
            replace hbp7 = .q if inlist(.r, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was refused

        * new ever med variable
            gen h_evermed = (hbp7 == 1) if hbp7 < . // recode 2 to 0
            replace h_evermed = hbp7 if hbp7 >= . // transfer missing values
            replace h_evermed = 0 if inlist(h_evermed, .d,.c,.r,.q) // DK and refused are recoded to "No"
            replace h_evermed = 0 if inlist(2, hbp1,hbp2) // never had BP measured or was never diagnosed
            lab var h_evermed "Has ever taken BP medication (hbp7)"
            lab val h_evermed yn01
            tab hbp7 h_evermed,m
            *.s are those that currently take medication

        * location of treatment initiation
            tab hbp8,m
            tab hbp8x,m
            replace hbp8 = . if inlist(hbp8x, "Has never been initiated ","Not in care","Not in care ") // is considered to never have been initiated
            replace hbp8x = "" if inlist(hbp8x, "Has never been initiated ","Not in care","Not in care ") // is considered to never have been initiated
            replace hbp8 = 334 if inlist(hbp8x, "South Africa","South Africa ","NZH in South Africa ","Albert Hospital, South Africa ")
            replace hbp8 = .d if hbp8x == "Does not remember "
            replace hbp8 = .s if inlist(2, hbp1,hbp2,hbp3,hbp7) // never measured, never diagnosed, no current or past meds
            replace hbp8 = .c if inlist(.d, hbp1,hbp2,hbp3,hbp7)  // answer to hbp1, hbp2, hbp3 or hbp7 is DK          

            * new code for private doctor/clinic
            replace hbp8 = 335 if inlist(hbp8x,"Dr Colts","Dr Futhi","Dr Gama special Dr","Dr Jonathan ","Dr Mathunjwa","Dr Mathunjwa (Special Doctor) ")
            replace hbp8 = 335 if inlist(hbp8x,"Dr Mnisi","Dr Sacolo ","Dr Sacolo, private practioner","Dr T. Thwala","Exipro special doctor ","Dr Twala")
            replace hbp8 = 335 if inlist(hbp8x, "Private Clinic Mbabane (Doctor)","Private Doctor","Private clinic ","Private doctor","Private doctor. Jonathan")
            * new code for pharmacy
            replace hbp8 = 336 if inlist(hbp8x, "Buy from the pharmacy ","Pharmacy ")
            replace hbp8x = "" if hbp8 < 99998 | hbp8 == .d // delete "specifies" for SA, private doctor, and pharmacy
            lab def hbp8 335 "335. Private doctor/clinic" 336 "336. Pharmacy/Chemist", add
            lab val hbp8 hbp8
                        *TODO: Send hbp8x list to CHAI to check if they fit in any of our clinic codes.
            replace hbp8_name = ".s" if hbp8 == .s
            replace hbp8_name = ".c" if hbp8 == .c

        * location of current care seeking for htn
            tab hbp9,m
            tab hbp9x
            *? few people currently take drugs but report to not be in care
            tab hbp3 if hbp9 == 99999,m
            replace hbp9 = 334 if inlist(hbp9x, "South Africa")
            * new code for private doctor
            replace hbp9 = 335 if inlist(hbp9x,"Dr Futhi","Dr Jonathan ","Dr Mathunjwa","Dr Mnisi","Dr Mnisi ","Dr Sacolo ","Dr Smith","Dr T. Thwala")
            replace hbp9 = 335 if inlist(hbp9x,"Dr. Mphandalana","Private Doctor","Private clinic","Private doctor ","Private pharmacy ")
            * new code for pharmacy
            replace hbp9 = 336 if inlist(hbp9x, "At the Pharmacy","Buy  from  pharmacy ","Buy from the pharmacy ","Buy the medication at the Pharmacy ","Buys her medications at a pharmacy ")
            replace hbp9 = 336 if inlist(hbp9x, "Chemist","Chemistry ","I buy them at the pharmacy store","Pharmacy","Pharmacy ","Philani Pharmacy ","Matata pharmacy ","Mlozi Pharmacy","Mlozi Chemist")
            replace hbp9 = 336 if inlist(hbp9x, "Buy the medication at the pharmacy store","But the medication at the pharmacy store ","Goes to buy medication at nearest pharmacy ")
            replace hbp9 = .s if inlist(2, hbp1, hbp2) // never had BP measured or was never diagnosed
            replace hbp9 = .c if inlist(hbp2, .d,.c) // answer to hbp1 or hbp2 was DK
            replace hbp9x = "" if hbp9 < 99998 | hbp9 == .d // delete "specifies" for SA, private doctor, pharmacy, and DK
            lab def hbp9 335 "335. Private doctor/clinic" 336 "336. Pharmacy/Chemist", add
            lab val hbp9 hbp9
                        *TODO: Ask CHAI if "chemist" is pharmacy
                        *TODO: Send hbp9x list to CHAI to check if they fit in any of our clinic codes.
            replace hbp9_name = ".s" if hbp9 == .s
            replace hbp9_name = ".c" if hbp9 == .c

        * reason for seeking care at a different facility than initiation
            tab hbp10,m
            replace hbp10 = ".s" if hbp9 == 99999 // currently not in care
            replace hbp10 = ".s" if inlist(2, hbp1, hbp2) // never had BP measured or was never diagnosed
            replace hbp10 = ".c" if inlist(.d, hbp1, hbp2) // answer to hbp1 or hbp2 was DK
            replace hbp10 = ".s" if hbp8_name==hbp9_name // place of initiation and current treatment are the same
            * Siteki public health unit and Mliba Nazarene Clinic were initially listed twice --> each in one case different

            forv q = 1/9 {
                replace hbp10`q' = .s if hbp10 == ".s" // transfer missings from hbp10
                replace hbp10`q' = .c if hbp10 == ".c" // transfer missings from hbp10
                rename hbp10`q' hbp10_`q' // rename variables for legibility
            } 
            replace hbp1098 = .s if hbp10 == ".s" // transfer missings from hbp10
            replace hbp1098 = .c if hbp10 == ".c" // transfer missings from hbp10
            rename hbp1098 hbp10_98 // rename variables for legibility
            
            br hbp10x if hbp10x != ""

            *New facility is closer to home (1)
                gen h_switch_home = hbp10_1
                lab var h_switch_home "New facility is closer to home (hbp101)" 
                lab val h_switch_home yn01
    
            *New facility is closer to work (2)
                gen h_switch_work = hbp10_2
                lab var h_switch_work "New facility is closer to work (hbp102)" 
                lab val h_switch_work yn01

            *More services offered (3)
            # delimit;
            foreach r in 
                "Not given care"
                "I have other sickness that they care for me at The Luke Commission"
                "I need services not offered in nearby facility (Dialysis) " 
                "It's the same clinic I'm taking ART treatment " { ;
                
                replace hbp10_3 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr
        
            gen h_switch_more = hbp10_3
            lab var h_switch_more "More services are offered (hbp103)" 
            lab val h_switch_more yn01


            *Better quality of care (4)
            # delimit;
            foreach r in 
                "Good staff"
                "Bad treatment by health workers at the clinic"
                "I was abused by a nurse"
                "At Sigangeni clinic they did not accept me because I was beingb cared at a  South African clinic they said their medication is not the same as here at eswatinj so I will have problems. Then I switched to Siphocosini where I was welcomed and I wasn't told that pills will be a problem to me unlike Sigangeni"
                "Medication is delivered "
                "Poor services at clinic" { ;
                
                replace hbp10_4 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_quality = hbp10_4
            lab var h_switch_quality "Better quality of care (hbp103)" 
            lab val h_switch_quality yn01

            *Cheaper services (5)
            gen h_switch_cheap = hbp10_5
            lab var h_switch_cheap "Cheaper services (hbp105)" 
            lab val h_switch_cheap yn01
            
            *The facility was recommended by others (family members, friends, co-workers) (6)
            gen h_switch_recommend = hbp10_6
            lab var h_switch_recommend "New facility was reommended (hbp106)" 
            lab val h_switch_recommend yn01

            *Advertisements in community (7)
            gen h_switch_advert = hbp10_7
            lab var h_switch_advert "Advertisements in community (hbp107)" 
            lab val h_switch_advert yn01
                    
            *I moved to a different community in the meantime (8)
            # delimit;
            foreach r in 
                "Retired and he's back home. He uses the pharmacy "
                "She relocated" { ;
                    
                replace hbp10_8 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_move = hbp10_8
            lab var h_switch_move "Moved to different community (hbp108)" 
            lab val h_switch_move yn01
                    
            *Drugs are more often available at new clinic (9)
            # delimit;
            foreach r in 
                "No medication "
                "Mgazini has no medication for raise blood sugar"
                "No medication at Mgazini clinic"
                "Pills not available at Mhlosheni clinic"
                "no drugs in local clinic "
                "Used to take them at Dvokolwako Health Center but they started saying there is no medication available then I decided to buy them at the pharmacy store"
                "I get all my hypertension and diabetic pills at hlatikhulu public health "
                "Drugs always available at Siteki"
                "No medication for BP at Mgazini Nazarene Clinic"
                "Drug provision is better there"
                "No medication at nearest clinic" { ;
                
                replace hbp10_9 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr
            * this one seemed to have an invisible line break
            *    "The medication was not available in the clinicsSo I started buying them at the pharmacy " 
                replace hbp10_9 = 1 if hhid == "12-11-NK05-12" & name == "DD" // include answer in binary variable
                replace hbp10_98 = 0 if hhid == "12-11-NK05-12" & name == "DD"  // exclude answer from binary "other" variable 
                replace hbp10x = "" if hhid == "12-11-NK05-12" & name == "DD"  // remove text answer from "specify" variable
        
            gen h_switch_drugs = hbp10_9
            lab var h_switch_drugs "Availability of drugs (hbp109)" 
            lab val h_switch_drugs yn01


            * accessibility (incl. money for transport) (new)
            gen hbp10_10 = 0
            lab var hbp10_10 "Accessibility (incl. money for transport) (hbp10x)" 
            # delimit;
            foreach r in 
                "route is easy in terms of public transport "
                "Very accessible because I use tar road going there."
                "Not physically able "
                "Easily accessible "
                "I am now unable to walk to Mkhulamini clinic " 
                "No money for transportation to health facility " 
                "No money for transportation from home to the clinic"
                "I get free transport to Lavumisa clinic than Matsanjeni Hospital" { ;

                replace hbp10_10 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_access = hbp10_10
            lab var h_switch_access "Accessibility (incl. money for transport) (hbp10x)" 
            lab val h_switch_access yn01

            * group was moved to different facility (new)
            gen hbp10_11 = 0 
            lab var hbp10_11 "Group was moved (hbp10x)" 
            # delimit;
            foreach r in 
                "Team was grouped to go to this clinic "
                "Clinic group moved from work place" { ;
                
                replace hbp10_11 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_group = hbp10_11
            lab var h_switch_group "Group was moved (hbp10x)" 
            lab val h_switch_group yn01

            * was referred by other clinic/hospital/physician (new)
            gen hbp10_12 = 0
            lab var hbp10_12 "Referral by health care worker (hbp10x)" 
            # delimit;
            foreach r in 
                "was referred from Maggie Clinic " 
                "was referred by the hospital at the height of covid regulations " 
                "was referred by him"
                "was transferred by initial facility" 
                "was transferred by Pigg's Peak Nazarene" 
                "Was transferred by health care worker" 
                "switched facility after Covid -19 regulations " { ;
                
                replace hbp10_12 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_referral = hbp10_12
            lab var h_switch_referral "Referral by health care worker (hbp10x)" 
            lab val h_switch_referral yn01

            * Did not switch (new)
            gen hbp10_13 = 0
            lab var hbp10_13 "Did not switch (hbp10x)" 
            # delimit;
            foreach r in 
                "Not switching clinic " 
                "No change" 
                "She did not switch the clinic " {;
                replace hbp10_13 = 1 if hbp10x == "`r'" ; // include answer in binary variable
                replace hbp10_98 = 0 if hbp10x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp10x = "" if hbp10x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_switch_noswitch = hbp10_13
            lab var h_switch_noswitch "Did not switch (hbp10x)" 
            lab val h_switch_noswitch yn01

                /*? Could not be categorized
                    No queue
                    Closed
                    Better waiting hours
                    Community Outreach is no longer available
                    Not taking any medication  went there just for check ups
                    Easier to manage
                    Just decided on it
                    most facilities don't take medical aid
                    Not taking medication
                    Decided to buy them
                    My daughter is a nurse and brings them to me monthly from South Africa.
                    Long queue in hospital
                */ 


        * first visit to facility for hypertension care
            tab hbp11ys,m
            * some interviewers entered the year instead of "years since" first visit
            replace hbp11ys = 22 if hbp11ys == 2000
            replace hbp11ys = 4 if hbp11ys == 2018
            replace hbp11ys = 3 if hbp11ys == 2019
            replace hbp11ys = 2 if hbp11ys == 2020
            replace hbp11ys = 1 if hbp11ys == 2021
            
            tab hbp11ms,m
            tab hbp11ws,m
            replace hbp11ws = .d if hbp11ws == 77 // did not know when first visit happened

            * new variable indicating years since first visit
            gen h_careyears = hbp11ys
            replace h_careyears = 0 if inrange(hbp11ms, 0,11) // up to 11 months since first visit
            replace h_careyears = 1 if inrange(hbp11ms, 12,23) // 12-23 months since first visit
            replace h_careyears = 2 if inrange(hbp11ms, 24,35) // 24-35 months since first visit
            replace h_careyears = 0 if hbp11ws < 52 // less than 52 weeks since first visit
        

            * year and month of first visit
            sum hbp11y // 1970 - 2022

            forv yr = `r(min)'(1)`r(max)' { // loop from earliest to latest year of first visit for care
                replace h_careyears = 2022 - `yr' if hbp11y == `yr' & hbp11m <= month // month of first visit was in or before month of interview
                replace h_careyears = 2022 - `yr' - 1 if hbp11y == `yr' & hbp11m > month & hbp11m < . // month of interview was after month of interview 
            }
            replace h_careyears = .s if inlist(2, hbp1,hbp2) // never had BP measured or was never diagnosed
            replace h_careyears = .s if hbp9 == 99999 // currently not in care
            replace h_careyears = .d if hbp11ws == .d // does not know when 1st visit happened
            replace h_careyears = .c if inlist(.d, hbp1,hbp2,hbp3) // answer to hbp1, hbp2, hbp3 was DK
            
            lab var h_careyears "Years since first visit to facility for htn care (hbp11*)"
            tab h_careyears,m


        * first visit was in past 12 months
            gen h_care12 = .
            replace h_care12 = 1 if hbp11y == 2022 // first visit in 2022
            replace h_care12 = 1 if hbp11y == 2021 & hbp11m >= month & hbp11m < . // first visit in 2021, month in or before interview month
            replace h_care12 = 0 if hbp11y == 2021 & hbp11m < month // first visit in 2021, month after interview month
            replace h_care12 = 0 if hbp11y < 2021 // first visit before 2021
            replace h_care12 = 1 if hbp11ys == 1 // one year since first visit
            replace h_care12 = 0 if hbp11ys > 1 & hbp11ys < . // more than one year since first visit
            replace h_care12 = 1 if hbp11ms < 12 | hbp11ws < 52 // less than 11 months or 52 weeks since first visit
            replace h_care12 = h_careyears if h_careyears >= . // transfer missings
            tab h_care12,m
            tab h_care12 h_told12,m
                        *? what do we do with cases that indicated that they were diagnosed in past 12 months but the date of first visit is longer ago?
            lab var h_care12 "First visit to facility for htn care was in past 12 months (hbp11*)"
            lab val h_care12 yn01

        * advice variables
            foreach v of varlist hbp12* { // list of all advice variables (hbp12)
                tab `v',m
                replace `v' = .s if inlist(2, hbp1,hbp2) // never had BP measured or was never diagnosed
                replace `v' = .s if hbp9 == 99999 // is currently not in care
                replace `v' = .d if `v' == 77 // DK in respective advice variable
                replace `v' = .c if inlist(.d, hbp1,hbp2) // answer to hbp1 or hbp2 was DK
            }

            *Quit using tobacco or don’t start (a)
                gen h_advtob = (hbp12a==1) if hbp12a < .
                replace h_advtob = hbp12a if hbp12a >= .
                lab var h_advtob "Advised to quit tobacco or don't start (hbp12a)"
                lab val h_advtob yn01
            *Reduce salt in your diet (b)
                gen h_advsalt = (hbp12b==1) if hbp12b < .
                replace h_advsalt = hbp12b if hbp12b >= .
                lab var h_advsalt "Advised to reduce salt in diet (hbp12b)"
                lab val h_advsalt yn01
            *Reduce fat in your diet (c)
                gen h_advfat = (hbp12c==1) if hbp12c < .
                replace h_advfat = hbp12c if hbp12c >= .
                lab var h_advfat "Advised to reduce fat in diet (hbp12c)"
                lab val h_advfat yn01
            *Start or do more physical activity (d)
                gen h_advpa = (hbp12d==1) if hbp12d < .
                replace h_advpa = hbp12d if hbp12d >= .
                lab var h_advpa "Advised to start/do more physical activity (hbp12d)"
                lab val h_advpa yn01
            *Maintain a healthy body weight or lose weight (e)
                gen h_advweight = (hbp12e==1) if hbp12e < .
                replace h_advweight = hbp12e if hbp12e >= .
                lab var h_advweight "Advised to maintain healthy/lose weight (hbp12e)"
                lab val h_advweight yn01
            *Reduce sugary beverages in your diet (f)
                gen h_advsug = (hbp12f==1) if hbp12f < .
                replace h_advsug = hbp12f if hbp12f >= .
                lab var h_advsug "Advised to reduce sugary beverages in diet (hbp12f)"
                lab val h_advsug yn01

        drop hbp11_When_did_you_ressure_hyper The_date_you_entered_uture_Pleas If_you_enter_a_year_eed_to_enter hbp12_Are_you_curre_other_health hbp12
       
        * reason for missing follow-up visits (among those currently in care)
            tab hbp13,m
            tab hbp9 if hbp13 == "",m 
            replace hbp13 = ".s" if hbp9 == 99999 // currently not in care
            replace hbp13 = ".s" if inlist(2, hbp1, hbp2) // never had BP measured or was never diagnosed
            replace hbp13 = ".c" if inlist(.d, hbp1,hbp2) // answer to hbp1 or hbp2 was DK

            forv q = 1/15 {
                replace hbp13`q' = .s if hbp13 == ".s" // transfer missings from hbp13
                replace hbp13`q' = .c if hbp13 == ".c" // transfer missings from hbp13
                rename hbp13`q' hbp13_`q'
            } 

            replace hbp1398 = .s if hbp13 == ".s" // transfer missings from hbp13
            replace hbp1398 = .c if hbp13 == ".c" // transfer missings from hbp13
            rename hbp1398 hbp13_98
            
            tab hbp13x,m

            *Need to work (1)
            gen h_miss_work = hbp13_1
            lab var h_miss_work "Had to work (hbp131)" 
            lab val h_miss_work yn01

            *Needed to take care of family members (2)
            gen h_miss_care = hbp13_2
            lab var h_miss_care "Care for family members (hbp132)" 
            lab val h_miss_care yn01

            *Too far away from home (3)
            gen h_miss_home = hbp13_2
            lab var h_miss_home "Too far away from home (hbp133)" 
            lab val h_miss_home yn01

            *No money to pay for transport (4)
                * This one is already indicated in hbp13_4 and the same obs is needed below as it contains 2 pieces of info. ;
                *"Asthma and hypertension pills need me to have more food of which I don't have enough so I skip sometimes getting my pills. I also don't have transport money even though I do get free transport sometimes." ;
            # delimit;
            foreach r in 
                "No money to pay transport to the clinic" {;
                
                replace hbp13_4 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_trans = hbp13_4
            lab var h_miss_trans "No money for transport (hbp134)" 
            lab val h_miss_trans yn01

            *No money to pay for health care services (5)
            # delimit;
            foreach r in 
                "Didn't have money to buy medication over the counter " {;
                
                replace hbp13_5 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_payserv = hbp13_5
            lab var h_miss_payserv "No money for transport (hbp135)" 
            lab val h_miss_payserv yn01
                
            *Waiting times are too long (6)
            gen h_miss_wait = hbp13_6
            lab var h_miss_wait "Waiting times are too long (hbp136)" 
            lab val h_miss_wait yn01

           *Low quality of services (7)
            gen h_miss_quality = hbp13_7
            lab var h_miss_quality "Low quality of services (hbp137)" 
            lab val h_miss_quality yn01

            *Bad treatment by health care workers (8)
            gen h_miss_bad = hbp13_8
            lab var h_miss_bad "Bad treatment by health care workers (hbp138)" 
            lab val h_miss_bad yn01

            *Feeling uncomfortable during consultation (9)
            gen h_miss_uncom = hbp13_9
            lab var h_miss_uncom "Feeling uncomfortable during consultation (hbp139)" 
            lab val h_miss_uncom yn01

            *No need to go because I felt good (10)
            # delimit;
            foreach r in 
                "Not taking medication  for now because sometime its drop" {;
                
                replace hbp13_10 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_feel = hbp13_10
            lab var h_miss_feel "No need to go because I felt good (hbp1310)" 
            lab val h_miss_feel yn01

            *I forgot about the appointment (11)
            # delimit;
            foreach r in 
                "Sometimes I forget " {;
                
                replace hbp13_11 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_forgot = hbp13_11
            lab var h_miss_forgot "I forgot about the appointment (hbp1311)" 
            lab val h_miss_forgot yn01

            *The consultation did not help me to feel better (12)
            # delimit;
            foreach r in 
                "Medication makes me feel worse"
                "Medication made her feel worse she almost died, she decided to stop Medication " {;
                
                replace hbp13_12 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_nothelp = hbp13_12
            lab var h_miss_nothelp "The consultation did not help me to feel better (hbp1312)" 
            lab val h_miss_nothelp yn01

            *I went to a traditional healer instead (13)
            gen h_miss_healer = hbp13_13
            lab var h_miss_healer "I went to a traditional healer instead (hbp1313)" 
            lab val h_miss_healer yn01

            *There are no drugs available at the facility (14)
            # delimit;
            foreach r in 
                "There were no drugs at the clinic at Mgazini Clinic" {;
                
                replace hbp13_14 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_nodrugs = hbp13_14
            lab var h_miss_nodrugs "There are no drugs available at the facility (hbp1314)" 
            lab val h_miss_nodrugs yn01
                
            *Did not miss a follow-up visit (15)
            gen h_miss_nomiss = hbp13_15
            lab var h_miss_nomiss "Did not miss a follow-up visit (hbp1315)" 
            lab val h_miss_nomiss yn01

            * accessibility (new) - *?maybe put together with  "too far away from home"
            gen hbp13_16 = 0
            lab var hbp13_16 "Accessibility (hbp13x)" 
            # delimit;
            foreach r in 
                "sometimes no transport due to slippery roads as we live in a remote area"
                "weather elements "
                "Bad roads on rainy days"
                "Transport scarcity" {;
                
                replace hbp13_16 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_access = hbp13_16
            lab var h_miss_access "Accessibility (hbp13x)" 
            lab val h_miss_access yn01
               

            * phyiscally unable / constrained physical mobility (new)
            gen hbp13_17 = 0
            lab var hbp13_17 "Phyiscally unable / constrained physical mobility (hbp13x)" 
            # delimit;
            foreach r in 
                "Unable to walk"
                "Unable to walk "
                "Challenges with transport, she cannot travel on her own. "
                "No longer able to reach bus station due to mobility issues"
                "Swollen feet can't walk at times"
                "Physically unable"
                "Wasn't feeling well (Sick)"
                "Not easily accessible because of mobility issues"
                "Can't walk properly sometimes "
                "Not physically able "
                "It's hard to walk all myself."
                "Can not walk anymore"
                "I am visually impaired, making it difficult to visit health facility"
                "Noone to take me to the clinic as I am too old and need assistance with moving around" {;
                
                replace hbp13_17 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_unable = hbp13_17
            lab var h_miss_unable "Phyiscally unable / constrained physical mobility (hbp13x)" 
            lab val h_miss_unable yn01

            * stopped taking medication (new)
            gen hbp13_18 = 0
            lab var hbp13_18 "Stopped taking medication (hbp13x)" 
            # delimit;
            foreach r in 
                "Asthma and hypertension pills need me to have more food of which I don't have enough so I skip sometimes getting my pills. I also don't have transport money even though I do get free transport sometimes."
                "Not taking medication  for now"
                "It never went down well with me that i will drink pills for the rest of my life"
                "It was a once off thing due to certain circumstances she's currently not on treatment."
                "Not on treatment "
                "It was induced hypertension "
                "They stopped his treatment at the health facility, told him he is fine now"
                "She was at psych hospital, then she stopped taking BP medication " {;
                
                replace hbp13_18 = 1 if hbp13x == "`r'" ; // include answer in binary variable
                replace hbp13_98 = 0 if hbp13x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp13x = "" if hbp13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_miss_stopmed = hbp13_18
            lab var h_miss_stopmed "Stopped taking medication (hbp13x)" 
            lab val h_miss_stopmed yn01

                                * TODO Ask CHAI to translate: Angisakhoni kuhamba libanga lelidze

                /*? Could not be categorized
                    Relative took my prescription card, so I haven't been able to go make another one
                    I lost my health card and feared going back without it
                    Financial problem
                    Healthcare workers stopped me
                    She had plenty of the treatment thud not seeing the need of going to the clinic.
                    No
                    Hiv Community outreach
                    Keep postponing
                    Never went back for follow since the date of My initiation
                    Medication still available
                */


        * reason for stop going to follow up visits (among those currently not in care)
            tab hbp14,m
            tab hbp9 if hbp14 != "",m 
            replace hbp14 = ".s" if hbp9 < 99999 // only asked to those who are currently not in care
            replace hbp14 = ".s" if inlist(2, hbp1, hbp2) // never had BP measured or was never diagnosed
            replace hbp14 = ".c" if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2, hbp3 was DK
            replace hbp14 = ".r" if inlist(hbp14x, "Refused ","Refusal ")

            forv q = 1/15 {
                replace hbp14`q' = .s if hbp14 == ".s" // transfer missings from hbp14
                replace hbp14`q' = .c if hbp14 == ".c" // transfer missings from hbp13
                replace hbp14`q' = .r if hbp14 == ".r" // transfer missings from hbp13

                rename hbp14`q' hbp14_`q' // transfer missings from hbp14
            } 

            replace hbp1498 = .s if hbp14 == ".s" // transfer missings from hbp14
            replace hbp1498 = .c if hbp14 == ".c" // transfer missings from hbp14
            replace hbp1498 = .r if hbp14 == ".r" // transfer missings from hbp14
            replace hbp14x = "" if hbp14 == ".r"
            
            rename hbp1498 hbp14_98

            tab hbp14x,m
            *Need to work (1)
            gen h_stop_work = hbp14_1
            lab var h_stop_work "Had to work (hbp141)" 
            lab val h_stop_work yn01

            *Needed to take care of family members (2)
            gen h_stop_care = hbp14_2
            lab var h_stop_care "Care for family members (hbp142)" 
            lab val h_stop_care yn01

            *Too far away from home (3)
            # delimit;
            foreach r in 
               "Facility far from home"
               "Facility away from home"
               "Difficulties to reach the clinic" {;
                
                replace hbp14_3 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_home = hbp14_3
            lab var h_stop_home "Too far away from home (hbp143)" 
            lab val h_stop_home yn01

            *No money to pay for transport (4)
            gen h_stop_trans = hbp14_4
            lab var h_stop_trans "No money for transport (hbp144)" 
            lab val h_stop_trans yn01

            *No money to pay for health care services (5)
            gen h_stop_payserv = hbp14_5
            lab var h_stop_payserv "No money for transport (hbp145)" 
            lab val h_stop_payserv yn01

            *Waiting times are too long (6)
            gen h_stop_wait = hbp14_6
            lab var h_stop_wait "Waiting times are too long (hbp146)" 
            lab val h_stop_wait yn01

           *Low quality of services (7)
            gen h_stop_quality = hbp14_7
            lab var h_stop_quality "Low quality of services (hbp147)" 
            lab val h_stop_quality yn01

            *Bad treatment by health care workers (8)
            gen h_stop_bad = hbp14_8
            lab var h_stop_bad "Bad treatment by health care workers (hbp148)" 
            lab val h_stop_bad yn01

            *Feeling uncomfortable during consultation (9)
            gen h_stop_uncom = hbp14_9
            lab var h_stop_uncom "Feeling uncomfortable during consultation (hbp149)" 
            lab val h_stop_uncom yn01

            *No need to go because I felt good (10)
            # delimit;
            foreach r in 
                "Felt better"
                "I was feeling better "
                "Improvement in health"
                "Improvement in health " {;
                
                replace hbp14_10 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_feel = hbp14_10
            lab var h_stop_feel "No need to go because I felt good (hbp1410)" 
            lab val h_stop_feel yn01
           
            *I forgot about the appointment (11)
            gen h_stop_forgot = hbp14_11
            lab var h_stop_forgot "I forgot about the appointment (hbp1411)" 
            lab val h_stop_forgot yn01
            *The consultation did not help me to feel better (12)
            # delimit;
            foreach r in 
                "The drugs made me sick "
                "Feeling like vomiting when taking them."
                "The medication made me feel sick so I decided to stop taking it "
                "Believes medication was affecting eyes"
                "After a few months on my tabs I started vomiting and discontinued " 
                "Medication had severe side effects" 
                "Drug side effects " 
                "Adverse side effects " 
                "She felt more sick and dizzy after taking medication"
                "I felt more sick after taking medication "
                "health concerns "
                "The health workers advised me to stop because I felt sick"
                "The drugs made her sick"
                "The medication made me sick "
                {;
                
                replace hbp14_12 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_nothelp = hbp14_12
            lab var h_stop_nothelp "The consultation did not help me to feel better (incl. side effects) (hbp1412)" 
            lab val h_stop_nothelp yn01
                

            *I went to a traditional healer instead (13)
            # delimit;
            foreach r in 
                "I am a traditional doctor so I usually make concoctions for whatever sickness I have." {;
                
                replace hbp14_13 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_healer = hbp14_13
            lab var h_stop_healer "I went to a traditional healer instead (hbp143)" 
            lab val h_stop_healer yn01

            *There are no drugs available at the facility (14)
            # delimit;
            foreach r in 
                "I will start taking pills and then at some point our government will not restock them at the clinic then I will have to buy from the pharmacy of which I don't have money for those drugs" {;
                
                replace hbp14_14 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_nodrugs = hbp14_14
            lab var h_stop_nodrugs "There are no drugs available at the facility (hbp1414)" 
            lab val h_stop_nodrugs yn01
                
            *My blood pressure went back to normal (15)
            # delimit;
            foreach r in 
                "BP subsided after taking natural vegetables like inkakha"
                "Thought it was triggered by a situation that later subsided "
                "The doctor told me that I am now fine"
                "Was told by Healthcare workers to stop as I was okay"
                "Doctor said blood pressure was normal, no need to take medication "
                "I was advised by the Health worker because my blood pressure was normal,"
                "She started eating healthy and would use the local pharmacy to check her BP, in most cases it would be within normal range."
                "Her blood pressure was back to normal in a week "
                "I was stressed. It  now normal "
                "The health worker said I was doing ok"
                "BP was normal after follow-up "
                "It went back to normal on second visit "
                "Blood pressure went back to normal "
                "The doctor advised to stop for a while given that the blood pressure was too low"
                "I drank special coffee beans and my BP went back to normal thus stopping pills"
                "Nurses told me to drop medication because my BP went back to normal" {;
                
                replace hbp14_15 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_normal = hbp14_15
            lab var h_stop_normal "BP went back to normal (hbp1415)" 
            lab val h_stop_normal yn01
                
            * stopped taking the medication (new)
            gen hbp14_16 = 0
            lab var hbp14_16 "stopped taking the medication (hbp14x)"
            # delimit;
            foreach r in 
                "Not on medication "
                "Not on treatment "
                "Not on medication"
                "Doctor ordered to stop medication "
                "Nurse ordered to stop medication "
                "Discontinued by medical professionals "
                "They stopped giving her medication "
                "Told by a doctor to stop " 
                "Doctor ordered to stop medication" {;
                
                replace hbp14_16 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_stopmed = hbp14_16
            lab var h_stop_stopmed "stopped taking the medication (hbp14x)" 
            lab val h_stop_stopmed yn01
                
            * was not initiated/not told to come back (new)
            gen hbp14_17 = 0
            lab var hbp14_17 "Was not initiated/not told to come back (hbp14x)"
            # delimit;
            foreach r in 
                "Health personnel did not give medication, educated on dietary changes"
                "Given a stat dose and not initiated on long term medication "
                "Had never been told of follow up"
                "Did not initiated on treatment "
                "No one ordered me to come for treatment again"
                "No treatment given"
                "Health professional did not give medication again "
                "Was not initiated on BP medication "
                "Treatment given once"
                "Healthcare workers are still monitoring the blood pressure levels"
                "Never been initiated treatment"
                "Still goes for screening but not initiated on treatment "
                "never been told of any follow-up "
                "not in care"
                "Not in care"
                "not in care "
                "was not told if I needed to come back"
                "Treatment was not offered "
                "I was not told to continue with the treatment after being discharged for COVID19"
                "Not in care. Never had a reason to seek care. I am still well. "
                "Not in the care" 
                "Treatment was not given " 
                "Not initiated on treatment " 
                "Treatment was not initiated " 
                "Not in care " 
                "Never in care" 
                "Never being in care" 
                "Not care" {;
                
                replace hbp14_17 = 1 if hbp14x == "`r'" ; // include answer in binary variable
                replace hbp14_98 = 0 if hbp14x == "`r'" ; // exclude answer from binary "other" variable 
                replace hbp14x = "" if hbp14x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen h_stop_notinit = hbp14_17
            lab var h_stop_notinit "Was not initiated/not told to come back (hbp14x)" 
            lab val h_stop_notinit yn01

            /*? could not be categorized
                No queue
                Closed
                Better waiting hours
                Community Outreach is no longer available
                Not taking any medication  went there just for check ups
                Easier to manage
                Just decided on it
                most facilities don't take medical aid
                Not taking medication
                Decided to buy them
                My daughter is a nurse and brings them to me monthly from South Africa.
                Long queue in hospital
            */

                
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx HYPERTENSION - DSD MODELS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    

    ** Facility-based treatment club
        * one obs indicated that they did not meet yet
        replace hftc1 = 2 if hftc7x == "Haven't yet met. Still to meet."
        replace hftc7x = "" if hftc7x == "Haven't yet met. Still to meet."

        * attended FTC meeting in past 12 months
            tab hftc1,m
            replace hftc1 = .r if hftc1 == 88 // answer to hftc1 was refused
            replace hftc1 = .d if hftc1 == 77 // answer to hftc1 was DK
            replace hftc1 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hftc1 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
        * new FTC meeting in past 12 months variable
            gen h_ftc12 = (hftc1==1) if hftc1 < . // recode 2 to 0
            replace h_ftc12 = hftc1 if hftc1 >= . // transfer missing values
            replace h_ftc12 = 0 if inlist(h_ftc12, .d, .r) // DK and refused are recoded to "No"
            replace h_ftc12 = .s if inlist(h_ftc12, .c, .q) // answer to hbp1, hbp2 was DK --> DSD not relevant
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var h_ftc12 "Went to FTC meeting in past 12 months (hftc1)"
            lab val h_ftc12 yn01
            tab hftc1 h_ftc12,m

        * times attended meeting
            tab hftc3,m
            replace hftc3 = .d if hftc3 == 77 // answer to hftc3 was DK
            replace hftc3 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hftc3 = .s if hftc1 == 2 // did not go to FTC meeting
            replace hftc3 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hftc3 = .c if hftc1 == .d // answer to hftc1 was DK      
            replace hftc3 = .q if hftc1 == .r
        * new number of FTC meetings attended variable
            gen h_ftcatt = hftc3
            lab var h_ftcatt "Number of FTC meetings attended in past 12 months (hftc3)"

        * reasons for missing group meetings
            tab hftc7,m
            replace hftc7 = ".s" if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hftc7 = ".s" if hftc1 == 2 // did not go to FTC meeting
            replace hftc7 = ".s" if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hftc7 = ".c" if hftc1 == .d // answer to hftc1 was DK
            replace hftc7 = ".q" if hftc1 == .r // answer to hftc1 was refused

            forv q = 1/8 {
                replace hftc7`q' = .s if hftc7 == ".s"
                replace hftc7`q' = .q if hftc7 == ".q"
                replace hftc7`q' = .c if hftc7 == ".c"
                rename hftc7`q' hftc7_`q'
            } 
            replace hftc798 = .s if hftc7 == ".s"
            replace hftc798 = .q if hftc7 == ".q"
            replace hftc798 = .c if hftc7 == ".c"
            rename hftc798 hftc7_98
            
            tab hftc7x,m

        *I did not have time (1)
        gen h_ftc_miss_time = hftc7_1 
        lab var h_ftc_miss_time "I did not have time (hftc71)"
        *I could not afford transport (2)
        gen h_ftc_miss_transport = hftc7_2
        lab var h_ftc_miss_transport "I could not afford transport (hftc72)"
        *I still had medication (3)
        gen h_ftc_miss_hadmed = hftc7_3
        lab var h_ftc_miss_hadmed "I still had medication (hftc73)"
        *I did not want to go (4)
        gen h_ftc_miss_notwant = hftc7_4
        lab var h_ftc_miss_notwant "I did not want to go (hftc74)"
        *I forgot (5)
        gen h_ftc_miss_forget = hftc7_5
        lab var h_ftc_miss_forget "I forgot (hftc75)"
        *I did not know about the meetings (6)
        gen h_ftc_miss_notknow = hftc7_6
        lab var h_ftc_miss_notknow "I did not know about the meetings (hftc76)"
        *I knew no medication was available (7)
        gen h_ftc_miss_nomed = hftc7_7
        lab var h_ftc_miss_nomed "I knew no medication was available (hftc77)"
        *Did not miss a meeting (8)
        gen h_ftc_miss_nomiss = hftc7_8
        lab var h_ftc_miss_nomiss "Did not miss a meeting (hftc78)"

            /*? could not be categorized
                Came late
                She is sick
                Came late
                They said I am closer to the hospital so I need to come myself. Service was created for those far away from the hospital
            */

        * label variables
        foreach v of varlist h_ftc_miss_* {
           lab val `v' yn01
        }

    ** Community Advisory Group
        * went to CAG meeting in past 12 months
            tab hcag1,m
            replace hcag1 = .d if hcag1 == 77 // answer to hcag1 was DK
            replace hcag1 = .r if hcag1 == 88 // answer to hcag1 was refused
            replace hcag1 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hcag1 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant

        * new CAG meeting in past 12 months variable
            gen h_cag12 = (hcag1==1) if hcag1 < . // recode 2 to 0
            replace h_cag12 = hcag1 if hcag1 >= . // transfer missing values
            replace h_cag12 = 0 if inlist(h_cag12, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var h_cag12 "Went to CAG meeting in past 12 months (hcag1)"
            lab val h_cag12 yn01
            tab hcag1 h_cag12,m

        * number of CAG meetings
            tab hcag3,m
            replace hcag3 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hcag3 = .s if hcag1 ==  2 // did not attend group meeting
            replace hcag3 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hcag3 = .d if hcag3 == 77
            replace hcag3 = .c if hcag1 == .d
            replace hcag3 = .q if hcag1 == .r
        * new number of CAG meetings attended variable
            gen h_cagatt = hcag3
            lab var h_cagatt "Number of CAG meetings attended in past 12 months (hcag3)"

        * reasons for missing CAG meetings
            tab hcag11,m
            tostring hcag11, replace
            replace hcag11 = ".s" if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hcag11 = ".s" if hcag1 == 2 // did not go to FTC meeting
            replace hcag11 = ".s" if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hcag11 = ".c" if hcag1 == .d // answer to hcag1 was DK
            replace hcag11 = ".q" if hcag1 == .r // answer to hcag1 was refused
            forv q = 1/8 {
                replace hcag11`q' = .s if hcag11 == ".s"
                replace hcag11`q' = .q if hcag11 == ".q"
                replace hcag11`q' = .c if hcag11 == ".c"
                rename hcag11`q' hcag11_`q'
            } 
            replace hcag1198 = .s if hcag11 == ".s"
            replace hcag1198 = .q if hcag11 == ".q"
            replace hcag1198 = .c if hcag11 == ".c"
            rename hcag1198 hcag11_98
            
            tab hcag11x,m

        *I did not have time (1)
        gen h_cag_miss_time = hcag11_1 
        lab var h_cag_miss_time "I did not have time (hcag111)"
        *I could not afford transport (2)
        gen h_cag_miss_transport = hcag11_2
        lab var h_cag_miss_transport "I could not afford transport (hcag112)"
        *I still had medication (3)
        gen h_cag_miss_hadmed = hcag11_3
        lab var h_cag_miss_hadmed "I still had medication (hcag113)"
        *I did not want to go (4)
        gen h_cag_miss_notwant = hcag11_4
        lab var h_cag_miss_notwant "I did not want to go (hcag114)"
        *I forgot (5)
        gen h_cag_miss_forget = hcag11_5
        lab var h_cag_miss_forget "I forgot (hcag115)"
        *I did not know about the meetings (6)
        gen h_cag_miss_notknow = hcag11_6
        lab var h_cag_miss_notknow "I did not know about the meetings (hcag116)"
        *I knew no medication was available (7)
        gen h_cag_miss_nomed = hcag11_7
        lab var h_cag_miss_nomed "I knew no medication was available (hcag117)"
        *Did not miss a meeting (8)
        gen h_cag_miss_nomiss = hcag11_8
        lab var h_cag_miss_nomiss "Did not miss a meeting (hcag118)"

            /*? could not be categorized
                Meeting was stopped for us because we are closer to the hospital            
            */
        * label variables
        foreach v of varlist h_cag_miss_* {
           lab val `v' yn01
        }

    ** Fast-track model
        * used fast-track model in past 12 months
            tab hft1,m
            replace hft1 = .r if hft1 == 88 // answer to hft1 was refused
            replace hft1 = .d if hft1 == 77 // answer to hft1 was DK
            replace hft1 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hft1 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hft1 = 2 if hft3 == 0 // used FT model 0 times in past 12 months
        * new fast track used in past 12 months variable
            gen h_ft12 = (hft1==1) if hft1 < . // recode 2 to 0
            replace h_ft12 = hft1 if hft1 >= . // transfer missing values
            replace h_ft12 = 0 if inlist(h_ft12, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var h_ft12 "Used fast-track in past 12 months (hft1)"
            lab val h_ft12 yn01
            tab hft1 h_ft12,m

        * number of times fast-track model used
            tab hft3,m
            replace hft3 = .s if inlist(2, hbp1,hbp2) // never measured nor diagnosed
            replace hft3 = .s if hft1 == 2 // did not participate in fast-track
            replace hft3 = .s if inlist(.d, hbp1,hbp2) // answer to hbp1, hbp2 was DK --> DSD not relevant
            replace hft3 = .d if hft3 == 77 // answer to hft3 was DK
            replace hft3 = .c if hft1 == .d // answer to hft1 was DK
            replace hft3 = .q if hft1 == .r // answer to hft1 was refused
        * new number of CAG meetings attended variable
            gen h_ftatt = hft3
            lab var h_ftatt "Number of times fast track was used in past 12 months (hft3)"

    ** Community distribution points
        * went to CDP for BP care in past 12 months
            tab hcdp1,m
            replace hcdp1 = .d if hcdp1 == 77 // answer to hcdp1 was DK
            replace hcdp1 = .r if hcdp1 == 88 // answer to hcdp1 was refused
            replace hcdp1 = .s if hbp1 == 2 // BP was never measured
            replace hcdp1 = .s if hbp1 == .d // answer to hbp1 was DK
        * new visited CDP in past 12 months variable
            gen h_cdp12 = (hcdp1==1) if hcdp1 < .
            replace h_cdp12 = hcdp1 if hcdp1 >= . // transfer missing values
            replace h_cdp12 = 0 if inlist(h_cdp12, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the CDPs are only relevant
            * to those who ever had BP measured. We also include .c and .q as .s
            lab var h_cdp12 "Attended CDP in past 12 months (hcdp1)"
            lab val h_cdp12 yn01
            tab hcdp1 h_cdp12,m

        * BP measured at CDP
            tab hcdp3,m
            replace hcdp3 = .s if hbp1 == 2 // never measured
            replace hcdp3 = .s if hcdp1 == 2 // did not participate in CDP
            replace hcdp3 = .d if hcdp3 == 77
            replace hcdp3 = .r if hcdp3 == 88
            replace hcdp3 = .c if inlist(.d, hcdp1,hbp1) // answer to hcdp1 or hbbp1 was DK
            replace hcdp3 = .q if hcdp1 == .r // answer to hcdp1 was refused
        * new measured BP at CDP variable
            gen h_cdpms = (hcdp3==1) if hcdp3 < .
            replace h_cdpms = hcdp3 if hcdp3 >= . // transfer missing values
            replace h_cdpms = 0 if inlist(h_cdpms, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the CDPs are only relevant
            * to those who ever had BP measured. We also include .c and .q as .s
            lab var h_cdpms "Attended CDP in past 12 months (hcdp3)"
            lab val h_cdpms yn01
            tab hcdp3 h_cdpms,m

        * referrals received at CDP
            tab hcdp4, m
            replace hcdp4 = .s if hbp1 == 2 // never measured
            replace hcdp4 = .s if hcdp1 == 2 // did not participate in CDP
            replace hcdp4 = .c if inlist(.d, hcdp1,hbp1) // answer to hcdp1 or hbbp1 was DK
            replace hcdp4 = .q if hcdp1 == .r // answer to hcdp1 was refused
            foreach q in 1 2 3 77 99 {
                replace hcdp4`q' = hcdp4 if inlist(hcdp4, .s,.c,.q)
                rename hcdp4`q' hcdp4_`q'
            } 
        * new referral variables 
            gen h_cdprefchk = hcdp4_1 // referred for treatment
            lab var h_cdprefchk "Was referred for check-up (hcdp4_1)"
            lab val h_cdprefchk yn01
            gen h_cdpreftrt = hcdp4_2 // referred for treatment
            lab var h_cdpreftrt "Was referred for treatment initiation (hcdp4_2)"
            lab val h_cdpreftrt yn01
            gen h_cdprefno = hcdp4_3 // referred for treatment
            lab var h_cdprefno "Was not referred (hcdp4_3)"
            lab val h_cdprefno yn01

        * number of times collecting medication from CDP
            tab hcdp6,m
            replace hcdp6 = .s if hbp1 == 2 // never measured
            replace hcdp6 = .s if hcdp1 == 2 // did not participate in CDP
            replace hcdp6 = .d if hcdp6 == 77
            replace hcdp6 = .c if inlist(.d, hcdp1,hbp1) // answer to hcdp1 or hbbp1 was DK
            replace hcdp6 = .q if hcdp1 == .r // answer to hcdp1 was refused
        * new CDP treatment collection variable
            gen h_cdpdrug = hcdp6
            lab var h_cdpdrug "Number of times collected BP med from CDP (hcdp6)"

    
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx HYPERTENSION - MEDICATION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * missing a dose in past 2 weeks
        tab chm1,m
        replace chm1 = .r if chm1 == 88 // answer to chm1 was DK
        replace chm1 = .d if chm1 == 77 // answer to chm1 was refused
        replace chm1 = .s if inlist(2, hbp1,hbp2,hbp3) // never measured BP and never diagnosed 
        replace chm1 = .c if inlist(.d, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was DK
        replace chm1 = .q if inlist(.r, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was refused
    * new missed dose variable
        gen h_adh2 = (chm1==1) if chm1 < . // recode 2 to 0
        replace h_adh2 = chm1 if chm1 >= . // transfer missing values
        replace h_adh2 = .s if inlist(h_adh2, .c,.q) // Skipped if DK or Ref in previous question
        lab var h_adh2 "Missed dose in past 2 weeks (chm1)"
        lab val h_adh2 yn01
        tab chm1 h_adh2,m

    * reason for missing a dose
        tab chm2,m
        replace chm2 = ".s" if inlist(2, chm1,hbp1,hbp2,hbp3) // never BP measured, diagnosed, no current drug, or never missed dose
        replace chm2 = ".c" if inlist(.d, chm1,hbp1,hbp2,hbp3) // answer to chm1, hbp1, hbp2 or hbp3 was DK
        replace chm2 = ".q" if inlist(.r, chm1,hbp1,hbp2,hbp3) // answer to chm1, hbp1, hbp2 or hbp3 was refused

        forv q = 1/9 {
            replace chm2`q' = .s if chm2 == ".s"
            replace chm2`q' = .c if chm2 == ".c"
            replace chm2`q' = .q if chm2 == ".q"
            rename chm2`q' chm2_`q'
        } 
        replace chm298 = .s if chm2 == ".s"
        replace chm298 = .c if chm2 == ".c"
        replace chm298 = .q if chm2 == ".q"
        rename chm298 chm2_98

        tab chm2x,m

    *Drugs were not available at all (1)
        gen h_adh_avail = chm2_1
        lab var h_adh_avail "Drugs were not available at all (chm21)" 
        lab val h_adh_avail yn01
    *Drugs were available but not for free (2)
        gen h_adh_availfr = chm2_2
        lab var h_adh_availfr "Drugs were available but not for free (chm22)" 
        lab val h_adh_availfr yn01

    *It is hard to remember all the doses / I forget taking them. (3)
        # delimit;
        foreach r in 
            "I sometimes forget "
            "Forgot "
            "Forget "
            "Forgets taking medication"
            "Forgot"
            "I forgot "
            "Forgetness sometimes"
            "Forgot to buy the pills "
            "I went away and forgot to take them with me "
            "Forgetful sometimes"
            "He forgot " { ;
            
            replace chm2_3 = 1 if chm2x == "`r'" ; // include answer in binary variable
            replace chm2_98 = 0 if chm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace chm2x = "" if chm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen h_adh_forgot = chm2_3
        lab var h_adh_forgot "It is hard to remember all the doses / I forget taking them (chm23)" 
        lab val h_adh_forgot yn01

    *It is hard to pay for this drug (4)
        # delimit;
        foreach r in 
            "No money for buying medication at pharmacy after prescription "
            "No money" { ;
            
            replace chm2_4 = 1 if chm2x == "`r'" ; // include answer in binary variable
            replace chm2_98 = 0 if chm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace chm2x = "" if chm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen h_adh_pay = chm2_4
        lab var h_adh_pay "It is hard to pay for this drug (chm24)" 
        lab val h_adh_pay yn01

    *It is hard to get my refill on time (5)
        gen h_adh_refill = chm2_5
        lab var h_adh_refill "It is hard to get my refill on time (chm25)" 
        lab val h_adh_refill yn01

    *I still get unwanted side effects from this drug (6)
        # delimit;
        foreach r in 
            "I get too much gas in my stomach " { ;
            
            replace chm2_6 = 1 if chm2x == "`r'" ; // include answer in binary variable
            replace chm2_98 = 0 if chm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace chm2x = "" if chm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen h_adh_side = chm2_6
        lab var h_adh_side "I still get unwanted side effects from this drug (chm26)" 
        lab val h_adh_side yn01
        
    *I worry about the long term effects of this drug (7)
        gen h_adh_long = chm2_7
        lab var h_adh_long "I worry about the long term effects of this drug (chm27)" 
        lab val h_adh_long yn01

    *This drug causes other concerns or problems (8)
        gen h_adh_othprob = chm2_8
        lab var h_adh_othprob "This drug causes other concerns or problems (chm28)" 
        lab val h_adh_othprob yn01

    *I don't feel sick or I don't think I need a drug (9)
        # delimit;
        foreach r in 
            "I felt strong and fit, so I did not find a need to take medication. " { ;
            
            replace chm2_9 = 1 if chm2x == "`r'" ; // include answer in binary variable
            replace chm2_98 = 0 if chm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace chm2x = "" if chm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen h_adh_fine = chm2_9
        lab var h_adh_fine "I don't feel sick or I don't think I need a drug (chm29)" 
        lab val h_adh_fine yn01
        

    * Mobility/Access (Infrastructure and physical constraints) (new)
        gen chm2_10 = 0
        # delimit;
        foreach r in 
            "Cannot walk long distances to local clinics because of mobility issues"
            "No means of getting to the clinic"
            "Old age " { ;
            
            replace chm2_10 = 1 if chm2x == "`r'" ; // include answer in binary variable
            replace chm2_98 = 0 if chm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace chm2x = "" if chm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen h_adh_access = chm2_10
        lab var h_adh_access " Mobility/Access (Infrastructure and physical constraints) (chm2x)" 
        lab val h_adh_access yn01

    /*? could not be categorized
        She was very busy at work
        Skipped 3 days angakakhoni kuwalandz
        was not sure whether I had taken my dose or not
        sometimes it takes too long for me to have meals
        was away from home for sometime
        at some point I refused to go, was once ill-treated
        The health worker advised me to stop
        Away from home
        Does not drink pills consistently at the same time
        Was not able to pick them up from the clinic
    */


    * times obtained hypertension medication in past 12 months
        tab chm3,m
        replace chm3 = .d if chm3 == 77
        replace chm3 = .r if chm3 == 88
        replace chm3 = .s if inlist(2, hbp1,hbp2,hbp3) // never measured BP and never diagnosed 
        replace chm3 = .c if inlist(.d, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was DK
        replace chm3 = .q if inlist(.r, hbp1,hbp2,hbp3) // answer to hbp1, hbp2 or hbp3 was refused
    * new obtained medication variable
        gen h_obtmed12 = chm3
        replace h_obtmed12 = .s if inlist(chm3, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var h_obtmed12 "Times obtained hypertension medication in past 12 months (chm3)"
        tab chm3 h_obtmed12, m

    * seen traditional healer for high BP
        tab chm5,m
        replace chm5 = .d if chm5 == 77
        replace chm5 = .r if chm5 == 88
        replace chm5 = .s if inlist(2, hbp1,hbp2) 
        replace chm5 = .c if inlist(.d, hbp1,hbp2) // answer to hbp1 or hbp2 was DK
        replace chm5 = .q if inlist(.r, hbp1,hbp2) // answer to hbp1 or hbp2 was refused
        replace chm5 = .m if version == "v1" & chm5 == . // the skip pattern was changed so that it would also be asked to people currently not taking meds.
    * new traditional healer visit variable
        gen h_trv = (chm5 == 1) if chm5 < . // recode 2 to 0
        replace h_trv = chm5 if chm5 >= . // transfer missings
        replace h_trv = .s if inlist(chm5, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var h_trv "Ever visited traditional healer (chm5)"
        lab val h_trv yn01
        tab chm5 h_trv,m

    * seen traditional healer for high BP
        tab chm6,m
        replace chm6 = .d if chm6 == 77
        replace chm6 = .r if chm6 == 88
        replace chm6 = .s if inlist(2, hbp1,hbp2) 
        replace chm6 = .c if inlist(.d, hbp1,hbp2) // answer to hbp1 or hbp2 was DK
        replace chm6 = .q if inlist(.r, hbp1,hbp2) // answer to hbp1 or hbp2 was refused
        replace chm6 = .m if version == "v1" & chm6 == . // the skip pattern was changed so that it would also be asked to people currently not taking meds.
    * new traditional medicine variable
        gen h_trmed = (chm6 == 1) if chm6 < . // recode 2 to 0
        replace h_trmed = chm6 if chm6 >= . // transfer missings
        replace h_trmed = .s if inlist(chm6, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var h_trmed "Currently takes herbal/traditional medicine (chm6)"
        lab val h_trmed yn01
        tab chm6 h_trmed,m



*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx DIABETES - CARE HISTORY xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    ** details on diabetes diagnosis
        * has been diagnosed with either diabetes or prediabetes
            gen pddm_told = 0 if hd2 == 2 & hd6 == 2 // no previous (pre)diabetes diagnosis
            replace pddm_told = 1 if inlist(1, hd2,hd6) // previous (pre)diabetes diagnosis
            replace pddm_told = 0 if hd1 == 2 // never measured BG
            replace pddm_told = .c if hd1 == .d // answer to hd1 was DK
            replace pddm_told = .d if inlist(.d, hd2,hd6) // answer to hd2 or hd6 was DK
            tab pddm_told,m
            lab val pddm_told yn01
            lab var pddm_told "Ever diagnosed with (pre)diabetes (hd2,hd6)"

        
        * diagnosed in past 12 months (diabetes)
            tab hd7an,m
            replace hd7an = .d if hd7an == 77 // answer to hd7an was DK
            replace hd7an = .s if inlist(2, hd1,hd2) // never had BG measured or was never diagnosed
            replace hd7an = .c if inlist(.d, hd1,hd2) // answer to hd1 or hd2 was DK
            tab hd7an,m

        * new diabetes diagnosis in past 12 months variable
            gen dm_told12 = (hd7an==1) if hd7an < . // recode 2 to 0
            replace dm_told12 = hd7an if hd7an >= . // transfer missing values
            replace dm_told12 = 0 if inlist(dm_told12, .s, .d, .c,.r,.q) // DK, refused, and never measured are recoded to "No"
            lab var dm_told12 "Was diagnosed with diabetes in past 12 months (hd7an)"
            lab val dm_told12 yn01
            tab hd7an dm_told12,m
        * diagnosed in past 12 months (pre-diabetes)
            tab hd7bn,m
            replace hd7bn = .s if inlist(2, hd1,hd6) // never had BG measured or was never diagnosed
            replace hd7bn = .s if hd2 == 1 // was diagnosed with diabetes
            replace hd7bn = .c if inlist(.d, hd1,hd2,hd6) // answer to hd1, hd2 or hd6 was DK
            tab hd7bn,m
        * new pre-diabetes diagnosis in past 12 months variable
            gen pd_told12 = (hd7bn==1) if hd7bn < . // recode 2 to 0
            replace pd_told12 = hd7bn if hd7bn >= . // transfer missing values
            replace pd_told12 = 0 if inlist(pd_told12, .s, .d, .c,.r,.q) // DK, refused, and never measured are recoded to "No"
            replace pd_told12 = .s if hd2 == 1 // previous diabetes diagnosis does not rule out ever diagnosed with pre-diabetes --> .s is kept            
            lab var pd_told12 "Was diagnosed with prediabetes in past 12 months (hd7bn)"
            lab val pd_told12 yn01
            tab hd7bn pd_told12,m

        * diagnosed in past 12 months (pre-diabetes or diabetes)
            gen pddm_told12 = 0 if hd7an == 2 & hd7bn == 2 // no (pre)diabetes diagnosis past 12 months
            replace pddm_told12 = 1 if inlist(1, hd7an,hd7bn) // (pre)diabetes diagnosis past 12 months
            replace pddm_told12 = 0 if hd1 == 2 // never measured BG
            replace pddm_told12 = .c if inlist(.d, hd1,hd2,hd6) // answer to hd1, hd2 or hd6 was DK
            replace pddm_told12 = .d if inlist(.d, hd7an,hd7bn) // answer to hd7an or hd7bn was DK
            lab val pddm_told12 yn01
            lab var pddm_told12 "Was diagnosed with (pre)diabetes in past 12 months (hd7an,hd7bn)"
            tab pddm_told12,m

        * location of diagnosis (diabetes)
            tab hd8a,m
            replace hd8a = .s if inlist(2, hd1,hd2,hd7an) // never measured, not diagnosed, not diagnosed in past 12 months 
            replace hd8a = .c if inlist(.d, hd1,hd2,hd7an) // answer to hd1, hd2 or hd7an was DK

        * location of diagnosis (prediabetes)
            tab hd8b,m
            replace hd8b = .s if inlist(2, hd1,hd6,hd7bn) // // never measured, not diagnosed not diagnosed in past 12 months 
            replace hd8b = .s if hd2 == 1 // diagnosed with diabetes
            replace hd8b = .c if inlist(.d, hd1,hd2,hd6,hd7bn) // answer to hd1, hd2, hd6 or hd7bn was DK

        * other location of diagnosis (prediabetes and diabetes)
            tab hd8x,m
            * new code for private doctor and pharmacy
            replace hd8a = 444 if inlist(hd8x,"Dr Hynd","Dr Sacolo, private practioner ","Dr Shabangu")
            replace hd8x = "" if hd8a < 99998 // remove "specify" details

            replace hd8_name = ".s" if (hd8a == .s | hd8b == .s) & hd8_name == ""
            replace hd8_name = ".c" if (hd8a == .c | hd8b == .c) & hd8_name == ""

                        *TODO: Send hd8x list to CHAI to check if they fit in any of our clinic codes.
            tab hd8_name,m // combines clinic names from prediabetes and diabetes

        * ever taken medication
            tab hd9,m
            replace hd9 = 2 if inlist(hd10x, "Not in care")
            replace hd9 = 2 if hd3 == .d & hd4 == 2 // DK in hd3 but "no" in hd4
            replace hd9 = .s if inlist(2, hd1, hd2) // never measured, never diagnosed
            replace hd9 = .s if inlist(1, hd3, hd4) // currently takes oral meds or insulin
            replace hd9 = .c if inlist(.d, hd1,hd2)  // answer to hd1 and hd2 was DK 
            replace hd9 = .q if hd3 == .r & hd4 == .r // answer to hd3 and hd4 was refused

        * new ever med variable
            gen dm_evermed = (hd9 == 1) if hd9 < . // recode 2 to 0
            replace dm_evermed = hd9 if hd9 >= . // transfer missing values
            replace dm_evermed = 0 if inlist(dm_evermed, .d,.c,.r,.q) // DK and refused are recoded to "No"
            replace dm_evermed = 0 if inlist(2, hd1,hd2) // never had BG measured or was never diagnosed
            lab var dm_evermed "Has ever taken BG medication (hd9)"
            lab val dm_evermed yn01
            tab hd9 dm_evermed,m
            *.s are those that currently take medication


        * location of treatment initiation
            tab hd10,m
            tab hd10x,m
            replace hd10 = .s if inlist(hd10x, "Not in care") // is considered to never have been initiated
            replace hd10x = "" if inlist(hd10x, "Not in care") // is considered to never have been initiated
            replace hd10 = .s if inlist(2, hd1, hd2) // never measured, never diagnosed
            replace hd10 = .s if (hd3 == 2 & hd4 ==2 ) | hd9 == 2 // no meds currently or in the past
            replace hd10 = .c if inlist(.d, hd1, hd2)
            replace hd10 = .r if (hd3 == .r & hd4 == .r)
            replace hd10 = 334 if hd10x == "South Africa "
            * new code for private doctor/clinic
            replace hd10 = 335 if inlist(hd10x,"Doctor Mathunjwa","Dr Mathunjwa","Dr Mathunjwa (Special Doctor) ","Dr Mnisi ","Dr Ngobe ","Dr Sacolo ","Dr Smith in manzini")
            replace hd10 = 335 if inlist(hd10x,"Dr T. Thwala","Private Clinic Mbabane (Doctor)","Private Doctor ","Private Doctor Dr Vilakati","Private clinic")
            replace hd10 = 335 if inlist(hd10x, "Simunye private clinic ","Simunye Clinic ")
            * new code for pharmacy
            replace hd10 = 336 if inlist(hd10x, "Chemist in Matsapha","Pharmaceutical ")
            replace hd10x = "" if hd10 < 99998 | hd10 == .d // delete "specifies" for SA, private doctor, and pharmacy
            lab def hd10 335 "335. Private doctor/clinic" 336 "336. Pharmacy/Chemist", add
            lab val hd10 hd10
                        *TODO: Send hd10x list to CHAI to check if they fit in any of our clinic codes.
            replace hd10_name = ".s" if hd10 == .s
            replace hd10_name = ".c" if hd10 == .c
            replace hd10_name = ".r" if hd10 == .r


        * location of current care seeking for diabetes
            tab hd11a,m
            tab hd11b,m // no "other specifies"
            tab hd11x
            *? few people currently take drugs but report to not be in care
            tab hd3 if hd11a == 99999,m
            tab hd4 if hd11a == 99999,m
            tab hd11a if hd11x != "" 
            replace hd11a = .s if inlist(2, hd1, hd2) // never had BG measured or was never diagnosed
            replace hd11a = .c if inlist(hd2, .d,.c) // answer to hd1 or hd2 was DK
            * new code for private doctor
            replace hd11a = 335 if inlist(hd11x,"DR NGOBE ","DR Smith"," Dr Jonathan ","Dr Mathunjwa","Dr Mnisi ","Dr T. Thwala","Dr. Mphandlana clinic ")
            * new code for pharmacy
            replace hd11a = 336 if inlist(hd11x, "Matata pharmacy","Pharmacy","Pharmacy ")
            replace hd11x = "" if hd11a < 99998 | hd11a == .d // delete "specifies" for SA, private doctor, pharmacy, and DK
            lab def hd11a 335 "335. Private doctor/clinic" 336 "336. Pharmacy/Chemist", add
            lab val hd11a hd11a
                        *TODO: Send hd11x list to CHAI to check if they fit in any of our clinic codes.

        * location of current care seeking for prediabetes
            replace hd11b = .s if inlist(2, hd1,hd6) // never had BG measured or was never diagnosed
            replace hd11b = .s if hd2 == 1 // was diagnosed with diabetes
            replace hd11b = .c if inlist(hd6, .d,.c) // answer to hd1 or hd2 was DK

            replace hd11_name = ".s" if (hd11a == .s | hd11b == .s) & hd11_name == ""
            replace hd11_name = ".c" if (hd11a == .c | hd11b == .c) & hd11_name == ""


        * reason for seeking diabetes care at a different facility than initiation
            tab hd12a,m
            replace hd12a = ".s" if hd11a == 99999 // currently not in care
            replace hd12a = ".s" if inlist(2, hd1, hd2) // never had BG measured or was never diagnosed
            replace hd12a = ".s" if hd10_name==hd11_name // place of initiation and current treatment are the same
            replace hd12a = ".s" if hd3 == 2 & hd4 == 2 // currently does not take medication
            replace hd12a = ".q" if hd10 == .r // answer to hd10 was refused
            replace hd12a = ".s" if hd3 == .d & hd4 == 2 // DK in hd3 but "no" in hd4

            forv q = 1/9 {
                replace hd12a`q' = .s if hd12a == ".s" // transfer missings from hd12a
                replace hd12a`q' = .q if hd12a == ".q" // transfer missings from hd12a
                rename hd12a`q' hd12a_`q' // rename variables for legibility
            } 
            replace hd12a98 = .s if hd12a == ".s" // transfer missings from hd12a
            replace hd12a98 = .q if hd12a == ".q" // transfer missings from hd12a
            rename hd12a98 hd12a_98 // rename variables for legibility
            
            br hd12x if hd12x != ""

            *New facility is closer to home (1)
            # delimit;
            foreach r in 
                "Facility closer to home" {;
                
                replace hd12a_1 = 1 if hd12x == "`r'" ; // include answer in binary variable
                replace hd12a_98 = 0 if hd12x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd12x = "" if hd12x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_switch_home = hd12a_1
            lab var dm_switch_home "New facility is closer to home (hd12a1)" 
            lab val dm_switch_home yn01

            *New facility is closer to work (2)
            gen dm_switch_work = hd12a_2
            lab var dm_switch_work "New facility is closer to work (hd12a2)" 
            lab val dm_switch_work yn01

            *More services offered (3)        
            gen dm_switch_more = hbp10_3
            lab var dm_switch_more "More services are offered (hd12a3)" 
            lab val dm_switch_more yn01


            *Better quality of care (4)
            # delimit;
            foreach r in 
                "They gave her expired medication " 
                "Better waiting hours" {;                
                replace hd12a_4 = 1 if hd12x == "`r'" ; // include answer in binary variable
                replace hd12a_98 = 0 if hd12x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd12x = "" if hd12x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_switch_quality = hd12a_4
            lab var dm_switch_quality "Better quality of care (hd12a3)" 
            lab val dm_switch_quality yn01

            *Cheaper services (5)
            gen dm_switch_cheap = hd12a_5
            lab var dm_switch_cheap "Cheaper services (hd12a5)" 
            lab val dm_switch_cheap yn01
            
            *The facility was recommended by others (family members, friends, co-workers) (6)
            gen dm_switch_recommend = hd12a_6
            lab var dm_switch_recommend "New facility was reommended (hd12a6)" 
            lab val dm_switch_recommend yn01

            *Advertisements in community (7)
            gen dm_switch_advert = hd12a_7
            lab var dm_switch_advert "Advertisements in community (hd12a7)" 
            lab val dm_switch_advert yn01
                    
            *I moved to a different community in the meantime (8)
            gen dm_switch_move = hd12a_8
            lab var dm_switch_move "Moved to different community (hd12a8)" 
            lab val dm_switch_move yn01
                    
            *Drugs are more often available at new clinic (9)
            # delimit;
            foreach r in 
                "The is enough medication"
                "I get all my tabs in this hospital"
                "Mgazini has no insulin injection"
                "No diabetic medication at Mgazini clinic or Our Lady of Sorrows clinic"
                "No diabetic medication at Mgazini Clinic"
                "Because I get the medicationi want and they are not available at Mhlosheni" { ;
                
                replace hd12a_9 = 1 if hd12x == "`r'" ; // include answer in binary variable
                replace hd12a_98 = 0 if hd12x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd12x = "" if hd12x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr
        
            gen dm_switch_drugs = hd12a_9
            lab var dm_switch_drugs "Availability of drugs (hd12a9)" 
            lab val dm_switch_drugs yn01


            * accessibility (incl. money for transport) (new)
            gen hd12a_10 = 0
            lab var hd12a_10 "Accessibility (incl. money for transport) (hd12x, not applicable for diabetes)" 

            gen dm_switch_access = hd12a_10
            lab var dm_switch_access "Accessibility (incl. money for transport) (hd12x, not applicable for diabetes)" 
            lab val dm_switch_access yn01

            * group was moved to different facility (new)
            gen hd12a_11 = 0 
            lab var hd12a_11 "Group was moved (hd12x, not applicable for diabetes)" 

            gen dm_switch_group = hd12a_11
            lab var dm_switch_group "Group was moved (hd12x, not applicable for diabetes)" 
            lab val dm_switch_group yn01

            * was referred by other clinic/hospital/physician (new)
            gen hd12a_12 = 0
            lab var hd12a_12 "Referral by health care worker (hd12x)" 
            # delimit;
            foreach r in 
                "Transferred for initiation of treatment " 
                "Referred by clinic" 
                "was referred by the hospital " 
                "switch facility due to Covid-19 regulations " { ;
                
                replace hd12a_12 = 1 if hd12x == "`r'" ; // include answer in binary variable
                replace hd12a_98 = 0 if hd12x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd12x = "" if hd12x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_switch_referral = hbp10_12
            lab var dm_switch_referral "Referral by health care worker (hd12x)" 
            lab val dm_switch_referral yn01

            * Did not switch (new)
            gen hd12a_13 = 0
            lab var hd12a_13 "Did not switch (hd12x, not applicable for diabetes)" 

            gen dm_switch_noswitch = hd12a_13
            lab var dm_switch_noswitch "Did not switch (hd12x, not applicable for diabetes)" 
            lab val dm_switch_noswitch yn01

        * reason for seeking prediabetes care at a different facility than diagnosis
            * this question was not relevant for any of the respondent --> all values are ".s"
            tab hd12b,m
            tostring hd12b, replace
            replace hd12b = ".s" if hd11b == 99999 // currently not in care
            replace hd12b = ".s" if inlist(2, hd1, hd6) // never had BG measured or was never diagnosed
            replace hd12b = ".s" if hd2 == 1 // previous diabetes diagnosis
            replace hd12b = ".s" if hd7bn == 2 // diagnosis not in past 12 months
            replace hd12b = ".s" if hd8_name==hd11_name // place of diagnosis and current treatment are the same

            forv q = 1/9 {
                replace hd12b`q' = .s if hd12b == ".s" // transfer missings from hd12b
                rename hd12b`q' hd12b_`q' // rename variables for legibility
            } 
            replace hd12b98 = .s if hd12b == ".s" // transfer missings from hd12b
            rename hd12b98 hd12b_98 // rename variables for legibility

            * additional categories created while cleaning "other specify" for htn and diabetes
            forv v = 10/13 {
                gen hd12b_`v' = .s
            }

            foreach v in home work more quality cheap recommend advert move drugs access group referral noswitch {
                gen pd_switch_`v' = .s
                lab val pd_switch_`v' yn01
            }

            * labelling variables
            lab var pd_switch_home "New facility is closer to home (hd12b1)" 
            lab var pd_switch_work "New facility is closer to work (hd12b2)" 
            lab var pd_switch_more "More services are offered (hd12b3)" 
            lab var pd_switch_quality "Better quality of care (hd12b3)" 
            lab var pd_switch_cheap "Cheaper services (hd12b5)" 
            lab var pd_switch_recommend "New facility was reommended (hd12b6)" 
            lab var pd_switch_advert "Advertisements in community (hd12b7)" 
            lab var pd_switch_move "Moved to different community (hd12b8)" 
            lab var pd_switch_drugs "Availability of drugs (hd12b9)" 
            lab var pd_switch_access "Accessibility (incl. money for transport) (hd12b, not applicable for prediabetes)" 
            lab var hd12b_11 "Group was moved (hd12x, not applicable for prediabetes)" 
            lab var pd_switch_group "Group was moved (hd12x, not applicable for prediabetes)" 
            lab var hd12b_12 "Referral by health care worker (hd12bx)" 
            lab var pd_switch_referral "Referral by health care worker (hd12x)" 
            lab var hd12b_13 "Did not switch (hd12x, not applicable for prediabetes)" 
            lab var pd_switch_noswitch "Did not switch (hd12x, not applicable for prediabetes)" 

        * reason for switching clinic (prediabetes and diabetes)
            foreach v in home work more quality cheap recommend advert move drugs access group referral noswitch {
                gen pddm_switch_`v' = dm_switch_`v' // only dm_ variables have values. pd_ variables are all .s
                lab val pddm_switch_`v' yn01
            }
            lab var pddm_switch_home "New facility is closer to home (hd12a1,hd12b1)" 
            lab var pddm_switch_work "New facility is closer to work (hd12a2,hd12b2)" 
            lab var pddm_switch_more "More services are offered (hd12a3,hd12b3)" 
            lab var pddm_switch_quality "Better quality of care (hd12a3,hd12b4)" 
            lab var pddm_switch_cheap "Cheaper services (hd12a5,hd12b5)" 
            lab var pddm_switch_recommend "New facility was reommended (hd12a6,hd12b6)" 
            lab var pddm_switch_advert "Advertisements in community (hd12a7,hd12b7)" 
            lab var pddm_switch_move "Moved to different community (hd12a8,hd12b8)" 
            lab var pddm_switch_drugs "Availability of drugs (hd12a9,hd12b9)" 
            lab var pddm_switch_access "Accessibility (incl. money for transport) (hd12x, not applicable for (pre)diabetes)" 
            lab var pddm_switch_group "Group was moved (hd12x, not applicable for (pre)diabetes)" 
            lab var pddm_switch_referral "Referral by health care worker (hd12x)" 
            lab var pddm_switch_noswitch "Did not switch (hd12x, not applicable for (pre)diabetes)" 

        * first visit to facility for diabetes care
            tab hd13ays,m
            * some interviewers entered the year instead of "years since" first visit
            replace hd13ays = 13 if hd13ays == 2009
            replace hd13ays = 10 if hd13ays == 2012
            replace hd13ays = 7 if hd13ays == 2015
            replace hd13ays = 6 if hd13ays == 2016
            replace hd13ays = 3 if hd13ays == 2019
            replace hd13ays = 2 if hd13ays == 2020
            
            tab hd13ams,m
            tab hd13aws,m
            replace hd13aws = .d if hd13aws == 77 // did not know when first visit happened

            * new variable indicating years since first visit
            gen dm_careyears = hd13ays
            replace dm_careyears = 0 if inrange(hd13ams, 0,11) // up to 11 months since first visit
            replace dm_careyears = 1 if inrange(hd13ams, 12,23) // 12-23 months since first visit
            replace dm_careyears = 2 if inrange(hd13ams, 24,35) // 24-35 months since first visit
            replace dm_careyears = 0 if hd13aws < 52 // less than 52 weeks since first visit
        

            * year and month of first visit
            sum hd13ay // 1985 - 2022

            forv yr = `r(min)'(1)`r(max)' { // loop from earliest to latest year of first visit for care
                replace dm_careyears = 2022 - `yr' if hd13ay == `yr' & hd13am <= month // month of first visit was in or before month of interview
                replace dm_careyears = 2022 - `yr' - 1 if hd13ay == `yr' & hd13am > month & hd13am < . // month of interview was after month of interview 
            }
            replace dm_careyears = .s if inlist(2, hd1,hd2) // never had BG measured or was never diagnosed
            replace dm_careyears = .s if hd11a == 99999 // currently not in care
            replace dm_careyears = .d if hd13aws == .d // does not know when 1st visit happened
            replace dm_careyears = .c if inlist(.d, hd1,hd2) // answer to hbp1 or hd2 was DK
            lab var dm_careyears "Years since first visit to facility for diabetes care (hd13a*)"
            tab dm_careyears,m


        * first visit was in past 12 months
            gen dm_care12 = .
            replace dm_care12 = 1 if hd13ay == 2022 // first visit in 2022
            replace dm_care12 = 1 if hd13ay == 2021 & hd13am >= month & hd13am < . // first visit in 2021, month in or before interview month
            replace dm_care12 = 0 if hd13ay == 2021 & hd13am < month // first visit in 2021, month after interview month
            replace dm_care12 = 0 if hd13ay < 2021 // first visit before 2021
            replace dm_care12 = 1 if hd13ays == 1 // one year since first visit
            replace dm_care12 = 0 if hd13ays > 1 & hd13ays < . // more than one year since first visit
            replace dm_care12 = 1 if hd13ams < 12 | hd13aws < 52 // less than 11 months or 52 weeks since first visit
            replace dm_care12 = dm_careyears if dm_careyears >= . // transfer missings
            tab dm_care12,m
            tab dm_care12 dm_told12,m
                        *? what do we do with cases that indicated that they were diagnosed in past 12 months but the date of first visit is longer ago?
                        *? this is the majority of cases. Maybe they misunderstood and thought it is the first visit to the facility in general.
            lab var dm_care12 "First visit to facility for diabetes care was in past 12 months (hd13a*)"
            lab val dm_care12 yn01


        * first visit to facility for diabetes care
            tab hd13bys,m // empty
            tab hd13bms,m // empty
            tab hd13bws,m
            replace hd13bws = .d if hd13bws == 77 // did not know when first visit happened

            * new variable indicating years since first visit
            gen pd_careyears = hd13bys
            replace pd_careyears = 0 if inrange(hd13bms, 0,11) // up to 11 months since first visit
            replace pd_careyears = 1 if inrange(hd13bms, 12,23) // 12-23 months since first visit
            replace pd_careyears = 2 if inrange(hd13bms, 24,35) // 24-35 months since first visit
            replace pd_careyears = 0 if hd13bws < 52 // less than 52 weeks since first visit
        

            * year and month of first visit
            sum hd13by // 1985 - 2022

            forv yr = `r(min)'(1)`r(max)' { // loop from earliest to latest year of first visit for care
                replace pd_careyears = 2022 - `yr' if hd13by == `yr' & hd13bm <= month // month of first visit was in or before month of interview
                replace pd_careyears = 2022 - `yr' - 1 if hd13by == `yr' & hd13bm > month & hd13bm < . // month of interview was after month of interview 
            }
            replace pd_careyears = .s if inlist(2, hd1,hd6) // never had BG measured or was never diagnosed
            replace pd_careyears = .s if hd2 == 1 // was diagnosed with diabetes
            replace pd_careyears = .s if hd11b == 99999 // currently not in care
            replace pd_careyears = .d if hd13bws == .d // does not know when 1st visit happened
            replace pd_careyears = .c if inlist(.d, hd1,hd2,hd6) // answer to hd1, or hd6 was DK
            lab var pd_careyears "Years since first visit to facility for prediabetes care (hd13b*)"
            tab pd_careyears,m

        * first visit was in past 12 months
            gen pd_care12 = .
            replace pd_care12 = 1 if hd13by == 2022 // first visit in 2022
            replace pd_care12 = 1 if hd13by == 2021 & hd13bm >= month & hd13bm < . // first visit in 2021, month in or before interview month
            replace pd_care12 = 0 if hd13by == 2021 & hd13bm < month // first visit in 2021, month after interview month
            replace pd_care12 = 0 if hd13by < 2021 // first visit before 2021
            replace pd_care12 = 1 if hd13bys == 1 // one year since first visit
            replace pd_care12 = 0 if hd13bys > 1 & hd13bys < . // more than one year since first visit
            replace pd_care12 = 1 if hd13bms < 12 | hd13bws < 52 // less than 11 months or 52 weeks since first visit
            replace pd_care12 = pd_careyears if pd_careyears >= . // transfer missings
            tab pd_care12,m
            tab pd_care12 pd_told12,m
                        *? what do we do with cases that indicated that they were diagnosed in past 12 months but the date of first visit is longer ago?
                        *? this is the majority of cases. Maybe they misunderstood and thought it is the first visit to the facility in general.
            lab var pd_care12 "First visit to facility for prediabetes care was in past 12 months (hd13b*)"
            lab val pd_care12 yn01

        * combine prediabetes and diabetes variables
            * new years since first visit for care variable
            gen pddm_careyears = .
            replace pddm_careyears = dm_careyears if dm_careyears < .
            replace pddm_careyears = pd_careyears if pd_careyears < .
            replace pddm_careyears = .s if pd_careyears == .s & dm_careyears == .s
            replace pddm_careyears = .c if pd_careyears == .c & dm_careyears == .c
            replace pddm_careyears = .c if pd_careyears == .c & dm_careyears == .s
            replace pddm_careyears = .d if pd_careyears == .d & dm_careyears == .s
            replace pddm_careyears = .d if pd_careyears == .s & dm_careyears == .d
            tab pddm_careyears,m
            lab var pddm_careyears "Years since first visit to facility for (pre)diabetes care (pd_careyears,dm_careyears)"

            * new years since in care variable
            gen pddm_care12 = .
            replace pddm_care12 = dm_care12 if dm_care12 < .
            replace pddm_care12 = pd_care12 if pd_care12 < .
            replace pddm_care12 = .s if pd_care12 == .s & dm_care12 == .s
            replace pddm_care12 = .c if pd_care12 == .c & dm_care12 == .c
            replace pddm_care12 = .c if pd_care12 == .c & dm_care12 == .s
            replace pddm_care12 = .d if pd_care12 == .d & dm_care12 == .s
            replace pddm_care12 = .d if pd_care12 == .s & dm_care12 == .d
            tab pddm_care12,m
            lab var pddm_care12 "First visit to facility for (pre)diabetes care was in past 12 months (pd_care12,dm_care12)"
            lab val pddm_care12 yn01

        * advice variables
            foreach v of varlist hd14* { // list of all advice variables (hd14)
                tab `v',m
                replace `v' = .s if hd1 == 2 // never had BG measured
                replace `v' = .s if hd2 == 2 & hd6 == 2 // never was diagnosed with (pre)diabetes
                replace `v' = .s if hd11a == 99999 | hd11b == 99999  // is currently not in care for (pre)diabetes
                replace `v' = .d if `v' == 77 // DK in respective advice variable
                replace `v' = .c if inlist(.d, hd1,hd2,hd6) // answer to  hd1, hd2 or hd6 was DK
            }

            *Quit using tobacco or don’t start (a)
                * prediabetes and diabetes
                gen pddm_advtob = (hd14a==1) if hd14a < .
                replace pddm_advtob = hd14a if hd14a >= .
                lab var pddm_advtob "Advised to quit tobacco or don't start (pre)diabetes (hd14a)"
                lab val pddm_advtob yn01
                * prediabetes
                gen pd_advtob = pddm_advtob
                replace pd_advtob = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advtob "Advised to quit tobacco or don't start prediabetes (hd14a)"
                lab val pd_advtob yn01
                * diabetes
                gen dm_advtob = pddm_advtob
                replace dm_advtob = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advtob "Advised to quit tobacco or don't start diabetes (hd14a)"
                lab val dm_advtob yn01


            *Reduce salt in your diet (b)
                * prediabetes and diabetes
                gen pddm_advsalt = (hd14b==1) if hd14b < .
                replace pddm_advsalt = hd14b if hd14b >= .
                lab var pddm_advsalt "Advised to reduce salt in diet (pre)diabetes (hd14b)"
                lab val pddm_advsalt yn01
                * prediabetes
                gen pd_advsalt = pddm_advsalt
                replace pd_advsalt = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advsalt "Advised to reduce salt in diet prediabetes (hd14b)"
                lab val pd_advsalt yn01
                * diabetes
                gen dm_advsalt = pddm_advsalt
                replace dm_advsalt = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advsalt "Advised to reduce salt in diet diabetes (hd14b)"
                lab val dm_advsalt yn01

            *Reduce fat in your diet (c)
                * prediabetes and diabetes
                gen pddm_advfat = (hd14c==1) if hd14c < .
                replace pddm_advfat = hd14c if hd14c >= .
                lab var pddm_advfat "Advised to reduce fat in diet (pre)diabetes (hd14c)"
                lab val pddm_advfat yn01
                * prediabetes
                gen pd_advfat = pddm_advfat
                replace pd_advfat = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advfat "Advised to reduce fat in diet prediabetes (hd14c)"
                lab val pd_advfat yn01
                * diabetes
                gen dm_advfat = pddm_advfat
                replace dm_advfat = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advfat "Advised to reduce fat in diet diabetes (hd14c)"
                lab val dm_advfat yn01

            *Start or do more physical activity (d)
                * prediabetes and diabetes
                gen pddm_advpa = (hd14d==1) if hd14d < .
                replace pddm_advpa = hd14d if hd14d >= .
                lab var pddm_advpa "Advised to start/do more physical activity (pre)diabetes (hd14d)"
                lab val pddm_advpa yn01
                * prediabetes
                gen pd_advpa = pddm_advpa
                replace pd_advpa = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advpa "Advised to start/do more physical activity prediabetes (hd14d)"
                lab val pd_advpa yn01
                * diabetes
                gen dm_advpa = pddm_advpa
                replace dm_advpa = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advpa "Advised to start/do more physical activity diabetes (hd14d)"
                lab val dm_advpa yn01

            *Maintain a healthy body weight or lose weight (e)
                * prediabetes and diabetes
                gen pddm_advweight = (hd14e==1) if hd14e < .
                replace pddm_advweight = hd14e if hd14e >= .
                lab var pddm_advweight "Advised to maintain healthy/lose weight (pre)diabetes (hd14e)"
                lab val pddm_advweight yn01
                * prediabetes
                gen pd_advweight = pddm_advweight
                replace pd_advweight = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advweight "Advised to maintain healthy/lose weight prediabetes (hd14e)"
                lab val pd_advweight yn01
                * diabetes
                gen dm_advweight = pddm_advweight
                replace dm_advweight = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advweight "Advised to maintain healthy/lose weight diabetes (hd14e)"
                lab val dm_advweight yn01

            *Reduce sugary beverages in your diet (f)
                * prediabetes and diabetes
                gen pddm_advsug = (hd14f==1) if hd14f < .
                replace pddm_advsug = hd14f if hd14f >= .
                lab var pddm_advsug "Advised to reduce sugary beverages in diet (pre)diabetes (hd14f)"
                lab val pddm_advsug yn01
                * prediabetes
                gen pd_advsug = pddm_advsug
                replace pd_advsug = .s if hd2 == 1 // diagnosed with diabetes
                lab var pd_advsug "Advised to reduce sugary beverages in diet prediabetes (hd14f)"
                lab val pd_advsug yn01
                * diabetes
                gen dm_advsug = pddm_advsug
                replace dm_advsug = .s if hd2 == 2 // not diagnosed with diabetes
                lab var dm_advsug "Advised to reduce sugary beverages in diet diabetes (hd14f)"
                lab val dm_advsug yn01

        drop IV IW hd13a_When_did_you_blood_sugar_d hd13b_When_did_you_d_sugar_pre_d JD JE JG hd14_Are_you_curren_other_health
        
        * reason for missing follow-up visits (among those currently in diabetes care)
            tab hd15,m
            tab hd11a if hd15 == "",m 
            replace hd15 = ".s" if hd11a == 99999 // currently not in care
            replace hd15 = ".s" if inlist(2, hd1, hd2) // never had BG measured or was never diagnosed
            replace hd15 = ".c" if inlist(.d, hd1,hd2) // answer to hbp1 or hbp2 was DK

            forv q = 1/15 {
                replace hd15`q' = .s if hd15 == ".s" // transfer missings from hd15
                replace hd15`q' = .c if hd15 == ".c" // transfer missings from hd15
                rename hd15`q' hd15_`q'
            } 

            replace hd1598 = .s if hd15 == ".s" // transfer missings from hd15
            replace hd1598 = .c if hd15 == ".c" // transfer missings from hd15
            rename hd1598 hd15_98
            
            br hd15x if hd15x != ""

            *Need to work (1)
            gen dm_miss_work = hd15_1
            lab var dm_miss_work "Had to work (hd151)" 
            lab val dm_miss_work yn01

            *Needed to take care of family members (2)
            gen dm_miss_care = hd15_2
            lab var dm_miss_care "Care for family members (hd152)" 
            lab val dm_miss_care yn01

            *Too far away from home (3)
            gen dm_miss_home = hd15_2
            lab var dm_miss_home "Too far away from home (hd153)" 
            lab val dm_miss_home yn01

            *No money to pay for transport (4)
            gen dm_miss_trans = hd15_4
            lab var dm_miss_trans "No money for transport (hd154)" 
            lab val dm_miss_trans yn01

            *No money to pay for health care services (5)
            gen dm_miss_payserv = hd15_5
            lab var dm_miss_payserv "No money for transport (hd155)" 
            lab val dm_miss_payserv yn01
                
            *Waiting times are too long (6)
            gen dm_miss_wait = hd15_6
            lab var dm_miss_wait "Waiting times are too long (hd156)" 
            lab val dm_miss_wait yn01

           *Low quality of services (7)
            gen dm_miss_quality = hd15_7
            lab var dm_miss_quality "Low quality of services (hd157)" 
            lab val dm_miss_quality yn01

            *Bad treatment by health care workers (8)
            gen dm_miss_bad = hd15_8
            lab var dm_miss_bad "Bad treatment by health care workers (hd158)" 
            lab val dm_miss_bad yn01

            *Feeling uncomfortable during consultation (9)
            gen dm_miss_uncom = hd15_9
            lab var dm_miss_uncom "Feeling uncomfortable during consultation (hd159)" 
            lab val dm_miss_uncom yn01

            *No need to go because I felt good (10)
            gen dm_miss_feel = hd15_10
            lab var dm_miss_feel "No need to go because I felt good (hd1510)" 
            lab val dm_miss_feel yn01

            *I forgot about the appointment (11)
            gen dm_miss_forgot = hd15_11
            lab var dm_miss_forgot "I forgot about the appointment (hd1511)" 
            lab val dm_miss_forgot yn01

            *The consultation did not help me to feel better (12)
            gen dm_miss_nothelp = hd15_12
            lab var dm_miss_nothelp "The consultation did not help me to feel better (hd1512)" 
            lab val dm_miss_nothelp yn01

            *I went to a traditional healer instead (13)
            gen dm_miss_healer = hd15_13
            lab var dm_miss_healer "I went to a traditional healer instead (hd1513)" 
            lab val dm_miss_healer yn01

            *There are no drugs available at the facility (14)
            gen dm_miss_nodrugs = hd15_14
            lab var dm_miss_nodrugs "There are no drugs available at the facility (hd1514)" 
            lab val dm_miss_nodrugs yn01
                
            *Did not miss a follow-up visit (15)
            gen dm_miss_nomiss = hd15_15
            lab var dm_miss_nomiss "Did not miss a follow-up visit (hd1515)" 
            lab val dm_miss_nomiss yn01

            * accessibility (new) - *?maybe put together with  "too far away from home"
            gen hd15_16 = 0
            lab var hd15_16 "Accessibility (hd15x)" 
            # delimit;
            foreach r in 
                "No transport available when its raining." {;
                
                replace hd15_16 = 1 if hd15x == "`r'" ; // include answer in binary variable
                replace hd15_98 = 0 if hd15x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd15x = "" if hd15x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_miss_access = hd15_16
            lab var dm_miss_access "Accessibility (hd15x)" 
            lab val dm_miss_access yn01
               

            * phyiscally unable / constrained physical mobility (new)
            gen hd15_17 = 0
            lab var hd15_17 "Phyiscally unable / constrained physical mobility (hd15x)" 
            # delimit;
            foreach r in 
                "Visually impaired, can't move around" 
                "Not physically able " 
                "Swollen feet can't walk at times" 
                "Unable to walk" {;
                
                replace hd15_17 = 1 if hd15x == "`r'" ; // include answer in binary variable
                replace hd15_98 = 0 if hd15x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd15x = "" if hd15x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_miss_unable = hd15_17
            lab var dm_miss_unable "Phyiscally unable / constrained physical mobility (hbp13x)" 
            lab val dm_miss_unable yn01

            * stopped taking medication (new)
            gen hd15_18 = 0
            lab var hd15_18 "Stopped taking medication (hd15x)" 
            # delimit;
            foreach r in 
                "Not taking diabetes medicine"
                "Not in care"
                "Stopped taking medication "
                "Normally default when there is no food at home, because they make him hungry if he takes them on an empty tummy" {;
                
                replace hd15_18 = 1 if hd15x == "`r'" ; // include answer in binary variable
                replace hd15_98 = 0 if hd15x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd15x = "" if hd15x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen dm_miss_stopmed = hd15_18
            lab var dm_miss_stopmed "Stopped taking medication (hbp13x)" 
            lab val dm_miss_stopmed yn01

                /*? Could not be categorized
                    Financial problem
                    No
                    Medication still available
                */

        * reason for stop going to follow up visits (among those currently not in care, pre(diabetes))
            tab hd16,m
            replace hd16 = ".s" if hd11a < 99999 | hd11b < 99999  // only asked to those who are currently not in care
            replace hd16 = ".s" if hd1 == 2 // never measured BG
            replace hd16 = ".s" if inlist(2, hd2,hd6) // was not diagnosed with (pre)diabetes
            replace hd16 = ".c" if inlist(.d, hd1,hd2,hd6) // answer to hd1 or hd2 was DK

            forv q = 1/14 {
                replace hd16`q' = .s if hd16 == ".s" // transfer missings from hd16
                replace hd16`q' = .c if hd16 == ".c" // transfer missings from hd16

                rename hd16`q' hd16_`q' // transfer missings from hd16
            } 

            replace hd1698 = .s if hd16 == ".s" // transfer missings from hd16
            replace hd1698 = .c if hd16 == ".c" // transfer missings from hd16
            rename hd1698 hd16_98

            br hd16x if hd16x != ""
            *Need to work (1)
            gen pddm_stop_work = hd16_1
            lab var pddm_stop_work "Had to work (hd161)" 
            lab val pddm_stop_work yn01

            *Needed to take care of family members (2)
            gen pddm_stop_care = hd16_2
            lab var pddm_stop_care "Care for family members (hd162)" 
            lab val pddm_stop_care yn01

            *Too far away from home (3)
            # delimit;
            foreach r in 
               "Facility far from home " 
               "Facility far from home" {;
                
                replace hd16_3 = 1 if hd16x == "`r'" ; // include answer in binary variable
                replace hd16_98 = 0 if hd16x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd16x = "" if hd16x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen pddm_stop_home = hd16_3
            lab var pddm_stop_home "Too far away from home (hd163)" 
            lab val pddm_stop_home yn01

            *No money to pay for transport (4)
            gen pddm_stop_trans = hd16_4
            lab var pddm_stop_trans "No money for transport (hd164)" 
            lab val pddm_stop_trans yn01

            *No money to pay for health care services (5)
            gen pddm_stop_payserv = hd16_5
            lab var pddm_stop_payserv "No money for transport (hd165)" 
            lab val pddm_stop_payserv yn01

            *Waiting times are too long (6)
            gen pddm_stop_wait = hd16_6
            lab var pddm_stop_wait "Waiting times are too long (hd166)" 
            lab val pddm_stop_wait yn01

           *Low quality of services (7)
            gen pddm_stop_quality = hd16_7
            lab var pddm_stop_quality "Low quality of services (hd167)" 
            lab val pddm_stop_quality yn01

            *Bad treatment by health care workers (8)
            gen pddm_stop_bad = hd16_8
            lab var pddm_stop_bad "Bad treatment by health care workers (hd168)" 
            lab val pddm_stop_bad yn01

            *Feeling uncomfortable during consultation (9)
            gen pddm_stop_uncom = hd16_9
            lab var pddm_stop_uncom "Feeling uncomfortable during consultation (hd169)" 
            lab val pddm_stop_uncom yn01

            *No need to go because I felt good (10)
            # delimit;
            foreach r in 
                "I felt better and I have been drinking  herbal tea" {;
                
                replace hd16_10 = 1 if hd16x == "`r'" ; // include answer in binary variable
                replace hd16_98 = 0 if hd16x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd16x = "" if hd16x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen pddm_stop_feel = hd16_10
            lab var pddm_stop_feel "No need to go because I felt good (hd1610)" 
            lab val pddm_stop_feel yn01
           
            *I forgot about the appointment (11)
            gen pddm_stop_forgot = hbp14_11
            lab var pddm_stop_forgot "I forgot about the appointment (hbp1411)" 
            lab val pddm_stop_forgot yn01
            
            *The consultation did not help me to feel better (12)
            # delimit;
            foreach r in 
                "Every time I took the insulin I always felt sick, therefore I stopped taking it and I also lost my medical records "
                {;
                
                replace hd16_12 = 1 if hd16x == "`r'" ; // include answer in binary variable
                replace hd16_98 = 0 if hd16x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd16x = "" if hd16x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen pddm_stop_nothelp = hd16_12
            lab var pddm_stop_nothelp "The consultation did not help me to feel better (incl. side effects) (hbp1412)" 
            lab val pddm_stop_nothelp yn01
                

            *I went to a traditional healer instead (13)
            gen pddm_stop_healer = hbp14_13
            lab var pddm_stop_healer "I went to a traditional healer instead (hbp143)" 
            lab val pddm_stop_healer yn01

            *There are no drugs available at the facility (14)
            gen pddm_stop_nodrugs = hbp14_14
            lab var pddm_stop_nodrugs "There are no drugs available at the facility (hbp1414)" 
            lab val pddm_stop_nodrugs yn01
                                
            * stopped taking the medication (new)
            gen hd16_16 = 0
            lab var hd16_16 "stopped taking the medication (hd16x)"
            # delimit;
            foreach r in 
                "Blood sugar was normal for a long time. So the doctor told me to stop taking them."
                "Told by a doctor to stop " 
                "Doctor took her off medication" 
                "was advised by the doctor to temporarily stop using the drugs as I had defaulted and my system is weakened " 
                "TB treatment caused Glucose level to be low, ended up stopping Insulin injection"
                {;
                
                replace hd16_16 = 1 if hd16x == "`r'" ; // include answer in binary variable
                replace hd16_98 = 0 if hd16x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd16x = "" if hd16x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen pddm_stop_stopmed = hd16_16
            lab var pddm_stop_stopmed "stopped taking the medication (hd16x)" 
            lab val pddm_stop_stopmed yn01
                
            * was not initiated/not told to come back (new)
            gen hd16_17 = 0
            lab var hd16_17 "Was not initiated/not told to come back (hd16x)"
            * includes not in care
            # delimit;
            foreach r in 
                "Not in care "
                "Not in care"
                "Not on treatment"
                "Not on treatment " 
                "Not given treatment "
                "Not ready to take treatment "
                "Was not initiated on treatment "
                "No prescribed medication "
                "Never been initiated treatment "
                "not in care "
                "not in care"
                "Never in care "
                "Never saw the need to start medication"
                "Was told to manage my diet"
                "I was advised to change my diet"
                "Not diabetic "
                {;
                
                replace hd16_17 = 1 if hd16x == "`r'" ; // include answer in binary variable
                replace hd16_98 = 0 if hd16x == "`r'" ; // exclude answer from binary "other" variable 
                replace hd16x = "" if hd16x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen pddm_stop_notinit = hd16_17
            lab var pddm_stop_notinit "Was not initiated/not told to come back (hd16x)" 
            lab val pddm_stop_notinit yn01

            /*? could not be categorized
                Diagnosed and told it in medium amount
            */

            * variables for diabetics and pre-diabetics separately
            * diabetics
            foreach v in work care home trans payserv wait quality bad uncom feel forgot nothelp healer nodrugs stopmed notinit {
                gen dm_stop_`v' = pddm_stop_`v'
                replace dm_stop_`v' = .s if hd11a != 99999 & dm_stop_`v' < . // set values of prediabetics .s but retain other special values
                lab val dm_stop_`v' yn01
            }
            lab var dm_stop_work "Had to work (hd161)" 
            lab var dm_stop_care "Care for family members (hd162)" 
            lab var dm_stop_home "Too far away from home (hd163)" 
            lab var dm_stop_trans "No money for transport (hd164)" 
            lab var dm_stop_payserv "No money for transport (hd165)" 
            lab var dm_stop_wait "Waiting times are too long (hd166)" 
            lab var dm_stop_quality "Low quality of services (hd167)" 
            lab var dm_stop_bad "Bad treatment by health care workers (hd168)" 
            lab var dm_stop_uncom "Feeling uncomfortable during consultation (hd169)" 
            lab var dm_stop_feel "No need to go because I felt good (hd1610)" 
            lab var dm_stop_forgot "I forgot about the appointment (hbp1411)" 
            lab var dm_stop_nothelp "The consultation did not help me to feel better (incl. side effects) (hbp1412)" 
            lab var dm_stop_healer "I went to a traditional healer instead (hbp143)" 
            lab var dm_stop_nodrugs "There are no drugs available at the facility (hbp1414)" 
            lab var dm_stop_stopmed "stopped taking the medication (hd16x)" 
            lab var dm_stop_notinit "Was not initiated/not told to come back (hd16x)" 


            * prediabetics
            foreach v in work care home trans payserv wait quality bad uncom feel forgot nothelp healer nodrugs stopmed notinit {
                gen pd_stop_`v' = pddm_stop_`v'
                replace pd_stop_`v' = .s if hd11b != 99999 & pd_stop_`v' < .  // set values of diabetics .s but retain other special values
                lab val pd_stop_`v' yn01
            }
            lab var pd_stop_work "Had to work (hd161)" 
            lab var pd_stop_care "Care for family members (hd162)" 
            lab var pd_stop_home "Too far away from home (hd163)" 
            lab var pd_stop_trans "No money for transport (hd164)" 
            lab var pd_stop_payserv "No money for transport (hd165)" 
            lab var pd_stop_wait "Waiting times are too long (hd166)" 
            lab var pd_stop_quality "Low quality of services (hd167)" 
            lab var pd_stop_bad "Bad treatment by health care workers (hd168)" 
            lab var pd_stop_uncom "Feeling uncomfortable during consultation (hd169)" 
            lab var pd_stop_feel "No need to go because I felt good (hd1610)" 
            lab var pd_stop_forgot "I forgot about the appointment (hbp1411)" 
            lab var pd_stop_nothelp "The consultation did not help me to feel better (incl. side effects) (hbp1412)" 
            lab var pd_stop_healer "I went to a traditional healer instead (hbp143)" 
            lab var pd_stop_nodrugs "There are no drugs available at the facility (hbp1414)" 
            lab var pd_stop_stopmed "stopped taking the medication (hd16x)" 
            lab var pd_stop_notinit "Was not initiated/not told to come back (hd16x)" 

        drop  hd14

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx DIABETES - DSD MODELS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    




    ** Facility-based treatment club
        * attended FTC meeting in past 12 months
            tab dftc1,m
            replace dftc1 = .d if dftc1 == 77 // answer to dftc1 was DK
            replace dftc1 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dftc1 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
        * new FTC meeting in past 12 months variable
            gen dm_ftc12 = (dftc1==1) if dftc1 < . // recode 2 to 0
            replace dm_ftc12 = dftc1 if dftc1 >= . // transfer missing values
            replace dm_ftc12 = 0 if inlist(dm_ftc12, .d, .r) // DK and refused are recoded to "No"
            replace dm_ftc12 = .s if inlist(dm_ftc12, .c, .q) // answer to hd1, hd2 was DK --> DSD not relevant
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var dm_ftc12 "Went to FTC meeting in past 12 months (dftc1)"
            lab val dm_ftc12 yn01
            tab dm_ftc12,m
        * variable for those with diabetes and hypertension
            gen co_ftc12 = .s
            replace co_ftc12 = 0 if inlist(0, dm_ftc12,h_ftc12) & dm_ftc12 < . & h_ftc12 < . // both ftc are non-missing and at least one is 0
            replace co_ftc12 = 1 if dm_ftc12 == 1 & h_ftc12 == 1 // visited FTC for both DM and HTN
            tab dm_ftc12 h_ftc12,m
            tab co_ftc12,m
            lab var co_ftc12 "Went to FTC meeting in past 12 months (dm_ftc12,h_ftc12)"
            lab val co_ftc12 yn01

        * times attended meeting
            tab dftc3,m
            replace dftc3 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dftc3 = .s if dftc1 == 2 // did not go to FTC meeting
            replace dftc3 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
            replace dftc3 = .c if dftc1 == .d // answer to hftc1 was DK
            replace dftc3 = .s if co_ftc12 == 1 // it was assumed that answers are the same if comorbid with HTN
        * new number of FTC meetings attended variable
            gen dm_ftcatt = dftc3
            replace dm_ftcatt = h_ftcatt if co_ftc12 == 1
            lab var dm_ftcatt "Number of FTC meetings attended in past 12 months (dftc3,h_ftcatt)"

        * reasons for missing group meetings
            tab dftc7,m
            tab dftc7x,m // empty
            tostring dftc7, replace
            tab hftc7 if co_ftc12 == 1,m // no "other specify"
            replace dftc7 = ".s" if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dftc7 = ".s" if hftc1 == 2 // did not go to FTC meeting
            replace dftc7 = ".s" if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
            replace dftc7 = ".c" if hftc1 == .d // answer to dftc1 was DK
            replace dftc7 = ".q" if hftc1 == .r // answer to dftc1 was refused

            forv q = 1/8 {
                replace dftc7`q' = .s if dftc7 == ".s"
                replace dftc7`q' = .q if dftc7 == ".q"
                replace dftc7`q' = .c if dftc7 == ".c"
                rename dftc7`q' dftc7_`q'
            } 
            replace dftc798 = .s if dftc7 == ".s"
            replace dftc798 = .q if dftc7 == ".q"
            replace dftc798 = .c if dftc7 == ".c"
            rename dftc798 dftc7_98

            *I did not have time (1)
            gen dm_ftc_miss_time = dftc7_1 
            replace dm_ftc_miss_time = hftc7_1 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_time "I did not have time (dftc71,hftc71)"
            *I could not afford transport (2)
            gen dm_ftc_miss_transport = dftc7_2
            replace dm_ftc_miss_transport = hftc7_2 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_transport "I could not afford transport (dftc72,hftc72)"
            *I still had medication (3)
            gen dm_ftc_miss_hadmed = dftc7_3
            replace dm_ftc_miss_hadmed = hftc7_3 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_hadmed "I still had medication (dftc73,hftc73)"
            *I did not want to go (4)
            gen dm_ftc_miss_notwant = dftc7_4
            replace dm_ftc_miss_notwant = hftc7_4 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_notwant "I did not want to go (dftc74,hftc74)"
            *I forgot (5)
            gen dm_ftc_miss_forget = dftc7_5
            replace dm_ftc_miss_forget = hftc7_5 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_forget "I forgot (dftc75,hftc75)"
            *I did not know about the meetings (6)
            gen dm_ftc_miss_notknow = dftc7_6
            replace dm_ftc_miss_notknow = hftc7_6 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_notknow "I did not know about the meetings (dftc76,hftc76)"
            *I knew no medication was available (7)
            gen dm_ftc_miss_nomed = dftc7_7
            replace dm_ftc_miss_nomed = hftc7_7 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_nomed "I knew no medication was available (dftc77,hftc77)"
            *Did not miss a meeting (8)
            gen dm_ftc_miss_nomiss = dftc7_8
            replace dm_ftc_miss_nomiss = hftc7_8 if co_ftc12 == 1 // transer information from those with htn visiting FTC
            lab var dm_ftc_miss_nomiss "Did not miss a meeting (dftc78,hftc78)"

            * label variables
            foreach v of varlist dm_ftc_miss_* {
            lab val `v' yn01
            }

    ** Community Advisory Group
        * went to CAG meeting in past 12 months
            tab dcag1,m
            replace dcag1 = .d if dcag1 == 77 // answer to dcag1 was DK
            replace dcag1 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dcag1 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
        * new CAG meeting in past 12 months variable
            gen dm_cag12 = (dcag1==1) if dcag1 < . // recode 2 to 0
            replace dm_cag12 = dcag1 if dcag1 >= . // transfer missing values
            replace dm_cag12 = 0 if inlist(dm_cag12, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var dm_cag12 "Went to CAG meeting in past 12 months (dcag1)"
            lab val dm_cag12 yn01
            tab dcag1 dm_cag12,m
        * variable for those with diabetes and hypertension
            gen co_cag12 = .s
            replace co_cag12 = 0 if inlist(0, dm_cag12,h_cag12) & dm_cag12 < . & h_cag12 < . // both ftc are non-missing and at least one is 0
            replace co_cag12 = 1 if dm_cag12 == 1 & h_cag12 == 1 // visited FTC for both DM and HTN
            tab dm_cag12 h_cag12,m
            tab co_cag12,m
            lab var co_cag12 "Went to CAG meeting in past 12 months (dm_cag12,h_cag12)"
            lab val co_cag12 yn01


        * number of CAG meetings
            tab dcag3,m
            replace dcag3 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dcag3 = .s if dcag1 == 2 // did not go to CAG meeting
            replace dcag3 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
            replace dcag3 = .c if dcag1 == .d // answer to dcag1 was DK
            replace dcag3 = .s if co_cag12 == 1 // it was assumed that answers are the same if comorbid with HTN
        * new number of CAG meetings attended variable
            gen dm_cagatt = dcag3
            replace dm_cagatt = h_cagatt if co_cag12 == 1
            lab var dm_cagatt "Number of CAG meetings attended in past 12 months (dcag3, h_cagatt)"

        * reasons for missing CAG meetings
            tab dcag11,m
            tostring dcag11, replace
            tab hcag11x,m // is empty
            replace dcag11 = ".s" if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dcag11 = ".s" if dcag1 == 2 // did not go to CAG meeting
            replace dcag11 = ".s" if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
            replace dcag11 = ".c" if dcag1 == .d // answer to hcag1 was DK
            forv q = 1/8 {
                replace dcag11`q' = .s if dcag11 == ".s"
                replace dcag11`q' = .c if dcag11 == ".c"
                rename dcag11`q' dcag11_`q'
            } 
            replace dcag1198 = .s if dcag11 == ".s"
            replace dcag1198 = .c if dcag11 == ".c"
            rename dcag1198 dcag11_98
            
            *I did not have time (1)
            gen dm_cag_miss_time = dcag11_1
            replace dm_cag_miss_time = dcag11_1 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_time "I did not have time (dcag111,hcag111)"
            *I could not afford transport (2)
            gen dm_cag_miss_transport = dcag11_2
            replace dm_cag_miss_transport = dcag11_2 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_transport "I could not afford transport (dcag112,hcag112)"
            *I still had medication (3)
            gen dm_cag_miss_hadmed = dcag11_3
            replace dm_cag_miss_hadmed = dcag11_3 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_hadmed "I still had medication (dcag113,hcag113)"
            *I did not want to go (4)
            gen dm_cag_miss_notwant = dcag11_4
            replace dm_cag_miss_notwant = dcag11_4 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_notwant "I did not want to go (dcag114,hcag114)"
            *I forgot (5)
            gen dm_cag_miss_forget = dcag11_5
            replace dm_cag_miss_forget = dcag11_5 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_forget "I forgot (dcag115,hcag115)"
            *I did not know about the meetings (6)
            gen dm_cag_miss_notknow = dcag11_6
            replace dm_cag_miss_notknow = dcag11_6 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_notknow "I did not know about the meetings (dcag116,hcag116)"
            *I knew no medication was available (7)
            gen dm_cag_miss_nomed = dcag11_7
            replace dm_cag_miss_nomed = dcag11_7 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_nomed "I knew no medication was available (dcag117,hcag117)"
            *Did not miss a meeting (8)
            gen dm_cag_miss_nomiss = dcag11_8
            replace dm_cag_miss_nomiss = dcag11_8 if co_cag12 == 1 // transer information from those with htn visiting CAG
            lab var dm_cag_miss_nomiss "Did not miss a meeting (dcag118,hcag118)"

            * label variables
            foreach v of varlist dm_cag_miss_* {
            lab val `v' yn01
            }

    ** Fast-track model
        * used fast-track model in past 12 months
            tab dft1,m
            replace dft1 = .d if dft1 == 77 // answer to dftc1 was DK
            replace dft1 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dft1 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
        * new FTC meeting in past 12 months variable
            gen dm_ft12 = (dft1==1) if dft1 < . // recode 2 to 0
            replace dm_ft12 = dft1 if dft1 >= . // transfer missing values
            replace dm_ft12 = 0 if inlist(dm_ft12, .d, .r) // DK and refused are recoded to "No"
            * different to htn history (e.g. ever diagnosed), we keep .s because the DSD models are only relevant
            * to those with hypertension. We also include .c and .q as .s
            lab var dm_ft12 "Used fast-track in past 12 months (dft1)"
            lab val dm_ft12 yn01
            tab dm_ft12,m
        * variable for those with diabetes and hypertension
            gen co_ft12 = .s
            replace co_ft12 = 0 if inlist(0, dm_ft12,h_ft12) & dm_ft12 < . & h_ft12 < . // both ftc are non-missing and at least one is 0
            replace co_ft12 = 1 if dm_ft12 == 1 & h_ft12 == 1 // visited FTC for both DM and HTN
            tab dm_ft12 h_ft12,m
            tab co_ft12,m
            lab var co_ft12 "Used fast-track in past 12 months (dm_ft12,h_ft12)"
            lab val co_ft12 yn01

        * number of times fast-track model used
            tab dft3,m
            replace dft3 = .s if inlist(2, hd1,hd2) // never measured nor diagnosed
            replace dft3 = .s if dft1 == 2 // did not use fast track
            replace dft3 = .s if inlist(.d, hd1,hd2) // answer to hd1, hd2 was DK --> DSD not relevant
            replace dft3 = .d if dft3 == 77 // answer to dft3 was DK
            replace dft3 = .c if dft1 == .d // answer to dft1 was DK
            replace dft3 = .s if co_ft12 == 1 // it was assumed that answers are the same if comorbid with HTN
            tab dft1 dft3,m
            * There are seven missings, which should not be missings. I can imagine that the interviewer
            * first entered "no" in dft1 and KOBO did not update. 
            replace dft3 = .m if dft3 == .
        * new number of fast-track meetings attended variable
            gen dm_ftatt = dft3
            replace dm_ftatt = h_ftatt if co_ft12 == 1
            lab var dm_ftatt "Number of times fast track was used in past 12 months (dft3,h_ftatt)"

    ** Community distribution points
        * went to CDP for BP care in past 12 months
            tab dcdp1,m
            replace dcdp1 = .d if dcdp1 == 77 // answer to dcdp1 was DK
            replace dcdp1 = .s if hd1 == 2 // BG was never measured
            replace dcdp1 = .s if hd1 == .d // answer to hd1 was DK
        * new visited CDP in past 12 months variable
            gen dm_cdp12 = (dcdp1==1) if dcdp1 < .
            replace dm_cdp12 = dcdp1 if dcdp1 >= . // transfer missing values
            replace dm_cdp12 = 0 if inlist(dm_cdp12, .d, .r) // DK and refused are recoded to "No"
            * different to diabetes history (e.g. ever diagnosed), we keep .s because the CDPs are only relevant
            * to those who ever had BG measured. We also include .c and .q as .s
            lab var dm_cdp12 "Attended CDP in past 12 months (dcdp1)"
            lab val dm_cdp12 yn01
            tab dcdp1 dm_cdp12,m
    
        * BG measured at CDP
            tab dcdp3,m
            replace dcdp3 = .s if hd1 == 2 // never measured
            replace dcdp3 = .s if dcdp1 == 2 // did not participate in CDP
            replace dcdp3 = .c if inlist(.d, dcdp1,hd1) // answer to dcdp1 or hd1 was DK
        * new measured BG at CDP variable
            gen dm_cdpms = (dcdp3==1) if dcdp3 < .
            replace dm_cdpms = dcdp3 if dcdp3 >= . // transfer missing values
            * different to diabetes history (e.g. ever diagnosed), we keep .s because the CDPs are only relevant
            * to those who ever had BG measured. We also include .c and .q as .s
            lab var dm_cdpms "Attended CDP in past 12 months (dcdp3)"
            lab val dm_cdpms yn01
            tab dcdp3 dm_cdpms,m

        * referrals received at CDP
            tab dcdp4, m
            replace dcdp4 = .s if hd1 == 2 // never measured
            replace dcdp4 = .s if dcdp1 == 2 // did not participate in CDP
            replace dcdp4 = .c if inlist(.d, dcdp1,hd1) // answer to hcdp1 or hbbp1 was DK
            foreach q in 1 2 3 77 99 {
                replace dcdp4`q' = dcdp4 if inlist(dcdp4, .s,.c,.q)
                rename dcdp4`q' dcdp4_`q'
            } 
        * new referral variables 
            gen dm_cdprefchk = dcdp4_1 // referred for treatment
            lab var dm_cdprefchk "Was referred for check-up (dcdp4_1)"
            lab val dm_cdprefchk yn01
            gen dm_cdpreftrt = dcdp4_2 // referred for treatment
            lab var dm_cdpreftrt "Was referred for treatment initiation (dcdp4_2)"
            lab val dm_cdpreftrt yn01
            gen dm_cdprefno = dcdp4_3 // referred for treatment
            lab var dm_cdprefno "Was not referred (dcdp4_3)"
            lab val dm_cdprefno yn01

        * number of times collecting medication from CDP
            tab dcdp6,m
            replace dcdp6 = .s if hd1 == 2 // never measured
            replace dcdp6 = .s if dcdp1 == 2 // did not participate in CDP
            replace dcdp6 = .c if inlist(.d, dcdp1,hd1) // answer to dcdp1 or hd1 was DK
        * new CDP treatment collection variable
            gen dm_cdpdrug = hcdp6
            lab var dm_cdpdrug "Number of times collected BG med from CDP (dcdp6)"


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx DIABETES - MEDICATION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * missing a dose in past 2 weeks
        tab cdm1,m
        replace cdm1 = .r if cdm1 == 88 // answer to cdm1 was DK
        replace cdm1 = .s if inlist(2, hd1,hd2) // never measured BG and never diagnosed
        replace cdm1 = .s if hd3 == 2 & hd4 == 2 // does not take BG medication
        replace cdm1 = .s if hd3 == .d & hd4 == 2 // does not take BG medication
        replace cdm1 = .c if inlist(.d, hd1,hd2) // answer to hd1 or hd2 was DK
        replace cdm1 = .q if inlist(.r, hd1,hd2) // answer to hd1 or hd2 was refused
        replace cdm1 = .q if hd3 == .r & hd4 == .r // answer to hd3 and hd4 was refused
    * new missed dose variable
        gen dm_adh2 = (cdm1==1) if cdm1 < . // recode 2 to 0
        replace dm_adh2 = cdm1 if cdm1 >= . // transfer missing values
        replace dm_adh2 = .s if inlist(dm_adh2, .c,.q) // Skipped if DK or Ref in previous question
        lab var dm_adh2 "Missed dose in past 2 weeks (cdm1)"
        lab val dm_adh2 yn01
        tab cdm1 dm_adh2,m


    * reason for missing a dose
        tab cdm2,m
        replace cdm2 = ".s" if inlist(2, cdm1,hd1,hd2) // never BG measured or diagnosed
        replace cdm2 = ".s" if hd3 == 2 & hd4 == 2 // does not take BG medication
        replace cdm2 = ".s" if hd3 == .d & hd4 == 2 // does not take BG medication
        replace cdm2 = ".c" if inlist(.d, cdm1,hd1,hd2) // answer to cdm1, hd1 or hd2 was DK
        replace cdm2 = ".q" if inlist(.r, cdm1,hd1,hd2) // answer to cdm1, hd1 or hd2 was refused
        replace cdm2 = ".q" if hd3 == .r & hd4 == .r // answer to hd3 and hd4 was refused

        forv q = 1/9 {
            replace cdm2`q' = .s if cdm2 == ".s"
            replace cdm2`q' = .c if cdm2 == ".c"
            replace cdm2`q' = .q if cdm2 == ".q"
            rename cdm2`q' cdm2_`q'
        } 
        replace cdm298 = .s if cdm2 == ".s"
        replace cdm298 = .c if cdm2 == ".c"
        replace cdm298 = .q if cdm2 == ".q"
        rename cdm298 cdm2_98

        br cdm2x if cdm2x != ""

    *Drugs were not available at all (1)
        gen dm_adh_avail = cdm2_1
        lab var dm_adh_avail "Drugs were not available at all (cdm21)" 
        lab val dm_adh_avail yn01
    *Drugs were available but not for free (2)
        gen dm_adh_availfr = cdm2_2
        lab var dm_adh_availfr "Drugs were available but not for free (cdm22)" 
        lab val dm_adh_availfr yn01

    *It is hard to remember all the doses / I forget taking them. (3)
        # delimit;
        foreach r in 
            "Participant had an ermegency to attend thus causing him to forget the taking the medication "
            "Sometimes Forgot " 
            "Busy with work " { ;
            
            replace cdm2_3 = 1 if cdm2x == "`r'" ; // include answer in binary variable
            replace cdm2_98 = 0 if cdm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace cdm2x = "" if cdm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen dm_adh_forgot = cdm2_3
        lab var dm_adh_forgot "It is hard to remember all the doses / I forget taking them (cdm23)" 
        lab val dm_adh_forgot yn01

    *It is hard to pay for this drug (4)
        gen dm_adh_pay = cdm2_4
        lab var dm_adh_pay "It is hard to pay for this drug (cdm24)" 
        lab val dm_adh_pay yn01

    *It is hard to get my refill on time (5)
        gen dm_adh_refill = cdm2_5
        lab var dm_adh_refill "It is hard to get my refill on time (cdm25)" 
        lab val dm_adh_refill yn01

    *I still get unwanted side effects from this drug (6)
        gen dm_adh_side = cdm2_6
        lab var dm_adh_side "I still get unwanted side effects from this drug (cdm26)" 
        lab val dm_adh_side yn01
        
    *I worry about the long term effects of this drug (7)
        gen dm_adh_long = cdm2_7
        lab var dm_adh_long "I worry about the long term effects of this drug (cdm27)" 
        lab val dm_adh_long yn01

    *This drug causes other concerns or problems (8)
        gen dm_adh_othprob = cdm2_8
        lab var dm_adh_othprob "This drug causes other concerns or problems (cdm28)" 
        lab val dm_adh_othprob yn01

    *I don't feel sick or I don't think I need a drug (9)
        gen dm_adh_fine = cdm2_9
        lab var dm_adh_fine "I don't feel sick or I don't think I need a drug (cdm29)" 
        lab val dm_adh_fine yn01
        

    * Mobility/Access (Infrastructure and physical constraints) (new)
        gen cdm2_10 = 0
        # delimit;
        foreach r in 
            "Ongoing Protests" { ;
            
            replace cdm2_10 = 1 if cdm2x == "`r'" ; // include answer in binary variable
            replace cdm2_98 = 0 if cdm2x == "`r'" ; // exclude answer from binary "other" variable 
            replace cdm2x = "" if cdm2x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen dm_adh_access = cdm2_10
        lab var dm_adh_access " Mobility/Access (Infrastructure and physical constraints) (cdm2x)" 
        lab val dm_adh_access yn01

    /*? could not be categorized
        No food to support the drug
        Out of the country
    */

    * times obtained hypertension medication in past 12 months
        tab cdm3,m
        replace cdm3 = .d if cdm3 == 77
        replace cdm3 = .r if cdm3 == 88
        replace cdm3 = .s if inlist(2, hd1,hd2) // never measured BG and never diagnosed 
        replace cdm3 = .s if hd3 == 2 & hd4 == 2 // does not take BG medication
        replace cdm3 = .s if hd3 == .d & hd4 == 2 // does not take BG medication
        replace cdm3 = .c if inlist(.d, hd1,hd2) // answer to hd1 or hd2 was DK
        replace cdm3 = .q if inlist(.r, hd1,hd2) // answer to hd1 or hd2 was refused
        replace cdm3 = .q if hd3 == .r & hd4 == .r // answer to hd3 and hd4 was refused
    * new obtained medication variable
        gen dm_obtmed12 = cdm3
        replace dm_obtmed12 = .s if inlist(cdm3, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var dm_obtmed12 "Times obtained diabetes medication in past 12 months (cdm3)"
        tab cdm3 dm_obtmed12, m

    * seen traditional healer for high BP
        tab cdm5,m
        replace cdm5 = .s if inlist(2, hd1,hd2) // never measured BG and never diagnosed 
        replace cdm5 = .c if inlist(.d, hd1,hd2) // answer to hd1 or hd2 was DK
        replace cdm5 = .m if version == "v1" & cdm5 == . // the skip pattern was changed so that it would also be asked to people currently not taking meds.
    * new traditional healer visit variable
        gen dm_trv = (cdm5 == 1) if cdm5 < . // recode 2 to 0
        replace dm_trv = cdm5 if cdm5 >= . // transfer missings
        replace dm_trv = .s if inlist(cdm5, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var dm_trv "Ever visited traditional healer (cdm5)"
        lab val dm_trv yn01
        tab cdm5 dm_trv,m

    * seen traditional healer for high BP
        tab cdm6,m
        replace cdm6 = .s if inlist(2, hd1,hd2) 
        replace cdm6 = .c if inlist(.d, hd1,hd2) // answer to hd1 or hd2 was DK
        replace cdm6 = .m if version == "v1" & cdm6 == . // the skip pattern was changed so that it would also be asked to people currently not taking meds.
    * new traditional medicine variable
        gen dm_trmed = (cdm6 == 1) if cdm6 < . // recode 2 to 0
        replace dm_trmed = cdm6 if cdm6 >= . // transfer missings
        replace dm_trmed = .s if inlist(cdm6, .c,.q) // if previous questions were DK or refused, this question is not relevant
        lab var dm_trmed "Currently takes herbal/traditional medicine (cdm6)"
        lab val dm_trmed yn01
        tab cdm6 dm_trmed,m


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx HEART ATTACK xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * had a heart attack in past 12 months
        tab ha2,m
        replace ha2 = .d if ha2 == 77
    * new heart attack variable
        gen ha = (ha2==1) if ha2 < . // recode 2 to 0
        replace ha = ha2 if ha2 >= . // transfer missings
        lab var ha "Heart attack/stroke in past 12 months (ha2)"
        lab val ha yn01
    *! I wouldn't use this variable. The prevalence is incredibly high in particular
    *! at the start of the survey.
        tab version ha,m row


*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx RURAL HEALTH MOTIVATOR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * visit by RHM in past 12 months
        tab rhm2n,m
        replace rhm2n = .d if rhm2n == 77
        replace rhm2n = .r if rhm2n == 88
        * there are 12 missings of which I don't know how they happened
        replace rhm2n = .m if rhm2n == .
    * new RHM visit in past 12 months variable
        gen RHM12 = (rhm2n==1) if rhm2n < .  // recode 2 to 0
        replace RHM12 = rhm2n if rhm2n >= . // transfer missings
        replace RHM12 = 0 if inlist(rhm2n, .d,.r) // DK and refused are recoded to "no"
        lab val RHM12 yn01
        lab var RHM12 "Was visited by RHM in past 12 months (rhm2n)"
        tab RHM12,m

        * services received by RHM
        tab rhm4,m
        replace rhm4 = ".s" if rhm2n == 2 // no RHM visit in past 12 months
        replace rhm4 = ".c" if rhm2n == .d // answer to rhm2n was DK
        replace rhm4 = ".q" if rhm2n == .r // answer to rhm2n was refused
        replace rhm4 = ".m" if rhm2n == .m  // answer to rhm2n was somehow missing

        * transfer missing values to binary variables
        forv q = 1/18 {
            replace rhm4`q' = .s if rhm4 == ".s"
            replace rhm4`q' = .c if rhm4 == ".c"
            replace rhm4`q' = .q if rhm4 == ".q"
            replace rhm4`q' = .m if rhm4 == ".m"
            rename rhm4`q' rhm4_`q'
        } 
        replace rhm498 = .s if rhm4 == ".s"
        replace rhm498 = .c if rhm4 == ".c"
        replace rhm498 = .q if rhm4 == ".q"
        replace rhm498 = .m if rhm4 == ".m"

        rename rhm498 rhm4_98

        br rhm4x if rhm4x != ""

        *Advice on how to eat healthy (1)
        # delimit;
        foreach r in 
            "Health education on diet to hypertension patient "
            "Health education on diet" { ;
            
            replace rhm4_1 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen RHM_serv_diet = rhm4_1
        lab var RHM_serv_diet "Advice on how to eat healthy (rhm41)" 
        lab val RHM_serv_diet yn01
           
        *Information on immunizations for children (2)
        gen RHM_serv_immun = rhm4_2
        lab var RHM_serv_immun "Information on immunizations for children (rhm42)" 
        lab val RHM_serv_immun yn01

        *Information and advice on feeding of babies (3)
        gen RHM_serv_feed = rhm4_3
        lab var RHM_serv_feed "Information and advice on feeding of babies (rhm43)" 
        lab val RHM_serv_feed yn01

        *Information on pregnancy and childbirth (4)
        gen RHM_serv_anc = rhm4_4
        lab var RHM_serv_anc "Information on pregnancy and childbirth (rhm44)" 
        lab val RHM_serv_anc yn01

        *Checking if a pregnancy is going well (5)
        gen RHM_serv_preg = rhm4_5
        lab var RHM_serv_preg "Checking if a pregnancy is going well (rhm45)" 
        lab val RHM_serv_preg yn01

        *Advice or help with sanitation, such as toilets (6)
        # delimit;
        foreach r in 
            "Cleaning toilets"
            "Hygiene "
            "Good sanitary practices "
            "waste management and disposal "
            "waste disposal and management "
            "personal hygiene "
            "Hygiene" { ;
            
            replace rhm4_6 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen RHM_serv_wash = rhm4_6
        lab var RHM_serv_wash "Advice or help with sanitation, such as toilets (rhm46)" 
        lab val RHM_serv_wash yn01

        *Referral to a healthcare facility when I was ill (7)
        gen RHM_serv_rill = rhm4_7
        lab var RHM_serv_rill "Referral to a healthcare facility when I was ill (rhm47)" 
        lab val RHM_serv_rill yn01

        *Care at home when I was ill (8)
        gen RHM_serv_care = rhm4_8
        lab var RHM_serv_care "Care at home when I was ill (rhm48)" 
        lab val RHM_serv_care yn01

        *Observing me taking my medication (9)
        gen RHM_serv_med = rhm4_9
        lab var RHM_serv_med "Observing me taking my medication (rhm49)" 
        lab val RHM_serv_med yn01

        *Information on family planning (10)
        gen RHM_serv_fp = rhm4_10
        lab var RHM_serv_fp "Information on family planning (rhm410)" 
        lab val RHM_serv_fp yn01

        *Screening for tuberculosis (11)
        gen RHM_serv_tb = rhm4_11
        lab var RHM_serv_tb "Screening for tuberculosis (rhm411)" 
        lab val RHM_serv_tb yn01

        *Advice on high blood pressure (hypertension) (12)
        gen RHM_serv_bp = rhm4_12
        lab var RHM_serv_bp "Advice on high blood pressure (rhm412)" 
        lab val RHM_serv_bp yn01

        *Advice on high blood glucose (diabetes) (13)
        gen RHM_serv_dm = rhm4_13
        lab var RHM_serv_dm "Advice on high blood glucose (rhm413)" 
        lab val RHM_serv_dm yn01

        *Advice on quitting tobacco use (14)
        gen RHM_serv_tob = rhm4_14
        lab var RHM_serv_tob "Advice on quitting tobacco use (rhm414)" 
        lab val RHM_serv_tob yn01

        *Advice on reducing/quitting alcohol consumption (15)
        gen RHM_serv_alc = rhm4_15
        lab var RHM_serv_alc "Advice on reducing/quitting alcohol consumption (rhm415)" 
        lab val RHM_serv_alc yn01

        *Advice on physical activity (16)
        gen RHM_serv_pa = rhm4_16
        lab var RHM_serv_pa "Advice on physical activity (rhm416)" 
        lab val RHM_serv_pa yn01

        *Referral to a healthcare facility for a health check up (17)
        # delimit;
        foreach r in 
            "Advice on routine checkup"
            "Advice to get checked regularly " { ;
            
            replace rhm4_17 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr
    
        gen RHM_serv_rcheck = rhm4_17
        lab var RHM_serv_rcheck "Referral to a healthcare facility for a health check up (rhm417)" 
        lab val RHM_serv_rcheck yn01

        *Screening for diabetes or hypertension (18)
        gen RHM_serv_scdmh = rhm4_18
        lab var RHM_serv_scdmh "Screening for diabetes or hypertension (rhm418)" 
        lab val RHM_serv_scdmh yn01

        * Gave medication/ other medical supplies (new)
        gen rhm4_19 = 0
        lab var rhm4_19 "Gave medication/ other medical supplies (rhm4x)" 
        lab val rhm4_19 yn01

        # delimit;
        foreach r in 
            "Gave pain medication "
            "Gave paracetamol for headache relief"
            "Drug supply and bandages"
            "Bringing supplies "
             { ;
            
            replace rhm4_19 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_serv_supp = rhm4_19
        lab var RHM_serv_supp "Gave medication/ other medical supplies (rhm4x)" 
        lab val RHM_serv_supp yn01

        * Advice on Covid-19 (new)
        gen rhm4_20 = 0
        lab var rhm4_20 "Advice on Covid-19 (rhm4x)" 
        lab val rhm4_20 yn01

        # delimit;
        foreach r in 
            "Health education on Covid 19"
            "Information about covid 19"
            "Advise on covid-19"
            "Covid information "
            "Covid"
             { ;
            
            replace rhm4_20 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_serv_covid = rhm4_20
        lab var RHM_serv_covid "Advice on Covid-19 (rhm4x)" 
        lab val RHM_serv_covid yn01

        * Updates on community activities (new)
        gen rhm4_21 = 0
        lab var rhm4_21 "Updates on community activities (rhm4x)" 
        lab val rhm4_21 yn01
        # delimit;
        foreach r in 
            "Update on community activities "
            "Community health events"
            "Notify upcoming events/meetings "
            "Registration of community members "
             { ;
            
            replace rhm4_21 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_serv_comm = rhm4_21
        lab var RHM_serv_comm "Updates on community activities (rhm4x)" 
        lab val RHM_serv_comm yn01

        * Talked about the study (new)
        gen rhm4_22 = 0
        lab var rhm4_22 "Talked about the study (rhm4x)" 
        lab val rhm4_22 yn01
        # delimit;
        foreach r in 
            "Talked-about the study "
            "About the survey "
            "Talked about the study "
            "Talked about the survey "
            "About the study "
            "Talked-about the survey "
            "Telling me of WHO-PEN Survey " { ;
            
            replace rhm4_22 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_serv_study = rhm4_22
        lab var RHM_serv_study "Talked about the study (rhm4x)" 
        lab val RHM_serv_study yn01

        * Checking general health status (new)
        gen rhm4_23 = 0
        lab var rhm4_23 "Checking general health status (rhm4x)" 
        lab val rhm4_23 yn01
        # delimit;
        foreach r in 
            "Asking about general health status "
            "Health education on knowing Health status "
            "Checking my wellbeing "
            "I was not at home but she came to talk with my family about health issues"
            "Routine check "
            "Just checking in "
            "Just checking up on the family " { ;
            
            replace rhm4_23 = 1 if rhm4x == "`r'" ; // include answer in binary variable
            replace rhm4_98 = 0 if rhm4x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm4x = "" if rhm4x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_serv_gen = rhm4_23
        lab var RHM_serv_gen "Talked about the study (rhm4x)" 
        lab val RHM_serv_gen yn01

        /*? could not be categorized
            Adhering to ART
            Cancer Screening
            Cancer screening
            Personal message
            Checking on a sick family,member
            checked if I had enough medication
            To check on her disable grandchild
            To register a disabled child
            Nothing else she does apart from exchanging pleasantries
        */

    * RHM referral
        tab rhm8,m
        replace rhm8 = .d if rhm8 == 77
        replace rhm8 = .r if rhm8 == 88
        replace rhm8 = .s if rhm2n == 2 // no visit by RHM in past 12 months
        replace rhm8 = .s if inlist(1, rhm4_7, rhm4_17) // indicated referral in previous question
        replace rhm8 = .c if rhm2n == .d // answer to rhm2n was DK
        replace rhm8 = .q if rhm2n == .r // answer to rhm2n was refused
        replace rhm8 = .m if rhm2n == .m  // answer to rhm2n was somehow missing
        tab rhm8,m
        * new general referral variable
        gen RHM_refgen = (rhm8==1) if rhm8 < . // recode 2 to 0
        replace RHM_refgen = rhm8 if rhm8 >= . // transfer missings
        replace RHM_refgen = 0 if inlist(rhm8, .d,.r) // refused and DK are recoded to 0
        lab val RHM_refgen yn01
        lab var RHM_refgen "Was referred by RHM (rhm8)"
        tab rhm8 RHM_refgen,m

    * Reason for RHM referral
        * was asked to those who indicated "yes" in rhm8
        tab rhm10,m
        replace rhm10 = ".s" if inlist(2, rhm2n,rhm8) // no visit by RHM or referral in past 12 months 
        replace rhm10 = ".s" if inlist(1, rhm4_7, rhm4_17) // indicated referral in previous question
        replace rhm10 = ".c" if inlist(.d, rhm2n,rhm8) // answer to rhm2n or rhm8  was DK
        replace rhm10 = ".q" if inlist(.r, rhm2n,rhm8) // answer to rhm2n or rhm8  was refused
        replace rhm10 = ".m" if rhm2n == .m  // answer to rhm2n was somehow missing

        forv q = 1/11 {
            replace rhm10`q' = .s if rhm10 == ".s"
            replace rhm10`q' = .c if rhm10 == ".c"
            replace rhm10`q' = .q if rhm10 == ".q"
            rename rhm10`q' rhm10_`q'
        } 
        replace rhm1098 = .s if rhm10 == ".s"
        replace rhm1098 = .c if rhm10 == ".c"
        replace rhm1098 = .q if rhm10 == ".q"
        rename rhm1098 rhm10_98

        tab rhm10x,m

        *Overweight / high BMI (1)
        gen RHM_ref_bmi = rhm10_1
        lab var RHM_ref_bmi "Overweight / high BMI (rhm101)" 
        lab val RHM_ref_bmi yn01

        *Symptoms of high blood sugar (2)
        gen RHM_ref_sdm = rhm10_2
        lab var RHM_ref_sdm "Symptoms of high blood sugar (rhm102)" 
        lab val RHM_ref_sdm yn01

        *Symptoms of high blood pressure (3)
        gen RHM_ref_sh = rhm10_3
        lab var RHM_ref_sh "Symptoms of high blood pressureI (rhm103)" 
        lab val RHM_ref_sh yn01

        *Symptoms of HIV (4)
        gen RHM_ref_shiv = rhm10_4
        lab var RHM_ref_shiv "Symptoms of HIV (rhm104)" 
        lab val RHM_ref_shiv yn01

        *Symptoms of other disease (5)
        # delimit;
        foreach r in 
            "Covid 19 injection side effects "
            "headache "
            "stomach disorders and vomiting " { ;
            
            replace rhm10_5 = 1 if rhm10x == "`r'" ; // include answer in binary variable
            replace rhm10_98 = 0 if rhm10x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm10x = "" if rhm10x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_ref_soth = rhm10_5
        lab var RHM_ref_soth "Symptoms of other disease (rhm105)" 
        lab val RHM_ref_soth yn01

        *Injury (6)
        gen RHM_ref_inj = rhm10_6
        lab var RHM_ref_inj "Injury (rhm106)" 
        lab val RHM_ref_inj yn01

        *Treatment adherence / follow up (high BP) (7)
        gen RHM_ref_fuh = rhm10_7
        lab var RHM_ref_fuh "Treatment adherence / follow up (high BP) (rhm107)" 
        lab val RHM_ref_fuh yn01

        *Treatment adherence / follow up (diabetes) (8)
        gen RHM_ref_fudm = rhm10_8
        lab var RHM_ref_fudm "Treatment adherence / follow up (diabetes) (rhm108)" 
        lab val RHM_ref_fudm yn01

        *Treatment adherence / follow up (HIV) (9)
        gen RHM_ref_fuhiv = rhm10_9
        lab var RHM_ref_fuhiv "Treatment adherence / follow up (rhm109)" 
        lab val RHM_ref_fuhiv yn01

        *Treatment adherence / follow up (other disease) (10)
        # delimit;
        foreach r in 
            "Asthma "
            "Adherence on TB medication "
            "physiotherapy session " { ;
            
            replace rhm10_10 = 1 if rhm10x == "`r'" ; // include answer in binary variable
            replace rhm10_98 = 0 if rhm10x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm10x = "" if rhm10x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_ref_fuoth = rhm10_10
        lab var RHM_ref_fuoth "Treatment adherence / follow up (other disease) (rhm1010)" 
        lab val RHM_ref_fuoth yn01

        *Routine check up (11)
        # delimit;
        foreach r in 
        "Medical check up"
        "Cancer screening"
        "Highly stressed"
        "Health education " { ;
            
            replace rhm10_11 = 1 if rhm10x == "`r'" ; // include answer in binary variable
            replace rhm10_98 = 0 if rhm10x == "`r'" ; // exclude answer from binary "other" variable 
            replace rhm10x = "" if rhm10x == "`r'" ; // remove text answer from "specify" variable
        } ;
        #delimit cr

        gen RHM_ref_check = rhm10_11
        lab var RHM_ref_check "Overweight / high BMI (rhm1011)" 
        lab val RHM_ref_check yn01


    * ever referred for diabetes/htn
        * was asked to everyone who did not answer rhm10
        tab rhm11,m
        replace rhm11 = .d if rhm11 == 77 
        replace rhm11 = .s if rhm2n == 2 // no visit by RHM in past 12 months
        replace rhm11 = .s if inlist(1, rhm10_2,rhm10_3,rhm10_7,rhm10_8)
        replace rhm11 = .c if rhm2n == .d // answer to rhm2n was DK
        replace rhm11 = .q if rhm2n == .r // answer to rhm2n was refused
        replace rhm11 = .m if rhm2n == .m  // answer to rhm2n was somehow missing
    * new ever referred for diabetes hypertension variable
        gen RHM_ref_dmh = (rhm11==1) if rhm11 < . // recode 2 to 0
        replace RHM_ref_dmh = rhm11 if rhm11 >= . // transfer missings
        replace RHM_ref_dmh = 0 if rhm11 == .d // DK is recoded to 0
        lab val RHM_ref_dmh yn01
        lab var RHM_ref_dmh "Referred for diabetes or hypertension (rhm11)"
        tab rhm11 RHM_ref_dmh,m

    * referred for diabetes/htn based on first two questions
        gen RHM_ref_dmh2 = .
        replace RHM_ref_dmh2 = 0 if inlist(0, RHM_ref_sh,RHM_ref_sdm,RHM_ref_fuh,RHM_ref_fudm,RHM_ref_dmh) // has a valid answer in any of the referral variables
        replace RHM_ref_dmh2 = 1 if inlist(1, RHM_ref_sh,RHM_ref_sdm,RHM_ref_fuh,RHM_ref_fudm,RHM_ref_dmh) // hanswered "yes" to any of the referral variables
        replace RHM_ref_dmh2 = .s if rhm2n == 2 // no visit by RHM in past 12 months
        replace RHM_ref_dmh2 = .c if rhm2n == .d // answer to rhm2n was DK
        replace RHM_ref_dmh2 = .q if rhm2n == .r // answer to rhm2n was refused
        replace RHM_ref_dmh2 = .m if rhm2n == .m  // answer to rhm2n was somehow missing
        lab val RHM_ref_dmh2 yn01
        lab var RHM_ref_dmh2 "Referred for diabetes or hypertension (RHM_ref_sh,RHM_ref_sdm,RHM_ref_fuh,RHM_ref_fudm,RHM_ref_dmh)"

        tab RHM_ref_dmh2,m
        tab RHM_ref_dmh2
        

    * date of last referral
    *!! clean this once it is clear what it is needed for. 
        tab rhm9m,m
        tab rhm9y,m
        tab rhm9ys,m
        tab rhm9ms,m
        tab rhm9ws,m

    * participant complied with referral
        tab rhm12,m
        replace rhm12 = .d if rhm12 == 77 // answer to rhm12 was DK
        replace rhm12 = .s if rhm2n == 2 // no visit by RHM in past 12 months
        replace rhm12 = .s if rhm11 == 2 // was not refered for diabetes or htn
        replace rhm12 = .s if RHM_ref_dmh2 == 0 // was not refered for diabetes or htn
        replace rhm12 = .c if rhm2n == .d // answer to rhm2n was DK
        replace rhm12 = .q if rhm2n == .r // answer to rhm2n was refused
        replace rhm12 = .m if rhm2n == .m  // answer to rhm2n was somehow missing
    * new compliance with referral variable
        gen RHM_compl = (rhm12==1) if rhm12 < . // recode 2 to 0
        replace RHM_compl = rhm12 if rhm12 >= . // transfer missings
        replace RHM_compl = 0 if rhm12 == .d // convert DK to "no"
        lab val RHM_compl yn01
        lab var RHM_compl "client visited facility after referral (rhm12)"

        * reason for not complying with referral
        tab rhm13,m
        replace rhm13 = ".s" if rhm12 == 1 // complied with referral 
        replace rhm13 = ".s" if rhm2n == 2 // no visit by RHM in past 12 months
        replace rhm13 = ".s" if rhm11 == 2 // was not refered for diabetes or htn
        replace rhm13 = ".s" if RHM_ref_dmh2 == 0 // was not refered for diabetes or htn
        replace rhm13 = ".c" if inlist(.d, rhm2n,rhm12) // answer to rhm12 was DK
        replace rhm13 = ".q" if rhm2n == .r // answer to rhm2n was refused
        replace rhm13 = ".m" if rhm2n == .m  // answer to rhm2n was somehow missing
        replace rhm13 = ".r" if rhm13x == "Do not want to disclose"
        replace rhm13x = "" if rhm13x == "Do not want to disclose"


        br rhm13x if rhm13x != ""

        foreach q in 1 2 3 4 5 6 7 8 9 10 11 13 14 {
            replace rhm13`q' = .s if rhm13 == ".s"
            replace rhm13`q' = .c if rhm13 == ".c"
            replace rhm13`q' = .q if rhm13 == ".q"
            replace rhm13`q' = .m if rhm13 == ".m"
            replace rhm13`q' = .r if rhm13 == ".r"
            rename rhm13`q' rhm13_`q'
        } 
        replace rhm1398 = .s if rhm13 == ".s"
        replace rhm1398 = .c if rhm13 == ".c"
        replace rhm1398 = .q if rhm13 == ".q"
        replace rhm1398 = .m if rhm13 == ".m"
        replace rhm1398 = .r if rhm13 == ".r"
        rename rhm1398 rhm13_98


        *Need to work (1)
            gen RHM_ncompl_work = rhm13_1
            lab var RHM_ncompl_work "Had to work (rhm131)" 
            lab val RHM_ncompl_work yn01

        *Needed to take care of family members (2)
            gen RHM_ncompl_care = rhm13_2
            lab var RHM_ncompl_care "Needed to take care of family members (rhm132)" 
            lab val RHM_ncompl_care yn01

        *Too far away from home (3)
            gen RHM_ncompl_home = rhm13_3
            lab var RHM_ncompl_home "Too far away from home (rhm133)" 
            lab val RHM_ncompl_home yn01

        *No money to pay for transport (4)
            gen RHM_ncompl_trans = rhm13_4
            lab var RHM_ncompl_trans "No money to pay for transport (rhm134)" 
            lab val RHM_ncompl_trans yn01

        *No money to pay for health care services (5)
            gen RHM_ncompl_payserv = rhm13_5
            lab var RHM_ncompl_payserv "No money to pay for health care services (rhm135)" 
            lab val RHM_ncompl_payserv yn01

        *Waiting times are too long (6)
            gen RHM_ncompl_wait = rhm13_6
            lab var RHM_ncompl_wait "Waiting times are too long (rhm136)" 
            lab val RHM_ncompl_wait yn01

        *Low quality of services (7)
            gen RHM_ncompl_quality = rhm13_7
            lab var RHM_ncompl_quality "Low quality of services (rhm137)" 
            lab val RHM_ncompl_quality yn01

        *Bad treatment by health care workers (8)
            gen RHM_ncompl_bad = rhm13_8
            lab var RHM_ncompl_bad "Bad treatment by health care workers (rhm138)" 
            lab val RHM_ncompl_bad yn01

        *Feeling uncomfortable during consultation  (9)
            gen RHM_ncompl_uncom = rhm13_9
            lab var RHM_ncompl_uncom "Feeling uncomfortable during consultation (rhm139)" 
            lab val RHM_ncompl_uncom yn01

        *No need to go because I felt good (10)
            gen RHM_ncompl_feel = rhm13_10
            lab var RHM_ncompl_feel "No need to go because I felt good (rhm1310)" 
            lab val RHM_ncompl_feel yn01

        *I forgot about it (11)
            gen RHM_ncompl_forgot = rhm13_11
            lab var RHM_ncompl_forgot "I forgot about it (rhm1311)" 
            lab val RHM_ncompl_forgot yn01

        *I went to a traditional healer instead (13)
            gen RHM_ncompl_nothelp = rhm13_13
            lab var RHM_ncompl_nothelp "I went to a traditional healer instead (rhm1313)" 
            lab val RHM_ncompl_nothelp yn01

        *There are no drugs available at the facility (14)
            gen RHM_ncompl_healer = rhm13_14
            lab var RHM_ncompl_healer "There are no drugs available at the facility (rhm1314)" 
            lab val RHM_ncompl_healer yn01

        * phyiscally unable / constrained physical mobility (new)
            gen rhm13_15 = 0
            lab var rhm13_15 "Phyiscally unable / constrained physical mobility (rhm13x)"
            lab val rhm13_15 yn01

            # delimit;
            foreach r in 
                "I got ill"
                "Physically unable"
                "Not physically able "
                "I can't move I am crippled "
                "Can't walk " {;
                
                replace rhm13_15 = 1 if rhm13x == "`r'" ; // include answer in binary variable
                replace rhm13_98 = 0 if rhm13x == "`r'" ; // exclude answer from binary "other" variable 
                replace rhm13x = "" if rhm13x == "`r'" ; // remove text answer from "specify" variable
            } ;
            #delimit cr

            gen RHM_ncompl_unable = rhm13_15
            lab var RHM_ncompl_unable "Phyiscally unable / constrained physical mobility (rhm13x)" 
            lab val RHM_ncompl_unable yn01

        /*? could not be categorized
            She'll go when she makes a follow up for her HIV treatment this month.
            There's no reason
            I hate ingesting lots of pills
            I was waiting for WHO-Survey as she told me about it
            I am not on treatment
            Treatment made illnesses worse
            My wife checks my vitals at home
            Was waiting for my 3 month refill then I go check what RHM advised me to do
        */

        drop READ_I_would_now_l_es_can_be_ide rhm9_When_was_the_l_ssure_hypert OS OT READ_In_this_secti_ilities_like_

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx KNOWLEDGE xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
        * general htn and diabetes
        tab ta1,m
        tab ta2,m
        tab ta3,m
        tab ta4,m
        tab ta5,m
        tab ta6,m
        tab ta7,m
        tab ta8,m
        tab ta9,m

        * hypoclyaemic shock
        tab ta18a,m
        tab ta18b,m
        tab ta18c,m
        tab ta18a hd2,m

        foreach q in a b c {
            replace ta18`q' = .s if inlist(hd2, 2,.s)
            replace ta18`q' = .s if hd2 == .d
        }

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx BEHAVIOURAL MEASUREMENTS xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * current smoking
        tab bm1,m
        replace bm1 = .r if bm1 == 88
    * new current smoking variable
        gen csmoke = .
        replace csmoke = 0 if bm1 == 3 // no smoking
        replace csmoke = 1 if bm1 == 2 // occasional smoking
        replace csmoke = 2 if bm1 == 1 // daily smoking
        replace csmoke = .r if bm1 == .r
        lab var csmoke "Current smoking (bm1)"
        lab def csmk 0 "Non-smoker" 1 "Occasional smoker" 2 "Daily smoker"
        lab val csmoke csmk
        tab csmoke,m

    * past smoking
        tab bm3,m
        replace bm3 = .r if bm3 == 88 // answer to bm3 was refused
        replace bm3 = .s if inlist(bm1, 1,2) // current smoker
        replace bm3 = .q if bm1 == .r // answer to bm1 was refused
    * new past smoking variable
        gen psmoke = .
        replace psmoke = 0 if bm3 == 3 // never smoker
        replace psmoke = 1 if bm3 == 2 // past occasional smoker
        replace psmoke = 2 if bm3 == 1 // past daily smoker
        replace psmoke = bm3 if bm3 >= .
        lab var psmoke "Past smoking (bm3)"
        lab def psmk 0 "Never-smoker" 1 "Past occasional smoker" 2 "Past daily smoker"
        lab val psmoke psmk
        tab psmoke,m

    * Quit in past 12 months
        tab bm4n,m
        replace bm4n = .s if inlist(bm1, 1,2) | bm3 == 3 // current smoker or never smoker
        replace bm4n = .q if inlist(.r,bm1,bm3) // answer to bm1 or bm3 was refused
    * new quit in past months variable
        gen qsmoke12 = (bm4n==1) if bm4n < . // recode 2 to 0
        replace qsmoke12 = bm4n if bm4n >= . // transfer missings
        lab var qsmoke12 "Quit smoking in past 12 months (bm4n)"
        lab val qsmoke12 yn01
        tab qsmoke12,m

    * vigorous activity - days
        tab bm6,m
        replace bm6 = .d if bm6 == 77

    * vigorous activity - hours and minutes
        tab bm7h,m
        tab bm7m,m
        
        * hours
        replace bm7h = .s if bm6 == 0 // did no vig. activitiy
        replace bm7h = .d if bm7m == 77 // answer to time spent was DK
        replace bm7h = .c if bm6 == .d // answer to days was DK
        * minutes
        replace bm7m = .s if bm6 == 0 // did no vig. activitiy
        replace bm7m = .d if bm7m == 77 // answer to time spent was DK
        replace bm7m = .c if bm6 == .d // answer to days was DK

        * vigorous activitiy per week
        gen vig_wk = ((bm7h*60) + bm7m) * bm6
        replace vig_wk = 0 if bm6 == 0 // did not vig. activity
        replace vig_wk = .d if bm7m == .d // answer to time was DK
        replace vig_wk = .c if bm6 == .d // answer to days was DK
        tab vig_wk,m
        lab var vig_wk "Vigorous activity per week (minutes) (bm6, bm7*)"

    * moderate activity - days
        tab bm8,m
        replace bm8 = .d if bm8 == 77

        * moderate activity - hours and minutes
        tab bm9h,m
        tab bm9m,m
        * hours
        replace bm9h = .s if bm8 == 0 // did no mod. activitiy
        replace bm9h = .d if inlist(77, bm9h,bm9m) // answer to time spent was DK
        replace bm9h = .c if bm8 == .d // answer to days was DK
        * minutes
        replace bm9m = .s if bm8 == 0 // did no mod. activitiy
        replace bm9m = .d if inlist(77, bm9h,bm9m) // answer to time spent was DK
        replace bm9m = .c if bm8 == .d // answer to days was DK

        * moderate activitiy per week
        gen mod_wk = ((bm9h*60) + bm9m) * bm8
        replace mod_wk = 0 if bm8 == 0 // did not mod. activity
        replace mod_wk = .d if bm9m == .d
        replace mod_wk = .c if bm8 == .d // answer to days was DK
        tab mod_wk,m
        lab var mod_wk "Moderate activity per week (minutes) (bm8, bm9*)"

    * walking - days
        tab bm10,m
        replace bm10 = .d if bm10 == 77

        * walking - hours and minutes
        tab bm11h,m
        tab bm11m,m
        
        * hours
        replace bm11h = .s if bm10 == 0 // did not walk
        replace bm11h = .d if inlist(77, bm11h,bm11m) // answer to time spent was DK
        replace bm11h = .c if bm10 == .d // answer to days was DK
        * minutes
        replace bm11m = .s if bm10 == 0 // did not walk
        replace bm11m = .d if inlist(77, bm11h,bm11m) // answer to time spent was DK
        replace bm11m = .c if bm10 == .d // answer to days was DK

        * walking per week
        gen walk_wk = ((bm11h*60) + bm11m) * bm10
        replace walk_wk = 0 if bm10 == 0 // did not walk
        replace walk_wk = .d if bm11m == .d
        replace walk_wk = .c if bm10 == .d // answer to days was DK
        tab walk_wk,m
        lab var walk_wk "Walking per week (minutes) (bm10, bm11*)"
    
    * sitting on a typcical day
        tab bm12h,m
        tab bm12m,m
        replace bm12h = .d if inlist(77, bm12h,bm12m)
        replace bm12m = .d if inlist(77, bm12h,bm12m)
        
        * sitting per day
        gen sit_day = (bm12h*60) + bm12m
        replace sit_day = .d if bm12m == .d
        tab sit_day,m
        lab var sit_day "Sitting per day (minutes) (bm12*)"

    * alcohol use in past 12 months
        tab bm18,m
        replace bm18 = .d if bm18 == 77
        replace bm18 = .r if bm18 == 88
    * new alcohol past 12 month variable
        gen alc12 = (bm18==1) if bm18 < . // recode 2 to 0
        replace alc12 = bm18 if bm18 >= . // transfer missings
        lab var alc12 "Drank alcohol in past 12 months (bm18)"
        lab val alc12 yn01

    * frequency of using alcohol in past 12 months
        tab bm20,m
        replace bm20 = .s if bm18 == 2
        replace bm20 = .q if bm18 == .r
        replace bm20 = .c if bm18 == .d
    * new alcohol use frequency variable
        gen alcfreq = .
        replace alcfreq = 0 if bm20 == 7 // never
        replace alcfreq = 1 if bm20 == 6 // < 1 per month
        replace alcfreq = 2 if bm20 == 5 // 1-3 days per month
        replace alcfreq = 3 if bm20 == 4 // 1-2 days per week
        replace alcfreq = 4 if bm20 == 3 // 3-4 days per week
        replace alcfreq = 5 if bm20 == 2 // 5-6 days per week
        replace alcfreq = 6 if bm20 == 1 // daily
        replace alcfreq = bm20 if bm20 >= . // transfer missings
        lab var alcfreq "Frequency of drinking alcohol in past 12 months (bm20)"
        lab def afreq 0 "Never" 1 "< 1 day/month" 2 "1-3 days/month" 3 "1-2 days/week" 4 "3-4 days/week" 5 "5-6 days/week" 6 "Daily"
        lab val alcfreq afreq
        tab alcfreq,m

        drop READ_We_are_interes_10_minutes_a bm7_How_much_time_d_on_one_of_th vigzero You_have_to_enter_mo_of_vigorous ///
            READ_Think_about_a_10_minutes_at You_have_to_enter_mo_of_moderate READ_Think_about_t_exercise_or_l ///
            bm11_How_much_time_on_one_of_tho walkzero You_have_to_enter_mo_0_minutes_o READ_The_last_ques_to_watch_tele ///
            bm12_How_much_time_ing_on_a_typi sitzero ZD READ_Now_I_would_l_or_nearly_eve modzero bm9_How_much_time_d_on_one_of_th ///
            ta18 READ_ta18_If_you_u_should_immedi READ_Now_I_will_re_ink_could_be_

*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx GENERAL ANXIETY AND DEPRESSEION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * guide for cleaning and interpretation: https://www.hiv.uw.edu/page/mental-health-screening/gad-2
    * ga1 and ga2 are fraom GAD-2; ga3-ga11 are from PHQ-9
        forv q = 1/11 {
            tab ga`q',m
            replace ga`q' = .r if ga`q' == 88 // answer was refused
        }

    * generate new variables that are coded 0-3 rather than 1-4
        lab def ga 0 "Never or one day (no days or 1 day)" 1 "Several days (2 to 6 days)" ///
            2 "More than half the days (7 to 11 days)" 3 "Nearly every day (12 to 14 days"

        forv q = 1/11 {
            gen ga04_`q' = ga`q'-1 // subtract 1 from each value to arrive at 0-3 scale
            replace  ga04_`q' = .r if  ga`q' == .r
            lab var ga04_`q' "GA-2 coding or ga04_`q'"
            lab val ga04_`q' ga
        }

    * GAD-2
    /* A score of 3 points is the preferred cut-off for identifying possible cases 
        and in which further diagnostic evaluation for generalized anxiety disorder 
        is warranted. 
    */
        * sum of all GAD-2 components
        egen gad2score = rowtotal(ga04_1 ga04_2) // add up scores
        replace gad2score = .r if inlist(.r, ga04_1, ga04_2) // transfer refusals
        lab var gad2score "Total GAD-2 score (ga04_1, ga04_2)"
        tab gad2score,m

        * categorization according to guideline
        gen gad2 = (gad2score >= 3) if gad2score < . // score of >= 3 is coded to 1
        replace gad2 = .r if gad2score == .r
        lab var gad2 "GAD-2 category"
        lab def gad2 0 "Score: 0-2" 1 "Score: 3-6"
        tab gad2,m

    * PHQ-9
    /* Total scores of 5, 10, 15, and 20 represent cutpoints for mild, moderate, moderately 
        severe and severe depression, respectively.
        Note: Question 9 is a single screening question on suicide risk. A patient who answers 
        yes to question 9 needs further assessment for suicide risk by an individual who is 
        competent to assess this risk.
    */
        * sum of all GAD-2 components
        egen phq9score = rowtotal(ga04_3-ga04_11) // add up scores
        forv q = 3/11 {
            replace phq9score = .r if ga04_`q' == .r // transfer refusals
        }
        lab var phq9score "Total PHG9 score (ga04_3-ga04_11)"
        tab phq9score,m

        * categorization according to guideline
        gen phq9 = .
        replace phq9 = 0 if inrange(phq9score, 0,4) // score of 0-4 is coded to 0
        replace phq9 = 1 if inrange(phq9score, 5,9) // score of 5-9 is coded to 1
        replace phq9 = 2 if inrange(phq9score, 10,14) // score of 10-14 is coded to 2
        replace phq9 = 3 if inrange(phq9score, 15,19) // score of 15-19 is coded to 3
        replace phq9 = 4 if phq9score >= 20 & phq9score < . // score of >= 20 is coded to 4
        replace phq9 = .r if phq9score == .r
        lab var phq9 "GAD-9 category"
        lab def phq 0 "None (Score: 0-4)" 1 "Mild (Score: 5-9)" 2 "Moderate (Score: 10-14)" 3 "Moderately severe (Score: 15-19)" ///
            4 "Severe (Score: 20+)" 
        lab val phq9 phq 
        tab phq9,m

        * suicide
        gen suicide = (ga11>1) if ga11 < . // recode to dummy
        replace suicide = .r if ga11 == .r
        lab var suicide "Indicated 'yes' in question on suicide risk (ga11)"
        lab val suicide yn01
        tab suicide,m
        tab ga11,m

        * ask AIGHD: how to deal with refusals? 
        * is the score for GAD-2 cut-off 3 or 4?
        * do they want single dummies for each PHQ-9 category?
        * do they want a separate suicide variable?
        * do they want dummies with "proper" names for each of the elements?



*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx HIV xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    * ever tested for HIV
        tab hiv1,m
        replace hiv1 = .r if hiv1 == 88
        replace hiv1 = .d if hiv1 == 77
    * new ever tested variable
        gen hiv_ms = (hiv1 == 1) if hiv1 < . // recode 2 to 0
        replace hiv_ms = hiv1 if hiv1 >= . // transfer missings
        replace hiv_ms = 0 if inlist(hiv_ms, .d,.r) // Don't know and refused are recoded to "no"
        lab var hiv_ms "Ever had an HIV test (hiv1)"
        lab val hiv_ms yn01

    * result of HIV test
        tab hiv2,m
        replace hiv2 = .s if hiv1 == 2
        replace hiv2 = .r if hiv2 == 3 // Do not want to disclose
        replace hiv2 = .c if hiv1 == .d
        replace hiv2 = .q if hiv1 == .r
    * new result variable
        gen hiv_pos = (hiv2 == 1) if hiv2 < . // recode 2 to 0
        replace hiv_pos = hiv2 if hiv2 >= . // transfer missing values
        lab var hiv_pos "HIV test result was positive (hiv1)"
        lab val hiv_pos yn01

        * time since last HIV test
        tab hiv3y,m
        tab hiv3m,m
        replace hiv3m = .d if hiv3m == 77
        replace hiv3y = .d if hiv3y == 77
        replace hiv3y = .d if hiv3m == .d & hiv3y == .
        replace hiv3m = .s if hiv3y < . & hiv3m >= . // they were supposed to only enter years
        replace hiv3y = .s if hiv3m < . & hiv3y >= .  // they were supposed to only enter years
        * it seems the interviewers did not know that they only need to enter years OR
        * months. But this should not have had an effect on the skip pattern of asking people
        * whether they would like to participate in a test. 
        replace hiv3y = .s if hiv1 == 2 // never tested
        replace hiv3m = .s if hiv1 == 2 // never tested
        foreach v in y m {
            replace hiv3`v' = .s if hiv2 == 1  // past test was positive
            replace hiv3`v' = .c if hiv1 == .d // answer to hiv1 was DK
            replace hiv3`v' = .q if inlist(.r, hiv1,hiv2) // answer to hiv1 or hiv2was refused
        }
        * there are 9 missings of which I don't know where they come from
        replace hiv3y = .m if hiv3y == .
        replace hiv3m = .m if hiv3m == .


    * consent for HIV test
        tab hiv4,m
        replace hiv4 = 2 if inlist(hiv4, 77,88) // refused or didn't know whether to give consent
        replace hiv4 = .s if hiv3y == 0 & hiv3m < 6 // test was within last 5 months 
        replace hiv4 = .s if hiv3y == .s & hiv3m < 6 // test was within last 5 months 
        replace hiv4 = .s if hiv2 == 1 // past test was positive
        replace hiv4 = .c if hiv1 == .d // answer to hiv1 was DK
        replace hiv4 = .q if inlist(.r, hiv1,hiv2) // answer to hiv1 or hiv2was refused
        replace hiv4 = .m if hiv3y == .m
        tab hiv3y if hiv4 == .,m

    * result of HIV test
        tab hiv6,m
        replace hiv6 = .q if hiv4 == 2 // no consent
        replace hiv6 = .s if hiv2 == 1  // past test was positive
        replace hiv6 = .s if hiv3y == 0 & hiv3m < 6 // test was within last 5 months 
        replace hiv6 = .s if hiv3y == .s & hiv3m < 6 // test was within last 5 months 
        replace hiv6 = .c if inlist(.d, hiv1) // answer to hiv1 was DK
        replace hiv6 = .q if inlist(.r, hiv1,hiv2) // answer to hiv1 or hiv2 was refused
        replace hiv6 = .m if hiv3y == .m
    * new HIV status variable (combining test result with previous text)
        gen hiv_stat = (hiv6 == 1) if hiv6 < . // recode 2 to 0
        replace hiv_stat = 0 if hiv3y == 0 & hiv3m < 6 // negative test was within last 5 months 
        replace hiv_stat = 0 if hiv3y == .s & hiv3m < 6 // negative test was within last 5 months 
        replace hiv_stat = 1 if hiv_pos == 1 // previous test was positive
        replace hiv_stat = .q if (hiv6 == .q | hiv_pos == .r) & hiv_stat >= . // refused test or info on previous test
        replace hiv_stat = .c if hiv1 == .d
        replace hiv_stat = .m if hiv3y == .m
        tab hiv_stat,m
        lab val hiv_stat yn01
        lab var hiv_stat "Person is HIV positive (hiv2,hiv6)"

    
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx FINALIZATION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    
    
    * dropping variables
        drop hiv3_When_was_the_l_time_you_wer READ_Thank_you_so_sure_can_be_im READ_I_want_to_kn_for_the_appoin 
        drop READ_I_want_to_kno_last_visit_a_ READ_In_this_secti_ties_such_as_  READ_In_this_secti_tine_or_preve 
        drop TS TT The_date_you_entered_s_ago_Pleas WC WD XB XJ he*

    * add special missing labels
        label dir
        foreach lab in `r(names)' {
            label define `lab' .s "Normal skip" .c  "Don't know in previous question" .d  "Don't know in this question" ///
                .q "Refused in previous question" .r "Refused in this question" .m "Accidental missing", add
        }


    * saving dataset with all variables (original and clean)
        save "$clean/WHOPEN_indiv_clean_all", replace

    * for R (and other programmes): convert missings
        ds, has(type numeric)
        foreach v in `r(varlist)' {
            replace `v' = 11111 if `v' == .s // normal skip pattern
            replace `v' = 22222 if `v' == .c // DK in previous question
            replace `v' = 33333 if `v' == .d // DK in this question
            replace `v' = 44444 if `v' == .q // Refused in previous question
            replace `v' = 55555 if `v' == .r // Refused in this question
            replace `v' = 66666 if `v' == .m // Accidental missing
        }

        foreach lab in `r(names)' {
            label define `lab' 1111 "Normal skip" 2222  "Don't know in previous question" 3333  "Don't know in this question" ///
                4444 "Refused in previous question" 5555 "Refused in this question" 6666 "Accidental missing", add
        }

        save "$clean/WHOPEN_indiv_clean_all_R", replace
    
    * keeping only new/clean variables
        use "$clean/WHOPEN_indiv_clean_all", clear
    
        keep RHM* age* alc* ate co_*  *smoke* *_avg dm_* educ elev* elig_* fbg female ga04* gad2* h_* ha hba1c hhid high* ///
            hiv_* marital *rate* pd_* pddm_* phq9* sit_day suicide swazi syn_sel *_wk work  clin_* // arm


    * saving dataset with new/clean variables only
        save "$clean/WHOPEN_indiv_clean", replace

    * for R (and other programmes): convert missings
        use "$clean/WHOPEN_indiv_clean_all_R", clear

        keep RHM* age* alc* ate co_*  *smoke* *_avg dm_* educ elev* elig_* fbg female ga04* gad2* h_* ha hba1c hhid high* ///
            hiv_* marital *rate* pd_* pddm_* phq9* sit_day suicide swazi syn_sel *_wk work  clin_* // arm
        
        save "$clean/WHOPEN_indiv_clean_R", replace


    *** generate codebook
        use "$clean/WHOPEN_indiv_clean", clear

        capture close log

        log using "$clean/WHOPEN_indiv_clean.txt", replace text
            desc
            codebook
        log close