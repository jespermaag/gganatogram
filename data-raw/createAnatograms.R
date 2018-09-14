library(ggplot2)
library(dplyr)
library(ggpolypath)



extractCoords <- function(coords, name, transMatrix) {
    c <- strsplit(coords, " ")
    c[[1]]

    c[[1]][c(grep("M", c[[1]] )+1,grep("M", c[[1]] )+2)] <- NA

    c[[1]] <- c[[1]][grep("[[:alpha:]]", c[[1]], invert=TRUE)]

    anatCoord <- as.data.frame(lapply( c, function(u) 
        matrix(as.numeric(unlist(strsplit(u, ","))),ncol=2,byrow=TRUE) ))
    anatCoord$X2[is.na(anatCoord$X1)] <- NA
    anatCoord$X1[is.na(anatCoord$X2)] <- NA
    anatCoord$id <- name

    if (length(transMatrix[grep('matrix', transMatrix)])>0) {
        transForm <- gsub('matrix\\(|\\)', '', transMatrix)
        transForm <- as.numeric(strsplit(transForm, ",")[[1]])
       
        anatCoord$x <-  (anatCoord$X1* transForm[1]) + (anatCoord$X1* transForm[3]) + transForm[5]
        anatCoord$y <-  (anatCoord$X2* transForm[2]) + (anatCoord$X2* transForm[4]) + transForm[6]
    } else if (grep('translate', transMatrix)) {
        transForm <- gsub('translate\\(|\\)', '', transMatrix)
        transForm <- as.numeric(strsplit(transForm, ",")[[1]])
         if(name =='leukocyte' & transForm[1]==4.5230265) {
            transForm <- c(103.63591+4.5230265,-47.577078+11.586659)
        }
        anatCoord$x <-  anatCoord$X1 + transForm[1]
        anatCoord$y <-  anatCoord$X2 + transForm[2]
    }
    #anatCoord <- anatCoord[complete.cases(anatCoord),]
    if (name == 'bronchus') {
        if (max(anatCoord$x, na.rm=T) >100 ) {
            anatCoord$x <- NA
            anatCoord$y <- NA
        }
    }
    if( any(anatCoord[complete.cases(anatCoord),]$x < -5)) {
            anatCoord$x <- NA
            anatCoord$y <- NA
    }

    if( any(anatCoord[complete.cases(anatCoord),]$x > 150)) {
            anatCoord$x <- NA
            anatCoord$y <- NA
    }
    return(anatCoord)
}




####
#Male Human
####
hsMale <- read.table('homo_sapiens.Male_coords.tsv', sep='\t', stringsAsFactors=F)
hgMale_list <- list()
for (i in 1:nrow(hsMale)) {
    df <- extractCoords(hsMale$V2[i], hsMale$V1[i],  hsMale$V3[i])

    hgMale_list[[i]] <- extractCoords(hsMale$V2[i], hsMale$V1[i],  hsMale$V3[i])
    hgMale_list[[i]]$id <- gsub(' ', '_', hgMale_list[[i]]$id)
    names(hgMale_list)[i] <-  paste0(hsMale$V1[i],'-', i)
}
names(hgMale_list) <- gsub('-.*', '', names(hgMale_list))
names(hgMale_list) <- gsub(' ', '_', names(hgMale_list) )

allAnatomy <- read.table('allOrgans.tsv', sep='\t', stringsAsFactors=F)
organColour <- data.frame(type = c('circulation', 'nerve', 'digestion', 'respiratory', 'hormone','other', 'reproductive'),
                            colour = c('red', 'purple', 'orange', 'steelblue', 'yellow', '#41ab5d', '#d95f02'), stringsAsFactors=F)
allAnatomy$colour <- organColour[match(allAnatomy$V2, organColour$type),]$colour
colnames(allAnatomy) <- c('organ', 'type', 'colour')
allAnatomy[allAnatomy$type=='nerve',]$type <- 'nervous_system'
allAnatomy$organ <- gsub(' ', '_', allAnatomy$organ)
allAnatomy <- allAnatomy[! allAnatomy$organ %in% c('amygdala','pituitary gland'),]
allAnatomy <- allAnatomy[!allAnatomy$type %in% 'hormone',]
hgMale_key <- allAnatomy
hgMale_key$value <- runif(nrow(hgMale_key), 0, 20)

#gganatogram(data=allAnatomy, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") +facet_wrap(~type, ncol=3) +theme_classic()

#####
#Female human
#####
hsFemale <- read.table('homo_sapiens.female_coords.tsv', sep='\t', stringsAsFactors=F)
hgFemale_list <- list()
for (i in 1:nrow(hsFemale)) {
    df <- extractCoords(hsFemale$V2[i], hsFemale$V1[i],  hsFemale$V3[i])

    hgFemale_list[[i]] <- extractCoords(hsFemale$V2[i], hsFemale$V1[i],  hsFemale$V3[i])
    hgFemale_list[[i]]$id <- gsub(' ', '_', hgFemale_list[[i]]$id)
    names(hgFemale_list)[i] <-  paste0(hsFemale$V1[i],'-', i)
}
hgFemale_list[['fallopian_tube-96']]$y <- hgFemale_list[['fallopian_tube-96']]$y  +56.53891
hgFemale_list[['fallopian_tube-96']]$x <- hgFemale_list[['fallopian_tube-96']]$x  + 4.7

