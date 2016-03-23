# Data Simulator 
simulatorS3 <- function(object){
  # Generating the variables
  Site = rep(object$site, object$patients)
  Id = paste0(object$site, "/", object$period, "/", 1:object$patients)
  Dates = as.Date(c(object$dates[1], object$dates[2]), format = "%d-%m-%Y")
  CollectionCycle = rep(paste0(Dates[1], " : ", Dates[2]), object$patients)
  Round = rep(object$period, object$patients)
  nExposed = object$patients * object$exposed/100
  response = c("Yes", "No")
  # Vector with number of exposed patients
  Exposed = sample(response, object$patients, replace = TRUE, prob = c(object$exposed/100, 1 - object$exposed/100))
  # Out of all the patients seen, how many have the disease?
  nPrevalence = round(object$patients * object$prevalence/100)
  # Out of all the patients with the disease how many are new cases?
  nNewCases = round(nPrevalence * object$incidence/100)
  # Out of the exposed, randomly have 18 as new cases  
  newCases = sample(which(Exposed == "Yes"), nNewCases)
  # A vector with "Yes" for indices of newCases and "No" otherwise 
  Incidences = ifelse(1:object$patients%in%newCases, "Yes", "No")
  # A vector for all cases (incidence plus previous patients)
  Incidences = ifelse(1:object$patients%in%newCases, "Yes", "No")
  # A vector for all cases (incidence plus previous patients)
  allCases = c(newCases, sample(which(Exposed == "No"), nPrevalence - nNewCases)) 
  Prevalence = ifelse(1:object$patients%in%allCases, "Yes", "No")
  nDead = round(nPrevalence * object$mortality/100)
  indDead = sample(allCases, nDead)
  Status =  ifelse(1:object$patients%in%indDead, "Dead", "Alive")
  Costs = round(rnorm(object$patients, mean = object$cost, sd = 4), 2)
  data.frame(Site = Site, ID = Id, Dates = CollectionCycle, Round = Round, Exposed = Exposed, Incidences = Incidences, Prevalence = Prevalence, Status = Status, MedicalCosts = Costs)
}

# Validator function
validatorS3 <- function(object){
  # Expected object should be a list with 2 elements 
  if(!is.list(object) | !length(object) == 2){
    stop("Object must be a list with two elements: Data Frame and Meta Data")
  } 
  # Expected variable names (data.frame)
  dfNames = c("Site", "ID", "Dates", "Round", "Exposed", "Incidences", "Prevalence", "Status", "MedicalCosts")
  # Getting objects names (dataset and metadata) 
  objNames = names(object[[1]])
  # Checking for missing variables in the dataframe 
  assess = dfNames%in%objNames
  # Stopping further execution if variables are not found
  if(any(assess == FALSE)){
    unfound <- dfNames[which(assess == FALSE)]
    cat("Columns", unfound, "not found in the data.frame.", sep = ", ")
    stop("Missing variables")
  }
  # Check metadata object is provided for objects proceeding for analysis and/or reporting
  classes <- class(object)
  metaDataObject <- object[[2]]
  if(classes[1] == "epidemiologistS3" | classes[1] == "summaryReportS3"){
    # Expected meta data
    metaData <- c("siteName", "siteId", "population", "name", "reportingCycle")
    namesMetaObj <- names(metaDataObject)
    assess = metaData%in%namesMetaObj
    # Send error for missing metadata
    if(any(assess == FALSE)){
      unfound = metaData[which(assess == FALSE)]
      cat("Include the following metadata:", unfound, sep = ", ")
      cat("\n")
      cat("Then combine the vector with the data.frame\n")
      stop("Missing Meta Data")
    }  
  }
}


