#syntax locations need editing as file now on S drive not on desktop#

library(forester)
library(readxl)

library(extrafont)
loadfonts(device = "win")
windowsFonts("Fira Sans" = windowsFont("Fira Sans"))

forester <- read_excel("C:/Users/wgprlc/OneDrive - Cardiff University/Homeless SR/DATA/forester cause-specific.xls")
View(forester)

# indent the subgroup if there is a number in the estimate column
forester$Cause <- ifelse(is.na(forester$Estimate), 
                            forester$Cause,
                            paste0("   ", forester$Cause))

forester(left_side_data = forester[,1:2],
         estimate = forester$Estimate,
         ci_low = forester$`CI low`,
         ci_high = forester$`CI high`,
         estimate_precision = 2,
         font_family = "Fira Sans",
         x_scale_linear	= FALSE,
         xlim = c(0.5,45),
         null_line_at = 1,
         estimate_col_name = "Risk ratio (95% CI)",
         arrows = TRUE,
         arrow_labels = c(" ", "Higher risk of mortality"),
         stripe_colour = "white",
         background_colour = "white",
         file_path = here::here("C:/Users/wgprlc/OneDrive - Cardiff University/Homeless SR/Figures/forest_causespecific.tif"))

