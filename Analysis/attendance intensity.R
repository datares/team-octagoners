
library(tidyverse)
library(lubridate)
library(textclean)
library(yarrr)

kaggle <- read_csv("kaggle.csv", col_types = cols()) %>%
  select(-contains("bout"), -constant_1)
wikipedia <- read_csv("wikipedia.csv", col_types = "icDccic")

  # prepare data for merging ----

kaggle$date <- mdy(kaggle$date)

wikipedia$country <- map_chr(wikipedia$location, function(x) {
  x <- str_trim(tail(unlist(str_split(x, ", ")), 1), "both")
  x <- ifelse(x == "U.S" | x == "U.S.", "USA", x)
  ifelse(x == "U.K.", "United Kingdom", x)
})

wikipedia$event <- replace_non_ascii(wikipedia$event)
wikipedia <- wikipedia %>%
  bind_cols(map_df(wikipedia$event, function(x) {
    x <- str_extract(x, ": [A-z ]{1,} vs\\. [A-z ]{1,}")
    x <- if (!is.na(x)) {
      str_split(x, " vs\\. ") %>%
        unlist() %>%
        str_replace("[^A-z]", "") %>%
        str_trim("both")
    } else {
      c(NA, NA)
    }
    data.frame(fighter1 = x[1], fighter2 = x[2])
  }))

  # merge using country, fighter last name and date ----

find_closest_match <- function(i) {
  row <- kaggle[i, ]
  match <- wikipedia %>%
    filter(country == row$country) %>%
    filter(str_detect(row$R_fighter, fighter1) |
             str_detect(row$B_fighter, fighter1) &
           str_detect(row$R_fighter, fighter2) |
             str_detect(row$B_fighter, fighter2)) %>%
    filter((date >= row$date - 1) & (date <= row$date + 1))
  ifelse(nrow(match) == 0, NA, match$attendance)
}
kaggle$wikipedia_attendance <-
  map_int(seq_len(nrow(kaggle)), find_closest_match)

  # prepare measures of intensity and calculate attendance percentiles ----

conditional_sum <- function(x, y) {
  if (is.na(x) & is.na(y)) {
    NA
  } else if (is.na(x)) {
    y
  } else if (is.na(y)) {
    x
  } else {
    x + y
  }
}

df <- kaggle %>%
  filter(!is.na(wikipedia_attendance))
df <- df %>%
  bind_cols(map_df(seq_len(nrow(df)), function(i) {
    row <- df[i, ]
    strikes <- conditional_sum(row$B_avg_SIG_STR_landed,
                               row$R_avg_SIG_STR_landed)
    takedowns <- conditional_sum(row$B_avg_TD_landed, row$R_avg_TD_landed)
    knockouts <- conditional_sum(row[["B_win_by_KO/TKO"]],
                                 row[["R_win_by_KO/TKO"]])
    data.frame(strikes = strikes, takedowns = takedowns, knockouts = knockouts)
  })) %>%
  select(wikipedia_attendance, strikes, takedowns, knockouts)
attendance_percentile <- ecdf(kaggle$wikipedia_attendance)
df <- df %>%
  mutate(attendance_percentile = attendance_percentile(wikipedia_attendance))
df$attendance_bin <- map_int(df$attendance_percentile, function(x) {
  x <- ifelse(x <= 0.1, 1,
              ifelse(x <= 0.2, 2,
                     ifelse(x <= 0.3, 3,
                            ifelse(x <= 0.4, 4,
                                   ifelse(x <= 0.5, 5,
                                          ifelse(x <= 0.6, 6,
                                                 ifelse(x <= 0.7, 7,
                                                        ifelse(x <= 0.8, 8,
                                                               ifelse(x <= 0.9, 9, 10)))))))))
  as.integer(x)
})

  # visualize results ----

pirateplot(strikes + takedowns + knockouts ~ attendance_bin, data = df,
           xlab = "Attendance, Binned by Percentile", ylab = "Intensity")
  