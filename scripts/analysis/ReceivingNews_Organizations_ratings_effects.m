clear;
clc;

% Define the variable to analyze
% Set the variable to analyze at the beginning of the script
analyze_variable = 'eval_success'; % Change 'reception' to any other variable you want to analyze

% Set up the paths and load data
project_root = strrep(pwd(), '\', '/');
cd(strcat(project_root, '/data/intermediate'));

% Load behavior data
load('Receivingnews2_extracted.mat');
load('Receivingnews3_extracted.mat');

% Initialize parameters
nbs2 = 80; % Number of subjects in Receivingnews2
nbs3 = 180; % Number of subjects in Receivingnews3
nbo = 12; % Number of organizations
nbstim = 48; % Number of stimuli

% Liste des noms des organisations
org_names_list = {'SOS Mediterranee', 'FEMEN', 'Generation Identitaire', 'La Manif Pour Tous', ...
                  'Greenpeace', 'WWF', 'NIPCC', 'Climato-realistes', 'Mouvement Europeen France', ...
                  'Fondation Robert Schuman', 'Frexit', 'Parti Libertarien'};

% Initialiser une structure pour les tables d'organisations
organizationTables = cell(nbo, 1); % 12 tables pour 12 organisations

% Boucle sur chaque organisation pour Receivingnews2
for j = 1:nbo
    org_name = org_names_list{j};  % Nom de l'organisation
    
    % Initialiser une table vide pour cette organisation
    orgTable = table();
    
    % Boucle sur chaque sujet dans Receivingnews2
    for i = 1:nbs2
        % Extraire les données pour ce sujet
        subject_data = Receivingnews2(i);
        subject_data.news.veracity_judgment = double(strcmp(subject_data.news.veracity_judgment, 'VRAIE'));
        
        % Extraire les réponses de ce sujet
        subject_responses = subject_data.news;
        
        % Extraire les évaluations de l'organisation
        org_ratings = subject_data.organizations;
        org_subset = org_ratings(strcmp(org_ratings.organization, org_name), :);
        
        % Vérifier que les données pour l'organisation existent
        if ~isempty(org_subset) && height(org_subset) == 1
            % Répéter les évaluations pour chaque réponse (48 lignes)
            repeated_ratings = repmat(table2array(org_subset(:, 5:end)), nbstim, 1);
            
            % Répéter les valeurs de réception pour chaque réponse
            if strcmp(analyze_variable, 'reception') || strcmp(analyze_variable, 'eval_success')
                repeated_responses = cell2mat(subject_responses.(analyze_variable)) - 1;
            else
                repeated_responses = cell2mat(subject_responses.(analyze_variable));
            end      
            
            % Créer la table pour ce sujet
            subjectTable = table(repeated_responses, repeated_ratings(:, 1), repeated_ratings(:, 2), ...
                                 repeated_ratings(:, 3), repeated_ratings(:, 4), ...
                                 repeated_ratings(:, 5), repeated_ratings(:, 6), repeated_ratings(:, 7),...
                                 'VariableNames', {'response', 'Q1_familiarity_self', 'Q2_valuecloseness_self', ...
                                 'Q3_likeness_self', 'Q4_familiarity_relatives', 'Q5_valuecloseness_relatives', 'Q6_likeness_relatives', 'social_dist'});
            
            % Ajouter les données de ce sujet à la table d'organisation
            orgTable = [orgTable; subjectTable];
        else
            error('No data found or more than one row for organization %s in subject %d.', org_name, i);
        end
    end
    
    % Boucle sur chaque sujet dans Receivingnews3
    for i = 1:nbs3
        % Extraire les données pour ce sujet
        subject_data = Receivingnews3(i);
        subject_data.news.veracity_judgment = double(strcmp(subject_data.news.veracity_judgment, 'VRAIE'));
        
        % Extraire les réponses de ce sujet
        subject_responses = subject_data.news;
        
        % Extraire les évaluations de l'organisation
        org_ratings = subject_data.organizations;
        org_subset = org_ratings(strcmp(org_ratings.organization, org_name), :);
        
        % Vérifier que les données pour l'organisation existent
        if ~isempty(org_subset) && height(org_subset) == 1
            % Répéter les évaluations pour chaque réponse (48 lignes)
            repeated_ratings = repmat(table2array(org_subset(:, 5:end)), nbstim, 1);
            
            % Répéter les valeurs de réception pour chaque réponse
            if strcmp(analyze_variable, 'reception')
                repeated_responses = subject_responses.(analyze_variable) - 1;
            else
                repeated_responses = subject_responses.(analyze_variable);
            end
            
            % Créer la table pour ce sujet
            subjectTable = table(repeated_responses, repeated_ratings(:, 1), repeated_ratings(:, 2), ...
                                 repeated_ratings(:, 3), repeated_ratings(:, 4), ...
                                 repeated_ratings(:, 5), repeated_ratings(:, 6), repeated_ratings(:, 7),...
                                 'VariableNames', {'response', 'Q1_familiarity_self', 'Q2_valuecloseness_self', ...
                                 'Q3_likeness_self', 'Q4_familiarity_relatives', 'Q5_valuecloseness_relatives', 'Q6_likeness_relatives', 'social_dist'});
            
            % Ajouter les données de ce sujet à la table d'organisation
            orgTable = [orgTable; subjectTable];
        else
            error('No data found or more than one row for organization %s in subject %d.', org_name, i);
        end
    end
    
    % Stocker la table de l'organisation dans la structure
    organizationTables{j} = orgTable;
end

% Modèles linéaires et calcul des AIC
aic_results = struct();

for j = 1:nbo
    orgTable = organizationTables{j};
    
    % Modèle linéaire pour les variables Q1 à Q6
    X_Q1_to_Q6 = orgTable{:, 2:7}; % Variables indépendantes (Q1 à Q6)
    y = orgTable.response; % Variable dépendante (reception)
    mdl_Q1_to_Q6 = fitglm(X_Q1_to_Q6, y, 'Distribution', 'binomial', 'Link', 'logit');
    
    % Extraire les coefficients et les p-values
    coeff_Q1_to_Q6 = mdl_Q1_to_Q6.Coefficients.Estimate;
    pval_Q1_to_Q6 = mdl_Q1_to_Q6.Coefficients.pValue;
    
    aic_results(j).model_Q1_to_Q6 = mdl_Q1_to_Q6;
    aic_results(j).AIC_Q1_to_Q6 = mdl_Q1_to_Q6.ModelCriterion.AIC;
    aic_results(j).coeff_Q1_to_Q6 = coeff_Q1_to_Q6;
    aic_results(j).pval_Q1_to_Q6 = pval_Q1_to_Q6;
    
    % Modèle linéaire pour social_dist
    X_social_dist = orgTable{:, 8}; % social_dist est la dernière colonne
    mdl_social_dist = fitglm(X_social_dist, y, 'Distribution', 'binomial', 'Link', 'logit');
    
    % Extraire les coefficients et les p-values
    coeff_social_dist = mdl_social_dist.Coefficients.Estimate;
    pval_social_dist = mdl_social_dist.Coefficients.pValue;
    
    aic_results(j).model_social_dist = mdl_social_dist;
    aic_results(j).AIC_social_dist = mdl_social_dist.ModelCriterion.AIC;
    aic_results(j).coeff_social_dist = coeff_social_dist;
    aic_results(j).pval_social_dist = pval_social_dist;
end

% Liste des noms des variables Q1 à Q6 et social_dist
Q_names = {'Q1_familiarity_self', 'Q2_valuecloseness_self', 'Q3_likeness_self', ...
           'Q4_familiarity_relatives', 'Q5_valuecloseness_relatives', 'Q6_likeness_relatives', 'social_dist'};

% Initialiser une table vide pour les p-values
ranked_pvalues = table('Size', [nbo, 1 + length(Q_names)], ...
    'VariableTypes', ["string", repmat("double", 1, length(Q_names))], ...
    'VariableNames', ['Organization', Q_names]);

for j = 1:nbo
    % Nom de l'organisation
    org_name = org_names_list{j};
    
    % Extraire les p-values pour les variables Q1 à Q6 et social_dist
    pval_Q1_to_Q6 = aic_results(j).pval_Q1_to_Q6;
    pval_social_dist = aic_results(j).pval_social_dist;
    
    % Remplir les p-values dans la table
    ranked_pvalues.Organization{j} = org_name;
    ranked_pvalues.Q1_familiarity_self(j) = pval_Q1_to_Q6(2); % P-value pour Q1
    ranked_pvalues.Q2_valuecloseness_self(j) = pval_Q1_to_Q6(3); % P-value pour Q2
    ranked_pvalues.Q3_likeness_self(j) = pval_Q1_to_Q6(4); % P-value pour Q3
    ranked_pvalues.Q4_familiarity_relatives(j) = pval_Q1_to_Q6(5); % P-value pour Q4
    ranked_pvalues.Q5_valuecloseness_relatives(j) = pval_Q1_to_Q6(6); % P-value pour Q5
    ranked_pvalues.Q6_likeness_relatives(j) = pval_Q1_to_Q6(7); % P-value pour Q6
    ranked_pvalues.social_dist(j) = pval_social_dist(2); % P-value pour social_dist
end

% Imprimer le classement des p-values avec toutes les décimales
fprintf('Ranking of p-values for each organization:\n');
for j = 1:nbo
    org_name = ranked_pvalues.Organization{j};
    pvals = table2array(ranked_pvalues(j, 2:end));
    [sorted_pvals, sort_idx] = sort(pvals);
    
    fprintf('\nOrganization: %s\n', org_name);
    fprintf('Rank\tVariable\tP-value\n');
    for k = 1:length(sorted_pvals)
        fprintf('%d\t%s\t%g\n', k, Q_names{sort_idx(k)}, sorted_pvals(k));
    end
end

% Initialize a score array for all variables
ranking_scores = zeros(1, length(Q_names));

% Loop through each organization and compute the ranks
for j = 1:nbo
    org_name = ranked_pvalues.Organization{j};
    pvals = table2array(ranked_pvalues(j, 2:end));
    
    % Sort p-values and get the ranking indices
    [sorted_pvals, sort_idx] = sort(pvals);
    
    % Assign scores inversely proportional to the rank if p-value >= 0.05
    for k = 1:length(sort_idx)
        if sorted_pvals(k) >= 0.05
            ranking_scores(sort_idx(k)) = ranking_scores(sort_idx(k)) + (length(sort_idx) - k + 1);
        else
            % If p-value < 0.05, assign a score of 0
            ranking_scores(sort_idx(k)) = ranking_scores(sort_idx(k)) + 0;
        end
    end
end

% Compute the average score across organizations
average_ranking_scores = ranking_scores / nbo;

% Display the ranking scores
fprintf('\nAverage Ranking Scores for Each Variable:\n');
for i = 1:length(Q_names)
    fprintf('%s: %.4f\n', Q_names{i}, average_ranking_scores(i));
end

% Initialize a table to store the best model for each organization
best_models = table('Size', [nbo, 3], ...
    'VariableTypes', ["string", "string", "double"], ...
    'VariableNames', {'Organization', 'Best_Model', 'Best_AIC'});

for j = 1:nbo
    % Nom de l'organisation
    org_name = org_names_list{j};
    
    % Extraire les AIC pour les modèles Q1 à Q6 et social_dist
    aic_Q1_to_Q6 = aic_results(j).AIC_Q1_to_Q6;
    aic_social_dist = aic_results(j).AIC_social_dist;
    
    % Déterminer le meilleur modèle
    if aic_Q1_to_Q6 < aic_social_dist
        best_models.Organization{j} = org_name;
        best_models.Best_Model{j} = 'Q1_to_Q6';
        best_models.Best_AIC(j) = aic_Q1_to_Q6;
    else
        best_models.Organization{j} = org_name;
        best_models.Best_Model{j} = 'social_dist';
        best_models.Best_AIC(j) = aic_social_dist;
    end
end

% Afficher les meilleurs modèles
fprintf('Best Model for Each Organization:\n');
for j = 1:nbo
    fprintf('\nOrganization: %s\n', best_models.Organization{j});
    fprintf('Best Model: %s (AIC: %.4f)\n', best_models.Best_Model{j}, best_models.Best_AIC(j));
end

% Initialize counters
count_Q1_to_Q6 = 0;
count_social_dist = 0;

% Count the number of times each model is the best
for j = 1:nbo
    if strcmp(best_models.Best_Model{j}, 'Q1_to_Q6')
        count_Q1_to_Q6 = count_Q1_to_Q6 + 1;
    else
        count_social_dist = count_social_dist + 1;
    end
end

% Display the counts
fprintf('Number of times Q1 to Q6 is the best model: %d\n', count_Q1_to_Q6);
fprintf('Number of times social_dist is the best model: %d\n', count_social_dist);
