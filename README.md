
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)

<img src="man/figures/typojoin.png" align="right" height="140"/>

# typojoin

Deterministic, typo-tolerant joins for structured keys.

`typojoin` reconciles data frames that *should already match* except for
minor formatting differences or small alphabetical typos.

It is designed for safe, predictable key harmonization — not general
fuzzy matching.

------------------------------------------------------------------------

## What typojoin does

- Normalizes case, spacing, and selected punctuation  
- Performs exact matching first  
- Resolves remaining keys using string distance  
- Enforces a single best match per record  
- Optionally asserts complete reconciliation

------------------------------------------------------------------------

## What typojoin does not do

- It is not a probabilistic fuzzy join framework  
- It does not return similarity scores for exploratory matching  
- It does not attempt multi-column heuristic reconciliation  
- It is not designed for large Cartesian search problems

------------------------------------------------------------------------

## When You Don’t Need `typojoin`

If discrepancies are purely formatting-related (case, spacing,
punctuation), you can normalize first and use a standard join:

``` r
library(dplyr)
library(tibble)
library(typojoin)

correct <- tibble(industry = c("Day care", "Construction"))
wrong   <- tibble(industry = c("Day-care", "Construction"))

correct$key_norm <- clean_normalize(correct$industry)
wrong$key_norm   <- clean_normalize(wrong$industry)

inner_join(correct, wrong, by = "key_norm")
```

    ## # A tibble: 2 × 3
    ##   industry.x   key_norm     industry.y  
    ##   <chr>        <chr>        <chr>       
    ## 1 Day care     day care     Day-care    
    ## 2 Construction construction Construction

------------------------------------------------------------------------

## When You Do Need `typojoin`

If small alphabetical errors are present (e.g., “Daycaer” vs “Daycare”),
normalization alone is insufficient.

`typo_inner_join()` computes edit distances internally and
deterministically selects the best match per row:

``` r
library(typojoin)
library(tibble)

correct <- tibble(
  industry = c("Daycare", "Construction"),
  value = c(1, 2)
)

wrong <- tibble(
  industry = c("Daycaer", "Construction"),
  value = c("A", "B")
)

typo_inner_join(correct, wrong, "industry")
```

    ## # A tibble: 2 × 4
    ##   industry.x   value.x industry.y   value.y
    ##   <chr>          <dbl> <chr>        <chr>  
    ## 1 Construction       2 Construction B      
    ## 2 Daycare            1 Daycaer      A

------------------------------------------------------------------------

## Why not fuzzyjoin?

`fuzzyjoin::stringdist_join()` is flexible and powerful.

`typojoin` is intentionally narrower:

- deterministic  
- single best match resolution  
- exact-first logic  
- production-friendly reconciliation

If your data should already align except for small human errors,
`typojoin` provides safer defaults.

------------------------------------------------------------------------

## Installation

``` r
install.packages("pak")
pak::pak("bcgov/typojoin")
```

------------------------------------------------------------------------

`typojoin` is built for pipelines where key alignment is expected — but
humans are involved.
