##### LIBRARIES #####

rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


# requirements: 
# 1. JAGS installed on the computer
# 2. The version of JAGS is on par with the version of R


list.of.packages <- c("tidyverse", "MKinfer", "ggplot2", "plyr", "BayesFactor", "bayestestR",
                      "EnvStats",
                      "rprojroot") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### VARIABLES #####

set.seed(12345)
project_root = find_rstudio_root_file()
source(paste(project_root,"/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))

dRec <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))
dRec = rename_variables(dRec)
dRec = mutate_values(dRec)

dRec_num = dRec
dRec_num$Success = as.numeric(as.character(dRec_num$Success))
dRec_num$Judgment = as.numeric(as.character(dRec_num$Judgment))
dRec_num$Reception = as.numeric(as.character(dRec_num$Reception))

N_TRIALS = 48
N_CONDS = 6
N_THEMES = 3
N_VERACITY = 2


themes = c("Ecology", "Democracy", "Social Justice")
conds_list = rep(list( rep(list(numeric(max(dRec$Subject))), each=N_VERACITY)), each=N_THEMES)

# to use for the cross-tabulation: create lists of repeated variable patterns that match the scores
Veracity = data.frame(rep(c('False', 'True'),times=N_THEMES, each=258))
Theme = data.frame(rep(c('Ecology', 'Ecology', 'Democracy', 'Democracy', 'Social justice', 'Social justice'),each=258))
Veracity_fat = data.frame(rep(c('False', 'True'), times=N_CONDS, each=258))
Theme_fat = data.frame(rep( rep(c('Ecology', 'Democracy', 'Social justice'), each=N_VERACITY), times=2, each=258))
Reception_fat = data.frame(rep( rep(c('No reception', 'Reception'), each=N_CONDS), times=1, each=258))

# Theme_fat is equal to doing:
# Theme_fat2 = data.frame(rep(c('Ecology', 'Ecology', 'Democracy', 'Democracy', 'Social justice', 'Social justice',
#                              'Ecology', 'Ecology', 'Democracy', 'Democracy', 'Social justice', 'Social justice'),each=258))
# sum(Theme_fat == Theme_fat2) == (nrow(Theme_fat) + nrow(Theme_fat2))/2

# Reception_fat is equal to doing:
# Reception_fat2 = data.frame(rep(c('Reception', 'Reception', 'Reception', 'Reception', 'Reception', 'Reception',
#                                   'No reception', 'No reception', 'No reception', 'No reception', 'No reception', 'No reception'),each=258))
# sum(Reception_fat == Reception_fat2) == (nrow(Reception_fat) + nrow(Reception_fat2))/2






##### SUCCESS ANALYSES #####

# Compute mean and standard error for each combination of Theme
theme_proportion_success <- dRec_num %>%
  dplyr::group_by(Theme, Subject) %>%
  dplyr::summarize(theme_proportion_success = (sum(Success == 1) / n() *100))

theme_proportion_success_summary <- theme_proportion_success %>%
  dplyr::group_by(Theme) %>%
  dplyr::summarize(Mean_Success = mean(theme_proportion_success),
            Standard_Deviation = sd(theme_proportion_success))


# Compute mean and standard error for each combination of Veracity
veracity_proportion_success <- dRec_num %>%
  dplyr::group_by(Veracity, Subject) %>%
  dplyr::summarize(veracity_proportion_success = (sum(Success == 1) / n() *100))

veracity_proportion_success_summary <- veracity_proportion_success %>%
  dplyr::group_by(Veracity) %>%
  dplyr::summarize(Mean_Success = mean(veracity_proportion_success),
            Standard_Deviation = sd(veracity_proportion_success))


# Scores for Success: Cross tabulation

success = conds_list

for (i in 1:length(success)) {
  for (j in 1:length(success[[i]])) {
    for (subj in 1:length(success[[i]][[j]])) {
      success[[i]][[j]][subj] = sum(dRec$Success[dRec$Subject == subj & 
                                                   dRec$Veracity == (j - 1) & 
                                                   dRec$Theme == themes[i]]) / (N_TRIALS/N_CONDS)
    }
  }
}

