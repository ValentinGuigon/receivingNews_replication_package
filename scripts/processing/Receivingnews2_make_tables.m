clear
clc

%% Personal note: 'format bank' was used for sake of display. Remember to go back to 'format short'

%% VARIABLES AND LOAD BEHAVIOR

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/intermediate'));

% Load behavior
load Receivingnews2_extracted.mat;

nbs = 80; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli


%% LOAD STIMULI AND STIMULI EVALUATIONS
cd(strcat(project_root,'/data/stimuli'));

% Load all Theme names
[~, ~, raw] = xlsread(strcat(project_root, '/stimuli/Stimuli_list.xlsx'),'Feuil1','F1:F96');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1); Theme = cellVectors(:,1);
clearvars raw cellVectors;

% Load news evaluations
load News_evaluations


%% TABLES PREPARATION %%%%%%%
data_type = {'idnews','veracity','eval','eval_RT','eval_success','reception','rec_RT','rec_WTP','rec_WTP_RT'}';

for i = 1:9 % group_data2 for each Dependent Variables for each group
    data_tables2(i).type = data_type(i);
    
    %% Tables for group 1 and 2
    g1 = allSubjects2(allSubjects2.group==1,15+i-1:9:446);
    g2 = allSubjects2(allSubjects2.group==2,15+i-1:9:446);
            
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
    group_data2(i).type = data_type(i);
    group_data2(i).group1 = g1;
    group_data2(i).group2 = g2;
end

%% Errors because complete mean, sd and count columns with zeros for participants not yet passed in the loop

%% OUTLIERS: cheaters detection (For success rates, outlier based on number of successes compared to others)

% For success rates: G1
out1 = table2array(group_data2(5).group1(1:end,50)); % TF: 1 if subject = outlier; B = table without outlier
[B1,TF1] = rmoutliers(out1); % Subject 80 (subject 39 of g1) is an outlier
group_data2(5).group1(:,53) = array2table(TF1);
group_data2(5).group1.Properties.VariableNames([53]) = {'outlier'};

% For success rates: G2
out2 = table2array(group_data2(5).group2(1:end,50));
[B2,TF2] = rmoutliers(out2); % returns no outlier in g2
group_data2(5).group2(:,53) = array2table(TF2);
group_data2(5).group2.Properties.VariableNames([53]) = {'outlier'};

% There is only one outliers, subject 80 (g1). Therefore, we check RT
% For evaluation RT: G1
out1 = table2array(group_data2(4).group1(1:end,49));
[B,TF] = rmoutliers(out1); % Subject 80 (subject 39 of g1) is an outlier as well
group_data2(4).group1(:,51) = array2table(TF);
group_data2(4).group1.Properties.VariableNames([51]) = {'outlier'};

out2 = table2array(group_data2(4).group2(1:end,49));
[B,TF] = rmoutliers(out2);
group_data2(4).group2(:,51) = array2table(TF);
group_data2(4).group2.Properties.VariableNames([51]) = {'outlier'};

% We get subject 80 out of data
for i = 1:9
    group_data2(i).group1(39,:) = [];
end
allSubjects2(80,:) = [];
Receivingnews2(80) = [];
nbs=nbs-1;


%% Models Tables

clear arrayg1 arrayg1neg arrayg1pos B B1 B2 g1 g2 i out out1 out2 TF TF1 TF2

