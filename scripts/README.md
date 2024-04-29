# Prerequisites:
* Matlab 2020b minimum
* R 4.3.1
* Install the package *renv* for R
* Load the R Project and call renv::restore()

For Bayesian analyses:

* Download and install:
    * JAGS 4.3.1 (simplest solution is to have installed R and JAGS, and Rstudio if exist, in the same folder)
    * Rtools 4.3
* On R, install.packages("rjags") 
* In case of trouble write in C:\Users\username\Documents\.R\Makevars.win the following:  
JAGS_HOME=C:\programs\JAGS\JAGS-4.3.1

JAGS and Rtools should be of a version that matches the version of R.


# To automatically redo the analyses, follow the steps below
* Requirements: **R** and **MATLAB**

Go to the ```./scripts/run_scripts```

1. Execute *ReceivingNews_1_Run_Matlab_scripts.m*
This will run steps 1 to 8 and step 10

2. Execute *ReceivingNews_2_Run_R_scripts.m*
This will run steps 9 to 16 as well as the .Rmd scripts, except step 10



# To manually redo the analyses, follow the steps below

## Analyses
1. We begin by extracting raw data and processing it. This process is done via MATLAB.  
2. Then we analyze the data.  
Behavioral images are computed by a MATLAB script.  
Behavioral analysis and their outputs are computed by R scripts.
3. Finally, we create *.html* notebooks.

### Data processing
Requirements: **MATLAB**  

Subjects raw data are located in ```.data\raw``` folder  
Stimuli raw data (tables for news evaluations by independent raters) are located in ```.data\stimuli``` folder

#### I. Extract data
Go to the ```./scripts/extraction```

1. Open *Receivingnews2_extract_subject.m*, set the project_root variable then run the script

2. Open *Receivingnews3_extract_subject.m*, set the project_root variable then run the script  

Data will be saved in the folder ```./data/intermediate```

ReceivingNews1 refers to the pilot experiment. It is not included in the data Analysis, therefore not processed.  
ReceivingNews2 refers to the first wave of the experiment. It is included in the processing and in the analysis.  
ReceivingNews3 refers to the second wave of the experiment. It is included in the processing and in the analysis.


#### II. Extract the evaluation of the news by the judges
Go to the ```./scripts/extraction``` folder

3. Open and run *ReceivingNews_news_evaluations.m*  
Its goal is to take the news evaluations by the judges, available in ```./data/stimuli```, and transform it to a usable table.

#### III. Create data tables
Go to the ```./scripts/processing``` folder

4. Open and run the *Receivingnews2_make_tables.m*
5. Open and run the *Receivingnews3_make_tables.m*

These two scripts will take the data saved in ```./data/intermediate``` and will create the tables for the analysis in ```./data/intermediate```  

6. Open and run *Receivingnews_brier_score.m*  
The .m file *Receivingnews_Brier.m* will be created in ```./data/brier_score```, with results on the subjects Brier score. This will be included in the table of all subjects behavior  

7. Open and run *ReceivingNews_maketable_allSubAllTrial.m*  
This will create a .m file with tables for all subjects, the allSubAllTrial table and will create a .csv for R analyses

8. Open and run *ReceivingNews_make_IRR.m*  
This will create a .m file with the InterRater Reliability table, for R analyses  
This will also output a table *ICC.csv* with mean data on news dimensions, for R analyses

### Data analysis
* Requirements: **R** and **MATLAB**

* Go at the root of the project: ```./receivingNews```  
**Open with R  the receivingNews R Project *receivingNews.Rproj***  

* In the project folder, make sure you have ran ```renv::restore()```. This should be prompted at the opening of the R Project.  
(The installed packages can be found in ```./scripts/src/packages/ReceivingNews_analysis_packages.R``` with the corresponding script).

* Navigate to ```./scripts/analysis```

#### IV. Run the power simulation used to determine the size of the second wave

9. Run *ReceivingNews2-power_simulation.R* on R.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews2-power_simulation_env.RData*  

#### V. Create the figures for the behavior

10. Open and run *ReceivingNews_Analyses_plots_article.m* on MATLAB to create plots for the articles  
This will output plots in ```./outputs/figures```.

#### VI. Run behavior analyses

The scripts below use a *ReceivingNews_analysis_utility.R* script, located in ```./scripts/src/utility```. That script take the processed data as a table and process it into a R data.frame for further analyses.

The Bayesian models take 3 models scripts, located in ```./scripts/src/models```.

11. Run *ReceivingNews-Stimuli_ICC.R* on R.  
This is intended to perform IntraClass Correlations on stimuli evaluations.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews-IRR_env.RData*

12. Run *ReceivingNews-Behavioral_measures.R* on R.  
This is intended to perform analyses on the behavior.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews2-Behavioral_measures_env.RData*  

13. Run *ReceivingNews-Bayesian_models.R* on R.  
This is intended to perform bayesian modelling on the behavior.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews-Bayesian_models_env.RData*

14. Run *ReceivingNews-Imprec_Polar_figures.R* on R.
This is intended to compute figures about the effect of Imprecision and Polarisation on Success, Judgment and Reception.
This will output figures in ```./outputs/figures```.

15. Run *ReceivingNews-Mixed_Linear_Models_main.R* on R.  
This is intended to perform Mixed Linear Modelling on our hypotheses about participants' behavior.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews-Mixed_Linear_Models_main_env.RData*

16. Run *ReceivingNews-Mixed_Linear_Models_alternatives.R* on R.  
This is intended to perform Mixed Linear Modelling on alternatives to our hypotheses about participants' behavior.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews-Mixed_Linear_Models_alternatives_env.RData*

17. Run *ReceivingNews-Bayesian_Mixed_Linear_Models.R* on R.  
This is intended to perform Bayesian Mixed Linear Modelling.  
This will output a R environment in ```./outputs/R_environment``` called *ReceivingNews-Bayesian_Mixed_Linear_Models_env.RData*

## Reporting / Figures creation

You can run scripts to obtain reports that include details on the analyses, additional analyses, tables and figure outputs. Those scripts will also generate the figures used in the article.  

To obtain a report, go to the folder ```./scripts/reporting```, open the notebook script corresponding to the intended analysis - or run the whole script - then click on the *knit* button. A ```.html``` report will be written in the folder.

* *ReceivingNews2-power_simulation-reporting.Rmd* is for power simulations. 
    
* *ReceivingNews-Stimuli_ICC-reporting.Rmd* is for IntraClass Correlations.

* *ReceivingNews-Behavioral_measures-reporting.Rmd* is for behavioral measures.

* *ReceivingNews-Bayesian_models-reporting.Rmd* is for Bayesian models of behavioral measures.

* *ReceivingNews-ReceivingNews-Imprec_Polar_figures-reporting.Rmd* is for figures of Imprecision and Polarisation on Success, Judgment and Reception.

* *ReceivingNews-MLM-reporting.Rmd* is for Mixed Linear Models.

* *ReceivingNews-Bayesian_MLM-reporting.Rmd* is for Bayesian Mixed Linear Models.

Move the reports to ```./outputs/reports```.