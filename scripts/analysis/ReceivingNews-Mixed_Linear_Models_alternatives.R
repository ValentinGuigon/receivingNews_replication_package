
##### VARIABLES #####

# Free memory
rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


list.of.packages <- c("lme4", "ggplot2", "sjPlot", "emmeans", "interactions", "jtools", 
                      "ggpubr", "mediation", "RColorBrewer",
                      "rprojroot") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}

# set paths and mk necessary directories
set.seed(12345)
project_root = find_rstudio_root_file()

if (!dir.exists(paste(project_root, "/outputs/figures/R", sep=""))){
  dir.create(paste(project_root, "/outputs/figures/R", sep=""))
}else{
  print("dir exists")
}

if (!dir.exists(paste(project_root, "/scripts/analysis/tab_model_htmlfiles", sep=""))){
  dir.create(paste(project_root, "/scripts/analysis/tab_model_htmlfiles", sep=""))
}else{
  print("dir exists")
}


# read the data
dRec <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))

# transform the data
source(paste(project_root,"/scripts/src/utility/ReceivingNews_analysis_utility.R", sep=""))
dRec = rename_variables(dRec)
nan_str_count = check_nan_strings(dRec)
dRec = correct_nan_strings(dRec, nan_str_count)
dRec = mutate_values(dRec)
dRec = mutate_types(dRec)
dRec = dRec %>% mutate(Veracity = relevel(Veracity, "False"))
dRec = dRec %>% mutate(Judgment = relevel(Judgment, "False"))
dRec = rescale_variables(dRec)


# create subdata
ecology = dRec[dRec$Theme == 'Ecology', ]; names(ecology)[names(ecology) == "Success"] <- "Ecology_success"
democracy = dRec[dRec$Theme == 'Democracy', ]; names(democracy)[names(democracy) == "Success"] <- "Democracy_success"
socjust = dRec[dRec$Theme == 'Social Justice', ]; names(socjust)[names(socjust) == "Success"] <- "SocJust_success"

dRecYear2 = dRec[dRec$Year == 2021, ]
names(dRecYear2)[names(dRecYear2) == "Prcnt_politique"] <- "Distrust_politics"
names(dRecYear2)[names(dRecYear2) == "Prcnt_journaliste"] <- "Distrust_journalists"
names(dRecYear2)[names(dRecYear2) == "Prcnt_medecin"] <- "Distrust_physicians"
names(dRecYear2)[names(dRecYear2) == "Prcnt_acteurjustsoc"] <- "Distrust_socjust_activists"
names(dRecYear2)[names(dRecYear2) == "Prcnt_chercheur"] <- "Distrust_researchers"
names(dRecYear2)[names(dRecYear2) == "Prcnt_acteurecologie"] <- "Distrust_environmental_activists"
names(dRecYear2)[names(dRecYear2) == "Prcnt_general"] <- "Distrust_general"

ecologyYear2 = dRecYear2[dRecYear2$Theme == 'Ecology', ]
democracyYear2 = dRecYear2[dRecYear2$Theme == 'Democracy', ]
socjustYear2 = dRecYear2[dRecYear2$Theme == 'Social Justice', ]


# in case of need: Command to select optimizer
'
mJudgment3 = glmer(Judgment ~ Veracity*Theme + Confidence + Age + Sex + Education + Epistemic_curiosity + (1|Year/Group/Subject) + (1|Order) + (1|Order), data=dRec, family=binomial(link=""logit""))
mJudgment3_allFits = allFit(mJudgment3)
glance(mJudgment3_allFits) |> select(optimizer, AIC, NLL_rel) |> arrange(NLL_rel)
'


# Note that we didn't assign random effects into a nested structure such as Year/Group/Subject to save computation time 
# (time could >15 min per glmer)





# I. Mixed Linear Models
##### F. MLM of success: Alternative hypotheses #####

### Models: Organizations
mSuccessEcology = glmer(Ecology_success ~ Greenpeace + WWF + NIPCC + Climato_realistes + 
                          (1|Subject), data=ecology, family=binomial(link="logit"))