for i = 1:9 % data_tables2 for each Dependent Variables for all subjects
    tempg1 = group_data2(i).group1; % pb ici
    for j =1:nbstim
        varNamesg1(j) = strcat(Theme(j), '_', num2str(j));
    end
    clear j
    % Nb is different from stimuli reference. For fusion of both g1 and g2 tables
    tempg1.Properties.VariableNames([1:nbstim]) = varNamesg1(1:nbstim);
    
    tempg2 = group_data2(i).group2;
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
        tempg(:,4:16) = allSubjects2(:,2:14); tempg(:,17:20) = allSubjects2(:,447:450);
        colNames(1:3) = {'scoreDemo', 'scoreEcol', 'scoreJust'};
        colNames(4:16) = allSubjects2(1,2:14).Properties.VariableNames; colNames(17:20) = allSubjects2(1,447:450).Properties.VariableNames;
        rowNames = allSubjects2(:,1).Properties.RowNames;
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
    
    data_tables2(i).models = models;
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
    data_tables2(i).within = within;
    % Can't put veracity because we merged group1 and group2 data.
    % Therefore, in the table, there are 48 trials to avoid accounting for group, but Truth value for trial 1 group 1 is not equal to Truth value for trial & group 2
    
    
    %% Completing tables for mean/tabulate for each theme
    m=53; % Ref for first row to fill results for each stim type
    
    if i == 3
        % Score = mean
        m=m+2;
        data_tables2(i).models(:,61:77) = data_tables2(i).models(:,58:74); data_tables2(i).models(:,58:60) = array2table(zeros(79,3));
        varNames = data_tables2(3).models.Properties.VariableNames;
        data_tables2(i).models.Properties.VariableNames(55:60) = {'scoreDemoPos','scoreDemoNeg','scoreEcolPos','scoreEcolNeg','scoreJustPos','scoreJustNeg'};
        data_tables2(3).models.Properties.VariableNames(:,61:77) = varNames(1,58:74);
        for k = 1:height(data_tables2(i).models)
            arpos = table2array(data_tables2(i).models(k,1:16));
            arpos = arpos(arpos(1,1:16)>0); % Subject 4: scoreDemoPos: NA because only reported negative values
            data_tables2(i).models(k,m) = array2table(mean(arpos));
            arneg = table2array(data_tables2(i).models(k,1:16));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables2(i).models(k,m+1) = array2table(mean(arneg));            
            
            arpos = table2array(data_tables2(i).models(k,17:32));
            arpos = arpos(arpos(1,1:16)>0);
            data_tables2(i).models(k,m+2) = array2table(mean(arpos));
            arneg = table2array(data_tables2(i).models(k,17:32));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables2(i).models(k,m+3) = array2table(mean(arneg));            
            
            arpos = table2array(data_tables2(i).models(k,33:nbstim));
            arpos = arpos(arpos(1,1:16)>0);
            data_tables2(i).models(k,m+4) = array2table(mean(arpos));
            arneg = table2array(data_tables2(i).models(k,33:nbstim));
            arneg = arneg(arneg(1,1:16)<0);
            data_tables2(i).models(k,m+5) = array2table(mean(arneg));
        end
        
    elseif i == 5 || i == 6
        if i == 5         m = m+1;
        end
        for k = 1:height(data_tables2(i).models)
            tblv = array2table(tabulate(data_tables2(i).models{k,1:16}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables2(i).models(k,m) = num2cell(0);
            else
                data_tables2(i).models(k,m) = tblv(2,3);
            end
            
            tblv = array2table(tabulate(data_tables2(i).models{k,17:32}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables2(i).models(k,m+1) = num2cell(0);
            else
                data_tables2(i).models(k,m+1) = tblv(2,3);
            end
            
            tblv = array2table(tabulate(data_tables2(i).models{k,33:nbstim}));
            if size(tblv,1) == 1 % If only zeros (no desirability for more news)
                data_tables2(i).models(k,m+2) = num2cell(0);
            else
                data_tables2(i).models(k,m+2) = tblv(2,3);
            end
        end
        
        
    elseif i == 4 || i == 7 || i == 8 || i == 9
        if i == 4
            m = m-1;
        elseif i == 7 || i == 8 || i == 9
            m = m-2;
        end
        for k = 1:height(data_tables2(i).models)
            ar = data_tables2(i).models{k,1:16};
            data_tables2(i).models(k,m) = array2table(mean(ar));
            
            ar = data_tables2(i).models{k,17:32};
            data_tables2(i).models(k,m+1) = array2table(mean(ar));
            
            ar = data_tables2(i).models{k,33:nbstim};
            data_tables2(i).models(k,m+2) = array2table(mean(ar));
        end
    end
    
    %% Between subjects tables = models
    clear tempg tempg1 tempg2 colNames rowNames varNames
end


%% allSub2AllTrial

indD= find(strcmp(Theme, 'Demo')); indE= find(strcmp(Theme, 'Ecol')); indJ= find(strcmp(Theme, 'Just'));
Themes(indE,1) = 1; Themes(indD,1) = 2; Themes(indJ,1) = 3; % ecol= 1 démo = 2 just = 3
m = 1;

for i = 1:nbs % allSub2AllTrial for each stim for each subject
    allSub2AllTrial(m:m+47,1) = i; % subject n°
    allSub2AllTrial(m:m+47,2) = Receivingnews2(i).info.subjectGroup; % Subject group n°
    if Receivingnews2(i).info.subjectGroup == 1 % group 1 theme for each stim
        allSub2AllTrial(m:m+47,3) = Themes(1:nbstim,1); % Themes is in idnews order, and data in Receivingnews2 is order par idstim
    else % group 2 theme for each stiù
        allSub2AllTrial(m:m+47,3) = Themes(49:96,1);
    end
    
    allSub2AllTrial(m:m+47,4) = Receivingnews2(i).news{:,2}; % idnews
    allSub2AllTrial(m:m+47,5:10) = cell2mat(Receivingnews2(i).news{:,3:8}); % evaluation, evaluationRT, reception, receptionRT, WTP, WTPRT
    indV= find(strcmp(Receivingnews2(i).news{:,9}, 'VRAIE')); indF= find(strcmp(Receivingnews2(i).news{:,9}, 'FAUSSE')); 
    allSub2AllTrial(indV+m-1,11) = 1; allSub2AllTrial(indF+m-1,11) = 0; % Veracity judgment produced
    clear indV indF; indV= find(strcmp(Receivingnews2(i).news{:,10}, 'VRAIE')); indF= find(strcmp(Receivingnews2(i).news{:,10}, 'FAUSSE')); 
    allSub2AllTrial(indV+m-1,12) = 1; allSub2AllTrial(indF+m-1,12) = 0; % True Veracity
    allSub2AllTrial(m:m+47,13) = cell2mat(Receivingnews2(i).news{:,11}); % Veracity judgment success
    
    for j = 1:14
        allSub2AllTrial(m:m+47,13+j:25) = table2array(allSubjects2(i,2+j)); % Organizations data
    end
    for j = 1:nbstim
        allSub2AllTrial(m+j-1,26:29) = table2array(allSubjects2(i,447:450));
    end
    m=m+48;
end

allSub2AllTrial = array2table(allSub2AllTrial);
allSub2AllTrial.Properties.VariableNames(1:13) = {'subject','group','theme','idnews','eval','eval_RT','rec','rec_RT','WTP','WTP_RT','judgment','veracity','success'};
allSub2AllTrial.Properties.VariableNames(14:29) = data_tables2(3).models.Properties.VariableNames(62:77);

% Fixing some shit happening with the judgment == 0/1
allSub2AllTrial(allSub2AllTrial{:,5} > 0,11) = array2table(1); allSub2AllTrial(allSub2AllTrial{:,5} < 0,11) = array2table(0);


%% ICC table
stims(1:48,2) = table2array(group_data2(1).group1(1,1:48))'; stims(1:48,1) = 1; stims(1:48,3) = table2array(group_data2(2).group1(1,1:48))'; stims(1:48,4) = table2array(allSub2AllTrial(97:144,4));
stims(49:96,2) = table2array(group_data2(1).group2(1,1:48))'; stims(49:96,1) = 2; stims(49:96,3) = table2array(group_data2(2).group2(1,1:48))'; stims(49:96,4) = table2array(allSub2AllTrial(1:48,4));
m=1;
for ii = 1:5
    temp(m:m+41,1) = IRR(ii).stims(1:42,1);     temp(m:m+41,2) = IRR(ii).ambiguity(1:42,width(IRR(ii).matrices(1,:)));     temp(m:m+41,3) = IRR(ii).split(1:42,width(IRR(ii).matrices(1,:)));     temp(m:m+41,4) = IRR(ii).desirability(1:42,width(IRR(ii).matrices(1,:)));
    m=m+42;
end
stims = array2table(stims); stims.Properties.VariableNames = {'group','idnews','veracity','theme'}; temp = array2table(temp); temp.Properties.VariableNames = {'idnews','ambiguity','split','desirability'};
ICC = join(stims, temp); clear stims temp ii m 


%Complete allSub2AllTrial with ICC
m = 1;
for i = 1:nbs
    if allSub2AllTrial{m:m+47,2} == 1 % ICC values
        allSub2AllTrial(m:m+47,30:32) = ICC(1:48,5:7); 
    elseif allSub2AllTrial{m:m+47,2} == 2
        allSub2AllTrial(m:m+47,30:32) = ICC(49:96,5:7); 
    end
    m=m+48;
end
allSub2AllTrial.Properties.VariableNames(30:32) = {'ambiguity','split','desirability'};
allSub2AllTrial = allSub2AllTrial(:,{'subject' 'group' 'idnews' 'theme' 'veracity' 'eval' 'eval_RT' 'judgment' 'success' 'rec' 'rec_RT' 'WTP' 'WTP_RT' 'ambiguity' 'split' 'desirability' 'SOS_Mediterranee' 'FEMEN' 'Generation_Identitaire' 'La_Manif_Pour_Tous' 'Greenpeace' 'WWF' 'NIPCC' 'Climato_realistes' 'Mouvement_Europeen_France' 'Fondation_Robert_Schuman' 'Frexit' 'Parti_Libertarien' 'age' 'sex' 'education' 'EC'});

%Add 7 empty columns so can combine with ReceivingNews3
allSub2AllTrial(:,33:39) = array2table(NaN);
allSub2AllTrial.Properties.VariableNames(33:39) = {'prcnt_politique', 'prcnt_journaliste', 'prcnt_medecin', 'prcnt_acteurjustsoc', 'prcnt_chercheur', 'prcnt_acteurecologie', 'prcnt_general'};

%Add a "year of experiment" column
allSub2AllTrial(:,40) = array2table(1);
allSub2AllTrial.Properties.VariableNames(40) = {'year'};

%% allSub2MeanTrial (for Themes * True and False data)

% Filters
clear temp
temp = table2array(allSub2AllTrial);
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
conditions = {'Ecology False ', 'Democracy False ', 'Social Justice False ', 'Ecology True ', 'Democracy True ', 'Social Justice True '}; % order not active for allSub2MeanTrial

if exist('allSub2MeanTrial') == 0
    allSub2MeanTrial = struct;
    for i = 1:8
        allSub2MeanTrial(i).type = VD(i);
    end
    for i = 1:8
        if isfield(allSub2MeanTrial(i),'output') == 0 || isfield(allSub2MeanTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(79,6);
            outputa = zeros(79,6); outputb = zeros(79,6);
            for sub = 1:79
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
                            allSub2MeanTrial(i).outputPos(sub,col) = outputa;
                            outputb = mean(temp(idxb,vd(i)));
                            allSub2MeanTrial(i).outputNeg(sub,col) = outputb;
                        elseif i == 3 || i == 4 || i == 8 % Binary
                            output = (sum(idxa))/(sum(idxb));
                            allSub2MeanTrial(i).output(sub,col) = output;
                        elseif i == 2 || i > 4 && i < 8
                            if i == 6 
                                output = mean(temp(idxb,vd(i)));
                            else % If i is not wtp: get rid of symbolic rounding
                                output = mean(temp(idxb,vd(i)))/1000;
                            end
                            allSub2MeanTrial(i).output(sub,col) = output;
                        end
                    end
                end
                % idx=booleen=1 quand ces conditions sont reunies et 0 sinon. sum va faire somme des lignes o� idx=1
            end
        end
    end
end

% Remark: for some participants, there is NaN in a condition in allSub2MeanTrial 
    % The reason is: some participants, in some conditions, didn't reply pos or neg

%% allSub2TruthTrial2Groups

if exist('allSub2TruthTrial') == 0
    allSub2TruthTrial2Groups = struct;
    for i = 1:8
        allSub2TruthTrial2Groups(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub2TruthTrial2Groups(i),'output') == 0 || isfield(allSub2TruthTrial2Groups(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(79,6); outputa = zeros(79,6); outputb = zeros(79,6);
            for sub = 1:79
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
                            allSub2TruthTrial2Groups(VD).outputPos(sub,col) = outputa;
                            allSub2TruthTrial2Groups(VD).outputNeg(sub,col) = outputb;
                        elseif VD == 3 || VD == 4 || VD == 8 % Binary
                            output = (sum(idxa))/(sum(idxb));
                            allSub2TruthTrial2Groups(VD).output(sub,col) = output;
                        elseif VD == 2 || VD > 4 && VD < 8
                            if VD == 6
                                output = mean(temp(idxb,vd(VD)));
                            else % If i is not wtp: get rid of symbolic rounding
                                output = mean(temp(idxb,vd(VD)))/1000;
                            end
                            allSub2TruthTrial2Groups(VD).output(sub,col) = output;
                        end
                    end
                end
            end
        end
    end
end

%% allSub2TruthTrial

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub2TruthTrial') == 0
    allSub2TruthTrial = struct;
    for i = 1:8
        allSub2TruthTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub2TruthTrial(i),'output') == 0 || isfield(allSub2TruthTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(79,6); outputa = zeros(79,6); outputb = zeros(79,6);
            for sub = 1:79
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
                        allSub2TruthTrial(VD).outputPos(sub,col) = outputa;
                        allSub2TruthTrial(VD).outputNeg(sub,col) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub2TruthTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub2TruthTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end

%% allSub2ThemeTrial (for theme trials only)

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub2ThemeTrial') == 0
    allSub2ThemeTrial = struct;
    for i = 1:8
        allSub2ThemeTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub2ThemeTrial(i),'output') == 0 || isfield(allSub2ThemeTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(79,6); outputa = zeros(79,6); outputb = zeros(79,6);
            for sub = 1:79
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
                        allSub2ThemeTrial(VD).outputPos(sub,col) = outputa;
                        allSub2ThemeTrial(VD).outputNeg(sub,col) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub2ThemeTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub2ThemeTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end


%% allSub2JudgTrial

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
if exist('allSub2JudgTrial') == 0
    allSub2JudgTrial = struct;
    for i = 1:8
        allSub2JudgTrial(i).type = VD(i);
    end
    for VD = 1:8
        if isfield(allSub2JudgTrial(i),'output') == 0 || isfield(allSub2JudgTrial(i),'outputa') == 0 %outputb is codependent on outputa
            output = zeros(79,6); outputa = zeros(79,6); outputb = zeros(79,6);
            for sub = 1:79
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
                        allSub2JudgTrial(VD).outputPos(sub,1) = outputa;
                        allSub2JudgTrial(VD).outputNeg(sub,1) = outputb;
                    elseif VD == 3 || VD == 4 || VD == 8 % Binary
                        output = (sum(idxa))/(sum(idxb));
                        allSub2JudgTrial(VD).output(sub,col) = output;
                    elseif VD == 2 || VD > 4 && VD < 8
                        if VD == 6
                            output = mean(temp(idxb,vd(VD)));
                        else % If i is not wtp: get rid of symbolic rounding
                            output = mean(temp(idxb,vd(VD)))/1000;
                        end
                        allSub2JudgTrial(VD).output(sub,col) = output;
                    end
                end
            end
        end
    end
end

%Insert 7 blank columns to allSubject2
allSubjects2(:,451:457) = array2table(NaN);
allSubjects2.Properties.VariableNames(451:457) = {'prcnt_politique' 'prcnt_journaliste' 'prcnt_medecin' 'prcnt_acteurjustsoc' 'prcnt_chercheur' 'prcnt_acteurecologie' 'prcnt_general'};

%Insert a year column to allSubjects2, data_tables2, group_data2
ii = width(allSubjects2);
allSubjects2(:,ii+1) = array2table(1);
allSubjects2.Properties.VariableNames(ii+1) = {'year'};

for ii = 1:length(data_tables2)
    jj = width(data_tables2(ii).models);
    if ii > 2
        data_tables2(ii).models(:,jj+1:jj+1+6) = array2table(NaN);
    end
    jj = width(data_tables2(ii).models);
    data_tables2(ii).models(:,jj+1) = array2table(1);
    data_tables2(ii).models.Properties.VariableNames(:,jj+1) = {'year'};
end

for ii = 1:length(group_data2)
    jj = width(group_data2(ii).group1);
    group_data2(ii).group1(:,jj+1) = array2table(1);
    group_data2(ii).group1.Properties.VariableNames(:,jj+1) = {'year'};
    
    jj = width(group_data2(ii).group2);
    group_data2(ii).group2(:,jj+1) = array2table(1);
    group_data2(ii).group2.Properties.VariableNames(:,jj+1) = {'year'};
end
clear ii jj


Rec2_allSub = struct;
Rec2_allSub.allSub2JudgTrial = allSub2JudgTrial;   Rec2_allSub.allSub2MeanTrial = allSub2MeanTrial;   Rec2_allSub.allSub2ThemeTrial = allSub2ThemeTrial;   Rec2_allSub.allSub2TruthTrial = allSub2TruthTrial; 


%% SAVE
clear m i j k ans arneg arpos indD indE indF indJ indV  sortedNames ar currentFolder data_type tblv condition trial varNames varNamesg1 varNamesg2 col idx idxa idxb output outputa outputb t eval evalrt group judgment rec recrt sub subject success temp theme Themes judged vd VD judgment wtp wtprt nbe nbo nbs nbstim within models truth tmp grp 

cd(strcat(project_root,'/data/intermediate'));
save Receivingnews2_tables
