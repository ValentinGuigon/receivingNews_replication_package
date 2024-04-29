clear
clc
close all

%% Notes
% Signed rank test when the data are paired and values are positively dependent (e.g., repeated measures). Otherwise, rank sum (i.e., unpaired values)


%% MERGE TABLES
load('Testable_Analyses_stats_n258.mat')
addpath(genpath('C:\Users\vguigon\Dropbox (Personal)\Scripts\Matlab\Anne Urai - Tools-master\plotting'))


%% Set Graphics root object properties

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
'DefaultAxesTickLength', [0.02 0.025]);

set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');



%% SUCCESS RATES

figure
dtempR = table2array(Rec_allSub.data_tables(5).models(:,1:48)); cellsIWantR = dtempR(1:79,:);
Success_year1 = sum(cellsIWantR,2)/size(cellsIWantR,2);
x1=fitdist(Success_year1*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1);

cellsIWantR = dtempR(80:end,:); Success_year2 = sum(cellsIWantR,2)/size(cellsIWantR,2);
x1=fitdist(Success_year2*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','red');
title(strcat("Participants' success rates"),'FontSize',22); xlabel('Frequency of success','FontSize',20); ylabel('Density','FontSize',20);
legend('Year 1','Year 2','FontSize',20);
set(gca, 'FontSize',18);





% Plot Share of correct judgments against Theoretical random distribution
h = figure; tiledlayout(1,1)
nexttile; set(h, 'DefaultTextFontSize', 30); m=0;
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
title(strcat("Distribution of participants' ability to estimate truthfulness"),'FontSize',30); 
xlabel('Proportion of correct judgments','FontSize',30); ylabel('Probability density','FontSize',30);
legend('Theoretical random distribution','Empirical correct judgments','FontSize',30);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISONS TRUE vs FALSE, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

figure
x1=fitdist(Rec_allSub.allSubTruthTrial(3).output(:,1)*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','red');
x1=fitdist(Rec_allSub.allSubTruthTrial(3).output(:,2)*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','green');
title(strcat("Participants' success rates"),'FontSize',22); xlabel('Frequency of success','FontSize',20); ylabel('Density','FontSize',20);
legend('False news','True news','FontSize',20);
set(gca, 'FontSize',18);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARISON BETWEEN FIRST HALF AND SECOND HALF OF THE TASK

% GRAPH (Report of standard deviation, not standard error)
a1_Y = [mean(Rec_allSub.data_tables(5).models.freq_1)/100 mean(Rec_allSub.allSubThemeTrial(3).output(:,1)) mean(Rec_allSub.allSubThemeTrial(3).output(:,2)) mean(Rec_allSub.allSubThemeTrial(3).output(:,3))];
a1_sd = [std(Rec_allSub.data_tables(5).models.freq_1)/100 std(Rec_allSub.allSubThemeTrial(3).output(:,1)) std(Rec_allSub.allSubThemeTrial(3).output(:,2)) std(Rec_allSub.allSubThemeTrial(3).output(:,3))];

X = categorical({'No theme' 'Ecol','Demo','Just'});  X = reordercats(X,{'No theme' 'Ecol','Demo','Just'});
figure; b1 = bar(a1_Y); ylim([0.3 1]);  title('Success rates per condition','FontSize',30);
hold on;
erp = errorbar( a1_Y, a1_sd, 'k','linestyle','none');  set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',30);
ylabel('Success rates','FontSize',30);
xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
text(xtips1,ytips1+a1_sd,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',25);
b1.FaceColor='flat'; %CData = control individual bars
b1.CData(1,:) = [1 1 1]; b1.CData(2,:) = [0.00,0.70,0.47]; b1.CData(4,:) = [0.8500, 0.3250, 0.0980]; 
hold off;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% Plot Share of correct judgments for True vs False for each theme
% list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True
h = figure; t = tiledlayout(1,3);
h.Position = [100 100 900 400];
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
    axis([0 100 0 0.032])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0031, p);
end
title(t, strcat("Distributions of participants' ability to estimate truthfulness"), 'FontSize', taille); 
xlabel(t, 'Proportion of correct judgments', 'FontSize', taille); ylabel(t, 'Probability density', 'FontSize', taille);
lg = legend('False information','True information', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';

% [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,3)*100, Rec_allSub.allSubMeanTrial(3).output(:,3+1)*100);
% [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,5)*100, Rec_allSub.allSubMeanTrial(3).output(:,5+1)*100);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% GRAPH (Report of standard deviation, not standard error)
a1_Y = [mean(Rec_allSub.allSubTruthTrial(3).output(:,1)) mean(Rec_allSub.allSubTruthTrial(3).output(:,2)); mean(Rec_allSub.allSubMeanTrial(3).output(:,1)) mean(Rec_allSub.allSubMeanTrial(3).output(:,2)); mean(Rec_allSub.allSubMeanTrial(3).output(:,3)) mean(Rec_allSub.allSubMeanTrial(3).output(:,4)); mean(Rec_allSub.allSubMeanTrial(3).output(:,5)) mean(Rec_allSub.allSubMeanTrial(3).output(:,6))];
a1_sd = [std(Rec_allSub.allSubTruthTrial(3).output(:,1)) std(Rec_allSub.allSubTruthTrial(3).output(:,2)); std(Rec_allSub.allSubMeanTrial(3).output(:,1)) std(Rec_allSub.allSubMeanTrial(3).output(:,2)); std(Rec_allSub.allSubMeanTrial(3).output(:,3)) std(Rec_allSub.allSubMeanTrial(3).output(:,4)); std(Rec_allSub.allSubMeanTrial(3).output(:,5)) std(Rec_allSub.allSubMeanTrial(3).output(:,6))];
standard_error = [std(Rec_allSub.allSubTruthTrial(3).output(:,1))/sqrt(length(~isnan(Rec_allSub.allSubTruthTrial(3).output(:,1))))... 
    std(Rec_allSub.allSubTruthTrial(3).output(:,2))/sqrt(length(~isnan(Rec_allSub.allSubTruthTrial(3).output(:,2))));... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,1))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,1))))... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,2))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,2))));... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,3))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,3))))... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,4))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,4))));... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,5))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,5))))... 
    std(Rec_allSub.allSubMeanTrial(3).output(:,6))/sqrt(length(~isnan(Rec_allSub.allSubMeanTrial(3).output(:,6))))];

