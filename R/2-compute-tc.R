library(publishTC)
# source("R/0-functions.R")
for (spec_f in list.files("data", pattern = "yml$",full.names = TRUE)){
	print(basename(spec_f))
	spec <- yaml::read_yaml(spec_f)
	data_path <- file.path(dirname(spec_f), spec$dataset)
	list_files <- list.files(pattern = "csv$", path = data_path, full.names = TRUE, include.dirs = FALSE)
	for (vintage in list_files) {
		if (length(list.files(pattern = basename(vintage), path = data_path, recursive = TRUE)) > 1)
			next; # already estimated
		y <- read.ts(vintage, list = TRUE)
		all_est <- lapply(names(y), function(series){
			spec_s <- spec$series[[series]]
			x <- window(y[[series]], start = spec_s$first_date)
			res <- smoothing(x = x,
					  length = spec_s$length,
					  ao = spec_s$outliers$ao,
					  ao_tc = spec_s$outliers$ao_tc,
					  ls = spec_s$outliers$ls)
			do.call(ts.union, lapply(res, `[[`, "tc"))
		})
		names(all_est) <- names(y)
		by_methods <- lapply(colnames(all_est[[1]]), function(method){
			do.call(ts.union, lapply(all_est, function(est){
				est[, method]
			}))
		})
		names(by_methods) <- colnames(all_est[[1]])
		for (method in names(by_methods)) {
			if (!dir.exists(file.path(data_path, method)))
				dir.create(file.path(data_path, method))

			write.ts(
				by_methods[[method]],
				file = file.path(data_path, method, basename(vintage))
			)
		}
	}
}
