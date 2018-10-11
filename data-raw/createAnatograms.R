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
         if(name =='leukocyte' & transForm[1]==103.63591) {
            transForm <- c(103.63591+4.5230265,-47.577078+11.586659)
        }
        anatCoord$x <-  anatCoord$X1 + transForm[1]
        anatCoord$y <-  anatCoord$X2 + transForm[2]
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
#Male Human
####
hsMale <- read.table('homo_sapiens.male_coords.tsv', sep='\t', stringsAsFactors=F)
hgMale_list <- list()
for (i in 1:nrow(hsMale)) {
    df <- extractCoords(hsMale$V2[i], hsMale$V1[i],  hsMale$V3[i])

    hgMale_list[[i]] <- extractCoords(hsMale$V2[i], hsMale$V1[i],  hsMale$V3[i])
    hgMale_list[[i]]$id <- gsub(' ', '_', hgMale_list[[i]]$id)
    if ( (unique(hgMale_list[[i]]$id) == 'leukocyte') & (min(hgMale_list[[i]]$x, na.rm=T)<15) ) {
        hgMale_list[[i]]$x <- hgMale_list[[i]]$x-4.5230265
        hgMale_list[[i]]$y <- hgMale_list[[i]]$y -11.586659
    }
    names(hgMale_list)[i] <-  paste0(hsMale$V1[i],'-', i)
}
library(DescTools)
plot(hgMale_list[['LAYER_OUTLINE-384']]$x, hgMale_list[['LAYER_OUTLINE-384']]$y)
testis1 <- DrawEllipse(x=59.421902+ -9.6858637, y=168.88368+ -66.040746, radius.x=1, radius.y=2.6421267,  col='red')
hgMale_list[['testis-1']] <- data.frame(X1 = testis1$x, X2 = testis1$y, id='testis', x = testis1$x, y = testis1$y, group ='testis1', stringsAsFactors = FALSE)
testis2 <- DrawEllipse(x=66.046127+ -9.6858637, y=168.88368 + -66.040746, radius.x=1, radius.y=2.6421267,  col='red')
hgMale_list[['testis-2']] <- data.frame(X1 = testis2$x, X2 = testis2$y, id='testis', x = testis2$x, y = testis2$y, group ='testis2', stringsAsFactors = FALSE)

prostate <- DrawEllipse(x=52.737728, y= 93.289169, radius.x=3.3939276, radius.y=2.6712799,  col='red')
hgMale_list[['prostate-1']] <- data.frame(X1 = prostate$x, X2 = prostate$y, id='prostate', x = prostate$x, y = prostate$y, group ='prostate', stringsAsFactors = FALSE)

breast1 <- DrawEllipse(x=43.5, y=47, radius.x=6, radius.y=5, col='red')
breast1 <- data.frame(x = breast1$x, y = breast1$y)
hgMale_list[['breast-1']] <- data.frame(X1 = breast1$x, X2 = breast1$y, id='breast', x = breast1$x, y = breast1$y, group = 'breast1', stringsAsFactors = F)

breast2 <- DrawEllipse(x=62, y=47, radius.x=6, radius.y=5, col='red')
breast2 <- data.frame(x = breast2$x, y = breast2$y)
hgMale_list[['breast-2']] <- data.frame(X1 = breast2$x, X2 = breast2$y, id='breast', x = breast2$x, y = breast2$y, group = 'breast2', stringsAsFactors = F)

plot(hgMale_list[['LAYER_OUTLINE-384']]$x, hgMale_list[['LAYER_OUTLINE-384']]$y, cex=0.3)
putGland <- DrawEllipse(x=53, y=10, radius.x=0.8, radius.y=1.6, col='red')

hgMale_list[['pituitary gland-6']] <- data.frame(X1 = putGland$x, X2 = putGland$y, id='pituitary_gland', x = putGland$x, y = putGland$y, group ='pituitary_gland', stringsAsFactors = FALSE)
#lines(hgMale_list[['pituitary gland-6']]$X1, hgMale_list[['pituitary gland-6']]$X2)
names(hgMale_list) <- gsub('-.*', '', names(hgMale_list))
names(hgMale_list) <- gsub(' ', '_', names(hgMale_list) )




