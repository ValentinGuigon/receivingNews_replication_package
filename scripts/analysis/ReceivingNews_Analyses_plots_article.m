clear
clc
close all


%% VARIABLES

project_root = strrep(pwd(), '\', '/');
addpath(genpath(strcat(project_root,'/matlab_toolboxes/MATLAB Tools')))
load(strcat(project_root, '/data/processed/ReceivingNews_tables'))

plots_data = allSubAllTrial;
plots_data.eval(plots_data.judgment == 0) = - plots_data.eval(plots_data.judgment == 0);


%% Install MATLAB Tools
% Clone repository from git@github.com/ValentinGuigon/MATLAB_Tools
% Then add the path to the MATLAB tools

proj = matlab.project.rootProject;
rootFolder = proj.RootFolder;
addpath(genpath(strcat(rootFolder, '/matlab_toolboxes/plotting')))


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

color_false = [0.9725, 0.4627, 0.4275];
color_true = [0, 0.7490, 0.7686];
color_judgment_true = [0, 0.4470, 0.7410];
color_judgment_false = [0.6350 0.0780 0.1840];
color_reception = [0.0196, 0.7098, 0.9176];
color_no_reception = [0.9882, 0.5137, 0];




%% SUCCESS RATES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2-LEVELS COMPARISONS: THEME * VERACITY, WITHIN EACH GROUPS & REGARDLESS OF GROUPS
% Plot Share of correct judgments for True vs False for each theme
% list: Ecol False, Ecol True, Demo False, Demo True, Just False, Just True

h = figure; 
h.Position = [100 100 900*outer_position_factor 700*outer_position_factor];
T = tiledlayout(2,3,'TileSpacing','compact'); % Outer layout
taille=16;
set(h, 'DefaultTextFontSize', taille); set(T, 'DefaultTextFontSize', taille);

subtitles = {'Ecology', '', 'Democracy', '', 'Social justice'};
m=1;
for ii = [1 3 5]
    t=tiledlayout(T,1,1); % Inner layout
    t.Layout.Tile = m;
    t.Layout.TileSpan = [1 1];
    
    [p h] = ranksum(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100, Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100);
    ax(m)=nexttile(t);
    
    x1=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100,'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
    h1=histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii)*100,8,'Normalization', 'pdf','facealpha', 1, 'FaceColor', color_false);
    hold on
    x2=fitdist(Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100,'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
    h2=histogram(Rec_allSub.allSubMeanTrial(3).output(:,ii+1)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', color_true);
    hold off
    
    subtitle(subtitles(ii), 'FontSize', taille); 
    xticks(0:50:100); xticklabels([0:0.5:1]);
    axis([0 100 0 0.035])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0035, p);
    
    if ii==1
        ylabel('Probability density','FontSize',taille);
    end
    if ii == 3
        ttl=title('Proportion of correct judgments', 'FontSize', taille);
    end
    m=m+1;
end

for ii = [1 3 5]
    t=tiledlayout(T,1,1); % Inner layout
    t.Layout.Tile = m;
    t.Layout.TileSpan = [1 1];
    
    [p h] = ranksum(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100, Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100);
    ax(m)=nexttile(t);
    x1=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100,'Normal'); x1_pdf = [0:0.1:1]; y1 = pdf(x1,x1_pdf);
    h1=histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii)*100,8,'Normalization', 'pdf','facealpha', 1, 'FaceColor', color_false);
    hold on
    x2=fitdist(Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100,'Normal'); x2_pdf = [0:0.1:1]; y2 =pdf(x2,x2_pdf);
    h2=histogram(Rec_allSub.allSubMeanTrial(8).output(:,ii+1)*100,8,'Normalization', 'pdf','facealpha', .5, 'FaceColor', color_true);
    hold off

    subtitle(subtitles(ii), 'FontSize', taille);    
    xticks(0:50:100); xticklabels([0:0.5:1]);
    axis([0 100 0 0.035])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontSize',taille)
    mysigstar(gca, [25 75], max(max(h1.Values), max(h2.Values))+0.0035, p);
    
    if ii==1
        ylabel('Probability density','FontSize',taille);
    end
    if ii == 3
        ttl=title('Proportion of news reported as being true', 'FontSize', taille);
    end
    m=m+1;
end
lg = legend(ax(2),'False','True', 'Orientation', 'horizontal', 'location','northoutside');
lg.Title.String = 'Veracity';
set(lg,'Box','off')