figure
t = tiledlayout(1,1,'Padding','compact','TileSpacing','compact');
nexttile; hold on
for ii = 1:9
    line([0 5],[ii/10 ii/10], 'Color',[0.9 0.9 0.9],'LineStyle','-');
end
X = categorical({'No theme'; 'Ecology'; 'Democracy'; 'Social justice'});  
X = reordercats(X,{'No theme'; 'Ecology'; 'Democracy'; 'Social justice'}); 
b1 = bar(a1_Y, 'grouped'); ylim([0.3 1]);

[ngroups, nbars] = size(a1_Y);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b1(i).XEndPoints;
end
erp = errorbar(x', a1_Y, standard_error, 'k','linestyle','none');  
set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',19);

ylabel(t, 'Mean success + SE','FontSize',30); xlabel('Themes','FontSize',30); 
title(t, 'Success rates','FontSize',30);
b1(1).FaceColor = [0.8500 0.3250 0.0980];
b1(2).FaceColor = [0 0.4470 0.7410];
b1(1).FaceAlpha = .85; b1(2).FaceAlpha = .85; 
lg = legend([b1(1) b1(2)], 'False information','True information', 'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize',25);
hold off;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

% Success rates for each condition for each year WITH STANDARD ERROR
figure; tiledlayout(1,2)
for jj = 1:2
    switch jj
        case 1,     var = m_success_year1; txt = 'Success rate (Year 1)';
        case 2,     var = m_success_year2; txt = 'Success rate (Year 2)';
    end
    nexttile
    Y = [mean(var(:,1),'omitnan') mean(var(:,2),'omitnan') mean(var(:,3),'omitnan')  mean(var(:,4),'omitnan')];
    sd = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4)))))];
     
    b1 = bar(Y); ylim([0 100]); title(txt,'FontSize',20);
    hold on;
    erp = errorbar( Y, sd, 'k','linestyle','none');  set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
    X = categorical({'no theme' 'Ecology','Democracy','Social justice'});
    set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
    ylabel('Average Rate (judging as true)','FontSize',20);
    xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
    text(xtips1,ytips1+sd,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',19);
    b1.FaceColor='flat';  %CData = control individual bars
    b1.CData(1,:) = [1 1 1];
    b1.CData(2,:) = [0.00,0.70,0.47];
    b1.CData(4,:) = [0.8500, 0.3250, 0.0980];
    hold off
end










%% VERACITY JUDGMENT

figure
dtempR = table2array(veracity_judgment(:,1:48)); cellsIWantR = dtempR(1:79,:);
Judgment_year1 = sum(cellsIWantR,2)/size(cellsIWantR,2);
x1=fitdist(Judgment_year1*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1);

cellsIWantR = dtempR(80:end,:); Judgment_year2 = sum(cellsIWantR,2)/size(cellsIWantR,2);
x1=fitdist(Judgment_year2*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','red');
title(strcat("Participants' judgment rates"),'FontSize',22); xlabel('Frequency of judging as true','FontSize',20); ylabel('Density','FontSize',20);
legend('Year 1','Year 2','FontSize',20);
set(gca, 'FontSize',18);

[p,h,stats] = ranksum(Judgment_year1, Judgment_year2); % h=0





% COMPARISONS TRUE vs FALSE, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

a1_Y = [mean(veracity_judgment.mean_pos) mean(Rec_allSub.allSubThemeTrial(8).output(:,1)) mean(Rec_allSub.allSubThemeTrial(8).output(:,2)) mean(Rec_allSub.allSubThemeTrial(8).output(:,3))];
a1_sd = [std(veracity_judgment.mean_pos) std(Rec_allSub.allSubThemeTrial(8).output(:,1)) std(Rec_allSub.allSubThemeTrial(8).output(:,2)) std(Rec_allSub.allSubThemeTrial(8).output(:,3))];

X = categorical({'No theme' 'Ecol','Demo','Just'});  X = reordercats(X,{'No theme' 'Ecol','Demo','Just'});
figure; b1 = bar(a1_Y); ylim([0.3 1]);  title('Judgment rates per condition','FontSize',20);
hold on;
erp = errorbar( a1_Y, a1_sd, 'k','linestyle','none');  set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
ylabel('Judment rates (judging as true)','FontSize',20);
xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
text(xtips1,ytips1+a1_sd,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',19);
b1.FaceColor='flat'; %CData = control individual bars
b1.CData(1,:) = [1 1 1]; b1.CData(2,:) = [0.00,0.70,0.47]; b1.CData(4,:) = [0.8500, 0.3250, 0.0980]; 
hold off;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% Plot Share of judgments for True vs False for each theme
% list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True
h = figure; t = tiledlayout(1,3);
h.Position = [100 100 900 400];
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
    title(titles(ii)); 
    xticks(0:50:100); xticklabels([0:0.5:1]);
    axis([0 100 0 0.032])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0031, p);
end
title(t, strcat("Distributions of participants' judgments as true"),'FontSize',taille); 
xlabel(t, 'Proportion of judgments as true','FontSize',taille); ylabel(t, 'Probability density','FontSize',taille);
lg = legend('False information','True information', 'Orientation', 'horizontal','FontSize',taille);
lg.Layout.Tile = 'North';

% [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,3)*100, Rec_allSub.allSubMeanTrial(8).output(:,3+1)*100);
% [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,5)*100, Rec_allSub.allSubMeanTrial(8).output(:,5+1)*100);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

