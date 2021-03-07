
library(tidyverse)
library(RColorBrewer)

kaggle <- read_csv("kaggle.csv", col_types = cols()) %>%
  select(-contains("bout"), -constant_1)

weight_class_win_type <- kaggle %>%
  select(weight_class, contains("win_by")) %>%
  mutate(dm_sum = R_win_by_Decision_Majority + B_win_by_Decision_Majority,
         dm_diff = abs(R_win_by_Decision_Majority - B_win_by_Decision_Majority),
         ds_sum = R_win_by_Decision_Split + B_win_by_Decision_Split,
         ds_diff = abs(R_win_by_Decision_Split - B_win_by_Decision_Split),
         du_sum = R_win_by_Decision_Unanimous + B_win_by_Decision_Unanimous,
         du_diff = abs(R_win_by_Decision_Unanimous - B_win_by_Decision_Unanimous),
         ko_sum = `R_win_by_KO/TKO` + `B_win_by_KO/TKO`,
         ko_diff = abs(`R_win_by_KO/TKO` - `B_win_by_KO/TKO`),
         submission_sum = R_win_by_Submission + B_win_by_Submission,
         submission_diff = abs(R_win_by_Submission - B_win_by_Submission),
         doctor_sum = R_win_by_TKO_Doctor_Stoppage + B_win_by_TKO_Doctor_Stoppage,
         doctor_diff = abs(R_win_by_TKO_Doctor_Stoppage - B_win_by_TKO_Doctor_Stoppage)) %>%
  select(weight_class, contains("sum"), contains("diff"))

  # male fighters ----

weight_class_win_type %>%
  select(weight_class, contains("sum")) %>%
  filter(str_detect(weight_class, "Women's", negate = TRUE)) %>%
  mutate(row_total = dm_sum + ds_sum + du_sum + ko_sum +
           submission_sum + doctor_sum,
         `Majority Decision` = dm_sum / row_total,
         `Split Decision` = ds_sum / row_total,
         `Unanimous Decision` = du_sum / row_total,
         `KO/TKO` = ko_sum / row_total,
         `Submission` = submission_sum / row_total,
         `Doctor Stoppage` = doctor_sum / row_total) %>%
  select(weight_class, c("Majority Decision", "Split Decision",
                         "Unanimous Decision", "KO/TKO", "Submission",
                         "Doctor Stoppage")) %>%
  pivot_longer(c("Majority Decision", "Split Decision", "Unanimous Decision",
                 "KO/TKO", "Submission", "Doctor Stoppage"),
               names_to = "prop_type", values_to = "prop_values") %>%
  ggplot() + geom_boxplot(aes(prop_type, prop_values, color = prop_type),
                          show.legend = FALSE) +
  scale_color_discrete(type = brewer.pal(7, "Set1")[-6]) +
  labs(title = "Mean Proportion of Win Type by Male Weight Class",
       x = "Win Type", y = "Mean Proportion") + 
  facet_wrap(~factor(weight_class,
                     levels = c("Flyweight", "Bantamweight", "Featherweight",
                                "Lightweight", "Welterweight", "Middleweight",
                                "Light Heavyweight", "Heavyweight", "Catch Weight")),
             nrow = 3) + coord_flip() +
  theme_bw() + theme(plot.title = element_text(face = "bold", hjust = 0.5))

  # female fighters ----

weight_class_win_type %>%
  select(weight_class, contains("sum")) %>%
  filter(str_detect(weight_class, "Women's")) %>%
  mutate(row_total = dm_sum + ds_sum + du_sum + ko_sum +
           submission_sum + doctor_sum,
         `Majority Decision` = dm_sum / row_total,
         `Split Decision` = ds_sum / row_total,
         `Unanimous Decision` = du_sum / row_total,
         `KO/TKO` = ko_sum / row_total,
         `Submission` = submission_sum / row_total,
         `Doctor Stoppage` = doctor_sum / row_total) %>%
  select(weight_class, c("Majority Decision", "Split Decision",
                         "Unanimous Decision", "KO/TKO", "Submission",
                         "Doctor Stoppage")) %>%
  pivot_longer(c("Majority Decision", "Split Decision", "Unanimous Decision",
                 "KO/TKO", "Submission", "Doctor Stoppage"),
               names_to = "prop_type", values_to = "prop_values") %>%
  ggplot() + geom_boxplot(aes(prop_type, prop_values, color = prop_type),
                          show.legend = FALSE) +
  scale_color_discrete(type = brewer.pal(7, "Set1")[-6]) +
  labs(title = "Mean Proportion of Win Type by Female Weight Class",
       x = "Win Type", y = "Mean Proportion") + 
  facet_wrap(~factor(weight_class,
                     levels = c("Women's Strawweight", "Women's Flyweight",
                                "Women's Bantamweight", "Women's Featherweight")),
             nrow = 2, scales = "free_y") + coord_flip() +
  theme_bw() + theme(plot.title = element_text(face = "bold", hjust = 0.5))
