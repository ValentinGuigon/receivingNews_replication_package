clear
clc
close all

%% Notes
% Signed rank test when the data are paired and values are positively dependent (e.g., repeated measures). Otherwise, rank sum (i.e., unpaired values)


%% MERGE TABLES
project_root = 'C:\Users\vguigon\Desktop\Research_directory\receivingNews';
currentFolder = strcat(pwd,'\');

% Load news evaluations
cd(strcat(project_root,'\data\stimuli'));
load News_evaluations

cd(strcat(project_root,'\data\intermediate'));
load Receivingnews2_data.mat
load Receivingnews3_data.mat

cd(strcat(project_root,'\data\brier_score'));
load('Receivingnews_Brier.mat', 'Brier');
% Receivingnews1 is pilote, therefore not included

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
clear i ii jj colnames currentFolder outsiders3 VD variable1 variable2 tmp Theme


% Do Receivingnews ?





%% ADDITIONAL VARIABLES

nbs = height(allSubjects); %nb sujets
nbs2 = height(allSubjects(allSubjects.year == 1,:));
nbs3 = height(allSubjects(allSubjects.year == 2,:));
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli


addpath 'C:\Users\vguigon\Dropbox (Personal)\Scripts\Matlab\Violinplot-Matlab-master'
addpath 'C:\Users\vguigon\Dropbox (Personal)\Scripts\Matlab\fitmethis'


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



%% Standalone Descriptives

% Receivingnews2 S80 removed and Receivingnews3 S121 (to verify) removed
% Beware of NaNs if want to use allSubTruthTrial (because different number of subjects in each group

% Participants sociodemo: 45males, 34females, mean + SD age = 21.14 + 2.63
nb_male = 0; age = zeros(nbs,1);
for ii = 1:nbs2
    if Receivingnews2(ii).info.sex == 1,         nb_male = nb_male+1;
    end
    age(ii,1) = Receivingnews2(ii).info.age;
end
for ii = 1:nbs3
    if ismissing(Receivingnews3(ii).info.sex)
    elseif Receivingnews3(ii).info.sex == 1,            nb_male = nb_male+1;
    end
    if ismissing(Receivingnews3(ii).info.age),          age(ii+nbs2,1) = NaN;
    else,                                               age(ii+nbs2,1) = Receivingnews3(ii).info.age;
    end
end
mean(age,'omitnan'); std(age,'omitnan'); max(age); min(age); % m=21.93, sd=2.78, min=18, max=34


% Participants RT
m=0; RTs=table;
for ii = [4 7 9 5]
    for jj = 1:3
        switch jj
            case 1, var1 = 'data_tables'; var2 = 'models';
            case 2, var1 = 'group_data';  var2 = 'group1';
            case 3, var1 = 'group_data';  var2 = 'group2';
        end
        if ii == 5, var3 = 'freq_1';
        else, var3 = 'mean_RT';
        end
        m = m+1;
        RTs(1,m) = array2table(mean(Rec_allSub.(var1)(ii).(var2).(var3)));
        RTs(2,m) = array2table(std(Rec_allSub.(var1)(ii).(var2).(var3)));
    end
end
RTs.Properties.VariableNames = {'eval all', 'eval g1', 'eval g2', 'rec all', 'rec g1', 'rec g2', 'wtp all', 'wtp g1', 'wtp g2', 'success all', 'success g1', 'success g2'};



% Differences between Sessions
% Truthfulness estimation RT
[p,h,stats] = ranksum(Rec_allSub.data_tables2(4).models.mean_RT, Rec_allSub.data_tables3(4).models.mean_RT);
% NS, mean session 1 = 14.46, mean session 2 = 14.39

% Reception RT
[p,h,stats] = ranksum(Rec_allSub.data_tables2(7).models.mean_RT, Rec_allSub.data_tables3(7).models.mean_RT);
% Difference: z=3.88, p<.001, mean session 1 = 1.84+, mean session 2 = 1.44

% WTP RT
[p,h,stats] = ranksum(Rec_allSub.data_tables2(9).models.mean_RT, Rec_allSub.data_tables3(9).models.mean_RT);
% Difference: z=2.96, p<.05, mean session 1 = 2.97, mean session 2 = 2.78



% Differences between Groups
% Truthfulness estimation RT
[p,h,stats] = ranksum(Rec_allSub.group_data(4).group1.mean_RT, Rec_allSub.group_data(4).group2.mean_RT);
% NS, mean session 1 = 15.00, mean session 2 = 13.84

% Reception RT
[p,h,stats] = ranksum(Rec_allSub.group_data(7).group1.mean_RT, Rec_allSub.group_data(7).group2.mean_RT);
% NS, mean session 1 = 1.63, mean session 2 = 1.50

% WTP RT
[p,h,stats] = ranksum(Rec_allSub.group_data(9).group1.mean_RT, Rec_allSub.group_data(9).group2.mean_RT);
% NS, mean session 1 = 2.86, mean session 2 = 2.81





% Correlation between split and ambiguity
[rho, pval] = corr(ICC.ambiguity, ICC.split,'Type','Pearson');
% p<.001, Rho=0.4782









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










%% Prepare tables for models

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
    sub2rd_order = readtable(strcat("C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews 2\Data comportemental\Sujets\raw\", sub2read(ii)), opts);     sub2rd_order = sub2rd_order(1:3:end,:);
    sub2rd_order(:,2) = array2table((1:48)'); sub2rd_order = sortrows(sub2rd_order,1);
    allSubAllTrial(allSubAllTrial{:,1} == str2double(sub2read{ii,2}), col) = sub2rd_order(:,2);
end
for ii = 1:nbs3
    sub2rd_order2 = readtable(strcat("C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews 3\Data comportemental\Sujets\raw\", sub2read2(ii)), opts);     sub2rd_order2 = sub2rd_order2(1:3:end,:);
    sub2rd_order2(:,2) = array2table((1:48)'); sub2rd_order2 = sortrows(sub2rd_order2,1);
    allSubAllTrial(allSubAllTrial{:,1} == str2double(sub2read2{ii,2}), col) = sub2rd_order2(:,2);
end
clear opts
allSubAllTrial.Properties.VariableNames(col) = {'order'};


plots_data = allSubAllTrial;
allSubAllTrial(:,6) = array2table(abs(allSubAllTrial{:,6}));
allSubAllTrial(allSubAllTrial{:,10} == 2, 10) = array2table(0);

% % WWF + Parti_Libertarien + Generation_Identitaire
% allSubAllTrial(allSubAllTrial{:,4} == 1, 44) = allSubAllTrial(allSubAllTrial{:,4} == 1, 22);
% allSubAllTrial(allSubAllTrial{:,4} == 2, 44) = allSubAllTrial(allSubAllTrial{:,4} == 2, 28);
% allSubAllTrial(allSubAllTrial{:,4} == 3, 44) = allSubAllTrial(allSubAllTrial{:,4} == 3, 19);
% allSubAllTrial.Properties.VariableNames(44) = {'orgaBest'};

% R SAYS WWF + Mouvement_Europeen_France + Generation_Identitaire
allSubAllTrial(allSubAllTrial{:,4} == 1, 44) = allSubAllTrial(allSubAllTrial{:,4} == 1, 22);
allSubAllTrial(allSubAllTrial{:,4} == 2, 44) = allSubAllTrial(allSubAllTrial{:,4} == 2, 25);
allSubAllTrial(allSubAllTrial{:,4} == 3, 44) = allSubAllTrial(allSubAllTrial{:,4} == 3, 19);
allSubAllTrial.Properties.VariableNames(44) = {'SuccessorgaBest'};

% R SAYS WWF + Mouvement_Europeen_France + Generation_Identitaire
allSubAllTrial(allSubAllTrial{:,4} == 1, 45) = allSubAllTrial(allSubAllTrial{:,4} == 1, 24);
allSubAllTrial(allSubAllTrial{:,4} == 2, 45) = allSubAllTrial(allSubAllTrial{:,4} == 2, 27);
allSubAllTrial(allSubAllTrial{:,4} == 3, 45) = allSubAllTrial(allSubAllTrial{:,4} == 3, 18);
allSubAllTrial.Properties.VariableNames(45) = {'RecorgaBest'};

% allSubAllTrial(:, 45) = allSubAllTrial(:, 20);
% allSubAllTrial(:, 45) = allSubAllTrial(:, 23);
% allSubAllTrial(:, 45) = allSubAllTrial(:, 25);
% allSubAllTrial.Properties.VariableNames(45) = {'orgaBestHaul'};
% % La_Manif_Pour_Tous + NIPCC + Mouvement_Europeen_France 


clear Brier col ii jj txt var
save Testable_analysis_tables.mat










%% STANDALONE PLOTS

%%% STIMS
% Plot correlation: raters mean ambiguity - raters mean consensuality

figure
scatter(ICC.ambiguity,ICC.split);
hold on
b1 = ICC.ambiguity\ICC.split; %b1 = x\y is mldivide aka: solves the system of linear equations A*x = B.
yCalc1 = b1*(ICC.ambiguity);
plot(ICC.ambiguity,yCalc1);
title('Correlation for each stim between raters mean ambiguity and raters mean consensuality','FontSize',20);
xlabel('Ambiguity','FontSize',20); ylabel('Split','FontSize',20);
ylim([2 10]); xlim([2 10]);

%%% Plot success ~ ambiguity: CHECK NEW PLOS ON BAYES

%%% Plot veracity_judgment ~ ambiguity: PAREIL










%% SUCCESS RATES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL SUCCESS RATE, NORMALITY TESTS AND DISTRIBUTION FITS


% Global success rate
mean(Rec_allSub.data_tables(5).models.freq_1); std(Rec_allSub.data_tables(5).models.freq_1); % m=51.57, sd=6.65
% F = figure; F1= fitmethis(Rec_allSub.group_data(5).group1.freq_1); close(F)

% Normality tests
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(5).group1.freq_1); %h=1, p<.001
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(5).group2.freq_1); %h=1, p<.001
% Rejection of nullhyp for group1 and group 2: Responses don't come from a standard normal distribution

% [p,h,stats] = ranksum(Rec_allSub.group_data(5).group1.freq_1, Rec_allSub.group_data(5).group2.freq_1); % h=1, p=.0034, z=2.9320
% Both distributions significantly different


% Data follows normal before uniform distribution
% F = figure; F1= fitmethis(Rec_allSub.group_data(5).group1.freq_1); close(F)
% F = figure; F2= fitmethis(Rec_allSub.group_data(5).group2.freq_1); close(F)
% Alas, both distrib fit neither normal nor uniform


% In case: Test against uniform distribution with kstest
% ks makes no assumption on theoretical distribution. Therefore, specify an uniform distrib from data vector. >>> Below: column 1 contains the data vector; column 2 contains cdf values evaluated at each value in data vector for a hypothesized uniform distribution with min = minimum of data vector and max = maximum of data vector
% test_cdf = [Rec_allSub.data_tables(5).models.freq_1, unifcdf(Rec_allSub.data_tables(5).models.freq_1, min(Rec_allSub.data_tables(5).models.freq_1),max(Rec_allSub.data_tables(5).models.freq_1))];
% [h,p,ksstat,cv] = kstest(Rec_allSub.data_tables(5).models.freq_1, 'CDF',test_cdf);
% [h,p,ksstat,cv] = kstest(Rec_allSub.data_tables(5).models.freq_1);







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS TRUE vs FALSE, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

clear tempg1 tempg2
fld = fieldnames(Rec_allSub.group_data);
tempg1 = zeros(height(Rec_allSub.group_data(5).group1),2); tempg2 = zeros(height(Rec_allSub.group_data(5).group2),2);
veracity1 = table2array(Rec_allSub.group_data(2).group1(1,1:48)); veracity2 = table2array(Rec_allSub.group_data(2).group2(1,1:48));
for grp = 1:2
    for vrct = 1:2
        for sub = 1:height(Rec_allSub.group_data(5).(fld{grp+1}))
            if grp == 1 && vrct == 1
                tempg1(sub,vrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,veracity1==1))))/24; % count number of successes for veracity == input
            elseif grp == 1 && vrct == 2
                tempg1(sub,vrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,veracity1==0))))/24;
            elseif grp == 2 && vrct == 1
                tempg2(sub,vrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,veracity2==1))))/24;
            elseif grp ==2 && vrct == 2
                tempg2(sub,vrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,veracity2==0))))/24;
            end
        end
    end
end
% ! allSubTruthTrial2Groups is fake_g1, true_g1, fake_g2, true_g2

% Difference in successes between False news and true news for group 1:
% TRUE:  mean(Rec_allSub.allSubTruthTrial2Groups(3).output(:,2),'omitnan'); std(Rec_allSub.allSubTruthTrial2Groups(3).output(:,2),'omitnan'); % m = 65.33, sd = 11.82
% FALSE: mean(Rec_allSub.allSubTruthTrial2Groups(3).output(:,1),'omitnan'); std(Rec_allSub.allSubTruthTrial2Groups(3).output(:,1),'omitnan'); % m = 40.33, sd = 12.44
% [p,h,stats] = signrank(tempg1(:,1), tempg1(:,2)); %h=1, p<.001, z=8.7967

