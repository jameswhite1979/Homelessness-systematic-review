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
generate double rel_diff = reldif(( log_ci_upper - log_effect_size ), ( log_effect_size - log_ci_lower ))
summarize rel_diff

*By default, the symmetry check is performed by meta set with a tolerance level of 1e-6, which means the largest relative difference between log_ci_upper - log_effect_size and log_effect_size - log_ci_lower  cannot be greater than 1e-6. 
*Our largest difference is 8.9 so set civartolerance to this. 

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


*Main analysis - reductionist /integrative approach - meta regression. nesting of effect sizes within studies 
*********************************************************.

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


***LEAVEONEOUT***** need to work out how to store results in one file.

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



	
	
	