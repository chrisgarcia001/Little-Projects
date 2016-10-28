# This provides a short function to combine data files in
# a directory into a single file.

library(stringr)

combine.data <- function(path='./', output.file=NULL) {
	if(!endsWith(path, '/')) { path <- paste(path, '/', sep='') }
	files <- dir(path)
	dframe <- NULL
	for(filename in files) {
		if(endsWith(filename, 'csv')) {
			nframe <- read.csv(paste(path, filename, sep=''))
			if(is.null(dframe)) {dframe <- nframe}
			else {dframe <- rbind(dframe, nframe)}
		}
	}
	if(!is.null(output.file)) {
		write.csv(dframe, output.file, row.names=FALSE)
	}
	dframe
}


# Assume a set of instance result names: result_X_1, result_X_2, ..., result_Y_1, result_Y_2, ...
# and assume these are contained in instance.labels. Strip off the ending numbers
# from each result instance name and just return the classes 
# (i.e. result_X, result_X, ... result_Y, ...)
# Example: > aggregate.labels(c('result_x_1', 'result_x_2', 'result_y_1', 'result_y_2'), splitter='_')
#            --> [1] "result_x" "result_x" "result_y" "result_y"
aggregate.labels <- function(instance.labels, splitter='_') {
	f <- function(s) {
		ps <- str_split(s, '_')[[1]]
		paste(ps[1:(length(ps) - 1)], collapse=splitter)
	}
	as.vector(sapply(instance.labels, f))
}

# Example of how to use the above to combine and analyse data in scheduling problem results analysis:
# > sm <- combine.data('./solutions')
# > sm$AID <- as.factor(aggregate.labels(sm$Problem.ID))
# > a.mean <- aggregate(Elapsed.Time ~ AID, sm, FUN=mean)
# > a.median <- aggregate(Elapsed.Time ~ AID, sm, FUN=median) 
# > a.min <- aggregate(Elapsed.Time ~ AID, sm, FUN=min) 
# > a.max <- aggregate(Elapsed.Time ~ AID, sm, FUN=max) 
# > agg.summary <- cbind(a.mean, a.median, a.min, a.max)
# > agg.summary <- cbind(a.mean, a.median$Elapsed.Time, a.min$Elapsed.Time, a.max$Elapsed.Time)
# > colnames(agg.summary) <- c('Problem.Class', 'Mean', 'Median', 'Min', 'Max')
# > head(agg.summary)
# > write.csv(agg.summary,'AGGREGATED-SUMMARY.CSV', row.names=FALSE)