library(ggplot2)

data.path <- "../Analytical-Data/"

ptsh <- read.csv(paste(data.path, "ana_point_sheet.csv", sep=""))
ptsh$date <- as.Date(ptsh$date)
att <- read.csv(paste(data.path, "ana_attendance.csv", sep=""))

plot(ptsh$cum_aikido, ptsh$behavior_total, col='blue')
abline(lm(ptsh$behavior_total ~ ptsh$cum_aikido), col="red", lwd=2)

plot(ptsh$cum_aikido, ptsh$academic_total, col='blue')
abline(lm(ptsh$academic_total ~ ptsh$cum_aikido), col="red", lwd=2)

am <- lm(academic_total ~ cum_aikido, data=ptsh)
summary(am)
bm <- lm(behavior_total ~ cum_aikido, data=ptsh)
summary(bm)

with(ptsh, plot(Grade, behavior_total, col="blue"))
with(ptsh, plot(Grade, academic_total, col="blue"))

# Look at top/bottom quantile comparisons over time
tb <- ptsh[which(ptsh$q_cum_aikido == "Q1" | ptsh$q_cum_aikido == "Q5"),]
behavior.top.bottom <- ggplot(tb, aes(date, behavior_total, color=factor(q_cum_aikido))) + geom_point()
academic.top.bottom <- ggplot(tb, aes(date, academic_total, color=factor(q_cum_aikido))) + geom_point()