% Reception rates for each condition for each year WITH STANDARD ERROR
figure; tiledlayout(1,2)
for jj = 1:2
    switch jj
        case 1,     var = m_judgment_year1; txt = 'Veracity judgment (Year 1)';
        case 2,     var = m_judgment_year2; txt = 'Veracity judgment (Year 2)';
    end
    nexttile
    Y = [mean(var(:,1),'omitnan') mean(var(:,2),'omitnan') mean(var(:,3),'omitnan')  mean(var(:,4),'omitnan')];
    sd = [std(var(:,1),'omitnan')/sqrt(length(var(~isnan(var(:,1))))) std(var(:,2),'omitnan')/sqrt(length(var(~isnan(var(:,2))))) std(var(:,3),'omitnan')/sqrt(length(var(~isnan(var(:,3))))) std(var(:,4),'omitnan')/sqrt(length(var(~isnan(var(:,4)))))];
     
    b1 = bar(Y); ylim([0 100]); title(txt,'FontSize',20);
    hold on;
    erp = errorbar( Y, sd, 'k','linestyle','none');  set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
    X = categorical({'no theme' 'Ecology','Democracy','Social justice'});
    set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
    ylabel('Average Rate (judging as true)','FontSize',20);
    xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
    text(xtips1,ytips1+sd,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',19);
    b1.FaceColor='flat';  %CData = control individual bars
    b1.CData(1,:) = [1 1 1];
    b1.CData(2,:) = [0.00,0.70,0.47];
    b1.CData(4,:) = [0.8500, 0.3250, 0.0980];
    hold off
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot CORRECT JUDGMENTS VS JUDGMENTSD AS TRUE

% % Plot Share of correct judgments for True vs False for each theme
% % list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True
% h = figure; t = tiledlayout(1,3);
% titles = {'Theme: ecology', '', 'Theme: democracy', '', 'Theme: social justice'};
% set(h, 'DefaultTextFontSize', 30);
% for ii = [1 3 5]
%     nexttile
%     x1=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii),'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
%     histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii),8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0.8500 0.3250 0.0980]);
%     hold on
% %     line(x1_pdf,y1);
%     x2=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii+1),'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
%     histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii+1),8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0 0.4470 0.7410]);
% %     line(x2_pdf,y2);
%     hold off
%     title(titles(ii),'FontSize',30); 
%     xticks(0:0.2:1);
%     axis([0 1 0 3])
% end
% title(t, strcat("Participants' ability to estimate truthfulness"),'FontSize',30); 
% xlabel(t, 'Proportion of correct judgments','FontSize',30); ylabel(t, 'Probability density','FontSize',30);
% legend('False information','True information','FontSize',30);





% % Plot Share of judgments for True vs False for each theme
% % list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True
% h = figure; t = tiledlayout(1,3);
% titles = {'Theme: ecology', '', 'Theme: democracy', '', 'Theme: social justice'};
% set(h, 'DefaultTextFontSize', 30);
% for ii = [1 3 5]
%     nexttile
%     x1=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii),'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
%     histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii),8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0.8500 0.3250 0.0980]);
%     hold on
% %     line(x1_pdf,y1);
%     x2=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii+1),'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
%     histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii+1),8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', [0 0.4470 0.7410]);
% %     line(x2_pdf,y2);
%     hold off
%     title(titles(ii),'FontSize',30); 
%     xticks(0:0.2:1);
%     axis([0 1 0 3])
% end
% title(t, strcat("Participants' judgments as true"),'FontSize',30); 
% xlabel(t, 'Proportion of judgments as true','FontSize',30); ylabel(t, 'Probability density','FontSize',30);
% legend('False information','True information','FontSize',30);










