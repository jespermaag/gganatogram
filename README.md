<!-- README.md is generated from README.Rmd. Please edit that file -->

------------------------------------------------------------------------

gganatogram
-----------

Create anatogram images for different organisms. For now only human male is available. This package uses the tissue coordinates from the figure in ArrayExpress Expression Atlas. <https://www.ebi.ac.uk/gxa/home>

Install
-------

Install from github using devtools.

``` r
## install from Github
devtools::install_github("jespermaag/gganatogram")
```

Usage
-----

This package requires `ggplot2` and `ggpolypath`

``` r
library(ggplot2)
library(ggpolypath)
library(gganatogram)
```

In order to use the function gganatogram, you need to have a data frame with organ, colour, and value if you want to.

``` r
organPlot <- data.frame(organ = c("heart", "leukocyte", "nerve", "brain", "liver", "stomach", "colon"), 
 type = c("circulation", "circulation",  "nervous system", "nervous system", "digestion", "digestion", "digestion"), 
 colour = c("red", "red", "purple", "purple", "orange", "orange", "orange"), 
 value = c(10, 5, 1, 8, 2, 5, 5), 
 stringsAsFactors=F)
```

``` r
gganatogram(data=organPlot, fillOutline='#a6bddb', organism='human', sex='male', fill="colour")
```

![](figure/organPlot-1.png)
