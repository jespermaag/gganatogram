library(ggplot2)
library(dplyr)
library(ggpolypath)
library(viridis)
library(gridExtra)

extractCoords <- function(coords, name, transMatrix) {
    c <- strsplit(coords, " ")
    c[[1]]

    if ( length(grep("M", c[[1]] ))>=1 & name !='intermediate_filaments' ) {
        c[[1]][c(grep("M", c[[1]] )+1,grep("M", c[[1]] )+2)] <- NA
    }
    if (name == "intermediate_filaments") {
        c[[1]][grep("Z", c[[1]])] <- paste0(NA, ",", NA)
    }

    if (length(grep("H", c[[1]] ))>=1) {
        for (i in grep("H", c[[1]] )) {
           c[[1]][i+1] <- paste0(c[[1]][i+1] ,",", strsplit(c[[1]][i-1],",")[[1]][2])
        }

    }

   if (length(grep("V", c[[1]] ))>=1) {
        for (i in grep("V", c[[1]] )) {
           c[[1]][i+1] <- paste0(strsplit(c[[1]][i-1],",")[[1]][1],",",  c[[1]][i+1] )
        }

    }

    #c[[1]][c(grep("L", c[[1]] )+1,grep("L", c[[1]])+2 )] <- NA
    #c[[1]][c(grep("C", c[[1]] ))] <- c(NA,NA)
    #c[[1]][c(grep("L", c[[1]] )+1,grep("L", c[[1]] )+2)] <- NA
   # if (length(grep("H", c[[1]]))>=1) {
    #    c[[1]] <- c[[1]][-c(grep("H", c[[1]]), grep("H", c[[1]])+1)]
    #}
    #c[[1]][c(grep("H", c[[1]] )+1)] <- NA
    c[[1]] <- c[[1]][grep("M|L|C|Z|V|H", c[[1]], invert=TRUE)]

    anatCoord <- as.data.frame(lapply( c, function(u) 
        matrix(as.numeric(unlist(strsplit(u, ","))),ncol=2,byrow=TRUE) ))
    anatCoord$X2[is.na(anatCoord$X1)] <- NA
    anatCoord$X1[is.na(anatCoord$X2)] <- NA
    anatCoord$id <- name

    anatCoord$x <-  anatCoord$X1 
    anatCoord$y <-  anatCoord$X2 
    lastVal <- 0
    anatCoord$group <- 1

    if (length(which(is.na(anatCoord$y))) >=1) { 
        for (j in 1:length(which(is.na(anatCoord$y)))) {
            curVal <- which(is.na(anatCoord$y))[j]
            anatCoord[c(lastVal:curVal),]$group <- paste0(i, '_', j)
            if (j < length(which(is.na(anatCoord$y)))) {
                lastVal <- curVal + 1
            } else if (j == length(which(is.na(anatCoord$y))) ) {
                anatCoord[c(curVal:length(anatCoord$y)),]$group <- paste0(i, '_',j+1) 
            }
        }
    }

    return(anatCoord)
}




####
#All others
####')
otherFiles <- "cell_20181017_Absolute_coords.tsv"

cell_list <- list()
cell_key <- list()

for (other in otherFiles) {
    otherCoord <- read.table(paste0('data-raw/',other), sep='\t', stringsAsFactors=F)

    species_list <- list()
    species_name <- gsub('_20181017_Absolute_coords.tsv', '', other)
    cat(species_name, '\n')
    for (i in 1:nrow(otherCoord)) {

            if (otherCoord$V1[i] == "g1195") {
                otherCoord$V1[i] <- 'endoplasmic_reticulum'
            }
            if (otherCoord$V1[i] == "g246") {
                otherCoord$V1[i]<- 'microtubules'
            }
            #if (otherCoord$V1[i] == 'g1594') {
            #    otherCoord$V1[i] <- 'cell_membrane'
            #}

             if (otherCoord$V1[i] == 'g4') {
                otherCoord$V1[i] <- 'cytosol'
            }
        species_list[[i]] <- extractCoords(otherCoord$V2[i], otherCoord$V1[i],  otherCoord$V3[i])
        species_list[[i]]$id <- gsub(' ', '_', species_list[[i]]$id)
        species_list[[i]]$x <- species_list[[i]]$X1 
        species_list[[i]]$y <- species_list[[i]]$X2 
        names(species_list)[i] <-  paste0(otherCoord$V1[i],'-', i)
        
        species_key <- data.frame(organ = unique(gsub('-.*', '',names(species_list))),
                                type = 'other',
                                colour = "purple",
                                value = runif(length(unique(gsub('-.*', '',names(species_list)))), 0, 20))
    }
    names(species_list) <- gsub('-.*', '', names(species_list))
    names(species_key) <- gsub('-.*', '', names(species_key))
    cell_list[[species_name]] <- species_list
    cell_key[[species_name]] <- species_key
}


bak.cell_list <- cell_list
for ( i in 1:length(cell_list)) {
        names(cell_list[[i]]) <- gsub('-.*', '', names(cell_list[[i]]))

}

