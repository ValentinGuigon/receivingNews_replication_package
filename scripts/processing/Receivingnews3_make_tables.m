clear
clc

%% Personal note: 'format bank' was used for sake of display. Remember to go back to 'format short'

%% VARIABLES AND LOAD BEHAVIOR

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/intermediate'));

% Load behavior
load Receivingnews3_extracted.mat;

nbs = height(allSubjects3); %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli

%% LOAD STIMULI AND STIMULI EVALUATIONS
cd(strcat(project_root,'/data/stimuli'));

% Load all Theme names
[~, ~, raw] = xlsread(strcat(project_root, '/stimuli/Stimuli_list.xlsx'),'Feuil1','F1:F96');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1); Theme = cellVectors(:,1);
clearvars raw cellVectors tmp;

% Load news evaluations
load News_evaluations


%% TABLES PREPARATION %%%%%%%
data_type = {'idnews','veracity','eval','eval_RT','eval_success','reception','rec_RT','rec_WTP','rec_WTP_RT'}';

for i = 1:9 % group_data for each Dependent Variables for each group
    data_tables3(i).type = data_type(i);
    
    %% Tables for group 1 and 2
    g1 = allSubjects3(allSubjects3.group==1,15+i-1:9:446);
    g2 = allSubjects3(allSubjects3.group==2,15+i-1:9:446);
            
    if i == 4 || i == 7 || i == 9 % Transform RT miliseconds data to RT seconds data 
        g1{:,:} = g1{:,:}/1000; g2{:,:} = g2{:,:}/1000;        
    end
    if i == 6 % Change reception binary data (from (1 or 2 in original table) to (1 or 0))
        for j = 1:nbstim
            g1(g1{:,j}==2,j) = num2cell(0);
            g2(g2{:,j}==2,j) = num2cell(0);
        end
    end
    clear j
    
    if i == 3 % For bidirectionnal data (eval)
        for j = 1:height(g1)
            arrayg1 = table2array(g1(j,1:nbstim));
            arrayg1pos = arrayg1(arrayg1(1,1:nbstim)>0);
            arrayg1neg = arrayg1(arrayg1(1,1:nbstim)<0);
            g1(j,49) = num2cell(mean(arrayg1pos)); % mean of positive evaluations
            g1(j,50) = num2cell(std(arrayg1pos)); % sd of positive evaluations
            g1(j,51) = num2cell(length(arrayg1pos)); % count of positive evaluations
            
            g1(j,52) = num2cell(mean(arrayg1neg)); % mean of negative evaluations
            g1(j,53) = num2cell(std(arrayg1neg)); % sd of neative evaluations
            g1(j,54) = num2cell(length(arrayg1neg)); % count of negative evaluations
        end
        g1.Properties.VariableNames([49:54]) = {'mean_pos','sd_pos','count_pos','mean_neg','sd_neg','count_neg'};
        clear j
        
        for j = 1:height(g2)
            arrayg1 = table2array(g2(j,1:nbstim));
            arrayg1pos = arrayg1(arrayg1(1,1:nbstim)>0);
            arrayg1neg = arrayg1(arrayg1(1,1:nbstim)<0);
            g2(j,49) = num2cell(mean(arrayg1pos)); % mean of positive evaluations
            g2(j,50) = num2cell(std(arrayg1pos)); % sd of positive evaluations
            g2(j,51) = num2cell(length(arrayg1pos)); % count of positive evaluations
            
            g2(j,52) = num2cell(mean(arrayg1neg)); % mean of negative evaluations
            g2(j,53) = num2cell(std(arrayg1neg)); % sd of neative evaluations
            g2(j,54) = num2cell(length(arrayg1neg)); % count of negative evaluations
        end
        g2.Properties.VariableNames([49:54]) = {'mean_pos','sd_pos','count_pos','mean_neg','sd_neg','count_neg'};
        clear j
        
    elseif i == 5 | i == 6 % For binomial data (success & rec)
        
        for j = 1:height(g1)
            tblv = array2table(tabulate(g1{j,1:nbstim}));
            g1(j,49) = tblv(1,2); % count
            g1(j,50) = tblv(1,3); % percent
            if size(tblv,1) == 1 % If only zeros and no desirability
                g1(j,51) = num2cell(0); % count
                g1(j,52) = num2cell(0); % percent
            else
                g1(j,51) = tblv(2,2); % count
                g1(j,52) = tblv(2,3); % percent
            end
        end
        g1.Properties.VariableNames([49,51]) = {'nb_0','nb_1'}; g1.Properties.VariableNames([50,52]) = {'freq_0','freq_1'};
        clear j
        
        for j = 1:height(g2)
            tblv = array2table(tabulate(g2{j,1:nbstim}));
            g2(j,49) = tblv(1,2); % count
            g2(j,50) = tblv(1,3); % percent
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                g2(j,51) = num2cell(0); % count
                g2(j,52) = num2cell(0); % percent
            else
                g2(j,51) = tblv(2,2); % count
                g2(j,52) = tblv(2,3); % percent
            end
        end
        g2.Properties.VariableNames([49,51]) = {'nb_0','nb_1'}; g2.Properties.VariableNames([50,52]) = {'freq_0','freq_1'};
        clear j
        
    elseif i == 4 || i == 7 || i == 8 || i == 9 % For continuous data(eval_RT, rec_RT, WTP, WTP_RT)
        for j = 1:height(g1)
            arrayg1 = table2array(g1(j,1:nbstim));
            g1(j,49) = num2cell(mean(arrayg1)); % mean of RT
            g1(j,50) = num2cell(std(arrayg1)); % sd of RT
        end
        if i == 8
            g1.Properties.VariableNames([49:50]) = {'mean_WTP','sd_WTP'};
        else
            g1.Properties.VariableNames([49:50]) = {'mean_RT','sd_RT'};
        end
        clear j
        
        for j = 1:height(g2)
            arrayg1 = table2array(g2(j,1:nbstim));
            g2(j,49) = num2cell(mean(arrayg1)); % mean of positive evaluations
            g2(j,50) = num2cell(std(arrayg1)); % sd of positive evaluations
        end
        if i == 8
            g2.Properties.VariableNames([49:50]) = {'mean_WTP','sd_WTP'};
        else
            g2.Properties.VariableNames([49:50]) = {'mean_RT','sd_RT'};
        end
        clear j
    end
    
    clear tblv
    group_data3(i).type = data_type(i);
    group_data3(i).group1 = g1;
    group_data3(i).group2 = g2;
