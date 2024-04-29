##### VARIABLES #####

# Free memory
rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


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
                      , "dplyr", "scales", "pracma"
                      , "rprojroot") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}


# set paths and mk necessary directories
set.seed(12345)
project_root = find_rstudio_root_file()


# read and transform the data
dRec <- read.csv(paste(project_root, "/data/processed/receivingNews_data.csv", sep=""))
source(paste(project_root, "/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))
dRec = rename_variables(dRec)
nan_str_count = check_nan_strings(dRec)
dRec = correct_nan_strings(dRec, nan_str_count)
dRec = mutate_values(dRec)

dRec <- dRec%>% mutate(
  Sex = ifelse(Sex == "2", "Female", "Male"),
  Veracity = ifelse(Veracity == "0", "False", "True"),
  Judgment = ifelse(Judgment == "0", "False", "True"))
dRec$Veracity = factor(dRec$Veracity, levels = c("True", "False")) # reorders levels, useful for graphs
dRec$Judgment = factor(dRec$Judgment, levels = c("True", "False")) # reorders levels, useful for graphs

# data for the Organizations model, with best explaining organizations already implemented
dRec_Organizations = extractorRData(paste(project_root, "/R_environments/ReceivingNews-Mixed_Linear_Models_alternatives_rand2_env.RData", sep=""), "dRec_plus")
dRec_Organizations$Success = as.numeric(dRec_Organizations$Success)
dRec_Organizations$Success = ifelse(dRec_Organizations$Success == 2, 0, 1)





##### Multicollinearity #####
# We handle multicollinearity by orthogonalizing with the Gram-Schmidt algorithm

# But first we mean-center
dRec$Imprecision = scale(dRec$Imprecision, center=TRUE, scale=FALSE)
dRec$Polarization = scale(dRec$Polarization, center=TRUE, scale=FALSE)

# Next we orthogonalize
data_for_orth = as.matrix(dRec[, c("Imprecision", "Polarization")])
data_orth = gramSchmidt(data_for_orth)

Imprecision = (Imprecision=data_orth$Q[,1])
Polarization = (Polarization=data_orth$Q[,2])

dRec$Imprecision = Imprecision
dRec$Polarization = Polarization

# Then we standardize the data
# Standardizing after orthogonalization can bring the variables to a common scale, which can aid in the interpretability of the coefficients
dRec$Imprecision = scale(dRec$Imprecision, center=FALSE, scale=TRUE)
dRec$Polarization = scale(dRec$Polarization, center=FALSE, scale=TRUE)





## Notes: 
# Caution: output models in log-odds -> set function to retransform
# When Bulk Effective Samples Size (ESS) is too low, posterior means and medians may be unreliable.
#     Running the chains for more iterations may help. 
#     See: http://mc-stan.org/misc/warnings.html#bulk-ess 
# Same for tail





########## MODELS OF SUCCESS ##########


##### PRIORS #####

prior_random <- c(
  prior(beta(0.5, 0.5), class = Intercept))

priorSubj <- c(
  prior(normal(0, 1), class = Intercept),
  prior(cauchy(0, 1), class = sd))

priorLM <- c(
  prior(normal(0, 1), class = Intercept),
  prior(normal(0, 1), class = b),
  prior(cauchy(0, 1), class = sd))





##### MODELS #####

mSuccessRandom <- brm(
  Success | trials(1) ~ (1|Subject),
  family = binomial(link = "logit"),
  prior = prior_random,
  sample_prior = "yes", 
  chains = 4,
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessSubject <- brm(
  Success | trials(1) ~ 1 + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorSubj,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessRT <- brm(
  Success | trials(1) ~ 1 + Estimation_RT + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessJudgment <- brm(
  Success | trials(1) ~ 1 + Judgment + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessImprecision <- brm(
  Success | trials(1) ~ 1 + Veracity:Imprecision + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessPolarization <- brm(
  Success | trials(1) ~ 1 + Veracity:Polarization + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

mSuccessImprecPolar <- brm(
  Success | trials(1) ~ 1 + Veracity:Imprecision + Veracity:Polarization + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))

# we use dRec_Organizations
mSuccessOrganization <- brm(
  Success | trials(1) ~ 1 + Theme:orgaBest + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec_Organizations, 
  control = list(adapt_delta = 0.85))





##### Imprecision & Polarization model controlled - to check posterior fixed effects #####

mSuccessImprecPolar_controlled <- brm(
  Success | trials(1) ~ 1 + Veracity*Imprecision + Veracity*Polarization + Confidence + Veracity*Theme + (1|Subject),
  family = binomial(link = "logit"),
  prior = priorLM,
  sample_prior = "yes", 
  iter = 4000,
  warmup = 1500,
  thin = 1,
  data = dRec, 
  control = list(adapt_delta = 0.85))





##### MODELS COMPARISON #####

mSuccessRandom <- add_criterion(mSuccessRandom, "waic")
mSuccessSubject <- add_criterion(mSuccessSubject, "waic")
mSuccessRT <- add_criterion(mSuccessRT, "waic")
mSuccessJudgment <- add_criterion(mSuccessJudgment, "waic")
mSuccessImprecision <- add_criterion(mSuccessImprecision, "waic")
mSuccessPolarization <- add_criterion(mSuccessPolarization, "waic")
mSuccessImprecPolar <- add_criterion(mSuccessImprecPolar, "waic")
mSuccessOrganization <- add_criterion(mSuccessOrganization, "waic")

mSuccessRandom <- add_criterion(mSuccessRandom, "loo")
mSuccessSubject <- add_criterion(mSuccessSubject, "loo")
mSuccessRT <- add_criterion(mSuccessRT, "loo")
mSuccessJudgment <- add_criterion(mSuccessJudgment, "loo")
mSuccessImprecision <- add_criterion(mSuccessImprecision, "loo")
mSuccessPolarization <- add_criterion(mSuccessPolarization, "loo")
mSuccessImprecPolar <- add_criterion(mSuccessImprecPolar, "loo")
mSuccessOrganization <- add_criterion(mSuccessOrganization, "loo")


## Hypothesis testing
# General models
model_comparison_table_Success <- loo_compare(mSuccessRandom, mSuccessSubject, 
                                              mSuccessRT, mSuccessJudgment, 
                                              mSuccessImprecision, mSuccessPolarization,
                                              mSuccessOrganization, mSuccessImprecPolar,
                                              criterion = "waic") %>%
  data.frame %>%
  rownames_to_column(var = "model")

# Akaike weights 
weights_Success <- data.frame(weight = model_weights(mSuccessRandom, mSuccessSubject, 
                                                     mSuccessRT, mSuccessJudgment, 
                                                     mSuccessImprecision, mSuccessPolarization,
                                                     mSuccessOrganization, mSuccessImprecPolar,
                                                     weights = "waic") ) %>%
  round(digits = 3) %>%
  rownames_to_column(var = "model")

# waic
comparison <- model_comparison_table_Success %>% data.frame %>% select(waic) %>% rownames_to_column()
waics <- comparison %>% arrange(rowname) %>% pull(waic)

# Ranking
left_join(model_comparison_table_Success, weights_Success, by = "model")

#Summary of the winner model
summary(mSuccessImprecPolar) # marginal means in odds ratio





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Bayesian_Mixed_Linear_Models_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