% Difference in successes between True news and False news for group 2
% TRUE:  mean(Rec_allSub.allSubTruthTrial2Groups(3).output(:,4),'omitnan'); std(Rec_allSub.allSubTruthTrial2Groups(3).output(:,4),'omitnan'); % True: m = 62.76, sd = 11.85
% FALSE: mean(Rec_allSub.allSubTruthTrial2Groups(3).output(:,3),'omitnan'); std(Rec_allSub.allSubTruthTrial2Groups(3).output(:,3),'omitnan'); % False: m = 37.88, sd = 11.52
% [p,h,stats] = signrank(tempg2(:,1), tempg2(:,2)); %h=1, p<.001, z=9.2196

% Between (true vs fake regardless of groups)
% TRUE:  mean(Rec_allSub.allSubTruthTrial(3).output(:,2)*100); std(Rec_allSub.allSubTruthTrial(3).output(:,2)*100); % True, % m=64.03, sd=11.88
% FALSE: mean(Rec_allSub.allSubTruthTrial(3).output(:,1)*100); std(Rec_allSub.allSubTruthTrial(3).output(:,1)*100);% False, % m=39.1, sd=12.03
% [p,h,stats]=ranksum(Rec_allSub.allSubTruthTrial(3).output(:,2), Rec_allSub.allSubTruthTrial(3).output(:,1)); % h=1, p<.001, z=16.73

% Difference in successes for TRUE between groups(ranksum = for independent groups)
% [p,h,stats] = ranksum(Rec_allSub.allSubTruthTrial2Groups(3).output(:,2), Rec_allSub.allSubTruthTrial2Groups(3).output(:,4)); 
% h=0, p=.0501, z=1.9595 

% Difference in successes for FALSE between groups(ranksum = for independent groups)
% [p,h,stats] = ranksum(Rec_allSub.allSubTruthTrial2Groups(3).output(:,1), Rec_allSub.allSubTruthTrial2Groups(3).output(:,3)); 
% h=0, p=.2198, z=1.2270





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN FIRST HALF AND SECOND HALF OF THE TASK

m_success_p1 = zeros(nbs,4);    m_success_p2 = zeros(nbs,4);
for ii = 1:nbs
    m_success_p1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}<25,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}<25,9))*100;
    m_success_p1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,9))*100;
    m_success_p1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,9))*100;
    m_success_p1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,9))*100;
    
    m_success_p2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}>24,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}>24,9))*100;
    m_success_p2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,9))*100;
    m_success_p2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,9))*100;
    m_success_p2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,9)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,9))*100;
end

% 1e partie de tâche
% ALL:  mean(m_success_p1(:,1)); std(m_success_p1(:,1)); % m=51.39, sd=9.71
% ECOL: mean(m_success_p1(:,2)); std(m_success_p1(:,2)); % m=51.87, sd=17.46
% DEMO: mean(m_success_p1(:,3)); std(m_success_p1(:,3)); % m=48.58, sd=17.46
% JUST: mean(m_success_p1(:,4)); std(m_success_p1(:,4)); % m=52.90, sd=17.71

% 2e partie de tâche
% ALL:  mean(m_success_p2(:,1)); std(m_success_p2(:,1)); % m=51.65, sd=10.04
% ECOL: mean(m_success_p2(:,2)); std(m_success_p2(:,2)); % m=51.83, sd=17.04
% DEMO: mean(m_success_p2(:,3)); std(m_success_p2(:,3)); % m=47.81, sd=18.27
% JUST: mean(m_success_p2(:,4)); std(m_success_p2(:,4)); % m=54.61, sd=17.44

% Difference:
% [p,h,stats] = signrank(m_success_p1(:,1), m_success_p2(:,1)); % h=0
% [p,h,stats] = signrank(m_success_p1(:,2), m_success_p2(:,2)); % h=0
% [p,h,stats] = signrank(m_success_p1(:,3), m_success_p2(:,3)); % h=0
% [p,h,stats] = signrank(m_success_p1(:,4), m_success_p2(:,4)); % h=0





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS BETWEEN THEMES, REGARDLESS OF GROUPS

% All conditions % ! allSubThemeTrial is the sum of groups ! % 1=Ecol, 2=Demo, 3=Just
% ECOL: mean(Rec_allSub.allSubThemeTrial(3).output(:,1)); std(Rec_allSub.allSubThemeTrial(3).output(:,1)); % m=52.16, sd=11.25
% DEMO: mean(Rec_allSub.allSubThemeTrial(3).output(:,2)); std(Rec_allSub.allSubThemeTrial(3).output(:,2)); % m=48.55, sd=11.53
% JUST: mean(Rec_allSub.allSubThemeTrial(3).output(:,3)); std(Rec_allSub.allSubThemeTrial(3).output(:,3)); % m=53.85, sd=11.78


clear tempg1 tempg2
tempg1 = zeros(height(Rec_allSub.group_data(5).group1),3);  tempg2 = zeros(height(Rec_allSub.group_data(5).group2),3);
themes = double(Rec_allSub.data_tables(1).within.condition);% 1 = Ecol, 2 = Demo, 3 = Just
fld = fieldnames(Rec_allSub.group_data);
for grp = 1:2
    for thm = 1:3
        for sub = 1:height(Rec_allSub.group_data(5).(fld{grp+1}))
            if grp == 1 && thm == 1
                tempg1(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==1))))/16; % count number of successes for themes == input
            elseif grp == 1 && thm == 2
                tempg1(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==2))))/16;
            elseif grp == 1 && thm == 3
                tempg1(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==3))))/16;
            elseif grp == 2 && thm == 1
                tempg2(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==1))))/16;
            elseif grp ==2 && thm == 2
                tempg2(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==2))))/16;
            elseif grp ==2 && thm == 3
                tempg2(sub,thm) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,themes==3))))/16;
            end
        end
    end
end

% Difference in successes between themes, group 1
% ECOL: mean(tempg1(:,1),'omitnan'); std(tempg1(:,1),'omitnan'); % m = 43.41, sd = 11.88
% DEMO: mean(tempg1(:,2),'omitnan'); std(tempg1(:,2),'omitnan'); % m = 63.92, sd = 11.51
% JUST: mean(tempg1(:,3),'omitnan'); std(tempg1(:,3),'omitnan'); % m = 50.88, sd = 12.19

% Difference in successes between themes, group 2
% ECOL: mean(tempg2(:,1),'omitnan'); std(tempg2(:,1),'omitnan'); % m = 50.87, sd = 11.87
% DEMO: mean(tempg2(:,2),'omitnan'); std(tempg2(:,2),'omitnan'); % m = 56.78, sd = 11.12
% JUST: mean(tempg2(:,3),'omitnan'); std(tempg2(:,3),'omitnan'); % m = 43.32, sd = 11.31

% All conditions % ! allSubThemeTrial is the sum of groups ! % 1=Ecol, 2=Demo, 3=Just
% ECOL: mean(Rec_allSub.allSubThemeTrial(3).output(:,1)); std(Rec_allSub.allSubThemeTrial(3).output(:,1)); % m = 52.16, sd = 11.25
% DEMO: mean(Rec_allSub.allSubThemeTrial(3).output(:,2)); std(Rec_allSub.allSubThemeTrial(3).output(:,2)); % m = 48.55, sd = 11.53
% JUST: mean(Rec_allSub.allSubThemeTrial(3).output(:,3)); std(Rec_allSub.allSubThemeTrial(3).output(:,3)); % m = 53.85, sd = 11.78

% Difference in successes between groups(ranksum = for independent groups)
% ECOL: [p,h,stats] = ranksum(tempg1(:,1), tempg2(:,1)); % h=1, p<.001,  z=-4.7625
% DEMO: [p,h,stats] = ranksum(tempg1(:,2), tempg2(:,2)); % h=1, p<.001,  z=4.1372
% JUST: [p,h,stats] = ranksum(tempg1(:,3), tempg2(:,3)); % h=1, p<.001,  z=5.4213


% FRIEDMAN for comparisons
% Col 1 and 2 = indices of the 2 samples compared. % Col 3 = lower confidence interval. % Col 4 = estimate. % Col 5 = upper confidence interval
% Col 6 is p-value for hypothesis test = corresponding mean difference is not equal to 0.
% [p,tbl,stats1]=friedman(tempg1); c = multcompare(stats1,'CType','bonferroni'); % Statistic difference between: 1 and 2, 2 and 3
% [p,tbl,stats2]=friedman(tempg2); c = multcompare(stats2,'CType','bonferroni'); % Statistic difference between the 3 groups
% % Between
% [p,tbl,stats]=friedman(allSubThemeTrial(3).output); c = multcompare(stats,'CType','bonferroni'); % Diff between 1 and 2, 2 and 3, not 1 and 3





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% clear tempg1 tempg2
% themes = double(Rec_allSub.data_tables(1).within.condition);% 1 = Ecol, 2 = Demo, 3 = Just
% veracity1 = table2array(Rec_allSub.group_data(2).group1(1,1:48)); veracity2 = table2array(Rec_allSub.group_data(2).group2(1,1:48)); cond(:,1) = themes; cond(:,2) = veracity1'; cond(:,3) = veracity2';
% for grp = 1:2,    for ii = 1:length(cond),        if cond(ii,1) == 1 && cond(ii,1+grp) == 0
%             cond(ii,3+grp) = 1; %Ecol false
%         elseif cond(ii,1) == 1 && cond(ii,1+grp) == 1
%             cond(ii,3+grp) = 2; %Ecol true
%         elseif cond(ii,1) == 2 && cond(ii,1+grp) == 0
%             cond(ii,3+grp) = 3; %Demo false
%         elseif cond(ii,1) == 2 && cond(ii,1+grp) == 1
%             cond(ii,3+grp) = 4; %Demo true
%         elseif cond(ii,1) == 3 && cond(ii,1+grp) == 0
%             cond(ii,3+grp) = 5; %Just false
%         elseif cond(ii,1) == 3 && cond(ii,1+grp) == 1
%             cond(ii,3+grp) = 6; %Just true
%         end
%     end
% end
%
% themes = double(Rec_allSub.data_tables(1).within.condition);% 1 = Ecol, 2 = Demo, 3 = Just
% veracity1 = table2array(Rec_allSub.group_data(2).group1(1,1:48)); veracity2 = table2array(Rec_allSub.group_data(2).group2(1,1:48)); cond(:,1) = themes; cond(:,2) = veracity1'; cond(:,3) = veracity2';
% thmvrct1 = cond(:,4); thmvrct2 = cond(:,5);
% fld = fieldnames(Rec_allSub.group_data);
% clear tempg1 tempg2
% for grp = 1:2,    for thmvrct = 1:6,        for sub = 1:height(Rec_allSub.group_data(5).(fld{grp+1}))
%             if grp == 1
%                 tempg1(sub,thmvrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,thmvrct1==thmvrct))))/8;
%             elseif grp == 2
%                 tempg2(sub,thmvrct) = sum(table2array((Rec_allSub.group_data(5).(fld{grp+1})(sub,thmvrct1==thmvrct))))/8;
%             end
%         end
%     end
% end

% All conditions % ! allSubThemeTrial is the sum of groups ! % 1=Ecol false, 2=Ecol true,, 3=Demo false, 4=Demo true, 5=Just false, 6=Just true
% ECOL FALSE: mean(Rec_allSub.allSubMeanTrial(3).output(:,1))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,1))*100; % m=35.17, sd=18.20
% DEMO FALSE: mean(Rec_allSub.allSubMeanTrial(3).output(:,3))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,3))*100; % m=41.91, sd=17.42
% JUST FALSE: mean(Rec_allSub.allSubMeanTrial(3).output(:,5))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,5))*100; % m=40.21, sd=18.28

% ECOL TRUE:  mean(Rec_allSub.allSubMeanTrial(3).output(:,2))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,2))*100; % m=69.28, sd=17.05
% DEMO TRUE:  mean(Rec_allSub.allSubMeanTrial(3).output(:,4))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,4))*100; % m=55.38, sd=19.93
% JUST TRUE:  mean(Rec_allSub.allSubMeanTrial(3).output(:,6))*100; std(Rec_allSub.allSubMeanTrial(3).output(:,6))*100; % m=67.44, sd=17.43

% ALL : [p,h,stats] = signrank(Rec_allSub.allSubTruthTrial(3).output(:,1), Rec_allSub.allSubTruthTrial(3).output(:,2)); % h=1, p<.001,  z=-12.72
% ECOL: [p,h,stats] = signrank(Rec_allSub.allSubMeanTrial(3).output(:,1), Rec_allSub.allSubMeanTrial(3).output(:,2)); % h=1, p<.001,  z=-12.31
% DEMO: [p,h,stats] = signrank(Rec_allSub.allSubMeanTrial(3).output(:,3), Rec_allSub.allSubMeanTrial(3).output(:,4)); % h=1, p<.001,  z=-7.04
% JUST: [p,h,stats] = signrank(Rec_allSub.allSubMeanTrial(3).output(:,5), Rec_allSub.allSubMeanTrial(3).output(:,6)); % h=1, p<.001,  z=-11.56





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

m_success_year1 = zeros(nbs2, 4); m_success_year2 = zeros(nbs3, 4);
for ii = 1:nbs2
    m_success_year1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,9))*100;
    m_success_year1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))*100;
    m_success_year1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))*100;
    m_success_year1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))*100;
end
for ii = 1:nbs3
    m_success_year2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,40}==2,9))*100;
    m_success_year2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))*100;
    m_success_year2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))*100;
    m_success_year2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))*100;
end