success.df = data.frame(unlist(success))
success.df[is.na(success.df)] <- 0
success.df = cbind(success.df,Theme,Veracity)
colnames(success.df) = c('Success','Theme','Veracity')

xtab1 = ddply(success.df, .(Theme,Veracity), summarise, mean = mean(Success), sd = sd(Success))
xtab1$mean = round(xtab1$mean*100, digits=2)
xtab1$sd = round(xtab1$sd*100, digits=2)





##### JUDGMENT ANALYSES #####

# Compute mean and standard error for each combination of Theme
theme_proportion_judgment <- dRec_num %>%
  dplyr::group_by(Theme, Subject) %>%
  dplyr::summarize(theme_proportion_judgment = (sum(Judgment == 1) / n() * 100))

theme_proportion_judgment_summary <- theme_proportion_judgment %>%
  dplyr::group_by(Theme) %>%
  dplyr::summarize(Mean_Judgment = mean(theme_proportion_judgment),
                   Standard_Deviation = sd(theme_proportion_judgment))


# Compute mean and standard error for each combination of Veracity
veracity_proportion_judgment <- dRec_num %>%
  dplyr::group_by(Veracity, Subject) %>%
  dplyr::summarize(veracity_proportion_judgment = (sum(Judgment == 1) / n() * 100))

veracity_proportion_judgment_summary <- veracity_proportion_judgment %>%
  dplyr::group_by(Veracity) %>%
  dplyr::summarize(Mean_Judgment = mean(veracity_proportion_judgment),
                   Standard_Deviation = sd(veracity_proportion_judgment))


# Scores for Judgment: Cross tabulation

judgment = conds_list

for (i in 1:length(judgment)) {
  for (j in 1:length(judgment[[i]])) {
    for (subj in 1:length(judgment[[i]][[j]])) {
      judgment[[i]][[j]][subj] = sum(dRec$Judgment[dRec$Subject == subj & 
                                                   dRec$Veracity == (j - 1) & 
                                                   dRec$Theme == themes[i]]) / (N_TRIALS/N_CONDS)
    }
  }
}

judgment.df = data.frame(unlist(judgment))
judgment.df[is.na(judgment.df)] <- 0
judgment.df = cbind(judgment.df,Theme,Veracity)
colnames(judgment.df) = c('Judgment','Theme','Veracity')

xtab2 = ddply(judgment.df, .(Theme,Veracity), summarise, mean = mean(Judgment), sd = sd(Judgment))
xtab2$mean = round(xtab2$mean*100, digits=2)
xtab2$sd = round(xtab2$sd*100, digits=2)





##### CONFIDENCE ANALYSES #####

# Compute mean and standard error for each combination of Theme
theme_proportion_confidence <- dRec_num %>%
  dplyr::group_by(Theme, Subject) %>%
  dplyr::summarize(theme_proportion_confidence = mean(Confidence))

theme_proportion_confidence_summary <- theme_proportion_confidence %>%
  dplyr::group_by(Theme) %>%
  dplyr::summarize(Mean_confidence = mean(theme_proportion_confidence),
                   Standard_Deviation = sd(theme_proportion_confidence))


# Compute mean and standard error for each combination of Veracity
veracity_proportion_confidence <- dRec_num %>%
  dplyr::group_by(Veracity, Subject) %>%
  dplyr::summarize(veracity_proportion_confidence = mean(Confidence))

veracity_proportion_confidence_summary <- veracity_proportion_confidence %>%
  dplyr::group_by(Veracity) %>%
  dplyr::summarize(Mean_confidence = mean(veracity_proportion_confidence),
                   Standard_Deviation = sd(veracity_proportion_confidence))


# Scores of Confidence: Cross tabulation

confidence = conds_list

