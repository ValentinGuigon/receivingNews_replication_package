clear
clc
close all

%% VARIABLES

project_root = 'C:\Users\vguigon\Desktop\Research_directory\receivingNews';
currentFolder = strcat(pwd,'\');

cd(strcat(project_root,'\data\processed'));
load('ReceivingNews_tables')

cd(strcat(project_root,'\outputs\figures'));

%% Install MATLAB Tools
% Clone repository from git@github.com/ValentinGuigon/MATLAB_Tools
% Then add the path to the MATLAB tools
addpath(genpath('C:\Users\vguigon\Dropbox (Personal)\Scripts\Matlab\MATLAB Tools\plotting'))


%% Set Graphics root object properties

% Can also use the following line after plotting every parts of the figure:
% set(gca,'Unit','normalized','Position',[0 0 1 1])

s = settings;
s.matlab.editor.export.FigureResolution.TemporaryValue = 300; % DPI set for the document at 300
outer_position_factor = 0.961;

set(groot, ...
'DefaultFigureColor', 'w', ...
'DefaultAxesLineWidth', 0.5, ...
'DefaultAxesXColor', 'k', ...
'DefaultAxesYColor', 'k', ...
'DefaultAxesFontUnits', 'points', ...
'DefaultAxesFontSize', 16, ...
'DefaultAxesFontName', 'Helvetica', ...
'DefaultLineLineWidth', 1, ...
'DefaultTextFontUnits', 'Points', ...
'DefaultTextFontSize', 16, ...
'DefaultTextFontName', 'Helvetica', ...
'DefaultAxesBox', 'off', ...
'DefaultAxesTickLength', [0.02 0.025], ...
'DefaultFigurePosition', [100 100 550*outer_position_factor 350*outer_position_factor], ... 
'DefaultFigureUnits', 'pixels');

% Default Axes Position to use: set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);

set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');

idnews = plots_data{1:48,3}; idnews(49:96) = plots_data{97:144,3};


%% SUCCESS RATES


% Plot Share of correct judgments against Theoretical random distribution
h = figure; tiledlayout(1,1)
nexttile; set(h, 'DefaultTextFontSize', 16); m=0;
% Generate 258 draws of each 48 binary trials with p = 0.5
n = 48*ones(258,1); p = 0.5; r = binornd(n,p); 
% Transform to frequency
r = r/48;
histogram(r, 20,'Normalization', 'pdf', 'FaceColor','white','facealpha', 1, 'LineWidth', 1.25);
hold on
x1=fitdist(Rec_allSub.data_tables(5).models.freq_1/100,'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
histogram(Rec_allSub.data_tables(5).models.freq_1/100, 20,'Normalization', 'pdf','FaceColor',[0 0.4470 0.7410],'facealpha', .8,'EdgeColor','none');
%line(x1_pdf,y1);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)
title(strcat("Distribution of participants' ability to estimate truthfulness")); 
xlabel('Proportion of correct judgments'); ylabel('Probability density');
legend('Theoretical random distribution','Empirical correct judgments');
box off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% Plot Share of correct judgments for True vs False for each theme
% list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True
h = figure; 
h.Position = [100 100 900*outer_position_factor 350*outer_position_factor];
t = tiledlayout(1,3,'TileSpacing','compact');

taille=16;
set(h, 'DefaultTextFontSize', taille);
set(t, 'DefaultTextFontSize', taille);
titles = {'Ecology', '', 'Democracy', '', 'Social justice'};
for ii = [1 3 5]
    [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100, Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100);
    
    nexttile
    x1=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100,'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
    h1=histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0.8500 0.3250 0.0980]);
    hold on
%     line(x1_pdf,y1);
    x2=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100,'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
    h2=histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0 0.4470 0.7410]);
%     line(x2_pdf,y2);
    hold off
    title(titles(ii), 'FontSize', taille); 
    xticks(0:50:100); xticklabels([0:0.5:1]);
    axis([0 100 0 0.035])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0035, p);
    
    if ii==1
        ylabel('Probability density','FontSize',taille);
    end