#test <- do.call(rbind, cell_list[['cell']][grep('g1195', names(cell_list[['cell']]))])
#test[complete.cases(test),] %>%
#    mutate(condition = group) %>%
#    #filter(X1 > 300   ) %>%
#    #filter(grepl('568', group) ) %>%
#    ggplot(aes(x = X1, y = X2))+
#        ggpolypath::geom_polypath(aes(x=X1, y=X2, group=group)) #+
#        #geom_point()   
#library(ggrepel)
#test <- do.call(rbind, cell_list[['cell']][grep('mitochondria', names(cell_list[['cell']]))])
#test <- test[grep('_ton', test$id, invert=T),]
#testdf <- test[!duplicated(test$group), ]
#test[complete.cases(test),] %>%
#    mutate(condition = group) %>%
#    filter(!grepl('_ton', id)) %>%
#    #filter(X1 > 300   ) %>%
#    #filter(grepl('760', group) ) %>%
#    ggplot(aes(x = X1, y = X2, label=group))+
#        ggpolypath::geom_polypath(aes(x=X1, y=X2, group=group),fill='blue', colour='black') #+
#        #geom_text_repel(data=testdf)coo
#
#        #geom_point()   




library(RColorBrewer)
n <- 60
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
qual_col_pals = qual_col_pals[c("Set1",
"Set2", "Set3", "Accent", "Dark2", "Paired", "Pastel1", "Pastel2" ),]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

#cell_key <- cell_key[grep('.brain|solanum_tuberosum', names(cell_key), invert=T)]

bak.cell_key <- cell_key
for (i in 1:length(cell_key)) {
    cell_key[[i]]$organ <-  gsub('-.*', '', cell_key[[i]]$organ)
    #cell_key[[i]]<- cell_key[[i]][grep('g7|outline|LAYER_OUTLINE|LAYER_EFO', cell_key[[i]]$organ, inver=T),]
    cell_key[[i]]$colour <- col_vector[1:nrow(cell_key[[i]])]
}

cell_list[['cell']] <- cell_list[['cell']][!names(cell_list[['cell']]) %in% c('g9', 'g4', 'g269','plasma_membrane', 'g1170', 'g1601')]
cell_list[['cell']] <- cell_list[['cell']][grep('_ton', names(cell_list[['cell']]), invert=T)]

cell_key[['cell']] <- cell_key[['cell']][! cell_key[['cell']]$organ %in% c('g9', 'g4', 'g269', 'plasma_membrane', 'g1170', 'g1601'),]
cell_key[['cell']] <- cell_key[['cell']][grep('_ton', cell_key[['cell']]$organ, invert=T),]
cell_key[['cell']][cell_key[['cell']]$organ=='cytosol',]$colour <- 'steelblue'

cell_list[['cell']][['g1594']]$id <- 'plasma_membrane'
names(cell_list[['cell']]) <- gsub('g1594', 'plasma_membrane', names(cell_list[['cell']]))
cell_key[['cell']]$organ <- gsub('g1594', 'plasma_membrane', cell_key[['cell']]$organ )
#for (i in 1:length(cell_list[[1]])) {
#    plot(cell_list[[1]][[1]]$X1, cell_list[[1]][[1]]$X2, cex=0.1)
#    lines(cell_list[[1]][[i]]$X1, cell_list[[1]][[i]]$X2, cex=0.1)
#}

library(devtools)
library(roxygen2)

devtools::use_data(pkg = "../gganatogram", cell_key, overwrite=TRUE)
devtools::use_data(pkg = "../gganatogram", cell_list, overwrite=TRUE)

document('../gganatogram')
install('../gganatogram')


dir.create('cell')
#test <- cell_key[['cell']][grep('_ton', cell_key[['cell']]$organ, invert=T),]
#test <- test[! test$organ %in% c('g9', 'g4', 'g269', 'g1170', 'g1601', 'plasma_membrane'),]
test <- cell_key[['cell']]
for (i in 1:nrow(test)) {
    p <- gganatogram(data=test[i,], outline = T, fillOutline='steelblue', organism="cell", fill="colour")  +theme_void() +ggtitle(test[i,]$organ) + theme(plot.title = element_text(hjust=0.5, size=16)) + coord_fixed()
    ggsave(p, file=paste0('cell/', test$organ[i],'.png'))
}

p1 <- gganatogram(data=test, outline = T, fillOutline='steelblue', organism="cell", fill="colour")  +theme_void() +ggtitle('cell') + theme(plot.title = element_text(hjust=0.5, size=16)) + coord_fixed()

png('figure/cell_col.png', res=300, units='in', width=5, height=5)
p1
dev.off()

p2 <- gganatogram(data=test, outline = T, fillOutline='lightgray', organism="cell", fill="value")  +theme_void() +ggtitle('cell') + theme(plot.title = element_text(hjust=0.5, size=16)) + coord_fixed() +  scale_fill_viridis()

png('figure/cell_val.png', res=300, units='in', width=5, height=5)
p2
dev.off()

library(gridExtra)
png('figure/cell_comb.png', res=300, units='in', width=10, height=5)
grid.arrange(p1, p2, ncol=2)
dev.off()