%% CONFIDENCE VALUES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

f1 = figure; hold on
year1 = Rec_allSub.data_tables(3).models(1:79,:); year2 = Rec_allSub.data_tables(3).models(80:end,:);
var = 'mean_pos';   hY1pos = histogram(year1.(var), 'Normalization', 'pdf');     hY1posValues = hY1pos.Values;     hY1posbins = hY1pos.BinEdges;
hY2pos = histogram(year2.(var), 'Normalization', 'pdf');     hY2posValues = hY2pos.Values;     hY2posbins = hY2pos.BinEdges;
var = 'mean_neg';   hY1neg = histogram(year1.(var), 'Normalization', 'pdf');     hY1negValues = hY1neg.Values;     hY1negbins = hY1neg.BinEdges;
hY2neg = histogram(year2.(var), 'Normalization', 'pdf');     hY2negValues = hY2neg.Values;     hY2negbins = hY2neg.BinEdges;
title('Getting values of gaussian distribution of confidence values'); hold off; close(f1)
% Bins array
binY1 = [0 hY1negbins 0 0 0 hY1posbins];             binY2 = [hY2negbins 0 hY2posbins];
% Values array
yY1 = [0 0 hY1negValues 0 0 0 hY1posValues 0];         yY2 = [0 hY2negValues 0 hY2posValues 0];

figure
f = fit([-100:10:100]', yY1', 'gauss2');
a1 = f.a1; b1 = f.b1; c1 = f.c1; a2 = f.a2; b2 = f.b2; c2 = f.c2; % Coefficients
fplot(@(x) f(x), [-100 100],'Color',[0 0.4470 0.7410]); hold on

f = fit([-100:10:100]', yY2', 'gauss2');
a1 = f.a1; b1 = f.b1; c1 = f.c1; a2 = f.a2; b2 = f.b2; c2 = f.c2; % Coefficients
fplot(@(x) f(x), [-100 100],'Color',[0.6350 0.0780 0.1840]); hold on
legend('Year 1','year 2','FontSize',20,'Location','northwest');
title(strcat("Participants' average confidence in their evaluations"),'FontSize',22); xlabel('Confidence degree for "false" and "true" judgments','FontSize',20); ylabel('Density','FontSize',20);
set(gca, 'FontSize',18); hold off





% Confidence degrees for each THEME
f1 = figure; hold on
data = Rec_allSub.data_tables(3).models;   
hY1pos = histogram(data.scoreDemoPos, 'Normalization', 'pdf');     hY1posValues = hY1pos.Values;     hY1posbins = hY1pos.BinEdges;
hY2pos = histogram(data.scoreEcolPos, 'Normalization', 'pdf');     hY2posValues = hY2pos.Values;     hY2posbins = hY2pos.BinEdges;
hY3pos = histogram(data.scoreJustPos, 'Normalization', 'pdf');     hY3posValues = hY3pos.Values;     hY3posbins = hY3pos.BinEdges;
hY1neg = histogram(data.scoreDemoNeg, 'Normalization', 'pdf');     hY1negValues = hY1neg.Values;     hY1negbins = hY1neg.BinEdges;
hY2neg = histogram(data.scoreEcolNeg, 'Normalization', 'pdf');     hY2negValues = hY2neg.Values;     hY2negbins = hY2neg.BinEdges;
hY3neg = histogram(data.scoreJustNeg, 'Normalization', 'pdf');     hY3negValues = hY3neg.Values;     hY3negbins = hY3neg.BinEdges;
title('Getting values of gaussian distribution of confidence values'); hold off; close(f1)
% Bins array
binY1 = [hY1negbins 0 hY1posbins];          binY2 = [hY2negbins hY2posbins];        binY3 = [hY3negbins hY3posbins];
% Values array
yY1 = [0 hY1negValues 0 hY1posValues 0];    yY2 = [0 hY2negValues 0 hY2posValues];  yY3 = [0 hY3negValues 0 hY3posValues];

figure
f = fit([-100:10:100]', yY1', 'gauss2');
a1 = f.a1; b1 = f.b1; c1 = f.c1; a2 = f.a2; b2 = f.b2; c2 = f.c2; % Coefficients
fplot(@(x) f(x), [-100 100],'Color',[0 0.4470 0.7410]); hold on

f = fit([-100:10:100]', yY2', 'gauss2');
a1 = f.a1; b1 = f.b1; c1 = f.c1; a2 = f.a2; b2 = f.b2; c2 = f.c2; % Coefficients
fplot(@(x) f(x), [-100 100],'Color','green'); hold on

f = fit([-100:10:100]', yY3', 'gauss2');
a1 = f.a1; b1 = f.b1; c1 = f.c1; a2 = f.a2; b2 = f.b2; c2 = f.c2; % Coefficients
fplot(@(x) f(x), [-100 100],'Color',[0.6350 0.0780 0.1840]); hold on

