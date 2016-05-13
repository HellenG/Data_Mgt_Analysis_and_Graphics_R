# MNCH Indicators
# Source: http://
owd <- getwd()
setwd("~/Data Mania Inc/Trainings/Indepth Research Services/Results Based Management Training/Workshop Documents/CaseStudyDocuments/2015_MNCH_Indicators")

# Demographics
dem <- read.csv("Demographics.csv")

# Under 5 mortality rate trend
u5m <- read.csv("U5MR.csv")
countrySpecific_U5m <- lapply(1:nrow(u5m), function(i) as.numeric(u5m[i, 2:length(u5m)]))
countries <- u5m[,1]
names(countrySpecific_U5m) <- countries
periodList <- strsplit(names(u5m[2:length(u5m)]), split = "[.]")
years <-  as.numeric(sapply(periodList, function(i) i[2]))
#countrySpecific_U5mNamed <- lapply(countrySpecific_U5m, function(i) names(i) <- years)
countrySpecific_U5mTS <- lapply(countrySpecific_U5m, FUN = ts, start = min(years))
origPar <- par("mfrow")
par(mfrow = c(2, 2))
for(i in 1:length(countrySpecific_U5mTS)){
  plot(countrySpecific_U5mTS[[i]], col = 4, xlab = "Years", ylab = "Mortality Rate", main = paste(as.character(countries[i]), "Under Five Mortality Rate"))
}
par(mfrow = origPar)

# Maternal Mortality Ratio
mmr <- read.csv("MMR trend.csv")
countrySpecific_MMR <- lapply(1:nrow(mmr), function(i) as.numeric(mmr[i, 2:length(mmr)]))
countries <- as.character(mmr[, "Country"])
periodList <- strsplit(names(mmr[2:length(mmr)]), split = "X")
years <-  as.numeric(sapply(periodList, function(i) i[2]))
names(countrySpecific_MMR) <- countries
countrySpecific_MMRTS <- lapply(countrySpecific_MMR, ts, start = min(years))
origPar <- par("mfrow")
par(mfrow = c(2, 2))
for(i in 1:length(countrySpecific_MMRTS)){
  plot(countrySpecific_MMRTS[[i]], col = 4, xlab = "Years", ylab = "Mortality Rate", main = paste(countries[i], "Maternal Mortality Rate"))
}
par(mfrow = origPar)

# Generally, both under five and maternal mortality is on the decline in all the listed countries


# Antenatal care (one or more visits)
ac1 <- read.csv("ANC1.csv")
# Antenatal care (four or more visits)
ac4 <- read.csv("ANC4.csv")
# Skilled attendant birth
sab <- read.csv("Skilled attendant birth.csv")
# Percentage of babies who received postnatal care within two days of childbirth
pncb <- read.csv("PNC baby.csv")
# Percentage of mothers who received postnatal care within two days of childbirth
pncm <- read.csv("PNC mother.csv")
# Women with low body mass index
bmi <- read.csv("BMI.csv")
# Wasting, Stunting and Underweight prevalences
wsu <- read.csv("Anthro trend.csv")


setwd(owd)


# Sat Apr 30 18:47:08 2016 ------------------------------

























