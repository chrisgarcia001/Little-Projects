# -------------------------------------------------------------------------
# @author: cgarcia
# This contains some basic commonly-used functions, implemented in R.
# -------------------------------------------------------------------------

# Count all elements in items which meet the specified criteria.
count <- function(criteria.f, items) {
	ct <- 0
	for(item in items) {
		if(criteria.f(item)) {ct <- ct + 1}
	}
	ct
}

# Reduce using the 2-arity function f (folds from left).
reduce <- function(f, items, identity=0) {
	if(length(items) == 0) {return(identity)}
	total <- items[1]
	for(i in 2:length(items)) {
		total <- f(total, items[i])
	}
	total
}

# Join a vector of items together into a single string. Similar to paste, 
# but takes a vector of items rather than the items.
vec_join <- function(str_vec, sep=' ') {
	reduce(function(x,y){paste(x,y,sep=sep)}, str_vec)
}



has_substr <- function(pattern, string) {
	
}