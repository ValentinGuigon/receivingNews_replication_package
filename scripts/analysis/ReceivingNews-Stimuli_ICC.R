##### LIBRARIES #####

rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


list.of.packages <- c("R.matlab", "psych",
                      "rprojroot") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}




##### VARIABLES #####

set.seed(12345)

project_root = find_rstudio_root_file()
list.import.mat <- R.matlab::readMat("./data/processed/ReceivingNews_IRR.mat") 
stimuli_dimensions <- read.csv(paste(project_root,"/data/processed/ICC.csv", sep=""))



##### Dimensions #####

ranksum_imprec_per_truth = wilcox.test(stimuli_dimensions$imprecision[stimuli_dimensions$veracity=='0'],
            stimuli_dimensions$imprecision[stimuli_dimensions$veracity=='1'], paired=FALSE, mu=0)

ranksum_polar_per_truth = wilcox.test(stimuli_dimensions$imprecision[stimuli_dimensions$veracity=='0'],
                                       stimuli_dimensions$imprecision[stimuli_dimensions$veracity=='1'], paired=FALSE, mu=0)




##### Intra Class Correlations #####

# ICC for ambiguity
ICC_imprecision = ICC(list.import.mat$IRR.ambig)

# ICC for split (i.d., inverse of consensuality)
ICC_split = ICC(list.import.mat$IRR.split)

# ICC consensuality
ICC_consensuality = ICC(10 - list.import.mat$IRR.split)

# ICC for desirability
ICC_desirability = ICC(list.import.mat$IRR.desir)


##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Stimuli_ICC_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
