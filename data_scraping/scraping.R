# Save the front pages of the three websites
download.file (url = 'http://www.nytimes.com/',
                               destfile = "nytimes.html",
                               method = "curl",
                               quiet = TRUE,
                               mode = "wb")
download.file (url = 'http://www.amazon.com/',
               destfile = "amazon.html",
               method = "curl",
               quiet = TRUE,
               mode = "wb")
download.file (url = 'http://www.epl.com/',
               destfile = "epl.html",
               method = "curl",
               quiet = TRUE,
               mode = "wb")
conn <- file('amazon.html',open="r")
amzn.tmp <- readLines(conn)
conn <- file('epl.html',open="r")
epl.tmp <- readLines(conn)
conn <- file('nytimes.html',open="r")
nytimes.tmp <- readLines(conn)

# join three into one list
join.lst.tmp <- list(amzn.tmp, epl.tmp, nytimes.tmp)

# write out the list to three files
for (i in seq_along(join.lst.tmp)) {
  writeLines(join.lst.tmp[[i]],  paste0("pages", i, ".html"))
  
}

# download another file
download.file("http://www.r-datacollection.com/materials/html/fortunes3.html",
              "fortunes3.html")
conn <- file("fortunes3.html", open="r")
fortunes.tmp <- readLines(conn)
idx <- grep('<script type=\"text/javascript\" src', fortunes.tmp) 
fortunes.tmp[idx]