# The Analyst
epidemiologistS3 <- function(object){
  epidata <- object # Removes [[1]] for compatibility with RC
  rows = length(epidata$Site)
  ## Computing Exposure Indicators ###################################
  # Total Number of exposed
  totalExp = length(which(epidata$Exposed == "Yes"))
  # Proportion of the exposed to patients seen
  propTotExposure = totalExp/rows
  # Total Number of unexposed
  totalUnExp = length(which(epidata$Exposed == "No"))
  # Proportion of unexposed to total patients
  propTotUnExposure = totalUnExp/rows
  ## Computing Incidence Indicators ################################
  # Total Number of New cases
  totNew = length(which(epidata$Incidences == "Yes"))
  # Proportion of new cases to total exposure
  propNewExp = totNew/totalExp
  # Incidence Rate (Absolute Risk):
  uninfectedExposed = totalExp - totNew
  incidenceRateExposed = totNew/(totNew + uninfectedExposed)
  unexposedInfected = length(which(epidata$Exposed == "No" & epidata$Prevalence == "Yes")) 
  unexposedUnInfected = length(which(epidata$Exposed == "No" & epidata$Prevalence == "No"))
  incidenceRateUnExposed = unexposedInfected/(unexposedInfected + unexposedUnInfected)
  ## Computing Prevalence Indicators #####################################
  # Total cases (new and previous)
  totCases = length(which(epidata$Prevalence == "Yes"))
  #  Prevalence rate - is it feasible? What are the inputs?
  periodPrevalence = totCases/rows
  ## Computing Mortality Indicators #####################################
  # Total Number of dead patients due to disease
  totMortality = length(which(epidata$Status == "Dead"))
  # Proportion of new cases that died
  propNewDead = length(which(epidata$Status == "Dead" & epidata$Incidences == "Yes"))/totMortality
  # Proportion of all cases that died
  propCaseDead = length(which(epidata$Status == "Dead" & epidata$Prevalence == "Yes"))/totMortality
  ## Computing Disease Burden ########################################
  # Total medical costs from the disease
  prevCosts <- data.frame(prevalence = epidata$Prevalence, costs = epidata$MedicalCosts)
  caseCosts = prevCosts[prevCosts$prevalence == "Yes", "costs"]
  totCosts = sum(caseCosts)
  # Average medical cost to the facility due to the disease
  averageCosts = median(caseCosts, na.rm = TRUE)
  ##################  OUtput  ##############################################
  list(NumberofPatients = rows,
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

# Function for generating report
summaryReportS3 <- function(object){
  output <- object[[1]]
  metaData <- object[[2]]
  ## Diverting output to file 
  File <- paste0("SummaryReport.", Sys.Date(), ".Rmd")
  sink(file = File)
  on.exit(sink(file = NULL))
  #######################   Print findings #########################
  cat("Summary Report  for", metaData$siteName, "(ID:", metaData$siteId, ")\n")
  cat("===============================================\n")
  cat(" \n")
  # Adding metadata from inherited `metaData` class
  if(metaData$reportingCycle >= 1 & metaData$reportingCycle <= 3){
    num <-paste0(1:3, c("st", "nd", "rd"))
    numWord <- num[metaData$reportingCycle]
  } else{
    numWord <- paste0(metaData$reportingCycle, "th")
  }
  cat("This summary report covers", metaData$population, "for the", numWord, "reporting cycle.\n")
  cat(" \n")
  reportDate <- as.character(Sys.time())
  cat("Generated by:", metaData$name, "on", reportDate,"\n")
  cat(" \n")
  
  cat("###Disease Exposure\n")
  cat("\n")
  cat(paste("Total number of patients exposed to the disease was", output$TotalExposed, paste0("(", round(output$ProportionTotExposed*100, 1), "%),"), "the unexposed were", output$TotalUnExposed, paste0("(", round(output$ProportionTotUnExposed*100, 1), "%).\n")))
  cat(" \n")
  
  cat("###Incidence\n")
  cat("\n")
  cat(paste("There were", output$TotalNewCases, "new cases which accounted for about", paste0(round(output$ProportionNewCasesExposed*100), "%"), "of the total disease exposure for this period. Those exposed and did not have the disease were", paste0(output$UninfectedExposed, "."), "Incidence expressed as a proportion of the exposed was about", paste0(round(output$IncidenceRateExposed, 2), ".\n")))
  cat(" \n")
  
  cat("###Prevalence\n")
  cat("\n")
  cat(paste("From the unxeposed patients,", output$UnexposedInfected, "had the disease (preexisting cases) and", output$UnexposedUnInfected, "did not have the disease. Period prevalence computed as the total number of cases", paste0("(", output$UnexposedUnInfected, ")"), "over the total number of patients seen", paste0("(", output$NumberofPatients, "),"), "was", paste0(round(output$PeriodPrevalence, 2)*100, "%.\n")))
  cat(" \n")
  
  cat("###Mortality\n")
  cat("\n")
  cat(paste("Total deaths in the facility for this period was", paste0(output$TotalMortality, " patients. This accounted for ", paste0(round(output$ProportionIncidenceDead, 2)*100, "%"), " of all the patients seen. From the new cases, the proportion dead was ", paste0(round(output$ProportioCaseDead, 2), ".\n"))))
  cat(" \n") 
  
  cat("###Disease Burden\n")
  cat("\n")
  cat(paste("During this period,", paste0("$", round(output$TotalCosts, 2)), "was incured by the facility in terms of medical cost; an average of", paste0("$", round(output$AverageCosts, 2)), "per patient.\n"))
  cat("\n")
  cat("\n")
  cat("####Output\n")
  cat("\n")
  print(output)
}
