*import data.
clear
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Homelessness Clean included papers Stata.xlsx", sheet("All cause for Stata") cellrange(A1:BH143) firstrow clear

*https://www.stata.com/support/faqs/statistics/meta-set-confidence-intervals-effect-sizes/
*meta set is designed to work with normally distributed effect sizes with symmetric confidence intervals, we cannot specify our rr, rr_ll, and rr_ul variables directly in meta set. 
*As we can see here, the confidence intervals of RRs are not symmetric around RRs, because RRs are not normally distributed. The same happens with ORs, IRRs, and HRs. In order to get normalized effect sizes and symmetric confidence intervals, we need to apply the natural logarithm transformation to rr as well as the limits of the confidence intervals, rr_ll and rr_ul.

generate double log_effect_size = log(final_effect)
generate double log_ci_lower = log(FE_LCI)
generate double log_ci_upper = log(FE_UCI)
list ID3 log_effect_size log_ci_lower log_ci_upper

*confidence intervals not symmetric error. Check the relative difference for symmetry. If rel_Diff=0 then symmeterical. 
generate double rel_diff = reldif(( log_ci_upper - log_effect_size ), ( log_effect_size - log_ci_lower ))
summarize rel_diff

*By default, the symmetry check is performed by meta set with a tolerance level of 1e-6, which means the largest relative difference between log_ci_upper - log_effect_size and log_effect_size - log_ci_lower  cannot be greater than 1e-6. 
*Our largest difference is 8.9 so set civartolerance to this. 

meta set log_effect_size log_ci_lower log_ci_upper, random civartolerance(9) studylabel(AUTHOR_YEAR_REASON)


*************************************************************************************************
keep if mainanalysis==1 & BB=="RR"
meta meregress log_effect_size  || ID4:, essevariable(_meta_se) 
predict predicted_log_rr, xb
predict se_log_rr, stdp
estat heterogeneity
generate ci_lower = predicted_log_rr - 1.96 * se_log_rr
generate ci_upper = predicted_log_rr + 1.96 * se_log_rr
generate predicted_rr = exp(predicted_log_rr)
generate ci_lower_rr = exp(ci_lower)
generate ci_upper_rr = exp(ci_upper)
summarize predicted_rr ci_lower_rr ci_upper_rr if mainanalysis==1 

meta forestplot, eform(RR) random(reml) esrefline nullrefline cibind(parentheses) crop(0.5 8) xscale(range(0.1 8)) xlabel(0.1 0.5 1 2 4 8, format(%9.1f))
*note foresplot doesnt show the adjusted pooled estimate.
meta bias, egger 
meta galbraithplot 

meta trimfill, eform(Risk ratio) poolmethod(reml)
meta trimfill, funnel eform(Risk ratio) poolmethod(reml)

*************************************************************************************************
keep if mainanalysis==1 & BB=="SMR"
meta meregress log_effect_size  || ID4:, essevariable(_meta_se) 
predict predicted_log_rr, xb
predict se_log_rr, stdp
estat heterogeneity
generate ci_lower = predicted_log_rr - 1.96 * se_log_rr
generate ci_upper = predicted_log_rr + 1.96 * se_log_rr
generate predicted_rr = exp(predicted_log_rr)
generate ci_lower_rr = exp(ci_lower)
generate ci_upper_rr = exp(ci_upper)
summarize predicted_rr ci_lower_rr ci_upper_rr if mainanalysis==1 

meta forestplot, eform(RR) random(reml) esrefline nullrefline cibind(parentheses) crop(0.5 16) xscale(range(0.1 16)) xlabel(0.1 0.5 1 2 4 8 16, format(%9.1f))

*note foresplot doesnt show the adjusted pooled estimate.meta bias, egger 
meta bias, egger 
meta galbraithplot 

meta trimfill, eform(Risk ratio) poolmethod(reml)
meta trimfill, funnel eform(Risk ratio) poolmethod(reml)