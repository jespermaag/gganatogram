#' gganatogram
#'
#' This function plots anatograms of specified tissues, species, and sex .
#'
#' @param data The main data frame consisting of what organs to plot,
#'  colours, and values. Default is NULL
#' @param outline logical indicating if the outline of the organism
#' should be plotted
#' @param organism The organism to be plotted.  Currently,
#' only \code{human} is accepted.
#' @param sex Sex of the organism
#' @param fill How to fill
#' @param fillOutline Fill colour of outline. Default is #a6bddb
#' @param anatogram A list, similar to \code{\link{hgMale_list}}
#' that will create the outline and has the corresponding organ
#' \code{data.frame}s in that list
#' @param ggplot2_only If \code{TRUE}, will try to use only
#' \code{ggplot2} functionality
#'
#' @keywords anatogram tissues organs
#' @export
#'
#' @importFrom stats complete.cases
#' @import ggplot2
#' @import ggpolypath
#' @examples
#'
#' library(ggplot2)
#' #First lets just plot the outline. Only male human is possible now
#' gganatogram(fillOutline='#a6bddb', organism='human',
#' sex='male', fill="colour")
#'
#' gganatogram(fillOutline='#a6bddb', organism='human',
#' sex='female', fill="colour")
#'
#' gganatogram(fillOutline='#a6bddb', organism='mouse',
#' sex='Male', fill="colour")
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
#'  stringsAsFactors=FALSE)
#'
#'
#' gganatogram(data=organPlot, fillOutline='#a6bddb',
#'  organism='human', sex='male', fill="colour")
#'
#'
#' #We can also remove the outline
#' oplot = gganatogram(data=organPlot, outline=FALSE, fillOutline='#a6bddb',
#' organism='human', sex='male', fill="colour")
#' oplot
#'
#' oplot + facet_wrap(~type)
#'
#' library(dplyr)
#' organPlot %>%
#'      dplyr::filter(type %in% 'circulation') %>%
#'  gganatogram(fillOutline='#a6bddb', organism='human',
#'  sex='male', fill="colour")
#'
#' organPlot %>%
#'      dplyr::filter(type %in% c('circulation', 'nervous system')) %>%
#'  gganatogram(fillOutline='#a6bddb', organism='human',
#'  sex='male', fill="value") +
#'  theme_void() +
#'  scale_fill_gradient(low = "white", high = "red")
#'
#'
#' #Use hgMale_key to find all tissues to plot
#' hgMale_key = gganatogram::hgMale_key
#' head(hgMale_key)
#' all_tissues = gganatogram(data=hgMale_key, fillOutline='#a6bddb',
#' organism='human', sex='male', fill="colour")
#' all_tissues + theme_void()
#'
#' all_tissues + theme_void() + facet_wrap(~type, ncol=3)
#'
#'
#' col_fill = gganatogram(data=hgMale_key, fillOutline='#a6bddb',
#' organism='human', sex='male', fill="colour")
#' col_fill
#' val_fill = gganatogram(data=hgMale_key, fillOutline='#a6bddb',
#' organism='human', sex='male', fill="value")
#' val_fill
#'
#' col_fill +facet_wrap(~type, ncol=3) + theme_void()
#'
#'
gganatogram <- function(
    data = NULL,
    outline = TRUE,
    fillOutline = 'lightgray',
    organism = "human",
    sex = 'male',
    fill = 'colour',
    anatogram = NULL,
    ggplot2_only = FALSE) {

    anatogram = get_anatogram(
        anatogram = anatogram,
        organism = organism,
        sex = sex)
    if (is.null(anatogram)) {
        stop("Defaults for organism not present. anatogram must be specified")
    }

    nd <-  names(anatogram)
    out_in <- "outline" %in% nd
    if (out_in) {
        outliner <- anatogram$outline
    } else {
        keep = grepl("outline", nd)
        if (!any(keep) && outline) {
            stop("No outline is present in anatogram")
            outline <- FALSE
        }
        if (sum(keep) > 1) {
            warning("Multiple outlines detected, keeping first")
            outliner = anatogram[[which(keep)[1]]]
        }
    }

    path_func = ggpolypath::geom_polypath
    poly_func = ggpolypath::geom_polypath
    if (ggplot2_only) {
        path_func = ggplot2::geom_path
        poly_func = ggplot2::geom_polygon
    }

    p <- ggplot2::ggplot(anatogram$fillFigure,
                         ggplot2::aes(x = x, y = -y))
    if (outline) {
        p <- p + ggplot2::geom_polygon( fill=fillOutline )
        if (ggplot2_only) {
            p <- p + path_func(
                data = outliner, aes(group = group),
                colour = 'black',
                linewidth = 0.2)
        } else {
            p <- p + path_func(
                data = outliner, aes(group = group),
                fill = fillOutline,
                colour = 'black',
                linewidth = 0.2)
        }
    }

    make_color = function(x) {
        with_u = "colour" %in% names(x)
        without_u = "color" %in% names(x)

        if (with_u & !without_u) {
            x$color = x$colour
        }
        if (!with_u & without_u) {
            x$colour = x$color
        }
        x
    }

    if (!is.null(data) && nrow(data) > 0) {
        for (Norgan in 1:nrow(data)){
            mapOrgans <-  anatogram[names(anatogram) %in% data[Norgan,]$organ]
            mapOrgans <- lapply(mapOrgans, function(x) {
                dataOrgan <- data[Norgan,]
                x$value <- dataOrgan[match(x$id, dataOrgan$organ),]$value
                x$type <- dataOrgan[match(x$id, dataOrgan$organ),]$type
                x
            })
            dat = do.call(rbind, mapOrgans)
            dat = make_color(dat)
            dat = dat[stats::complete.cases(dat), ]
            if (fill == 'colour' || fill == "color") {
                organColour <- data[Norgan, ]$colour
                p <-
                    p + poly_func(
                        data = dat,
                        aes(group = group),
                        fill = organColour,
                        colour = "black",
                        linewidth = 0.2
                    )

            } else if (fill == 'value') {
                p <-
                    p + poly_func(
                        data = dat,
                        ggplot2::aes(fill = value, group=group),
                        colour = "black",
                        linewidth = 0.2
                    )

            } else {
                p <-
                    p + path_func(
                        data = dat,
                        colour = "black",
                        linewidth = 0.2)
            }
        }

    } else {
        # warning("No data to plot")
        return(p)
    }
    p
}