for (i in 1:length(confidence)) {
  for (j in 1:length(confidence[[i]])) {
    for (subj in 1:length(confidence[[i]][[j]])) {
      confidence[[i]][[j]][subj] = mean(dRec$Confidence[dRec$Subject == subj & 
                                                     dRec$Veracity == (j - 1) & 
                                                     dRec$Theme == themes[i]])
    }
  }
}

confidence.df = data.frame(unlist(confidence))
confidence.df[is.na(confidence.df)] <- 0
confidence.df = cbind(confidence.df,Theme,Veracity)
colnames(confidence.df) = c('Confidence','Theme','Veracity')

xtab3 = ddply(confidence.df, .(Theme,Veracity), summarise, mean = mean(Confidence), sd = sd(Confidence))
xtab3$mean = round(xtab3$mean, digits=2)
xtab3$sd = round(xtab3$sd, digits=2)





##### RECEPTION ANALYSES #####

# Compute mean and standard error for each combination of Theme
theme_proportion_reception <- dRec_num %>%
  dplyr::group_by(Theme, Subject) %>%
  dplyr::summarize(theme_proportion_reception = (sum(Reception == 1) / n() * 100))

theme_proportion_reception_summary <- theme_proportion_reception %>%
  dplyr::group_by(Theme) %>%
  dplyr::summarize(Mean_reception = mean(theme_proportion_reception),
                   Standard_Deviation = sd(theme_proportion_reception))


# Compute mean and standard error for each combination of Veracity
veracity_proportion_reception <- dRec_num %>%
  dplyr::group_by(Veracity, Subject) %>%
  dplyr::summarize(veracity_proportion_reception = (sum(Reception == 1) / n() * 100))

veracity_proportion_reception_summary <- veracity_proportion_reception %>%
  dplyr::group_by(Veracity) %>%
  dplyr::summarize(Mean_reception = mean(veracity_proportion_reception),
                   Standard_Deviation = sd(veracity_proportion_reception))


# Scores of Reception: Cross tabulation

reception = conds_list

for (i in 1:length(reception)) {
  for (j in 1:length(reception[[i]])) {
    for (subj in 1:length(reception[[i]][[j]])) {
      reception[[i]][[j]][subj] = sum(dRec$Reception[dRec$Subject == subj & 
                                                     dRec$Veracity == (j - 1) & 
                                                     dRec$Theme == themes[i]]) / (N_TRIALS/N_CONDS)
    }
  }
}

reception.df = data.frame(unlist(reception))
reception.df[is.na(reception.df)] <- 0
reception.df = cbind(reception.df,Theme,Veracity)
colnames(reception.df) = c('Reception','Theme','Veracity')

xtab4 = ddply(reception.df, .(Theme,Veracity), summarise, mean = mean(Reception), sd = sd(Reception))
xtab4$mean = round(xtab4$mean*100, digits=2)
xtab4$sd = round(xtab4$sd*100, digits=2)

xtab4_Veracity = ddply(reception.df, .(Veracity), summarise, mean = mean(Reception), sd = sd(Reception))
xtab4_Veracity$mean = round(xtab4_Veracity$mean*100, digits=2)
xtab4_Veracity$sd = round(xtab4_Veracity$sd*100, digits=2)

xtab4_Theme = ddply(reception.df, .(Theme), summarise, mean = mean(Reception), sd = sd(Reception))
xtab4_Theme$mean = round(xtab4_Theme$mean*100, digits=2)
xtab4_Theme$sd = round(xtab4_Theme$sd*100, digits=2)

reception_curious = list(numeric(max(dRec$Subject)))
for (subj in 1:length(reception_curious[[1]])) {
  reception_curious[[1]][subj] = sum(dRec$Reception[dRec$Subject == subj]) / (N_TRIALS)
}

curiosity = sum(reception_curious[[1]] > 0) / length(reception_curious[[1]])






##### WTP ANALYSES #####