% All : [p,h,stats] = ranksum(m_success_year1(:,1), m_success_year2(:,1)); 
% ECOL: [p,h,stats] = ranksum(m_success_year1(:,2), m_success_year2(:,2)); 
% DEMO: [p,h,stats] = ranksum(m_success_year1(:,3), m_success_year2(:,3)); % h=1, p=.0147, z=-2.4388
% JUST: [p,h,stats] = ranksum(m_success_year1(:,4), m_success_year2(:,4));










%% VERACITY JUDGMENT
% No need to compare performances within groups and between groups for anything else than success rates

% Create a veracity judgment table:
veracity_judgment = Rec_allSub.data_tables(3).models;
for ii = 1:48
    veracity_judgment(veracity_judgment{:,ii}>0,ii) = array2table(1);
    veracity_judgment(veracity_judgment{:,ii}<0,ii) = array2table(0);
end
veracity_judgment(:,51:52) = array2table(veracity_judgment{:,49:50}/48); veracity_judgment(:,53:54) = [];
for ii = 1:height(veracity_judgment)
    veracity_judgment(ii,53) = array2table((sum(veracity_judgment{ii,1:16})/16)*100); veracity_judgment(ii,54) = array2table(100 - veracity_judgment{ii,53});
    veracity_judgment(ii,55) = array2table((sum(veracity_judgment{ii,17:32})/16)*100); veracity_judgment(ii,56) = array2table(100 - veracity_judgment{ii,55});
    veracity_judgment(ii,57) = array2table((sum(veracity_judgment{ii,33:48})/16)*100); veracity_judgment(ii,58) = array2table(100 - veracity_judgment{ii,57});
end
%%% count_neg and count_pos = nb judged as false and nb judged as true; mean_neg and mean_pos = percentage
%%% scoreDemoPos, etc. = frequency of judged as true or false for stim in the corresponding condition





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL JUDGMENT RATE, NORMALITY TESTS AND DISTRIBUTION FITS

% Global 
% JUDGED AS TRUE:  mean(veracity_judgment.mean_pos); std(veracity_judgment.mean_pos); % m=59.54, sd=10.60
% JUDGED AS FALSE: mean(veracity_judgment.mean_neg); std(veracity_judgment.mean_neg); % m=39.79, sd=10.51

% Group 1
% JUDGED AS TRUE:  mean((Rec_allSub.group_data(3).group1.count_pos/48)*100); std((Rec_allSub.group_data(3).group1.count_pos/48)*100); % m=59.78, sd=10.40
% JUDGED AS FALSE: mean((Rec_allSub.group_data(3).group1.count_neg/48)*100); std((Rec_allSub.group_data(3).group1.count_neg/48)*100); % m=39.39, sd=10.10
% Group 2
% JUDGED AS TRUE:  mean((Rec_allSub.group_data(3).group2.count_pos/48)*100); std((Rec_allSub.group_data(3).group2.count_pos/48)*100); % m=59.30, sd=10.82
% JUDGED AS FALSE: mean((Rec_allSub.group_data(3).group2.count_neg/48)*100); std((Rec_allSub.group_data(3).group2.count_neg/48)*100); % m=40.18, sd=10.92

% [h,p,ksstat,cv] = kstest(veracity_judgment.mean_pos);
% Data doesn't come from normal distribution: h=1, p<.001, D=0.6268

% [p,h,z] = ranksum(Rec_allSub.group_data(3).group1.count_pos, Rec_allSub.group_data(3).group2.count_pos);
% Data from both groups come from same distribution: h=0, p=.5293, z=0.6921

% F= figure; F1= fitmethis(veracity_judgment.mean_pos); close(F)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS TRUE vs FALSE, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% TRUE
% mean(Rec_allSub.allSubTruthTrial(8).output(:,2)*100, 'omitnan'); std(Rec_allSub.allSubTruthTrial(8).output(:,2)*100, 'omitnan'); % m=60.89, sd=12.66
% sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==1,8)))/height(allSubAllTrial(allSubAllTrial{:,5}==1,8)); % Says the same thing
% FALSE
% mean(Rec_allSub.allSubTruthTrial(8).output(:,1)*100, 'omitnan'); std(Rec_allSub.allSubTruthTrial(8).output(:,1)*100, 'omitnan'); % m=58.20, sd=13.09
% sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==0,8)))/height(allSubAllTrial(allSubAllTrial{:,5}==0,8)) % Says the same thing
% Meaning 60% of true news were judged as true!! AND 58% of fake news were judged as true
% Meaning 40% of true news were judged as fake AND 42% of fake news were judged as fake

% [p,h,stats]=ranksum(Rec_allSub.allSubTruthTrial(8).output(:,2), Rec_allSub.allSubTruthTrial(8).output(:,1)); % h=1, p=.0444, z=2.01
% Difference but idgaf no ?

% Comparaison entre, pour news vraies, taux de jugement as true et taux de jugement as false
% [p,h,stats]  = kstest2(Rec_allSub.allSubTruthTrial(8).output(:,2)*100, (100-Rec_allSub.allSubTruthTrial(8).output(:,2)*100)) % h=1
% Comparaison entre, pour news fausses, taux de jugement as true et taux de jugement as false
% [p,h,stats]  = kstest2(Rec_allSub.allSubTruthTrial(8).output(:,1)*100, (100-Rec_allSub.allSubTruthTrial(8).output(:,1)*100)) % h=1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN EACH THEME, NO GROUP

% All conditions % ! allSubThemeTrial is the sum of groups ! % 1=Ecol, 2=Demo, 3=Just
% ECOL: mean(Rec_allSub.allSubThemeTrial(8).output(:,1)); std(Rec_allSub.allSubThemeTrial(8).output(:,1)); % m=64.46, sd=14.11
% DEMO: mean(Rec_allSub.allSubThemeTrial(8).output(:,2)); std(Rec_allSub.allSubThemeTrial(8).output(:,2)); % m=53.27, sd=15.59
% JUST: mean(Rec_allSub.allSubThemeTrial(8).output(:,3)); std(Rec_allSub.allSubThemeTrial(8).output(:,3)); % m=60.90, sd=12.72





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN FIRST HALF AND SECOND HALF OF THE TASK

m_judgment_p1 = zeros(nbs,4);    m_judgment_p2 = zeros(nbs,4);
for ii = 1:nbs
    m_judgment_p1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}<25,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}<25,8))*100;
    m_judgment_p1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,8))*100;
    m_judgment_p1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,8))*100;
    m_judgment_p1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,8))*100;
    
    m_judgment_p2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}>24,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,42}>24,8))*100;
    m_judgment_p2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,8))*100;
    m_judgment_p2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,8))*100;
    m_judgment_p2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,8)))/height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,8))*100;
end

% 1e partie de tâche
% ALL:  mean(m_judgment_p1(:,1)); std(m_judgment_p1(:,1)); % m=58.79, sd=12.03
% ECOL: mean(m_judgment_p1(:,2)); std(m_judgment_p1(:,2)); % m=64.77, sd=12.28
% DEMO: mean(m_judgment_p1(:,3)); std(m_judgment_p1(:,3)); % m=51.33, sd=19.77
% JUST: mean(m_judgment_p1(:,4)); std(m_judgment_p1(:,4)); % m=60.17, sd=15.85

% 2e partie de tâche
% ALL:  mean(m_judgment_p2(:,1)); std(m_judgment_p2(:,1)); % m=60.3, sd=13.09
% ECOL: mean(m_judgment_p2(:,2)); std(m_judgment_p2(:,2)); % m=63.99, sd=19.27
% DEMO: mean(m_judgment_p2(:,3)); std(m_judgment_p2(:,3)); % m=55.19, sd=20.89
% JUST: mean(m_judgment_p2(:,4)); std(m_judgment_p2(:,4)); % m=61.50 sd=18.49

% Difference:
% [p,h,stats] = signrank(m_judgment_p1(:,1), m_judgment_p2(:,1)); % h=0
% [p,h,stats] = signrank(m_judgment_p1(:,2), m_judgment_p2(:,2)); % h=0
% [p,h,stats] = signrank(m_judgment_p1(:,3), m_judgment_p2(:,3)); % h=1
% [p,h,stats] = signrank(m_judgment_p1(:,4), m_judgment_p2(:,4)); % h=0
%%% Behavior changed during the course of the experiment: but can't wrap my mind around it





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% themes = double(Rec_allSub.data_tables(1).within.condition);% 1 = Ecol, 2 = Demo, 3 = Just
% veracity1 = table2array(Rec_allSub.group_data(2).group1(1,1:48)); veracity2 = table2array(Rec_allSub.group_data(2).group2(1,1:48)); cond(:,1) = themes; cond(:,2) = veracity1'; cond(:,3) = veracity2';

% All conditions % ! allSubThemeTrial is the sum of groups ! % 1=Ecol false, 2=Ecol true,, 3=Demo false, 4=Demo true, 5=Just false, 6=Just true
% ECOL FALSE:  mean(Rec_allSub.allSubMeanTrial(8).output(:,1)); std(Rec_allSub.allSubMeanTrial(8).output(:,1)); % m=61.00, sd=18.24
% DEMO FALSE:  mean(Rec_allSub.allSubMeanTrial(8).output(:,3)); std(Rec_allSub.allSubMeanTrial(8).output(:,3)); % m=56.15, sd=19.04
% JUST FALSE:  mean(Rec_allSub.allSubMeanTrial(8).output(:,5)); std(Rec_allSub.allSubMeanTrial(8).output(:,5)); % m=57.46, sd=17.85

% ECOL TRUE:   mean(Rec_allSub.allSubMeanTrial(8).output(:,2)); std(Rec_allSub.allSubMeanTrial(8).output(:,2)); % m=67.93, sd=17.97
% DEMO TRUE:   mean(Rec_allSub.allSubMeanTrial(8).output(:,4)); std(Rec_allSub.allSubMeanTrial(8).output(:,4)); % m=50.39, sd=21.09
% JUST TRUE:   mean(Rec_allSub.allSubMeanTrial(8).output(:,6)); std(Rec_allSub.allSubMeanTrial(8).output(:,6)); % m=64.34, sd=17.41





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

m_judgment_year1 = zeros(nbs2, 8); m_judgment_year2 = zeros(nbs3, 8);
for ii = 1:nbs2
    m_judgment_year1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,8))*100;
    m_judgment_year1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,8))*100;
    m_judgment_year1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,8))*100;
    m_judgment_year1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,8))*100;
end
for ii = 1:nbs3
    m_judgment_year2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,40}==2,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,40}==2,8))*100;
    m_judgment_year2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,8))*100;
    m_judgment_year2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,8))*100;
    m_judgment_year2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,8))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,8))*100;
end

% All  [p,h,stats] = ranksum(m_judgment_year1(:,1), m_judgment_year2(:,1)); % h=0
% ECOL [p,h,stats] = ranksum(m_judgment_year1(:,2), m_judgment_year2(:,2)); % h=0
% DEMO [p,h,stats] = ranksum(m_judgment_year1(:,3), m_judgment_year2(:,3)); % h=0
% JUST [p,h,stats] = ranksum(m_judgment_year1(:,4), m_judgment_year2(:,4)); % h=0










%% CONFIDENCE VALUES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL CONFIDENCE VALUES, NORMALITY TESTS AND DISTRIBUTION FITS


% No need to compare performances within groups and between groups for anything else than success rates
% Though:
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(3).group1.mean_pos);    [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(3).group1.mean_neg);
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(3).group2.mean_pos);    [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(3).group2.mean_neg);
% Data don't come from normal distribution: h=1, p<.001

% [p,h,stat] = ranksum(Rec_allSub.group_data(3).group1.mean_pos, Rec_allSub.group_data(3).group2.mean_pos); % h=0, p=.6178, z=-0.4989
% [p,h,stat] = ranksum(Rec_allSub.group_data(3).group1.mean_neg, Rec_allSub.group_data(3).group2.mean_neg); % h=0, p=.7703, z=-0.292
% Conclusion: 0 diff between group1 and group2 distributions
% Therefore can pool the data


% Matlab file exchange function 'fitmethis' returns Uniform as well as best fitting (AIC criterion)
% F=figure; F1= fitmethis(Rec_allSub.data_tables(3).models.mean_pos); close(F)
% Fits kernel but looks like normal





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS TRUE vs FALSE, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% COMPARISONS REGARDLESS OF GROUPS BETWEEN TRUE NEWS AND FALSE NEWS
% TRUE, POS VALUES:  mean(Rec_allSub.allSubTruthTrial(1).outputPos(:,2), 'omitnan'); std(Rec_allSub.allSubTruthTrial(1).outputPos(:,2), 'omitnan'); % m=55.06, sd=17.21
% TRUE, NEG VALUES:  mean(Rec_allSub.allSubTruthTrial(1).outputNeg(:,2), 'omitnan'); std(Rec_allSub.allSubTruthTrial(1).outputNeg(:,2), 'omitnan'); % m=-53.84, sd=18.49

% FALSE, POS VALUES: mean(Rec_allSub.allSubTruthTrial(1).outputPos(:,1), 'omitnan'); std(Rec_allSub.allSubTruthTrial(1).outputPos(:,1), 'omitnan'); % m=54.17, sd=16.94
% FALSE, POS VALUES: mean(Rec_allSub.allSubTruthTrial(1).outputNeg(:,1), 'omitnan'); std(Rec_allSub.allSubTruthTrial(1).outputNeg(:,1), 'omitnan'); % m=-54.98, sd=19.20

