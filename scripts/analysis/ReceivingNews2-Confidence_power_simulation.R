##### LIBRARIES #####

rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


list.of.packages=c("lme4", "magrittr", "dplyr", "simr", "broom.mixed", "purrr",
                   "rprojroot")
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}





##### VARIABLES #####

set.seed(12345)

project_root = find_rstudio_root_file()
dRec <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))

source(paste(project_root,"/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))
dRec = rename_variables(dRec)
dRec = mutate_values(dRec)
dRec = mutate_types(dRec)
#dRec = rescale_variables(dRec)



# create a subset for the first wave
dRecYear1 = subset(dRec, Year==2020)






##### Arguments #####

# object: a fitted model object to extend.
# along: the name of an explanatory variable. This variable will have its number of levels extended.
# within: names of grouping variables, separated by "+" or ",". Each combination of groups will be extended to n rows.
# n: number of levels: the levels of the explanatory variable will be replaced by 1,2,3,..,n for a continuous variable or a,b,c,...,n for a factor.
# values: alternatively, you can specify a new set of levels for the explanatory variable.

# To fix the error "Error in attr(test, "text")(fit, sim) : attempt to apply non-function", 
# one should make sure the input test function has some functions as the "text" attribute.
# From an issue raised at the simr GitHub : https://github.com/pitakakariki/simr/issues/203 :
# test1=fixed("Imprecision")
# attr(test1, "text") <- function(...) NULL

# Can specify which effect we want tester: fixed("x","lr")
# Can use z instead of likelihood ratio





##### SIMULATIONS FROM FIRST WAVE: controlled model #####

## SUCCESS
##### SIMULATIONS FROM FIRST WAVE: lighter model, current fixef #####
## We remove the sociodemoraphics to lower computation time:
mSuccessConf = glmer(Success ~ Confidence + 
                   (1|Subject), data=dRecYear1, family='binomial'(link='logit'))
summary(mSuccessConf)
mSuccessConf_fixed = mSuccessConf
mSuccessConf_fixed_extended <- extend(mSuccessConf_fixed, along="Subject", n=250)

# We show the curve of power for main effect of confidence:
pc_mSuccessConf_extended  <- powerCurve(mSuccessConf_fixed_extended, test=fixed("Confidence"), along="Subject",
                                    breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessConf_extended)
pc_mSuccessConf_extended $errors
pc_mSuccessConf_extended $warnings
pc_mSuccessConf_extended 


cc_Success = fixef(mSuccessConf)
# intercept proba is 49.65%
plogis(cc_Success["(Intercept)"])
# Each increase in confidence decreases the odds by 0.15 pt (as given by odds ratio)
1 - exp(cc_Success["Confidence"])

## We increase the fixed main effect to a decrease of odds equal to 0.45pt
new_decrease_in_points = 0.15*2
new_log_odds = log(1- (new_decrease_in_points/100))
mSuccessConf2 = mSuccessConf
fixef(mSuccessConf2)['Confidence'] <- new_log_odds

mSuccessConf2_fixed = mSuccessConf2
mSuccessConf2_fixed_extended <- extend(mSuccessConf2_fixed, along="Subject", n=250)
pc_SuccessConf2_fixed_extended <- powerCurve(mSuccessConf2_fixed_extended, test=fixed("Confidence"), along="Subject",
                                         breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_SuccessConf2_fixed_extended)
pc_SuccessConf2_fixed_extended$errors
pc_SuccessConf2_fixed_extended$warnings
pc_SuccessConf2_fixed_extended







## RECEPTION
##### SIMULATIONS FROM FIRST WAVE: lighter model, current fixef #####
## We remove the sociodemoraphics to lower computation time:
mRecConf = glmer(Reception ~ Confidence + Judgment + Veracity*Theme + 
                         (1|Subject), data=dRecYear1, family='binomial'(link='logit'))
summary(mRecConf)
mRecConf_fixed = mRecConf
mRecConf_fixed_extended <- extend(mRecConf_fixed, along="Subject", n=250)

# We show the curve of power for main effect of confidence:
pc_mRecConf_extended  <- powerCurve(mRecConf_fixed_extended, test=fixed("Confidence"), along="Subject",
                                    breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mRecConf_extended)
pc_mRecConf_extended $errors
pc_mRecConf_extended $warnings
pc_mRecConf_extended 
# Computation time is <45mins, power is 99% starting at 80 subjects


cc_Rec = fixef(mRecConf)
# intercept proba is 51.24%
plogis(cc_Rec["(Intercept)"])
# Each increase in confidence decreases the odds by 1.45 pt (as given by odds ratio)
1 - exp(cc_Rec["Confidence"])

## We lower the fixed main effect to a decrease of odds equal to 1pt
new_decrease_in_points = 1.45/2
new_log_odds = log(1- (new_decrease_in_points/100))
mRecConf2 = mRecConf
fixef(mRecConf2)['Confidence'] <- new_log_odds

mRecConf2_fixed = mRecConf2
mRecConf2_fixed_extended <- extend(mRecConf2_fixed, along="Subject", n=250)
pc_RecConf2_fixed_extended <- powerCurve(mRecConf2_fixed_extended, test=fixed("Confidence"), along="Subject",
                                                     breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_RecConf2_fixed_extended)
pc_RecConf2_fixed_extended$errors
pc_RecConf2_fixed_extended$warnings
pc_RecConf2_fixed_extended









##### SAVE #####

#save.image(paste(project_root, "/R_environments/ReceivingNews2-power_simulation2_env.RData",sep=""))

#invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
