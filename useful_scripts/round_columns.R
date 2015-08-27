round_col <- function(col, places=2){
    as.numeric(format(round(col, places), nsmall = places))
}

round_cols <- function(df, idx, places=2){
    df[, idx] <- apply(df[, idx], 2, round_col, places)
    df
}
