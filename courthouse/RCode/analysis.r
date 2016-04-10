library(ggplot2)

data.path <- "../Analytical-Data/"

# ----------------- PART I: LOAD IN DATA AND DO FINAL TRANSFORMS ---------------
ptsh <- read.csv(paste(data.path, "ana_point_sheet.csv", sep=""))
ptsh$date <- as.Date(ptsh$date)
att <- read.csv(paste(data.path, "ana_attendance.csv", sep=""))
dates <- sapply(1:nrow(att), function(i){paste(att[i,"year"], att[i,"month"], "01", sep="-")})
att$date <- dates

# Data sanity check:
bad <- ptsh[which(ptsh$behavior_total == 0 & !is.na(ptsh$aikido_day_status)),]
message(paste("Bad Rows:", nrow(bad)))

# ----------------- PART I.B - SIMPLE EXPLORATION ---------------
cor(ptsh$behavior_total, ptsh$academic_total) #0.9831874 - the two are essentially the same

# ----------------- PART II: BUILD SIMPLE PLOTS/ANALYSES OF AIKIDO EXPOSURE TO PERFORMANCE METRICS ---------------
plot(ptsh$cum_aikido, ptsh$behavior_total, col='blue', pch=16)
abline(lm(ptsh$behavior_total ~ ptsh$cum_aikido), col="red", lwd=2)

plot(ptsh$cum_aikido, ptsh$academic_total, col='blue', pch=16)
abline(lm(ptsh$academic_total ~ ptsh$cum_aikido), col="red", lwd=2)

am <- lm(academic_total ~ cum_aikido, data=ptsh)
summary(am)
bm <- lm(behavior_total ~ cum_aikido, data=ptsh)
summary(bm)

with(ptsh, plot(Grade, behavior_total, col="blue", pch=16))
with(ptsh, plot(Grade, academic_total, col="blue", pch=16))

aov.f_name <- aov(behavior_total ~ f_name, data=ptsh)
model.tables(aov.f_name, "means")
summary(aov.f_name)

aov.cum_aikido <- aov(behavior_total ~ q_cum_aikido, data=ptsh)
model.tables(aov.cum_aikido, "means")
summary(aov.cum_aikido)

aov.condition <- aov(behavior_total ~ condition_id, data=ptsh)
model.tables(aov.condition, "means")
summary(aov.condition)

aov.grade <- aov(behavior_total ~ q_grade, data=ptsh)
model.tables(aov.grade, "means")
summary(aov.grade)


aov.full <- aov(behavior_total ~ q_cum_aikido * condition_id * q_grade, data=ptsh)
model.tables(aov.full, "means")
summary(aov.full)

# Show the different quartiles over time
behavior.all <- ggplot(ptsh, aes(date, behavior_total, color=q_cum_aikido)) + geom_point()
academic.all <- ggplot(ptsh, aes(date, academic_total, color=q_cum_aikido)) + geom_point()


# ----------------- PART III: Look at top/bottom quantile comparisons over time ------------------------------
tb <- ptsh[which(ptsh$q_cum_aikido == "Q1" | ptsh$q_cum_aikido == "Q5"),]
#q5.names <- unique(as.character(subset(tb, q_cum_aikido == "Q5")$f_name))
#tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
behavior.top.bottom <- ggplot(tb, aes(date, behavior_total, color=q_cum_aikido)) + geom_point()
academic.top.bottom <- ggplot(tb, aes(date, academic_total, color=q_cum_aikido)) + geom_point()

ab <- aov(behavior_total ~ q_cum_aikido, data=tb)
summary(ab)
model.tables(ab,"means")

# --------------- COMPARE OVER TIME ONLY THOSE WHO MADE IT INTO Q5 -----------------------
tb <- ptsh
q5.names <- unique(as.character(subset(tb, q_cum_aikido == "Q5")$f_name))
tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
unique(tb$f_name) # Print names those who made it into Q5

behavior.q5 <- ggplot(tb, aes(date, behavior_total, color=q_cum_aikido)) + geom_point()
academic.q5 <- ggplot(tb, aes(date, academic_total, color=q_cum_aikido)) + geom_point()

ab <- aov(behavior_total ~ q_cum_aikido, data=tb)
summary(ab)
model.tables(ab,"means")

# --------------- PART IV: LOOK AT TRENDS COMPARING DAY BEFORE/OF/AFTER -------------------------------------
behavior.aikido.day <- ggplot(ptsh[which(!is.na(ptsh$aikido_day_status)),], aes(date, behavior_total, color=aikido_day_status)) + geom_point()
academic.aikido.day <- ggplot(ptsh[which(!is.na(ptsh$aikido_day_status)),], aes(date, academic_total, color=aikido_day_status)) + geom_point()

ad <- aov(behavior_total ~ aikido_day_status, data=subset(ptsh, !is.na(aikido_day_status)))
model.tables(ad, "means")
summary(ad)

# --------------- PART V: LOOK AT TRENDS ON ATTENDANCE -------------  

