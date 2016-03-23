# 1. Function for simulating data
simulatorS4 <- function(object){
  Site <- rep(object@site, object@patients)
  Id = paste0(object@site, "/", object@period, "/", 1:object@patients)
  Dates = as.Date(object@dates, format = "%d-%m-%Y")
  CollectionCycle = rep(paste0(Dates[1], "_", Dates[2]), object@patients)
  Round = rep(object@period, object@patients)
  nExposed = object@patients * object@exposed/100
  response = c("Yes", "No")
  Exposed = sample(response, object@patients, replace = TRUE, prob = c(object@exposed/100, 1 - object@exposed/100))
  nPrevalence = round(object@patients * object@prevalence/100)
  nNewCases = round(nPrevalence * object@incidence/100)
  newCases = sample(which(Exposed == "Yes"), nNewCases)
  Incidences = ifelse(1:object@patients%in%newCases, "Yes", "No")
  allCases = c(newCases, sample(which(Exposed == "No"), nPrevalence - nNewCases)) 
  Prevalence = ifelse(1:object@patients%in%allCases, "Yes", "No")
  nDead = round(nPrevalence * object@mortality/100)
  indDead = sample(allCases, nDead)
  Status =  ifelse(1:object@patients%in%indDead, "Dead", "Alive")
  Costs = round(rnorm(object@patients, mean = object@cost, sd = 2), 2)
  return(data.frame(Site = Site, ID = Id, Dates = CollectionCycle, Round = Round, Exposed = Exposed, Incidences = Incidences, Prevalence = Prevalence, Status = Status, MedicalCosts = Costs))
}

# 2. Function to do the analysis 
EpidemiologistS4 <- function(object){
  if(class(object) == "list"){
    epidata <- object[[1]]
    metaData <- object[[2]]  
  } else {
    epidata <- object
  }
  rows <- nrow(epidata@data)
  ## Computing Exposure Indicators ###################################
  # Total Number of exposed
  totalExp = length(which(epidata@data$Exposed == "Yes"))
  # Proportion of the exposed to patients seen
  propTotExposure = totalExp/rows
  # Total Number of unexposed
  totalUnExp = length(which(epidata@data$Exposed == "No"))
  # Proportion of unexposed to total patients
  propTotUnExposure = totalUnExp/rows
  ## Computing Incidence Indicators ################################
  # Total Number of New cases
  totNew = length(which(epidata@data$Incidences == "Yes"))
  # Proportion of new cases to total exposure
  propNewExp = totNew/totalExp
  # Incidence Rate (Absolute Risk):
  uninfectedExposed = totalExp - totNew
  incidenceRateExposed = totNew/(totNew + uninfectedExposed)
  unexposedInfected = length(which(epidata@data$Exposed == "No" & epidata@data$Prevalence == "Yes")) 
  unexposedUnInfected = length(which(epidata@data$Exposed == "No" & epidata@data$Prevalence == "No"))
  incidenceRateUnExposed = unexposedInfected/(unexposedInfected + unexposedUnInfected)
  ## Computing Prevalence Indicators #####################################
  # Total cases (new and previous)
  totCases = length(which(epidata@data$Prevalence == "Yes"))
  #  Prevalence rate - is it feasible? What are the inputs?
  periodPrevalence = totCases/rows
  ## Computing Mortality Indicators #####################################
  # Total Number of dead patients due to disease
  totMortality = length(which(epidata@data$Status == "Dead"))
  # Proportion of new cases that died
  propNewDead = length(which(epidata@data$Status == "Dead" & epidata@data$Incidences == "Yes"))/totMortality
  # Proportion of all cases that died
  propCaseDead = length(which(epidata@data$Status == "Dead" & epidata@data$Prevalence == "Yes"))/totMortality
  ## Computing Disease Burden ########################################
  # Total medical costs from the disease
  caseCosts = epidata@data[epidata@data$Prevalence == "Yes", "MedicalCosts"] 
  totCosts = sum(caseCosts)
  # Average medical cost to the facility due to the disease
  averageCosts = median(caseCosts, na.rm = TRUE)
  
  ##################  OUtput  ##############################################
  list(NumberOfPatients = rows,
       TotalExposed = totalExp,
       ProportionTotExposed = propTotExposure,
       TotalUnExposed = totalUnExp,
       ProportionTotUnExposed = propTotUnExposure,
       TotalNewCases = totNew,
       ProportionNewCasesExposed = propNewExp,
       UninfectedExposed = uninfectedExposed, 
       IncidenceRateExposed = incidenceRateExposed, 
       UnexposedInfected = unexposedInfected, 
       UnexposedUnInfected = unexposedUnInfected,
       IncidenceRateUnExposed = incidenceRateUnExposed,
       TotalCases = totCases, 
       PeriodPrevalence = periodPrevalence,
       TotalMortality = totMortality,
       ProportionIncidenceDead = propNewDead, 
       ProportioCaseDead = propCaseDead,
       TotalCosts = totCosts,
       AverageCosts = averageCosts)
}

