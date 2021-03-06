library(sqldf)
library(dplyr)

data.path <- "../CSV/"
output.path <- "../Analytical-Data/"

# ------------------- AUXILIARY SQL -----------------------------------
aux.sql.1 <- 'SELECT * FROM ptsh WHERE attended_aikido == 1'
# ---------------------------------------------------------------------

# ------------------- AUXILIARY FUNTIONS ------------------------------

recoder.f <- function(matches, new.val) {
	function(x) { 
		if(is.element(x, matches))
			return(new.val)
		return(x)
	}
}

range.recoder.f <- function(lower.ranges, new.vals, default=NA) {
	function(x) {
		if(!is.na(x)) {
			for(i in 1:length(lower.ranges)) {
				if(x <= lower.ranges[i]) {return(new.vals[i])}
			}
		}
		return(default)
	}
}

labeled.quantiles <- function(nums, qtile=0.2) {
	sv <- sort(nums)
	binner <- function(val) {
		curr.qtile <- qtile
		count <- 1
		while((val > sv[ceiling(length(sv) * curr.qtile)]) & (curr.qtile < 1)) {
			curr.qtile <- curr.qtile + qtile
			count <- count + 1
		}
		paste("Q", count, sep="")
	}
	sapply(nums, binner)
}

ordered.bin.labels <- function(n, num.bins = 2) {
	labeled.quantiles(1:n, qtile=1/num.bins)
}

years.diff <- function(ref.date, test.date) {
	days <- as.Date(ref.date) - as.Date(test.date)
	floor(days / 365)
}


# ---------------------------------------------------------------------
# STEP 1: BUILD ACADEMIC/BEHAVIORAL ANALYTICAL DATA
# ---------------------------------------------------------------------
aikido_att <- read.csv(paste(data.path, "aikido-attendance-data.csv", sep=""))
sch_att <- read.csv(paste(data.path, "attendance-sheet-data.csv", sep=""))
pt_sheet <- read.csv(paste(data.path, "point-sheet-data.csv", sep=""))
st_info <- subset(read.csv(paste(data.path, "student-info.csv", sep="")), Grade > 5) 
st_info$f_name <- st_info$First.Name
st_info$condition_id <- st_info$Condition.ID

pt_sheet <- subset(pt_sheet, year != -1)
#pt_sheet <- subset(pt_sheet, ((academic_total > 0) & (behavior_total > 0)))


aikido_att$attended_aikido <- rep(1, nrow(aikido_att))

sql1 <- 'SELECT pt_sheet.*, aikido_att.attended_aikido
		 FROM pt_sheet LEFT OUTER JOIN aikido_att
         ON (pt_sheet.f_name == aikido_att.Name) AND (pt_sheet.date == aikido_att.Date)'

ptsh <- sqldf(sql1)
ptsh$attended_aikido <- sapply(ptsh$attended_aikido, recoder.f(NA, 0))

sql2 <- 'SELECT ptsh.*, st_info.Grade, st_info.condition_id
         FROM ptsh LEFT OUTER JOIN st_info
		 ON ptsh.f_name == st_info.f_name'
		 
ptsh <- sqldf(sql2)

# Remove potentially questionable rows 
ptsh <- subset(ptsh, !is.na(condition_id))

# Exclude absences here - dealt with in attendance dataset.
ptsh <- ptsh[which(ptsh$behavior_total != 0),]  

##Calculate Cumulative Aikido Exposure
ptsh$date <- as.Date(ptsh$date, format='%m/%d/%Y')
ptsh <- arrange(ptsh, f_name, date)
ptsh$cum_aikido <- rep(0, nrow(ptsh))
curr.name <- '-'
for(i in 1:nrow(ptsh)) {
	if(ptsh[i, "f_name"] == curr.name) { 
		ptsh[i, "cum_aikido"] <- ptsh[i - 1, "cum_aikido"] + ptsh[i, "attended_aikido"]
		
	}
	else { 
		ptsh[i, "cum_aikido"] <- ptsh[i, "attended_aikido"] 
		curr.name <- ptsh[i, "f_name"]
		#message(paste(i, "Updating"))
	}
}

### Mark Day Before/After/Of
ptsh$aikido_day_before <- rep(0, nrow(ptsh))
ptsh$aikido_day_after <- rep(0, nrow(ptsh))
ptsh$aikido_day_of <- rep(0, nrow(ptsh))
for(i in 1:nrow(ptsh)) {
	if((i > 1) && (ptsh[i, "f_name"] == ptsh[i - 1, "f_name"]) && (ptsh[i - 1, "attended_aikido"] == 1)) {
	   ptsh[i, "aikido_day_after"] <- 1
	}
	if((i < nrow(ptsh)) && (ptsh[i, "f_name"] == ptsh[i + 1, "f_name"]) && (ptsh[i + 1, "attended_aikido"] == 1)) {
	   ptsh[i, "aikido_day_before"] <- 1
	}
	if(ptsh[i, "attended_aikido"] == 1) {
	   ptsh[i, "aikido_day_of"] <- 1
	}
}

