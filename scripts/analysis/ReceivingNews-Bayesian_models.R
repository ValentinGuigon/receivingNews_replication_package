##### LIBRARIES #####

rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


# requirements: 
# 1. JAGS installed on the computer
# 2. The version of JAGS is on par with the version of R

list.of.packages <- c("coda", "rjags", "R2jags", "runjags", "dplyr",
                      "rprojroot") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### VARIABLES #####

set.seed(12345)

project_root = find_rstudio_root_file()

# get data
dRec <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))

# transform data
source(paste(project_root,"/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))
dRec = rename_variables(dRec)
dRec = mutate_values(dRec)

# create directory to save the model textfiles
setwd(paste(project_root, "/scripts/analysis", sep=""))

if (!dir.exists("Bayesian_models_textfiles")){
  dir.create("Bayesian_models_textfiles")
}else{
  print("dir exists")
}

setwd(paste(project_root, "/scripts/analysis/Bayesian_models_textfiles", sep=""))


# initiate lists

# lists for the number of subjects in 2020 and 2021
list_years = list(numeric(max(dRec$Subject[dRec$Year == 2020])), 
                  numeric(max(dRec$Subject[dRec$Year == 2021]) - max(dRec$Subject[dRec$Year == 2020])))

# lists for the id of subjects: dependent on the Year: subjects 1 to 79 were Year==2020
id_years = list(dRec$Subject[dRec$Year==2020][seq(1,length(dRec$Subject[dRec$Year==2020]),48)], 
                dRec$Subject[dRec$Year==2021][seq(1,length(dRec$Subject[dRec$Year==2021]),48)])


# lists for the number of subjects in group1 and group2
list_groups = list(numeric(length(dRec$Subject[dRec$Group == 1])/48), 
                   numeric(length(dRec$Subject[dRec$Group == 2])/48))

# gives the id of subjects in group1 and group2
id_groups = list(dRec$Subject[dRec$Group==1][seq(1,length(dRec$Subject[dRec$Group==1]),48)], 
                 dRec$Subject[dRec$Group==2][seq(1,length(dRec$Subject[dRec$Group==2]),48)])


# empty list of 258 subjects
list_subjects = numeric(length(dRec$Subject)/48)

# years of the two waves
years = c("2020", "2021")






# Source the Bayesian models
source(paste(project_root,"/scripts/src/models/Bayesian_beta_binomial_1way_model.R", sep=""))
source(paste(project_root,"/scripts/src/models/Bayesian_normal_1way_model.R", sep=""))
source(paste(project_root,"/scripts/src/models/Bayesian_normal_2way_model.R", sep=""))


## MCMC settings for the Bayesian models

nchains <- 5 # number of chains
niter <- 10000 # number of iterations
nburn <- 2000 # number of iterations to discard (the burn-in-period)
nthin <- 5 # every nthin iterations, 1 iteration is saved










##### A. Model for probability of Success between waves ####

success_years = list_years

# empty lists to fill, corresponding to the years of each wave
for (i in 1:length(id_years)) {
  for (sub in 1:length(id_years[[i]])) {
    success_years[[i]][sub] = sum(dRec$Success[dRec$Subject == id_years[[i]][sub] & dRec$Year == years[i]])
  }
}

# modelling participants behavior with beta binomial models and non informative priors
out_success_year = Bayesian_beta_binomial_1way(list1=success_years[[1]], # year 2020
                                               list2=success_years[[2]], # year 2021
                                               textfile="jags_successProba_years.txt", 
                                               max.score1=rep(48, length(success_years[[1]])), # year 2020
                                               max.score2=rep(48, length(success_years[[2]])), # year 2021
                                               nchains, niter, nburn, nthin,
                                               prior_alpha=0.5, 
                                               prior_beta=0.5)




##### B. Model for probability of Success between groups #####

success_groups = list_groups

# empty lists to fill, corresponding to the years of each group
for (i in 1:length(id_groups)) {
  for (sub in 1:length(id_groups[[i]])) {
    success_groups[[i]][sub] = sum(dRec$Success[dRec$Subject == id_groups[[i]][sub] ])
  }
}

out_success_group = Bayesian_beta_binomial_1way(list1=success_groups[[1]], # group 1
                                                list2=success_groups[[2]], # group 2
                                                textfile="jags_successProba_groups.txt", 
                                                max.score1=rep(48, length(success_groups[[1]])), # group 1
                                                max.score2=rep(48, length(success_groups[[2]])), # group 2
                                                nchains, niter, nburn, nthin,
                                                prior_alpha=0.5, 
                                                prior_beta=0.5)





##### C. Model for probability of Reception between waves #####

reception_years = list_years

for (i in 1:length(id_years)) {
  for (sub in 1:length(id_years[[i]])) {
    reception_years[[i]][sub] = sum(dRec$Reception[dRec$Subject == id_years[[i]][sub] & dRec$Year == years[i]])
  }
}

out_rec_year = Bayesian_beta_binomial_1way(list1=reception_years[[1]], # year 2020
                                          list2=reception_years[[2]], # year 2021
                                           textfile="jags_recProba_years.txt", 
                                           max.score1=rep(48, length(reception_years[[1]])), # year 2020
                                           max.score2=rep(48, length(reception_years[[2]])), # year 2021
                                           nchains, niter, nburn, nthin,
                                           prior_alpha=0.5, 
                                           prior_beta=0.5)





##### D. Model for probability of Reception between groups #####

reception_groups = list_groups

for (i in 1:length(id_groups)) {
  for (sub in 1:length(id_groups[[i]])) {
    reception_groups[[i]][sub] = sum(dRec$Reception[dRec$Subject == id_groups[[i]][sub] ])
  }
}

out_rec_group = Bayesian_beta_binomial_1way(list1=reception_groups[[1]], # group 1
                                            list2=reception_groups[[2]], # group 2
                                            textfile="jags_recProba_groups.txt", 
                                            max.score1=rep(48, length(reception_groups[[1]])), # group 1
                                            max.score2=rep(48, length(reception_groups[[2]])), # group 2
                                            nchains, niter, nburn, nthin,
                                            prior_alpha=0.5, 
                                            prior_beta=0.5)





##### E. Model for probability of Reception between true and false news (not used in paper) #####

reception_veracity = list(list_subjects, list_subjects)

# filling the lists with the score (i.e., Reception) of each Subject for true news and false news
# Veracity == (i - 1) because it is coded from 0 (false) to 1 (true), not from 1 to 2
for (i in 1:length(reception_veracity)) {
  for (sub in 1:length(reception_veracity[[i]])) {
    reception_veracity[[i]][sub] = sum(dRec$Reception[dRec$Subject == sub & dRec$Veracity == (i -1)])
  }
}

# beware: list1 is reception rate for false news; list2 is reception rate for true news
out_rec_veracity = Bayesian_beta_binomial_1way(list1=reception_veracity[[1]], # false news
                                                   list2=reception_veracity[[2]], # true news
                                                   textfile="jags_recProba_veracity.txt", 
                                                   max.score1=rep(48, length(reception_veracity[[1]])), # false news
                                                   max.score2=rep(48, length(reception_veracity[[2]])), # true news
                                                   nchains, niter, nburn, nthin,
                                                   prior_alpha=0.5, 
                                                   prior_beta=0.5)





##### F. Model for probability of Reception between judgments #####

# 2 lists of 258 subjects with empty values for reception choices for the two judgments
reception_judgment = list(list_subjects, list_subjects)

# 2 lists of 258 subjects with empty values for the two judgments
max_judgment = list(list_subjects, list_subjects)


# filling the lists with each subject's reception rate for judgments as true and as false
# Judgment == (i - 1) because it is coded from 0 (false) to 1 (true), not from 1 to 2
for (i in 1:length(reception_judgment)) {
  for (sub in 1:length(reception_judgment[[i]])) {
    reception_judgment[[i]][sub] = sum(dRec$Reception[dRec$Subject == sub & dRec$Judgment == (i -1)])
  }
}

# filling the lists with each subject's number of judgments as true and judgments as false
for (i in 1:length(max_judgment)) {
  for (sub in 1:length(max_judgment[[i]])) {
  max_judgment[[i]][sub] <- length(dRec$Judgment[dRec$Subject == sub & dRec$Judgment == (i - 1)])
  }
}

# beware: list1 is reception rate for news judged as false; 
# list2 is reception rate for news judged as true
out_rec_judgment = Bayesian_beta_binomial_1way(list1=reception_judgment[[1]], # judged as false
                                               list2=reception_judgment[[2]], # judged as true
                                               textfile="jags_recProba_judgment.txt", 
                                               max.score1=max_judgment[[1]], # judged as false
                                               max.score2=max_judgment[[2]], # judged as true
                                               nchains, niter, nburn, nthin,
                                               prior_alpha=0.5, 
                                               prior_beta=0.5)





##### G. Model for probability of Willingness-To-Pay between waves #####

WTP_years = list_years

for (i in 1:length(id_years)) {
  for (sub in 1:length(id_years[[i]])) {
    WTP_years[[i]][sub] = mean(dRec$WTP[dRec$Subject == id_years[[i]][sub] & dRec$Year == years[i]])
  }
}

out_WTP_year = Bayesian_normal_1way(list1=WTP_years[[1]], # year 2020
                                    list2=WTP_years[[2]], # year 2021
                                    textfile="jags_WTP_year.txt", 
                                    nchains, niter, nburn, nthin,
                                    mu_prior_min=0, 
                                    mu_prior_max=10,
                                    scale=1)





##### H. Model for Willingness-To-Pay between groups #####

WTP_groups = list_groups

for (i in 1:length(id_groups)) {
  for (sub in 1:length(id_groups[[i]])) {
    WTP_groups[[i]][sub] = mean(dRec$WTP[dRec$Subject == id_groups[[i]][sub] ])
  }
}

out_WTP_group = Bayesian_normal_1way(list1=WTP_groups[[1]], # group 1
                                     list2=WTP_groups[[2]], # group 2
                                     textfile="jags_WTP_group.txt", 
                                     nchains, niter, nburn, nthin,
                                     mu_prior_min=0, 
                                     mu_prior_max=10,
                                     scale=1)





##### I. Model for probability of Willingness-To-Pay between Reception choices #####

# create an empty list to store the id of subjects that made reception choices
id_reception = list(numeric, numeric)

# we use dyplr pipes to find the id of subjects that made choices to receive==value
for (i in 1:2){
  id_reception[[i]] = dRec %>% filter(Reception==(i - 1)) %>% distinct(Subject)
  id_reception[[i]] = id_reception[[i]][,] # transpose the vector
}

WTP_reception = list(numeric(length(id_reception[[1]])), numeric(length(id_reception[[2]])))

# Reception == (i - 1) because it is coded from 0 (false) to 1 (true), not from 1 to 2
for (i in 1:length(WTP_reception)) {
  for (sub in 1:length(WTP_reception[[i]])) {
    WTP_reception[[i]][sub] = mean(dRec$WTP[dRec$Subject == id_reception[[i]][sub] & dRec$Reception == (i -1)])
  }
}

out_WTP_rec = Bayesian_normal_1way(list1=WTP_reception[[1]], # choice not to receive
                                   list2=WTP_reception[[2]], # choice to receive
                                   textfile="jags_WTP_rec.txt", 
                                   nchains, niter, nburn, nthin,
                                   mu_prior_min=0, 
                                   mu_prior_max=10,
                                   scale=1)





##### J. Model for Willingness-To-Pay between sessions for the two Reception choices #####

# create an empty list to store the id of subjects that made reception choices
id_reception_2way = list(list(numeric, numeric), list(numeric, numeric))

# we use dyplr pipes to find the id of subjects that made choices to receive==value
# then we transpose the vector
for (i in 1:2){
  for (j in 1:2){
    id_reception_2way[[i]][[j]] = dRec %>% filter(Reception==(j - 1)) %>% filter(Year== years[i]) %>% distinct(Subject)
    id_reception_2way[[i]][[j]] = id_reception_2way[[i]][[j]][,] 
  }
}

# we create list that have the length of subjects that made choices to receive==value, for the two waves
WTP_reception_years = list(
  list(numeric(length(id_reception_2way[[1]] [[1]])), numeric(length(id_reception_2way[[1]] [[2]]))),
  list(numeric(length(id_reception_2way[[2]] [[1]])), numeric(length(id_reception_2way[[2]] [[2]]))))

# Reception == (i - 1) because it is coded from 0 (false) to 1 (true), not from 1 to 2
for (i in 1:length(WTP_reception_years)) { # i handles years
  for (j in 1:length(WTP_reception_years[[i]])) { # j handles reception
    for (sub in 1:length(WTP_reception_years[[i]][[j]])) { # sub handles subjects
      WTP_reception_years[[i]][[j]][sub] = mean(dRec$WTP[dRec$Year  == years[i]
                                                         & dRec$Reception == (j -1) 
                                                & dRec$Subject == id_reception_2way[[i]][[j]][sub] ])
    }
  }
}

out_WTP_rec_years = Bayesian_normal_2way(list1=WTP_reception_years[[1]][[1]], # year 2020 no reception
                                         list2=WTP_reception_years[[1]][[2]], # year 2020 reception
                                         list3=WTP_reception_years[[2]][[1]], # year 2021 no reception
                                         list4=WTP_reception_years[[2]][[2]], # year 2021 reception
                                         textfile="jags_WTP_rec_years.txt", 
                                         nchains, niter, nburn, nthin,
                                         mu_prior_min=0, 
                                         mu_prior_max=10,
                                         scale=1)





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Bayesian_models_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
