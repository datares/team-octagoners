
library(tidyverse)
library(RColorBrewer)
library(yarrr)

kaggle <- read_csv("kaggle.csv", col_types = cols()) %>%
  select(-contains("bout"), -constant_1)

  # physical attribute data check ----

which(kaggle$B_Height_cms == 0) # integer(0)
which(kaggle$R_Height_cms == 0) # integer(0)
which(kaggle$B_Reach_cms == 0) # 366 -> irwin rivera
  # reach = 170 in row 183 and reach = 168 in row 244: use reach = 169
kaggle$B_Reach_cms[366] <- 169
which(kaggle$R_Reach_cms == 0) # integer(0)
which(kaggle$B_Weight_lbs == 0) # integer(0)
which(kaggle$R_Weight_lbs == 0) # integer(0)

  # pirate plots of win difference against physical attribute difference  ----

kaggle %>%
  mutate(odds_difference =
           abs(ifelse(R_odds < 0, R_odds - B_odds, B_odds - R_odds))) %>%
  group_by(weight_class) %>%
  mutate(gender = ifelse(gender == "MALE", "Male", "Female"),
         average_weight = sum(R_Weight_lbs, B_Weight_lbs) / n()) %>%
  ggplot() + geom_boxplot(aes(fct_reorder(weight_class, odds_difference),
                              odds_difference, fill = average_weight)) +
  scale_fill_gradient("Average Weight", low = "#C6DBEF", high = "#08306B") +
  labs(title = "Difference in Odds by Weight Class",
       x = "Weight Class", y = "Difference in Odds") +
  theme_bw() + theme(plot.title = element_text(face = "bold", hjust = 0.5)) + 
  facet_wrap(~gender, nrow = 2, scales = "free_x")

df <- kaggle %>%
    # calculate signed differences
  mutate(height = ifelse(Winner == "Red",
                         R_Height_cms - B_Height_cms,
                         B_Height_cms - R_Height_cms),
         reach = ifelse(Winner == "Red",
                        R_Reach_cms - B_Reach_cms,
                        B_Reach_cms - R_Reach_cms),
         weight = ifelse(Winner == "Red",
                         R_Weight_lbs - B_Weight_lbs,
                         B_Weight_lbs - R_Weight_lbs),
         wins = ifelse(Winner == "Red", R_wins - B_wins, B_wins - R_wins)) %>%
    # standardize values
  mutate(height = (height - mean(height)) / sd(height),
         reach = (reach - mean(reach)) / sd(reach),
         weight = (weight - mean(weight)) / sd(weight),
         wins = (wins - mean(wins)) / sd(wins)) %>%
    # bin x-values by rounding
  mutate(height = round(height), reach = round(reach),
         weight = round(weight)) %>%
  select(height, reach, weight, wins)

pirateplot(wins ~ height, data = df,
           xlab = "Standardized and Binned Height Difference",
           ylab = "Standardized Difference in Number of Wins")
pirateplot(wins ~ reach, data = df,
           xlab = "Standardized and Binned Reach Difference",
           ylab = "Standardized Difference in Number of Wins")
pirateplot(wins ~ weight, data = df,
           xlab = "Standardized and Binned Weight Difference",
           ylab = "Standardized Difference in Number of Wins")
