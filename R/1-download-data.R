library(publishTC)
source("R/0-functions.R")
for (spec in list.files("data", pattern = "yml$",full.names = TRUE)){
	data <- yaml::read_yaml(spec)
	if (!dir.exists(file.path("data", data$dataset)))
		dir.create(file.path("data", data$dataset))

	data_insee <- lectureBDM(sapply(data$series, `[[`, "idbank"))
	colnames(data_insee) <- names(data$series)
	last_date <- format(zoo::as.Date(time(data_insee)), "%Y_%m")
	last_date <- last_date[length(last_date)]
	file <- sprintf(
		"data/%s/%s.csv",
		data$dataset,
		last_date
	)
	if (file.exists(file))
		next;
	write.ts(data_insee, file)
}


# data_lb <- do.call(rbind, lapply(list.files("data", pattern = "yml$",full.names = TRUE), function(spec){
# 	data <- yaml::read_yaml(spec)
#
# 	UrlData <- paste0("https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/",
# 					  paste(data$series[[1]]$idbank, collapse = "+"))
# 	dataBDM <- as.data.frame(rsdmx::readSDMX(UrlData, isURL = T),
# 							 stringsAsFactors = TRUE)
# 	data.frame(spec, strsplit(dataBDM$TITLE_FR[1], "-")[[1]][1])
# }))
# View(data_lb)
