# Receivingnews

The receivingNews project investigates how individual estimate the truthfulness of true and false news, their metacognitive abilites in doing so, and the predictors of preferences for receiving supplementary information that may disambiguate the content of the news.

## Requirements

* Matlab 2020b minimum
* R 4.3.1
* R::renv
* JAGS 4.3.1
* Rtools 4.3
* R::rjags

## Installing and removing the environment

No MATLAB environment was created.

An environment for R was created via renv. It is specified across `renv.lock`, `.Rprofile`, `renv/settings.json` and `renv/activate.R`. To operate with the project renv, first open the R Project `receivingNews.Rproj`.

To restore the environment:
```
renv::init()
renv::restore()
```

To deactivate the environment:
```
renv::deactivate()
```
This removes the renv auto-loader from the project .Rprofile, but doesn’t touch any other renv files used in the project. 

To later re-activate the environment:
```
renv::activate()
```

To completely remove the environment:
```
renv::deactivate(clean = TRUE)
```

## Project Structure
This structure is adapted from the TIER protocol 4.0 (https://www.projecttier.org/tier-protocol/protocol-4-0/root/).
Each folder and subfolder has to have a descriptive and meaningful name, contains the files that are supposed to be in there, and a readme file documents the content of each.
```
receivingNews/
    ├── LICENSE
    ├── README.md          <- Top-level README for people using this project.
    ├── AUTHORS.md         <- Author information.
    |
    ├── setup.cfg          <- Triggers the setting up of the directory.
    ├── .gitattributes     <- Set-up the directory.
    ├── .gitignore         <- Set-up the directory and tells Git which files to ignore.
    ├── .gitkeep           <- Set-up the directory and tells Git to keep the folder when empty.
    |
    ├── ReceivingNews.prj  <- MATLAB project.
    ├── receivingNews.Rprj <- R project.
    |
    ├── .Rhistory          <- R history.
    ├── .Rprofile          <- R profile.
    |
    ├── renv.lock          <- Lock for R renv.
    |
    ├── data/
    |   ├── brier_score    <- Contains brier scores
    │   ├── raw            <- Data files initially obtained or constructed at the beginning of the project.
    |   ├── intermediate   <- Data created at some point in the processing of the data that need to be saved temporarily.
    │   ├── processed      <- Data cleaned and processed.
    │   ├── stimuli        <- Data on experiment stimuli.
    │   └── README.md      <- Information on data sources and retrieval. 
    |
    ├── matlab_toolboxes/  <- A place for 3rd party MATLAB toolboxes.
    │   ├── toolbox/
    │   └── get_toolbox.sh <- Script to download toolboxes.
    |   └── README.md      <- Information on toolboxes. 
    |
    ├── output/            <- Saved figures, tables and other outputs generated during analysis.
    |   ├── reports        <- Html reports on analyses, output from notebooks.
    │   ├── figures        <- Contains figures presented in the Journal Article.
    │   └── README.md      <- Information on data outputs and about scripts that produce them. 
    |
    ├── R_environments     <- Contains R environments, output by .R files and input of .Rmd files.
    |
    ├── renv/              <- R renv to restore a snapshot of R environment containing installed packages with versioning. Executed by R `renv::activate()`
    │   ├── activate.R
    │   ├── settings.json
    │   └── README.md      <- Information on the snapshot of libraries. 
    |
    ├── resources/project/ <- Contains the MATLAB project
    │   └── ...      
    │
    ├── scripts/           <- Jupyter notebooks, MATLAB code and anything else that constitutes analysis.
    │   ├── analysis       <- Scripts that produce the results, such as figures, tables and statistics.
    │   ├── extraction     <- Preprocessing scripts that extract data from raw files for processing.
    │   ├── processing     <- Scripts that transform extracted data files into processed data files.
    │   ├── reporting      <- Scripts that produce the reports on the results.
    │   ├── run_scripts    <- Scripts that run the whole reproducibility pipeline
    │   ├── src            <- Source scripts used across scripts, such as models, utilities, packages.
    │   ├── supplementary  <- Scripts that produce the results present in the Supplementary Materials.
    │   ├── README.md      <- Any information about the analysis, such as execution order. 
    │   |
    │   ├── *.py           <- Master script in Python that reproduces the Results of your project by executing all the other scripts, in the correct order.
    │   ├── *.m            <- Master script in MATLAB that reproduces the Results of your project by executing all the other scripts, in the correct order.
    │   └── *.r            <- Master script in in R that reproduces the Results of your project by executing all the other scripts, in the correct order.
    │
    ├── stimuli/           <- Contains the stimuli
    │   └── ...
    ├── venv/              <- Python virtual environment
    |
    
 ```

 ## Project recovery
Requirements: R and MATLAB

To automatically recover the project, follow the steps below:
1. Go to the ./scripts/run_scripts
2. Execute ReceivingNews_1_Run_Matlab_scripts.m This will run steps 1 to 8 and step 10
3. Execute ReceivingNews_2_Run_R_scripts.m This will run steps 9 to 16 as well as the .Rmd scripts, except step 10

To manually recover the project, follow the instructions inside the **README.md** located at `/scripts`.

