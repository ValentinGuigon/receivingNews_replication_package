%%%%% Run automatically all scripts

proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File;

%% Data extraction
addpath(strcat(project_root,"/scripts/extraction"))

proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); Receivingnews2_extract_subject
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); Receivingnews3_extract_subject
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); ReceivingNews_news_evaluations

%% Data processing
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; addpath(strcat(project_root,"/scripts/processing"))

proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); Receivingnews2_make_tables
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); Receivingnews3_make_tables
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); Receivingnews_brier_score
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); ReceivingNews_maketable_allSubAllTrial
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); ReceivingNews_make_IRR

%% Figures
proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; addpath(strcat(project_root,"/scripts/analysis"))

proj = matlab.project.rootProject; project_root = proj.ProjectPath(1,1).File; cd(project_root); ReceivingNews_Analyses_plots_article