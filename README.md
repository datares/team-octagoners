# Team-Octagoners
# UFC Sport Analytics - Champion Prediction, Players Analysis 
This repository provides explanations of the data analysis process for the DataRes article ["What makes an Ultimate Fighter? UFC Sports analytics & prediction] (https://ucladatares.medium.com/what-makes-an-ultimate-fighter-ufc-sports-analytics-prediction-2d4cf4314b14?source=friends_link&sk=643bc43bf42a1aff47e3284f8ade205d)", published [March 24th], 2021. Please check out our article, which contains visualizations and insights about UFC.

Contributors: 

Project Lead: Hana Lim

Data Visualization Specialists: Lia Bergman-Turnbull, Dara Tan, Ben Brill 

Content Specialists: Zoeb Jamal, Kaushik Naresh 

# Data
The data used to develop our Medium article came from: [Kaggle](https://www.kaggle.com/mdabbert/ultimate-ufc-dataset) and [Wikipedia](https://en.wikipedia.org/wiki/List_of_UFC_events). 

The Wikipedia dataset contained data pertaining to each UFC event including the venue, location and attendance for each event. This data stretches from the inception of the UFC in 1993 to present day. We used this in combination with the larger and more detailed Kaggle dataset, which contained 4558 observations and 137 columns. The Kaggle dataset has a variety of data for each fight and for each fighter ranging from 2010 to present, allowing for a large variety of data analysis. The variables in this dataset ranged from player's info such as their wins, losses, and so on, as well as fight specific details such as average significant strikes, average submission attemps, and average takedown attempts. 

# Data Processing 
Data Scraping:
To construct the Wikipedia dataset, we used the `rvest` package in R to extract the "Past events" title of the page linked above. Canceled events were removed. Additionally, we cleaned the dataset to ensure that merged cells were properly filled out.

Data Preprocessing: Some modification is used to make the dataset tidier - we transformed 21 weight class rank columns into two columns: weight class and rank. Once the data is adjusted, we removed the columns with zero variance and highly correlated variables with the threshold of 0.8 to avoid multicollinearity. Then we split the data into 80% of training and 20% of the validation set. 

# Analysis and Code 
Our analysis was split between data visualizations and machine learning models.

### Visualizations
We looked at various aspects of the UFC, including the UFC's growth in the past years, specific fighters' data, and general UFC wide trends. Considering that the UFC is divided into weight classes, we decided to look at how fights vary between weight classes. We also looked at how 

### Machine Learning
Given the large number of variables our dataset contained, we realized that we could create machine learning models to predict the winner of a fight. We used a variety of models, including logistic regression, K-nearest neighbors, random forest, decision trees, support vector machine, and neural network.

# Technologies Used 
R,
Python 