names(hgFemale_list) <- gsub('-.*', '', names(hgFemale_list))
names(hgFemale_list) <- gsub(' ', '_', names(hgFemale_list))
names(hgFemale_list) [names(hgFemale_list) %in% 'bladder'] <- 'urinary_bladder'

####
#Collapse all paths into an outline and group
####
for (i in 1:length(hgFemale_list[grep('path3584', names(hgFemale_list))])) {
    hgFemale_list[grep('path3584', names(hgFemale_list))][[i]]$group <- i 
}

#femSkin <- hgFemale_list[['skin']] 
#femSkin <- femSkin[complete.cases(femSkin),]
#femSkin$group <- 20
hgFemale_list[['outline']] <- do.call(rbind, hgFemale_list[grep('path3584', names(hgFemale_list))])
hgFemale_list[['fillFigure']] <-  do.call(rbind, hgFemale_list[grep('LAYER_OUTLINE', names(hgFemale_list))])
hgFemale_list[['fillFigure']]$group <- 21
#hgFemale_list[['fillFigure']] <- hgFemale_list[['fillFigure']][complete.cases(hgFemale_list[['fillFigure']]),]
#hgFemale_list[['outline']] <- rbind(hgFemale_list[['outline']], femOut)
hgFemale_list[['outline']] <- hgFemale_list[['outline']][complete.cases(hgFemale_list[['outline']]),]

#####
#Fix male outline
#####
hgMale_list[['fillFigure']] <- hgMale_list[['human_male_outline']]
hgMale_list[['human_male_outline']]$group <- c(rep(1, 420), rep(2, 1155-420), rep(3, 1168-1155), rep(4, 1181-1168), rep(5, 1191-1181), rep(6, 1201-1191), rep(7, 1211-1201), rep(8, 1221-1211), rep(9, 1324-1221), rep(10, 1334-1324), rep(11, 1347-1334), rep(12, 1363-1347), rep(13, 1385-1363), rep(14, 1407-1385), rep(15, nrow(hgMale_list[['human_male_outline']])-1407))
hgMale_list[['human_male_outline']] <- hgMale_list[['human_male_outline']][complete.cases(hgMale_list[['human_male_outline']]),]





hgFemale_list <- hgFemale_list[!names(hgFemale_list) %in% c('path9', 'path3584', 'salivary_gland')] 
hgFemale_key <- data.frame(organ = unique(names(hgFemale_list)),
                    colour = "grey", stringsAsFactors = FALSE)

hgFemale_key$colour <- allAnatomy[match(hgFemale_key$organ, allAnatomy$organ),]$colour
hgFemale_key$type <- allAnatomy[match(hgFemale_key$organ, allAnatomy$organ),]$type
hgFemale_key <- hgFemale_key[!hgFemale_key$organ %in% c('LAYER_OUTLINE', 'outline', 'fillFigure', 'amygdala'),]
hgFemale_key$colour[is.na(hgFemale_key$colour)]  <- '#d95f02'
hgFemale_key$type[is.na(hgFemale_key$type)]  <- 'reproductive'
hgFemale_key <- hgFemale_key[!hgFemale_key$type %in% 'hormone',]
hgFemale_key[hgFemale_key$organ=='cerebral_cortex',]$type <- 'nervous_system'
hgFemale_key[hgFemale_key$organ=='nasal_septum',]$type <- 'other'
hgFemale_key <- hgFemale_key[grep('gland', hgFemale_key$organ, invert=T),]
hgFemale_key
hgFemale_key$value <- runif(nrow(hgFemale_key), 0, 20)
#hgFemale_key <- hgFemale_key[!hgFemale_key$organ %in% c('path3584', 'salvary_gland'),]
#gganatogram(data=hgFemale_key, outline = F, fillOutline='#a6bddb', organism='human', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()

#hgFemale_key %>%
#    dplyr::filter(type =='hormone') %>%
#    mutate(type = organ) %>%
#    gganatogram( outline=F, fillOutline='#a6bddb', organism='human', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()


#hgFemale_key %>%
#    dplyr::filter(type =='reproductive') %>%
#    dplyr::filter(!organ =='path9') %>%
#    mutate(type = organ) %>%
#    gganatogram( outline=F, fillOutline='#a6bddb', organism='human', sex='female', fill="colour")  +theme_classic() + facet_wrap(~type)


library(devtools)
library(roxygen2)

#create("gganatogram")
#hgMale_key <- allAnatomy
#hgMale_key$value <- runif(46, 0, 20)
devtools::use_data(pkg = "gganatogram", hgMale_key, overwrite=TRUE)
devtools::use_data(pkg = "gganatogram", hgFemale_key, overwrite=TRUE)

#hgMale_list <- humanList
devtools::use_data(pkg = "gganatogram", hgMale_list, overwrite= TRUE)
devtools::use_data(pkg = "gganatogram", hgFemale_list, overwrite= TRUE)
document('gganatogram')
install('gganatogram')



gganatogram(data=hgFemale_key, outline = T, fillOutline='#a6bddb', organism='human', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()
gganatogram(data=hgMale_key, outline = T, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()


hgFemale_key %>%
    dplyr::filter(type =='reproductive') %>%
    dplyr::filter(!organ =='path9') %>%
    mutate(type = organ) %>%
    gganatogram( outline=F, fillOutline='#a6bddb', organism='human', sex='female', fill="colour")  +theme_classic() + facet_wrap(~type)


library(rmarkdown)
render('gganatogram/Readme.rmd')