mSuccessDemocracy = glmer(Democracy_success ~ Mouvement_europeen_france + Fondation_Robert_Schuman + Frexit + Parti_libertarien + 
                            (1|Subject), data=democracy, family=binomial(link="logit"))

mSuccessSocjust = glmer(SocJust_success ~Sos_mediterranee + Femen + Generation_identitaire + La_manif_pour_tous + 
                          (1|Subject), data=socjust, family=binomial(link="logit"))



## Compute the 3 organizations that explain best the behavior and insert them in a new version of dRec
# return the 3 organizations with the greatest z-value:
# WWF
ecolBest = abs(summary(mSuccessEcology)$coeff[-1,3])[abs(summary(mSuccessEcology)$coeff[-1,3]) == max(abs(summary(mSuccessEcology)$coeff[-1,3]))]
# Mouvement_europeen_france
demoBest = abs(summary(mSuccessDemocracy)$coeff[-1,3])[abs(summary(mSuccessDemocracy)$coeff[-1,3]) == max(abs(summary(mSuccessDemocracy)$coeff[-1,3]))]
# Generation_identitaire
socjBest = abs(summary(mSuccessSocjust)$coeff[-1,3])[abs(summary(mSuccessSocjust)$coeff[-1,3]) == max(abs(summary(mSuccessSocjust)$coeff[-1,3]))]

orgaBest = data.frame(c(dRec$Theme), numeric(nrow(dRec)))
orgaBest[orgaBest[,1] == "Ecology", 2] = dRec$WWF[dRec$Theme == "Ecology"]
orgaBest[orgaBest[,1] == "Democracy", 2] = dRec$Mouvement_europeen_france[dRec$Theme == "Democracy"]
orgaBest[orgaBest[,1] == "Social Justice", 2] = dRec$Generation_identitaire[dRec$Theme == "Social Justice"]

dRec_plus = dRec
dRec_plus$orgaBest = orgaBest[,2]

# Run the models with now the best organizations of each theme
mSuccessAllthemes = glmer(Success ~ Theme*orgaBest + (1|Subject), data=dRec_plus, family=binomial(link="logit"))
mSuccessAllthemes2 = glmer(Success ~ Theme*orgaBest + Confidence + Veracity*Theme + (1+Confidence|Subject), data=dRec_plus, family=binomial(link="logit"))
# orgaBest is not significant


### Model: Sociodemographics
mSuccessSocioDemo = glmer(Success ~ Age + Sex + Education + Epistemic_curiosity  + (1|Subject), data=dRec, family=binomial(link="logit"), 
                          na.action=na.exclude)


### Models: RT
mSuccessRT = glmer(Success ~ Estimation_RT  + 
                     (1+Estimation_RT|Subject), data=dRec, family=binomial(link="logit"))

mSuccessRT_ctrld1 = glmer(Success ~ Estimation_RT + Veracity*Theme + 
                            (1+Estimation_RT|Subject), data=dRec, family=binomial(link="logit"))

mSuccessRT_ctrld2 = glmer(Success ~ Estimation_RT + Veracity*Theme + Confidence + Age + Sex + Education + Epistemic_curiosity + 
                            (1+Estimation_RT+Confidence|Subject), data=dRec, family=binomial(link="logit"), 
                          na.action=na.exclude)


### Models: Confidence
mSuccessConfidence = glmer(Success ~ Confidence + 
                             (1+Confidence|Subject), data=dRec, family=binomial(link="logit"))