# Compute mean and standard error for each combination of Reception
reception_proportion_WTP <- dRec_num %>%
  dplyr::group_by(Reception, Subject) %>%
  dplyr::summarize(proportion_WTP = mean(WTP))

reception_proportion_WTP_summary <- reception_proportion_WTP %>%
  dplyr::group_by(Reception) %>%
  dplyr::summarize(Mean_WTP = mean(proportion_WTP),
                   Standard_Deviation = sd(proportion_WTP))

# Compute mean and standard error for each combination of Theme
theme_proportion_WTP <- dRec_num %>%
  dplyr::group_by(Theme, Reception, Subject) %>%
  dplyr::summarize(theme_proportion_WTP = mean(WTP))

theme_proportion_WTP_summary <- theme_proportion_WTP %>%
  dplyr::group_by(Theme, Reception) %>%
  dplyr::summarize(Mean_WTP = mean(theme_proportion_WTP),
                   Standard_Deviation = sd(theme_proportion_WTP))


# Compute mean and standard error for each combination of Veracity
veracity_proportion_WTP <- dRec_num %>%
  dplyr::group_by(Veracity, Reception, Subject) %>%
  dplyr::summarize(veracity_proportion_WTP = mean(WTP))

veracity_proportion_WTP_summary <- veracity_proportion_WTP %>%
  dplyr::group_by(Veracity, Reception) %>%
  dplyr::summarize(Mean_WTP = mean(veracity_proportion_WTP),
                   Standard_Deviation = sd(veracity_proportion_WTP))


# Scores of WTP: Cross tabulation

WTP = list(conds_list, conds_list)

for (rec_choice in 1:length(WTP)){
  for (i in 1:length(WTP[[rec_choice]])) {
    for (j in 1:length(WTP[[rec_choice]] [[i]])) {
      for (subj in 1:length(WTP[[rec_choice]] [[i]][[j]])) {
        WTP[[rec_choice]] [[i]][[j]][subj] = mean(dRec$WTP[dRec$Subject == subj & 
                                                             dRec$Veracity == (j - 1) & 
                                                             dRec$Theme == themes[i] & 
                                                             dRec$Reception == (rec_choice - 1) ])}
    }
  }
}

WTP.df = data.frame(unlist(WTP))
WTP.df = cbind(WTP.df,Theme_fat, Veracity_fat, Reception_fat)
colnames(WTP.df) = c('WTP', 'Theme', 'Veracity', 'Reception')

xtab5 = ddply(WTP.df, .(Reception,Theme,Veracity), summarise, mean = mean(WTP,na.rm=TRUE), sd = sd(WTP,na.rm=TRUE))
xtab5$mean = round(xtab5$mean, digits=2)
xtab5$sd = round(xtab5$sd, digits=2)

xtab5_Reception = ddply(WTP.df, .(Reception), summarise, mean = mean(WTP,na.rm=TRUE), sd = sd(WTP,na.rm=TRUE))
xtab5_Reception$mean = round(xtab5_Reception$mean, digits=2)
xtab5_Reception$sd = round(xtab5_Reception$sd, digits=2)




# Difference in Response Times between waves: 
### Ranksum test between waves returns no significant difference between the two waves of experiment

year_2020 = numeric(max(dRec$Subject[dRec$Year == 2020]))
year_2021 = numeric(max(dRec$Subject[dRec$Year == 2021]) - length(year_2020))

for (i in 1:length(year_2020)) {
  year_2020[i] <- mean(dRec$Estimation_RT[dRec$Subject == i & dRec$Year == 2020])
}

j=1
for (i in min(dRec$Subject[dRec$Year == 2021]):max(dRec$Subject[dRec$Year == 2021])) {
  year_2021[j] <- mean(dRec$Estimation_RT[dRec$Subject == i])
  j=j+1
}

waves_test = wilcox.test(year_2020,year_2021)





# Participants are not better than chance

# We compare participants' performances in estimating Veracity with a
# theoretical random distribution. We define this distribution by a number
# of draws n=48, a probability p=.05 and a population of size N=258:

response_successes = array()
for (sub in unique(dRec$Subject)){
  response_successes[sub] = sum(dRec$Success[dRec$Subject==sub])
  end
}

r = rbinom(258, size=48, prob=0.5)/48*100
sample1 <- data.frame(sample = 'empiric data', values = response_successes/48*100)
sample2 <- data.frame(sample = 'simulated data', values = r)
samples <- rbind(sample1,sample2)
ggplot(samples,aes(x = values, col = sample, fill = sample, group = sample)) + geom_density(alpha=0.2)

success_performances = boot.t.test(x=(response_successes/48*100), y=r,  alternative = "two.sided", mu=0, paired=FALSE, var.equal=FALSE,
            conf.level=0.95, R=100000)





## ALTERNATIVE Bayesian test of proportions
# We test the null hypothesis that the probability of a success is p
# The Bayes factor compares two hypotheses: probability is p0 (p) or is not p0 (not p)
# Manual: https://cran.r-project.org/web/packages/BayesFactor/vignettes/manual.html
# The proportionBF is from the library 'BayesFactor'
# The posterior description uses the library 'bayestestR'



# We will model our distribution via a logistic function.
# We choose a scaling parameter by visualizing the distributions:
# The distribution sd is 3.2; 
# create a sequence of x values from 18 to 30, which is near +/- 2sd
x <- seq(18,30, by=0.02) 
px<-dlogis(x,24,1.5) # We compute the Logistic pdf for each x with a scale of 1.5
plot(x,px,type="l",xlim=c(18,30),ylim=c(0,max(px)), lwd=3, col="darkred",ylab="f(x)",
     main=expression(paste("PDF of Logis(",mu,"=24, ",lambda,"=.5)"))) # Plot
abline(v=c(24),lty=2,col="gray")
# This corresponds to a wide scale, roughly mapping the empiric distribution



# With a 'medium' scale parameter at .5
samples1 = proportionBF(y = response_successes, N = as.integer(rep(48, each=258)), 
                      p = 0.5, iterations=10000, rscale=.5)
1/samples1
# With a scale parameter of .5, the Bayes factor favors the null hypothesis by a factor of about 0.102
# which is considered anecdotal evidence, according to Jeffereys (1961) and Lee & Wagenmakers (2013)


chains1 = posterior(samples1, iterations = 10000)
plot(chains1[,"p"], main = "Posterior of true probability\nof 'random-equivalent' behavior")
# the proportion of samples inside the ROPE [0.48 0.52] is 84.99% :
proportionBF1_table = describe_posterior(samples1, centrality="median", dispersion=TRUE, 
                                     rope_range=c(0.48, 0.52))
# the proportion of posterior samples inside the ROPE [0.49 0.53] is 100% :
proportionBF1_table2 = describe_posterior(samples1, centrality="median", dispersion=TRUE, 
                                        rope_range=c(0.49, 0.53))

## In other words, participants are slightly better than chance



# With a wider scale parameter, at 1.5
elogis(response_successes)
# estimated scale = 1.77
# run with scale = 1.5
samples2 = proportionBF(y = response_successes, N = as.integer(rep(48, each=258)), 
                        p = 0.5, iterations=10000, rscale=1.5)

1/samples2
# The Bayes factor favors the null hypothesis by a factor of about .3. Still anecdotal evidence

chains2 = posterior(samples2, iterations = 10000)
plot(chains2[,"p"], main = "Posterior of true probability\nof 'random-equivalent' behavior")
# the proportion of samples inside the ROPE [0.48 0.52] is 85.05%
proportionBF2_table = describe_posterior(samples2, centrality="median", dispersion=TRUE, 
                                         rope_range=c(0.48, 0.52))
# the proportion of posterior samples inside the ROPE [0.49 0.53] is 100%
proportionBF2_table2 = describe_posterior(samples2, centrality="median", dispersion=TRUE, 
                                          rope_range=c(0.49, 0.53))





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-behavioral_measures_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