allAnatomy <- read.table('allOrgans.tsv', sep='\t', stringsAsFactors=F)
organColour <- data.frame(type = c('circulation', 'nerve', 'digestion', 'respiratory', 'hormone','other', 'reproductive'),
                            colour = c('red', 'purple', 'orange', 'steelblue', 'yellow', '#41ab5d', '#d95f02'), stringsAsFactors=F)
allAnatomy$colour <- organColour[match(allAnatomy$V2, organColour$type),]$colour
colnames(allAnatomy) <- c('organ', 'type', 'colour')
allAnatomy[allAnatomy$type=='nerve',]$type <- 'nervous_system'
allAnatomy$organ <- gsub(' ', '_', allAnatomy$organ)
#allAnatomy <- allAnatomy[! allAnatomy$organ %in% c('amygdala','pituitary gland'),]
#allAnatomy <- allAnatomy[!allAnatomy$type %in% 'hormone',]
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

#####
#TODO OVARY 
#####

fall<- do.call(rbind, hgFemale_list[grep('fallopian_tube|uterus', names(hgFemale_list))])
plot(fall$x, fall$y, ylim=c(80, 99))
lines(fall$x, fall$y)  
DrawEllipse(x=46.9, y=91, radius.x=1, radius.y=0.6, rot=20, col='red')
DrawEllipse(x=58.5, y=91, radius.x=1, radius.y=0.6, rot=2, col='red')
DrawEllipse(x=48.6, y=90.5, radius.x=0.1, radius.y=1.2, rot=20, col='red')
DrawEllipse(x=56.8, y=90.5, radius.x=0.1, radius.y=1.2, rot=2, col='red')
 hgFemale_list[['ovary-1']]<- data.frame(X1 = DrawEllipse(x=46.9, y=91, radius.x=1, radius.y=0.6, rot=20)$x,
                X2 = DrawEllipse(x=46.9, y=91, radius.x=1, radius.y=0.6, rot=20)$y,
                id ='ovary',
                x =  DrawEllipse(x=46.9, y=91, radius.x=1, radius.y=0.6, rot=20)$x,
                y =  DrawEllipse(x=46.9, y=91, radius.x=1, radius.y=0.6, rot=20)$y,
                group = 'overy1',
                stringsAsFactors = F)

 hgFemale_list[['ovary-11']]<- data.frame(X1 = DrawEllipse(x=48.6, y=90.5, radius.x=0.1, radius.y=1.2, rot=20)$x,
                X2 = DrawEllipse(x=48.6, y=90.5, radius.x=0.1, radius.y=1.2, rot=20)$y,
                id ='ovary',
                x =  DrawEllipse(x=48.6, y=90.5, radius.x=0.1, radius.y=1.2, rot=20)$x,
                y =  DrawEllipse(x=48.6, y=90.5, radius.x=0.1, radius.y=1.2, rot=20)$y,
                group = 'overy11',
                stringsAsFactors = F)

 hgFemale_list[['ovary-2']]<- data.frame(X1 = DrawEllipse(x=58.5, y=91, radius.x=1, radius.y=0.6, rot=2)$x,
                X2 = DrawEllipse(x=58.5, y=91, radius.x=1, radius.y=0.6, rot=2)$y,
                id ='ovary',
                x =  DrawEllipse(x=58.5, y=91, radius.x=1, radius.y=0.6, rot=2)$x,
                y =  DrawEllipse(x=58.5, y=91, radius.x=1, radius.y=0.6, rot=2)$y,
                group = 'overy2',
                stringsAsFactors = F)

 hgFemale_list[['ovary-22']]<- data.frame(X1 = DrawEllipse(x=56.8, y=90.5, radius.x=0.1, radius.y=1.2, rot=2)$x,
                X2 = DrawEllipse(x=56.8, y=90.5, radius.x=0.1, radius.y=1.2, rot=2)$y,
                id ='ovary',
                x =  DrawEllipse(x=56.8, y=90.5, radius.x=0.1, radius.y=1.2, rot=2)$x,
                y =  DrawEllipse(x=56.8, y=90.5, radius.x=0.1, radius.y=1.2, rot=2)$y,
                group = 'overy22',
                stringsAsFactors = F)

