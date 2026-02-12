utils::globalVariables(c("x_id", "dist", ".key_norm"))
#' @importFrom rlang .data
NULL
add_normalized_key <- function(df, col_name) {
  df |>
    dplyr::mutate(
      .key_norm = clean_normalize(.data[[col_name]])
    )
}

suffix_columns <- function(df, suffix) {
  cols <- setdiff(names(df), ".key_norm")
  names(df)[names(df) %in% cols] <- paste0(cols, suffix)
  df
}

fuzzy_candidates <- function(x_remain, y_remain, max_dist, method) {

  grid <- tidyr::crossing(
    x_id = seq_len(nrow(x_remain)),
    y_id = seq_len(nrow(y_remain))
  )

  len_diff <- abs(
    nchar(x_remain$.key_norm[grid$x_id]) -
      nchar(y_remain$.key_norm[grid$y_id])
  )

  include <- len_diff <= max_dist

  if (!any(include)) return(NULL)

  dists <- rep(NA_real_, nrow(grid))

  dists[include] <- stringdist::stringdist(
    x_remain$.key_norm[grid$x_id][include],
    y_remain$.key_norm[grid$y_id][include],
    method = method
  )

  keep <- !is.na(dists) & dists <= max_dist

  if (!any(keep)) return(NULL)

  tibble::tibble(
    x_id = grid$x_id[keep],
    y_id = grid$y_id[keep],
    dist = dists[keep]
  )
}

best_per_x <- function(candidates) {
  candidates |>
    dplyr::group_by(x_id) |>
    dplyr::slice_min(dist, with_ties = FALSE) |>
    dplyr::ungroup()
}

