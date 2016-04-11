library(ggplot2)

data.path <- "../Analytical-Data/"

# ----------------- PART I: LOAD IN DATA AND DO FINAL TRANSFORMS ---------------
ptsh <- read.csv(paste(data.path, "ana_point_sheet.csv", sep=""))
ptsh$date <- as.Date(ptsh$date)
att <- read.csv(paste(data.path, "ana_attendance.csv", sep=""))
dates <- sapply(1:nrow(att), function(i){paste(att[i,"year"], att[i,"month"], "01", sep="-")})
att$date <- dates

# ----------------- PART II - SIMPLE EXPLORATION ---------------
cor(ptsh$behavior_total, ptsh$academic_total) #0.9831874 - the two are essentially the same


# ----------------- PART III: HOW DO GRADE AND CONDITION AFFECT BEHAVIOR, TARDIES, ABSENCES, AND SUSPENSIONS? ------
# -- PART A: GRADE
png("../grade-behavior-dist.png")
with(ptsh, plot(q_grade, behavior_total, col="orange", pch=16,
	 xlab="Grade Level", ylab="Pt. Sheet Behavior Score (out of 50)",
	 main="Behavior Score Distributions by Grade"))
dev.off()
	 
aov.grade <- aov(behavior_total ~ q_grade, data=ptsh)
model.tables(aov.grade, "means")
summary(aov.grade)

# -- PART B: CONDITION ID
png("../condition-behavior-dist.png")	 
with(ptsh, plot(condition_id, behavior_total, col="orange", pch=16,
	 xlab="Condition ID", ylab="Pt. Sheet Behavior Score (out of 50)",
	 main="Behavior Score Distributions by Condition"))
dev.off()
	 
aov.condition <- aov(behavior_total ~ condition_id, data=ptsh)
model.tables(aov.condition, "means")
summary(aov.condition)


# ----------------- PART V: HOW DOES AMT. AIKIDO AFFECT BEHAVIOR? ----------------------------------------
# --- First Look: What is the general relationship between Aikido and behavior?
png("../cum-aikido-behavior.png")
plot(ptsh$cum_aikido, ptsh$behavior_total, col='blue', pch=16,
	   xlab="Cumulative Aikido (Num. Training Sessions)", 
	   ylab="Pt. Sheet Behavior Score (out of 50)", 
	   main="Relation Between Cumulative Aikido \nand Behavior Score")
abline(lm(ptsh$behavior_total ~ ptsh$cum_aikido), col="red", lwd=2)
dev.off()

# --- Second Look: Compare all quartiles to one another across all students
png("../qcum-behavior-time.png")
behavior.all <- ggplot(ptsh, aes(date, behavior_total, color=q_cum_aikido)) + geom_point() +
		labs(x="Date", y="Pt. Sheet Behavior Score (out of 50)", 
		    title="Behavior Scores Over Time", color="Quintile")
behavior.all
dev.off()

aov.cum_aikido <- aov(behavior_total ~ q_cum_aikido, data=ptsh)
model.tables(aov.cum_aikido, "means")
summary(aov.cum_aikido)

# --- Third Look: Compare Q1 and Q5 data ONLY for students eventually achieving Q5
tb <- ptsh
q5.names <- unique(as.character(subset(tb, q_cum_aikido == "Q5")$f_name))
tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
unique(tb$f_name) # Print names those who made it into Q5

png("../qcum-behavior-time-q5.png")
behavior.q5 <- ggplot(tb, aes(date, behavior_total, color=q_cum_aikido)) + geom_point() +
		labs(x="Date", y="Behavior Score (out of 50)", 
		    title="Behavior Scores Over Time (only students reaching Q5)", color="Quintile")
behavior.q5	
dev.off()		

ab <- aov(behavior_total ~ q_cum_aikido, data=tb)
model.tables(ab,"means")
summary(ab)
	
# ----------------- PART V: HOW DOES AMT. AIKIDO AFFECT TARDINESS, ABSENCES, AND SUSPENSIONS? --------------
png("../cum-aikido-tard-abs-sus.png")
par(mfrow = c(3, 1))
cor(att$monthly_cum_aikido, att$tardy)
plot(att$monthly_cum_aikido, att$tardy, col='blue', pch=16,
	   xlab="Cumulative Aikido at Month Start (Num. Training Sessions)", 
	   ylab="Num. Tardies in Month", 
	   main="Relation Between Cumulative Aikido \nand Monthly Tardies")
abline(lm(att$tardy ~ att$monthly_cum_aikido), col="red", lwd=2)

cor(att$monthly_cum_aikido, att$absent)
plot(att$monthly_cum_aikido, att$absent, col='blue', pch=16,
	   xlab="Cumulative Aikido at Month Start (Num. Training Sessions)", 
	   ylab="Num. Absences in Month", 
	   main="Relation Between Cumulative Aikido \nand Monthly Absences")
abline(lm(att$absent ~ att$monthly_cum_aikido), col="red", lwd=2)

cor(att$monthly_cum_aikido, att$suspend)
plot(att$monthly_cum_aikido, att$suspend, col='blue', pch=16,
	   xlab="Cumulative Aikido at Month Start (Num. Training Sessions)", 
	   ylab="Num. Suspensions in Month", 
	   main="Relation Between Cumulative Aikido \nand Monthly Suspensions")
abline(lm(att$suspend ~ att$monthly_cum_aikido), col="red", lwd=2)
dev.off()

abs.aov <- aov(absent ~ q_cum_aikido, data=att)
summary(abs.aov)
model.tables(abs.aov,"means")

tardy.aov <- aov(tardy ~ q_cum_aikido, data=att)
summary(tardy.aov)
model.tables(tardy.aov,"means")

suspend.aov <- aov(suspend ~ q_cum_aikido, data=att)
summary(suspend.aov)
model.tables(suspend.aov,"means")

# --------------- PART VI: ATTENDANCE - COMPARE OVER TIME ONLY THOSE WHO MADE IT INTO Q5 -------------------
tb <- att
q5.names <- unique(as.character(subset(att, q_cum_aikido == "Q5")$f_name))
tb <- tb[which(is.element(as.character(tb$f_name), q5.names)),]
abs.q5 <- ggplot(tb, aes(date, absent, color=q_cum_aikido)) + geom_point()
tardy.q5 <- ggplot(tb, aes(date, tardy, color=q_cum_aikido)) + geom_point()
suspend.q5 <- ggplot(tb, aes(date, suspend, color=q_cum_aikido)) + geom_point()

tardy.q5.aov <- aov(tardy ~ q_cum_aikido, data=tb)
summary(tardy.q5.aov)
model.tables(tardy.q5.aov,"means")