fall<- do.call(rbind, hgFemale_list[grep('path3584', names(hgFemale_list))])
plot(fall$x, fall$y)
breast1 <- DrawEllipse(x=43.5, y=47, radius.x=6, radius.y=5, col='red')
breast1 <- data.frame(x = breast1$x, y = breast1$y)
hgFemale_list[['breast-1']] <- data.frame(X1 = breast1$x, X2 = breast1$y, id='breast', x = breast1$x, y = breast1$y, group = 'breast1', stringsAsFactors = F)
breast2 <- DrawEllipse(x=62, y=47, radius.x=6, radius.y=5, col='red')
breast2 <- data.frame(x = breast2$x, y = breast2$y)
hgFemale_list[['breast-2']] <- data.frame(X1 = breast2$x, X2 = breast2$y, id='breast', x = breast2$x, y = breast2$y, group = 'breast2', stringsAsFactors = F)
putGland <- DrawEllipse(x=52.5, y=10, radius.x=0.8, radius.y=1.6, col='red')

hgFemale_list[['pituitary gland-16']] <- data.frame(X1 = putGland$x, X2 = putGland$y, id='pituitary_gland', x = putGland$x, y = putGland$y, group ='pituitary_gland', stringsAsFactors = FALSE)


#lines(hgFemale_list[['ovary-1']]$x, -hgFemale_list[['ovary-1']]$y)
#lines(test$x, -test$y)
#test <- DrawEllipse(x=58.5, y=-91, radius.x=1, radius.y=0.6, rot=20)
#lines(test$x, -test$y)

#library(plotrix)
#draw.ellipse(x= c(183.93817), y= c(-4.7179484), c(.899), c(0.833), border = 'red', lwd = 2, draw=F)
#       id="UBERON_0000992"
#       style="fill:none;stroke:none"
#       inkscape:label="UBERON_0000992"
#       transform="translate(-28.558744,-76.741038)">
#      <title
#         id="ovary">ovary</title>
#      <path
#         sodipodi:end="6.275538"
#         sodipodi:start="0"
#         transform="matrix(0.91474633,-0.40402864,0.43444822,0.90069681,0,0)"
#         d="M -3.7252197,183.93817 A 0.99272877,0.83321977 0 0 1 -4.7160505,184.77139 0.99272877,0.83321977 0 0 1 -5.7106699,183.94136 0.99272877,0.83321977 0 0 1 -4.7236422,183.10497 0.99272877,0.83321977 0 0 1 -3.7252487,183.9318 L -4.7179484,183.93817 Z"
#         sodipodi:ry="0.83321977"
#         sodipodi:rx="0.99272877"
#         sodipodi:cy="183.93817"
#         sodipodi:cx="-4.7179484"
#         id="path18952"
#         sodipodi:type="arc" />
#      <path
#         sodipodi:type="arc"
#         id="path18954"
#         sodipodi:cx="-148.18413"
#         sodipodi:cy="-112.90377"
#         sodipodi:rx="0.97524083"
#         sodipodi:ry="0.85279381"
#         d="M -147.20889,-112.90377 A 0.97524083,0.85279381 0 0 1 -148.18226,-112.05098 0.97524083,0.85279381 0 0 1 -149.15936,-112.90051 0.97524083,0.85279381 0 0 1 -148.18972,-113.75655 0.97524083,0.85279381 0 0 1 -147.20892,-112.91029 L -148.18413,-112.90377 Z"
#         transform="matrix(-0.90007703,-0.43573081,0.41100361,-0.91163372,0,0)"
#         sodipodi:start="0"
#         sodipodi:end="6.275538" />

