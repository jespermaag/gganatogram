# unit tests for gganatogram
context("gganatogram")
test_that("gganatogram",{

  # test the basic function first
  man_image <- gganatogram()

  # man_image is a ggplot object and as such is a list of 9
  expect_is(man_image,"ggplot")
  expect_equal(mode(man_image), "list")
  expect_equal(length(man_image), 9)
  expect_equal(dim(man_image$data)[1], 1425)
  expect_equal(dim(man_image$data)[2], 5)

  # man_image should have some labels
  expect_equal(man_image$labels$x, "x")
  expect_equal(man_image$labels$y, "-y")

  # check man_image layers - should have one
  #expect_equal(length(man_image$layers), 1)
  expect_equal(length(man_image$layers), 2)
  # https://stackoverflow.com/questions/13457562/how-to-determine-the-geom-type-of-each-layer-of-a-ggplot2-object/43982598#43982598
  # types of layers...
  expect_equal(class(man_image$layers[[1]]$geom)[1], "GeomPolygon")

  ## Test a more detailed group....
  # create data.frame for output
  organPlot <- data.frame(organ = c("heart", "leukocyte", "nerve", "brain",
    "liver", "stomach", "colon"),
    type = c("circulation", "circulation",  "nervous system", "nervous system",
      "digestion", "digestion", "digestion"),
    colour = c("red", "red", "purple", "purple", "orange", "orange", "orange"),
    value = c(10, 5, 1, 8, 2, 5, 5),
    stringsAsFactors=F)

  # make man_image
  man_image <- gganatogram(data=organPlot,
    fillOutline='#a6bddb',
    organism='human',
    sex='male',
    fill="colour")

  # man_image is a ggplot object and as such is a list of 9
  expect_is(man_image,"ggplot")
  expect_equal(mode(man_image), "list")
  expect_equal(length(man_image), 9)

  # man_image should have some labels
  expect_equal(man_image$labels$x, "x")
  expect_equal(man_image$labels$y, "-y")

  # check the layers
  # check man_image layers - should have 52
  #expect_equal(length(man_image$layers), 52)
  expect_equal(length(man_image$layers), 53)
  # https://stackoverflow.com/questions/13457562/how-to-determine-the-geom-type-of-each-layer-of-a-ggplot2-object/43982598#43982598
  # types of layers...
  # first one is a GeomPolygons
  expect_equal(class(man_image$layers[[1]]$geom)[1], "GeomPolygon")
  # rest are different things...
  expect_equal(class(man_image$layers[[1]]$geom)[2], "Geom")
  expect_equal(class(man_image$layers[[1]]$geom)[3], "ggproto")
  expect_equal(class(man_image$layers[[1]]$geom)[4], "gg")
})

