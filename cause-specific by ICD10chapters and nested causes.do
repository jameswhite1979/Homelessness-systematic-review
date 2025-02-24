*cause specific mortality 2. by ICD10 chapter with specific causes nested.

clear
import excel "C:\Users\wgprlc\OneDrive - Cardiff University\Homeless SR\DATA\Homelessness Clean included papers Stata.xlsx", sheet("cause_specific2") firstrow clear

generate double log_effect_size = log(finaleffectRR)
generate double log_ci_lower = log(BJ)
generate double log_ci_upper = log(BK)
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
tab Cause

*add in order by ICD10 code chapters.
gen subgroup_order = .
replace subgroup_order = 1 if Cause == "Certain infectious and parasitic diseases"
replace subgroup_order = 2 if Cause == "COVID-19"
replace subgroup_order = 3 if Cause == "HIV disease"
replace subgroup_order = 4 if Cause == "Sepsis"
replace subgroup_order = 5 if Cause == "Tuberculosis"
replace subgroup_order = 6 if Cause == "Viral hepatitis"
replace subgroup_order = 7 if Cause == "Neoplasms"
replace subgroup_order = 8 if Cause == "Diseases of the blood and blood-forming organs"
replace subgroup_order = 9 if Cause == "Endocrine, nutritional and metabolic diseases"
replace subgroup_order = 10 if Cause == "Mental and behavioural disorders"
replace subgroup_order = 11 if Cause == "Mental illness/psychiatric diseases"
replace subgroup_order = 12 if Cause == "Psychoactive substance use disorder"
replace subgroup_order = 13 if Cause == "Diseases of the nervous system"
replace subgroup_order = 14 if Cause == "Diseases of the circulatory system"
replace subgroup_order = 15 if Cause == "Cardiovascular"
replace subgroup_order = 16 if Cause == "Cerebrovascular disease"
replace subgroup_order = 17 if Cause == "Heart disease"
replace subgroup_order = 18 if Cause == "Diseases of the respiratory system"
replace subgroup_order = 19 if Cause == "Chronic lower respiratory diseases"
replace subgroup_order = 20 if Cause == "Influenza and pneumonia"
replace subgroup_order = 21 if Cause == "Respiratory"
replace subgroup_order = 22 if Cause == "Diseases of the digestive system"
replace subgroup_order = 23 if Cause == "Diseases of liver"
replace subgroup_order = 24 if Cause == "Diseases of the musculoskeletal system"
replace subgroup_order = 25 if Cause == "Diseases of the genitourinary system"
replace subgroup_order = 26 if Cause == "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified"
replace subgroup_order = 27 if Cause == "Injury, poisoning and certain other consequences of external causes"
replace subgroup_order = 28 if Cause == "Alcohol-related"
replace subgroup_order = 29 if Cause == "Drug-overdose"
replace subgroup_order = 30 if Cause == "Drug-related (excluding overdose)"
replace subgroup_order = 31 if Cause == "Toxic effect of other and unspecified substances"
replace subgroup_order = 32 if Cause == "External causes"
replace subgroup_order = 33 if Cause == "Accidents"
replace subgroup_order = 34 if Cause == "Homicide"
replace subgroup_order = 35 if Cause == "Intentional self-harm"
replace subgroup_order = 36 if Cause == "Other external causes of accidental injury"
replace subgroup_order = 37 if Cause == "Suicide"
replace subgroup_order = 38 if Cause == "Transport accidents"
replace subgroup_order = 39 if Cause == "Natural causes"
replace subgroup_order = 40 if Cause == "Other/unknown"

                    
sort subgroup_order
label define subgroup_order2 1 "Certain infectious and parasitic diseases" 2 " - COVID-19" 3 " - HIV disease" 4 " - Sepsis" 5 " - Tuberculosis" 6 " - Viral hepatitis" 7 "Neoplasms" 8 "Diseases of the blood and blood-forming organs" 9 "Endocrine, nutritional and metabolic diseases" 10 "Mental and behavioural disorders" 11 " - Mental illness/psychiatric diseases" 12 " - Psychoactive substance use disorder" 13 "Diseases of the nervous system" 14 "Diseases of the circulatory system" 15 " - Cardiovascular" 16 " - Cerebrovascular disease" 17 " - Heart disease" 18 "Diseases of the respiratory system" 19 " - Chronic lower respiratory diseases" 20 " - Influenza and pneumonia" 21 " - Respiratory" 22 "Diseases of the digestive system" 23 " - Diseases of liver" 24 "Diseases of the musculoskeletal system" 25 "Diseases of the genitourinary system" 26 "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified" 27 "Injury, poisoning and certain other consequences of external causes" 28 " - Alcohol-related" 29 " - Drug-overdose" 30 " - Drug-related (excluding overdose)" 31 " - Toxic effect of other and unspecified substances" 32 "External causes" 33 " - Accidents" 34 " - Homicide" 35 " - Intentional self-harm" 36 " - Other external causes of accidental injury" 37 " - Suicide" 38 " - Transport accidents" 39 "Natural causes" 40 "Other/unknown", modify
label values subgroup_order subgroup_order2

******
drop if Cause == "Chronic lower respiratory diseases" | Cause == "Intentional self-harm" | Cause == "Natural causes"
meta summarize, subgroup(subgroup_order) eform(Risk ratio) random(reml)

meta forestplot, subgroup(Cause finaleffect) eform(Risk ratios) random(reml) ///
nullrefline cibind(parentheses) columnopts(_K, title("Number of effects")) nooverall ///
crop(0.1 32) xscale(range(0.1 32)) xlabel(0.1 0.5 1 2 4 8 16, format(%9.1f))  ///
columnopts(_plot, plotregion(margin(right))) 