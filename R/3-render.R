files <- list.files(path = "data", pattern = ".yml")

# Create report files from template
qmd_files <- sapply(files, function(f) {
    data <- yaml::read_yaml(file.path("data", f))

    # Create copy of template file
    new_template <- file.path(
        "report",
        paste0(data$dataset, ".qmd")
    )
    file.copy(
        "report/template.qmd",
        new_template,
        overwrite = TRUE
    )
    template <- readLines(new_template)
    i_file <- grep("file:", template)
    template[i_file] <- gsub("IPI.yml", f, template[i_file])
    writeLines(template, new_template)

    new_template
})

qmd_files <- c(qmd_files, "report/index.qmd")

library(future)
plan(multisession)
options(future.rng.onMisuse="ignore")
fs <- list()
for (f in qmd_files){
    print(f)
    fs[[f]] <- future({
        quarto::quarto_render(f,quiet = TRUE)
    })
}
fs <- lapply(fs, FUN = future::value)
