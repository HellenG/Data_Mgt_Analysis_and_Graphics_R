source("Scripts/epiProgramOOP_S3.R")
simulatorRC <- function(object){
  if(length(object$data) == 2){
    simulatorS3(object$data[[1]])
  } else {
    simulatorS3(object$data)
  }
}

epidemiologistRC <- function(object){
  if(class(object) == "data.frame"){
    epidemiologistS3(object)
  } else if(length(object$data) == 2){
    epidemiologistS3(object$data[[1]])
  }  else {
    epidemiologistS3(object$data)
  }
}

summaryReportRC <- function(object){
  summaryReportS3(object)
}
