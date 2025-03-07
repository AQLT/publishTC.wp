lectureBDM<-function(idbank, ...)
{
    #On récupère les idbank et on supprime les éventuels espaces
    idbank<-gsub(" ","",c(idbank,unlist(list(...))))

    #Les url pour télécharger le(s) série(s)
    UrlData <- paste0("https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/",paste(idbank,collapse = "+"))

    tryCatch({
        dataBDM <- as.data.frame(rsdmx::readSDMX(UrlData,isURL = T),
                                 stringsAsFactors=TRUE)
    },error=function(e){
        stop(paste0("Il y a une erreur dans le téléchargement des données. Vérifier le lien\n",UrlData),
             call. = FALSE)
    })

    FREQ <- levels(factor(dataBDM$FREQ))

    if (length(FREQ)!=1)
        stop("Les séries ne sont pas de la même périodicité !")

    freq<-switch(FREQ
                 ,M=12
                 ,B=6
                 ,T=4
                 ,S=2
                 ,A=1)
    #On détermine le format de la colonne qui contient les dates en fonction de la fréquence
    sepDate<-switch(FREQ
                    ,M="-"
                    ,B="-B"
                    ,T="-Q"
                    ,S="-S"
                    ,A=" ")
    dataBDM <- dataBDM |>
        dplyr::select(TIME_PERIOD, IDBANK, OBS_VALUE) |>
        tidyr::pivot_wider(names_from = IDBANK,
                           values_from = OBS_VALUE) |>
        dplyr::arrange(TIME_PERIOD)

    #On récupère la première date
    dateDeb <- dataBDM$TIME_PERIOD[1]
    dateDeb <- regmatches(dateDeb,gregexpr(sepDate,dateDeb),invert=T)[[1]]
    dateDeb <- as.numeric(dateDeb)

    #On supprime la colonne des dates et on convertit les séries en numérique
    dataBDM$TIME_PERIOD <- NULL
    dataBDM <- apply(dataBDM,2,as.numeric)

    if(ncol(dataBDM) != length(idbank))
        warning(paste("Le ou les idbank suivant n'existent pas :",
                      paste(grep(paste(colnames(dataBDM),collapse="|"),idbank,value=T,invert = T),
                            collapse=", ")))
    if(ncol(dataBDM) > 1){
        # On a au moins 2 colonnes : on replace les colonnes dans le même ordre que les séries en entrée
        idbank <- idbank[idbank %in% colnames(dataBDM)] #On ne garde que les idbank présents dans la base
        dataBDM <- dataBDM[,idbank]
    }
    dataBDM <- ts(dataBDM,start=dateDeb, frequency =freq)
    return(dataBDM)
}
