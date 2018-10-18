#' Get anatogram from defaults in gganatogram
#'
#' @param organism The organism to be plotted.  Currently,
#' only \code{human} is accepted.
#' @param sex Sex of the organism
#' @param anatogram A list, similar to \code{\link{hgMale_list}}
#' that will create the outline and has the corresponding organ
#' \code{data.frame}s in that list
#' @return A list of values for the \code{anatogram}
#' @export
#'
#' @examples
#' get_anatogram()
#' get_anatogram(sex = "female")
#' get_anatogram(organism = "mouse")
get_anatogram = function(
  organism = "human",
  sex = 'male',
  anatogram = NULL
) {
  if (is.null(anatogram)) {
    organism = tolower(organism)
    organism = match.arg(
      organism,
      choices = c("human", "mouse", names(gganatogram::other_list), names(gganatogram::cell_list)))
    sex = tolower(sex)
    sex = match.arg(sex, choices = c("male", "female"))
    if (organism == 'human') {
      if (sex == 'male') {
        anatogram <- gganatogram::hgMale_list
        anatogram$outline <- anatogram$human_male_outline
        anatogram$fillFigure <- anatogram$fillFigure
      } else if ( sex == 'female') {
        anatogram <- gganatogram::hgFemale_list
        anatogram$outline <- anatogram$outline
        anatogram$fillFigure <- anatogram$fillFigure
      }
    } else if (organism == 'mouse') {
      if (sex == 'male') {
        anatogram <- gganatogram::mmMale_list
        anatogram$outline <- anatogram$outline
        anatogram$fillFigure <- anatogram$LAYER_OUTLINE
      } else if ( sex == 'female') {
        anatogram <- gganatogram::mmFemale_list
        anatogram$outline <- anatogram$outline
        anatogram$fillFigure <- anatogram$LAYER_OUTLINE
      }
    } else if (organism %in% names(gganatogram::other_list) ) {
        anatogram <- gganatogram::other_list[[organism]]
        if (length(grep('outline', names(anatogram))) >=1) {
          anatogram$outline <- do.call(rbind, anatogram[grep('outline', names(anatogram))])
          anatogram$outline <- anatogram$outline[complete.cases(anatogram$outline),]
        } else {
          anatogram$outline <- do.call(rbind, anatogram[grep('LAYER_OUTLINE', names(anatogram))])
          anatogram$outline <- anatogram$outline[complete.cases(anatogram$outline),]

        }  
        anatogram$fillFigure <- do.call(rbind, anatogram[grep('LAYER_OUTLINE', names(anatogram))])
        #anatogram$fillFigure <- anatogram$fillFigure[complete.cases(anatogram$fillFigure),]

    } else if (organism %in% names(gganatogram::cell_list) ) {
        anatogram <- gganatogram::cell_list[[organism]]
        anatogram$outline <- do.call(rbind, anatogram[grep('cytosol', names(anatogram))])
        anatogram$outline <- anatogram$outline[complete.cases(anatogram$outline),]

        anatogram$fillFigure <- do.call(rbind, anatogram[grep('cytosol', names(anatogram))])
        #anatogram$fillFigure <- anatogram$fillFigure[complete.cases(anatogram$fillFigure),]

    }
  }
  return(anatogram)
}
