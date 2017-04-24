score2 <- c(60,65,72,78,82)
gender2<- c('m','f','m','f','f')

typ <- c(NA_character_, NA_character_)

for(i in 1:length(InsectSprays)) {
   cat(i, "\n")
   typ[i] <- is.factor(InsectSprays[, i])
}

is.factor(InsectSprays$spray)

sapply(InsectSprays, is.factor)

# This is a comment

dataframe <- data.frame(score2, gender2)

View(dataframe)

# Subsetting

dataframe$gender2


dataframe[,2]

dataframe[, "gender2"]

dataframe$score2[1]

dataframe[1, 1]

dataframe[, "gender2"]


# Lists

lst <- list(score2, gender2, dataframe)

lst[1]

class(lst[1])

mean(lst[1])

lst[[1]]

class(lst[[1]])

mean(lst[[1]])


# Data Importation

tips1 <- read.csv("Data/tips.csv")
tips2 <- read.delim("Data/tips.txt") 
#View(tips2)

#help(package = "foreign")

#search()

library(foreign)

#search()

#?read.spss

#som <- read.spss("Data/KAPS_Somalia.sav", to.data.frame = TRUE)
#View(som)