% [p,h,stats]=ranksum(Rec_allSub.allSubTruthTrial(1).outputPos(:,2), Rec_allSub.allSubTruthTrial(1).outputPos(:,1)); % h=0, p=.5093, z=0.6599
% [p,h,stats]=ranksum(Rec_allSub.allSubTruthTrial(1).outputNeg(:,2), Rec_allSub.allSubTruthTrial(1).outputNeg(:,1)); % h=0, p=.5315, z=0.6257
% 0 diff for Confidence_degree distributions between true and fake news





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN EACH THEME, NO GROUP

% ECOL, POS VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputPos(:,1));            std(Rec_allSub.allSubThemeTrial(1).outputPos(:,1));           % m=56.86, sd=17.73
% DEMO, POS VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputPos(:,2),'omitnan');  std(Rec_allSub.allSubThemeTrial(1).outputPos(:,2),'omitnan'); % m=48.89, sd=18.40
% JUST, POS VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputPos(:,3));            std(Rec_allSub.allSubThemeTrial(1).outputPos(:,3));           % m=57.49, sd=17.75

% ECOL, NEG VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputNeg(:,1),'omitnan'); std(Rec_allSub.allSubThemeTrial(1).outputNeg(:,1),'omitnan'); % Ecol, % m=-52.65, sd=20.16
% DEMO, NEG VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputNeg(:,2),'omitnan'); std(Rec_allSub.allSubThemeTrial(1).outputNeg(:,2),'omitnan'); % Demo, % m=-53.48, sd=19.45
% JUST, NEG VALUES: mean(Rec_allSub.allSubThemeTrial(1).outputNeg(:,3),'omitnan'); std(Rec_allSub.allSubThemeTrial(1).outputNeg(:,3),'omitnan'); % Just, % m=-57.06, sd=19.55

m_conf = zeros(nbs,4);    
for ii = 1:nbs
    m_conf(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii,6)));
    m_conf(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1,6)));
    m_conf(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2,6)));
    m_conf(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3,6)));
end
% ALL:  mean(m_conf(:,1)); std(m_conf(:,1));  % m=54.5281, sd=16.2854
% ECOL: mean(m_conf(:,2)); std(m_conf(:,2));  % m=55.4128, sd=14.6216
% DEMO: mean(m_conf(:,3)); std(m_conf(:,3));  % m=51.0940, sd=17.1790
% JUST: mean(m_conf(:,4)); std(m_conf(:,4));  % m=57.0775, sd=16.7610




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% POS VALUES
% ECOL FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,1),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,1),'omitnan'); % m=56.01, sd=169.44
% DEMO FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,3),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,3),'omitnan'); % m=48.83, sd=19.71
% JUST FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,5),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,5),'omitnan'); % m=57.54, sd=18.90
% ECOL TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,2),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,2),'omitnan'); % m=57.43, sd=18.69
% DEMO TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,4),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,4),'omitnan'); % m=48.71, sd=20.77
% JUST TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputPos(:,6),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputPos(:,6),'omitnan'); % m=57.48, sd=19.72

% NEG VALUES
% ECOL FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,1),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,1),'omitnan'); % m=-53.01, sd=21.26
% DEMO FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,3),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,3),'omitnan'); % m=-53.79, sd=21.49
% JUST FALSE: mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,5),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,5),'omitnan'); % m=-58.85, sd=23.01
% ECOL TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,2),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,2),'omitnan'); % m=-52.83, sd=23.53
% DEMO TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,4),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,4),'omitnan'); % m=-53.80, sd=20.74
% JUST TRUE:  mean(Rec_allSub.allSubMeanTrial(1).outputNeg(:,6),'omitnan'); std(Rec_allSub.allSubMeanTrial(1).outputNeg(:,6),'omitnan'); % m=-54.14, sd=22.01





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

m_confidence_year1 = zeros(nbs2, 2); m_confidence_year2 = zeros(nbs3, 2);
for ii = 1:nbs2
    m_confidence_year1(ii,1) = sum(table2array(plots_data(plots_data{:,1}==ii & plots_data{:,40}==1 & plots_data{:,6} <0, 6))) /height(plots_data(plots_data{:,1}==ii & plots_data{:,40}==1 & plots_data{:,6} <0, 6))*100;
    m_confidence_year1(ii,2) = sum(table2array(plots_data(plots_data{:,1}==ii & plots_data{:,40}==1 & plots_data{:,6} >0, 6))) /height(plots_data(plots_data{:,1}==ii & plots_data{:,40}==1 & plots_data{:,6} >0, 6))*100;
end
for ii = 1:nbs3
    m_confidence_year2(ii,1) = sum(table2array(plots_data(plots_data{:,1}==ii & plots_data{:,40}==2 & plots_data{:,6} <0, 6))) /height(plots_data(plots_data{:,1}==ii & plots_data{:,40}==2 & plots_data{:,6} <0, 6))*100;
    m_confidence_year2(ii,2) = sum(table2array(plots_data(plots_data{:,1}==ii & plots_data{:,40}==2 & plots_data{:,6} >0, 6))) /height(plots_data(plots_data{:,1}==ii & plots_data{:,40}==2 & plots_data{:,6} >0, 6))*100;
end

% [p,h,stats] = ranksum(m_confidence_year1(:,1), m_confidence_year2(:,1)); % h=0
% [p,h,stats] = ranksum(m_confidence_year1(:,2), m_confidence_year2(:,2)); % h=0





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN FIRST HALF AND SECOND HALF OF THE TASK

m_conf_pos_p1 = zeros(nbs,4);    m_conf_pos_p2 = zeros(nbs,4);      m_conf_neg_p1 = zeros(nbs,4);    m_conf_neg_p2 = zeros(nbs,4);
for ii = 1:nbs
    m_conf_pos_p1(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,42}<25,6)));
    m_conf_pos_p1(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,6)));
    m_conf_pos_p1(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,6)));
    m_conf_pos_p1(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,6)));
    
    m_conf_pos_p2(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,42}>24,6)));
    m_conf_pos_p2(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,6)));
    m_conf_pos_p2(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,6)));
    m_conf_pos_p2(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,6)));
    
    m_conf_neg_p1(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,42}<25,6)));
    m_conf_neg_p1(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}<25,6)));
    m_conf_neg_p1(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}<25,6)));
    m_conf_neg_p1(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}<25,6)));
    
    m_conf_neg_p2(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,42}>24,6)));
    m_conf_neg_p2(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,42}>24,6)));
    m_conf_neg_p2(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,42}>24,6)));
    m_conf_neg_p2(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,8}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,42}>24,6)));
end

% 1e partie de tâche
% POS
% ALL:  mean(m_conf_pos_p1(:,1)); std(m_conf_pos_p1(:,1));                      % m=54.5057, sd=16.51
% ECOL: mean(m_conf_pos_p1(:,2)); std(m_conf_pos_p1(:,2));                      % m=56.7612, sd=19.5249
% DEMO: mean(m_conf_pos_p1(:,3),'omitnan'); std(m_conf_pos_p1(:,3),'omitnan');  % m=48.8985, sd=19.3048
% JUST: mean(m_conf_pos_p1(:,4)); std(m_conf_pos_p1(:,4));                      % m=57.3487, sd=18.4819

% NEG
% ALL:  mean(m_conf_neg_p1(:,1)); std(m_conf_neg_p1(:,1));                      % m=53.5146, sd=18.5353
% ECOL: mean(m_conf_neg_p1(:,2),'omitnan'); std(m_conf_neg_p1(:,2),'omitnan');  % m=51.5616, sd=22.4128
% DEMO: mean(m_conf_neg_p1(:,3),'omitnan'); std(m_conf_neg_p1(:,3),'omitnan');  % m=51.7986, sd=20.8896
% JUST: mean(m_conf_neg_p1(:,4),'omitnan'); std(m_conf_neg_p1(:,4),'omitnan');  % m=55.6942, sd=21.5147

% 2e partie de tâche
% POS
% ALL:  mean(m_conf_pos_p2(:,1)); std(m_conf_pos_p2(:,1));                      % m=54.5536, sd=18.2587
% ECOL: mean(m_conf_pos_p2(:,2),'omitnan'); std(m_conf_pos_p2(:,2),'omitnan');  % m=56.3271, sd=19.8849
% DEMO: mean(m_conf_pos_p2(:,3),'omitnan'); std(m_conf_pos_p2(:,3),'omitnan');  % m=49.0425, sd=21.1226
% JUST: mean(m_conf_pos_p2(:,4)); std(m_conf_pos_p2(:,4));                      % m=57.6895, sd=20.4776


% NEG
% ALL:  mean(m_conf_neg_p2(:,1),'omitnan'); std(m_conf_neg_p2(:,1),'omitnan'); % m=53.9112, sd=20.0486
% ECOL: mean(m_conf_neg_p2(:,2),'omitnan'); std(m_conf_neg_p2(:,2),'omitnan'); % m=52.6266, sd=23.1498
% DEMO: mean(m_conf_neg_p2(:,3),'omitnan'); std(m_conf_neg_p2(:,3),'omitnan'); % m=53.9288, sd=22.4666
% JUST: mean(m_conf_neg_p2(:,4),'omitnan'); std(m_conf_neg_p2(:,4),'omitnan'); % m=55.8273, sd=23.3988

% Difference:
% [p,h,stats] = signrank(m_conf_pos_p1(:,1), m_conf_pos_p2(:,1)); % h=0
% [p,h,stats] = signrank(m_conf_pos_p1(:,2), m_conf_pos_p2(:,2)); % h=0
% [p,h,stats] = signrank(m_conf_pos_p1(:,3), m_conf_pos_p2(:,3)); % h=0
% [p,h,stats] = signrank(m_conf_pos_p1(:,4), m_conf_pos_p2(:,4)); % h=0

% [p,h,stats] = signrank(m_conf_neg_p1(:,1), m_conf_neg_p2(:,1)); % h=0
% [p,h,stats] = signrank(m_conf_neg_p1(:,2), m_conf_neg_p2(:,2)); % h=0
% [p,h,stats] = signrank(m_conf_neg_p1(:,3), m_conf_neg_p2(:,3)); % h=0
% [p,h,stats] = signrank(m_conf_neg_p1(:,4), m_conf_neg_p2(:,4)); % h=0
















%% RECEPTION DESIRABILITY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL RECEPTION RATE, NORMALITY TESTS AND DISTRIBUTION FITS

clear x_sum x1_sum x2_sum x3_sum x4_sum x5_sum
[x_sum, x1_sum, x2_sum, x3_sum, x4_sum, x5_sum] = deal(double.empty(0,1));
for ii = 1:nbs
    tmp = allSubAllTrial(allSubAllTrial.subject == ii, :);
    x_sum(end+1) = sum(tmp.rec)/length(tmp.rec);                                % mean=42.29, sd=31.9
    x1_sum(end+1) = sum(tmp.rec(tmp.theme==1))/length(tmp.rec(tmp.theme==1));   % mean=43.27, sd=33.67
    x2_sum(end+1) = sum(tmp.rec(tmp.theme==2))/length(tmp.rec(tmp.theme==2));   % mean=41.04, sd=33.16
    x3_sum(end+1) = sum(tmp.rec(tmp.theme==3))/length(tmp.rec(tmp.theme==3));   % mean=42.56, sd=33.08

    x4_sum(end+1) = sum(tmp.rec(tmp.judgment==1))/length(tmp.rec(tmp.judgment==1)); % mean=43.79, sd=33.31
    x5_sum(end+1) = sum(tmp.rec(tmp.judgment==0))/length(tmp.rec(tmp.judgment==0)); % mean=40.6, sd=32.78
end

% Number of subjects that want to receive 0 news
size(Rec_allSub.data_tables(6).models(Rec_allSub.data_tables(6).models{:,50} == 0, 50),1); % n=55
% Number of subjects that want to receive all news
size(Rec_allSub.data_tables(6).models(Rec_allSub.data_tables(6).models{:,50} == 100, 50),1); % n=0


% idgav but
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(6).group1.freq_1);
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(6).group2.freq_1);
% Data doesn't come from normal distribution: h=1, p<.001

% [h,p,ksstat2] = kstest2(Rec_allSub.group_data(6).group1.freq_1, Rec_allSub.group_data(6).group2.freq_1); % h=0, p=.8978, ksstat=0.0702
% [p,h,stat] = ranksum(Rec_allSub.group_data(6).group1.freq_1, Rec_allSub.group_data(6).group2.freq_1);
% Conclusion: 0 diff between group1 and group2 distributions

% Matlab file exchange function 'fitmethis' returns Uniform as well as best fitting (AIC criterion)
% F=figure; F1= fitmethis(Rec_allSub.data_tables(6).models.freq_1); close(F)





% COMPARISONS REGARDLESS OF GROUPS BETWEEN TRUE NEWS AND FALSE NEWS
% TRUE:  mean(Rec_allSub.allSubTruthTrial(4).output(:,2)); std(Rec_allSub.allSubTruthTrial(4).output(:,2)); % m=42.07, sd=32.14
% FALSE: mean(Rec_allSub.allSubTruthTrial(4).output(:,1)); std(Rec_allSub.allSubTruthTrial(4).output(:,1)); % m=42.51, sd=32.44
% [p,h,stats] = ranksum(Rec_allSub.allSubTruthTrial(4).output(:,1), Rec_allSub.allSubTruthTrial(4).output(:,2)); % h=0





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS REGARDLESS OF GROUPS BETWEEN NEWS JUDGED AS TRUE AND FALSE

