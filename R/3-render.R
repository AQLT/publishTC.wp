files <- list.files(path = "data", pattern = ".yml")
files <- sapply(files, function(f) {
    data <- yaml::read_yaml(file.path("data", f))
    file.path(
        "report",
        paste0(data$dataset, ".qmd")
    )
})

library(future)
plan(multisession)
options(future.rng.onMisuse="ignore")
fs <- list()
for (f in files){
    print(f)
    fs[[f]] <- future({
        quarto::quarto_render(f,quiet = TRUE)
    })
}
fs <- lapply(fs, FUN = future::value)