end
% title(t, strcat("Distributions of participants' ability to estimate truthfulness"), 'FontSize', taille); 
xlabel(t, 'Proportion of correct judgments', 'FontSize', taille);
lg = legend('False information','True information', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')

% [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,3)*100, Rec_allSub.allSubMeanTrial(3).output(:,3+1)*100);
% [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,5)*100, Rec_allSub.allSubMeanTrial(3).output(:,5+1)*100);





% SUCCESS AGAINST IMPRECISION
clear temp tmp temp2 tmp2
m = 0; x = zeros(length(idnews),3);
h = figure; tiledlayout(1,1)
nexttile
for ii = 1:length(idnews)
    tmp = table2array(plots_data(plots_data.idnews == idnews(ii), 9));
    x(ii,1) = ii;
    x(ii,2) = sum(tmp==1)/length(tmp);
    x(ii,3) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
end

p1 = polyfit(x(:,3),x(:,2),1); f1 = polyval(p1,x(:,3));
hold on;
line([0 10],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
line(x(:,3),f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x(:,3), x(:,2), 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0, 0.4470, 0.7410]); 
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min(x(:,3)) max(x(:,3))])
% title('Frequency of correct truthfulness estimations');
xlabel('Imprecision'); ylabel('Correct judgments');





% SUCCESS AGAINST IMPRECISION FOR NEWS PERCEIVED AS TRUE OR FALSE
clear temp tmp temp2 tmp2
m = 0; [x1_ii, x1_sum, x1_level, x2_ii, x2_sum, x2_level] = deal(double.empty(0,1));
h = figure; tiledlayout(1,1)
nexttile
for ii = 1:length(idnews)
    tmp = plots_data(plots_data.idnews == idnews(ii), :);
    if tmp.veracity(1) == 1
        x1_ii(end+1) = ii;
        x1_sum(end+1) = sum(tmp.success)/length(tmp.success);
        x1_level(end+1) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
    elseif tmp.veracity(1) == 0
        x2_ii(end+1) = ii;
        x2_sum(end+1) = sum(tmp.success)/length(tmp.success);
        x2_level(end+1) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
    end
end

p1 = polyfit(x1_level,x1_sum,1); f1 = polyval(p1,x1_level);
p2 = polyfit(x2_level,x2_sum,1); f2 = polyval(p2,x2_level);
hold on;

line([0 10],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
line(x1_level,f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0, 0.4470, 0.7410]); 
line(x2_level,f2,'Color',[0.8500 0.3250 0.0980]', 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0.8500 0.3250 0.0980]); 
lg = legend([p1 p2], 'True information', 'False information', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min([x1_level x2_level]) max([x1_level x2_level])])
% title('Frequency of correct truthfulness estimations');
xlabel('Imprecision'); ylabel('Correct judgments');
set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);










%% VERACITY JUDGMENT


% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% Plot Share of judgments for True vs False for each theme
% list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True

h = figure; 
h.Position = [100 100 900*outer_position_factor 280*outer_position_factor];
t = tiledlayout(1,3,'TileSpacing','compact');
taille=16;
set(h, 'DefaultTextFontSize', taille);
set(t, 'DefaultTextFontSize', taille);
titles = {'Ecology', '', 'Democracy', '', 'Social justice'};
for ii = [1 3 5]
    [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100, Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100);
    
    nexttile
    x1=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100,'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
    h1=histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0.8500 0.3250 0.0980]);
    hold on
%     line(x1_pdf,y1);
    x2=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100,'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
    h2=histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0 0.4470 0.7410]);
%     line(x2_pdf,y2);
    hold off
%     title(titles(ii)); 
    xticks(0:50:100); xticklabels([0:0.5:1]);
    axis([0 100 0 0.035])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0035, p);
    
    if ii==1
        ylabel('Probability density','FontSize',taille);
    end
end
% title(t, strcat("Distributions of participants' judgments as true"),'FontSize',taille); 
xlabel(t,'Proportion of news reported as being true','FontSize',taille); 
% lg = legend('False information','True information', 'Orientation', 'horizontal','FontSize',taille);
% lg.Layout.Tile = 'North';

% [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,3)*100, Rec_allSub.allSubMeanTrial(8).output(:,3+1)*100);
% [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,5)*100, Rec_allSub.allSubMeanTrial(8).output(:,5+1)*100);





