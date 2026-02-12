test_that("join works", {
  correct <- tibble::tibble(
    lmo_industry = c(
      "Oil and Gas Extraction",
      "Forestry and Logging",
      "Fishing, Hunting and Trapping",
      "Support Activities for Mining",
      "Construction of Buildings",
      "Management of Companies and Enterprises"
    ),
    value = 1:6
  )

  wrong <- tibble::tibble(
    lmo = c(
      "Oil & Gas Extraction",                  # & instead of and
      "Forestry  and Logging",                 # double space
      "Fishing Hunting & Traping",             # missing comma, &, spelling error
      "Support activities for mining",         # case difference
      "Construction-of Buildings",             # hyphen instead of space
      "Management of Companies & Enterprise",  # singular + &
      "Retail Trade"                           # true non-match
    ),
    value = LETTERS[1:7]
  )

  joined <- typo_inner_join(correct,
                            wrong,
                            "lmo_industry",
                            "lmo",
                            keep_y_key = FALSE,
                            assert_complete = TRUE)

  truth <- structure(list(lmo_industry = c("Oil and Gas Extraction", "Forestry and Logging",
                                           "Support Activities for Mining", "Construction of Buildings",
                                           "Fishing, Hunting and Trapping", "Management of Companies and Enterprises"
  ), value.x = c(1L, 2L, 4L, 5L, 3L, 6L), value.y = c("A", "B",
                                                      "D", "E", "C", "F")), row.names = c(NA, -6L), class = c("tbl_df",
                                                                                                              "tbl", "data.frame"))

  expect_identical(joined, truth)
})
