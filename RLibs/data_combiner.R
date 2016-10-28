# This provides a short function to combine data files in
# a directory into a single file.

library(stringr)

combine.data <- function(path='./', output.file='output.csv') {
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
	write.csv(dframe, output.file, row.names=FALSE)
}