# 3. Function to produce summary report
summaryReportS4 <- function(object){
  results <- object[[1]]
  metaData <- object[[2]]
  # Diverting output to file 
  sink(paste0("SummaryReport.", Sys.Date(), ".Rmd"))
  #######################   Print findings #########################
  cat("Summary Report  for", metaData@siteName, "(ID:", metaData@siteId, ")\n")
  cat("===============================================\n")
  cat(" \n")
  # Adding metadata from inherited `epiSystem` class
  if(metaData@reportingCycle > 0 & metaData@reportingCycle <= 3){
    num <-paste0(1:3, c("st", "nd", "rd"))
    numWord <- num[metaData@reportingCycle]
  } else{
    numWord <- paste0(metaData@reportingCycle, "th")
  }
  
  cat("This summary report covers", metaData@population, "for the", numWord, "reporting cycle.\n")
  cat(" \n")
  reportDate <- as.character(Sys.Date())
  cat("Generated by:", metaData@name, "on", reportDate, "\n") 
  cat(" \n")
  
  cat("Disease Exposure\n")
  cat("-----------------\n")
  cat(paste("Total number of patients exposed to the disease was", results$TotalExposed, paste0("(", round(results$ProportionTotExposed*100, 2), "%),"), "the unexposed were", results$TotalUnExposed, paste0("(", round(results$ProportionTotUnExposed*100, 2), "%).\n")))
  cat(" \n")
  
  cat("Incidence\n")
  cat("----------\n")
  cat(paste("There were", results$TotalNewCases, "new cases which accounted for about", paste0(round(results$ProportionNewCasesExposed*100), "%"), "of the total disease exposure for this period. Those exposed and did not have the disease were", paste0(results$UninfectedExposed, "."), "Incidence expressed as a proportion of the exposed was about", paste0(round(results$IncidenceRateExposed, 2), ".\n")))
  cat(" \n")
  
  cat("Prevalence\n")
  cat("----------\n")
  cat(paste("From the unxeposed patients,", results$UnexposedInfected, "had the disease (preexisting cases) and", results$UnexposedUnInfected, "did not have the disease. Period prevalence computed as the total number of cases", paste0("(", results$TotalCases, ")"), "over the total number of patients seen", paste0("(", results$NumberOfPatients, "),"), "was", paste0(round(results$PeriodPrevalence, 2)*100, "%.\n")))
  cat(" \n")
  
  cat("Mortality\n")
  cat("----------\n")
  cat(paste("Total deaths in the facility for this period was", paste0(results$TotalMortality, " patients. This accounted for ", paste0(round(results$ProportionIncidenceDead, 2)*100, "%"), " of all the patients seen. From the new cases, the proportion dead was ", paste0(round(results$ProportioCaseDead, 2), ".\n"))))
  cat(" \n") 
  
  cat("Disease Burden\n")
  cat("---------------\n")
  cat(paste("During this period,", paste0("$", results$TotalCosts), "was incured by the facility in terms of medical cost; an average of", paste0("$", round(results$AverageCosts, 2)), "per patient.\n"))
  cat("\n")
  ## Closing diversion and previewing file  
  sink(file = NULL)
  file.show(paste0("SummaryReport.", Sys.Date(), ".Rmd"))
  ## Showing Results system calls
  return(results)
} 