count_char_ocurrences <- function(char, s) {
    s2 <- gsub(char, "", s, fixed = TRUE)
    return (nchar(s) - nchar(s2))
}

lines <- readLines("loans.txt")
seps <- count_char_ocurrences("|", lines)

good_lines_indexes <- seps == 41 #42 columns
good_lines <- lines[good_lines_indexes]

#Write to a file
file_con <- file("loans_preprocessed.txt")
writeLines(good_lines, file_con)
close(file_con)