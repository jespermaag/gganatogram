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
    } else if (length(transMatrix[grep('translate', transMatrix)]) >0) {
        transForm <- gsub('translate\\(|\\)', '', transMatrix)
        transForm <- as.numeric(strsplit(transForm, ",")[[1]])
         if(name =='leukocyte' & transForm[1]==103.63591) {
            transForm <- c(103.63591+4.5230265,-47.577078+11.586659)
        }
        anatCoord$x <-  anatCoord$X1 + transForm[1]
        anatCoord$y <-  anatCoord$X2 + transForm[2]
    } else { 
        anatCoord$x <-  anatCoord$X1 
        anatCoord$y <-  anatCoord$X2 
    }
    #anatCoord <- anatCoord[complete.cases(anatCoord),]
    if (name == 'bronchus') {
        if (min(anatCoord$y, na.rm=T) <25 ) {
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

    lastVal <- 0
    anatCoord$group <- 1
    for (j in 1:length(which(is.na(anatCoord$y)))) {
        curVal <- which(is.na(anatCoord$y))[j]
        anatCoord[c(lastVal:curVal),]$group <- paste0(i, '_', j)
        if (j < length(which(is.na(anatCoord$y)))) {
            lastVal <- curVal + 1
        } else if (j == length(which(is.na(anatCoord$y))) ) {
            anatCoord[c(curVal:length(anatCoord$y)),]$group <- paste0(i, '_',j+1) 
        }
    }

    return(anatCoord)
}




####
#All others
####
otherFiles <- list.files('data-raw/other/')
otherFiles <- otherFiles[grep('musculus.female_|musculus.male_|sapiens.female|sapiens.male', otherFiles, invert=T)]

other_list <- list()
other_key <- list()

for (other in otherFiles) {
    otherCoord <- read.table(paste0('data-raw/other/',other), sep='\t', stringsAsFactors=F)

    species_list <- list()
    species_name <- gsub('_coords.tsv', '', other)
    cat(species_name, '\n')
    for (i in 1:nrow(otherCoord)) {

        species_list[[i]] <- extractCoords(otherCoord$V2[i], otherCoord$V1[i],  otherCoord$V3[i])
        species_list[[i]]$id <- gsub(' ', '_', species_list[[i]]$id)

        names(species_list)[i] <-  paste0(otherCoord$V1[i],'-', i)
        species_key <- data.frame(organ = unique(names(species_list)),
                                type = 'other',
                                colour = "purple",
                                value = runif(length(unique(names(species_list))), 0, 20))
    }
    names(species_list) <- gsub('-.*', '', names(species_list))
    names(species_key) <- gsub('-.*', '', names(species_key))
    other_list[[species_name]] <- species_list
    other_key[[species_name]] <- species_key
}

bak.other_list <- other_list
for ( i in 1:length(other_list)) {
        names(other_list[[i]]) <- gsub('-.*', '', names(other_list[[i]]))

}
#test <- do.call(rbind, other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))])
#other_list[['bos_taurus']]
#plot(other_list[['bos_taurus']][['cow_outline']]$x, other_list[['bos_taurus']][['cow_outline']]$y, cex=0.1)
#lines(test$x, test$y)

for (i in 1:length(other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))])) {
    other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))][[i]]$x <- other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))][[i]]$X1
    other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))][[i]]$y <- other_list[['bos_taurus']][grep("UBERON_0014892", names(other_list[['bos_taurus']]))][[i]]$X2+3

}

other_list[['rattus_norvegicus']] <- other_list[['rattus_norvegicus']][grep("testis", names(other_list[['rattus_norvegicus']]), invert=T)]
other_key[['rattus_norvegicus']] <- other_key[['rattus_norvegicus']][grep("testis", other_key[['rattus_norvegicus']]$organ, invert=T),]


library(RColorBrewer)
n <- 60
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
qual_col_pals = qual_col_pals[c("Set1",
"Set2", "Set3", "Accent", "Dark2", "Paired", "Pastel1", "Pastel2" ),]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

other_key <- other_key[grep('.brain|solanum_tuberosum', names(other_key), invert=T)]

bak.other_key <- other_key
for (i in 1:length(other_key)) {
    other_key[[i]]$organ <-  gsub('-.*', '', other_key[[i]]$organ)
    other_key[[i]]<- other_key[[i]][grep('g7|outline|LAYER_OUTLINE|LAYER_EFO', other_key[[i]]$organ, inver=T),]
    other_key[[i]]$colour <- col_vector[1:nrow(other_key[[i]])]
}




library(devtools)
library(roxygen2)

devtools::use_data(pkg = "../gganatogram", other_key, overwrite=TRUE)
devtools::use_data(pkg = "../gganatogram", other_list, overwrite=TRUE)

document('../gganatogram')
install('../gganatogram')

names(other_key)
library(gridExtra)
plotList <- list()
for (organism in names(other_key)) {
    plotList[[organism]] <- gganatogram(data=other_key[[organism]], outline = T, fillOutline='white', organism=organism, sex='female', fill="colour")  +theme_void() +ggtitle(organism) + theme(plot.title = element_text(hjust=0.5, size=9)) + coord_fixed()
}

png(file='figure/other12.png',  width = 8, height = 5, units = 'in', res = 300)
do.call(grid.arrange,  c(plotList[1:12], ncol=3))
dev.off()

png(file='figure/other24.png',  width = 8, height = 5, units = 'in', res = 300)
do.call(grid.arrange,  c(plotList[13:24], ncol=3))
dev.off()

#Cow and #17
library(dplyr)
other_key[[organism]] %>%
    mutate(type=organ) %>%
    gganatogram( outline = T, fillOutline='white', organism=organism, sex='female', fill="colour")  +theme_void() +ggtitle(organism) +facet_wrap(~type, scale='free')