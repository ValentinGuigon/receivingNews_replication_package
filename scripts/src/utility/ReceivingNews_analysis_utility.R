
# Functions to clean the data that I frequently use as big chunks of processes

rename_variables = function(data){
  list.of.packages <- c("dplyr","stringr") 
  {
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
  }

  # first letter becomes capitalized
  data = data %>% rename_with(str_to_title)
  
  # rename variables
  names(data)[names(data) == "Eval"] <- "Confidence"
  names(data)[names(data) == "Eval_rt"] <- "Estimation_RT"
  names(data)[names(data) == "Ambiguity"] <- "Imprecision"
  names(data)[names(data) == "Split"] <- "Polarization"
  # names(data)[names(data) == "Veracity"] <- "Truthfulness"
  names(data)[names(data) == "Rec"] <- "Reception"
  names(data)[names(data) == "Ec"] <- "Epistemic_curiosity"
  names(data)[names(data) == "Estimation_rt"] <- "Estimation_RT"
  names(data)[names(data) == "Rec_rt"] <- "Reception_RT"
  names(data)[names(data) == "Wtp"] <- "WTP"
  names(data)[names(data) == "Wtp_rt"] <- "WTP_RT"
  names(data)[names(data) == "Wwf"] <- "WWF"
  names(data)[names(data) == "Nipcc"] <- "NIPCC"
  names(data)[names(data) == "Fondation_robert_schuman"] <- "Fondation_Robert_Schuman"
  
  detach("package:stringr", unload=TRUE)
  
  return(data)
}


check_nan_strings = function(data){
  # calculate the number of values with string 'NaN' and give the location in columns
  nan_str_count = 0
  for (i in 1:ncol(data)){
    if (sum(data[,i] == 'NaN') > 0){
      print(paste("For the variable: ", colnames(data[i]), ", the number of strings 'NaN' is: ", sum(data[,i] == 'NaN')))
      nan_str_count = nan_str_count+1
    }
  }
  print("The function returns a variable 'nan_str_count', input it to 'correct_nan_strings(data, nan_str_count)'")
  
  return(nan_str_count)
}
 

correct_nan_strings = function(data, nan_str_count){
  # replace values with string 'NaN' to actual value NA
  if (nan_str_count >0){
    data <- replace(data, data=='NaN', NA)
  }
  
  return(data)
}


mutate_values = function(data){
  
  # mutate values of variables
  data$Estimation_RT = data$Estimation_RT/1000
  data$Reception_RT = data$Reception_RT/1000
  data$WTP_RT = data$WTP_RT/1000
  data$Year[data$Year == 1] = 2020
  data$Year[data$Year == 2] = 2021
  data$Confidence = abs(data$Confidence)
  data$Year = cut(data$Year, breaks = 2, labels = c("2020", "2021"))
  data$Theme = cut(data$Theme, breaks = 3, labels = c("Ecology", "Democracy", "Social Justice"))
  data$Education = cut(data$Education, breaks = 4, labels = c("Brevet", "Bac", "Licence", "Master"))
  
  return(data)
  }


mutate_types = function(data){
  list.of.packages <- c("dplyr") 
  {
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)
    lapply(list.of.packages, require, character.only = TRUE)
  }
  
  # mutate types of variables
  data <- data%>% mutate(
    Sex = ifelse(Sex == "2", "Female", "Male"),
    Veracity = ifelse(Veracity == "0", "False", "True"),
    Judgment = ifelse(Judgment == "0", "False", "True"))
  
  # factor is to change type to 'factor', modify the names of levels, order levels, etc.
  data$Theme = factor(data$Theme,levels=unique(data$Theme))
  data$Sex = factor(data$Sex, levels = c("Female", "Male")) # reorder levels
  data$Veracity = factor(data$Veracity, levels = c("True", "False")) # reorders levels, useful for graphs
  
  # as.factor is to simply change type to "factor"
  data$Success = as.factor(data$Success)
  data$Judgment = as.factor(data$Judgment)
  data$Reception = as.factor(data$Reception)
  data$Idnews = as.factor(data$Idnews)
  data$Sex = as.factor(data$Sex)
  data$Education = as.factor(data$Education)
  data$Group = as.factor(data$Group)
  data$Year = as.factor(data$Year)
  
  #data$Judgment = factor(data$Judgment, levels = c("True", "False")) # causes weird behaviors
  #data$OrgaBest = as.numeric(data$OrgaBest) # not implemented anymore
  
  return(data)
}


rescale_variables = function(data){
  # rescale continuous variables
  data$Age <- scale(data$Age)
  #data$Imprecision <- scale(data$Imprecision)
  #data$Polarization <- scale(data$Polarization)
  data$Epistemic_curiosity <- scale(data$Epistemic_curiosity)
  data$Confidence <- scale(data$Confidence)
  
  data$Estimation_RT = scale(data$Estimation_RT)
  data$Reception_RT = scale(data$Reception_RT)
  return(data)
}


make_theme_tables = function(data){
  ecology = data[data$Theme == 'Ecology', ]
  names(ecology)[names(ecology) == "Success"] <- "Ecology_success"
  democracy = data[data$Theme == 'Democracy', ]
  names(democracy)[names(democracy) == "Success"] <- "Democracy_success"
  socjust = data[data$Theme == 'SocJust', ]
  names(socjust)[names(socjust) == "Success"] <- "SocJust_success" 
  
  return(ecology,democracy,socjust)
}


make_year2_tables = function(data){
  dRecYear2 = data[data$Year == 2021, ]
  names(dRecYear2)[names(dRecYear2) == "Prcnt_politique"] <- "Distrust_politics"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_journaliste"] <- "Distrust_journalists"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_medecin"] <- "Distrust_physicians"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_acteurjustsoc"] <- "Distrust_socjust_activists"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_chercheur"] <- "Distrust_researchers"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_acteurecologie"] <- "Distrust_environmental_activists"
  names(dRecYear2)[names(dRecYear2) == "Prcnt_general"] <- "Distrust_general"
  
  ecologyYear2 = dRecYear2[dRecYear2$Theme == 'Ecology', ]
  democracyYear2 = dRecYear2[dRecYear2$Theme == 'Democracy', ]
  socjustYear2 = dRecYear2[dRecYear2$Theme == 'SocJust', ] 
  
  return(dRecYear2,ecologyYear2,democracyYear2,socjustYear2)
}


extractorRData <- function(file, object) {
  #' Function for extracting an object from a .RData file created by R's save() command
  #' Inputs: RData file, object name
  E <- new.env()
  load(file=file, envir=E)
  return(get(object, envir=E, inherits=F))
}

