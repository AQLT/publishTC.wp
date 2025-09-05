library(publishTC)
library(rjd3filters)
library(tidyr)

filter_d1 <- lp_filter(degree = 0)
nrev <- 6
tot_rev <- lapply(list.files("data", pattern = "yml$",full.names = TRUE), function(spec_f){
    print(basename(spec_f))
    spec <- yaml::read_yaml(spec_f)
    data_path <- file.path(dirname(spec_f), spec$dataset)
    methods <- list.dirs(data_path, recursive = FALSE,full.names = FALSE)
    first_file <- list.files(data_path, ".csv")[1]
    last_file <- tail(list.files(data_path, ".csv"),1)

    data <- lapply(methods, function(method) {

        all_tc_first <- read.ts(file.path(data_path, method, first_file), list = FALSE)
        all_tc_last <- read.ts(file.path(data_path, method, last_file), list = FALSE)
        rev <- (all_tc_last - all_tc_first[,colnames(all_tc_last)]) / all_tc_first[,colnames(all_tc_last)] * 100
        colnames(rev) <- colnames(all_tc_last)
        rev <- rev[,seq(min(ncol(rev) - nrev,1) , ncol(rev) - 1)]

        # rev[!apply(round(rev,5)==0,1, all),]
        data.frame(
            survey = tools::file_path_sans_ext(basename(spec_f)),
            method = method,
            dates = as.numeric(time(rev)),
            apply(rev,2, as.numeric)
        )
    })
    data <- c(
        data,
        list(
            {
                all_tc_first <- read.ts(file.path(data_path, first_file), list = FALSE)
                all_tc_last <- read.ts(file.path(data_path, last_file), list = FALSE)
                rev <- (all_tc_last * filter_d1 - all_tc_first[,colnames(all_tc_last)] * filter_d1) / (all_tc_first[,colnames(all_tc_last)] * filter_d1) * 100
                colnames(rev) <- colnames(all_tc_last)
                rev <- rev[,seq(min(ncol(rev) - nrev,1) , ncol(rev) - 1)]

                # rev[!apply(round(rev,5)==0,1, all),]
                data.frame(
                    survey = tools::file_path_sans_ext(basename(spec_f)),
                    method = "H_d1",
                    dates = as.numeric(time(rev)),
                    apply(rev,2, as.numeric)
                )
            }
        ))
    data_ripples <- do.call(
        rbind,
        data
    )
    data_ripples |>
        pivot_longer(
            cols = -c(survey, method, dates),
            names_to = "series",
            values_to = "revision"
        ) |>
        pivot_wider(
            names_from = method,
            values_from = revision
        )
})
library(ggplot2)
do.call(rbind, tot_rev)  |>
    pivot_longer(
        cols = -c(survey, series, dates),
        names_to = "method",
        values_to = "Revisions"
    ) |>
    # mutate(
    #     method = factor(method, levels = c("tc", "tc_estimates", "tc_estimates_2")),
    #     survey = factor(survey, levels = c("survey1", "survey2"))
    # ) |>
    ggplot(aes(x = method, y = Revisions)) +
    geom_boxplot() +
    # geom_jitter() +
    theme(axis.text.x = element_text(angle = 90))
