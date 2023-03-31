********************************************************************************
* DO FILE *
********************************************************************************

/*
Author: 	Lexi Schubert, University of Zurich
Project: 	Roth vs Traditional IRAs
Date:		March 2023

Program: 	Stata/MP 17.0
Packages: 	outreg2
Data:		Bohr_Holt_Schubert_IRA_table1.xlsx (import excel sheet as per code below; cd needs to be set accordingly)

*/

*cd "/Users/alschub/Dropbox/Academia/Research/Macro/Roth Accounts/submission" // needs to be adjusted acordingly!
import excel "Bohr_Holt_Schubert_IRA_table1.xlsx", sheet("Sheet1") firstrow case(lower)

********************************************************************************
* DATA CLEANING *
********************************************************************************

* Encoding and generating of existing variables
	
	encode treatment, gen(i_treat) // treatment
	encode session, gen(i_session) // session

	gen subject_id = _n // observation id
	
	gen savings_corrected = savings // correct savings to account for taxation
	replace savings_corrected = savings*0.8 if i_treat == 2
	
	gen roth_account = 1 if i_treat == 1 // Roth treatment variable
	replace roth_account = 0 if i_treat == 2
	
	gen female = 1 if male1_female2 == 2 // gender variable
	replace female = 0 if male1_female2 == 1

	replace vote = "" if vote == "*" // vote variable
	rename vote vote_str
	destring vote_str, gen(vote)

	rename risk riskaversion // for better identifyability

* Labeling variables for tables
	label variable savings_corrected "Savings"
	label variable optimality "Consumption Optimality"
	label variable female "Female"
	label variable riskaversion "Risk aversion"
	label variable patience "Patience"
	label variable roth_account "Roth account"
	label variable c_15_18 "Retirement consumption"

********************************************************************************
* REGRESSIONS *
********************************************************************************

// Main Paper

* TABLE 1

	*Consumption in retirement (w/ clustering)
	reg c_15_18 roth_account, cluster(i_session)
		outreg2 using tab1_tight.doc, replace word label ctitle(C (15-18)) 
	reg c_15_18 roth_account female riskaversion patience, cluster(i_session)
		outreg2 using tab1_tight.doc, append label ctitle(C (15-18)) 

	*Savings (w/ clustering)
	reg savings_corrected roth_account, cluster(i_session)
		outreg2 using tab1_tight.doc, append word label ctitle(Savings) 
	reg savings_corrected roth_account female riskaversion patience, cluster(i_session)
		outreg2 using tab1_tight.doc, append label ctitle(Savings)

	* Interpretation of coefficients in column (4)
	
	sum patience, de // compute st dev of patience
	di 1.671025 * 75.05473 // multiply with 1-unit change coefficient
	
	sum risk, de // compute st dev of risk aversion
	di .4662673 * 153.1084 // multiply with 1-unit change coefficient

// Robustness checks 

* ADDITIONAL OUTCOME

	*Consumption optimality (w/ clustering)
	reg optimality roth_account, cluster(i_session)
	reg optimality roth_account female riskaversion patience, cluster(i_session)

* NO CLUSTERING

	*Consumption in retirement (w/o clustering)
	reg c_15_18 roth_account
	reg c_15_18 roth_account female riskaversion patience

	*Savings (w/o clustering)
	reg savings_corrected roth_account
	reg savings_corrected roth_account female riskaversion patience

	*Consumption optimality (w/o clustering)
	reg optimality roth_account
	reg optimality roth_account female riskaversion patience



