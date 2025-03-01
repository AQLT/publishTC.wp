sheets <- openxlsx::getSheetNames("Data.xlsx")
sheets <- sheets[1:3]
# for (s in sheets){
# 	if (!dir.exists(file.path("data", s)))
# 		dir.create(file.path("data", s))
# 	data <- openxlsx::readWorkbook("Data.xlsx",sheet = s)
# 	data <- data[,2:1]
# 	if (any(nchar(data$idBank) < 9)) {
# 		non_complete <- which(nchar(data$idBank) < 9)
# 		for (i in non_complete) {
# 			data$idBank[i] <- paste0(
# 				paste0(rep("0", 9 - nchar(data$idBank[i])), collapse = ""),
# 				data$idBank[i])
# 		}
# 	}
# 	res <- data$idBank
# 	names(res) <- data$label
# 	dput(res,
# 		 file = file.path("data", s, "0-download_data.R")
# 	)
# }

sheets <- openxlsx::getSheetNames("Data.xlsx")
# Nombre de séries étudiées
sapply(sheets, function(s){
	nrow(openxlsx::readWorkbook("Data.xlsx",sheet = s))
}) |> sum()
for (s in sheets){
	if (!dir.exists(file.path("data", s)))
		dir.create(file.path("data", s))
	data <- openxlsx::readWorkbook("Data.xlsx",sheet = s)
	data <- data[,2:1]
	if (any(nchar(data$idBank) < 9)) {
		non_complete <- which(nchar(data$idBank) < 9)
		for (i in non_complete) {
			data$idBank[i] <- paste0(
				paste0(rep("0", 9 - nchar(data$idBank[i])), collapse = ""),
				data$idBank[i])
		}
	}
	res <- data$idBank
	names(res) <- data$label
	c(sprintf("dataset: %s", s),
	  "series:",
	  sprintf('  %s: "%s"', data$label, data$idBank)
	) |> cat(
		file = file.path("data", sprintf("%s.yml", s)),
		sep = "\n"
	)
}

## NEW TEMPLATE
sheets <- openxlsx::getSheetNames("Data.xlsx")
sheets <- sheets[1:3]
for (s in sheets){
	if (!dir.exists(file.path("data", s)))
		dir.create(file.path("data", s))
	data <- openxlsx::readWorkbook("Data.xlsx",sheet = s)
	data <- data[, c("label", "idbank", "description")]
	if (any(nchar(data$idbank) < 9)) {
		non_complete <- which(nchar(data$idbank) < 9)
		for (i in non_complete) {
			data$idbank[i] <- paste0(
				paste0(rep("0", 9 - nchar(data$idbank[i])), collapse = ""),
				data$idbank[i])
		}
	}
	rownames(data) <- data$label
	# res <- data$idbank
	# names(res) <- data$label
	data_s <- lapply(data$label, function(label){
		list(idbank = data[label, "idbank"],
			 description = data[label, "description"],
			 outliers = list(ao = NULL, ao_tc = NULL, ls = NULL),
			 first_date = 2012,
			 length = 13
			 )
	})
	names(data_s) <- tolower(data$label)
	list(dataset = s,
		 datasetname = s,
		 series = data_s
		 ) |>
		yaml::write_yaml(file = file.path("data", sprintf("%s.yml", s)))
}

all_yml <- list.files(path = "data", "yml", full.names = TRUE)
all_yml <- file.path("data", paste0(c("CONSO", "ENT", "ICAM"), ".yml"))
for (yml_f in all_yml) {
	print(yml_f)
	yml_data <- yaml::read_yaml(yml_f)
	dir <- gsub("\\.yml$", "", yml_f)
	all_f <- list.files(path = dir, pattern = "csv", full.names = TRUE,recursive = TRUE)
	data <- read.ts(all_f[1])
	for (series in colnames(data)) {
		print(series)
		y <- data[, series]
		y <- window(y, start = yml_data$series[[series]]$first_date)

		out <- rjd3x13::regarima_outliers(y, seasonal = c(0, 0, 0, 0))$model$variables
		if (!is.null(out)) {
			out <- do.call(
				rbind,
				lapply(strsplit(out, "\\."), function(x){
					data.frame(
						out = tolower(x[1]),
						date = time(y)[as.numeric(x[2])]
					)
				})
			)
			out <- out[order(out$out, out$date), ]
			all_out <- split(out$date, out$out)
			for (nout in names(all_out)){
				yml_data$series[[series]]$outliers[[nout]] <- all_out[[nout]]
			}
		}

	}
	yaml::write_yaml(yml_data, yml_f)
}

files <- list.files(path = "data", pattern = ".yml")
for (f in files){
	data <- yaml::read_yaml(file.path("data", f))
	for (s in names(data$series)) {
		data$series[[s]]$methods <- NULL
		data$series[[s]]$plots <- NULL
	}
	data$plots <- NULL
	data$methods <-
		list(henderson = list(
			name = "Henderson",
			eval = TRUE),
			henderson_localic = list(
				name = "Henderson local I/C",
				eval = TRUE),
			henderson_robust = list(
				name = "Henderson (robust)",
				eval = FALSE),
			henderson_robust_localic = list(
				name = "Henderson (robust)\nlocal I/C",
				eval = TRUE),
			clf_cn = list(
				name = "CLF and cut-and-normalize",
				eval = TRUE),
			clf_alf = list(
				name = "CLF and alf",
				eval = FALSE))
	data$plots <-
		list(nyears = 4,
			 digits = 2,
			 bymethods = list(
			 	enabled = TRUE,
			 	name = "By methods"
			 ),
			 byplots = list(
			 	enabled = TRUE,
			 	name = "By kind of plots"
			 ),
			 kind = list(normal = TRUE,
			 			confint = TRUE,
			 			lollypop = TRUE,
			 			implicit_forecasts = TRUE),
			 comparison_plot =  list(
			 	enabled = TRUE,
			 	interactive = TRUE,
			 	name = "Comparison of methods"
			 ),
			 revision_history = list(
			 	enabled = TRUE,
			 	name = "Analysis of revisions",
			 	table = list(
			 		enabled = TRUE,
			 		contribution_of_sa = TRUE
			 	)
			 	),
			 extra_info = list(
			 	enabled = TRUE,
			 	name = "Extra informations"
			 )
		)

	data$revision_history <- NULL
	data |>
		yaml::write_yaml(file = file.path("data", f))
}

