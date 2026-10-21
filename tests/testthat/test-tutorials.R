test_that("all tutorials are found by learnr", {
  tutorials <- list_fos_tutorials()
  expect_setequal(tutorials$name,
                  c("Iris-dataset", "Food-dataset", "NMR-metabolomics"))
})

test_that("the data files are installed next to the tutorials", {
  expect_true(nzchar(system.file("tutorials", "Food-dataset", "foods.csv",
                                 package = "FOStutorials")))
  expect_true(nzchar(system.file("tutorials", "NMR-metabolomics",
                                 "metabolomics.xlsx",
                                 package = "FOStutorials")))
})

test_that("run_fos_tutorial() rejects unknown tutorials", {
  expect_error(run_fos_tutorial("does-not-exist"), "must be one of")
})

test_that("all tutorials have a description", {
  tutorials <- list_fos_tutorials()
  expect_true(all(!is.na(tutorials$description) & nzchar(tutorials$description)))
})