legend('Democracy','Ecology','Social justice','FontSize',20,'Location','northwest');
title(strcat("Participants' average confidence in their evaluations"),'FontSize',22); xlabel('Confidence degree for "false" and "true" judgments','FontSize',20); ylabel('Density','FontSize',20);
set(gca, 'FontSize',18); hold off










%% RECEPTION DESIRABILITY

m=0; figure; k=1;
dtempR = table2array(Rec_allSub.data_tables(6).models(:,1:48)); vtempR = table2array(Rec_allSub.data_tables(3).models(:,1:48));
cellsIWantR = vtempR(:,:) >0; extractedDataR = dtempR(cellsIWantR);
Desir_TrueR = sum(extractedDataR,2)/size(extractedDataR,2);
x1=fitdist(Desir_TrueR*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','green');
colsIWantR = vtempR(1,:) <0; extractedDataR = dtempR(:,colsIWantR);
Desir_FalseR = sum(extractedDataR,2)/size(extractedDataR,2);
x1=fitdist(Desir_FalseR*100,'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','red');
title(strcat("Participants' desirability rates"),'FontSize',22); xlabel('Frequency of choices to receive','FontSize',20); ylabel('Density','FontSize',20);
legend('News judged as true','News judged as false','FontSize',20);
set(gca, 'FontSize',18);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS

% WTP for each condition WITH STANDARD ERROR
Y = [mean(m_rec(:,1),'omitnan')  mean(m_rec(:,4),'omitnan') ;
    mean(m_rec(:,2),'omitnan')  mean(m_rec(:,5),'omitnan') ;
    mean(m_rec(:,3),'omitnan')  mean(m_rec(:,6),'omitnan')];
sd = [std(m_rec(:,1),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,1))))) std(m_rec(:,4),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,1)))));
    std(m_rec(:,2),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,2))))) std(m_rec(:,5),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,2))))) ;
    std(m_rec(:,3),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,3))))) std(m_rec(:,6),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,3)))))];
figure;
b1 = bar(Y); ylim([30 60]);  title('Reception choices','FontSize',20);
hold on;
nbars = size(Y, 2); x = [];
for i = 1:nbars
    x = [x ; b1(i).XEndPoints];
end
erp = errorbar(x', Y, sd, 'k','linestyle','none');
LA2 = legend('False','True'); LA2.Location ='best';
X = categorical({'Ecology','Democracy','Social justice'});
set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
ylabel('Reception rate','FontSize',20);
sd1 = [std(m_rec(:,1),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,1))))) std(m_rec(:,2),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,2))))) std(m_rec(:,3),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,3)))))];
xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
sd2 = [std(m_rec(:,3),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,3))))) std(m_rec(:,4),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,4))))) std(m_rec(:,6),'omitnan')/sqrt(length(m_rec(~isnan(m_rec(:,6)))))];
xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

% Reception rates for each condition for each year WITH STANDARD ERROR
figure
Y = [mean(m_rec_year1(:,1),'omitnan')  mean(m_rec_year2(:,1),'omitnan') ;
    mean(m_rec_year1(:,2),'omitnan')  mean(m_rec_year2(:,2),'omitnan') ;
    mean(m_rec_year1(:,3),'omitnan')  mean(m_rec_year2(:,3),'omitnan')
    mean(m_rec_year1(:,4),'omitnan')  mean(m_rec_year2(:,4),'omitnan')];
sd = [std(m_rec_year1(:,1),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,1))))) std(m_rec_year2(:,1),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,1)))));
    std(m_rec_year1(:,2),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,2))))) std(m_rec_year2(:,2),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,2))))) ;
    std(m_rec_year1(:,3),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,3))))) std(m_rec_year2(:,3),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,3)))))
    std(m_rec_year1(:,4),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,4))))) std(m_rec_year2(:,4),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,4)))))];
b1 = bar(Y); ylim([0 100]); title('Reception choices','FontSize',20);
hold on;
nbars = size(Y, 2); x = [];
for i = 1:nbars
    x = [x ; b1(i).XEndPoints];
end
erp = errorbar(x', Y, sd, 'k','linestyle','none');
LA2 = legend('Year 1','year 2'); LA2.Location ='best';
X = categorical({'No theme' 'Ecology','Democracy','Social justice'});
set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
ylabel('Reception rate','FontSize',20);
sd1 = [std(m_rec_year1(:,1),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,1))))) std(m_rec_year1(:,2),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,2))))) std(m_rec_year1(:,3),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,3))))) std(m_rec_year1(:,4),'omitnan')/sqrt(length(m_rec_year1(~isnan(m_rec_year1(:,4)))))];
xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
sd2 = [std(m_rec_year2(:,1),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,1))))) std(m_rec_year2(:,2),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,2))))) std(m_rec_year2(:,3),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,3))))) std(m_rec_year2(:,4),'omitnan')/sqrt(length(m_rec_year2(~isnan(m_rec_year2(:,4)))))];
xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
hold off





