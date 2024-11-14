
##### VARIABLES #####

# Free memory
rm(list = ls(all.names = TRUE)) #will clear all objects includes hidden objects.
gc() #free up memory and report the memory usage


list.of.packages <- c("lme4", "pracma", "ggplot2", "sjPlot", "emmeans", "interactions", "jtools", 
                      "ggpubr", "mediation", "RColorBrewer", "broom.mixed", "purrr",
                      "rprojroot", "webshot",
                      "mediation") 
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

figure_path = paste(project_root, "/outputs/figures/R", sep="")

if (!dir.exists(paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles", sep=""))){
  dir.create(paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles", sep=""))
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
dRec_unscaled = dRec





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

dRec_conf_unscaled = dRec





##### Finish preprocessing #####

# We rescale the other variables
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
socjustYear2 = dRecYear2[dRecYear2$Theme == 'SocJust', ]


# in case of need: Command to select optimizer
'
model = glmer(response ~ fixed_effect + (1|Subject), data=data, family=binomial(link=""logit""))
model_allFits = allFit(model)
glance(model_allFits) |> select(optimizer, AIC, NLL_rel) |> arrange(NLL_rel)
'


# Note that we didn't assign random effects into a nested structure such as Year/Group/Subject to save computation time 
# (time could >15 min per glmer)






##### A. MLM of success: Better performances for true news #####

### Models
mSuccess_truth_themes = glmer(Success ~ Veracity + 
                                (1|Subject), data=dRec, family=binomial(link="logit"))

mSuccess_truth_themes2 = glmer(Success ~ Veracity*Theme + 
                                 (1|Subject), data=dRec, family=binomial(link="logit"))

mSuccess_truth_themes2_ctrld = glmer(Success ~ Veracity*Theme + Confidence + Judgment + Age + Sex + Education + Epistemic_curiosity + 
                                       (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"))


#### Table
table_1 = tab_model(mSuccess_truth_themes, mSuccess_truth_themes2, mSuccess_truth_themes2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 4, 5, 6, 7, 9, 19, 18, 10, 11, 3, 2, 12, 13, 8, 14, 15, 16, 17)
                    , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mSuccess_truth_themes.html", sep=""))




### Emmeans
estSuccess_truth_themes <- emmeans(mSuccess_truth_themes2_ctrld,~Theme,type = "response")
estSuccess_truth_themes_pairs = pairs(estSuccess_truth_themes) # gives comparisons odds-ratio
estSuccess_truth_themes_pairs_ci <- confint(estSuccess_truth_themes_pairs) # confidence intervals for the paired comparison
estSuccess_truth_themes_size = eff_size(estSuccess_truth_themes, sigma = sigma(mSuccess_truth_themes2_ctrld), edf = Inf) # gives comparisons effect size

estSuccess_truth_themes2 <- emmeans(mSuccess_truth_themes2_ctrld,~Veracity|Theme,type = "response")
estSuccess_truth_themes_pairs2 = pairs(estSuccess_truth_themes2, reverse=TRUE) # gives comparisons odds-ratio
estSuccess_truth_themes_pairs2_ci <- confint(estSuccess_truth_themes_pairs2) # confidence intervals for the paired comparison





##### B. MLM of success: Biased in judgment #####

### Models
mSuccess_truth_judgment = glmer(Success ~ Judgment + 
                                  (1+Judgment|Subject), data=dRec, family=binomial(link="logit"))

mSuccess_truth_Judgment_ctrld = glmer(Success ~ Judgment + Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity + 
                                        (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Table
table_2 = tab_model(mSuccess_truth_judgment, mSuccess_truth_Judgment_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 4, 5, 6, 7, 9, 10, 11, 19, 18, 3, 2, 12, 13, 8, 14, 15, 16, 17)
                    , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mSuccess_truth_judgment.html", sep=""))


### Emmeans
estSuccess_truth_judgment <- emmeans(mSuccess_truth_Judgment_ctrld,~Veracity,type = "response") 
estSuccess_truth_judgment_pairs = pairs(estSuccess_truth_judgment,interaction="revpairwise", type = "response") # gives comparisons odds-ratio
estSuccess_truth_judgment_pairs_ci <- confint(estSuccess_truth_judgment_pairs) # confidence intervals for the paired comparison
estSuccess_truth_judgment_size = eff_size(estSuccess_truth_judgment, sigma = sigma(mSuccess_truth_Judgment_ctrld), edf = Inf) # gives comparisons effect size




##### C. MLM of judgment: Biased in judgment #####

### Models
mJudgment_truth_themes = glmer(Judgment ~ Veracity + 
                                 (1|Subject), data=dRec, family=binomial(link="logit"))

mJudgment_truth_themes2 = glmer(Judgment ~ Veracity*Theme + 
                                  (1|Subject), data=dRec, family=binomial(link="logit"))

mJudgment_truth_themes2_ctrld = glmer(Judgment ~ Veracity*Theme + Confidence + Age + Sex + Education + Epistemic_curiosity + 
                                        (1+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Table
table_3 = tab_model(mJudgment_truth_themes, mJudgment_truth_themes2, mJudgment_truth_themes2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 4, 5, 6, 7, 9, 17, 16, 3, 2, 10, 11, 8, 12, 13, 14, 15)
                    , file = paste(project_root, "/scripts/analysis/tab_model_htmlfiles/tab_mJudgment_truth_themes.html", sep=""))

### Emmeans
estJudgment_truth_theme <- emmeans(mJudgment_truth_themes2_ctrld,~Theme,type = "response")
estJudgment_truth_theme_pairs = pairs(estJudgment_truth_theme, type = "response") # gives comparisons odds-ratio
estJudgment_truth_theme_pairs_ci <- confint(estJudgment_truth_theme_pairs) # confidence intervals for the paired comparison
estJudgment_truth_theme_size = eff_size(estJudgment_truth_theme, sigma = sigma(mJudgment_truth_themes2_ctrld), edf = Inf) # gives comparisons effect size

estJudgment_truth_theme2 <- emmeans(mJudgment_truth_themes2_ctrld,~Veracity|Theme,type = "response")
estJudgment_truth_theme_pairs2 = pairs(estJudgment_truth_theme2, reverse=TRUE) # gives comparisons odds-ratio
estJudgment_truth_theme_pairs2_ci <- confint(estJudgment_truth_theme_pairs2) # confidence intervals for the paired comparison





##### D. MLM of success: interaction effect of imprecision with Veracity #####

### Models
mSuccess_truth_ambig = glmer(Success ~ Veracity*Polarization + Veracity*Imprecision +
                               (1|Subject), data=dRec, family=binomial(link="logit"))

mSuccess_truth_ambig_ctrld = glmer(Success ~ Veracity*Polarization + Veracity*Imprecision + Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity + 
                                     (1+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                   control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mSuccess_truth_ambig_ctrld2 = glmer(Success ~ Veracity*Polarization + Veracity*Imprecision + Judgment + Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity + 
                                      (1+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                    control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mSuccess_truth_ambig_plot = glmer(Success ~ Veracity*Polarization + Veracity*Imprecision + Confidence + Veracity*Theme + 
                                    (1+Confidence|Subject), data=dRec_unscaled, family=binomial(link="logit"))


### Table
table_4 = tab_model(mSuccess_truth_ambig, mSuccess_truth_ambig_ctrld2, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 4, 5, 9, 12, 20, 21, 6, 7, 10, 11, 13, 23, 22, 3, 2, 14, 15, 8, 16, 17, 18, 19)
                    , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mSuccess_truth_ambig_orth.html", sep=""))


### Emmeans
estSuccess_truth_imprec <- emmeans(mSuccess_truth_ambig_ctrld2,~Imprecision|Veracity,type = "response", cov.reduce = range)
estSuccess_truth_imprec_pairs = pairs(estSuccess_truth_imprec,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estSuccess_truth_imprec_size = eff_size(estSuccess_truth_imprec, sigma = sigma(mSuccess_truth_ambig_ctrld2), edf = Inf) # gives comparisons effect size
estSuccess_truth_imprec_ci = confint(estSuccess_truth_imprec_pairs)

estSuccess_truth_polar <- emmeans(mSuccess_truth_ambig_ctrld2,~Polarization|Veracity,type = "response", cov.reduce = range)
estSuccess_truth_polar_pairs = pairs(estSuccess_truth_polar,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estSuccess_truth_polar_size = eff_size(estSuccess_truth_polar, sigma = sigma(mSuccess_truth_ambig_ctrld2), edf = Inf) # gives comparisons effect size
estSuccess_truth_polar_ci = confint(estSuccess_truth_polar_pairs)






##### E. MLM of judgment: interaction effect of imprecision with Veracity #####

### Models
mJudgment_truth_ambig = glmer(Judgment ~ Polarization + Imprecision +
                                (1|Subject), data=dRec, family=binomial(link="logit"))

mJudgment_truth_ambig2 = glmer(Judgment ~ Veracity*Polarization + Veracity*Imprecision + 
                                 (1|Subject), data=dRec, family=binomial(link="logit"))

mJudgment_truth_ambig2_ctrld = glmer(Judgment ~ Veracity*Polarization + Veracity*Imprecision + Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity + 
                                       (1+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                     control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mJudgment_truth_ambig_plot = glmer(Judgment ~ Veracity*Polarization + Veracity*Imprecision + Confidence + Veracity*Theme + (1+Confidence|Subject) + 
                                     (1|Order) + (1|Group) + (1|Year), data=dRec_unscaled, family=binomial(link="logit"), 
                                   control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Table
table_5 = tab_model(mJudgment_truth_ambig, mJudgment_truth_ambig2, mJudgment_truth_ambig2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                    order.terms = c(1, 4, 5, 9, 10, 18, 19, 6, 7, 11, 21, 20, 3, 2, 12, 13, 8, 14, 15, 16, 17)
                    , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mJudgment_truth_ambig_orth.html", sep=""))


### Emmeans
estJudgment_imprec_pairs = pairs(emmeans(mJudgment_truth_ambig2_ctrld,~Imprecision,type = "response", cov.reduce = range), reverse=TRUE)
estJudgment_imprec_pairs_ci = confint(estJudgment_imprec_pairs)

estJudgment_polar_pairs = pairs(emmeans(mJudgment_truth_ambig2_ctrld,~Polarization,type = "response", cov.reduce = range), reverse=TRUE)
estJudgment_polar_pairs_ci = confint(estJudgment_polar_pairs)

estJudgment_truth_imprec <- emmeans(mJudgment_truth_ambig2_ctrld,~Imprecision|Veracity,type = "response", cov.reduce = range)
estJudgment_truth_imprec_pairs = pairs(estJudgment_truth_imprec,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estJudgment_truth_imprec_size = eff_size(estJudgment_truth_imprec, sigma = sigma(mJudgment_truth_ambig2_ctrld), edf = Inf) # gives comparisons effect size
estJudgment_truth_imprec_ci = confint(estJudgment_truth_imprec_pairs)

estJudgment_truth_polar <- emmeans(mJudgment_truth_ambig2_ctrld,~Polarization|Veracity,type = "response", cov.reduce = range)
estJudgment_truth_polar_pairs = pairs(estJudgment_truth_polar,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estJudgment_truth_polar_size = eff_size(estJudgment_truth_polar, sigma = sigma(mJudgment_truth_ambig2_ctrld), edf = Inf) # gives comparisons effect size
estJudgment_truth_polar_ci = confint(estJudgment_truth_polar_pairs)





##### H. MLM of Metacognition (confidence) #####

### Models: Organizations
mConfidence_Ecology = lmer(Confidence ~ Greenpeace + WWF + NIPCC + Climato_realistes + 
                             (1|Subject), data=ecology
                           , control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=100000)))

mConfidence_Democracy = lmer(Confidence ~ Mouvement_europeen_france + Fondation_Robert_Schuman + Frexit + Parti_libertarien + 
                               (1|Subject), data=democracy)

mConfidence_Socjust = lmer(Confidence ~ Sos_mediterranee + Femen + Generation_identitaire + La_manif_pour_tous + 
                             (1|Subject), data=socjust)


### Models: Sociodemographics
mConfidence_SocioDemo = lmer(Confidence ~ Age + Sex + Education + Epistemic_curiosity  + 
                               (1|Subject), data=dRec
                             , control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=100000)))

mConfidence_SocioDemo2 = lmer(Confidence ~ Age + Sex + Education + Epistemic_curiosity  + Veracity*Theme + Judgment + 
                                (1+Judgment|Subject), data=dRec,
                              control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=100000)))


### Models: RT
mConfidence_RT = lmer(Confidence ~ Estimation_RT  + (1+Estimation_RT|Subject), data=dRec,
                      control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=100000))) 

mConfidence_RT2 = lmer(Confidence ~ Estimation_RT  + Veracity*Theme + (1+Estimation_RT|Subject), data=dRec, 
                       control=lmerControl(optimizer="Nelder_Mead",optCtrl=list(maxfun=100000))) 


### Models: Imprecision & Polarization
mConfidence_judgment_ambig = lmer(Confidence ~ Judgment*Polarization + Judgment*Imprecision + 
                                    (1|Subject), data=dRec)

mConfidence_judgment_ambig2 = lmer(Confidence ~ Judgment*Polarization + Judgment*Imprecision + Veracity*Theme + 
                                     (1|Subject), data=dRec)

mConfidence_judgment_ambig2_ctrld = lmer(Confidence ~ Judgment*Polarization + Judgment*Imprecision + Veracity*Theme + Estimation_RT + Age + Sex + Education + Epistemic_curiosity + 
                                           (1|Subject), data=dRec)

mConfidence_judgment_ambig2_ctrld_plot = lmer(Confidence ~ Judgment*Polarization + Judgment*Imprecision + Veracity*Theme + Estimation_RT + Age + Sex + Education + Epistemic_curiosity + 
                                           (1|Subject), data=dRec_conf_unscaled)



### Emmeans
# We lower computation time by specifying the only non nuisance variables of interest, changing the df for satterthwaite and increasing the limit of observations
estConfidence_judgment_imprec <- emmeans(mConfidence_judgment_ambig2_ctrld,~Judgment|Imprecision,type = "response", cov.reduce = function(x) quantile(x, c(0, 0.5, 1)), 
                                         non.nuisance = quote(all.vars(specs)), lmer.df = "satterthwaite", lmerTest.limit = 10944)
estConfidence_judgment_imprec_pairs = pairs(estConfidence_judgment_imprec,interaction="revpairwise", type = "response") # gives comparisons odds-ratio
estConfidence_judgment_imprec_pairs_ci = confint(estConfidence_judgment_imprec_pairs)
estConfidence_judgment_imprec_size = eff_size(estConfidence_judgment_imprec, sigma = sigma(mConfidence_judgment_ambig2_ctrld), edf = Inf) # gives comparisons effect size

estConfidence_judgment_polar <- emmeans(mConfidence_judgment_ambig2_ctrld,~Judgment|Polarization,type = "response", cov.reduce = function(x) quantile(x, c(0, 0.5, 1)),
                                        non.nuisance = quote(all.vars(specs)), lmer.df = "satterthwaite", lmerTest.limit = 10944)
estConfidence_judgment_polar_pairs = pairs(estConfidence_judgment_polar,interaction="revpairwise", type = "response") # gives comparisons odds-ratio
estConfidence_judgment_polar_pairs_ci = confint(estConfidence_judgment_polar_pairs)
estConfidence_judgment_polar_size = eff_size(estConfidence_judgment_polar, sigma = sigma(mJudgment_truth_ambig2_ctrld), edf = Inf) # gives comparisons effect size


### Tables
table_11 = tab_model(mConfidence_Ecology, mConfidence_Democracy, mConfidence_Socjust, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 2, 7, 10, 13, 4, 5, 9, 11, 3, 6, 8, 12)
                     , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mConfidence_organizations.html", sep=""))

table_12 = tab_model(mConfidence_judgment_ambig, mConfidence_judgment_ambig2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 3, 4, 9, 14, 12, 13, 5, 6, 10, 11, 15, 23, 22, 8, 2, 16, 17, 7, 18, 19, 20, 21)
                     , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mConfidence_judgment_ambig_orth.html", sep=""))




##### I. GLM of reception #####


### Models
mRec_theme = glmer(Reception ~ Veracity*Theme + 
                     (1|Subject), data=dRec, family=binomial(link="logit"), 
                   control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_confidence = glmer(Reception ~ Confidence + 
                          (1+Confidence|Subject), data=dRec, family=binomial(link="logit"), 
                        control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_confidence2 = glmer(Reception ~ Judgment*Confidence + 
                           (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"), 
                         control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_confidence2_ctrld = glmer(Reception ~ Judgment*Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity  + 
                                 (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"), 
                               control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_truth_confidence2_ctrld2 = glmer(Reception ~ Judgment*Confidence + Veracity*Theme + Veracity*Polarization + Veracity*Imprecision + Age + Sex + Education + Epistemic_curiosity + 
                                        (1+Judgment+Confidence|Subject), data=dRec, family=binomial(link="logit"),
                                      control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mRec_confidence_plot = glmer(Reception ~ Judgment*Confidence + Veracity*Theme + 
                               (1+Judgment+Confidence|Subject), data=dRec_unscaled, family=binomial(link="logit"), 
                             control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

# Unstandardizing the coefficients
mRec_confidence2_ctrld_coef_st = tidy(mRec_confidence2_ctrld, 
                                      effects = "fixed",
                                      conf.int = FALSE)

mRec_confidence2_ctrld_sd_all = dRec_unscaled %>%
  dplyr::select(Confidence) %>%
  map(sd) %>%
  stack() %>%
  dplyr::rename(sd = values)

mRec_confidence2_ctrld_coef_unst = mRec_confidence2_ctrld_coef_st  %>%
  inner_join(., mRec_confidence2_ctrld_sd_all, by = c("term" = "ind") ) %>%
  mutate_at( .vars = vars(estimate), 
             .funs = list(~round( ./sd, 4) ) ) %>%
  dplyr::select(-effect, -(std.error:p.value), -sd)

mRec_confidence2_ctrld_coef_unst_log_odds = 1 - exp(mRec_confidence2_ctrld_coef_unst$estimate)

#### Table
table_13 = tab_model(mRec_confidence2, mRec_confidence2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 3, 4, 5, 11, 6, 7, 9, 10, 12, 20, 19, 2, 13, 14, 8, 15, 16, 17, 18)
                     , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mRec_confidence.html", sep=""))


### Emmeans
estRec_judgment_confidence <- emmeans(mRec_confidence2_ctrld,~Confidence|Judgment,type = "response", cov.reduce = range)
estRec_judgment_confidence_pairs = pairs(estRec_judgment_confidence,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estRec_judgment_confidence_size = eff_size(estRec_judgment_confidence, sigma = sigma(mRec_confidence2_ctrld), edf = Inf) # gives comparisons effect size
estRec_judgment_confidence_ci = confint(estRec_judgment_confidence_pairs)





##### K. GLM of WTP ####

mWTP_confidence = lmer(WTP ~ Confidence + 
                         (1+Confidence|Subject), data=dRec, 
                       control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTP_confidence2 = lmer(WTP ~ Judgment*Confidence + 
                          (1+Judgment+Confidence|Subject), data=dRec, 
                        control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTP_confidence2bis = lmer(WTP ~ Reception*Confidence + 
                             (1+Reception+Confidence|Subject), data=dRec, 
                           control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTP_confidence2bis_ctrld = lmer(WTP ~ Reception*Confidence + Veracity*Theme + Age + Sex + Education + Epistemic_curiosity + 
                                   (1+Reception+Confidence|Subject), data=dRec, 
                                 control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTP_confidence2_ctrld2 = lmer(WTP ~ Reception*Confidence + Veracity*Theme + Veracity*Polarization + Veracity*Imprecision + Estimation_RT + Age + Sex + Education + Epistemic_curiosity + 
                                 (1+Reception+Confidence|Subject), data=dRec,
                               control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))

mWTP_confidence_plot = lmer(WTP ~ Reception*Confidence + Veracity*Theme + 
                              (1+Reception+Confidence|Subject), data=dRec_unscaled, 
                            control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=100000)))


### Table
table_14 = tab_model(mWTP_confidence2bis, mWTP_confidence2bis_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 4, 5, 3, 11, 6, 7, 9, 10, 12, 20, 19, 2, 13, 14, 8, 15, 16, 17, 18)
                     , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mWTP_confidence.html", sep=""))


### Emmeans
estWTP_rec_confidence <- emmeans(mWTP_confidence2bis_ctrld,~Confidence|Reception,Reception = "response", cov.reduce = range) #cov.reduce = function(x) quantile(x, c(0, 0.5, 1)))
estWTP_rec_confidence_pairs = pairs(estWTP_rec_confidence,interaction="pairwise", type = "response") # gives comparisons odds-ratio
estWTP_rec_confidence_size = eff_size(estWTP_rec_confidence, sigma = sigma(mWTP_confidence2bis_ctrld), edf = Inf) # gives comparisons effect size
estWTP_rec_confidence_ci = confint(estWTP_rec_confidence_pairs)
estWTP_rec_confidence_2 <- emmeans(mWTP_confidence2bis_ctrld,specs = c("Confidence","Reception"), cov.reduce = range)
estWTP_rec_confidence_2_contrast <- contrast(estWTP_rec_confidence_2,
                                             method = "revpairwise",
                                             simple = "each",
                                             combine = TRUE,
                                             adjust = "none") %>%
  summary(infer = TRUE)





##### Mediation analysis #####
## Mediation analysis: content precision -\> confidence -\> reception choice

list.of.packages <- c("lavaan", "semTools") 
{
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)
}


# We use the glm and lm functions, not glmer and lmer!
dRec_mediation <- read.csv(paste(project_root,"/data/processed/receivingNews_data.csv", sep=""))

dRec_mediation = rename_variables(dRec_mediation)
nan_str_count = check_nan_strings(dRec_mediation)
dRec_mediation = correct_nan_strings(dRec_mediation, nan_str_count)
dRec_mediation = mutate_values(dRec_mediation)
dRec_mediation$Confidence = as.numeric(dRec_mediation$Confidence)

## Terrence Jorgensen: "You don't have to center anything [...] lavaan will automatically partition its variance into the level-specific components."
# link: https://groups.google.com/g/lavaan/c/h2GiNsxBIdk

# Final dataset
dRec_mediation = dRec_mediation[,c("Subject", "Confidence", "Judgment", "Imprecision", "Polarization", "Reception")]



## Moderated mediation: thorough interactions model

# We conduct first a Confirmatory factor analysis (CFA)

model_confidence = 
  "
 Confidence =~ Imprecision + Polarization + Judgment + Imprecision:Judgment + Polarization:Judgment
"

cfa_confidence = cfa(model_confidence, data=dRec_mediation[,3:6], std.lv = TRUE, se = "bootstrap", bootstrap = 1000)
cfa_factor_loadings = summary(cfa_confidence, standardized=TRUE)
cfa_composite_reliability = compRelSEM(cfa_confidence)
cfa_variance = reliability(cfa_confidence)


# Then we define a moderated mediation model
model_categ_complex = 
  "
  # total effect
  Reception ~ c1*Imprecision + c2*Polarization + m*Confidence + wa*Judgment + wc1*Imprecision:Judgment + wc2*Polarization:Judgment
  # mediation effect
  Confidence ~ a1*Imprecision + a2*Polarization + wc*Judgment + wa1*Imprecision:Judgment + wa2*Polarization:Judgment
  # indirect and total effect, conditional on Judgment == 0
  ab01 := a1*m          # + 0*wa1*m
  total01 := ab01 + c1  # + 0*wc1
  ab02 := a2*m          # + 0*wa2*m
  total02 := ab02 + c2  # +0*wc2
  # indirect and total effect, conditional on Judgment == 1
  ab11 := ab01 + 1*wa1*m
  total11 := ab11 + c1 + 1*wc1
  ab12 := ab02 + 1*wa2*m
  total12 := ab12 + c2 + 1*wc2
"

# Fit the mediation model
fit_complex_categ_mediation <- lavaan::sem(model_categ_complex, data = dRec_mediation, estimator = "DWLS", se = "bootstrap", bootstrap = 1000, ordered = c("Judgment", "Reception"), orthogonal=TRUE)

# Display the results
summary(fit_complex_categ_mediation, standardized = F, rsquare=T)
lavaan::parameterEstimates(fit_complex_categ_mediation)

# Plot the mediation path diagram
lavaanPlot::lavaanPlot(model = fit_complex_categ_mediation, node_options = list(shape = "box", fontname = "Helvetica"), edge_options = list(color = "grey"), coefs = TRUE, covs = TRUE, stars = "regress")





##### POST-HOC #####

table_15 = tab_model(mSuccess_truth_ambig_ctrld2, mJudgment_truth_ambig2_ctrld, mConfidence_judgment_ambig2_ctrld, show.reflvl=TRUE, prefix.labels = "varname", auto.label=TRUE, collapse.ci=FALSE,
                     order.terms = c(1, 4, 5, 10, 15, 6, 7, 23, 24, 13, 14, 11, 12, 16, 26, 25, 3, 9, 8, 2, 17, 18, 19, 20, 21, 22)
                     , file = paste(project_root, "/scripts/analysis/tab_model_rand2_htmlfiles/tab_mSuccess_n_Judgment_truth_imprec_rand2.html", sep=""))
table_15
webshot(table_15$file, paste(figure_path, "/", "tab_rand2_mAll_truth_ambig.png", sep=""))





##### SAVE #####

save.image(paste(project_root, "/R_environments/ReceivingNews-Mixed_Linear_Models_main_rand2_env.RData",sep=""))

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
