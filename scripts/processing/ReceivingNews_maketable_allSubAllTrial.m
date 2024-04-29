clear
clc
close all

%% VARIABLES

project_root = strrep(pwd(), '\', '/');

% Load news evaluations
load(strcat(project_root,'/data/stimuli/News_evaluations.mat'))

load(strcat(project_root,'/data/intermediate/Receivingnews2_tables.mat'))
load(strcat(project_root,'/data/intermediate/Receivingnews3_tables.mat'))

load(strcat(project_root,'/data/brier_score/Receivingnews_Brier.mat'), 'Brier');
% Receivingnews1 is pilot, therefore not included


%% MERGE TABLES

% Change Subject id for allSub3Trial and allSubjects3
allSub3AllTrial(:,1) = array2table(allSub3AllTrial{:,1} + height(allSubjects2));
allSubjects3(:,1) = array2table(allSubjects3{:,1} + height(allSubjects2));

% Vertical concatenate data from both Receivingnews2 and Receivingnews3
allSubAllTrial = vertcat(allSub2AllTrial, allSub3AllTrial);
allSubjects2.Properties.RowNames = string(allSubjects2{:,1}); allSubjects3.Properties.RowNames = string(allSubjects3{:,1});
allSubjects = vertcat(allSubjects2, allSubjects3);
clear allSub2AllTrial allSub3AllTrial allSubjects2 allSubjects3

VD = {'eval','evalrt','success','rec','recrt','wtp','wtprt','judgment'};
for ii = 1:5
    temp = struct;
    for i = 1:8
        temp(i).type = VD(i);
    end
    switch ii
        case 1
            variable1 = allSub2JudgTrial;            variable2 = allSub3JudgTrial;
        case 2
            variable1 = allSub2MeanTrial;            variable2 = allSub3MeanTrial;
        case 3
            variable1 = allSub2ThemeTrial;           variable2 = allSub3ThemeTrial;
        case 4
            variable1 = allSub2TruthTrial;           variable2 = allSub3TruthTrial;
        case 5
            variable1 = allSub2TruthTrial2Groups;    variable2 = allSub3TruthTrial2Groups;
    end
    for jj = 1:length(variable1)
        if jj == 1
            temp(jj).outputPos = vertcat(variable1(jj).outputPos, variable2(jj).outputPos);
            temp(jj).outputNeg = vertcat(variable1(jj).outputNeg, variable2(jj).outputNeg);
        else
            temp(jj).output = vertcat(variable1(jj).output, variable2(jj).output);
        end
    end
    if ii==1,                allSubJudgTrial = temp; %#ok<*NASGU>
    elseif ii == 2,          allSubMeanTrial = temp;
    elseif ii == 3,          allSubThemeTrial = temp;
    elseif ii == 4,          allSubTruthTrial = temp;
    elseif ii == 5,          allSubTruthTrial2Groups = temp;
    end
    clear temp
end
clear allSub2AllTrial allSub2JudgTrial allSub2MeanTrial allSub2ThemeTrial allSub2TruthTrial allSub2TruthTrial2Groups
clear allSub3AllTrial allSub3JudgTrial allSub3MeanTrial allSub3ThemeTrial allSub3TruthTrial allSub3TruthTrial2Groups

data_tables = struct; group_data = struct;
for ii = 1:9
    data_tables(ii).type = data_tables2(ii).type;
    temp1 = table2array(data_tables2(ii).models);    colnames = data_tables2(ii).models.Properties.VariableNames;
    temp2 = table2array(data_tables3(ii).models);
    data_tables(ii).models = array2table(vertcat(temp1, temp2));
    data_tables(ii).models.Properties.VariableNames = colnames;
    data_tables(ii).within = data_tables2(ii).within;
    clear temp1 temp2
    
    group_data(ii).type = group_data2(ii).type;
    temp1 = table2array(group_data2(ii).group1);    colnames = group_data2(ii).group1.Properties.VariableNames;
    temp2 = table2array(group_data3(ii).group1);
    group_data(ii).group1 = array2table(vertcat(temp1, temp2));
    group_data(ii).group1.Properties.VariableNames = colnames;
    clear temp1 temp2
    
    temp1 = table2array(group_data2(ii).group2);    colnames = group_data2(ii).group2.Properties.VariableNames;
    temp2 = table2array(group_data3(ii).group2);
    group_data(ii).group2 = array2table(vertcat(temp1, temp2));
    group_data(ii).group2.Properties.VariableNames = colnames;
    clear temp1 temp2
end
clear i ii jj colnames outsiders3 VD variable1 variable2 tmp Theme


%% ADDITIONAL VARIABLES

nbs = height(allSubjects); %nb sujets
nbs2 = height(allSubjects(allSubjects.year == 1,:));
nbs3 = height(allSubjects(allSubjects.year == 2,:));
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli


Rec_allSub = struct;
txt = {'allSubjects' 'data_tables' 'data_tables2' 'data_tables3' 'group_data' 'group_data2' 'group_data3' 'allSubMeanTrial' 'allSubThemeTrial' 'allSubJudgTrial' 'allSubTruthTrial' 'allSubTruthTrial2Groups' 'Brier'};
for ii = 1:length(txt)
    var = txt{ii};
    Rec_allSub.(var) = eval(var);
end
clear allSubjects data_tables data_tables2 data_tables3 group_data group_data2 group_data3 allSubMeanTrial allSubThemeTrial allSubJudgTrial allSubTruthTrial allSubTruthTrial2Groups


for jj = 3:size(Rec_allSub.data_tables,2)
    col = size(Rec_allSub.data_tables(jj).models{ii,:}, 2);
    for ii = 1:height(Rec_allSub.data_tables(5).models)
        Rec_allSub.data_tables(jj).models{ii,col+1} = ii;
    end
    Rec_allSub.data_tables(jj).models.Properties.VariableNames(col+1)= {'subject'};
end


% Add Brier score to allSubAllTrial
col=size(allSubAllTrial{ii,:},2);
for ii = 1:nbs
    allSubAllTrial(allSubAllTrial{:,1} == ii,col+1) = array2table(Brier.BScores(ii,2));
end
allSubAllTrial.Properties.VariableNames(col+1) = {'Brier'};


% Add consensuality (10 - split) (10 points Likert scale for split)
col=size(allSubAllTrial{ii,:},2);
allSubAllTrial(:,col+1) = array2table(10 - allSubAllTrial{:,15});
allSubAllTrial.Properties.VariableNames(col+1) = {'consensuality'};


%% Check missing data

nb_NaN_age = sum(isnan(allSubAllTrial{:,29}))/48; % 3
nb_NaN_sex = sum(isnan(allSubAllTrial{:,30}))/48; % 4
nb_NaN_educ = sum(isnan(allSubAllTrial{:,31}))/48; % 28
nb_NaN_EC = sum(isnan(allSubAllTrial{:,32}))/48; % 0


%% Check outliers and randomness of presentation

%Check for stimuli outlying
% Outlier: defined as a point more than three standard deviations from the mean of the data.
temp = zeros(nbstim,3);
for ii = 1:96
    if ii < 49
        temp(ii,1) = table2array(Rec_allSub.group_data(1).group1(1,ii));
        temp(ii,2) = mean(table2array(Rec_allSub.group_data(5).group1(:,ii)));  temp(ii,3) = mean(table2array(Rec_allSub.group_data(6).group1(:,ii)));
    else
        temp(ii,1) = table2array(Rec_allSub.group_data(1).group2(1,ii-48));
        temp(ii,2) = mean(table2array(Rec_allSub.group_data(5).group2(:,ii-48)));  temp(ii,3) = mean(table2array(Rec_allSub.group_data(6).group2(:,ii-48)));
    end
end
mean(temp(:,2)); std(temp(:,2));  mean(temp(:,3), 'omitnan'); std(temp(:,3),'omitnan');
[B1,TF1] = rmoutliers(temp(:,2), 'mean'); sum(TF1(TF1==1)); % 0 outlying news in veracity evaluation success rate
[B1,TF1] = rmoutliers(temp(:,3), 'mean'); sum(TF1(TF1==1)); % 0 outlying news in reception choices


% Verify randomness of stimuli presentation
[h,p] = runstest(allSubAllTrial{:,33},49); %#ok<*ASGLU>         % p=1, h=0 -> presentation order is random


%% PREPARE TABLES FOR MODELS

% Add a time parameter
for ii = 1:nbs2
    sub2read(ii,1) = string(Receivingnews2(ii).info.file);
    sub2read(ii,2) = string(Receivingnews2(ii).info.subject(8:end));
end
for ii = 1:nbs3
    sub2read2(ii,1) = string(Receivingnews3(ii).info.file);
    sub2read2(ii,1) = erase(sub2read2(ii,1), 'xls');
    sub2read2(ii,1) = strcat(sub2read2(ii,1), 'csv');
    if ii> 120
        sub2read2(ii,2) = string(str2double(Receivingnews3(ii).info.subject(8:end))+78); % compensate for S121 eliminated
    else
        sub2read2(ii,2) = string(str2double(Receivingnews3(ii).info.subject(8:end))+79);
    end
end



opts = delimitedTextImportOptions("NumVariables", 39); opts.DataLines = [17,Inf]; opts.Delimiter = ",";
opts.VariableNames = ["Var1", "trialNo", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27", "Var28", "Var29", "Var30", "Var31", "Var32", "Var33", "Var34", "Var35", "Var36", "Var37", "Var38", "Var39"]; opts.SelectedVariableNames = "trialNo";
opts.VariableTypes = ["string", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
col=size(allSubAllTrial{ii,:}, 2)+1;
for ii = 1:nbs2
    sub2rd_order = readtable(strcat(project_root, "/data/raw/ReceivingNews2/Data_behavior/Sujets/raw/", sub2read(ii)), opts);     sub2rd_order = sub2rd_order(1:3:end,:);
    sub2rd_order(:,2) = array2table((1:48)'); sub2rd_order = sortrows(sub2rd_order,1);
    allSubAllTrial(allSubAllTrial{:,1} == str2double(sub2read{ii,2}), col) = sub2rd_order(:,2);
end
for ii = 1:nbs3
    sub2rd_order2 = readtable(strcat(project_root, "/data/raw/ReceivingNews3/Data_behavior/Sujets/raw/", sub2read2(ii)), opts);     sub2rd_order2 = sub2rd_order2(1:3:end,:);
    sub2rd_order2 = readtable(strcat(project_root,"/data/raw/ReceivingNews3/Data_behavior/Sujets/raw/", sub2read2(ii)), opts);     sub2rd_order2 = sub2rd_order2(1:3:end,:);
    sub2rd_order2(:,2) = array2table((1:48)'); sub2rd_order2 = sortrows(sub2rd_order2,1);
    allSubAllTrial(allSubAllTrial{:,1} == str2double(sub2read2{ii,2}), col) = sub2rd_order2(:,2);
end
clear opts
allSubAllTrial.Properties.VariableNames(col) = {'order'};


plots_data = allSubAllTrial;
allSubAllTrial(:,6) = array2table(abs(allSubAllTrial{:,6}));
allSubAllTrial(allSubAllTrial{:,10} == 2, 10) = array2table(0);

for sub = unique(allSubAllTrial.subject)'
    success_responses(sub) = sum(allSubAllTrial.success(allSubAllTrial.subject == sub));
end


%% SAVE

clear ans B1 Brier col h ii jj nb_NaN_age nb_NaN_EC nb_NaN_educ nb_NaN_sex p temp TF1 txt var 

save(strcat(project_root,'/data/processed/ReceivingNews_tables.mat'));
writetable(allSubAllTrial,strcat(project_root,'/data/processed/receivingNews_data.csv'));