names(hgFemale_list) <- gsub('-.*', '', names(hgFemale_list))
names(hgFemale_list) <- gsub(' ', '_', names(hgFemale_list))
names(hgFemale_list) [names(hgFemale_list) %in% 'bladder'] <- 'urinary_bladder'

#salvGland <- do.call(rbind, hgFemale_list[grep("salivary_gland", names(hgFemale_list))])
for ( i in grep("salivary_gland", names(hgFemale_list))) {
    hgFemale_list[[i]]$x <-  hgFemale_list[[i]]$x + 4.4
    hgFemale_list[[i]]$y <-  hgFemale_list[[i]]$y + 46
}
#plot(fall$x, fall$y, cex=0.2, ylim=c(-20, 200))
#lines(salvGland$x+4.4, salvGland$y+46, col='red') 

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
hgFemale_list[['spinal_cord']] <- hgMale_list[['spinal_cord']]
hgFemale_list[['spinal_cord']]$x <- hgFemale_list[['spinal_cord']]$x -0.8
#####
#Fix male outline
#####
hgMale_list[['fillFigure']] <- hgMale_list[['human_male_outline']]
hgMale_list[['human_male_outline']]$group <- c(rep(1, 420), rep(2, 1155-420), rep(3, 1168-1155), rep(4, 1181-1168), rep(5, 1191-1181), rep(6, 1201-1191), rep(7, 1211-1201), rep(8, 1221-1211), rep(9, 1324-1221), rep(10, 1334-1324), rep(11, 1347-1334), rep(12, 1363-1347), rep(13, 1385-1363), rep(14, 1407-1385), rep(15, nrow(hgMale_list[['human_male_outline']])-1407))
hgMale_list[['human_male_outline']] <- hgMale_list[['human_male_outline']][complete.cases(hgMale_list[['human_male_outline']]),]





#hgFemale_list <- hgFemale_list[!names(hgFemale_list) %in% c('path9', 'path3584', 'salivary_gland')] 
hgFemale_key <- data.frame(organ = unique(names(hgFemale_list)),
                    colour = "grey", stringsAsFactors = FALSE)

hgFemale_key$colour <- allAnatomy[match(hgFemale_key$organ, allAnatomy$organ),]$colour
hgFemale_key$type <- allAnatomy[match(hgFemale_key$organ, allAnatomy$organ),]$type
hgFemale_key <- hgFemale_key[!hgFemale_key$organ %in% c('LAYER_OUTLINE', 'outline', 'fillFigure', 'amygdala'),]
hgFemale_key$colour[is.na(hgFemale_key$colour)]  <- '#d95f02'
hgFemale_key$type[is.na(hgFemale_key$type)]  <- 'reproductive'
#hgFemale_key <- hgFemale_key[!hgFemale_key$type %in% 'hormone',]
hgFemale_key[hgFemale_key$organ=='cerebral_cortex',]$type <- 'nervous_system'
hgFemale_key[hgFemale_key$organ=='nasal_septum',]$type <- 'other'
#hgFemale_key <- hgFemale_key[grep('gland', hgFemale_key$organ, invert=T),]
hgFemale_key
hgFemale_key$value <- runif(nrow(hgFemale_key), 0, 20)
hgFemale_key <- hgFemale_key[!hgFemale_key$organ %in% c('path3584', 'path9'),]
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


#####
#Mouse male
#####
mmMale <- read.table('mus_musculus.male_coords.tsv', sep='\t', stringsAsFactors=F)
mmMale_list <- list()
for (i in 1:nrow(mmMale)) {
    df <- extractCoords(mmMale$V2[i], mmMale$V1[i],  mmMale$V3[i])

    mmMale_list[[i]] <- extractCoords(mmMale$V2[i], mmMale$V1[i],  mmMale$V3[i])
    mmMale_list[[i]]$id <- gsub(' ', '_', mmMale_list[[i]]$id)
    
    names(mmMale_list)[i] <-  paste0(mmMale$V1[i],'-', i)
}

 
names(mmMale_list) <- gsub('-.*', '', names(mmMale_list))
names(mmMale_list) <- gsub(' ', '_', names(mmMale_list))

