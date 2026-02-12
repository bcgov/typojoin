#' Normalize Keys for Typo-Tolerant Matching
#'
#' Cleans strings by standardizing whitespace, case,
#' and selected punctuation for key comparison.
#'
#' @param x A character vector.
#' @return A normalized character vector.
#' @export
clean_normalize <- function(x) {
  x <- as.character(x)
  x <- gsub("\u00A0", " ", x)
  x <- gsub("[\t\r\n]", " ", x)
  x <- gsub("&", " and ", x)
  x <- tolower(x)
  x <- gsub("[^a-z]", " ", x)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}
