library(ggplot2)

data.path <- "../Analytical-Data/"

# ----------------- PART I: LOAD IN DATA AND DO FINAL TRANSFORMS ---------------
ptsh <- read.csv(paste(data.path, "ana_point_sheet.csv", sep=""))
ptsh$date <- as.Date(ptsh$date)
att <- read.csv(paste(data.path, "ana_attendance.csv", sep=""))

# Re-code day before/after/of status
aikido.day.status <- rep(NA, nrow(ptsh))
for(i in 1:nrow(ptsh)) {
	if(ptsh[i,"aikido_day_before"] == 1) {aikido.day.status[i] <- "DayBefore"}
	if(ptsh[i,"aikido_day_after"] == 1) {aikido.day.status[i] <- "DayAfter"}
	if(ptsh[i,"aikido_day_of"] == 1) {aikido.day.status[i] <- "DayOf"}
	
}
ptsh$aikido_day_status <- aikido.day.status

ptsh <- ptsh[which(ptsh$behavior_total != 0),]

bad <- ptsh[which(ptsh$behavior_total == 0 & !is.na(ptsh$aikido_day_status)),]

# ----------------- PART I.B - SIMPLE EXPLORATION ---------------
cor(ptsh$behavior_total, ptsh$academic_total) #0.99567 - the two are essentially the same

# ----------------- PART II: BUILD SIMPLE PLOTS/ANALYSES OF AIKIDO EXPOSURE TO PERFORMANCE METRICS ---------------
plot(ptsh$cum_aikido, ptsh$behavior_total, col='blue', pch=16)
abline(lm(ptsh$behavior_total ~ ptsh$cum_aikido), col="red", lwd=2)

plot(ptsh$cum_aikido, ptsh$academic_total, col='blue', pch=16)
abline(lm(ptsh$academic_total ~ ptsh$cum_aikido), col="red", lwd=2)

am <- lm(academic_total ~ cum_aikido, data=ptsh)
summary(am)
bm <- lm(behavior_total ~ cum_aikido, data=ptsh)
summary(bm)

with(ptsh, plot(Grade, behavior_total, col="blue"))
with(ptsh, plot(Grade, academic_total, col="blue"))

# ----------------- PART III: Look at top/bottom quantile comparisons over time ------------------------------
tb <- ptsh[which(ptsh$q_cum_aikido == "Q1" | ptsh$q_cum_aikido == "Q5"),]
behavior.top.bottom <- ggplot(tb, aes(date, behavior_total, color=factor(q_cum_aikido))) + geom_point()
academic.top.bottom <- ggplot(tb, aes(date, academic_total, color=factor(q_cum_aikido))) + geom_point()

behavior.all <- ggplot(ptsh, aes(date, behavior_total, color=q_cum_aikido)) + geom_point()
academic.all <- ggplot(ptsh, aes(date, academic_total, color=q_cum_aikido)) + geom_point()


# --------------- PART IV: LOOK AT TRENDS COMPARING DAY BEFORE/OF/AFTER -------------------------------------
behavior.aikido.day <- ggplot(na.omit(ptsh), aes(date, behavior_total, color=factor(aikido_day_status))) + geom_point()
academic.aikido.day <- ggplot(na.omit(ptsh), aes(date, academic_total, color=factor(aikido_day_status))) + geom_point()

ad <- aov(behavior_total ~ aikido_day_status, data=subset(ptsh, !is.na(aikido_day_status)))
model.tables(ad, "means")
summary(ad)