% JUDGED AS TRUE:  mean(Rec_allSub.allSubJudgTrial(4).output(:,2)); std(Rec_allSub.allSubJudgTrial(4).output(:,2)); % m=43.79, sd=33.31
% JUDGED AS FALSE: mean(Rec_allSub.allSubJudgTrial(4).output(:,1)); std(Rec_allSub.allSubJudgTrial(4).output(:,1)); % m=40.60, sd=32.78
% [p,h,stats] = ranksum(Rec_allSub.allSubJudgTrial(4).output(:,2), Rec_allSub.allSubJudgTrial(4).output(:,1)); %h=0





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN EACH THEME, NO GROUP

% ECOL: mean(Rec_allSub.allSubThemeTrial(4).output(:,1)); std(Rec_allSub.allSubThemeTrial(4).output(:,1)); % m=43.27, sd=33.67
% DEMO: mean(Rec_allSub.allSubThemeTrial(4).output(:,2)); std(Rec_allSub.allSubThemeTrial(4).output(:,2)); % m=41.04, sd=33.16
% JUST: mean(Rec_allSub.allSubThemeTrial(4).output(:,3)); std(Rec_allSub.allSubThemeTrial(4).output(:,3)); % m=42.56, sd=33.08





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS
% 1=Ecol false, 2=Ecol true,, 3=Demo false, 4=Demo true, 5=Just false, 6=Just true

m_rec = zeros(nbs,6);
for ii = 1:nbs
    m_rec(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1,10))*100;
    m_rec(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2,10))*100;
    m_rec(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3,10))*100;
    
    m_rec(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1,10))*100;
    m_rec(ii,5) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2,10))*100;
    m_rec(ii,6) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==3,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3,10))*100;
end

% ECOL FALSE: mean(m_rec(:,1)); std(m_rec(:,1)); % m=43.70, sd=34.63
% DEMO FALSE: mean(m_rec(:,2)); std(m_rec(:,2)); % m=41.18, sd=34.59
% JUST FALSE: mean(m_rec(:,3)); std(m_rec(:,3)); % m=42.64, sd=34.47

% ECOL TRUE: mean(m_rec(:,4)); std(m_rec(:,4)); % m=42.83, sd=35.02
% DEMO TRUE: mean(m_rec(:,5)); std(m_rec(:,5)); % m=40.89, sd=34.74
% JUST TRUE: mean(m_rec(:,6)); std(m_rec(:,6)); % m=42.49, sd=34.06





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

m_rec_year1 = zeros(nbs2,4); m_rec_year2 = zeros(nbs3,4);
for ii = 1:nbs2
    m_rec_year1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==1,10))*100;
    m_rec_year1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))*100;
    m_rec_year1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))*100;
    m_rec_year1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))*100;
end
for ii = 1:nbs3
    m_rec_year2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,40}==2,10))*100;
    m_rec_year2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))*100;
    m_rec_year2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))*100;
    m_rec_year2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))*100;
end

% All  [p,h,stats] = ranksum(m_rec_year1(:,1), m_rec_year2(:,1)); % h=0
% ECOL [p,h,stats] = ranksum(m_rec_year1(:,2), m_rec_year2(:,2)); % h=0
% DEMO [p,h,stats] = ranksum(m_rec_year1(:,3), m_rec_year2(:,3)); % h=0
% JUST [p,h,stats] = ranksum(m_rec_year1(:,4), m_rec_year2(:,4)); % h=0





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRELATION BETWEEN RECEPTION AND DESIRABILITY

clear temp
temp(:,1) = ICC(:,2); temp(:,2) = ICC(:,7);
temp(1:48,3) = array2table(Rec_allSub.group_data(1).group1{1,1:48}'); temp(49:96,3) = array2table(Rec_allSub.group_data(1).group2{1,1:48}');
for stim = 1:48
    temp(stim,4) = array2table(sum(Rec_allSub.group_data(6).group1{:,stim})/height(Rec_allSub.group_data(6).group1)); 
    temp(stim+48,4) = array2table(sum(Rec_allSub.group_data(6).group2{:,stim})/height(Rec_allSub.group_data(6).group2));
    %temp(stim,5) = array2table(mean(Rec_allSub.group_data(8).group1{:,stim})); temp(stim+48,5) = array2table(mean(Rec_allSub.group_data(8).group2{:,stim})); This line is for WTP. But WTP is for both receiving and refusing. Can't mix it up. No sense this line Val
end
[rho, pval] = corr(temp{:,2}, temp{:,4},'Type','Pearson','rows','complete'); % p<.001, rho=0.3489


figure
scatter(temp{:,2},temp{:,4});
hold on
temp(21,:) = [];
b1 = temp{:,2}\temp{:,4}; %b1 = x\y is mldivide aka: solves the system of linear equations A*x = B.
yCalc1 = b1*(temp{:,2});
plot(temp{:,2},yCalc1);
title('Correlation for each stim between raters mean desirability and receivers mean desirability','FontSize',20);
xlabel('Raters desirability','FontSize',20); ylabel('Receivers derisability','FontSize',20);
ylim([0 1]);


% Correlation veracity judgment ~ ambiguity
clear test tmp
idnews = plots_data{1:48,3}; idnews(49:96) = plots_data{97:144,3}; tmp = zeros(96,4);
for id = 1:96
    tmp(id,1) = mean(table2array(plots_data(plots_data{:,3}==idnews(id),3))); % Stim idnews
    tmp(id,2) = sum(table2array(plots_data(plots_data{:,3}==idnews(id) & plots_data{:,10}==1,10)))/height(plots_data(plots_data{:,3}==idnews(id),10)); % Stim rec
    tmp(id,3) = mean(table2array(plots_data(plots_data{:,3}==idnews(id),5))); % Stim true veracity
    tmp(id,4) = mean(table2array(plots_data(plots_data{:,3}==idnews(id),14))); % Stim ambiguity
end
tmp=sortrows(tmp,3); tmp0 = tmp(tmp(:,3)==0,:); tmp1 = tmp(tmp(:,3)==1,:); %tmp0 = stim whose true veracity is false

% Correlation between ambiguity and reception choices, for news = false and news = true
% [rho, pval] = corr(tmp0(:,2), tmp0(:,4),'Type','Pearson'); % p=.5461, rho=-0.0893
% [rho, pval] = corr(tmp1(:,2), tmp1(:,4),'Type','Pearson'); % p=.4639, rho=-0.1083










%% WTP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL RECEPTION RATE, NORMALITY TESTS AND DISTRIBUTION FITS

% GLOBAL:  mean(Rec_allSub.data_tables(8).models.mean_WTP); std(Rec_allSub.data_tables(8).models.mean_WTP); % m=6.02, sd=5.41
% GROUP 1: mean(Rec_allSub.group_data(8).group1.mean_WTP); std(Rec_allSub.group_data(8).group1.mean_WTP);   % m=5.94, sd=5.27
% GROUP 2: mean(Rec_allSub.group_data(8).group2.mean_WTP); std(Rec_allSub.group_data(8).group2.mean_WTP);   % m=6.10, sd=5.57

% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(8).group1.mean_WTP);
% [h,p,ksstat,cv] = kstest(Rec_allSub.group_data(8).group2.mean_WTP);
% Data doesn't come from normal distribution: h=1, p<.001

% [h,p,ksstat2] = kstest2(Rec_allSub.group_data(8).group1.mean_WTP, Rec_allSub.group_data(8).group2.mean_WTP); % h=0, p=.9328, ksstat=0.0661
% [p,h,stat] = ranksum(Rec_allSub.group_data(8).group1.mean_WTP, Rec_allSub.group_data(8).group2.mean_WTP);
% Conclusion: 0 diff between group1 and group2 distributions

% Matlab file exchange function 'fitmethis' returns Uniform as well as best fitting (AIC criterion)
% F=figure; F1= fitmethis(Rec_allSub.data_tables(8).models.mean_WTP); close(F)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WTP TO RECEIVE/AVOID OF GROUPS BETWEEN TRUE NEWS AND FALSE NEWS

% WTP to receive par thème (ensemble)
WTP_rec = allSubAllTrial(allSubAllTrial{:,10} == 1,:);
% ALL:  mean(WTP_rec{:,12}); std(WTP_rec{:,12});                             % m=7.33, sd=6.19
% ECOL: mean(WTP_rec{WTP_rec{:,4}==1,12}); std(WTP_rec{WTP_rec{:,4}==1,12}); % m=7.41, sd=6.21
% DEMO: mean(WTP_rec{WTP_rec{:,4}==2,12}); std(WTP_rec{WTP_rec{:,4}==2,12}); % m=7.25, sd=6.14
% JUST: mean(WTP_rec{WTP_rec{:,4}==3,12}); std(WTP_rec{WTP_rec{:,4}==3,12}); % m=7.32, sd=6.20

% WTP to avoid par thème (ensemble)
WTP_avoid = allSubAllTrial(allSubAllTrial{:,10} == 0,:);
% ALL:  mean(WTP_avoid{:,12}); std(WTP_avoid{:,12});                                 % m=5.07, sd=6.51
% ECOL: mean(WTP_avoid{WTP_avoid{:,4}==1,12}); std(WTP_avoid{WTP_avoid{:,4}==1,12}); % m=5.13, sd=6.75
% DEMO: mean(WTP_avoid{WTP_avoid{:,4}==2,12}); std(WTP_avoid{WTP_avoid{:,4}==2,12}); % m=5.01, sd=6.30
% JUST: mean(WTP_avoid{WTP_avoid{:,4}==3,12}); std(WTP_avoid{WTP_avoid{:,4}==3,12}); % m=5.06, sd=6.50

% WTP to receive par thème (average par sujet)
m_WTP_rec = zeros(nbs,4); m_WTP_avoid = zeros(nbs,4);

for ii = 1:nbs
    m_WTP_rec(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==1,12)));
    m_WTP_rec(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==1,12)));
    m_WTP_rec(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==1,12)));
    m_WTP_rec(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==1,12)));
    
    m_WTP_avoid(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==0,12)));
    m_WTP_avoid(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==0,12)));
    m_WTP_avoid(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==0,12)));
    m_WTP_avoid(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==0,12)));
end

% RECEPTION
% ALL:  mean(m_WTP_rec(:,1),'omitnan'); std(m_WTP_rec(:,1),'omitnan'); % m=7.07, sd=4.96
% ECOL: mean(m_WTP_rec(:,2),'omitnan'); std(m_WTP_rec(:,2),'omitnan'); % m=7.18, sd=5.13
% DEMO: mean(m_WTP_rec(:,3),'omitnan'); std(m_WTP_rec(:,3),'omitnan'); % m=7.30, sd=5.02
% JUST: mean(m_WTP_rec(:,4),'omitnan'); std(m_WTP_rec(:,4),'omitnan'); % m=7.24, sd=5.17

% AVOID
% ALL:  mean(m_WTP_avoid(:,1),'omitnan'); std(m_WTP_avoid(:,1),'omitnan'); % m=5.75, sd=5.69
% ECOL: mean(m_WTP_avoid(:,2),'omitnan'); std(m_WTP_avoid(:,2),'omitnan'); % m=5.87, sd=6.02
% DEMO: mean(m_WTP_avoid(:,3),'omitnan'); std(m_WTP_avoid(:,3),'omitnan'); % m=5.75, sd=5.80
% JUST: mean(m_WTP_avoid(:,4),'omitnan'); std(m_WTP_avoid(:,4),'omitnan'); % m=5.71, sd=5.80

% Difference:
% [p,h,stats] = signrank(m_WTP_rec(:,1), m_WTP_avoid(:,1)); % h=1, p<.001
% [p,h,stats] = signrank(m_WTP_rec(:,2), m_WTP_avoid(:,2)); % h=1, p<.001
% [p,h,stats] = signrank(m_WTP_rec(:,3), m_WTP_avoid(:,3)); % h=1, p<.001
% [p,h,stats] = signrank(m_WTP_rec(:,4), m_WTP_avoid(:,4)); % h=1, p<.001





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

m_WTP_rec_year1 = zeros(nbs2,4); m_WTP_avoid_year1 = zeros(nbs2,4); m_WTP_rec_year2 = zeros(nbs3,4); m_WTP_avoid_year2 = zeros(nbs3,4);
for ii = 1:nbs2
    m_WTP_rec_year1(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_rec_year1(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_rec_year1(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_rec_year1(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==1,12)));
    
    m_WTP_avoid_year1(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_avoid_year1(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_avoid_year1(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==1,12)));
    m_WTP_avoid_year1(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==1,12)));
end
for ii = 1:nbs3
    m_WTP_rec_year2(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==2,12)));
    m_WTP_rec_year2(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==2,12)));
    m_WTP_rec_year2(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==2,12)));
    m_WTP_rec_year2(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==1 & allSubAllTrial{:,40} ==2,12)));
    
    m_WTP_avoid_year2(ii,1) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,10} ==0,12)));
    m_WTP_avoid_year2(ii,2) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==1 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==2,12)));
    m_WTP_avoid_year2(ii,3) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==2 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==2,12)));
    m_WTP_avoid_year2(ii,4) = mean(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,4}==3 & allSubAllTrial{:,10} ==0 & allSubAllTrial{:,40} ==2,12)));
end