saveas(gcf,strcat(project_root,'/outputs/figures/Matlab/Success_perTruthfulness_perTheme.png'))
saveas(gcf,strcat(project_root,'/outputs/figures/Matlab/Success_perTruthfulness_perTheme.tif'))





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
line(x1_level,f1,'Color',color_true, 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_true); 
line(x2_level,f2,'Color',color_false', 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_false); 
lg = legend([p1 p2], 'True news', 'False news', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min([x1_level x2_level]) max([x1_level x2_level])])
% title('Frequency of correct truthfulness estimations');
xlabel('Imprecision'); ylabel('Correct judgments');
set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);

saveas(gcf,strcat(project_root,'/outputs/figures/Matlab/Success_perTruthfulness_predImprecision.png'))
saveas(gcf,strcat(project_root,'/outputs/figures/Matlab/Success_perTruthfulness_predImprecision.tif'))







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
line(x1_level,f1,'Color',color_true, 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_true); 
line(x2_level,f2,'Color',color_false, 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_false); 
lg = legend([p1 p2], 'True news', 'False news', 'Orientation', 'horizontal');
lg.Layout.Tile = 'North';
set(lg,'Box','off')
set(gca,'linewidth',1)
ylim([0 1])
yticks([0:0.2:1])
xlim([min([x1_level x2_level]) max([x1_level x2_level])])
% title('Frequency of judgments as true');
xlabel('Imprecision'); ylabel('Judgments as true');
set(gca,'Unit','normalized','Position',[0.15 0.25 0.82 0.72]);

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Judgment_perTruthfulness_predImprecision.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Judgment_perTruthfulness_predImprecision.tif'))








%% CONFIDENCE-ACCURACY CALIBRATION PREPARATION

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
        judgment = table2array(allSubAllTrial(allSubAllTrial{:,1} == sub, 8));
        scores = ((proba/100) - outcome).^2; % + (1-(proba/100) - notoutcome).^2;
        Brier.subjects(sub).BrierTable = [proba outcome scores theme veracity idnews ambiguity judgment];
    end
end

% Confidence-accuracy calibration: judgments as true vs judgments as false
for sub = 1:nbs
    for acc = 1:10 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy_10_F(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_T(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,5) == 1,2)));
    end
end

% Confidence-accuracy calibration: judgments as true vs judgments as false
for sub = 1:nbs
    for acc = 1:10 % Accuracy for each 20% bin
        temp=Brier.subjects(sub).BrierTable;
        Brier.subjects(sub).Bins_accuracy_10_JF(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,8) == 0,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,8) == 0,2)));
        
        Brier.subjects(sub).Bins_accuracy_10_JT(1,acc) = array2table(sum(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,8) == 1,2))... 
            / length(temp(temp(:,1)>(0+10*(acc-1)) & temp(:,1)<(10*acc)+1 & temp(:,8) == 1,2)));
    end
end

clear temp
m=1; tbl=zeros; percent = struct('percent10',tbl,'percent20',tbl,'percent30',tbl,'percent40',tbl,'percent50',tbl,'percent60',tbl,'percent70',tbl,'percent80',tbl,'percent90',tbl,'percent100',tbl);
fields = fieldnames(percent);
percentF = percent; percentT = percent;
percentJF = percent; percentJT = percent;

for ii = 1:nbs
    tempF = table2array(Brier.subjects(ii).Bins_accuracy_10_F);
    tempT = table2array(Brier.subjects(ii).Bins_accuracy_10_T);
    
    for jj = 1:10
        percentF.(fields{jj})(ii,1) = tempF(1,jj);
        percentT.(fields{jj})(ii,1) = tempT(1,jj);
    end
end
for jj = 1:10
    tableF(:,jj) = percentF.(fields{jj})(:,1);
    tableT(:,jj) = percentT.(fields{jj})(:,1);
end

for ii = 1:nbs
    tempJF = table2array(Brier.subjects(ii).Bins_accuracy_10_JF);
    tempJT = table2array(Brier.subjects(ii).Bins_accuracy_10_JT);
    
    for jj = 1:10
        percentJF.(fields{jj})(ii,1) = tempJF(1,jj);
        percentJT.(fields{jj})(ii,1) = tempJT(1,jj);
    end
end
for jj = 1:10
    tableJF(:,jj) = percentJF.(fields{jj})(:,1);
    tableJT(:,jj) = percentJT.(fields{jj})(:,1);
end



%% CONFIDENCE-ACCURACY CALIBRATION TABLE FOR BOTH NEWS JUDGMENTS
    
