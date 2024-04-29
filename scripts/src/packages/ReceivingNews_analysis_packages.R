##### VARIABLES #####

# Free memory
rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage





##### ReceivingNews2-Power_simulation #####

list.of.packages=c('lme4', 'magrittr', 'dplyr')

{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNewss_ICC #####


list.of.packages <- c("R.matlab", "psych") 

{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNews-Behavioral_measures #####

list.of.packages <- c("MKinfer", "ggplot2", "plyr", "BayesFactor", "bayestestR") 

{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNews-Bayesian_models #####

list.of.packages <- c("coda", "rjags", "R2jags", "runjags", "dplyr") 

{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNews-Mixed_Linear_Models_main #####

list.of.packages <- c("lme4", "ggplot2", "sjPlot", "emmeans", "interactions", "jtools", "ggpubr", "mediation", "RColorBrewer") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNews-Mixed_Linear_Models_alternatives #####

list.of.packages <- c("lme4", "ggplot2", "sjPlot", "emmeans", "interactions", "jtools", "ggpubr", "mediation", "RColorBrewer",) 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### ReceivingNews-Bayesian_Mixed_Linear_Models #####

## If not installed, uncomment and run the following commands to avoid compilation errors:
# remove.packages(c("StanHeaders", "rstan"))
# install.packages("StanHeaders", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies = TRUE)
# verify the installation: example(stan_model, package = "rstan", run.dontrun = TRUE)
# devtools::install_github("rmcelreath/rethinking")
# In case of need: install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

list.of.packages <- c("brms", "rstan", "rjags", "mcmc", "rethinking", "StanHeaders"
                      , "tidyverse", "modelr", "ks", "bayestestR", "logspline"
                      , "tidybayes", "bayesplot", "BEST", "ggplot2", "see", "GGally"
                      , "dplyr") 

{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}