mmMale_list[['seminal_vesicle']] <- mmMale_list[['seminal_vesicle']][mmMale_list[['seminal_vesicle']]$y >100,] 
#for (i in 1:length(mmMale_list[grep('skin', names(mmMale_list))])) {
#    mmMale_list[grep('skin', names(mmMale_list))][[i]]$group <- i 
#}
test <- mmMale_list[['lymph_node']]


mmMale_list[['outline']] <- do.call(rbind, mmMale_list[grep('skin', names(mmMale_list))])
mmMale_list[['outline']]  <- mmMale_list[['outline']][complete.cases(mmMale_list[['outline']]),]



mmMale_key <- data.frame(organ = unique(names(mmMale_list)),
                    colour = "grey", stringsAsFactors = FALSE)
mmMale_key$type <- allAnatomy[match(mmMale_key$organ, allAnatomy$organ),]$type
mmMale_key$type[is.na(mmMale_key$type)] <- 'other'
mmMale_key$value <- runif(nrow(mmMale_key), 0, 20)
mmMale_key[mmMale_key$organ %in% c('jejunum') ,]$type <- 'digestion'
mmMale_key[mmMale_key$organ %in% c('peripheral_nervous_system', 'sciatic_nerve', 'trigeminal_nerve'),]$type <- 'nervous_system'
mmMale_key[mmMale_key$organ %in% c('circulatory_system', 'blood_vessel'),]$type <- 'circulation'
mmMale_key$colour <- allAnatomy[match(mmMale_key$type, allAnatomy$type),]$colour

mmMale_key <- mmMale_key[!mmMale_key$organ %in% c('UBERON_0000947', 'submandibular_gland', 'parotid_gland', 'white_adipose_tissue', 'path9', 'LAYER_OUTLINE', 'outline'),]






#####
#Mouse female
#####

mmFemale <- read.table('mus_musculus.female_coords.tsv', sep='\t', stringsAsFactors=F, quote = "" )
mmFemale[,1][mmFemale[,1] %in% 'title5002'] <- 'peripheral_nervous_system'
mmFemale_list <- list()
#mmFemale == ""
for (i in 1:nrow(mmFemale)) {
    df <- extractCoords(mmFemale$V2[i], mmFemale$V1[i],  mmFemale$V3[i])

    mmFemale_list[[i]] <- extractCoords(mmFemale$V2[i], mmFemale$V1[i],  mmFemale$V3[i])
    mmFemale_list[[i]]$id <- gsub(' ', '_', mmFemale_list[[i]]$id)
    
    names(mmFemale_list)[i] <-  paste0(mmFemale$V1[i],'-', i)
}
names(mmFemale_list) <- gsub('-.*', '', names(mmFemale_list))
names(mmFemale_list) <- gsub(' ', '_', names(mmFemale_list))
#names(mmFemale_list) <- gsub('title5002', 'peripheral_nervous_system', names(mmFemale_list) )
#mmFemale_list[['seminal_vesicle']] <- mmFemale_list[['seminal_vesicle']][mmFemale_list[['seminal_vesicle']]$y >100,] 
#for (i in 1:length(mmFemale_list[grep('skin', names(mmFemale_list))])) {
#    mmFemale_list[grep('skin', names(mmFemale_list))][[i]]$group <- i 
#}
#test <- mmFemale_list[['lymph_node']]


mmFemale_list[['outline']] <- do.call(rbind, mmFemale_list[grep('skin', names(mmFemale_list))])
mmFemale_list[['outline']]  <- mmFemale_list[['outline']][complete.cases(mmFemale_list[['outline']]),]
mmFemale_key <- data.frame(organ = unique(names(mmFemale_list)),
                    colour = "grey", stringsAsFactors = FALSE)