% JUDGMENT AGAINST IMPRECISION
clear temp tmp temp2 tmp2
h = figure; tiledlayout(1,1)
nexttile
m = 0; x = zeros(length(idnews),3);
for ii = 1:length(idnews)
    tmp = table2array(plots_data(plots_data.idnews == idnews(ii), 8));
    x(ii,1) = ii;
    x(ii,2) = sum(tmp==1)/length(tmp);
    x(ii,3) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
end

p1 = polyfit(x(:,3),x(:,2),1); f1 = polyval(p1,x(:,3));
hold on;
line([0 10],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
line(x(:,3),f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x(:,3), x(:,2), 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0, 0.4470, 0.7410]); 
set(gca,'linewidth',1.1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min(x(:,3)) max(x(:,3))])
% title('Frequency of judgments as true');
xlabel('Imprecision'); ylabel('Judgments as true');





% JUDGMENT AGAINST IMPRECISION FOR NEWS PERCEIVED AS TRUE OR FALSE
clear temp tmp temp2 tmp2
m = 0; [x1_ii, x1_sum, x1_level, x2_ii, x2_sum, x2_level] = deal(double.empty(0,1));
h = figure; tiledlayout(1,1)
nexttile
for ii = 1:length(idnews)
    tmp = plots_data(plots_data.idnews == idnews(ii), :);
    if tmp.veracity(1) == 1
        x1_ii(end+1) = ii;
        x1_sum(end+1) = sum(tmp.judgment)/length(tmp.judgment);
        x1_level(end+1) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
    elseif tmp.veracity(1) == 0
        x2_ii(end+1) = ii;
        x2_sum(end+1) = sum(tmp.judgment)/length(tmp.judgment);
        x2_level(end+1) = mean(table2array(plots_data(plots_data.idnews == idnews(ii), 14)));
    end
end

p1 = polyfit(x1_level,x1_sum,1); f1 = polyval(p1,x1_level);
p2 = polyfit(x2_level,x2_sum,1); f2 = polyval(p2,x2_level);
hold on;

line([0 10],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
line(x1_level,f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0, 0.4470, 0.7410]); 
line(x2_level,f2,'Color',[0.8500 0.3250 0.0980]', 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0.8500 0.3250 0.0980]); 
lg = legend([p1 p2], 'True information', 'False information', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min([x1_level x2_level]) max([x1_level x2_level])])
% title('Frequency of judgments as true');
xlabel('Imprecision'); ylabel('Judgments as true');
set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);








%% CONFIDENCE-ACCURACY CALIBRATION

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

% Plot the mean of total Brier score after each trial (from After trial 1 to After trial 48)





% binning data
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

% Confidence-accuracy calibration: judgments as true vs judgments as false
for sub = 1:nbs
    for acc = 1:10 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy_10_F(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_V(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 1,2)));
    end

end


clear temp
m=1; tbl=zeros; percent = struct('percent10',tbl,'percent20',tbl,'percent30',tbl,'percent40',tbl,'percent50',tbl,'percent60',tbl,'percent70',tbl,'percent80',tbl,'percent90',tbl,'percent100',tbl);
fields = fieldnames(percent);
percentF = percent; percentT = percent;

for ii = 1:nbs
    tempF = table2array(Brier.subjects(ii).Bins_accuracy_10_F);
    tempT = table2array(Brier.subjects(ii).Bins_accuracy_10_V);
    
    for jj = 1:10
        percentF.(fields{jj})(ii,1) = tempF(1,jj);
        percentT.(fields{jj})(ii,1) = tempT(1,jj);
    end
end

%  Voir si je peux pas pondérer par le nombre de sujets qui ont des NaN
for jj = 1:10
    tableF(:,jj) = percentF.(fields{jj})(:,1);
    tableT(:,jj) = percentT.(fields{jj})(:,1);
end



% Figure: display full-size then save
colors = cbrewer('qual', 'Paired', 12); m=0; 
figure
t = tiledlayout(1,1);
x = [0 100]; y = [0 1]; x1 = [5:10:100]; x1bis = [5 95]; y1bis = [0.05 1];
yu = y1bis+0.05; yd = y1bis-0.05;
yy = [0.5 0.5]; yyy = [0.45 0.45]; yyyy = [0.55 0.55];
xticks1 = {'', '', '', '', '', '', '', '', '', ''};
xticks2 = {'1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100'};

