##### LIBRARIES #####

rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


list.of.packages=c("lme4", "magrittr", "dplyr", "simr",
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
dRec = rescale_variables(dRec)



# create a subset for the first wave
dRecYear1 = subset(dRec, Year==2020)





##### Multicollinearity #####
# We handle multicollinearity by orthogonalizing with the Gram-Schmidt algorithm

# But first we mean-center
dRecYear1$Imprecision = scale(dRecYear1$Imprecision, center=TRUE, scale=FALSE)
dRecYear1$Polarization = scale(dRecYear1$Polarization, center=TRUE, scale=FALSE)

# Next we orthogonalize
data_for_orth = as.matrix(dRecYear1[, c("Imprecision", "Polarization")])
data_orth = gramSchmidt(data_for_orth)

Imprecision = (Imprecision=data_orth$Q[,1])
Polarization = (Polarization=data_orth$Q[,2])

dRecYear1$Imprecision = Imprecision
dRecYear1$Polarization = Polarization

# Then we standardize the data
# Standardizing after orthogonalization can bring the variables to a common scale, which can aid in the interpretability of the coefficients
dRecYear1$Imprecision = scale(dRecYear1$Imprecision, center=FALSE, scale=TRUE)
dRecYear1$Polarization = scale(dRecYear1$Polarization, center=FALSE, scale=TRUE)





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
# Simple effect of imprecision: Success 1
# The model was reduced to its core components to save computation time + complex models output errors in this analysis
mSuccessAmbig = glmer(Success ~ Veracity*Imprecision + Veracity*Polarization + Confidence + Veracity*Theme + 
                        Age + Sex + Education + Epistemic_curiosity +
                        (1|Subject), data=dRecYear1, family='binomial'(link='logit')
                      ,control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000))
)
summary(mSuccessAmbig)

# Observed effect size for Imprecision is -0.2
doTest(mSuccessAmbig, fixed("Imprecision","z"))

# Observed effect size for Polarization is -0.17
doTest(mSuccessAmbig, fixed("Polarization","z"))

exp(coef(summary(mSuccessAmbig)))
# Imprecision odds-ratio=0.82 & Polarization odds-ratio=0.84


# Simulated actual power for imprecision
ps_mSuccessImprec=powerSim(mSuccessAmbig, test=fixed("Imprecision"), nsim=100, alpha=.05, progress=TRUE)
# Simulated actual power for main effect is 99%
ps2_mSuccessImprec=powerSim(mSuccessAmbig, test=fixed("VeracityFalse:Imprecision"), nsim=100, alpha=.05, progress=TRUE)
# Simulated actual power for interaction effect is 100%

# Simulated actual power for polarization
p3_mSuccessPolar=powerSim(mSuccessAmbig, test=fixed("Polarization"), nsim=100, alpha=.05, progress=TRUE)
# Simulated actual power for main effect is 99%
ps4_mSuccessPolar=powerSim(mSuccessAmbig, test=fixed("VeracityFalse:Polarization"), nsim=100, alpha=.05, progress=TRUE)
# Simulated actual power for interaction effect is 100%





##### SIMULATIONS FROM FIRST WAVE: lighter model, current fixef #####
## Second version of the model: we remove the sociodemoraphics to lower computation time:
mSuccessAmbig2 = glmer(Success ~ Veracity*Imprecision + Veracity*Polarization + Confidence + Veracity*Theme + 
                         #Age + Sex + Education + Ec +
                         (1|Subject), data=dRecYear1, family='binomial'(link='logit')
                       ,control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000))
)
summary(mSuccessAmbig2)
mSuccessAmbig2_fixed = mSuccessAmbig2
mSuccessAmbig2_fixed_extended <- extend(mSuccessAmbig2_fixed, along="Subject", n=250)

