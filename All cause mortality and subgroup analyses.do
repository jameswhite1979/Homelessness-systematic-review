*import data.
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Homelessness Clean included papers Stata.xlsx", sheet("All cause for Stata") firstrow clear

*https://www.stata.com/support/faqs/statistics/meta-set-confidence-intervals-effect-sizes/
*
*meta set is designed to work with normally distributed effect sizes with symmetric confidence intervals, we cannot specify our rr, rr_ll, and rr_ul variables directly in meta set. 
*The confidence intervals of RRs are not symmetric around RRs, because RRs are not normally distributed. The same happens with ORs, IRRs, and HRs. To get normalized effect sizes and symmetric confidence intervals, we need to apply the natural logarithm transformation to rr as well as the limits of the confidence intervals, rr_ll and rr_ul.

generate double log_effect_size = log(final_effect)
generate double log_ci_lower = log(FE_LCI)
generate double log_ci_upper = log(FE_UCI)
list ID3 log_effect_size log_ci_lower log_ci_upper

*confidence intervals not symmetric error. Check the relative difference for symmetry. If rel_Diff=0 then symmeterical.
*By default, the symmetry check is performed by meta set with a tolerance level of 1e-6, which means the largest relative difference between log_ci_upper - log_effect_size and log_effect_size - log_ci_lower  cannot be greater than 1e-6. 

generate double rel_diff = reldif(( log_ci_upper - log_effect_size ), ( log_effect_size - log_ci_lower ))
summarize rel_diff
meta set log_effect_size log_ci_lower log_ci_upper, random civartolerance(5) studylabel(AUTHOR_YEAR_REASON)

*Shaw study has CIs that are completely assymetrical in the log domain- If the relative difference has any large values, that means the transformed confidence intervals are not close to symmetric. In this case, you need to check how the effect sizes and their confidence intervals are originally computed and decide if a different type of transformation is needed.

****************************************************************************.

* All effect estimates - for all 145 effects from 95 
tab ID
meta summarize, eform(Risk ratio) random(reml)
meta bias, egger 

*Main analysis - reductionist approach - 126 effects
keep if mainanalysis==1
meta summarize, eform(Risk ratio) random(reml) sort(AUTHOR_YEAR_REASON)

meta forestplot, eform(Risk ratio) random(reml) noohetstats noohomtest esrefline ///
cibind(none) ciopts(lcolor(black)) markeropts(mcolor(black)) ///
columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) ///
sort(AUTHOR_YEAR_REASON) crop(0.25 16) xscale(range(.5 16)) xlabel(0.25 0.5 1 2 4 8 16, format(%2.1f)) 

meta bias, egger 
meta galbraithplot 
meta trimfill, eform(Risk ratios) poolmethod(reml)
meta trimfill, funnel eform(Risk ratios) poolmethod(reml)

meta forestplot, eform(Risk ratios) random(reml) esrefline cibind(parentheses)leaveoneout

*I2=99% means that 99% of the variability among the effect sizes is due to true heterogeneity in our data as opposed to the sampling variability.

***************************************************************************.
*Main analysis - reductionist /integrative approach - meta regression. nesting of effect sizes within studies 
***************************************************************************.*.

meta meregress log_effect_size || ID4:, essevariable(_meta_se) 
predict predicted_log_rr, xb
predict se_log_rr, stdp
estat heterogeneity

generate ci_lower = predicted_log_rr - 1.96 * se_log_rr
generate ci_upper = predicted_log_rr + 1.96 * se_log_rr

generate predicted_rr = exp(predicted_log_rr)
generate ci_lower_rr = exp(ci_lower)
generate ci_upper_rr = exp(ci_upper)

*adjusted pooled effect.
summarize predicted_rr ci_lower_rr ci_upper_rr 


***LEAVEONEOUT***** 

*import data.
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Homelessness Clean included papers 6JAN.xlsx", sheet("All cause for Stata") firstrow clear
generate double log_effect_size = log(final_effect)
generate double log_ci_lower = log(FE_LCI)
generate double log_ci_upper = log(FE_UCI)
generate double rel_diff = reldif(( log_ci_upper - log_effect_size ), ( log_effect_size - log_ci_lower ))
meta set log_effect_size log_ci_lower log_ci_upper, fixed civartolerance(5) studylabel(AUTHOR_YEAR_REASON)
keep if mainanalysis==1

local n = _N
forvalues i = 1/`n' {
    preserve
    drop if _n == `i'
    meta meregress log_effect_size || ID4:, essevariable(_meta_se) 
	predict predicted_log_rr, xb
	predict se_log_rr, stdp
	generate ci_lower = predicted_log_rr - 1.96 * se_log_rr
	generate ci_upper = predicted_log_rr + 1.96 * se_log_rr
	generate predicted_rr = exp(predicted_log_rr)
	generate ci_lower_rr = exp(ci_lower)
	generate ci_upper_rr = exp(ci_upper)
summarize predicted_rr ci_lower_rr ci_upper_rr
restore
}