% Reception rates for each year
year1 = Rec_allSub.data_tables(6).models(1:79,:); year2 = Rec_allSub.data_tables(6).models(80:end,:);
var = 'freq_1'; figure
x1=fitdist((year1.(var)),'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color',[0 0.4470 0.7410]);
title(strcat("Participants' desirability rates"),'FontSize',20); xlabel('Frequency of choices to receive','FontSize',20); ylabel('Density','FontSize',20);
legend('year 1','FontSize',20);
set(gca, 'FontSize',18);
hold on
x1=fitdist((year2.(var)),'Normal'); x1_pdf = [1:1:100]; y1 = pdf(x1,x1_pdf);
line(x1_pdf,y1,'Color','red');
title(strcat("Participants' desirability rates"),'FontSize',20); xlabel('Frequency of choices to receive','FontSize',20); ylabel('Density','FontSize',20);
legend({'year 1' 'year 2'},'FontSize',20);
set(gca, 'FontSize',18);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT REC

% Plot REC: Bin by 10 units
clear temp tmp temp2 tmp2
figure
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
supertemp= [temp; temp2]; bar(supertemp(:,1),supertemp(:,2));
for I = 1:10                                       % connect upper and lower bound with a line
    line([I*10 I*10],[supertemp(I,4) supertemp(I,5)],'Color','red');
    line([-I*10 -I*10],[supertemp(I+10,4) supertemp(I+10,5)], 'Color','red');
    hold on;
end
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)
title('Average desirability to receive more news as a function of news perceived veracity and evaluation confidence','FontSize',20);
xlabel('News evaluation','FontSize',20); ylabel('Receivers derisability','FontSize',20);





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
xticklabels({'1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18)
legend([p1 p2], 'News judged as true', 'News judged as false','FontSize',30)
title('Average desirability to receive more news','FontSize',30);
xlabel('Confidence in judgment','FontSize',30); ylabel('Reception probability + CI','FontSize',30);





% Plot REC: Bin by 10 units: Year 1 and Year 2
clear temp_y1 tmp_y1 temp2_y1 tmp2_y1   temp_y2 tmp_y2 temp2_y2 tmp2_y2
m=0; temp_y1 = zeros(10,5); temp2_y1 = zeros(10,5); temp_y2 = zeros(10,5); temp2_y2 = zeros(10,5);
for ii = 1:10
    tmp_y1 = table2array(plots_data(plots_data.eval >= 1+m & plots_data.eval < ii*10 & plots_data.year == 1, 10)); % disp([1+m, ii*10])
    temp_y1(ii,1)=ii*10;      temp_y1(ii,2) = sum(tmp_y1==1)/length(tmp_y1);
    [phat,pci] = binofit(sum(tmp_y1==1),length(tmp_y1));
    temp_y1(ii,3) = phat; temp_y1(ii,4) = pci(1); temp_y1(ii,5) = pci(2);
    
    tmp_y2 = table2array(plots_data(plots_data.eval >= 1+m & plots_data.eval < ii*10 & plots_data.year == 2, 10));
    temp_y2(ii,1)=ii*10;      temp_y2(ii,2) = sum(tmp_y2==1)/length(tmp_y2);
    [phat,pci] = binofit(sum(tmp_y2==1),length(tmp_y2));
    temp_y2(ii,3) = phat; temp_y2(ii,4) = pci(1); temp_y2(ii,5) = pci(2);
    
    tmp2_y1 = table2array(plots_data(plots_data.eval <= -1-m & plots_data.eval > -ii*10 & plots_data.year == 1, 10));
    temp2_y1(ii,1)=-ii*10;    temp2_y1(ii,2) = sum(tmp2_y1==1)/length(tmp2_y1);
    [phat2,pci2] = binofit(sum(tmp2_y1==1),length(tmp2_y1));
    temp2_y1(ii,3) = phat2; temp2_y1(ii,4) = pci2(1); temp2_y1(ii,5) = pci2(2);
    
    tmp2_y2 = table2array(plots_data(plots_data.eval <= -1-m & plots_data.eval > -ii*10 & plots_data.year == 2, 10));
    temp2_y2(ii,1)=-ii*10;    temp2_y2(ii,2) = sum(tmp2_y2==1)/length(tmp2_y2);
    [phat2,pci2] = binofit(sum(tmp2_y2==1),length(tmp2_y2));
    temp2_y2(ii,3) = phat2; temp2_y2(ii,4) = pci2(1); temp2_y2(ii,5) = pci2(2);
    m=m+10;
end
supertemp_y1= [temp_y1; temp2_y1]; supertemp_y2= [temp_y2; temp2_y2];
figure; tiledlayout(1,2);
for jj = 1:2
    nexttile
    switch jj
        case 1, variable1 = supertemp_y1;   head = {'Desirability to receive as a function of news perceived veracity and evaluation confidence (Year 1)'};
        case 2, variable1 = supertemp_y2;   head = {'Desirability to receive as a function of news perceived veracity and evaluation confidence (Year 2)'};
    end
    bar(variable1(:,1), variable1(:,2));
    for I = 1:10                                       % connect upper and lower bound with a line
        line([I*10 I*10],[variable1(I,4) variable1(I,5)],'Color','red');
        line([-I*10 -I*10],[variable1(I+10,4) variable1(I+10,5)], 'Color','red');
        hold on;
    end
    title(head,'FontSize',20)
    xlabel('News evaluation','FontSize',20); ylabel('Receivers derisability','FontSize',20);
end





%% WTP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WTP TO RECEIVE/AVOID OF GROUPS BETWEEN TRUE NEWS AND FALSE NEWS

% WTP for each condition WITH STANDARD ERROR
Y = [mean(m_WTP_rec(:,1),'omitnan')  mean(m_WTP_avoid(:,1),'omitnan') ;
    mean(m_WTP_rec(:,2),'omitnan') mean(m_WTP_avoid(:,2),'omitnan') ;
    mean(m_WTP_rec(:,3),'omitnan') mean(m_WTP_avoid(:,3),'omitnan')
    mean(m_WTP_rec(:,4),'omitnan') mean(m_WTP_avoid(:,4),'omitnan')];
sd = [std(m_WTP_rec(:,1),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,1))))) std(m_WTP_avoid(:,1),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,1)))));
    std(m_WTP_rec(:,2),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,2))))) std(m_WTP_avoid(:,2),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,2))))) ;
    std(m_WTP_rec(:,3),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,3))))) std(m_WTP_avoid(:,3),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,3))))) ;
    std(m_WTP_rec(:,4),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,4))))) std(m_WTP_avoid(:,4),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,4)))))];