% Figure setup
h = figure;
outer_position_factor = 1; % Define the factor if not already defined
h.Position = [100, 100, 900 * outer_position_factor, 350 * 1.5 * outer_position_factor];
t = tiledlayout(1, 1, 'TileSpacing', 'compact', 'Padding', 'none'); % Removed padding to fit within window

% Data
x = [0 100]; y = [0 1]; x1 = 5:10:100; x1bis = [5 95]; y1bis = [0.05 1];
yu = y1bis + 0.05; yd = y1bis - 0.05;
yy = [0.5 0.5]; yyy = [0.45 0.45]; yyyy = [0.55 0.55];
xticks2 = {'1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100'};

% Plotting
nexttile
hold on
fill([x1bis fliplr(x1bis)], [yu fliplr(yd)], [0.95 0.95 0.95], 'linestyle', 'none');
l1 = line(x1bis, y1bis, 'Color', 'black', 'LineWidth', 1.5);
line([0 100], [0 0], 'Color', 'black', 'LineWidth', 1.5);
l2 = line(x, yy, 'Color', [0.7 0.7 0.7], 'LineStyle', ':', 'LineWidth', 1.5);
line(x, yyy, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 1.5);
line(x, yyyy, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 1.5);

% Plot data with patches and error bars
a1_y = mean(tableJT, 'omitnan');
a2_y = mean(tableJF, 'omitnan');
patch([x1 fliplr(x1)], [a1_y(1,1:10) - std(tableJT,'omitnan') ./ sqrt(length(~isnan(tableJT))) ...
        fliplr(a1_y(1,1:10) + std(tableJT,'omitnan') ./ sqrt(length(~isnan(tableJT))))], color_judgment_true, 'FaceAlpha', 0.3);
p1 = plot(x1, a1_y(1,1:10), 'Color', color_judgment_true, 'LineWidth', 2);

patch([x1 fliplr(x1)], [a2_y(1,1:10) - std(tableJF,'omitnan') ./ sqrt(length(~isnan(tableJF))) ...
        fliplr(a2_y(1,1:10) + std(tableJF,'omitnan') ./ sqrt(length(~isnan(tableJF))))], color_judgment_false, 'FaceAlpha', 0.3);
p2 = plot(x1, a2_y(1,1:10), 'Color', color_judgment_false, 'LineWidth', 2);

errorbar(x1, mean(tableJT,'omitnan'), std(tableJT,'omitnan') / sqrt(length(~isnan(tableJT))), 'Color', color_judgment_true);
errorbar(x1, mean(tableJF,'omitnan'), std(tableJF,'omitnan') / sqrt(length(~isnan(tableJF))), 'Color', color_judgment_false);