nexttile
hold on
% title(strcat('News judged as false'),'FontSize',25);
line(x1bis,y1bis,'Color','black','LineStyle','--'); ln = fill([x1bis fliplr(x1bis)], [yu fliplr(yd)], [0.95 0.95 0.95], 'linestyle', 'none');
l1 = line(x1bis,y1bis, 'Color','black', 'LineWidth',1.5);
line([0 100], [0 0], 'Color','black', 'LineWidth',1.5);
l2 = line(x,yy, 'Color',[.7 .7 .7],'LineStyle',':', 'LineWidth',1.5);
line(x,yyy, 'Color',[.7 .7 .7],'LineStyle','--', 'LineWidth',1.5);
line(x,yyyy, 'Color',[.7 .7 .7],'LineStyle','--', 'LineWidth',1.5);

a1_y = mean(tableT,'omitnan');
a2_y = mean(tableF,'omitnan');
% p1= plot(x1, mean(tableT,'omitnan'), 'LineWidth',3,'MarkerSize',30, 'LineStyle', '-', 'Marker', '.', 'Color', colors(2,:)); 
% p2= plot(x1, mean(tableF,'omitnan'),'LineWidth',3,'MarkerSize',30, 'LineStyle', '-', 'Marker', '.', 'Color', colors(9,:)); 

patch([x1 fliplr(x1)], [a1_y(1,1:10)-std(tableT,'omitnan')./sqrt(length(~isnan(tableT))) fliplr(a1_y(1,1:10)+std(tableT,'omitnan')./sqrt(length(~isnan(tableT))))],colors(4,:), 'FaceAlpha', 0.3)
p1 = plot(x1, a1_y(1,1:10),'Color', colors(4,:),'LineWidth',2);

patch([x1 fliplr(x1)], [a2_y(1,1:10)-std(tableF,'omitnan')./sqrt(length(~isnan(tableF))) fliplr(a2_y(1,1:10)+std(tableF,'omitnan')./sqrt(length(~isnan(tableF))))],colors(6,:), 'FaceAlpha', 0.3)
p2 = plot(x1, a2_y(1,1:10),'Color', colors(6,:),'LineWidth',2);

standard_error1 = std(tableT,'omitnan') / sqrt(length(~isnan(tableT)));
e1 = errorbar(x1, mean(tableT,'omitnan'), standard_error1, 'Color', colors(4,:));
standard_error2 = std(tableF,'omitnan') / sqrt(length(~isnan(tableF)));
e2 = errorbar(x1, mean(tableF,'omitnan'), standard_error2, 'Color', colors(6,:));
% 
% e1.CapSize = 30; e2.CapSize = 30;
% e1.LineWidth = 2; e2.LineWidth = 2;
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)

xticks([5:10:100]);
xticklabels(xticks2);
xlabel('Confidence','FontSize',30);
axis([0 100 0 1])

ylabel(t, 'Proportion correct (mean + SE)','FontSize',30);
title(t, strcat('Confidence-accuracy calibration'),'FontSize',30);
lg = legend([p1 p2 l1 l2],'News judged as true','News judged as false','Well-calibrated interval','Non-calibrated interval'...
    ,'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize',22);
 lg.Layout.Tile = 'North';
 
 










%% RECEPTION DESIRABILITY


% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT REC

% Plot REC: Bin by 10 units
clear temp tmp temp2 tmp2
m=0; temp = zeros(10,5); temp2 = zeros(10,5);
for ii = 1:10
    tmp = table2array(plots_data(plots_data.eval >= 1+m & plots_data.eval < ii*10, 10)); % disp([1+m, ii*10])
    temp(ii,1)=ii*10;      temp(ii,2) = sum(tmp==1)/length(tmp);
    [phat,pci] = binofit(sum(tmp==1),length(tmp));
    temp(ii,3) = phat; temp(ii,4) = pci(1); temp(ii,5) = pci(2);
    
    tmp2 = table2array(plots_data(plots_data.eval <= -1-m & plots_data.eval > -ii*10, 10));
    temp2(ii,1)=-ii*10;    temp2(ii,2) = sum(tmp2==1)/length(tmp2);
    [phat2,pci2] = binofit(sum(tmp2==1),length(tmp2));
    temp2(ii,3) = phat2; temp2(ii,4) = pci2(1); temp2(ii,5) = pci2(2);
    m=m+10;