mSuccessConfidence_ctrld = glmer(Success ~ Judgment*Confidence + Veracity*Theme + 
                                   (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"))


### Models: Distrust
mSuccessDistrust = glmer(Success ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                           Distrust_researchers + Distrust_environmental_activists + Distrust_general + 
                           (1|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"))

mSuccessDistrust2 = glmer(Success ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                            Distrust_researchers + Distrust_environmental_activists + Distrust_general + Veracity*Theme + 
                            (1|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"))

mSuccessDistrust3 = glmer(Success ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                            Distrust_researchers + Distrust_environmental_activists + Distrust_general + Veracity*Theme + Confidence + 
                            (1+Confidence|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"))

mSuccessDistrust4 = glmer(Success ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                            Distrust_researchers + Distrust_environmental_activists + Distrust_general + Veracity*Theme + Confidence + Age + 
                            Sex + Education + Epistemic_curiosity + (1+Confidence|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"), 
                          na.action=na.exclude,
                          control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


mSuccessDistrustEco = glmer(Success ~ Distrust_environmental_activists + Distrust_general + 
                              (1|Subject) + (1|Order) + (1|Group), data=ecologyYear2, family=binomial(link="logit"))

mSuccessDistrustDemo = glmer(Success ~ Distrust_politics + Distrust_general + 
                               (1|Subject) + (1|Order) + (1|Group), data=democracyYear2, family=binomial(link="logit"))

mSuccessDistrustSocJust = glmer(Success ~ Distrust_socjust_activists + Distrust_general + 
                                  (1|Subject) + (1|Order) + (1|Group), data=socjustYear2, family=binomial(link="logit"))


### Tables
table_6 = tab_model(mSuccessRT, mSuccessRT_ctrld2, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 9, 3, 4, 5, 6, 7, 10, 17, 16, 2, 11, 12, 8, 13, 14, 15, 18)
                    , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mSuccess_alternatives_RT.html", sep=""))
table_7 = tab_model(mSuccessConfidence, mSuccessConfidence_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 11)
                    , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mSuccess_alternatives_confidence.html", sep=""))
table_8 = tab_model(mSuccessEcology, mSuccessDemocracy, mSuccessSocjust, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 2, 7, 10, 13, 4, 5, 9, 11, 3, 6, 8, 12)
                    , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mSuccess_alternatives_organizations.html", sep=""))
table_9 = tab_model(mSuccessRT_ctrld1, mSuccessSocioDemo, mSuccessDistrust, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 15, 10, 11, 12, 13, 16, 24, 23, 2, 17, 18, 14, 19, 20, 21, 22, 3, 4, 5, 6, 7, 8, 9)
                    , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mSuccess_alternatives.html", sep=""))





##### G. MLM of judgment: Alternative hypotheses #####

### Models: Organizations
mJudgmentEcology = glmer(Judgment ~ Greenpeace + WWF + NIPCC + Climato_realistes +  
                           (1|Subject), data=ecology, family=binomial(link="logit"))

mJudgmentDemocracy = glmer(Judgment ~ Mouvement_europeen_france + Fondation_Robert_Schuman + Frexit + Parti_libertarien +  
                             (1|Subject), data=democracy, family=binomial(link="logit"))

mJudgmentSocjust = glmer(Judgment ~Sos_mediterranee + Femen + Generation_identitaire + La_manif_pour_tous + 
                           (1|Subject), data=socjust, family=binomial(link="logit"))


### Model: Sociodemographics
mJudgmentSocioDemo = glmer(Judgment ~ Age + Sex + Education + Epistemic_curiosity  + Confidence + Veracity*Theme + 
                             (1+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                           na.action=na.exclude,
                           control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: RT
mJudgmentRT = glmer(Judgment ~ Estimation_RT  + Confidence + Veracity*Theme + 
                      (1+Estimation_RT+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: Confidence
mJudgmentConfidence = glmer(Judgment ~ Confidence + Veracity*Theme + (1+Confidence|Subject), data=dRec, family=binomial(link="logit"))


### Models: Distrust
mJudgmentDistrust = glmer(Judgment ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                            Distrust_researchers + Distrust_environmental_activists + Distrust_general + Confidence + Veracity*Theme + 
                            (1+Confidence|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"))


mJudgmentDistrustEco = glmer(Judgment ~ Distrust_environmental_activists + Distrust_general + Confidence + Veracity + 
                               (1+Confidence|Subject) + (1|Order) + (1|Group), data=ecologyYear2, family=binomial(link="logit"))

mJudgmentDistrustDemo = glmer(Judgment ~ Distrust_politics + Distrust_general + Confidence + Veracity + 
                                (1+Confidence|Subject) + (1|Order) + (1|Group), data=democracyYear2, family=binomial(link="logit"))

mJudgmentDistrustSocJust = glmer(Judgment ~ Distrust_socjust_activists + Distrust_general + Confidence + Veracity + 
                                   (1+Confidence|Subject) + (1|Order) + (1|Group), data=socjustYear2, family=binomial(link="logit"))


### Table
table_10 = tab_model(mJudgmentRT, mJudgmentConfidence, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 2, 3, 4, 5, 6, 7, 8, 10, 9)
                     , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mJudgment_alternatives.html", sep=""))





##### J. GLM of reception: Alternative hypotheses #####

### Models: Organizations
mRecEcology = glmer(Reception ~ Greenpeace + WWF + NIPCC + Climato_realistes + 
                      (1|Subject), data=ecology, family=binomial(link="logit"), 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRecDemocracy = glmer(Reception ~ Mouvement_europeen_france + Fondation_Robert_Schuman + Frexit + Parti_libertarien + 
                        (1|Subject), data=democracy, family=binomial(link="logit"), 
                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRecSocjust = glmer(Reception ~ Sos_mediterranee + Femen + Generation_identitaire + La_manif_pour_tous + 
                      (1|Subject), data=socjust, family=binomial(link="logit"), 
                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Run the models with now the best organizations of each theme
mRecAllthemes = glmer(Reception ~ Theme*orgaBest + (1|Subject), data=dRec_plus, family=binomial(link="logit"),
                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
mRecAllthemes2 = glmer(Reception ~ Theme*orgaBest + Confidence + Veracity*Theme + (1+Confidence|Subject), data=dRec_plus, family=binomial(link="logit"),
                       control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
# orgaBest is not significant

### Model: Sociodemographics
mRecSocioDemo = glmer(Reception ~ Age + Sex + Education + Epistemic_curiosity  + Year + 
                        (1|Subject), data=dRec, family=binomial(link="logit"), 
                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: RT
mRecRT = glmer(Reception ~ Reception_RT  + Year + 
                 (1+Reception_RT|Subject), data=dRec, family=binomial(link="logit"), 
               control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Models: Distrust
mRecDistrust = glmer(Reception ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                       Distrust_researchers + Distrust_environmental_activists + Distrust_general + 
                       (1|Subject) + (1|Order) + (1|Group), data=dRecYear2, family=binomial(link="logit"), 
                     control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


mRecDistrustEco = glmer(Reception ~ Distrust_environmental_activists + Distrust_general + 
                          (1|Subject) + (1|Order) + (1|Group), data=ecologyYear2, family=binomial(link="logit"))

mRecDistrustDemo = glmer(Reception ~ Distrust_politics + Distrust_general + 
                           (1|Subject) + (1|Order) + (1|Group), data=democracyYear2, family=binomial(link="logit"))

mRecDistrustSocJust = glmer(Reception ~ Distrust_socjust_activists + Distrust_general + 
                              (1|Subject) + (1|Order) + (1|Group), data=socjustYear2, family=binomial(link="logit"))


### Model: Imprecision & Polarisation

mRec_judgment_ambig = glmer(Reception ~ Judgment*Polarisation + Judgment*Imprecision +
                              (1+Judgment|Subject), data=dRec, family=binomial(link="logit"),
                            control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_truth_ambig = lmer(WTP ~ Veracity*Imprecision + Veracity*Polarisation +
                          (1|Subject), data=dRec,
                        control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

estRec_truth_imprec <- emmeans(mRec_truth_ambig,~Imprecision|Veracity,type = "response", cov.reduce = range)
estRec_truth_imprec_pairs = pairs(estRec_truth_imprec,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estRec_truth_imprec_size = eff_size(estRec_truth_imprec, sigma = sigma(mRec_truth_ambig), edf = Inf) # gives comparisons effect size
estRec_truth_imprec_confint = confint(estRec_truth_imprec_pairs)

estRec_truth_polar <- emmeans(mRec_truth_ambig,~Polarisation|Veracity,type = "response", cov.reduce = range)
estRec_truth_polar_pairs = pairs(estRec_truth_polar,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estRec_truth_polar_size = eff_size(estRec_truth_polar, sigma = sigma(mRec_truth_ambig), edf = Inf) # gives comparisons effect size
estRec_truth_polar_confint = confint(estRec_truth_polar_pairs)





##### L. GLM of WTP: Alternative hypotheses #####

### Models: Organizations
mWTPEcology = lmer(WTP ~ Greenpeace + WWF + NIPCC + Climato_realistes + 
                     (1|Subject), data=ecology, 
                   control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTPDemocracy = lmer(WTP ~ Mouvement_europeen_france + Fondation_Robert_Schuman + Frexit + Parti_libertarien + 
                       (1|Subject), data=democracy, 
                     control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTPSocjust = lmer(WTP ~Sos_mediterranee + Femen + Generation_identitaire + La_manif_pour_tous + 
                     (1|Subject), data=socjust, 
                   control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: Sociodemographics
mWTPSocioDemo = lmer(WTP ~ Age + Sex + Education + Epistemic_curiosity  + 
                       (1|Subject), data=dRec, 
                     control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: RT
'
# mWTPRT = lmer(WTP ~ WTP_RT  + (1+WTP_RT|Subject), data=dRec, control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))
'


### Models: Distrust
mWTPDistrust = lmer(WTP ~ Distrust_politics + Distrust_journalists + Distrust_physicians + Distrust_socjust_activists + 
                      Distrust_researchers + Distrust_environmental_activists + Distrust_general + 
                      (1|Subject) + (1|Order) + (1|Group), data=dRecYear2, 
                    control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTPDistrustEco = lmer(WTP ~ Distrust_environmental_activists + Distrust_general + 
                         (1|Subject) + (1|Order) + (1|Group), data=ecologyYear2, 
                       control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTPDistrustDemo = lmer(WTP ~ Distrust_politics + Distrust_general + 
                          (1|Subject) + (1|Order) + (1|Group), data=democracyYear2, 
                        control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTPDistrustSocJust = lmer(WTP ~ Distrust_socjust_activists + Distrust_general + 
                             (1|Subject) + (1|Order) + (1|Group), data=socjustYear2, 
                           control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Model: Imprecision & Polarisation
mWTP_judgment_ambig = lmer(WTP ~ Judgment*Imprecision + Judgment*Polarisation +
                             (1+Judgment|Subject), data=dRec)

mWTP_truth_ambig = lmer(WTP ~ Veracity*Polarisation + Veracity*Imprecision + Veracity*Theme + 
                          (1|Subject), data=dRec)


estWTP_judgment_imprec <- emmeans(mWTP_judgment_ambig,~Veracity|Imprecision,type = "response", cov.reduce = function(x) quantile(x, c(0, 0.5, 1)), 
                                  non.nuisance = quote(all.vars(specs)), lmer.df = "satterthwaite", lmerTest.limit = 10944)
estWTP_judgment_imprec_pairs = pairs(estWTP_judgment_imprec,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estWTP_judgment_imprec_size = eff_size(estWTP_judgment_imprec, sigma = sigma(mWTP_judgment_ambig), edf = Inf) # gives comparisons effect size

estWTP_judgment_polar <- emmeans(mWTP_judgment_ambig,~Veracity|Polarisation,type = "response", cov.reduce = function(x) quantile(x, c(0, 0.5, 1)),
                                 non.nuisance = quote(all.vars(specs)), lmer.df = "satterthwaite", lmerTest.limit = 10944)
estWTP_judgment_polar_pairs = pairs(estWTP_judgment_polar,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estWTP_judgment_polar_size = eff_size(estWTP_judgment_polar, sigma = sigma(mWTP_judgment_ambig), edf = Inf) # gives comparisons effect size





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Mixed_Linear_Models_alternatives_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
