# unit tests for gganatogram
context("gganatogram")
test_that("gganatogram",{

  # test the basic function first
  # produces just an outline
  male_image <- gganatogram()

  # male_image is a ggplot object and as such is a list of 9
  expect_is(male_image,"ggplot")
  expect_equal(mode(male_image), "list")
  expect_equal(length(male_image), 9)
  expect_equal(dim(male_image$data)[1], 1425)
  expect_equal(dim(male_image$data)[2], 6)

  # male_image should have some labels
  expect_equal(male_image$labels$x, "x")
  expect_equal(male_image$labels$y, "-y")

  # check male_image layers - should have one
  expect_equal(length(male_image$layers), 2)
  # https://stackoverflow.com/questions/13457562/how-to-determine-the-geom-type-of-each-layer-of-a-ggplot2-object/43982598#43982598
  # types of layers...
  expect_equal(class(male_image$layers[[1]]$geom)[1], "GeomPolygon")
  expect_equal(class(male_image$layers[[1]]$geom)[2], "Geom")

  ## Test a more detailed group of layers
  # create data.frame for output
  organPlot <- data.frame(organ = c("heart", "leukocyte", "nerve", "brain",
    "liver", "stomach", "colon"),
    type = c("circulation", "circulation",  "nervous system", "nervous system",
      "digestion", "digestion", "digestion"),
    colour = c("red", "red", "purple", "purple", "orange", "orange", "orange"),
    value = c(10, 5, 1, 8, 2, 5, 5),
    stringsAsFactors=F)

  # make female_image
  female_image <- gganatogram(data=organPlot,
    fillOutline='#a6bddb',
    organism='human',
    sex='female',
    fill="colour")

  # female_image is a ggplot object and as such is a list of 9
  expect_is(female_image,"ggplot")
  expect_equal(mode(female_image), "list")
  expect_equal(length(female_image), 9)

  # female_image should have some labels
  expect_equal(female_image$labels$x, "x")
  expect_equal(female_image$labels$y, "-y")

  # check the layers
  # check female_image layers - should have 9
  # two basic ones and 7 as added using organPlot
  expect_equal(length(female_image$layers), 9)
  # last layer should be "colon" as per organPlot
  expect_equal(rownames(female_image$layers[[9]]$data[1])[[1]],
    "colon.2")

  # https://stackoverflow.com/questions/13457562/how-to-determine-the-geom-type-of-each-layer-of-a-ggplot2-object/43982598#43982598
  # types of layers...
  # first one is a GeomPolygons
  expect_equal(class(female_image$layers[[1]]$geom)[1], "GeomPolygon")
  # rest are different things...
  expect_equal(class(female_image$layers[[1]]$geom)[2], "Geom")
  expect_equal(class(female_image$layers[[1]]$geom)[3], "ggproto")
  expect_equal(class(female_image$layers[[1]]$geom)[4], "gg")


  # make male_image
  male_image <- gganatogram(data=organPlot,
    fillOutline='#a6bddb',
    organism='human',
    sex='male',
    fill="colour")

  # male_image is a ggplot object and as such is a list of 9
  expect_is(male_image,"ggplot")
  expect_equal(mode(male_image), "list")
  expect_equal(length(male_image), 9)

  # male_image should have some labels
  expect_equal(male_image$labels$x, "x")
  expect_equal(male_image$labels$y, "-y")

  # check the layers
  # check male_image layers - should have 9
  # two basic ones and 7 as added using organPlot
  expect_equal(length(male_image$layers), 9)
  # last layer should be "colon" as per organPlot
  expect_equal(rownames(male_image$layers[[9]]$data[1])[[1]],
    "colon.2")


  # https://stackoverflow.com/questions/13457562/how-to-determine-the-geom-type-of-each-layer-of-a-ggplot2-object/43982598#43982598
  # types of layers...
  # first one is a GeomPolygons
  expect_equal(class(male_image$layers[[1]]$geom)[1], "GeomPolygon")
  # rest are different things...
  expect_equal(class(male_image$layers[[1]]$geom)[2], "Geom")
  expect_equal(class(male_image$layers[[1]]$geom)[3], "ggproto")
  expect_equal(class(male_image$layers[[1]]$geom)[4], "gg")


  ## plot all of the human female layers and check number
  # should be 66, 64 tissues in key and background and outline
  hgFemale <- gganatogram(data=hgFemale_key,
    fillOutline='#a6bddb',
    organism='human', sex='female', fill="colour") + theme_void()
  expect_equal(length(hgFemale$layers), 66)
  # ninth layer should be "duodenum.2" as per hgFemale_key
  expect_equal(rownames(hgFemale$layers[[9]]$data[1])[[1]],
    "duodenum.2")
  # check some other layers
  expect_equal(rownames(hgFemale$layers[[65]]$data[1])[[1]],
    "spinal_cord.2")
  expect_equal(rownames(hgFemale$layers[[54]]$data[1])[[1]],
    "uterus.2")


  ## plot all of the human male layers and check number
  # 61 layers in key
  hgMale <- gganatogram(data=hgMale_key,
    fillOutline='#a6bddb',
    organism='human', sex='male', fill="colour") + theme_void()
  expect_equal(length(hgMale$layers), 63)
  # check some layers
  expect_equal(rownames(hgMale$layers[[9]]$data[1])[[1]],
    "caecum.2")
  expect_equal(rownames(hgMale$layers[[63]]$data[1])[[1]],
    "prostate.1")
  expect_equal(rownames(hgMale$layers[[20]]$data[1])[[1]],
    "spinal_cord.2")

  # plot all of the mouse female layers and check number
  mmFemale <- gganatogram(data=mmFemale_key,
    outline = T,
    fillOutline='#a6bddb',
    organism='mouse', sex='female', fill="colour")  +theme_void()
  expect_equal(length(mmFemale$layers), nrow(mmFemale_key)+2)
  expect_equal(rownames(mmFemale$layers[[19]]$data[1])[[1]],
    "vagina.2")


  # plot all of the mouse male layers
  mmMale <- gganatogram(data=mmMale_key,
    fillOutline='#a6bddb',
    organism='mouse', sex='male', fill="colour") + theme_void()
  expect_equal(length(mmMale$layers), nrow(mmMale_key)+2)
  expect_equal(rownames(mmMale$layers[[19]]$data[1])[[1]],
    "seminal_vesicle.2")

})

