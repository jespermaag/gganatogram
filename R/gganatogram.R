#' gganatogram
#'
#' This function plots anatograms of specified tissues, species, and sex .
#' @param data The main data frame consisting of what organs to plot, colours, and values. Default is NULL
#' @param fillOutline Fill colour of outline. Default is #a6bddb
#' @param organism. Species to plot. Default is human.
#'
#' @keywords anatogram tissues organs
#' @export
#' @examples
#'
#' #First lets just plot the outline. Only male human is possible now
#' gganatogram(fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
#'
#'
#' #To add organs, create a data frame with specified tissues
#'
#'
#' organPlot <- data.frame(organ = c("heart", "leukocyte", "nerve", "brain",
#'      "liver", "stomach", "colon"),
#'  type = c("circulation", "circulation",
#'      "nervous system", "nervous system", "digestion", "digestion",
#'      "digestion"),
#'  colour = c("red", "red", "purple", "purple", "orange",
#'      "orange", "orange"),
#'  value = c(10, 5, 1, 8, 2, 5, 5),
#'  stringsAsFactors=F)
#'
#'
#' gganatogram(data=organPlot, fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
#'
#'
#' #We can also remove the outline
#' gganatogram(data=organPlot, outline=FALSE, fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
#'
#'
#' organPlot %>%
#'      dplyr::filter(type %in% 'circulation') %>%
#'  gganatogram(fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
#'
#' organPlot %>%
#'      dplyr::filter(type %in% c('circulation', 'nervous system')) %>%
#'  gganatogram(fillOutline='#a6bddb', organism='human', sex='male', fill="value") +
#'  theme_void() +
#'  scale_fill_gradient(low = "white", high = "red")
#'
#' gganatogram(data=oraganPlot, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") +
#' facet_wrap(~type)
#'
#' #Use hgMale_key to find all tissues to plot
#' hgMale_key = gganatogram::hgMale_key
#' head(hgMale_key)
#' gganatogram(data=hgMale_key, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") + theme_void()
#'
#'
#' gganatogram(data=hgMale_key, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") + theme_void() + facet_wrap(~type, ncol=3)
#'
#'
#' gganatogram(data=hgMale_key, fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
#'
#'
#' gganatogram(data=hgMale_key, fillOutline='#a6bddb', organism='human', sex='male', fill="value")
#'
#'
#' gganatogram(data=hgMale_key, fillOutline='#a6bddb', organism='human', sex='male', fill="colour") +facet_wrap(~type, ncol=3) +void()
#'
#'
gganatogram <- function(data = NULL, outline = TRUE, fillOutline='lightgray', organism="human", sex='male', fill='colour') {
    if ( organism == 'human' ) {
        if( sex == 'male' ) {
            anatogram <- gganatogram::hgMale_list
        #} else if (sex == 'female') {
        #    anatogram <- NULL
        }
    }
    if (outline) {
        p <- ggplot2::ggplot(anatogram[['human_male_outline']], ggplot2::aes(x=x, y = -y)) +
            ggplot2::geom_polygon(fill=fillOutline, colour='black', size=0.2)
    } else if (outline == FALSE) {
        p <- ggplot2::ggplot(anatogram[['human_male_outline']], ggplot2::aes(x=x, y = -y))
    }
    for (Norgan in 1:nrow(data)){
        mapOrgans <-  anatogram[names(anatogram) %in% data[Norgan,]$organ]
        mapOrgans <- lapply(mapOrgans, function(x) {
            dataOrgan <- data[Norgan,]
            x$value <- dataOrgan[match(x$id, dataOrgan$organ),]$value
            x$type <- dataOrgan[match(x$id, dataOrgan$organ),]$type
            x
        })
        for (i in 1:length(mapOrgans)) {

            if (fill == 'colour' || fill == "color") {
                organColour <- data[Norgan,]$colour
                p <- p + ggpolypath::geom_polypath(data=mapOrgans[[i]][complete.cases(mapOrgans[[i]]),],  fill=organColour, colour="black", size=0.2)

            } else if (fill == 'value') {
                p <- p + ggpolypath::geom_polypath(data=mapOrgans[[i]][complete.cases(mapOrgans[[i]]),],  ggplot2::aes(fill=value), colour="black", size=0.2)

            } else {
                p <- p + ggpolypath::geom_polypath(data=mapOrgans[[i]][complete.cases(mapOrgans[[i]]),], colour="black", size=0.2)
            }
        }
    }
    p
}