mean(m_WTP_rec_year1(:,1),'omitnan'); std(m_WTP_rec_year1(:,1),'omitnan'); % mean=8.9, sd=4.57
mean(m_WTP_rec_year2(:,1),'omitnan'); std(m_WTP_rec_year2(:,1),'omitnan'); % mean=6.79, sd=4.8

% All  [p,h,stats] = ranksum(m_WTP_rec_year1(:,1), m_WTP_rec_year2(:,1)); % h=1, p=.0091, z=2.6067
% ECOL [p,h,stats] = ranksum(m_WTP_rec_year1(:,2), m_WTP_rec_year2(:,2)); % h=1, p=.0154, z=2.4235
% DEMO [p,h,stats] = ranksum(m_WTP_rec_year1(:,3), m_WTP_rec_year2(:,3)); % h=1, p=.0484, z=1.9739
% JUST [p,h,stats] = ranksum(m_WTP_rec_year1(:,4), m_WTP_rec_year2(:,4)); % h=1, p=.0100, z=2.5744

% All  [p,h,stats] = ranksum(m_WTP_avoid_year1(:,1), m_WTP_avoid_year2(:,1)); % h=0
% ECOL [p,h,stats] = ranksum(m_WTP_avoid_year1(:,2), m_WTP_avoid_year2(:,2)); % h=0
% DEMO [p,h,stats] = ranksum(m_WTP_avoid_year1(:,3), m_WTP_avoid_year2(:,3)); % h=0
% JUST [p,h,stats] = ranksum(m_WTP_avoid_year1(:,4), m_WTP_avoid_year2(:,4)); % h=0
% C'est bien ça: y'a une variation entre années que sur WTP to receive. Donc la WTP to receive est bien affectée





% Do hist of eval for both rec & ~rec











%% Ambiguity
Id =[1 2 19 23 28 30 31 34 38 39 53 69 70 74 75 76 77 78 86 87 97 100 103 104 113 119 120 122 124 125 128 130 134 139 140 145 151 157 161 162 174 176 179 181 187 190 191 203 3 7 12 17 18 21 27 36 165 168 177 178 180 182 184 192 68 108 123 126 127 129 136 147 159 163 194 205 206 208 209 50 62 64 80 81 85 88 90 93 95 99 109 112 114 116 118 164];
minimum = min(table2array(allSubAllTrial(1:144,14))); allSubAllTrial(allSubAllTrial{1:144,14} == minimum, 3);
maximum = max(table2array(allSubAllTrial(1:96,14))); allSubAllTrial(allSubAllTrial{1:144,14} == maximum, 3);

% clear temp
% temp = table2array(allSubAllTrial);
% for ii = 1:length(Id)
% tmplist(1,:) =  temp(temp(:,3) == Id(ii), 14)
% ambig_success(ii,1) = Id(ii);
% ambig_success(ii,2) = sum(tmplist==1)/length(tmplist);
% ambig_success(ii,3) = sum(temp(temp(:,3) == Id(ii), 9))/length(tmplist);
% clear tmplist
% end










%%% Uncomment the following to run
%% MODELS OF SUCCESS RATES

% ORGANIZATIONS
% Organizations explain success ?
% fitlme(Rec_allSub.data_tables(5).models,'scoreDemo ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject)');
% fitlme(Rec_allSub.data_tables(5).models,'scoreEcol ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject)');
% fitlme(Rec_allSub.data_tables(5).models,'scoreJust ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject)');
% NS

% Organizations explain evaluation ?
% fitlme(Rec_allSub.data_tables(3).models,'scoreDemoPos ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject)');
% fitlme(Rec_allSub.data_tables(3).models,'scoreEcolPos ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject)');
% fitlme(Rec_allSub.data_tables(3).models,'scoreJustPos ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject)');
% fitlme(Rec_allSub.data_tables(3).models,'scoreDemoNeg ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject)');
% fitlme(Rec_allSub.data_tables(3).models,'scoreEcolNeg ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject)');
% fitlme(Rec_allSub.data_tables(3).models,'scoreJustNeg ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject)');
% NS. RIEN. NADA. NOTHING. VOID AND EMPTINESS.



%%% STIM MODELS

% VERACITY = 0 OR 1
fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'success ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % False (p<.001, estimate=0.1112)
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'success ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % True  (p<.001, estimate=-0.1089)
% Success in false and true information depends on ambiguity
% ->> true news = the less it is ambiguous, the better we succeed; fake news = inverse

fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'success ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % False (p<.001, estimate=0.2050)
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'success ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % True  (p<.001, estimate=-0.1599)
% Same

% When add split and desirability to model: signal is captured by split and not anymore by ambiguity:
fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'success ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % False (p<.001, estimate=-0.2146)
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'success ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % True  (p<.001, estimate=0.1876)
% Desirability is very significative as well



% JUDGMENT = 0 OR 1
% Participants declare all news as true 60% of the time
sum(table2array(allSubAllTrial(:,8))) / length(table2array(allSubAllTrial(:,8))); % 0.59.54
sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==0,8))) / length(table2array(allSubAllTrial(allSubAllTrial{:,5}==0,8))); % 58.20
sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==1,8))) / length(table2array(allSubAllTrial(allSubAllTrial{:,5}==1,8))); % 60.89


