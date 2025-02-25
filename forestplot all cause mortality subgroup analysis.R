
install.packages("forestploter")
library(forestploter)
library(grid) 

loadfonts(device = "win")
windowsFonts("Fira Sans" = windowsFont("Fira Sans"))


path = c("C:/Users/wgprlc/OneDrive - Cardiff University/Homeless SR/DATA")

data = read.csv(paste0(path, "/forester SGA.csv"), sep=",", header=T)

colnames(data)[2] = c('N studies')
colnames(data)[6] = c('p-value')


# indent the subgroup if there is a number in the estimate column
data$Subgroup <- ifelse(is.na(data$Estimate), 
                        data$Subgroup,
                        paste0("   ", data$Subgroup))

# Create a confidence interval column to display
data$`Risk ratio (95% CI)`=sprintf("%.2f (%.2f to %.2f)",
                                     data$Estimate, data$CI.low, data$CI.high)

#replaces the decimal point with a midpoint#
middecimal <- function(s, ...) {
  gsub("([[:digit:]])[.]([[:digit:]])",
       "\\1·\\2", s)
}
                 
data$`Risk ratio (95% CI)`= middecimal(data$`Risk ratio (95% CI)`)
data$`p-value`= middecimal(data$`p-value`)

data[1,2]=" "
data[1,6]=" "
data[1,7]=" "
data[3,6]=" "

data[4,2]=" "
data[4,6]=" "
data[4,7]=" "
data[6,6]=" "
data[7,6]=" "
data[8,6]=" "
data[9,6]=" "
data[10,6]=" "

data[11,2]=" "
data[11,6]=" "
data[11,7]=" "
data[13,6]=" "
data[14,6]=" "
data[15,6]=" "

data[16,2]=" "
data[16,6]=" "
data[16,7]=" "
data[18,6]=" "
data[19,6]=" "

data[20,2]=" "
data[20,6]=" "
data[20,7]=" "
data[22,6]=" "

data[23,2]=" "
data[23,6]=" "
data[23,7]=" "

data[24,2]=" "
data[24,6]=" "
data[24,7]=" "
data[26,6]=" "

data[27,2]=" "
data[27,6]=" "
data[27,7]=" "
data[29,6]=" "

data[30,2]=" "
data[30,6]=" "
data[30,7]=" "
data[32,6]=" "

data[33,2]=" "
data[33,6]=" "
data[33,7]=" "
data[35,6]=" "

data[36,2]=" "
data[36,6]=" "
data[36,7]=" "
data[38,6]=" "
data[39,6]=" "

data[40,2]=" "
data[40,6]=" "
data[40,7]=" "
data[42,6]=" "

data[43,2]=" "
data[43,6]=" "
data[43,7]=" "
data[45,6]=" "

data[46,2]=" "
data[46,6]=" "
data[46,7]=" "
data[48,6]=" "
data[49,6]=" "
data[50,6]=" "
data[51,6]=" "
data[52,6]=" "
data[53,6]=" "
data[54,6]=" "

data[55,2]=" "
data[55,6]=" "
data[55,7]=" "
data[57,6]=" "

data$` ` <- paste(rep(" ", 10), collapse = " ")

par(mar = c(10, 10, 10, 10))

tm <- forest_theme(core = list(bg_params=list(fill = c("white"))),
                  )

p <- forest(data[,c(1:2,8:6)],
            est = data$Estimate,
            lower = data$CI.low, 
            upper = data$CI.high,
            sizes = 0.5,
            ci_column = 3,
            ref_line = 1,
            xlim = c(0, 12),
            ticks_at = c(0, 1, 2, 4, 6, 8, 12),
            xlog=TRUE,
            arrows = TRUE,
            font_family = "Fira Sans",
            cex = 4,
            theme = tm 
            )

bold_rows <-c(1,4,11,16,20,24,27,30,33,36,40,43,46,55) 
for (row in bold_rows) {
  p <- edit_plot(p, row = row, gp = gpar(fontface = "bold"))
}

plot(p)