*************************
*Subgroup analyses.
*************************

*All subgroups in one forest plot. 

gen sample_size = .
replace sample_size = 1 if SAMPLE_SIZE_CAT == "<1k"
replace sample_size = 2 if SAMPLE_SIZE_CAT == "1k-<10k"
replace sample_size = 3 if SAMPLE_SIZE_CAT == "10k-<100k"
replace sample_size = 4 if SAMPLE_SIZE_CAT == "100k-<500k"
replace sample_size = 5 if SAMPLE_SIZE_CAT == "500k-<1m"
replace sample_size = 6 if SAMPLE_SIZE_CAT == "1m-<5m"
replace sample_size = 7 if SAMPLE_SIZE_CAT == "5m-<10m"
replace sample_size = 8 if SAMPLE_SIZE_CAT == "10m+"

sort sample_size
label define sample_size2 1 "<1k" 2 "1k-<10k" 3 "10k-<100k" 4 "100k-<500k" 5 "500k-<1m" 6 "1m-<5m" 7 "5m-<10m" 8 "10m+"
label values sample_size sample_size2
		
meta forestplot, subgroup(sample_size Region COUNTRY_CLASSIFICATION MASTERscale HOMELESS_TYPE_CAT Currenthistorichomelessness Methodhomelessnessassessed2 Studytype publishedunpublished Sex Ageadjusted Analysisadjustedforcovariates Comparatortype Socioeconomicallydisadvantaged) ///
	eform(Risk ratio) random(reml) noohetstats nullrefline ///
	columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 
	
**Country detailed**
meta forestplot if mainanalysis==1, subgroup(Country Sex ) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 

***********************************************************
*interacton p-values
*Sex
encode Sex, generate(Sex_num)
tab Sex_num
meta meregress log_effect_size i.Sex_num if Sex != "Males and Females"|| ID4:, essevariable(_meta_se) 
margins Sex_num, expression(exp(predict(xb)))
testparm i.Sex_num

meta forestplot if Sex != "Males and Females", subgroup(Sex Ageadjusted) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 

*COUNTRY_CLASSIFICATION
tab COUNTRY_CLASSIFICATION
encode COUNTRY_CLASSIFICATION, generate(COUNTRY_CLASSIFICATION_num)
tab COUNTRY_CLASSIFICATION_num
meta meregress log_effect_size i.COUNTRY_CLASSIFICATION_num if mainanalysis==1|| ID4:, essevariable(_meta_se) 
margins COUNTRY_CLASSIFICATION_num, expression(exp(predict(xb)))
testparm i.COUNTRY_CLASSIFICATION_num

meta forestplot if mainanalysis==1, subgroup(Sex COUNTRY_CLASSIFICATION) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
	
*MASTERscale
tab MASTERscale
encode MASTERscale, generate(MASTERscale_num)
tab MASTERscale_num
meta meregress log_effect_size i.MASTERscale_num if mainanalysis==1|| ID4:, essevariable(_meta_se) 
margins MASTERscale_num, expression(exp(predict(xb)))
testparm i.MASTERscale_num