% % THERE IS COL SPLIT AND COL CONSENSUALITY. BEWARE OF WHICH TO USE
% 
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'success ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % False (p<.001, estimate=-0.1196)
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'success ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % True  (p<.001, estimate=0.1880)
% % Infos jugées comme fausses, plus c'est ambigu plus ils foirent
% % Infos jugées comme vraies, plus c'est ambigu moins ils foirent ; moins c'est ambigu plus ils foirent (à vérifier avec les estimated means)
% % -> Ambiguité est donc bien un marqueur de véracité
% 
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'success ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % False (p<.001, estimate=-0.0718)
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'success ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit'); % True  (p<.001, estimate=0.1232)
% % Same for split
% 
% % When add split and desirability to model: signal is captured by ambiguity alone for JUDGED AS TRUE ; by everithing for JUDGED AS FALSE:
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'success ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'success ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% 
% fitglme(allSubAllTrial,'success ~ veracity*ambiguity + veracity*split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% % veracity, split and veracity*split
% fitglme(allSubAllTrial,'success ~ veracity*ambiguity + veracity*split + veracity*desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit')
% % same + desirability + veracity*desirability


%%% BEHAVIORAL MODELS
fitglme(allSubAllTrial,'success ~ veracity + judgment + eval + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');


%%% SOCIO-DEMO MODELS

% Year
% fitglme(allSubAllTrial,'success ~ year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% Sociodemo
fitglme(allSubAllTrial,'success ~ age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial,'success ~ age + sex + education + EC + prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS


% Orgas: 3 themes
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'success ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Ecol: NS, best: WWF
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'success ~ Greenpeace + WWF + NIPCC + Climato_realistes + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Ecol, best: La_Manif_Pour_Tous

% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'success ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Demo: NS, best: Parti_libertarien
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'success ~ Greenpeace + WWF + NIPCC + Climato_realistes + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Demo, best: NIPCC

% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'success ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Just: NS, best: Generation_Identitaire
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'success ~ Greenpeace + WWF + NIPCC + Climato_realistes + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + Parti_Libertarien+ (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Just, best: Mouvement_Europeen_France


% Orgas: All
% fitglme(allSubAllTrial,'success ~ Greenpeace + WWF + NIPCC + Climato_realistes + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% All, best: Parti_Libertarien
% fitglme(allSubAllTrial,'success ~ WWF + Parti_Libertarien + Generation_Identitaire + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% All: WWF works
% fitglme(allSubAllTrial,'success ~ orgaBest + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial,'success ~ orgaBestHaul + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');



% Sociodemo + orgas: 3 themes
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'success ~ age + sex + education + EC + Greenpeace + WWF + NIPCC + Climato_realistes + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Ecol: NS
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'success ~ age + sex + education + EC + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + prcnt_politique + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Demo: NS
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'success ~ age + sex + education + EC + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + prcnt_acteurjustsoc + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Just: NS

fitglme(allSubAllTrial, 'success ~ prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Prcnt_chercheur seul



%%%  Full models

fitglme(allSubAllTrial, 'success ~ 1 + judgment*ambiguity', 'Distribution','Binomial','Link','logit')

fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'success ~ ambiguity + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% False: ambiguity: p<.001, estimate=0.1092
fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'success ~ split + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% False: split: p<.001, estimate=0.2034

fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'success ~ ambiguity + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% True: ambiguity: p<.001, estimate=-0.1084
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'success ~ split + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% True: split: p<.001, estimate=-0.1719

fitglme(allSubAllTrial,'success ~ veracity + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% veracity: p<.001, estimate=1.0173

fitglme(allSubAllTrial,'success ~ eval*judgment + veracity*ambiguity + veracity*split + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Veracity + split +veracity*split explain


% Model with RT
% Model with RT
fitglme(allSubAllTrial,'success ~ eval_RT + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% RT explain
fitglme(allSubAllTrial,'success ~ eval_RT + eval*judgment + veracity*ambiguity + veracity*split + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% RT + veracity + split +veracity*split explain




% Sure models (eval >60)
Sure = allSubAllTrial(allSubAllTrial{:,6}>59,:);
fitglme(Sure,'success ~ eval + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Veracity + eval + split + ambiguity*split + Brier

% Unsure models (eval <40)
Unsure = allSubAllTrial(allSubAllTrial{:,6}<41,:);
fitglme(Unsure,'success ~ eval + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Veracity + eval + Brier

% Middle models (eval >41 & <59)
Middle = allSubAllTrial(allSubAllTrial{:,6}>41 & allSubAllTrial{:,6}<59,:);
fitglme(Middle,'success ~ eval + theme + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Veracity





%% MODELS OF VERACITY JUDGMENTS

%%% ORGANISATIONS
% Organizations explain veracity_judgment ?
% fitlme(veracity_judgment,'scoreDemoPos ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|group)');
% fitlme(veracity_judgment,'scoreDemoNeg ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|group)');
% fitlme(veracity_judgment,'scoreEcolPos ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|group)');
% fitlme(veracity_judgment,'scoreEcolNeg ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|group)');
% fitlme(veracity_judgment,'scoreJustPos ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group)');
% fitlme(veracity_judgment,'scoreJustNeg ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group)');
% NS sauf La manif pour tous pour scoreJustNeg


% Organizations explain veracity judgment ?
% fitlme(veracity_judgment,'mean_pos ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + Greenpeace + WWF + NIPCC + Climato_realistes + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group) + (1|year)');
% NS sauf La manif pour tous
% fitlme(veracity_judgment,'mean_neg ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + Greenpeace + WWF + NIPCC + Climato_realistes + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group) + (1|year)');
% NS sauf La manif pour tous et Mouvement Europeen France





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALLSUBALLTRIAL

%%% No need to look at a variable that the subject produces (i.e., dependent variable: judgment) given a variable that the subject is not aware of (i.e., true veracity)
%%% Just compute for all stims

% JUDGMENT = 0 OR 1
% Participants declare all news as true 60% of the time
sum(table2array(allSubAllTrial(:,8))) / length(table2array(allSubAllTrial(:,8))); % 0.59.54
sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==0,8))) / length(table2array(allSubAllTrial(allSubAllTrial{:,5}==0,8))); % 58.20
sum(table2array(allSubAllTrial(allSubAllTrial{:,5}==1,8))) / length(table2array(allSubAllTrial(allSubAllTrial{:,5}==1,8))); % 60.89


%%% SOCIO-DEMO MODELS

% Year
% fitglme(allSubAllTrial,'judgment ~ year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% Sociodemo
% fitglme(allSubAllTrial,'judgment ~ age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% Sociodemo + orgas: 3 themes
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'judgment ~ age + sex + education + EC + Greenpeace + WWF + NIPCC + Climato_realistes + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Ecol: NS
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'judgment ~ age + sex + education + EC + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + prcnt_politique + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Demo: NS
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'judgment ~ age + sex + education + EC + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + prcnt_acteurjustsoc + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Just: NS (sauf prcnt_acteurjustsoc)

% fitglme(allSubAllTrial, 'judgment ~ prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');


% JUDGMENT = 0 OR 1 CAN'T OBVIOUSLY BE DONE IN JUDGMENT AS DEPENDENT VARIABLE

% VERACITY = 0 OR 1
fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'judgment ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'judgment ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');


%%%  Full models

% THERE IS COL SPLIT AND COL CONSENSUALITY. BEWARE OF WHICH TO USE
fitglme(allSubAllTrial,'judgment ~ ambiguity + theme + Brier + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% ambiguity: p<.001, estimate=-0.1427
fitglme(allSubAllTrial,'judgment ~ split + theme + Brier + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% split: p<.001, estimate=-0.2409

fitglme(allSubAllTrial,'judgment ~ ambiguity + split + theme + Brier + desirability + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Theme + desirability + split 

fitglme(allSubAllTrial,'judgment ~ veracity*ambiguity + veracity*split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Split + veracity*split

% model with RT
fitglme(allSubAllTrial,'judgment ~ eval_RT + ambiguity + split + theme + Brier + desirability + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% RT + theme + desirability + split 





%% MODELS OF CONFIDENCE VALUES

%%% ALLSUBALLTRIAL: EVAL SOLELY
%%% PLOTS_DATA: REPRESENTS JUDGMENT*EVAL (thanks to negative values)

%%% No need to look at a variable that the subject produces (i.e., dependent variable: confidence) given a variable that the subject is not aware of (i.e., true veracity)
%%% Just compute for all stims

%%% SOCIO-DEMO MODELS

% Year
% fitlme(allSubAllTrial,'eval ~ year + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS

% Sociodemo
fitlme(allSubAllTrial,'eval ~ age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)');
% Sex is significant: p<.001, estimate=-9.0178 (male = 1 ; female = 2)

% Sociodemo + orgas: 3 themes
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'eval ~ age + sex + education + EC + Greenpeace + WWF + NIPCC + Climato_realistes + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)');
% Ecol: NS sauf sex
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'eval ~ age + sex + education + EC + Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + prcnt_politique + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)');
% Demo: NS sauf sex
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'eval ~ age + sex + education + EC + SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + prcnt_acteurjustsoc + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)');
% Just: NS sauf sex

% fitlme(plots_data, 'eval ~ prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)');

% JUDGMENT = 0 OR 1
fitlme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'eval ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
fitlme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'eval ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');

% VERACITY = 0 OR 1
fitlme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'eval ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
fitlme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'eval ~ ambiguity + consensuality + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');




%%%  Full models
% THERE IS COL SPLIT AND COL CONSENSUALITY. BEWARE OF WHICH TO USE
fitlme(allSubAllTrial,'eval ~ ambiguity + judgment + theme + Brier + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)');
% ambiguity: p<.001, estimate=-0.7156
fitlme(allSubAllTrial,'eval ~ split + judgment + theme + Brier + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)');
% split: p<.001, estimate=-0.3489
fitlme(allSubAllTrial,'eval ~ ambiguity + split + judgment + theme + Brier + desirability + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)');
% Theme + ambiguity + desirability + sex 

fitlme(allSubAllTrial,'eval ~ veracity*ambiguity + veracity*split + (1|subject) + (1|group) + (1|order) + (1|year)');
% Ambiguity + veracity*ambiguity


% Model with RT
fitlme(allSubAllTrial,'eval ~ eval_RT + ambiguity + split + judgment + theme + Brier + desirability + age + sex + education + EC + year + (1|subject) + (1|group) + (1|order) + (1|year)');
% RT + theme + ambiguity + desirability + sex 





%% MODELS OF RECEPTION DESIRABILITY

%%% ORGANISATIONS
fitlme(Rec_allSub.data_tables(6).models,'scoreDemo ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|year)');
fitlme(Rec_allSub.data_tables(6).models,'scoreEcol ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|year)');
fitlme(Rec_allSub.data_tables(6).models,'scoreJust ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|year)');
% 'Climato_realistes' explains Ecol ; 'FEMEN' explains Just



%%% STIM MODELS

% VERACITY = 0 OR 1

% fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'rec ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'rec ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'rec ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'rec ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% When add split and desirability to model: Ambiguity explains
fitglme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'rec ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
fitglme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'rec ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Desirability explains


% JUDGMENT = 0 OR 1

% fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'rec ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'rec ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'rec ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'rec ~ split + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS
% THERE IS COL SPLIT AND COL CONSENSUALITY. BEWARE OF WHICH TO USE
% When add split and desirability to model:
fitglme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'rec ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
fitglme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'rec ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Desirability explains


% Brier
fitglme(allSubAllTrial,'rec ~ theme + Brier + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS

% All
fitglme(allSubAllTrial,'rec ~ theme + veracity + ambiguity + split + desirability + Brier + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Desirability only



%%% SOCIO-DEMO MODELS

% Year
% fitglme(allSubAllTrial,'rec ~ year + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Nothing

% Sociodemo
% fitglme(allSubAllTrial,'rec ~ age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Nothing

% Sociodemo + orgas: 3 themes
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'rec ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Ecol: Climato-realistes
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'rec ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Demo: NS
% fitglme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'rec ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Just: Femen

% fitglme(allSubAllTrial, 'rec ~ prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% NS



%%%  Full models

fitglme(allSubAllTrial,'rec ~ theme + veracity + ambiguity + split + desirability + Brier + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% Desirability explain

fitglme(allSubAllTrial,'rec ~ eval*judgment + theme + veracity + ambiguity + split + desirability + Brier + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% -> desirability + eval + eval*judgment

fitglme(allSubAllTrial,'rec ~ eval*judgment + (1|subject) + (1|group) + (1|order) + (1|year)','Distribution','Binomial','Link','logit');
% -> desirability + eval + eval*judgment





%% MODELS OF WTP

%%% ORGANISATIONS
glme = fitlme(Rec_allSub.data_tables(8).models,'scoreDemo ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|year)');
glme = fitlme(Rec_allSub.data_tables(8).models,'scoreEcol ~ Greenpeace + WWF + NIPCC + Climato_realistes + (1|subject) + (1|year)');
glme = fitlme(Rec_allSub.data_tables(8).models,'scoreJust ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|year)');
% 'Fontation_Robert_Schuman' only explains, Demo



%%% STIM MODELS

% VERACITY = 0 OR 1

% fitlme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'WTP ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)');
% fitlme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'WTP ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS

% fitlme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'WTP ~ split + (1|subject) + (1|group) + (1|order) + (1|year)');
% fitlme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'WTP ~ split + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS

% When add split and desirability to model:
fitlme(allSubAllTrial(allSubAllTrial{:,5}==0,:),'WTP ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
fitlme(allSubAllTrial(allSubAllTrial{:,5}==1,:),'WTP ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
% Desirability explains; explains most for false news


% JUDGMENT = 0 OR 1

% fitlme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'WTP ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)');
% fitlme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'WTP ~ ambiguity + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS

% fitlme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'WTP ~ split + (1|subject) + (1|group) + (1|order) + (1|year)');
% fitlme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'WTP ~ split + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS
% THERE IS COL SPLIT AND COL CONSENSUALITY. BEWARE OF WHICH TO USE
% When add split and desirability to model:
fitlme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'WTP ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
fitlme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'WTP ~ ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
% Desirability explains; explain only for false news

% Brier
% fitlme(allSubAllTrial,'WTP ~ theme + Brier + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS



%%% SOCIO-DEMO

% Year
fitlme(allSubAllTrial,'WTP ~ year + (1|subject) + (1|group) + (1|order) + (1|year)');
% Year S
fitlme(allSubAllTrial,'WTP ~ year*judgment + (1|subject) + (1|group) + (1|order) + (1|year)');
% Year*Judgment NS
fitlme(allSubAllTrial(allSubAllTrial{:,8}==0,:),'WTP ~ year + (1|subject) + (1|group) + (1|order) + (1|year)');
fitlme(allSubAllTrial(allSubAllTrial{:,8}==1,:),'WTP ~ year + (1|subject) + (1|group) + (1|order) + (1|year)');
% Year S

% Sociodemo
% fitlme(allSubAllTrial,'WTP ~ age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)');
% NS

% Sociodemo + orgas: 3 themes
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==1,:),'eval ~ WWF + NIPCC + Climato_realistes + (1|subject) + (1|group) + (1|order) + (1|year)');
% Ecol: NS sauf sex
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==2,:),'eval ~ Mouvement_Europeen_France + Fondation_Robert_Schuman + Frexit + Parti_Libertarien + (1|subject) + (1|group) + (1|order) + (1|year)');
% Demo: NS sauf sex
% fitlme(allSubAllTrial(allSubAllTrial{:,4} ==3,:),'eval ~ SOS_Mediterranee + FEMEN + Generation_Identitaire + La_Manif_Pour_Tous + (1|subject) + (1|group) + (1|order) + (1|year)');
% Just: NS sauf sex

% fitlme(allSubAllTrial, 'eval ~ prcnt_politique + prcnt_journaliste + prcnt_medecin + prcnt_acteurjustsoc + prcnt_chercheur + prcnt_acteurecologie + prcnt_general + (1|subject) + (1|group) + (1|order) + (1|year)');




%%%  Full models

fitlme(allSubAllTrial,'WTP ~ theme + veracity + ambiguity + split + desirability + (1|subject) + (1|group) + (1|order) + (1|year)');
% Desirability

fitlme(allSubAllTrial,'WTP ~ theme + Brier + veracity + ambiguity + split + desirability + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)');
% Desirability

fitlme(allSubAllTrial,'WTP ~ rec + eval * judgment + theme + ambiguity + split + desirability + age + sex + education + EC + (1|subject) + (1|group) + (1|order) + (1|year)');
% Eval, Rec, Desirability, Eval*Judgment

fitlme(allSubAllTrial,'WTP ~ rec + eval * judgment + (1|subject) + (1|group) + (1|order) + (1|year)');
% Eval, rec, interaction










%% ADDITIONAL PLOTS

% %%% Uniform distribution:
% % Plot empirical distrib and theoretical uniform distribution
% tiledlayout(1,2)
% for jj = 1:2
%     switch jj
%         case 1,     var = 'group1'; txt = 'Group 1';
%         case 2,     var = 'group2'; txt = 'Group 2';
%     end
%     nexttile; [f,x_values] = ecdf(Rec_allSub.group_data(5).(var).freq_1);
%     J = plot(x_values,f); hold on;
%     K = plot(x_values,unifcdf(x_values, min(x_values),max(x_values)),'r--');
%     set(J,'LineWidth',2); set(K,'LineWidth',2); legend([J K],'Empirical CDF','Uniform CDF','Location','SE');
%     title(txt); hold off
% end





% %%% Participants' desirability rate
% m=0; figure; k=1;
% var = 'freq_1';
% x1=fitdist((Rec_allSub.data_tables(6).models.(var)),'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf); %#ok<*NBRAK>
% line(x1_pdf,y1,'Color',[0 0.4470 0.7410]);
% title(strcat("Participants' desirability rates"),'FontSize',20); xlabel('Frequency of choices to receive','FontSize',20); ylabel('Density','FontSize',20);
% legend('Receivers','FontSize',20);
% set(gca, 'FontSize',18);





%%% Correlation between veracity judgment and social distance to organizations
% figure
% for ii = 1:12
%     subplot(3,4,ii)
%     scatter(Rec_allSub.data_tables(3).models.count_pos,Rec_allSub.data_tables(3).models{:,61+ii});
%     hold on
%     b1 = (Rec_allSub.data_tables(3).models.count_pos\Rec_allSub.data_tables(3).models{:,61+ii}); %b1 = x\y is mldivide aka: solves the system of linear equations A*x = B.
%     yCalc1 = b1*(Rec_allSub.data_tables(3).models.count_pos);
%     plot(Rec_allSub.data_tables(3).models.count_pos,yCalc1);
%     sgtitle('Correlation for each stim between social distance to organization and judgment as true');
%     xlabel(Rec_allSub.data_tables(3).models.Properties.VariableNames(61+ii),'FontSize',20); ylabel(strcat('R2 = ',num2str(corr(Rec_allSub.data_tables(3).models.count_pos,Rec_allSub.data_tables(3).models{:,61+ii}))),'FontSize',20);
% end

%% Corrélation pour jugement = vrai entre confidence degree et distance sociale
% figure
% for ii = 1:12
%     subplot(3,4,ii)
%     scatter(Rec_allSub.data_tables(3).models.mean_pos,Rec_allSub.data_tables(3).models{:,61+ii});
%     hold on
%     b1 = (Rec_allSub.data_tables(3).models.mean_pos\Rec_allSub.data_tables(3).models{:,61+ii}); %b1 = x\y is mldivide aka: solves the system of linear equations A*x = B.
%     yCalc1 = b1*(Rec_allSub.data_tables(3).models.mean_pos);
%     plot(Rec_allSub.data_tables(3).models.mean_pos,yCalc1);
%     sgtitle('Correlation for news judged as true between confidence degree and social distance','FontSize',20);
%     xlabel(Rec_allSub.data_tables(3).models.Properties.VariableNames(61+ii),'FontSize',20); ylabel(strcat('R2 = ',num2str(corr(Rec_allSub.data_tables(3).models.mean_pos,Rec_allSub.data_tables(3).models{:,61+ii}))),'FontSize',20);
% end


%%% Corrélation pour jugement = faux entre confidence degree et distance sociale
% figure
% for ii = 1:12
%     subplot(3,4,ii)
%     scatter(Rec_allSub.data_tables(3).models.mean_neg,Rec_allSub.data_tables(3).models{:,61+ii});
%     hold on
%     b1 = (Rec_allSub.data_tables(3).models.mean_neg\Rec_allSub.data_tables(3).models{:,61+ii}); %b1 = x\y is mldivide aka: solves the system of linear equations A*x = B.
%     yCalc1 = b1*(Rec_allSub.data_tables(3).models.mean_neg);
%     plot(Rec_allSub.data_tables(3).models.mean_neg,yCalc1);
%     sgtitle('Correlation for news judged as false between confidence degree and social distance','FontSize',20);
%     xlabel(Rec_allSub.data_tables(3).models.Properties.VariableNames(61+ii),'FontSize',20); ylabel(strcat('R2 = ',num2str(corr(Rec_allSub.data_tables(3).models.mean_neg,Rec_allSub.data_tables(3).models{:,61+ii}))),'FontSize',20);
% end





%% %% Desirability to receive more news 

% As function of judgment*confidence for both Groups
% figure
% clear temp tmp temp2 tmp2
% m=0;
% for ii = 1:10
% tmp = table2array(plots_data(plots_data.group == 1 & plots_data.eval == ii*10, 10)); % disp([1+m, ii*10]);
% tmp2 = table2array(plots_data(plots_data.group == 1 & plots_data.eval == -ii*10, 10));
% temp(ii,1)=ii*10;temp2(ii,1)=-ii*10;
% temp(ii,2) = sum(tmp==1)/length(tmp); temp2(ii,2) = sum(tmp2==1)/length(tmp2);
% m=m+10;
% end
% supertemp= [temp; temp2]; bar(supertemp(:,1),supertemp(:,2));
% title('Desirability to receive more news as a function of news perceived veracity and evaluation confidence in GROUP 1','FontSize',20);
% xlabel('News evaluation','FontSize',20); ylabel('Receive frequency','FontSize',20);
%
% figure
% clear temp tmp temp2 tmp2
% m=0;
% for ii = 1:10
% tmp = table2array(plots_data(plots_data.group == 2 & plots_data.eval == ii*10, 10)); % disp([1+m, ii*10]);
% tmp2 = table2array(plots_data(plots_data.group == 2 & plots_data.eval == -ii*10, 10));
% temp(ii,1)=ii*10;temp2(ii,1)=-ii*10;
% temp(ii,2) = sum(tmp==1)/length(tmp); temp2(ii,2) = sum(tmp2==1)/length(tmp2);
% m=m+10;
% end
% supertemp= [temp; temp2]; bar(supertemp(:,1),supertemp(:,2));
% title('Desirability to receive more news as a function of news perceived veracity and evaluation confidence in GROUP 1','FontSize',20);
% xlabel('News evaluation','FontSize',20); ylabel('Receive frequency','FontSize',20);


% For each subject
% for sub = 5
% clear temp tmp temp2 tmp2
% figure
% m=0;
% for ii = 1:10
% tmp = table2array(plots_data(plots_data.subject == sub & plots_data.eval == ii*10, 10)); % disp([1+m, ii*10]);
% tmp2 = table2array(plots_data(plots_data.subject == sub & plots_data.eval == -ii*10, 10));
% temp(ii,1)=ii*10;temp2(ii,1)=-ii*10;
% temp(ii,2) = sum(tmp==1)/length(tmp); temp2(ii,2) = sum(tmp2==1)/length(tmp2);
% m=m+10;
% end
% supertemp= [temp; temp2]; bar(supertemp(:,1),supertemp(:,2));
% title('Subject desirability to receive more news as a function of news perceived veracity and evaluation confidence','FontSize',20);
% xlabel('News evaluation','FontSize',20); ylabel('Receive frequency','FontSize',20);
% end





% %%% Plot REC: Bin by 20 units
% clear temp tmp temp2 tmp2
% figure
% m=0; temp = zeros(20,5); temp2 = zeros(20,5);
% for ii = 1:20
%     tmp = table2array(plots_data(plots_data.eval >= 1+m & plots_data.eval < ii*5, 10));
%     temp(ii,1)=ii*5;
%     temp(ii,2) = sum(tmp==1)/length(tmp);
%     [phat,pci] = binofit(sum(tmp==1),length(tmp));
%     temp(ii,3) = phat; temp(ii,4) = pci(1); temp(ii,5) = pci(2);
%     
%     tmp2 = table2array(plots_data(plots_data.eval <= -1-m & plots_data.eval > -ii*5, 10));
%     temp2(ii,1)=-ii*5;
%     temp2(ii,2) = sum(tmp2==1)/length(tmp2);
%     [phat2,pci2] = binofit(sum(tmp2==1),length(tmp2));
%     temp2(ii,3) = phat2; temp2(ii,4) = pci2(1); temp2(ii,5) = pci2(2);
%     m=m+5;
% end
% supertemp= [temp; temp2]; bar(supertemp(:,1),supertemp(:,2));
% for I = 1:20                                       % connect upper and lower bound with a line
%     line([I*5 I*5],[supertemp(I,4) supertemp(I,5)],'Color','red');
%     line([-I*5 -I*5],[supertemp(I+20,4) supertemp(I+20,5)], 'Color','red');
%     hold on;
% end
% title('Average desirability to receive more news as a function of news perceived veracity and evaluation confidence','FontSize',20);
% xlabel('News evaluation','FontSize',20); ylabel('Receivers derisability','FontSize',20);



% m_success_tf_year1 = zeros(nbs2, 8); m_success_tf_year2 = zeros(nbs3, 8);
% for ii = 1:nbs2
%     m_success_tf_year1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))*100;
%     
%     m_success_tf_year1(ii,5) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,6) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,7) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,9))*100;
%     m_success_tf_year1(ii,8) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,9))*100;
% end
% for ii = 1:nbs3
%     m_success_tf_year2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))*100;
%     
%     m_success_tf_year2(ii,5) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,6) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,7) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,9))*100;
%     m_success_tf_year2(ii,8) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,9))*100;
% end
% 
% % All  FALSE: [p,h,stats] = ranksum(m_success_tf_year1(:,1), m_success_tf_year2(:,1)); % h=1, p=.0012, z=3.2275
% % ECOL FALSE: [p,h,stats] = ranksum(m_success_tf_year1(:,2), m_success_tf_year2(:,2)); % h=1, p=.0088, z=2.6203
% % DEMO FALSE: [p,h,stats] = ranksum(m_success_tf_year1(:,3), m_success_tf_year2(:,3)); 
% % JUST FALSE: [p,h,stats] = ranksum(m_success_tf_year1(:,4), m_success_tf_year2(:,4)); % h=1, p=.0192, z=2.3407
% 
% % ALL  TRUE: [p,h,stats] = ranksum(m_success_tf_year1(:,5), m_success_tf_year2(:,5)); % h=1, p<.001, z=-3.3509
% % ECOL TRUE: [p,h,stats] = ranksum(m_success_tf_year1(:,6), m_success_tf_year2(:,6));
% % DEMO TRUE: [p,h,stats] = ranksum(m_success_tf_year1(:,7), m_success_tf_year2(:,7)); % h=1, p<.001, z=-4.7121
% % JUST TRUE: [p,h,stats] = ranksum(m_success_tf_year1(:,8), m_success_tf_year2(:,8));
% 
% 
% 
% % Reception rates for each condition for each year WITH STANDARD ERROR
% figure; tiledlayout(1,2)
% for jj = 1:2
%     switch jj
%         case 1,     var = m_success_tf_year1; txt = 'Success rate (Year 1)';
%         case 2,     var = m_success_tf_year2; txt = 'Success rate (Year 2)';
%     end
%     nexttile
%     Y = [mean(var(:,1),'omitnan')  mean(var(:,5),'omitnan') ;
%          mean(var(:,2),'omitnan')  mean(var(:,6),'omitnan') ;
%          mean(var(:,3),'omitnan')  mean(var(:,7),'omitnan')
%          mean(var(:,4),'omitnan')  mean(var(:,8),'omitnan')];
%     sd = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5)))));
%           std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) ;
%           std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7)))))
%           std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     
%     b1 = bar(Y); ylim([0 100]); title(txt,'FontSize',20);   hold on;
%     nbars = size(Y, 2); x = [];
%     for i = 1:nbars
%         x = [x ; b1(i).XEndPoints];
%     end
%     erp = errorbar(x', Y, sd, 'k','linestyle','none');      LA2 = legend('False','True'); LA2.Location ='best';
%     X = categorical({'No theme' 'Ecology','Democracy','Social justice'});
%     set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);     ylabel('Rate','FontSize',20);
%     
%     sd1 = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4)))))];
%     xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
%     text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     
%     sd2 = [std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
%     text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     
%     b1(1).FaceColor='flat'; b1(2).FaceColor='flat'; %CData = control individual bars
%     for kk = 1:4
%         b1(1).CData(kk,:) = [0.6350, 0.0780, 0.1840];   b1(2).CData(kk,:) = [0.00,0.70,0.47];
%     end
%     hold off
% end




% %%% Reception rates for each condition for each veracity for each year WITH STANDARD ERROR
% figure; tiledlayout(1,2)
% for jj = 1:2
%     switch jj
%         case 1,     var = m_success_year1; txt = 'Success rate (Year 1)';
%         case 2,     var = m_success_year2; txt = 'Success rate (Year 2)';
%     end
%     nexttile
%     Y = [mean(var(:,1),'omitnan')  mean(var(:,5),'omitnan') ;
%          mean(var(:,2),'omitnan')  mean(var(:,6),'omitnan') ;
%          mean(var(:,3),'omitnan')  mean(var(:,7),'omitnan')
%          mean(var(:,4),'omitnan')  mean(var(:,8),'omitnan')];
%     sd = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5)))));
%           std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) ;
%           std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7)))))
%           std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     
%     b1 = bar(Y); ylim([0 100]); title(txt,'FontSize',20);   hold on;
%     nbars = size(Y, 2); x = [];
%     for i = 1:nbars
%         x = [x ; b1(i).XEndPoints];
%     end
%     erp = errorbar(x', Y, sd, 'k','linestyle','none');      LA2 = legend('False','True'); LA2.Location ='best';
%     X = categorical({'No theme' 'Ecology','Democracy','Social justice'});
%     set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);     ylabel('Rate','FontSize',20);
%     
%     sd1 = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4)))))];
%     xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
%     text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     
%     sd2 = [std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
%     text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     hold off
% end





% %%% Reception rates for each condition for each veracity for each year WITH STANDARD ERROR
% m_rec_tf_year1 = zeros(nbs2,8); m_rec_tf_year2 = zeros(nbs3,8);
% for ii = 1:nbs2
%     m_rec_tf_year1(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))*100;
%     
%     m_rec_tf_year1(ii,5) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,6) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,7) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year1(ii,8) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==1,10))*100;
% end
% for ii = 1:nbs3
%     m_rec_tf_year2(ii,1) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==2,10))*100;
%     m_rec_tf_year2(ii,2) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))*100;
%     m_rec_tf_year2(ii,3) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))*100;
%     m_rec_tf_year2(ii,4) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))*100;
%     
%     m_rec_tf_year2(ii,5) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,40}==1,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,40}==1,10))*100;
%     m_rec_tf_year2(ii,6) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==1 & allSubAllTrial{:,40}==2,10))*100;
%     m_rec_tf_year2(ii,7) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==2 & allSubAllTrial{:,40}==2,10))*100;
%     m_rec_tf_year2(ii,8) = sum(table2array(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==1 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))) /height(allSubAllTrial(allSubAllTrial{:,1}==ii+nbs2 & allSubAllTrial{:,5}==0 & allSubAllTrial{:,4}==3 & allSubAllTrial{:,40}==2,10))*100;
% end
% 
% figure
% tiledlayout(1,2)
% for jj = 1:2
%     switch jj
%         case 1,     var = m_rec_tf_year1; txt = 'Reception choices (Year 1)';
%         case 2,     var = m_rec_tf_year2; txt = 'Reception choices (Year 2)';
%     end
%     nexttile
%     Y = [mean(var(:,1),'omitnan')  mean(var(:,5),'omitnan') ;
%         mean(var(:,2),'omitnan')  mean(var(:,6),'omitnan') ;
%         mean(var(:,3),'omitnan')  mean(var(:,7),'omitnan')
%         mean(var(:,4),'omitnan')  mean(var(:,8),'omitnan')];
%     sd = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5)))));
%         std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) ;
%         std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7)))))
%         std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     
%     b1 = bar(Y); ylim([30 60]); title(txt,'FontSize',20);    hold on;
%     nbars = size(Y, 2); x = [];
%     for i = 1:nbars
%         x = [x ; b1(i).XEndPoints];
%     end
%     erp = errorbar(x', Y, sd, 'k','linestyle','none');    LA2 = legend('False','True'); LA2.Location ='best';
%     X = categorical({'No theme' 'Ecology','Democracy','Social justice'});
%     set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);    ylabel('Reception rate','FontSize',20);
%     
%     sd1 = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4)))))];
%     xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
%     text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     
%     sd2 = [std(var(:,5),'omitnan')/sqrt(length(var(~isnan(var(:,5))))) std(var(:,6),'omitnan')/sqrt(length(var(~isnan(var(:,6))))) std(var(:,7),'omitnan')/sqrt(length(var(~isnan(var(:,7))))) std(var(:,8),'omitnan')/sqrt(length(var(~isnan(var(:,8)))))];
%     xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
%     text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
%     hold off
% end





%% CLEAR

clearvars -except nbs nbs2 nbs3 nbstim allSubAllTrial ICC IRR idnews plots_data Rec2_allSub Rec3_allSub Rec_allSub Receivingnews2 Receivingnews3 RTs veracity_judgment WTP_avoid WTP_rec m_judgment_p1 m_judgment_p2 m_judgment_year1 m_judgment_year2 m_rec m_rec_tf_year1 m_rec_tf_year2 m_rec_year1 m_rec_year2 m_success_p1 m_success_p2 m_success_year1 m_success_year2 m_WTP_avoid m_WTP_avoid_year1 m_WTP_avoid_year2 m_WTP_rec m_WTP_rec_year1 m_WTP_rec_year2


%% SAVE

save('Testable_Analyses_stats.mat');
cd 'C:/Users/vguigon/Dropbox (Personal)/Neuroeconomics Lab/FAKE NEWS/Scripts/R'
writetable(allSubAllTrial,"receivingNews.csv")
writetable(array2table(Rec_allSub.data_tables(5).models.freq_1), 'receivingNewsSuccess.csv')