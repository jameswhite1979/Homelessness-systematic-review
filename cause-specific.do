*cause specific mortality

clear
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Homelessness Clean included papers Stata.xlsx", sheet("cause specific") firstrow clear

generate double log_effect_size = log(finaleffectRR)
generate double log_ci_lower = log(DF)
generate double log_ci_upper = log(DG)
list ID log_effect_size log_ci_lower log_ci_upper

*confidence intervals not symmetric error. Check the relative difference. 
generate double rel_diff = reldif(( log_ci_upper - log_effect_size ), ( log_effect_size - log_ci_lower ))
summarize rel_diff
tab rel_diff

*By default, the symmetry check is performed by meta set with a tolerance level of 1e-6, which means the largest relative difference between log_rr_ul-log_rr and log_rr-log_rr_ll cannot be greater than 1e-6. 
*Our largest difference is 0.65 so set civartolerance to this. 

meta set log_effect_size log_ci_lower log_ci_upper, random civartolerance(2.0) studylabel(AUTHOR_YEAR)
tab COD_CAT1
tab COD_Top_Level
rename COD_Top_Level Cause 


******
meta summarize, subgroup(Cause) eform(Risk ratio) random(reml)

meta forestplot, subgroup(Cause SOCIO_DISADV) eform(Risk ratios) random(reml) ///
nullrefline cibind(parentheses) columnopts(_K, title("Number of Studies")) nooverall ///
crop(0 16) xscale(range(.5 14)) xlabel(0.5 1 2 4 8 )  ///
columnopts(_plot, plotregion(margin(right))) 

ssc install treemap
help treemap
ssc install palettes, replace
ssc install colrspace, replace

clear
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Tree Map data.xlsx", sheet("Sheet1") firstrow clear

treemap N, by(Cause RR RR_CAT) palette("Blues") colorby(RR) novalues addt  nolab

*See R**