mmFemale_key$type <- mmMale_key[match(mmFemale_key$organ, mmMale_key$organ),]$type
mmFemale_key$type[is.na(mmFemale_key$type)] <- 'other'
mmFemale_key$value <- runif(nrow(mmFemale_key), 0, 20)
mmFemale_key[mmFemale_key$organ %in% c('jejunum') ,]$type <- 'digestion'

mmFemale_key[mmFemale_key$organ %in% c('peripheral_nervous_system', 'sciatic_nerve', 'trigeminal_nerve'),]$type <- 'nervous_system'
mmFemale_key[mmFemale_key$organ %in% c('circulatory_system', 'blood_vessel'),]$type <- 'circulation'
mmFemale_key[mmFemale_key$organ %in% c('reproductive_system', 'mammary_gland', 'uterus', 'vagina'),]$type <- 'reproductive'

mmFemale_key$colour <- allAnatomy[match(mmFemale_key$type, allAnatomy$type),]$colour

mmFemale_key <- mmFemale_key[!mmFemale_key$organ %in% c('UBERON_0000947', 'submandibular_gland', 'parotid_gland', 'white_adipose_tissue', 'path9', 'LAYER_OUTLINE', 'outline'),]


mmMale_list[['urinary_bladder']] <- mmFemale_list[['urinary_bladder']]
mmMale_list[['urinary_bladder']]$group <- '100_2'






library(devtools)
library(roxygen2)

#create("gganatogram")
#hgMale_key <- allAnatomy
#hgMale_key$value <- runif(46, 0, 20)
devtools::use_data(pkg = "gganatogram", hgMale_key, overwrite=TRUE)
devtools::use_data(pkg = "gganatogram", hgFemale_key, overwrite=TRUE)
devtools::use_data(pkg = "gganatogram", mmMale_key, overwrite=TRUE)
devtools::use_data(pkg = "gganatogram", mmFemale_key, overwrite=TRUE)
#hgMale_list <- humanList
devtools::use_data(pkg = "gganatogram", hgMale_list, overwrite= TRUE)
devtools::use_data(pkg = "gganatogram", hgFemale_list, overwrite= TRUE)
devtools::use_data(pkg = "gganatogram", mmMale_list, overwrite=TRUE)
devtools::use_data(pkg = "gganatogram", mmFemale_list, overwrite=TRUE)


document('gganatogram')
install('gganatogram')

#gganatogram(data=hgFemale_key[hgFemale_key$type=='nervous_system',], outline = T, fillOutline='#a6bddb', organism='human', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()


gganatogram(data=hgFemale_key, outline = T, fillOutline='#a6bddb', organism='human', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()
gganatogram(data=hgMale_key, outline = T, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()
gganatogram(data=mmMale_key, outline = T, fillOutline='#a6bddb', organism='mouse', sex='male', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()
gganatogram(data=mmFemale_key, outline = T, fillOutline='#a6bddb', organism='mouse', sex='female', fill="colour") +facet_wrap(~type, ncol=4) +theme_classic()


hgMale_key %>%
    dplyr::filter(type =='hormone') %>%
    dplyr::filter(!organ =='path9') %>%
    mutate(type = organ) %>%
    gganatogram( outline=T, fillOutline='#a6bddb', organism='human', sex='male', fill="colour")  +theme_classic()+ facet_wrap(~type) 

hgFemale_key %>%
    dplyr::filter(type =='reproductive') %>%
    #dplyr::filter(!organ %in% c('path9', 'seminal_vesicle')) %>%
    mutate(type = organ) %>%
    gganatogram( outline=T, fillOutline='#a6bddb', organism='human', sex='female', fill="colour")  +theme_classic() +facet_wrap(~type)

mmMale_list[['seminal_vesicle']]

library(rmarkdown)
render('gganatogram/Readme.rmd')