cor(att$monthly_cum_aikido, att$tardy)
plot(att$monthly_cum_aikido, att$tardy, col='blue', pch=16)
abline(lm(att$tardy ~ att$monthly_cum_aikido), col="red", lwd=2)

cor(att$monthly_cum_aikido, att$absent)
plot(att$monthly_cum_aikido, att$absent, col='blue', pch=16)
abline(lm(att$absent ~ att$monthly_cum_aikido), col="red", lwd=2)

cor(att$monthly_cum_aikido, att$suspend)
plot(att$monthly_cum_aikido, att$suspend, col='blue', pch=16)
abline(lm(att$suspend ~ att$monthly_cum_aikido), col="red", lwd=2)

# ----------------- ATTENDANCE: Look at top/bottom quantile comparisons over time ------------------------------
tb <- att[which(att$q_cum_aikido == "Q1" | att$q_cum_aikido == "Q5"),]
#q5.names <- unique(as.character(subset(tb, q_cum_aikido == "Q5")$f_name))
#tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
abs.top.bottom <- ggplot(tb, aes(date, absent, color=q_cum_aikido)) + geom_point()
tardy.top.bottom <- ggplot(tb, aes(date, tardy, color=q_cum_aikido)) + geom_point()
suspend.top.bottom <- ggplot(tb, aes(date, suspend, color=q_cum_aikido)) + geom_point()

abs.tb.aov <- aov(absent ~ q_cum_aikido, data=tb)
summary(abs.tb.aov)
model.tables(abs.tb.aov,"means")

tardy.tb.aov <- aov(tardy ~ q_cum_aikido, data=tb)
summary(tardy.tb.aov)
model.tables(tardy.tb.aov,"means")

suspend.tb.aov <- aov(suspend ~ q_cum_aikido, data=tb)
summary(suspend.tb.aov)
model.tables(suspend.tb.aov,"means")

# --------------- ATTENDANCE - COMPARE OVER TIME ONLY THOSE WHO MADE IT INTO Q5 -------------------
tb <- att
q5.names <- unique(as.character(subset(att, q_cum_aikido == "Q5")$f_name))
tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
abs.q5 <- ggplot(tb, aes(date, absent, color=q_cum_aikido)) + geom_point()
tardy.q5 <- ggplot(tb, aes(date, tardy, color=q_cum_aikido)) + geom_point()
suspend.q5 <- ggplot(tb, aes(date, suspend, color=q_cum_aikido)) + geom_point()

abs.q5.aov <- aov(absent ~ q_cum_aikido, data=tb)
summary(abs.q5.aov)
model.tables(abs.q5.aov,"means")

tardy.q5.aov <- aov(tardy ~ q_cum_aikido, data=tb)
summary(tardy.q5.aov)
model.tables(tardy.q5.aov,"means")

suspend.q5.aov <- aov(suspend ~ q_cum_aikido, data=tb)
summary(suspend.q5.aov)
model.tables(suspend.q5.aov,"means")


# -- Tardy DV
tardy.aov.cum_aikido <- aov(tardy ~ q_cum_aikido, data=att)
model.tables(tardy.aov.cum_aikido, "means")
summary(tardy.aov.cum_aikido)

tardy.aov.condition <- aov(tardy ~ condition_id, data=att)
model.tables(tardy.aov.condition, "means")
summary(aov.condition)

tardy.aov.grade <- aov(tardy ~ q_grade, data=att)
model.tables(tardy.aov.grade, "means")
summary(tardy.aov.grade)


tardy.aov.full <- aov(tardy ~ q_cum_aikido * condition_id * q_grade, data=att)
model.tables(tardy.aov.full, "means")
summary(tardy.aov.full)

# -- Absent DV
absent.aov.cum_aikido <- aov(absent ~ q_cum_aikido, data=att)
model.tables(absent.aov.cum_aikido, "means")
summary(absent.aov.cum_aikido)

absent.aov.condition <- aov(absent ~ condition_id, data=att)
model.tables(absent.aov.condition, "means")
summary(aov.condition)

absent.aov.grade <- aov(absent ~ q_grade, data=att)
model.tables(absent.aov.grade, "means")
summary(absent.aov.grade)


absent.aov.full <- aov(absent ~ q_cum_aikido * condition_id * q_grade, data=att)
model.tables(absent.aov.full, "means")
summary(absent.aov.full)

# -- Suspend DV
suspend.aov.cum_aikido <- aov(suspend ~ q_cum_aikido, data=att)
model.tables(suspend.aov.cum_aikido, "means")
summary(suspend.aov.cum_aikido)

suspend.aov.condition <- aov(suspend ~ condition_id, data=att)
model.tables(suspend.aov.condition, "means")
summary(aov.condition)

suspend.aov.grade <- aov(suspend ~ q_grade, data=att)
model.tables(suspend.aov.grade, "means")
summary(suspend.aov.grade)


suspend.aov.full <- aov(suspend ~ q_cum_aikido * condition_id * q_grade, data=att)
model.tables(suspend.aov.full, "means")
summary(suspend.aov.full)