end

%% Errors because complete mean, sd and count columns with zeros for participants not yet passed in the loop

%% OUTLIERS: cheaters detection (For success rates, outlier based on number of successes compared to others)

% For success rates: G1
out1 = table2array(group_data3(5).group1(1:end,52)); % TF: 1 if subject = outlier; B = table without outlier
[B1,TF1] = rmoutliers(out1); sum(TF1); %5 outliers
id_out1 = cat(2,out1,TF1);
group_data3(5).group1(:,53) = array2table(TF1);
group_data3(5).group1.Properties.VariableNames([53]) = {'outlier'};

% For success rates: G2
out2 = table2array(group_data3(5).group2(1:end,52));
[B2,TF2] = rmoutliers(out2); sum(TF2); %0 outliers
id_out2 = cat(2,out2,TF2);
group_data3(5).group2(:,53) = array2table(TF2);
group_data3(5).group2.Properties.VariableNames([53]) = {'outlier'};


clear out1 out2 B1 B2 TF1 TF2 id_out1 id_out2

% For evaluation RT: G1
out1 = table2array(group_data3(4).group1(1:end,49));
[B1,TF1] = rmoutliers(out1); sum(TF1); %8 outliers
id_out1 = cat(2,out1,TF1);
group_data3(4).group1(:,51) = array2table(TF1);
group_data3(4).group1.Properties.VariableNames([51]) = {'outlier'};

group_data3(5).group1(group_data3(4).group1{:,51} ==1, 52); 
group_data3(4).group1(group_data3(5).group1{:,53} ==1, 49); 
% conclusion:: RT: subject22: 11.175 ; subject28: 27.544  ; subject51: 5.1748 ; subject121: 1.9299 ; subject174: 13.803 
group_data3(4).group1(group_data3(5).group1{:,53} ==1 & group_data3(4).group1{:,51} ==1, 49); 
group_data3(5).group1(group_data3(5).group1{:,53} ==1 & group_data3(4).group1{:,51} ==1, 52); 
% only subject28 comes at the intersect 
% but it is not superior or inferior to mean +/- 2*SD that would be 15.17 +2*(10.14) = >35.45 or <5.11
% BUT subject121 has very very low mean RTs: 1.9299 +/- 1.3117 seconds