% Axis settings
xticks(5:10:100);
xticklabels(xticks2);
xlabel('Confidence', 'FontSize', taille, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel('Proportion correct (mean + SE)', 'FontSize', taille, 'FontWeight', 'bold', 'FontName', 'Arial');
title(t, 'Confidence-accuracy calibration', 'FontSize', taille);

% Legends
leg1 = legend([p2, p1], 'False', 'True', 'Location', 'NorthWest', 'Orientation', 'horizontal', 'FontSize', taille);
leg1.Title.String = 'Judgment';
set(leg1, 'EdgeColor', 'none');
ah1 = axes('Position', get(gca, 'Position'), 'Visible', 'off');
leg2 = legend(ah1, [l1, l2], 'Well-calibrated', 'Non-calibrated', 'Location', 'NorthEast', 'Orientation', 'horizontal', 'FontSize', taille);
leg2.Title.String = 'Calibration';
set(leg2, 'EdgeColor', 'none');

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Metacognition_calibration.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Metacognition_calibration.tif'))





%% CONFIDENCE-ACCURACY CALIBRATION TABLE FOR BOTH NEWS TRUTHFULNESS

% Figure setup
h = figure;
outer_position_factor = 1; % Define if not already set
h.Position = [100, 100, 900 * outer_position_factor, 350 * 1.5 * outer_position_factor];
t = tiledlayout(1, 1, 'TileSpacing', 'compact', 'Padding', 'none');

% Data
x = [0 100]; y = [0 1]; x1 = 5:10:100; x1bis = [5 95]; y1bis = [0.05 1];
yu = y1bis + 0.05; yd = y1bis - 0.05;
yy = [0.5 0.5]; yyy = [0.45 0.45]; yyyy = [0.55 0.55];
xticks2 = {'1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-90', '91-100'};

% Plotting
nexttile
hold on
fill([x1bis fliplr(x1bis)], [yu fliplr(yd)], [0.95 0.95 0.95], 'linestyle', 'none');
l1 = line(x1bis, y1bis, 'Color', 'black', 'LineWidth', 1.5); % Well-calibrated interval
line([0 100], [0 0], 'Color', 'black', 'LineWidth', 1.5);
l2 = line(x, yy, 'Color', [0.7 0.7 0.7], 'LineStyle', ':', 'LineWidth', 1.5); % Non-calibrated interval
line(x, yyy, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 1.5);
line(x, yyyy, 'Color', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 1.5);

% Plot data with patches and error bars
a1_y = mean(tableT, 'omitnan');
a2_y = mean(tableF, 'omitnan');
patch([x1 fliplr(x1)], [a1_y(1, 1:10) - std(tableT, 'omitnan') ./ sqrt(length(~isnan(tableT))), ...
      fliplr(a1_y(1, 1:10) + std(tableT, 'omitnan') ./ sqrt(length(~isnan(tableT))))], color_true, 'FaceAlpha', 0.3);
p1 = plot(x1, a1_y(1, 1:10), 'Color', color_true, 'LineWidth', 2); % True
patch([x1 fliplr(x1)], [a2_y(1, 1:10) - std(tableF, 'omitnan') ./ sqrt(length(~isnan(tableF))), ...
      fliplr(a2_y(1, 1:10) + std(tableF, 'omitnan') ./ sqrt(length(~isnan(tableF))))], color_false, 'FaceAlpha', 0.3);
p2 = plot(x1, a2_y(1, 1:10), 'Color', color_false, 'LineWidth', 2); % False

errorbar(x1, mean(tableT, 'omitnan'), std(tableT, 'omitnan') / sqrt(length(~isnan(tableT))), 'Color', color_true);
errorbar(x1, mean(tableF, 'omitnan'), std(tableF, 'omitnan') / sqrt(length(~isnan(tableF))), 'Color', color_false);

% Axis settings
xticks(5:10:100);
xticklabels(xticks2);
xlabel('Confidence', 'FontSize', taille, 'FontWeight', 'bold', 'FontName', 'Arial');
ylabel('Proportion correct (mean + SE)', 'FontSize', taille, 'FontWeight', 'bold', 'FontName', 'Arial');
title(t, 'Confidence-accuracy calibration', 'FontSize', taille);

% Legends
leg1 = legend([p2, p1], 'False', 'True', 'Location', 'NorthWest', 'Orientation', 'horizontal', 'FontSize', taille);
leg1.Title.String = 'Veracity';
set(leg1, 'EdgeColor', 'none');
ah1 = axes('Position', get(gca, 'Position'), 'Visible', 'off');
leg2 = legend(ah1, [l1, l2], 'Well-calibrated', 'Non-calibrated', 'Location', 'NorthEast', 'Orientation', 'horizontal', 'FontSize', taille);
leg2.Title.String = 'Calibration';
set(leg2, 'EdgeColor', 'none');

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Metacognition_calibration_perTruthfulness.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Metacognition_calibration_perTruthfulness.tif'))


 







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




x1=supertemp(1:10,1); y1=supertemp(1:10,2);
x2=supertemp(1:10,1); y2=supertemp(11:20,2);

figure
p1 = polyfit(x1,y1,1); f1 = polyval(p1,x1);
p2 = polyfit(x2,y2,1); f2 = polyval(p2,x2);
hold on;

line(x1,f1,'Color',color_judgment_true, 'LineWidth', 1.5);
p1 = plot(x1, y1, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_judgment_true); 
line(x2,f2,'Color',color_judgment_false, 'LineWidth', 1.5);
p2 = plot(x2, y2, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', 'diamond', 'Color', color_judgment_false); 

line([10 100],[0.5 0.5], 'Color',[0.7 0.7 0.7],'LineStyle','--');
for ii = 1:10
    line([x1(ii) x1(ii)], [supertemp(ii,4) supertemp(ii,5)], 'Color', color_judgment_true, 'LineWidth', 1);
    line([x2(ii) x2(ii)], [supertemp(ii+10,4) supertemp(ii+10,5)], 'Color', color_judgment_false, 'LineWidth', 1);
end

ylim([0.25 0.75])
xlim([10 100])
%xticklabels({'', '11-20', '', '31-40', '', '51-60', '', '71-80', '', '91-100'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',16)
legend([p1 p2], 'News judged as true', 'News judged as false')
title('Average probability to receive more news');
xlabel('Confidence degree'); ylabel('Reception probability + CI');
xticklabels({'11-20', '31-40', '51-60', '71-80', '91-100'});

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Reception_perTruthfulness_predConfidence.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Reception_perTruthfulness_predConfidence.tif'))





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
line(x1_level,f1,'Color',color_judgment_true, 'LineWidth', 1.5);
p1 = plot(x1_level, x1_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', '.', 'Color', color_judgment_true); 
line(x2_level,f2,'Color',color_judgment_false, 'LineWidth', 1.5);
p2 = plot(x2_level, x2_sum, 'LineWidth',1.5,'MarkerSize',10,'LineStyle','none', 'Marker', '.', 'Color', color_judgment_false); 
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

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Reception_perTruthfulness_predConfidence2.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/Reception_perTruthfulness_predConfidence2.tif'))











%% WTP

% WTP FOR NEWS DESIRED/UNDESIRED
clear temp tmp temp2 tmp2
temp1 = plots_data(plots_data{:,10}==1,:); temp2 = plots_data(plots_data{:,10}==0,:);
h = figure;
t = tiledlayout(1,1);
nexttile
x2=fitdist(temp2.WTP,'Normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf', 'FaceColor', color_no_reception); temp=-(h2.Values);
x1=fitdist(temp1.WTP,'Normal'); x1_pdf = [1:1:25]; y1 = pdf(x1,x1_pdf); h1 = histogram(temp1.WTP, 'Normalization', 'pdf', 'FaceColor', color_reception);
hold on; b=bar([0:25], temp,'FaceColor', color_no_reception); b.BarWidth=1;
%title('WTP to receive vs not to receive additional news', 'FontWeight','Normal');
xlabel('Willingness-to-pay'); ylabel('Probability density');
lg = legend('Reception','No reception','Orientation', 'horizontal','location','North');
set(gca,'YLim',[-0.3 0.3])
set(gca,'linewidth',1)
set(gca, 'box', 'off')
set(lg,'Box','off')
yticks(-0.3:0.1:0.3)

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/WTP_perReception.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/WTP_perReception.tif'))





clear temp tmp temp2 tmp2

h = figure; 
h.Position = [100 100 550 350];
T = tiledlayout(2,3,'TileSpacing','compact'); % Outer layout
taille=20;
set(h, 'DefaultTextFontSize', taille); set(T, 'DefaultTextFontSize', taille);

t = tiledlayout(1,2);
for jj = 1:2
    switch jj   
        case 1,     var = 1; txt = 'WTP to receive';
        case 2,     var = 0; txt = 'WTP not to receive';
    end
    nexttile
    temp1 = plots_data(plots_data.eval > 0 & plots_data.rec ==var,:); temp2 = plots_data(plots_data.eval < 0 & plots_data.rec ==var,:);
    x2=fitdist(temp2.WTP,'normal'); x2_pdf = [1:1:25]; y2 = -(pdf(x2,x2_pdf)); h2 = histogram(temp2.WTP, 'Normalization', 'pdf'); temp=-(h2.Values); %#ok<*NBRAK>
    legend([h2], {'test'});
    x1=fitdist(temp1.WTP,'normal'); x1_pdf = [1:1:25]; y1 =   pdf(x1,x1_pdf);  h1 = histogram(temp1.WTP, 'Normalization', 'pdf');
    hold on; b=bar([0:25], temp); b.BarWidth=1;
    set(gca,'YLim',[-0.3 0.3])
    xticks(0:5:25)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a)
    title(txt);
    set(gca, 'box', 'off')
end
lg = legend('News judged as true','News judged as false', 'Orientation', 'horizontal');
set(lg,'Box','off')
lg.Layout.Tile = 'North';
ylabel(t,'Probability density', 'FontSize', taille)

saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/WTP_perReception_perTruthfulness.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/WTP_perReception_perTruthfulness.tif'))


%% Compute judgment as true, success and information seeking when participants are close either to organizations pro {theme} or against, for each themes

orgs_pro = [1 2 5 6 9 10];
orgs_con = [3 4 7 8 11 12];
theme_names = ["socjust", "ecology", "democracy"];
pooled = ["pooled"];

orgs = string(allSubAllTrial.Properties.VariableNames(17:28));
variables_of_organizations = string(Receivingnews2(1).organizations.Properties.VariableNames(5:11));
% "Q1_familiarity_self", "Q2_valuecloseness_self", "Q3_likeness_self", 
% "Q4_familiarity_relatives", "Q5_valuecloseness_relatives", "Q6_likeness_relatives", "social_dist"

% Choose Q the proxy for participants' beliefs
Q = 7;
variable_of_interest = variables_of_organizations(Q);
if Q < 7 % if we compute beliefs based on single questions
    threshold_single_measure = 5; threshold_base = 10;
    threshold = threshold_single_measure; var = 'closeness of values';
elseif Q == 7 % elseif we compute beliefs based on aggregated measure
    threshold_aggregated_measure = 59; threshold_base = 100;
    threshold = threshold_aggregated_measure; var = 'social closeness';
end


for sub = unique(plots_data.subject)'
    if sub < 80
        id = sub; org_data = Receivingnews2(id).organizations; 
    else
        id = sub-79; org_data = Receivingnews3(id).organizations; 
    end

    for orga = orgs
        plots_data.(orga)(plots_data.subject == sub) = repmat(...
            org_data.(variable_of_interest)(regexprep(org_data.organization,'-',' ') == regexprep(orga,'_',' '))...
            , 1, length(plots_data.(orga)(plots_data.subject == sub)))';
    end
end


judgment_per_dist = struct('pro', struct('socjust',0,'democracy',0,'ecology',0), 'con', struct('socjust',0,'democracy',0,'ecology',0));
success_per_dist = judgment_per_dist;
seeking_per_dist = judgment_per_dist;
WTP_receive_per_dist = judgment_per_dist;
WTP_avoid_per_dist = judgment_per_dist;

for valence = ["pro", "con"]
    for theme = unique(plots_data.theme)'
        switch theme
            case 1, base = 17;
            case 2, base = 21;
            case 3, base = 25;
        end

        data_filtered_pro = plots_data( (plots_data{:,base} + plots_data{:,base+1})/2 > threshold,:);
        data_filtered_con = plots_data( (plots_data{:,base+2} + plots_data{:,base+3})/2 > threshold,:);

        switch true
            case strcmp(valence, 'pro')==1, data_filtered = data_filtered_pro;
            case strcmp(valence, 'con')==1, data_filtered = data_filtered_con;
        end

        sub_sub=1;
        for sub = unique(data_filtered.subject)'
            data = data_filtered(data_filtered.subject == sub,:);

            judgment_per_dist.(valence).(theme_names(theme))(sub_sub) = sum(data.judgment(data.theme == theme)) / length(data.judgment(data.theme == theme))';
            success_per_dist.(valence).(theme_names(theme))(sub_sub) = sum(data.success(data.theme == theme)) / length(data.success(data.theme == theme))';
            seeking_per_dist.(valence).(theme_names(theme))(sub_sub) = sum(data.rec(data.theme == theme)) / length(data.rec(data.theme == theme))';
            WTP_receive_per_dist.(valence).(theme_names(theme))(sub_sub) = mean(data.WTP(data.theme == theme & data.rec == 1));
            WTP_avoid_per_dist.(valence).(theme_names(theme))(sub_sub) = mean(data.WTP(data.theme == theme & data.rec == 0));
            sub_sub=sub_sub+1;
        end
    end
end


for valence = ["pro", "con"]
    judgment_per_dist.(valence).(pooled) = ...
        [judgment_per_dist.(valence).socjust...
        judgment_per_dist.(valence).democracy...
        judgment_per_dist.(valence).ecology]';
    
    success_per_dist.(valence).(pooled) = ...
        [success_per_dist.(valence).socjust...
        success_per_dist.(valence).democracy...
        success_per_dist.(valence).ecology]';
    
    seeking_per_dist.(valence).(pooled) = ...
        [seeking_per_dist.(valence).socjust...
        seeking_per_dist.(valence).democracy...
        seeking_per_dist.(valence).ecology]';
    
    WTP_receive_per_dist.(valence).(pooled) = ...
        [WTP_receive_per_dist.(valence).socjust...
        WTP_receive_per_dist.(valence).democracy...
        WTP_receive_per_dist.(valence).ecology]';
    
    WTP_avoid_per_dist.(valence).(pooled) = ...
        [WTP_avoid_per_dist.(valence).socjust...
        WTP_avoid_per_dist.(valence).democracy...
        WTP_avoid_per_dist.(valence).ecology]';
end


%% BELIEFS

data_per_dist = struct("judgment_per_dist", judgment_per_dist, "success_per_dist", success_per_dist, "seeking_per_dist", ...
    seeking_per_dist, "WTP_receive_per_dist", WTP_receive_per_dist, "WTP_avoid_per_dist", WTP_avoid_per_dist);
variable_names = ["Judgments", "Success", "Reception", "WTP to receive", "WTP not to receive"]; 
variables = ["judgment_per_dist", "success_per_dist", "seeking_per_dist", "WTP_receive_per_dist", "WTP_avoid_per_dist"];


for j = 1:3
    h = figure; 
    T = tiledlayout(1,1,'TileSpacing','compact');
    taille = 16; 
    set(h, 'DefaultTextFontSize', taille); 
    set(T, 'DefaultTextFontSize', taille);
    ylabel(T, 'Proportion (%)', 'FontSize', taille); 
    x = categorical(theme_names);
    
    data = data_per_dist.(variables(j));
    data = struct('pro_ecology', data.pro.ecology, 'pro_democracy', data.pro.democracy, 'pro_socjust', data.pro.socjust, ...
    'con_ecology', data.con.ecology, 'con_democracy', data.con.democracy, 'con_socjust', data.con.socjust);
    fields = fieldnames(data);
    
    nexttile; 
    hold on;
    ylim([0 1]);
    line([0.5 2.5], [0.5 0.5], 'Color', [.7 .7 .7], 'LineStyle', '--')
    
    y = [mean(data.pro_ecology(:),'omitnan') mean(data.pro_democracy(:),'omitnan') mean(data.pro_socjust(:),'omitnan');
         mean(data.con_ecology(:),'omitnan') mean(data.con_democracy(:),'omitnan') mean(data.con_socjust(:),'omitnan')];
     
    errors = [std(data.pro_ecology(:),'omitnan') / sqrt(numel(data.pro_ecology(:))) ...
                  std(data.pro_democracy(:),'omitnan') / sqrt(numel(data.pro_democracy(:))) ...
                  std(data.pro_socjust(:),'omitnan') / sqrt(numel(data.pro_socjust(:)));
                  std(data.con_ecology(:),'omitnan') / sqrt(numel(data.con_ecology(:))) ...
                  std(data.con_democracy(:),'omitnan') / sqrt(numel(data.con_democracy(:))) ...
                  std(data.con_socjust(:),'omitnan') / sqrt(numel(data.con_socjust(:)))];
    
    b = bar(y, 'grouped');
    [ngroups, nbars] = size(y);
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i, :) = b(i).XEndPoints;
    end
    
    jitter_amount = 0.01;
    for k = 1:nbars*ngroups
        data_values = data.(string(fields{k}));
        jittered_x = x(k) + jitter_amount * randn(size(data_values));
        scatter(jittered_x, data_values, 10, 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.5);
    end
    
    errorbar(x', y, errors, 'k', 'LineStyle', 'none', 'LineWidth', 0.9);
    
    title(variable_names(j)); 
    xticks([1 2]); 
    set(gca, 'xticklabel', {'Alignment'; 'Misalignment'});
    xtickangle(15);
    lg = legend(b, {'Ecology', 'Democracy', 'Social justice'}, 'Orientation', 'horizontal', 'Location', 'northoutside');
    set(lg, 'Box', 'off');
    
    saveas(gcf, strcat(project_root, '/outputs/figures/Matlab/', variables(j), 'per_theme.png'))
    saveas(gcf, strcat(project_root, '/outputs/figures/Matlab/', variables(j), 'per_theme.tif'))
end


for j = 1:3
    h = figure; 
    T = tiledlayout(1,1,'TileSpacing','compact');
    taille = 16; 
    set(h, 'DefaultTextFontSize', taille); 
    set(T, 'DefaultTextFontSize', taille);
    ylabel(T,'Proportion (%)','FontSize',taille); 
    x = categorical(theme_names);
    
    nexttile; 
    hold on;
    
    if j < 4
        ylim([0.3 0.71]); 
        line([0 3], [0.5 0.5], 'Color',[.7 .7 .7],'LineStyle','--')
    else
        ylim([0 10]); 
        line([0 3], [5 5], 'Color',[.7 .7 .7],'LineStyle','--')
    end
    
    pro_data = data_per_dist.(variables(j)).pro.pooled(:);
    con_data = data_per_dist.(variables(j)).con.pooled(:);
    
    y = [mean(pro_data, 'omitnan'); mean(con_data, 'omitnan')];
    errors = [std(pro_data, 'omitnan') / sqrt(numel(pro_data)); 
              std(con_data, 'omitnan') / sqrt(numel(con_data))];
    
    b = bar(y);
    errorbar(1:2, y, errors, 'k', 'LineStyle', 'none', 'LineWidth', 0.9);
    
    jitter_amount = 0.05;
    scatter(1 + jitter_amount * randn(size(pro_data)), pro_data, 10, 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.5);
    scatter(2 + jitter_amount * randn(size(con_data)), con_data, 10, 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerFaceAlpha', 0.5);
    
    title(variable_names(j)); 
    xticks([1 2]); 
    set(gca,'xticklabel',{'Alignment'; 'Misalignment'}); 
    xtickangle(15);
    
    saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/', variables(j), '.png'));
    saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/', variables(j), '.tif'));
end



h = figure; T = tiledlayout(1,2,'TileSpacing','compact');
taille=16; set(h, 'DefaultTextFontSize', taille); set(T, 'DefaultTextFontSize', taille);
ylabel(T,'Willingness-To-Pay (ECU)','FontSize',taille); x = categorical(theme_names);
for j = 4:5
    ax = nexttile; 
    hold on;
    
    ylim([0 15]); 
    xlim([0.5 2.5]); 
    line([0.5 2.5], [5 5], 'Color',[.7 .7 .7],'LineStyle','--', 'HandleVisibility','off');
    
    pro_ecology = data_per_dist.(variables(j)).pro.ecology(:);
    pro_democracy = data_per_dist.(variables(j)).pro.democracy(:);
    pro_socjust = data_per_dist.(variables(j)).pro.socjust(:);
    
    con_ecology = data_per_dist.(variables(j)).con.ecology(:);
    con_democracy = data_per_dist.(variables(j)).con.democracy(:);
    con_socjust = data_per_dist.(variables(j)).con.socjust(:);
    
    y = [mean(pro_ecology, 'omitnan') mean(pro_democracy, 'omitnan') mean(pro_socjust, 'omitnan');
         mean(con_ecology, 'omitnan') mean(con_democracy, 'omitnan') mean(con_socjust, 'omitnan')];
    errors = [std(pro_ecology, 'omitnan') / sqrt(numel(pro_ecology)) std(pro_democracy, 'omitnan') / sqrt(numel(pro_democracy)) std(pro_socjust, 'omitnan') / sqrt(numel(pro_socjust));
              std(con_ecology, 'omitnan') / sqrt(numel(con_ecology)) std(con_democracy, 'omitnan') / sqrt(numel(con_democracy)) std(con_socjust, 'omitnan') / sqrt(numel(con_socjust))];
    
    b = bar(y, 'grouped');
    bar_colors = [b(1).FaceColor; b(2).FaceColor; b(3).FaceColor];
    [ngroups, nbars] = size(y);
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i, :) = b(i).XEndPoints;
    end
    
    scatter_x_offsets = 0.05;
    scatter(x(1, 1) + scatter_x_offsets * randn(size(pro_ecology)), pro_ecology, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(1,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    scatter(x(2, 1) + scatter_x_offsets * randn(size(pro_democracy)), pro_democracy, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(2,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    scatter(x(3, 1) + scatter_x_offsets * randn(size(pro_socjust)), pro_socjust, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(3,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    scatter(x(1, 2) + scatter_x_offsets * randn(size(con_ecology)), con_ecology, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(1,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    scatter(x(2, 2) + scatter_x_offsets * randn(size(con_democracy)), con_democracy, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(2,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    scatter(x(3, 2) + scatter_x_offsets * randn(size(con_socjust)), con_socjust, 15, ...
        'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerFaceColor', bar_colors(3,:) * 0.8, 'MarkerFaceAlpha', 0.6);
    
    errorbar(x', y, errors, 'k', 'LineStyle', 'none', 'LineWidth', 0.9);
    
    title(variable_names(j)); 
    xticks([1 2]); 
    set(gca, 'xticklabel', {'Alignment', 'Misalignment'});
    xtickangle(15);
end
lg = legend(ax, b(:), {'Ecology', 'Democracy', 'Social justice'}, 'Orientation', 'horizontal', 'Location', 'northoutside');
lg.Layout.Tile = 'North';
set(lg, 'Box', 'off');
    
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/', 'WTP', 'per_theme.png'))
saveas(gcf, strcat(project_root,'/outputs/figures/Matlab/', 'WTP', 'per_theme.tif'))
