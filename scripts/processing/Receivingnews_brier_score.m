clear
clc
close all


%% MERGE TABLES

project_root = strrep(pwd(), '\', '/');
addpath(genpath(strcat(project_root,'/matlab_toolboxes/MATLAB Tools')))

% Load news evaluations
cd(strcat(project_root,'/data/stimuli'));
load News_evaluations

cd(strcat(project_root,'/data/intermediate'));
load Receivingnews2_tables.mat
load Receivingnews3_tables.mat
% Receivingnews1 is pilot, therefore not included

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
clear i ii jj colnames outsiders3 VD variable1 variable2 tmp veracity conditions Theme





%% VARIABLES
nbs = height(allSubjects); %nb sujets
nbs2 = height(allSubjects(allSubjects.year == 1,:));
nbs3 = height(allSubjects(allSubjects.year == 2,:));
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli

addpath 'C:/Users/vguigon/Dropbox (Personal)/Scripts/Matlab/Violinplot-Matlab-master'
addpath 'C:/Users/vguigon/Dropbox (Personal)/Scripts/Matlab/fitmethis'
addpath(genpath('C:/Users/vguigon/Dropbox (Personal)/Scripts/Matlab/Anne Urai - Tools-master'));

data_plots = allSubAllTrial;
allSubAllTrial(:,6) = array2table(abs(allSubAllTrial{:,6}));

Rec_allSub = struct;
txt = {'data_tables' 'data_tables2' 'data_tables3' 'group_data' 'group_data2' 'group_data3' 'allSubJudgTrial' 'allSubMeanTrial' 'allSubTruthTrial' 'allSubTruthTrial2Groups'};
for ii = 1:length(txt)
    var = txt{ii};
    Rec_allSub.(var) = eval(var);
end
clear data_tables data_tables2 data_tables3 group_data group_data2 group_data3 allSubJudgTrial allSubMeanTrial allSubTruthTrial allSubTruthTrial2Groups





%% BRIER SCORE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL


tbl = table(zeros,zeros,zeros); tbl.Properties.VariableNames = {'proba','outcome','scores'};
tbl2 = table(zeros,zeros,zeros,zeros,zeros); tbl2.Properties.VariableNames = {'0-20%','20-40%','40-60%','60-80%','80-100%'};
tbl3 = table(zeros,zeros,zeros,zeros,zeros,zeros,zeros,zeros,zeros,zeros); tbl3.Properties.VariableNames = {'0-10%','10-20%','20-30%','30-40%','40-50%','50-60%','60-70%','70-80%','80-90%','90-100%'};

for sub = 1:nbs
    Brier.subjects(sub) = struct('subject',sub,'BrierTable',tbl,'Bins_accuracy',tbl2, 'BrierTable_true',tbl,'Bins_accuracy_true',tbl2, 'BrierTable_false',tbl,'Bins_accuracy_false',tbl2,'BrierTable_judgment_true',tbl,'Bins_accuracy_judgment_true',tbl2, 'BrierTable_judgment_false',tbl,'Bins_accuracy_judgment_false',tbl2, 'Bins_accuracy_10',tbl3);
    for stims = 1:nbstim % Brier score
        proba = abs(table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 6))); % proba is equal to absolute evaluation
        outcome = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 9)); % outcome is not veracity but success: therefore we can account for directionnality of evaluation (if eval=-50, then proba = 50 and success=1 means outcome was = 0)
        notoutcome = ~outcome;
        theme = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 4));
        veracity = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 5));
        idnews = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 3));
        ambiguity = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 14));
        scores = ((proba/100) - outcome).^2; % + (1-(proba/100) - notoutcome).^2;
        Brier.subjects(sub).BrierTable = [proba outcome scores theme veracity idnews ambiguity];
    end
    for acc = 1:5 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy(1,acc) = array2table(sum(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)) / length(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)));
        %if isnan(Brier.subjects(sub).Bins_accuracy{1,acc})==1
        % Brier.subjects(sub).Bins_accuracy(1,acc)=[]
        %end
    end
    for ii = 1:nbstim
        Brier.BScores(sub,1) = sub; Brier.BScores(sub,ii+1) = sum(scores(1:ii,1))/length(scores(1:ii,1)); % Each subject Brier score
    end
end






% 10 bins instead of 5
for sub = 1:nbs
    for acc = 1:10 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy_10(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1,2)) / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1,2)));
        %if isnan(Brier.subjects(sub).Bins_accuracy{1,acc})==1
        % Brier.subjects(sub).Bins_accuracy(1,acc)=[]
        %end
    end
    %Brier.BScores(sub,1) = sub; Brier.BScores(sub,2) = sum(scores)/length(scores); % Each subject Brier score
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEWS == TRUE


