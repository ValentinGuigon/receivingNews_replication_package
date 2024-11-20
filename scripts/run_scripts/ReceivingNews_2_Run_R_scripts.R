
# Behavior analyses scripts
source("./scripts/analysis/ReceivingNews2-power_simulation.R")
source("./scripts/analysis/ReceivingNews-Stimuli_ICC.R")
source("./scripts/analysis/ReceivingNews-Behavioral_measures.R")
source("./scripts/analysis/ReceivingNews-Bayesian_models.R")
source("./scripts/analysis/ReceivingNews-Imprec_Polar_figures.R")
source("./scripts/analysis/ReceivingNews-Mixed_Linear_Models_main.R")
source("./scripts/analysis/ReceivingNews-Mixed_Linear_Models_alternatives.R")
source("./scripts/analysis/ReceivingNews-Bayesian_Mixed_Linear_Models.R")

# Behavior analyses reports
rmarkdown::render("./scripts/reporting/ReceivingNews2-power_simulation-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-Stimuli_ICC-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-Behavioral_measures-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-Bayesian_models-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-Imprec_Polar_figures-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-MLM_reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
rmarkdown::render("./scripts/reporting/ReceivingNews-Bayesian_MLM-reporting.Rmd",output_dir = paste(project_root, "/outputs/reports", sep=""))