meta forestplot if mainanalysis==1, subgroup(Sex MASTERscale_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
		
*Currenthistorichomelessness
tab Currenthistorichomelessness
encode Currenthistorichomelessness, generate(Currenthistorichomelessness_num)
tab Currenthistorichomelessness_num

meta meregress log_effect_size i.Currenthistorichomelessness_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins Currenthistorichomelessness_num, expression(exp(predict(xb)))
testparm i.Currenthistorichomelessness_num

meta forestplot if mainanalysis==1, subgroup(Sex Currenthistorichomelessness_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
		
*HOMELESS_TYPE_CAT
tab HOMELESS_TYPE_CAT
encode HOMELESS_TYPE_CAT, generate(HOMELESS_TYPE_CAT_num)
tab HOMELESS_TYPE_CAT_num if HOMELESS_TYPE_CAT != "Type unclear " & HOMELESS_TYPE_CAT != "x" & HOMELESS_TYPE_CAT != "Sofa surfing" & HOMELESS_TYPE_CAT != "Squatting"
meta meregress log_effect_size i.HOMELESS_TYPE_CAT_num if HOMELESS_TYPE_CAT != "Type unclear " & HOMELESS_TYPE_CAT != "x"  & HOMELESS_TYPE_CAT != "Sofa surfing" & HOMELESS_TYPE_CAT != "Squatting" || ID4:, essevariable(_meta_se) 
margins HOMELESS_TYPE_CAT_num, expression(exp(predict(xb)))
testparm i.HOMELESS_TYPE_CAT_num

meta forestplot if HOMELESS_TYPE_CAT != "Type unclear " & HOMELESS_TYPE_CAT != "x"  & HOMELESS_TYPE_CAT != "Sofa surfing" & HOMELESS_TYPE_CAT != "Squatting" , subgroup(Sex HOMELESS_TYPE_CAT_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
		
	
*sample_size
tab SAMPLE_SIZE_CAT
encode SAMPLE_SIZE_CAT, generate(sample_size_num)
tab sample_size_num
meta meregress log_effect_size i.sample_size_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins sample_size_num, expression(exp(predict(xb)))
testparm i.sample_size_num

meta forestplot if mainanalysis==1, subgroup(Sex sample_size) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
		
*Methodhomelessnessassessed2
tab Methodhomelessnessassessed2
encode Methodhomelessnessassessed2, generate(Methodhomelessnessassessed2_num)
tab Methodhomelessnessassessed2_num

meta meregress log_effect_size i.Methodhomelessnessassessed2_num if mainanalysis==1 & Methodhomelessnessassessed2 != "Self-report/administrative record" & Methodhomelessnessassessed2 !="Unclear"|| ID4:, essevariable(_meta_se) 
margins Methodhomelessnessassessed2_num, expression(exp(predict(xb)))
testparm i.Methodhomelessnessassessed2_num

meta forestplot if mainanalysis==1 & Methodhomelessnessassessed2 != "Self-report/administrative record" & Methodhomelessnessassessed2 !="Unclear", subgroup(Sex Methodhomelessnessassessed2_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

		
*Region.
tab Region2
encode Region2, generate(Region_num)
tab Region_num if mainanalysis==1 & Region2 != "Asia" & Region2 != "Africa"

meta meregress log_effect_size i.Region_num if mainanalysis==1 & Region2 !="Asia" & Region2 !="Africa" || ID4:, essevariable(_meta_se) 
margins Region_num, expression(exp(predict(xb)))
testparm i.Region_num
meta forestplot if mainanalysis==1 & Region2 !="Asia" & Region2 !="Africa" , subgroup(Region2 Sex) eform(Risk ratio) random(reml) noohetstats nullrefline ///
	columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 
	
*study type
tab Studytype
encode Studytype, generate(Studytype_num)
tab Studytype_num if mainanalysis==1 & Studytype != "Both" & Studytype !="RCT"

meta meregress log_effect_size i.Studytype_num if mainanalysis==1 & Studytype != "Both" & Studytype !="RCT"|| ID4:, essevariable(_meta_se) 
margins Studytype_num, expression(exp(predict(xb)))
testparm i.Studytype_num

meta forestplot if mainanalysis==1 & Studytype != "Both" & Studytype !="RCT", subgroup(Sex Studytype_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

*publishedunpublished 
tab publishedunpublished
encode publishedunpublished, generate(publishedunpublished_num)
tab publishedunpublished_num if mainanalysis==1

meta meregress log_effect_size i.publishedunpublished_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins publishedunpublished_num, expression(exp(predict(xb)))
testparm i.publishedunpublished_num

meta forestplot if mainanalysis==1, subgroup(Sex publishedunpublished) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

*Ageadjusted 
tab Ageadjusted
encode Ageadjusted, generate(Ageadjusted_num)
tab Ageadjusted_num if mainanalysis==1

meta meregress log_effect_size i.Ageadjusted_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins Ageadjusted_num, expression(exp(predict(xb)))
testparm i.Ageadjusted_num

meta forestplot if mainanalysis==1, subgroup(Sex Ageadjusted_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

*Analysisadjustedforcovariates 
tab Analysisadjustedforcovariates
encode Analysisadjustedforcovariates, generate(Adj_num)
tab Adj_num if mainanalysis==1

meta meregress log_effect_size i.Adj_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins Adj_num, expression(exp(predict(xb)))
testparm i.Adj_num

meta forestplot if mainanalysis==1, subgroup(Sex Adj_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

*Comparatortype 
tab Comparatortype
encode Comparatortype, generate(Comp_num)
tab Comp_num if mainanalysis==1

meta meregress log_effect_size i.Comp_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins Comp_num, expression(exp(predict(xb)))
testparm i.Comp_num

meta forestplot if mainanalysis==1, subgroup(Sex Comp_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	

*Socioeconomicallydisadvantaged	
	
tab Socioeconomicallydisadvantaged
encode Socioeconomicallydisadvantaged, generate(Socdis_num)
tab Socdis_num if mainanalysis==1

meta meregress log_effect_size ib1.Socdis_num if mainanalysis==1 || ID4:, essevariable(_meta_se) 
margins Socdis_num, expression(exp(predict(xb)))
testparm i.Socdis_num

meta regress ib1.Socdis_num if mainanalysis==1 
margins Socdis_num, expression(exp(predict(xb)))
testparm i.Socdis_num

meta forestplot if mainanalysis==1, subgroup(Sex Socdis_num) eform(Risk ratio) random(reml) noohetstats nullrefline columnopts(_K, title("Number of effects")) nooverall crop(0.5 16) xscale(range(.5 16)) xlabel(0.5 1 2 4 8 16, format(%2.1f)) columnopts(_lb, mask("[%4.2f",)) columnopts(_ub, mask("%4.2f]")) 	
	
	
	
	