% For evaluation RT: G2
out2 = table2array(group_data3(4).group2(1:end,49));
[B2,TF2] = rmoutliers(out2); sum(TF2); %5 outliers
id_out2 = cat(2,out2,TF2);
group_data3(4).group2(:,51) = array2table(TF2);
group_data3(4).group2.Properties.VariableNames([51]) = {'outlier'};

group_data3(5).group2(group_data3(4).group2{:,51} ==1, 52); 
group_data3(4).group2(group_data3(5).group2{:,53} ==1, 49); 
% conclusion:: RT: irrelevant ; % no intersect


% conclusion: we get subject121 out of the results
for i = 1:9
    group_data3(i).group1(63,:) = [];
end
allSubjects3(121,:) = [];
Receivingnews3(121) = [];
nbs=nbs-1;


%% Models Tables

clear arrayg1 arrayg1neg arrayg1pos B B1 B2 g1 g2 i out out1 out2 TF TF1 TF2 id_out1 id_out2

for i = 1:9 % data_tables3 for each Dependent Variables for all subjects
    tempg1 = group_data3(i).group1; % pb ici
    for j =1:nbstim
        varNamesg1(j) = strcat(Theme(j), '_', num2str(j));
    end
    clear j
    % Nb is different from stimuli reference. For fusion of both g1 and g2 tables
    tempg1.Properties.VariableNames([1:nbstim]) = varNamesg1(1:nbstim);
    
    tempg2 = group_data3(i).group2;
    for j =49:96
        varNamesg2(j) = strcat(Theme(j), '_', num2str(j));
    end
    clear j
    tempg2.Properties.VariableNames([1:nbstim]) = varNamesg2(49:96);
    
    % Sorting tables by columns (by stimuli)
    modelsg1 = tempg1(:,sort(tempg1.Properties.VariableNames)); modelsg2 = tempg2(:,sort(tempg2.Properties.VariableNames));
    sortedNames = modelsg1.Properties.VariableNames; sortedNames = char(sortedNames);
    
    if i < 3
        for j =1:nbstim
            varNames(j) = cellstr(strcat(sortedNames(j,1:5), num2str(j))); 
        end
    end
    
    if i > 2
        % Fusion tables
        tempg(:,1:3) = array2table(zeros(nbs,3), 'variableNames', {'scoreDemo', 'scoreEcol', 'scoreJust'});
        tempg(:,4:16) = allSubjects3(:,2:14); tempg(:,17:27) = allSubjects3(:,447:457);
        colNames(1:3) = {'scoreDemo', 'scoreEcol', 'scoreJust'};
        colNames(4:16) = allSubjects3(1,2:14).Properties.VariableNames; colNames(17:27) = allSubjects3(1,447:457).Properties.VariableNames;
        rowNames = allSubjects3(:,1).Properties.RowNames;
        tempg.Properties.VariableNames = colNames; tempg.Properties.RowNames = rowNames;
        modelsg1 = innerjoin(modelsg1, tempg, 'Keys', 'Row'); modelsg2 = innerjoin(modelsg2, tempg, 'Keys', 'Row');
        for j =1:nbstim
            varNames(j) = strcat(cellstr('y'), num2str(j));
        end
    end
    clear j
    
    % Models, g = group
    tempg1 = modelsg1; tempg1.Properties.VariableNames(1:nbstim) = varNames;
    tempg2 = modelsg2; tempg2.Properties.VariableNames(1:nbstim) = varNames;
    models = vertcat(tempg1, tempg2);
    
    data_tables3(i).models = models;
    clear modelsg1 modelsg2 tempg tempg1 tempg2
    
    
    %% Within subjects tables preparation
    
    condition=zeros(nbstim,1);
    condition(1:16,1)=2; condition(17:32,1)=1; condition(33:nbstim,1)=3;
    condition=table(condition);
    trial=zeros(nbstim,1);
    trial(1:16,1) = 1:16; trial(17:32,1) = 1:16; trial(33:nbstim,1) = 1:16;
    trial=table(trial);
    within = [condition trial];
    within.condition = categorical(within.condition); within.trial = categorical(within.trial);
    data_tables3(i).within = within;
    % Can't put veracity because we merged group1 and group2 data.
    % Therefore, in the table, there are 48 trials to avoid accounting for group, but Truth value for trial 1 group 1 is not equal to Truth value for trial & group 2
    
    
    %% Completing tables for mean/tabulate for each theme
    m=53; % Ref for first row to fill results for each stim type
    
    if i == 3
        % Score = mean
        m=m+2;
        data_tables3(i).models(:,61:84) = data_tables3(i).models(:,58:81); data_tables3(i).models(:,58:60) = array2table(zeros(nbs,3));
        varNames = data_tables3(3).models.Properties.VariableNames;
        data_tables3(i).models.Properties.VariableNames(55:60) = {'scoreDemoPos','scoreDemoNeg','scoreEcolPos','scoreEcolNeg','scoreJustPos','scoreJustNeg'};
        data_tables3(3).models.Properties.VariableNames(:,61:84) = varNames(1,58:81);
        for k = 1:height(data_tables3(i).models)
            arpos = table2array(data_tables3(i).models(k,1:16));
            arpos = arpos(arpos(1,1:16)>0); % Subject 4: scoreDemoPos: NA because only reported negative values
            data_tables3(i).models(k,m) = array2table(mean(arpos));
            arneg = table2array(data_tables3(i).models(k,1:16));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables3(i).models(k,m+1) = array2table(mean(arneg));            
            
            arpos = table2array(data_tables3(i).models(k,17:32));
            arpos = arpos(arpos(1,1:16)>0);
            data_tables3(i).models(k,m+2) = array2table(mean(arpos));
            arneg = table2array(data_tables3(i).models(k,17:32));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables3(i).models(k,m+3) = array2table(mean(arneg));            
            
            arpos = table2array(data_tables3(i).models(k,33:nbstim));
            arpos = arpos(arpos(1,1:16)>0);
            data_tables3(i).models(k,m+4) = array2table(mean(arpos));
            arneg = table2array(data_tables3(i).models(k,33:nbstim));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables3(i).models(k,m+5) = array2table(mean(arneg));
        end
        
    elseif i == 5 || i == 6
        if i == 5         m = m+1;
        end
        for k = 1:height(data_tables3(i).models)
            tblv = array2table(tabulate(data_tables3(i).models{k,1:16}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables3(i).models(k,m) = num2cell(0);
            else
                data_tables3(i).models(k,m) = tblv(2,3);
            end
            
            tblv = array2table(tabulate(data_tables3(i).models{k,17:32}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables3(i).models(k,m+1) = num2cell(0);
            else
                data_tables3(i).models(k,m+1) = tblv(2,3);
            end
            
            tblv = array2table(tabulate(data_tables3(i).models{k,33:nbstim}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables3(i).models(k,m+2) = num2cell(0);
            else
                data_tables3(i).models(k,m+2) = tblv(2,3);
            end
        end
        
        
    elseif i == 4 || i == 7 || i == 8 || i == 9
        if i == 4
            m = m-1;
        elseif i == 7 || i == 8 || i == 9
            m = m-2;
        end
        for k = 1:height(data_tables3(i).models)
            ar = data_tables3(i).models{k,1:16};
            data_tables3(i).models(k,m) = array2table(mean(ar));
            
            ar = data_tables3(i).models{k,17:32};
            data_tables3(i).models(k,m+1) = array2table(mean(ar));
            
            ar = data_tables3(i).models{k,33:nbstim};
            data_tables3(i).models(k,m+2) = array2table(mean(ar));
        end
    end
    
    %% Between subjects tables = models
    clear tempg tempg1 tempg2 colNames rowNames varNames
end


%% allSub3AllTrial

indD= find(strcmp(Theme, 'Demo')); indE= find(strcmp(Theme, 'Ecol')); indJ= find(strcmp(Theme, 'Just'));
Themes(indE,1) = 1; Themes(indD,1) = 2; Themes(indJ,1) = 3; % ecol= 1 démo = 2 just = 3
m = 1;

for i = 1:nbs % allSub3AllTrial for each stim for each subject
    allSub3AllTrial(m:m+47,1) = i; % subject n°
    allSub3AllTrial(m:m+47,2) = Receivingnews3(i).info.subjectGroup; % Subject group n°
    if Receivingnews3(i).info.subjectGroup == 1 % group 1 theme for each stim
        allSub3AllTrial(m:m+47,3) = Themes(1:nbstim,1); % Themes is in idnews order, and data in Receivingnews3 is order par idstim
    else % group 2 theme for each stiù
        allSub3AllTrial(m:m+47,3) = Themes(49:96,1);
    end
    
    allSub3AllTrial(m:m+47,4) = Receivingnews3(i).news{:,2}; % idnews
    allSub3AllTrial(m:m+47,5:10) = (Receivingnews3(i).news{:,3:8}); % evaluation, evaluationRT, reception, receptionRT, WTP, WTPRT
    indV= find(strcmp(Receivingnews3(i).news{:,9}, 'VRAIE')); indF= find(strcmp(Receivingnews3(i).news{:,9}, 'FAUSSE')); 
    allSub3AllTrial(indV+m-1,11) = 1; allSub3AllTrial(indF+m-1,11) = 0; % Veracity judgment produced
    clear indV indF; indV= find(strcmp(Receivingnews3(i).news{:,10}, 'VRAIE')); indF= find(strcmp(Receivingnews3(i).news{:,10}, 'FAUSSE')); 
    allSub3AllTrial(indV+m-1,12) = 1; allSub3AllTrial(indF+m-1,12) = 0; % True Veracity
    allSub3AllTrial(m:m+47,13) = (Receivingnews3(i).news{:,11}); % Veracity judgment success
    
    for j = 1:14
        allSub3AllTrial(m:m+47,13+j:25) = table2array(allSubjects3(i,2+j)); % Organizations data
    end
    for j = 1:nbstim
        allSub3AllTrial(m+j-1,26:36) = table2array(allSubjects3(i,447:457));
    end
    m=m+48;
end

allSub3AllTrial = array2table(allSub3AllTrial); 
allSub3AllTrial.Properties.VariableNames(1:13) = {'subject','group','theme','idnews','eval','eval_RT','rec','rec_RT','WTP','WTP_RT','judgment','veracity','success'};
allSub3AllTrial.Properties.VariableNames(14:36) = data_tables3(3).models.Properties.VariableNames(62:84);

% Fixing some things happening with the judgment == 0/1
allSub3AllTrial(allSub3AllTrial{:,5} > 0,11) = array2table(1); allSub3AllTrial(allSub3AllTrial{:,5} < 0,11) = array2table(0);


%% ICC table
stims(1:48,2) = table2array(group_data3(1).group1(1,1:48))'; stims(1:48,1) = 1; stims(1:48,3) = table2array(group_data3(2).group1(1,1:48))'; stims(1:48,4) = table2array(allSub3AllTrial(97:144,4));
stims(49:96,2) = table2array(group_data3(1).group2(1,1:48))'; stims(49:96,1) = 2; stims(49:96,3) = table2array(group_data3(2).group2(1,1:48))'; stims(49:96,4) = table2array(allSub3AllTrial(1:48,4));
m=1;
for ii = 1:5
    temp(m:m+41,1) = IRR(ii).stims(1:42,1);     temp(m:m+41,2) = IRR(ii).ambiguity(1:42,width(IRR(ii).matrices(1,:)));     temp(m:m+41,3) = IRR(ii).split(1:42,width(IRR(ii).matrices(1,:)));     temp(m:m+41,4) = IRR(ii).desirability(1:42,width(IRR(ii).matrices(1,:)));
    m=m+42;
end
stims = array2table(stims); stims.Properties.VariableNames = {'group','idnews','veracity','theme'}; temp = array2table(temp); temp.Properties.VariableNames = {'idnews','ambiguity','split','desirability'};
ICC = join(stims, temp); clear stims temp ii m 


%Complete allSub3AllTrial with ICC
m = 1;
for i = 1:nbs
    if allSub3AllTrial{m:m+47,2} == 1 % ICC values
        allSub3AllTrial(m:m+47,37:39) = ICC(1:48,5:7); 
    elseif allSub3AllTrial{m:m+47,2} == 2
        allSub3AllTrial(m:m+47,37:39) = ICC(49:96,5:7); 
    end
    m=m+48;
end
allSub3AllTrial.Properties.VariableNames(37:39) = {'ambiguity','split','desirability'};
allSub3AllTrial = allSub3AllTrial(:,{'subject' 'group' 'idnews' 'theme' 'veracity' 'eval' 'eval_RT' 'judgment' 'success' 'rec' 'rec_RT' 'WTP' 'WTP_RT' 'ambiguity' 'split' 'desirability' 'SOS_Mediterranee' 'FEMEN' 'Generation_Identitaire' 'La_Manif_Pour_Tous' 'Greenpeace' 'WWF' 'NIPCC' 'Climato_realistes' 'Mouvement_Europeen_France' 'Fondation_Robert_Schuman' 'Frexit' 'Parti_Libertarien' 'age' 'sex' 'education' 'EC' 'prcnt_politique' 'prcnt_journaliste' 'prcnt_medecin' 'prcnt_acteurjustsoc' 'prcnt_chercheur' 'prcnt_acteurecologie' 'prcnt_general'});

%Add a "year of experiment" column
allSub3AllTrial(:,40) = array2table(2);
allSub3AllTrial.Properties.VariableNames(40) = {'year'};

%% allSub3MeanTrial (for Themes * True and False data)

% Filters
clear temp ans ar arneg arpos i indE indE indF indJ indV j k m sortedNames varNamesg1 varNamesg2
temp = table2array(allSub3AllTrial);
subject=temp(:,1);
group=temp(:,2);
theme=temp(:,4);
veracity=temp(:,5); 
judgment=temp(:,8);


% Dependent variables
eval=temp(:,6); % bidirectional (>-100 | <+100)
evalrt=temp(:,7); % continuous 
success=temp(:,9); % binary
rec=temp(:,10); % binary
recrt=temp(:,11); % continuous 
wtp=temp(:,12); % continuous (<=25)
wtprt=temp(:,13); % continuous 
judgment=temp(:,8); % binary

vd = [6 7 9 10 11 12 13 8];
VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
%conditions = {'Ecology False ', 'Democracy False ', 'Social Justice False ', 'Ecology True ', 'Democracy True ', 'Social Justice True '}; % order not active for allSub3MeanTrial

if exist('allSub3MeanTrial') == 0
    allSub3MeanTrial = struct;
    for i = 1:8
        allSub3MeanTrial(i).type = VD(i);
    end
    for i = 1:8
        if isfield(allSub3MeanTrial(i),'output') == 0 || isfield(allSub3MeanTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(nbs,6);
            outputa = zeros(nbs,6); outputb = zeros(nbs,6);
            for sub = 1:nbs
                col=0;
                for t = [1 2 3] % 1=Ecol, 2=Demo, 3=Just
                    for truth = [0 1] % 0=false, 1=true
                        col=col+1;
                        if i == 1 % Bidirectional (refer to the j items)
                            idxa = (subject==sub) & (theme==t) & (veracity==truth) & (temp(:,vd(i))>0); % pos values
                            idxb = (subject==sub) & (theme==t) & (veracity==truth) & (temp(:,vd(i))<0); % neg values
                        elseif i == 3 || i == 4 || i == 8 % Binary
                            idxa = (subject==sub) & (theme==t) & (veracity==truth) & (temp(:,vd(i))==1);
                            idxb = (subject==sub) & (theme==t) & (veracity==truth);
                        else % Continuous
                            idxb = (subject==sub) & (theme==t) & (veracity==truth);
                        end
                        
                        if i == 1 % Bidirectional
                            outputa = mean(temp(idxa,vd(i))); % pass via outputa bcause no reason ?
                            allSub3MeanTrial(i).outputPos(sub,col) = outputa;
                            outputb = mean(temp(idxb,vd(i)));
                            allSub3MeanTrial(i).outputNeg(sub,col) = outputb;
                        elseif i == 3 || i == 4 || i == 8 % Binary
                            output = (sum(idxa))/(sum(idxb));
                            allSub3MeanTrial(i).output(sub,col) = output;
                        elseif i == 2 || i > 4 && i < 8
                            if i == 6
                                output = mean(temp(idxb,vd(i)));
                            else % If i is not wtp: get rid of symbolic rounding
                                output = mean(temp(idxb,vd(i)))/1000;
                            end
                            allSub3MeanTrial(i).output(sub,col) = output;
                        end
                    end
                end
                % idx=booleen=1 quand ces conditions sont reunies et 0 sinon. sum va faire somme des lignes o� idx=1
            end
        end
    end
end

% Remark: for some participants, there is NaN in a condition in allSub3MeanTrial 
    % The reason is: some participants, in some conditions, didn't reply pos or neg

%% allSub3TruthTrial2Groups

if exist('allSub3TruthTrial') == 0
    allSub3TruthTrial2Groups = struct;
    for i = 1:8
        allSub3TruthTrial2Groups(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub3TruthTrial2Groups(i),'output') == 0 || isfield(allSub3TruthTrial2Groups(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(nbs,6); outputa = zeros(nbs,6); outputb = zeros(nbs,6);
            for sub = 1:nbs
                col=0;
                for grp = [1 2]
                    for truth = [0 1] % 0=false, 1=true
                        col=col+1;
                        if VD == 1 % Bidirectional (refer to the j items)
                            idxa = (subject==sub) & (veracity==truth) & (group==grp) & (temp(:,vd(VD))>0); % pos values
                            idxb = (subject==sub) & (veracity==truth) & (group==grp) & (temp(:,vd(VD))<0); % neg values
                        elseif VD == 3 || VD == 4 || VD == 8 % Binary
                            idxa = (subject==sub) & (veracity==truth) & (group==grp) & (temp(:,vd(VD))==1);
                            idxb = (subject==sub) & (veracity==truth) & (group==grp);
                        else % Continuous
                            idxb = (subject==sub) & (veracity==truth) & (group==grp);
                        end
                        
                        if VD == 1 % Bidirectional
                            outputa = mean(temp(idxa,vd(VD))); outputb = mean(temp(idxb,vd(VD)));
                            allSub3TruthTrial2Groups(VD).outputPos(sub,col) = outputa;
                            allSub3TruthTrial2Groups(VD).outputNeg(sub,col) = outputb;
                        elseif VD == 3 || VD == 4 || VD == 8 % Binary
                            output = (sum(idxa))/(sum(idxb));
                            allSub3TruthTrial2Groups(VD).output(sub,col) = output;
                        elseif VD == 2 || VD > 4 && VD < 8
                            if VD == 6
                                output = mean(temp(idxb,vd(VD)));
                            else % If i is not wtp: get rid of symbolic rounding
                                output = mean(temp(idxb,vd(VD)))/1000;
                            end
                            allSub3TruthTrial2Groups(VD).output(sub,col) = output;
                        end
                    end
                end
            end
        end
    end
end

%% allSub3TruthTrial

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub3TruthTrial') == 0
    allSub3TruthTrial = struct;
    for i = 1:8
        allSub3TruthTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub3TruthTrial(i),'output') == 0 || isfield(allSub3TruthTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(nbs,6); outputa = zeros(nbs,6); outputb = zeros(nbs,6);
            for sub = 1:nbs
                col=0;
                for truth = [0 1] % 0=false, 1=true
                    col=col+1;
                    if VD == 1 % Bidirectional (refer to the j items)
                        idxa = (subject==sub) & (veracity==truth) & (temp(:,vd(VD))>0); % pos values
                        idxb = (subject==sub) & (veracity==truth) & (temp(:,vd(VD))<0); % neg values
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        idxa = (subject==sub) & (veracity==truth) & (temp(:,vd(VD))==1);
                        idxb = (subject==sub) & (veracity==truth);
                    else % Continuous
                        idxb = (subject==sub) & (veracity==truth);
                    end
                    
                    if VD == 1 % Bidirectional
                        outputa = mean(temp(idxa,vd(VD))); outputb = mean(temp(idxb,vd(VD)));
                        allSub3TruthTrial(VD).outputPos(sub,col) = outputa;
                        allSub3TruthTrial(VD).outputNeg(sub,col) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub3TruthTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub3TruthTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end

%% allSub3ThemeTrial (for theme trials only)

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub3ThemeTrial') == 0
    allSub3ThemeTrial = struct;
    for i = 1:8
        allSub3ThemeTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub3ThemeTrial(i),'output') == 0 || isfield(allSub3ThemeTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(nbs,6); outputa = zeros(nbs,6); outputb = zeros(nbs,6);
            for sub = 1:nbs
                col=0;
                for t = [1 2 3] % 1=Ecol, 2=Demo, 3=Just
                    col=col+1;
                    if VD == 1 % Bidirectional (refer to the j items)
                        idxa = (subject==sub) & (theme==t) & (temp(:,vd(VD))>0); % pos values
                        idxb = (subject==sub) & (theme==t) & (temp(:,vd(VD))<0); % neg values
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        idxa = (subject==sub) & (theme==t) & (temp(:,vd(VD))==1);
                        idxb = (subject==sub) & (theme==t);
                    else % Continuous
                        idxb = (subject==sub) & (theme==t);
                    end
                    
                    if VD == 1 % Bidirectional
                        outputa = mean(temp(idxa,vd(VD))); outputb = mean(temp(idxb,vd(VD)));
                        allSub3ThemeTrial(VD).outputPos(sub,col) = outputa;
                        allSub3ThemeTrial(VD).outputNeg(sub,col) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub3ThemeTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub3ThemeTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end


%% allSub3JudgTrial

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub3JudgTrial') == 0
    allSub3JudgTrial = struct;
    for i = 1:8
        allSub3JudgTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub3JudgTrial(i),'output') == 0 || isfield(allSub3JudgTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(nbs,6); outputa = zeros(nbs,6); outputb = zeros(nbs,6);
            for sub = 1:nbs
                col=0;
                for judged = [0 1] % 0=judged as false, 1=judged as true
                    col=col+1;
                    if VD == 1 % Bidirectional (refer to the j items)
                        if judged == 0
                            idxb = (subject==sub) & (judgment==judged) & (temp(:,vd(VD))<0); % neg values
                        else
                            idxa = (subject==sub) & (judgment==judged) & (temp(:,vd(VD))>0); % pos values
                        end
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        idxa = (subject==sub) & (judgment==judged) & (temp(:,vd(VD))==1);
                        idxb = (subject==sub) & (judgment==judged);
                    else % Continuous
                        idxb = (subject==sub) & (judgment==judged);
                    end
                    
                    if VD == 1 % Bidirectional
                        outputa = mean(temp(idxa,vd(VD))); outputb = mean(temp(idxb,vd(VD)));
                        allSub3JudgTrial(VD).outputPos(sub,1) = outputa;
                        allSub3JudgTrial(VD).outputNeg(sub,1) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub3JudgTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub3JudgTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end

%Insert a year column to allSubjects3, data_tables3, group_data3
ii = width(allSubjects3);
allSubjects3(:,ii+1) = array2table(2);
allSubjects3.Properties.VariableNames(ii+1) = {'year'};

for ii = 1:length(data_tables3)
    jj = width(data_tables3(ii).models);
    data_tables3(ii).models(:,jj+1) = array2table(2);
    data_tables3(ii).models.Properties.VariableNames(:,jj+1) = {'year'};
end

for ii = 1:length(group_data3)
    jj = width(group_data3(ii).group1);
    group_data3(ii).group1(:,jj+1) = array2table(2);
    group_data3(ii).group1.Properties.VariableNames(:,jj+1) = {'year'};
    
    jj = width(group_data3(ii).group2);
    group_data3(ii).group2(:,jj+1) = array2table(2);
    group_data3(ii).group2.Properties.VariableNames(:,jj+1) = {'year'};
end
clear ii jj
    

Rec3_allSub = struct;
Rec3_allSub.allSub3JudgTrial = allSub3JudgTrial;   Rec3_allSub.allSub3MeanTrial = allSub3MeanTrial;   Rec3_allSub.allSub3ThemeTrial = allSub3ThemeTrial;   Rec3_allSub.allSub3TruthTrial = allSub3TruthTrial; 

%% SAVE
clear m i j k ans arneg arpos indD indE indF indJ indV  sortedNames ar currentFolder data_type tblv condition trial varNames varNamesg1 varNamesg2 col idx idxa idxb output outputa outputb t eval evalrt group judgment rec recrt sub subject success temp theme Themes judged vd VD judgment wtp wtprt nbe nbo nbs nbstim within models truth grp

cd(strcat(project_root,'/data/intermediate'));
save Receivingnews3_tables