for sub = 1:nbs
    for stims = 1:nbstim/2 % Brier score
        proba = abs(table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,5} == 1, 6))); % proba is equal to absolute evaluation
        outcome = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,5} == 1, 9)); % outcome is not veracity but success: therefore we can account for directionnality of evaluation (if eval=-50, then proba = 50 and success=1 means outcome was = 0)
        scores = ((proba/100) - outcome).^2;         Brier.subjects(sub).BrierTable_true = [proba outcome scores];
    end
    for acc = 1:5 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable_true;
        Brier.subjects(sub).Bins_accuracy_true(1,acc) = array2table(sum(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)) / length(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)));
    end
    Brier.BScores_true(sub,1) = sub; Brier.BScores_true(sub,2) = sum(scores)/length(scores); % Each subject Brier score
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEWS == FALSE


for sub = 1:nbs
    for stims = 1:nbstim/2 % Brier score
        proba = abs(table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,5} == 0, 6))); % proba is equal to absolute evaluation
        outcome = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,5} == 0, 9)); % outcome is not veracity but success: therefore we can account for directionnality of evaluation (if eval=-50, then proba = 50 and success=1 means outcome was = 0)
        scores = ((proba/100) - outcome).^2;         Brier.subjects(sub).BrierTable_false = [proba outcome scores];
    end
    for acc = 1:5 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable_false;
        Brier.subjects(sub).Bins_accuracy_false(1,acc) = array2table(sum(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)) / length(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)));
    end
    Brier.BScores_false(sub,1) = sub; Brier.BScores_false(sub,2) = sum(scores)/length(scores); % Each subject Brier score
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JUDGMENT == TRUE

for sub = 1:nbs
    for stims = 1:nbstim/2 % Brier score
        proba = abs(table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,8} == 1, 6))); % proba is equal to absolute evaluation
        outcome = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,8} == 1, 9)); % outcome is not veracity but success: therefore we can account for directionnality of evaluation (if eval=-50, then proba = 50 and success=1 means outcome was = 0)
        scores = ((proba/100) - outcome).^2;         Brier.subjects(sub).BrierTable_judgment_true = [proba outcome scores];
    end
    for acc = 1:5 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable_judgment_true;
        Brier.subjects(sub).Bins_accuracy_judgment_true(1,acc) = array2table(sum(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)) / length(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)));
    end
    Brier.BScores_judgment_true(sub,1) = sub; Brier.BScores_judgment_true(sub,2) = sum(scores)/length(scores); % Each subject Brier score
end

% Compute accuracy for each bin
clear temp
m=1; tbl=zeros; percentE = struct('percent20',tbl,'percent40',tbl,'percent60',tbl,'percent80',tbl,'percent100',tbl); 
fields = fieldnames(percentE);
for ii = 1:nbs
    temp = table2array(Brier.subjects(ii).Bins_accuracy_judgment_true);
    for jj = 1:5
        tmp = temp(1,jj);         percentE.(fields{jj})(ii,1) = tmp;
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JUDGMENT == FALSE

for sub = 1:nbs
    for stims = 1:nbstim/2 % Brier score
        proba = abs(table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,8} == 0, 6))); % proba is equal to absolute evaluation
        outcome = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub & allSubAllTrial{:,8} == 0, 9)); % outcome is not veracity but success: therefore we can account for directionnality of evaluation (if eval=-50, then proba = 50 and success=1 means outcome was = 0)
        scores = ((proba/100) - outcome).^2;         Brier.subjects(sub).BrierTable_judgment_false = [proba outcome scores];
    end
    for acc = 1:5 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable_judgment_false;
        Brier.subjects(sub).Bins_accuracy_judgment_false(1,acc) = array2table(sum(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)) / length(temp(temp(:,1)>(0+20*(acc-1)) & temp(:,1)<(20*acc)+1,2)));
    end
    Brier.BScores_judgment_false(sub,1) = sub; Brier.BScores_judgment_false(sub,2) = sum(scores)/length(scores); % Each subject Brier score
end

% Compute accuracy for each bin
clear temp
m=1; tbl=zeros; percentF = struct('percent20',tbl,'percent40',tbl,'percent60',tbl,'percent80',tbl,'percent100',tbl); 
fields = fieldnames(percentF);
for ii = 1:nbs
    temp = table2array(Brier.subjects(ii).Bins_accuracy_judgment_false);
    for jj = 1:5
        tmp = temp(1,jj);         percentF.(fields{jj})(ii,1) = tmp;
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Confidence-accuracy calibration V2: judgments as true vs judgments as false, for each theme

% 10 bins instead of 5
for sub = 1:nbs
    for acc = 1:10 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy_10_Eco_F(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 1 & temp(:,5) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 1 & temp(:,5) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_Eco_V(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 1 & temp(:,5) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 1 & temp(:,5) == 1,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_Demo_F(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 2 & temp(:,5) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 2 & temp(:,5) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_Demo_V(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 2 & temp(:,5) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 2 & temp(:,5) == 1,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_Just_F(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 3 & temp(:,5) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 3 & temp(:,5) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_Just_V(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 3 & temp(:,5) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,4) == 3 & temp(:,5) == 1,2)));
    end

end






%% SAVE

if ~exist((strcat(project_root,'/data/brier_score')), 'dir')
       mkdir((strcat(project_root,'/data/brier_score')))
end

cd(strcat(project_root,'/data/brier_score'));
save('Receivingnews_Brier.mat', 'Brier');