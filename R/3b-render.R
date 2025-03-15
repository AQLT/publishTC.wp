files <- list.files(path = "data", pattern = ".yml")
files <- sapply(files, function(f) {
    data <- yaml::read_yaml(file.path("data", f))
    file.path(
        "report",
        paste0(data$dataset, ".qmd")
    )
})

for (f in files){
    print(f)
    quarto::quarto_render(f,quiet = TRUE)
}
