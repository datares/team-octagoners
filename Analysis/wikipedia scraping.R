
library(tidyverse)
library(rvest)
library(lubridate)

  # extract text ----

wiki_text <- read_html("https://en.wikipedia.org/wiki/List_of_UFC_events") %>%
  html_nodes("#Past_events td") %>%
  html_text()

  # organize text into table ----

wiki_indices <- c(which(str_detect(wiki_text, "^[0-5]{1}[0-9]{2}\n$")),
                  length(wiki_text) + 1)

wiki_table <- data.frame()
for (i in seq_along(wiki_indices)[-length(wiki_indices)]) {
  row <- wiki_text[seq(wiki_indices[i], wiki_indices[i + 1] - 1)]
  if (length(row) == 7) {
    row <- str_trim(row, "both")
    names(row) <- c("id", "event", "date", "venue", "location",
                    "attendance", "reference")
    row <- as.data.frame(t(row))
  } else if (length(row) > 7) {
    row <- row[seq(1, which(str_detect(row, "^—\n$"))[1] - 1)]
  }
    # for short rows, assign values to columns
  if (length(row) < 7) {
    row <- str_trim(row, "both")
    attendance <- which(str_detect(row, "^0$") | str_detect(row, "^N/A$") |
                          str_detect(row, "^[0-9,]{3,}"))
      # id would match "^[0-9,]{3,}" pattern
    attendance <- attendance[attendance != 1]
    reference <- which(str_detect(row, "^\\[[0-9]{1,}\\]"))
    if (length(attendance) != 0) {
      if (attendance == 5) {
        venue <- row[4]
        location <- NA
      } else if (attendance == 6) {
        venue <- row[4]
        location <- row[5]
      } else {
        venue <- NA
        location <- NA
      }
    } else if (length(reference) != 0) {
        # only 514 to 551 should have missing attendance
      if (reference == 6) {
        venue <- row[4]
        location <- row[5]
      } else {
        venue <- NA
        location <- NA
      }
    }
    attendance <- ifelse(length(attendance) == 0, NA, row[attendance])
    reference <- ifelse(length(reference) == 0, NA, row[reference])
    row <- data.frame(id = row[1], event = row[2], date = row[3],
                      venue = venue, location = location,
                      attendance = attendance, reference = reference)
  }
  wiki_table <- rbind(wiki_table, row)
}

  # clean and save table ----

wiki_table$id <- as.integer(wiki_table$id)
wiki_table$date <- mdy(wiki_table$date)

    # fill in data for merged cells

for (i in seq_len(nrow(wiki_table))) {
  previous <- wiki_table[i - 1, ]
  if (is.na(wiki_table$venue[i])) {
    wiki_table$venue[i] <- previous$venue
  }
  if (is.na(wiki_table$location[i])) {
    wiki_table$location[i] <- previous$location
  }
  if (is.na(wiki_table$attendance[i])) {
    wiki_table$attendance[i] <- previous$attendance
  }
  if (is.na(wiki_table$reference[i])) {
    wiki_table$reference[i] <- previous$reference
  }
}

wiki_table$attendance[wiki_table$attendance == "N/A"] <- NA
wiki_table$attendance <- wiki_table$attendance %>%
  str_replace("\\D", "") %>%
  str_trim("both") %>%
  as.integer()
wiki_table$reference[wiki_table$reference == ""] <- NA

write.csv(wiki_table, "wikipedia.csv", row.names = FALSE)