end
supertemp= [temp; temp2]; %bar(supertemp(:,1),supertemp(:,2));





% plot linear interaction
temp = zeros(10,5); temp2 = zeros(10,5);
for jj = 1:nbs
    m=0;
    for ii = 1:10
    tmp = table2array(plots_data(plots_data.eval >= 1+m & plots_data.eval < ii*10 & plots_data.subject == jj, 10)); % disp([1+m, ii*10])
    temp(jj,ii) = sum(tmp==1)/length(tmp);
    
    tmp2 = table2array(plots_data(plots_data.eval <= -1-m & plots_data.eval > -ii*10 & plots_data.subject == jj, 10));
    temp2(jj,ii) = sum(tmp2==1)/length(tmp2);
    m=m+10;
    end
end

x1=supertemp(1:10,1); y1=supertemp(1:10,2);
x2=supertemp(1:10,1); y2=supertemp(11:20,2);

figure
p1 = polyfit(x1,y1,1); f1 = polyval(p1,x1);
p2 = polyfit(x2,y2,1); f2 = polyval(p2,x2);
hold on;

line(x1,f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x1, y1, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0, 0.4470, 0.7410]); 
line(x2,f2,'Color',[0.6350 0.0780 0.1840], 'LineWidth', 1.5);
p2 = plot(x2, y2, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', [0.6350 0.0780 0.1840]); 

line([10 100],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
for ii = 1:10
    line([x1(ii) x1(ii)], [supertemp(ii,4) supertemp(ii,5)], 'Color', [0, 0.4470, 0.7410], 'LineWidth', 1);
    line([x2(ii) x2(ii)], [supertemp(ii+10,4) supertemp(ii+10,5)], 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 1);
end

ylim([0.25 0.75])
xlim([10 100])
xticklabels({'', '11-20', '', '31-40', '', '51-60', '', '71-80', '', '91-100'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',16)
legend([p1 p2], 'News judged as true', 'News judged as false')
title('Average probability to receive more news');
xlabel('Confidence degree'); ylabel('Reception probability + CI');
xticklabels({'', '11-20', '', '31-40', '', '51-60', '', '71-80', '', '91-100'});





% RECEPTION AGAINST CONFIDENCE FOR NEWS TRUE OR FALSE
clear tmp x1_ii x1_sum x1_level x2_ii x2_sum x2_level
m = 0; [x1_ii, x1_sum, x1_level, x2_ii, x2_sum, x2_level] = deal(double.empty(0,1));
h = figure; tiledlayout(1,1)
nexttile
for ii = 1:nbs
    tmp = allSubAllTrial(allSubAllTrial.subject == ii, :);
    
    x1_ii(end+1) = ii;
    x1_sum(end+1) = sum(tmp.rec(tmp.judgment==1))/length(tmp.rec(tmp.judgment==1));
    x1_level(end+1) = mean(table2array(tmp(tmp.subject == ii & tmp.judgment==1, 6)));
    
    x2_ii(end+1) = ii;
    x2_sum(end+1) = sum(tmp.rec(tmp.judgment==0))/length(tmp.rec(tmp.judgment==0));
    x2_level(end+1) = mean(table2array(tmp(tmp.subject == ii & tmp.judgment==1, 6)));
end

p1 = polyfit(x1_level,x1_sum,1); f1 = polyval(p1,x1_level);
p2 = polyfit(x2_level,x2_sum,1); f2 = polyval(p2,x2_level);
hold on;

line([0 100],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
line(x1_level,f1,'Color',[0, 0.4470, 0.7410]', 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', '.', 'Color', [0, 0.4470, 0.7410]); 
line(x2_level,f2,'Color',[0.8500 0.3250 0.0980]', 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', '.', 'Color', [0.8500 0.3250 0.0980]); 
lg = legend([p1 p2], 'Judged as True', 'Judged as False', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min([x1_level x2_level]) max([x1_level x2_level])])
% title('Frequency of judgments as true');
xlabel('Confidence'); ylabel('Reception probability');
set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);
set(gca,'linewidth',1)












%% WTP

% WTP FOR NEWS PERCEIVED AS TRUE OR FALSE

h = figure; 
h.Position = [100 100 900 400];     clear temp tmp temp2 tmp2
t = tiledlayout(1,2);
legend('News perceived as true','News perceived as false','FontSize',25, 'Location', 'southoutside');
for jj = 1:2
    switch jj
        case 1,     var = 1; txt = 'WTP to receive more news';
        case 2,     var = 2; txt = 'WTP to not receive more news';
    end
    nexttile
    temp1 = plots_data(plots_data.eval > 0 & plots_data.rec ==var,:); temp2 = plots_data(plots_data.eval < 0 & plots_data.rec ==var,:);
    x2=fitdist(temp2.WTP,'normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf'); temp=-(h2.Values); %#ok<*NBRAK>
    legend([h2], {'test'});
    x1=fitdist(temp1.WTP,'normal'); x1_pdf = [1:1:25]; y1 =   pdf(x1,x1_pdf);  h1 = histogram(temp1.WTP, 'Normalization', 'pdf'); line(x1_pdf,y1, 'HandleVisibility','off');
    hold on; b=bar([0:25], temp); line(x2_pdf,y2, 'HandleVisibility','off'); b.BarWidth=1;
    set(gca,'YLim',[-0.3 0.3])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    title(txt);
    xlabel('Willingness-to-pay'); 
    if jj == 1
        ylabel('Probability density');
    end
    yticks([-0.3 -0.2 -0.1 0 0.1 0.2 0.3])
end
lg = legend('News judged as true','News judged as false', 'Orientation', 'horizontal');
lg.Layout.Tile = 'South';





% WTP FOR NEWS DESIRED/UNDESIRED
clear temp tmp temp2 tmp2
temp1 = plots_data(plots_data{:,10}==1,:); temp2 = plots_data(plots_data{:,10}==2,:);
h = figure;
t = tiledlayout(1,1);
nexttile
x2=fitdist(temp2.WTP,'Normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf'); temp=-(h2.Values);
x1=fitdist(temp1.WTP,'Normal'); x1_pdf = [1:1:25]; y1 = pdf(x1,x1_pdf); h1 = histogram(temp1.WTP, 'Normalization', 'pdf'); line(x1_pdf,y1,'HandleVisibility','off');
hold on; b=bar([0:25], temp); line(x2_pdf,y2,'HandleVisibility','off'); b.BarWidth=1;
%title('WTP to receive vs not to receive additional news', 'FontWeight','Normal');
xlabel('Willingness-to-pay'); ylabel('Probability density');
lg = legend('Reception','No reception','Orientation', 'horizontal','location','North');
set(gca,'YLim',[-0.3 0.3])
set(gca,'linewidth',1)
set(gca, 'box', 'off')
set(lg,'Box','off')
yticks(-0.3:0.1:0.3)





% % Correct judgments (truthfulness estimation success) explained by Truthfulness & Imprecision 
% for jj = 1:96
%     success_imprecision(jj,1) = mean(allSubAllTrial{allSubAllTrial{:,3} == idnews(jj), 3});
%     success_imprecision(jj,2) = mean(allSubAllTrial{allSubAllTrial{:,3} == idnews(jj), 14});
%     success_imprecision(jj,3) = mean(allSubAllTrial{allSubAllTrial{:,3} == idnews(jj), 9});
%     success_imprecision(jj,4) = mean(allSubAllTrial{allSubAllTrial{:,3} == idnews(jj), 5});
% end
% 
% figure
% scatter(success_imprecision(success_imprecision(:,4)==1,2), success_imprecision(success_imprecision(:,4)==1,3))
% hold on
% scatter(success_imprecision(success_imprecision(:,4)==0,2), success_imprecision(success_imprecision(:,4)==0,3))
% 
% 
% 
% % News reported as true (judgment as true) explained by Truthfulness & Imprecision


