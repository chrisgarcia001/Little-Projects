# Note - this uses the restriktor package for constrained regression.
#      Available at: http://www.restriktor.ugent.be/

library('restriktor') # Used for the constrained regression.


data <- read.csv('ss-data.csv')

# --------------- Part 1: Data Preprocessing --------------------------
recode <- function(vec, from.vals, to.vals) {
	f = function(v) {
		for(i in 1:length(from.vals)) {
			if(v == from.vals[i]) { return(to.vals[i]) }
		}
		return(v)
	}
	return(sapply(as.vector(vec), f))
}

# Function for imputing mean of a vector to its missing values.
impute.mean <- function(vec) {
	vec[is.na(vec)] = mean(vec, na.rm=TRUE)
	vec
}

# Function for imputing value of 0 to each missing value in the vector.
impute.0 <- function(vec) {
	vec[is.na(vec)] = 0
	vec
}
# Clean and recode numeric columns.
numeric.columns <- colnames(data)[8:ncol(data)]
for(col in numeric.columns) {
	data[[col]] <- as.numeric(as.character(data[[col]]))
}

imputer.f <- impute.0 # Missing value imputation function - can change if needed

# Impute missing values to component scores and print out the percent missing in each column.
for(i in 8:20) {
	message(paste('Percent Missing Values for Column "', colnames(data)[i], '": ', 100*(1 - (length(sort(data[[i]]))/nrow(data)))))
	data[[i]] <- imputer.f(data[[i]])
}

# Properly binarize binary columns.
data$Statewide.High.Priority <- as.numeric(sapply(data$Statewide.High.Priority, function(x){if(x == 'x') return(1); return(0);}))
data$District.Grant <- as.numeric(sapply(data$District.Grant, function(x){if(x == 'x') return(1); return(0);}))

# --------------- Part 2: Data Exploration --------------------------

# Explore distributions of different projects.
table(data$Area.Type)
table(data$District)

ss.mean <- mean(data$SMART.SCALE.Score, na.rm=TRUE)
ss.sd <- sd(data$SMART.SCALE.Score, na.rm=TRUE)

aggregate(data$SMART.SCALE.Score ~ data$Area.Type, FUN=mean)
aggregate(data$SMART.SCALE.Score ~ data$District, FUN=mean)

# Look at project-based score data. 
pscore.data <- data[21:ncol(data)]
nrow(na.omit(pscore.data)) / nrow(pscore.data)  # Percent of rows without any missing project-based score data
cor(na.omit(pscore.data)) # Look at correlations that exist among project-based score measures

plot(1:length(sort(data$SMART.SCALE.Score)), sort(data$SMART.SCALE.Score), col='blue', pch=16) # See shape of SSS curve
plot(1:length(sort(data$SMART.SCALE.Score)), log(sort(data$SMART.SCALE.Score)), col='blue', pch=16) # See with log transform 

# SSS by benefit ranks.
plot(data$Benefit.Rank, data$SMART.SCALE.Score, col='blue', pch=16) 
plot(data$State.Rank, data$SMART.SCALE.Score, col='blue', pch=16) 
plot(data$District.Rank, data$SMART.SCALE.Score, col='blue', pch=16) 

# --------------- Part 3: Investigating Smart Scale Calculation --------------------------
# Look at Smart Scale Score fit by area type.
# In this section we use regression to calculate the actual weights of each factor by area type. These
# can be then compared to the stated weights in the technical guide to see if they are in fact consistent.

# For a given data frame, a set of weights, and a set of selected columns, this function returns a new
# vector corresponding to the weighted averages of the columns.
weighted.column.average <- function(data.frame, weight.vec, selected.columns) {
	v <- rep(0, nrow(data.frame))
	for(i in 1:length(weight.vec)) {
		v <- v + (weight.vec[i] * data.frame[[selected.columns[i]]])
	}
	v
}

# Calculate the composite factor scores (except Land Use, which is APPARENTLY already given in the data) from 
# component scores according to the Smart Scale November 2017 technical guide.
data$Safety.Score <- weighted.column.average(data, c(0.5, 0.5), c('Crash.Frequency.Score', 'Crash.Rate.Score'))
data$Congestion.Score <- weighted.column.average(data, c(0.5, 0.5), c('Throughput.Score', 'Delay.Score'))
data$Accessibility.Score <- weighted.column.average(data, c(0.5, 0.5), c('Access.to.Jobs', 'Disadvantaged.Access.to.Jobs', 'Multimodal.Access.Score'))
data$Environmental.Score <- weighted.column.average(data, c(0.5, 0.5), c('Air.Quality.Score', 'Enviro.Impact.Score'))
data$Economic.Score <- weighted.column.average(data, c(0.5, 0.5), c('Econ.Dev.Support.Score', 'Intermodal.Access.Score', 'Travel.Time.Reliability.Score'))
# Land use score already in data - no component scores listed.




# This function uses constrained regression to reconstruct the weighting coefficients for a set of SS projects. Returns the fitted constrained model.
ss.reconstruction <- function(dataset) {
  # Set the linear regression equation form
  reg.form <- SMART.SCALE.Score ~ Safety.Score + Congestion.Score + Accessibility.Score + Environmental.Score + Economic.Score + Land.Use.Score + 0
  
  # Build a constrained regression model to find the best fit given that 1) 0 <= each variable <= 1, and 2) sum(variables) = 1			
  constraints <- 'Safety.Score > 0
				          Congestion.Score > 0
                  Accessibility.Score > 0
				          Environmental.Score > 0
				          Economic.Score > 0
                  Safety.Score + Congestion.Score + Accessibility.Score + Environmental.Score + Economic.Score + Land.Use.Score == 1'				
  fit <- lm(reg.form, data=dataset)
  restriktor(fit, constraints = constraints)
}


# Split out data sets by area type.
ta <- subset(data, Area.Type == 'A')
tb <- subset(data, Area.Type == 'B')
tc <- subset(data, Area.Type == 'C')
td <- subset(data, Area.Type == 'D')

rs.a <- ss.reconstruction(ta)
summary(rs.a)
rs.b <- ss.reconstruction(tb)
summary(rs.b)
rs.c <- ss.reconstruction(tc)
summary(rs.c)
rs.d <- ss.reconstruction(td)
summary(rs.b)



