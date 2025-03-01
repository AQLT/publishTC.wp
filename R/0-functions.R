lectureBDM <- function (idbank, ...) {
	idbank <- gsub(" ", "", c(idbank, unlist(list(...))))
	UrlData <- paste0("https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/",
					  paste(idbank, collapse = "+"))
	tryCatch({
		dataBDM <- as.data.frame(rsdmx::readSDMX(UrlData, isURL = T),
								 stringsAsFactors = TRUE)
	}, error = function(e) {
		stop(paste0("Il y a une erreur dans le téléchargement des données. Vérifier le lien\n",
					UrlData), call. = FALSE)
	})
	FREQ <- levels(factor(dataBDM$FREQ))
	if (length(FREQ) != 1)
		stop("Les séries ne sont pas de la même périodicité !")
	freq <- switch(FREQ, M = 12, B = 6, T = 4, S = 2, A = 1)
	sepDate <- switch(FREQ, M = "-", B = "-B", T = "-Q", S = "-S",
					  A = " ")
	dataBDM <- reshape2::dcast(dataBDM, "TIME_PERIOD ~ IDBANK",
							   value.var = "OBS_VALUE")
	dataBDM <- dataBDM[order(dataBDM$TIME_PERIOD), ]
	dateDeb <- dataBDM$TIME_PERIOD[1]
	dateDeb <- regmatches(dateDeb, gregexpr(sepDate, dateDeb),
						  invert = T)[[1]]
	dateDeb <- as.numeric(dateDeb)
	dataBDM$TIME_PERIOD <- NULL
	dataBDM <- apply(dataBDM, 2, as.numeric)
	if (ncol(dataBDM) != length(idbank))
		warning(paste("Le ou les idbank suivant n'existent pas :",
					  paste(grep(paste(colnames(dataBDM), collapse = "|"),
					  		   idbank, value = T, invert = T), collapse = ", ")))
	if (ncol(dataBDM) > 1) {
		idbank <- idbank[idbank %in% colnames(dataBDM)]
		dataBDM <- dataBDM[, idbank]
	}
	dataBDM <- ts(dataBDM, start = dateDeb, frequency = freq)
	return(dataBDM)
}
