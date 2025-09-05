library(tidyr)
library(rjd3filters)
library(publishTC)
filter_d1 <- lp_filter(degree = 0)

unwanted_ripples <- function(
        x, start = NULL, end = NULL,
        digits = 6, k = 3, m = 1){
    if (is.null(x))
        return(NULL)
    # if (is_tc_estimates(x)) {
    #     x <- x$tc
    # }
    tp <- turning_points(x, start = start, end = end, digits = digits, k = k, m = m)
    # sum(sapply(tp, function(tp_s){
    # 	sum(diff(tp_s) <= 10 / frequency(x))
    # }))
    tp <- sort(unlist(tp))
    sum(diff(tp) <= 10 / frequency(x))

}

unwanted_ripples_prp <- function(
        x, start = NULL, end = NULL,
        digits = 6, k = 3, m = 1){
    if (is.null(x))
        return(NULL)
    # if (is_tc_estimates(x)) {
    #     x <- x$tc
    # }
    tp <- turning_points(x, start = start, end = end, digits = digits, k = k, m = m)
    # sum(sapply(tp, function(tp_s){
    # 	sum(diff(tp_s) <= 10 / frequency(x))
    # }))
    tp <- sort(unlist(tp))
    sum(diff(tp) <= 10 / frequency(x)) / length(tp) * 100

}

ripples_prp <- function(
        x, start = NULL, end = NULL,
        digits = 6, k = 3, m = 1){
    if (is.null(x))
        return(NULL)
    # if (is_tc_estimates(x)) {
    #     x <- x$tc
    # }
    tp <- turning_points(x, start = start, end = end, digits = digits, k = k, m = m)
    # sum(sapply(tp, function(tp_s){
    # 	sum(diff(tp_s) <= 10 / frequency(x))
    # }))
    tp <- sort(unlist(tp))
   length(tp)

}

all_ripples <- lapply(list.files("data", pattern = "yml$",full.names = TRUE), function(spec_f){
    print(basename(spec_f))
    spec <- yaml::read_yaml(spec_f)
    data_path <- file.path(dirname(spec_f), spec$dataset)
    methods <- list.dirs(data_path, recursive = FALSE,full.names = FALSE)
    last_file <- tail(list.files(data_path, ".csv"),1)

    data <- lapply(methods, function(method) {
        all_tc <- read.ts(file.path(data_path, method, last_file), list = TRUE)
        data.frame(
            survey = tools::file_path_sans_ext(basename(spec_f)),
            series = names(all_tc),
            unwanted_ripples = sapply(all_tc, unwanted_ripples),
            method = method
        )
    })
    data <- c(
        data,
        list(
            {
                all_tc <- read.ts(file.path(data_path, last_file), list = TRUE)
                all_tc <-lapply(all_tc, function(x){
                    x *filter_d1
                })
                data.frame(
                    survey = tools::file_path_sans_ext(basename(spec_f)),
                    series = names(all_tc),
                    unwanted_ripples = sapply(all_tc, unwanted_ripples),
                    method = "H_d1"
                )
            }
        ))
    data_ripples <- do.call(rbind, data)
    data_ripples |>
        pivot_wider(
            names_from = method,
            values_from = unwanted_ripples
        )
})

all_ripples_prp <- lapply(list.files("data", pattern = "yml$",full.names = TRUE), function(spec_f){
    print(basename(spec_f))
    spec <- yaml::read_yaml(spec_f)
    data_path <- file.path(dirname(spec_f), spec$dataset)
    methods <- list.dirs(data_path, recursive = FALSE,full.names = FALSE)
    last_file <- tail(list.files(data_path, ".csv"),1)

    data <- lapply(methods, function(method) {
        all_tc <- read.ts(file.path(data_path, method, last_file), list = TRUE)
        data.frame(
            survey = tools::file_path_sans_ext(basename(spec_f)),
            series = names(all_tc),
            unwanted_ripples = sapply(all_tc, unwanted_ripples_prp),
            method = method
        )
    })
    data <- c(
        data,
        list(
            {
                all_tc <- read.ts(file.path(data_path, last_file), list = TRUE)
                all_tc <-lapply(all_tc, function(x){
                    x *filter_d1
                })
                data.frame(
                    survey = tools::file_path_sans_ext(basename(spec_f)),
                    series = names(all_tc),
                    unwanted_ripples = sapply(all_tc, unwanted_ripples_prp),
                    method = "H_d1"
                )
            }
        ))
    data_ripples <- do.call(rbind, data)
    data_ripples |>
        pivot_wider(
            names_from = method,
            values_from = unwanted_ripples
        )
})

nb_ripples <- lapply(list.files("data", pattern = "yml$",full.names = TRUE), function(spec_f){
    print(basename(spec_f))
    spec <- yaml::read_yaml(spec_f)
    data_path <- file.path(dirname(spec_f), spec$dataset)
    methods <- list.dirs(data_path, recursive = FALSE,full.names = FALSE)
    last_file <- tail(list.files(data_path, ".csv"),1)

    data <- lapply(methods, function(method) {
        all_tc <- read.ts(file.path(data_path, method, last_file), list = TRUE)
        data.frame(
            survey = tools::file_path_sans_ext(basename(spec_f)),
            series = names(all_tc),
            unwanted_ripples = sapply(all_tc, ripples_prp),
            method = method
        )
    })

    data <- c(
        data,
        list(
            {
                all_tc <- read.ts(file.path(data_path, last_file), list = TRUE)
                all_tc <-lapply(all_tc, function(x){
                    x *filter_d1
                })
                data.frame(
                    survey = tools::file_path_sans_ext(basename(spec_f)),
                    series = names(all_tc),
                    unwanted_ripples = sapply(all_tc, ripples_prp),
                    method = "H_d1"
                )
            }
        ))
    data_ripples <- do.call(rbind, data)
    data_ripples |>
        pivot_wider(
            names_from = method,
            values_from = unwanted_ripples
        )
})
library(ggplot2)
do.call(rbind, all_ripples)  |>
    pivot_longer(
        cols = -c(survey, series),
        names_to = "method",
        values_to = "unwanted_ripples"
    ) |>
    # mutate(
    #     method = factor(method, levels = c("tc", "tc_estimates", "tc_estimates_2")),
    #     survey = factor(survey, levels = c("survey1", "survey2"))
    # ) |>
    ggplot(aes(x = method, y = unwanted_ripples)) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    # geom_jitter() +
    theme(axis.text.x = element_text(angle = 90))

do.call(rbind, all_ripples_prp)  |>
    pivot_longer(
        cols = -c(survey, series),
        names_to = "method",
        values_to = "unwanted_ripples"
    ) |>
    ggplot(aes(x = method, y = unwanted_ripples)) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    # geom_jitter() +
    theme(axis.text.x = element_text(angle = 90))

do.call(rbind, nb_ripples)  |>
    pivot_longer(
        cols = -c(survey, series),
        names_to = "method",
        values_to = "unwanted_ripples"
    ) |>
    ggplot(aes(x = method, y = unwanted_ripples)) +
    geom_violin(draw_quantiles = c(0.25, 0.5, 0.75)) +
    # geom_jitter() +
    theme(axis.text.x = element_text(angle = 90))
