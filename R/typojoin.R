#' Deterministic Typo-Tolerant Join
#'
#' Reconciles two data frames that should match except for
#' minor formatting differences or small alphabetical typos.
#' @param x,y Data frames to join.
#' @param by_x A character string giving the column name in `x`
#'   to use as the join key.
#' @param by_y A character string giving the column name in `y`
#'   to use as the join key. Defaults to `by_x`.
#' @param max_dist Maximum string distance.
#' @param method String distance method.
#' @param keep_y_key Keep messy key in output.
#' @param assert_complete Error if unmatched rows remain.
#' @return A joined data frame.
#' @export
typo_inner_join <- function(x, y,
                            by_x,
                            by_y = by_x,
                            max_dist = 2,
                            method = "lv",
                            keep_y_key = TRUE,
                            assert_complete = FALSE) {

  # --- Validate column inputs ---
  if (!is.character(by_x) || length(by_x) != 1) {
    stop("`by_x` must be a single column name (string).", call. = FALSE)
  }

  if (!is.character(by_y) || length(by_y) != 1) {
    stop("`by_y` must be a single column name (string).", call. = FALSE)
  }

  if (!by_x %in% names(x)) {
    stop(sprintf("Column '%s' not found in x.", by_x), call. = FALSE)
  }

  if (!by_y %in% names(y)) {
    stop(sprintf("Column '%s' not found in y.", by_y), call. = FALSE)
  }

  by_x_name <- by_x
  by_y_name <- by_y

  # --- Normalize keys ---
  x <- add_normalized_key(x, by_x_name)
  y <- add_normalized_key(y, by_y_name)

  # --- Suffix user columns ---
  x <- suffix_columns(x, ".x")
  y <- suffix_columns(y, ".y")

  # --- Exact matches ---
  exact <- dplyr::inner_join(x, y, by = ".key_norm") |>
    dplyr::select(-.key_norm)

  # --- Remove exact matches ---
  x_remain <- dplyr::anti_join(x, y, by = ".key_norm")
  y_remain <- dplyr::anti_join(y, x, by = ".key_norm")

  out <- exact

  # --- Fuzzy stage ---
  if (nrow(x_remain) > 0 && nrow(y_remain) > 0) {

    candidates <- fuzzy_candidates(
      x_remain,
      y_remain,
      max_dist = max_dist,
      method = method
    )

    if (!is.null(candidates) && nrow(candidates) > 0) {

      best <- best_per_x(candidates)

      x_fuzzy <- x_remain[best$x_id, , drop = FALSE] |>
        dplyr::select(-.key_norm)

      y_fuzzy <- y_remain[best$y_id, , drop = FALSE] |>
        dplyr::select(-.key_norm)

      fuzzy <- dplyr::bind_cols(x_fuzzy, y_fuzzy)

      out <- dplyr::bind_rows(out, fuzzy)
    }
  }

  # --- Optional cleanup ---
  if (!keep_y_key) {
    messy <- paste0(by_y_name, ".y")
    canonical <- paste0(by_x_name, ".x")

    if (messy %in% names(out)) {
      out <- dplyr::select(out, -dplyr::all_of(messy))
    }

    if (canonical %in% names(out)) {
      names(out)[names(out) == canonical] <- by_x_name
    }
  }

  # --- Optional completeness check ---
  if (assert_complete) {
    if (nrow(out) != nrow(x)) {
      stop("Not all rows from x matched to y.", call. = FALSE)
    }
  }

  out
}