ptsh$date <- as.Date(ptsh$date)

# Re-code day before/after/of status
aikido.day.status <- rep(NA, nrow(ptsh))
for(i in 1:nrow(ptsh)) {
	if(ptsh[i,"aikido_day_before"] == 1) {aikido.day.status[i] <- "DayBefore"}
	if(ptsh[i,"aikido_day_after"] == 1) {aikido.day.status[i] <- "DayAfter"}
	if(ptsh[i,"aikido_day_of"] == 1) {aikido.day.status[i] <- "DayOf"}
	
}
ptsh$aikido_day_status <- aikido.day.status


### Quantiles for aikido exposure
ptsh$q_cum_aikido <- labeled.quantiles(ptsh$cum_aikido)

### Adjust grade levels for academic year - initial grades are in 2015-16 AY.
curr.year.start <- as.Date("2015-08-01")
year.delta <- sapply(ptsh$date, function(x){years.diff(curr.year.start, x)})
ptsh$Grade <- ptsh$Grade - year.delta

### Set grade labels
code.grade <- range.recoder.f(c(8,10,12), c("Middle School", "Lower High School", "Upper High School"))
ptsh$q_grade <- sapply(ptsh$Grade, code.grade)

# 2014-15 behavior/academic totals max out at 45, while 2015-16 max out at 50. Scale appropriately.
for(i in 1:nrow(ptsh)) {
	if((ptsh[i,"year"] < 2015) | ((ptsh[i,"month"] <= 6) & ptsh[i,"year"] == 2015)) {
		ptsh[i,"behavior_total"] <- min(50, (50/45) * ptsh[i,"behavior_total"])
		ptsh[i,"academic_total"] <- min(50, (50/45) * ptsh[i,"academic_total"])
	}
}


# Control for differences in person   - EXPERIMENTAL
# agg_pers_tmp <- group_by(ptsh, f_name)
# agg_pers <- summarize(agg_pers_tmp, a.mean=mean(academic_total), a.sd=sd(academic_total),
									# b.mean=mean(behavior_total), b.sd=sd(behavior_total))
# adj_behavior <- c()
# adj_academic <- c()

# for(i in 1:nrow(ptsh)) {
	# aa <- (ptsh[i,"academic_total"] - subset(agg_pers, f_name == ptsh[i,"f_name"])$a.mean) / subset(agg_pers, f_name == ptsh[i,"f_name"])$a.sd
	# #adj_behavior[i] <- 
# }


# ---------------------------------------------------------------------
# STEP 2: BUILD ATTENDANCE DATA
# ---------------------------------------------------------------------
att <- read.csv(paste(data.path, "attendance-sheet-data.csv", sep=""))
agg_ptsh_tmp <- group_by(ptsh, f_name, month, year)
agg_ptsh <- summarize(agg_ptsh_tmp, monthly_cum_aikido = mean(cum_aikido), 
					                grade = first(Grade),
									q_grade = first(q_grade), 
									condition_id = first(condition_id),
									q_cum_aikido = first(q_cum_aikido))

sql3 <- 'SELECT agg_ptsh.*, att.* 
		 FROM agg_ptsh LEFT OUTER JOIN att
         ON (agg_ptsh.f_name == att.first_name) AND (agg_ptsh.month == att.month) AND (agg_ptsh.year == att.year)'
		 
att_data <- sqldf(sql3)
att_data$absent <- sapply(att_data$absent, recoder.f(NA, 0))
att_data$tardy <- sapply(att_data$tardy, recoder.f(NA, 0))
att_data$suspend <- sapply(att_data$suspend, recoder.f(NA, 0))
att_data$q_cum_aikido <- sapply(att_data$q_cum_aikido, recoder.f(NA, "Q1"))
att_data <- subset(att_data, ((year != -1) & (month != -1)))

# ---------------------------------------------------------------------
# STEP 3: WRITE FINAL ANALYTICAL DATA SHEETS
# ---------------------------------------------------------------------
write.csv(ptsh, paste(output.path, "ana_point_sheet.csv", sep=""), row.names=FALSE)
write.csv(att_data, paste(output.path, "ana_attendance.csv", sep=""), row.names=FALSE)