# We show the curve of power for main effect of imprecision:
pc_mSuccess2_fixed_extended_Imprec  <- powerCurve(mSuccessAmbig2_fixed_extended, test=fixed("Imprecision"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccess2_fixed_extended_Imprec )
pc_mSuccess2_fixed_extended_Imprec $errors
pc_mSuccess2_fixed_extended_Imprec $warnings
pc_mSuccess2_fixed_extended_Imprec 
# Computation time is <45mins, power is 99% starting at 80 subjects

# We show the curve of power for main effect of polarization:
pc_mSuccess2_fixed_extended_Polar <- powerCurve(mSuccessAmbig2_fixed_extended, test=fixed("Polarization"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccess2_fixed_extended_Polar)
pc_mSuccess2_fixed_extended_Polar$errors
pc_mSuccess2_fixed_extended_Polar$warnings
pc_mSuccess2_fixed_extended_Polar
# Power is ~88% starting at 80 subjects





##### SIMULATIONS FROM FIRST WAVE: lighter model, lower fixef #####
## We lower the fixed main effect of imprecision:
mSuccessAmbig3 = mSuccessAmbig2
fixef(mSuccessAmbig3)['Imprecision'] <- -0.05
mSuccessAmbig3_fixed = mSuccessAmbig3
mSuccessAmbig3_fixed_extended <- extend(mSuccessAmbig3_fixed, along="Subject", n=250)
pc_mSuccessAmbig3_fixed_extended_Imprec <- powerCurve(mSuccessAmbig3_fixed_extended, test=fixed("Imprecision"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig3_fixed_extended_Imprec)
pc_mSuccessAmbig3_fixed_extended_Imprec$errors
pc_mSuccessAmbig3_fixed_extended_Imprec$warnings
# Effect size too low to have good power

## We lower the fixed main effect of polarization:
mSuccessAmbig3 = mSuccessAmbig2
fixef(mSuccessAmbig3)['Polarization'] <- -0.05
mSuccessAmbig3_fixed = mSuccessAmbig3
mSuccessAmbig3_fixed_extended <- extend(mSuccessAmbig3_fixed, along="Subject", n=250)
pc_mSuccessAmbig3_fixed_extended_Polar <- powerCurve(mSuccessAmbig3_fixed_extended, test=fixed("Polarization"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig3_fixed_extended_Polar)
pc_mSuccessAmbig3_fixed_extended_Polar$errors
pc_mSuccessAmbig3_fixed_extended_Polar$warnings
# Effect size too low to have good power








## We test middle fixed effects for Imprecision:
# Main effect
mSuccessAmbig4 = mSuccessAmbig2
fixef(mSuccessAmbig4)['Imprecision'] <- -0.1
mSuccessAmbig4_fixed = mSuccessAmbig4
mSuccessAmbig4_fixed_extended <- extend(mSuccessAmbig4_fixed, along="Subject", n=250)
pc_mSuccessAmbig4_fixed_extended_Imprec <- powerCurve(mSuccessAmbig4_fixed_extended, test=fixed("Imprecision"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig4_fixed_extended_Imprec)
pc_mSuccessAmbig4_fixed_extended_Imprec$errors
pc_mSuccessAmbig4_fixed_extended_Imprec$warnings
# Effect size with power >91% from 200 subjects


# Interaction effect
mSuccessAmbig5 = mSuccessAmbig2
fixef(mSuccessAmbig5)['VeracityFalse:Imprecision'] <- -0.25
mSuccessAmbig5_fixed = mSuccessAmbig5
mSuccessAmbig5_fixed_extended <- extend(mSuccessAmbig5_fixed, along="Subject", n=250)
pc_mSuccessAmbig5_fixed_extended_Imprec <- powerCurve(mSuccessAmbig5_fixed_extended, test=fixed("VeracityFalse:Imprecision"), along="Subject",
                                               breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig5_fixed_extended_Imprec)
pc_mSuccessAmbig5_fixed_extended_Imprec$errors
pc_mSuccessAmbig5_fixed_extended_Imprec$warnings
# Effect size with power >94% from 80 subjects


## We test a middle fixed main effect for Polarization:
# Main effect
mSuccessAmbig4 = mSuccessAmbig2
fixef(mSuccessAmbig4)['Polarization'] <- -0.1
mSuccessAmbig4_fixed = mSuccessAmbig4
mSuccessAmbig4_fixed_extended <- extend(mSuccessAmbig4_fixed, along="Subject", n=250)
pc_mSuccessAmbig4_fixed_extended_Polar <- powerCurve(mSuccessAmbig4_fixed_extended, test=fixed("Polarization"), along="Subject",
                                                      breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig4_fixed_extended_Polar)
pc_mSuccessAmbig4_fixed_extended_Polar$errors
pc_mSuccessAmbig4_fixed_extended_Polar$warnings
# Effect size with power >80% from 200 subjects


# Interaction effect
mSuccessAmbig5 = mSuccessAmbig2
fixef(mSuccessAmbig5)['VeracityFalse:Polarization'] <- -0.25
mSuccessAmbig5_fixed = mSuccessAmbig5
mSuccessAmbig5_fixed_extended <- extend(mSuccessAmbig5_fixed, along="Subject", n=250)
pc_mSuccessAmbig5_fixed_extended_Polar <- powerCurve(mSuccessAmbig5_fixed_extended, test=fixed("VeracityFalse:Polarization"), along="Subject",
                                                      breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
plot(pc_mSuccessAmbig5_fixed_extended_Polar)
pc_mSuccessAmbig5_fixed_extended_Polar$errors
pc_mSuccessAmbig5_fixed_extended_Polar$warnings
# Effect size with power >95% from 80 subjects





##### Comparing the detection of Interaction effect of imprecision with only main effect model: #####
mSuccessAmbigInt_fixed = mSuccessAmbig2
summary(mSuccessAmbigInt_fixed)
# Interaction effect is at .35

# We check simulated current power:
ps_mSuccessAmbigInt_fixed <- powerSim(mSuccessAmbigInt_fixed, nsim=100, 
                                      test = fcompare(Success ~ Veracity + Imprecision + Polarization + Confidence + Veracity*Theme + (1|Subject)))
# It is currently at 100%

# We check simulated power for higher sample size and lower fixed effect:
mSuccessAmbigInt_fixed_extended <- extend(mSuccessAmbigInt_fixed, along="Subject", n=250)
fixef(mSuccessAmbigInt_fixed_extended)['VeracityFalse:Imprecision'] <- -0.25
fixef(mSuccessAmbigInt_fixed_extended)['VeracityFalse:Polarization'] <- -0.25

# fcompare function: compare model to only specified fixed effects in the alternative model:
p_curve_interaction_success  <- powerCurve(mSuccessAmbigInt_fixed_extended, 
                                           test=fcompare(Success ~ Veracity + Imprecision + Polarization + Confidence + Veracity*Theme + 
                                                           (1|Subject)), 
                                           along="Subject", breaks=c(80,150,200,250), nsim=100, alpha=.05, progress=TRUE)
p_curve_interaction_success$errors
p_curve_interaction_success$warnings
plot(p_curve_interaction_success)
# Estimated power above 95% is reached from 80 subjects



##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews2-power_simulation_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