figure;
b1 = bar(Y); ylim([0 25]);  title('WTP to receive vs avoid more news','FontSize',20);
hold on;
nbars = size(Y, 2); x = [];
for i = 1:nbars,     x = [x ; b1(i).XEndPoints];
end
erp = errorbar(x', Y, sd, 'k','linestyle','none');
LA2 = legend('Reception','Avoidance'); LA2.Location ='best';
X = categorical({'No-theme','Ecology','Democracy','Social justice'});
set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
ylabel('Willingness-to-Pay','FontSize',20);

sd1 = [std(m_WTP_rec(:,1),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,1))))) std(m_WTP_rec(:,2),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,2))))) std(m_WTP_rec(:,3),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,3))))) std(m_WTP_rec(:,4),'omitnan')/sqrt(length(m_WTP_rec(~isnan(m_WTP_rec(:,4)))))];
xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
sd2 = [std(m_WTP_avoid(:,1),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,1))))) std(m_WTP_avoid(:,2),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,2))))) std(m_WTP_avoid(:,3),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,3))))) std(m_WTP_avoid(:,4),'omitnan')/sqrt(length(m_WTP_avoid(~isnan(m_WTP_avoid(:,4)))))];
xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YEARS COMPARISONS

% WTP for each condition for each year WITH STANDARD ERROR
figure
tiledlayout(1,2)
for jj = 1:2
    switch jj
        case 1,     var1 = m_WTP_rec_year1; var2 = m_WTP_avoid_year1; txt = 'WTP to receive vs avoid more news (Year 1)';
        case 2,     var1 = m_WTP_rec_year2; var2 = m_WTP_avoid_year2; txt = 'WTP to receive vs avoid more news (Year 2)';
    end
    nexttile
    Y = [mean(var1(:,1),'omitnan')  mean(var2(:,1),'omitnan') ;
        mean(var1(:,2),'omitnan') mean(var2(:,2),'omitnan') ;
        mean(var1(:,3),'omitnan') mean(var2(:,3),'omitnan')
        mean(var1(:,4),'omitnan') mean(var2(:,4),'omitnan')];
    sd = [std(var1(:,1),'omitnan')/sqrt(length(var1(~isnan(var1(:,1))))) std(var2(:,1),'omitnan')/sqrt(length(var2(~isnan(var2(:,1)))));
        std(var1(:,2),'omitnan')/sqrt(length(var1(~isnan(var1(:,2))))) std(var2(:,2),'omitnan')/sqrt(length(var2(~isnan(var2(:,2))))) ;
        std(var1(:,3),'omitnan')/sqrt(length(var1(~isnan(var1(:,3))))) std(var2(:,3),'omitnan')/sqrt(length(var2(~isnan(var2(:,3))))) ;
        std(var1(:,4),'omitnan')/sqrt(length(var1(~isnan(var1(:,4))))) std(var2(:,4),'omitnan')/sqrt(length(var2(~isnan(var2(:,4)))))];
    b1 = bar(Y); ylim([0 25]);  title(txt,'FontSize',20); hold on;
    nbars = size(Y, 2); x = [];
    for i = 1:nbars,     x = [x ; b1(i).XEndPoints];
    end
    erp = errorbar(x', Y, sd, 'k','linestyle','none');
    LA2 = legend('Reception','Avoidance'); LA2.Location ='best';
    X = categorical({'No-theme','Ecology','Democracy','Social justice'});
    set(gca, 'XTickLabel',X, 'XTick',1:numel(X),'FontSize',20);
    ylabel('Willingness-to-Pay','FontSize',20);
    
    sd1 = [std(var1(:,1),'omitnan')/sqrt(length(var1(~isnan(var1(:,1))))) std(var1(:,2),'omitnan')/sqrt(length(var1(~isnan(var1(:,2))))) std(var1(:,3),'omitnan')/sqrt(length(var1(~isnan(var1(:,3))))) std(var1(:,4),'omitnan')/sqrt(length(var1(~isnan(var1(:,4)))))];
    xtips1 = b1(1).XEndPoints; ytips1 = b1(1).YEndPoints; labels1 = arrayfun(@num2str, round(b1(1).YData,2), 'Uniform', false);
    text(xtips1,ytips1+sd1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
    
    sd2 = [std(var2(:,1),'omitnan')/sqrt(length(var2(~isnan(var2(:,1))))) std(var2(:,2),'omitnan')/sqrt(length(var2(~isnan(var2(:,2))))) std(var2(:,3),'omitnan')/sqrt(length(var2(~isnan(var2(:,3))))) std(var2(:,4),'omitnan')/sqrt(length(var2(~isnan(var2(:,4)))))];
    xtips2 = b1(2).XEndPoints; ytips2 = b1(2).YEndPoints; labels2 = arrayfun(@num2str, round(b1(2).YData,2), 'Uniform', false);
    text(xtips2,ytips2+sd2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',17);
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WTP FOR NEWS PERCEIVED AS TRUE OR FALSE

figure;     clear temp tmp temp2 tmp2
t = tiledlayout(1,2);
legend('News perceived as true','News perceived as false','FontSize',25, 'Location', 'southoutside');
for jj = 1:2
    switch jj
        case 1,     var = 1; txt = 'WTP to receive more news';
        case 2,     var = 2; txt = 'WTP to avoid receiving more news';
    end
    nexttile
    temp1 = plots_data(plots_data.eval > 0 & plots_data.rec ==var,:); temp2 = plots_data(plots_data.eval < 0 & plots_data.rec ==var,:);
    x2=fitdist(temp2.WTP,'normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf'); temp=-(h2.Values); %#ok<*NBRAK>
    legend([h2], {'test'});
    x1=fitdist(temp1.WTP,'normal'); x1_pdf = [1:1:25]; y1 =   pdf(x1,x1_pdf);  h1 = histogram(temp1.WTP, 'Normalization', 'pdf'); line(x1_pdf,y1, 'HandleVisibility','off');
    hold on; b=bar([0:25], temp); line(x2_pdf,y2, 'HandleVisibility','off'); b.BarWidth=1;
    set(gca,'YLim',[-0.3 0.3])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)
    title(txt,'FontSize',30);
    xlabel('Willingness-to-pay','FontSize',30); ylabel('Probability density','FontSize',30);
end
lg = legend('News judged as true','News judged as false','FontSize',25, 'Orientation', 'horizontal');
lg.Layout.Tile = 'South';


% figure;     
% tiledlayout(1,2)
% for jj = 1:2
%     clear temp1 tmp1 temp2 tmp2 temp
%     switch jj
%         case 1,     var = 1; txt = 'Average WTP to receive more news';
%         case 2,     var = 2; txt = 'Average WTP to avoid receiving more news';
%     end
%     for ii = 1:nbs
%         tmp1 = table2array(plots_data(plots_data.eval > 0 & plots_data.rec ==var & plots_data.subject ==ii,12))';        temp1(ii,1) = mean(tmp1); temp1 = rmmissing(temp1);
%         tmp2 = table2array(plots_data(plots_data.eval < 0 & plots_data.rec ==var & plots_data.subject ==ii,12))';        temp2(ii,1) = mean(tmp2); temp2 = rmmissing(temp2);
%     end
%     nexttile
%     x2=fitdist(temp2(:,1),'normal'); x2_pdf = [0.5:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2(:,1), 25,'Normalization', 'pdf'); temp=-(h2.Values); %#ok<*NBRAK>
%     legend([h2], {'test'});
%     x1=fitdist(temp1(:,1),'normal'); x1_pdf = [0.5:1:25]; y1 =   pdf(x1,x1_pdf);  h1 = histogram(temp1(:,1), 25,'Normalization', 'pdf'); line(x1_pdf,y1, 'HandleVisibility','off');
%     hold on; b=bar([0.5:25], temp); line(x2_pdf,y2, 'HandleVisibility','off'); b.BarWidth=1;
%     legend('News perceived as true','News perceived as false');
%     title(txt,'FontSize',20);
%     xlabel('Willingness-to-pay','FontSize',20); ylabel('Average Probability','FontSize',20);
% end




% WTP FOR NEWS DESIRED/UNDESIRED
clear temp tmp temp2 tmp2
temp1 = plots_data(plots_data{:,10}==1,:); temp2 = plots_data(plots_data{:,10}==2,:);
figure
x2=fitdist(temp2.WTP,'Normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf'); temp=-(h2.Values);
x1=fitdist(temp1.WTP,'Normal'); x1_pdf = [1:1:25]; y1 = pdf(x1,x1_pdf); h1 = histogram(temp1.WTP, 'Normalization', 'pdf'); line(x1_pdf,y1);
hold on; b=bar([0:25], temp); line(x2_pdf,y2); b.BarWidth=1;
title('Probability density function of WTP for reiceiving vs avoiding more news','FontSize',20);
xlabel('Willingness-to-pay','FontSize',20); ylabel('Probability','FontSize',20);
set(gca,'YLim',[-0.3 0.3])