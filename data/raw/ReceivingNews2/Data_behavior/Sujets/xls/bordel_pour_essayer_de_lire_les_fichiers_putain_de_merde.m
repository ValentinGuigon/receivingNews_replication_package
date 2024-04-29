clear
clc

%%% Import data from spreadsheet
% Script for importing data from the following spreadsheets:
cd 'C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews 2\Sujets\csv'
currentFolder = strcat(pwd,'\');
%% VARIABLES
nbs = 1; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations

%% Import the data
allFiles = dir(currentFolder);
allNames = {allFiles(3:82).name};

%%Setup the Import Options and import the data
opts = detectImportOptions('NumVariables', 45);

% Specify sheet and range
opts.Sheet = 'Feuille1';
opts.DataRange = 'A2:AS146';

% Specify column names and types
opts.VariableNames = ['rowNo', 'trialNo', 'type', 'title', 'fixation', 'ITI', 'trialText', 'trialTextPos', 'trialTextOptions', 'stim1', 'stimPos', 'button1', 'button2', 'if1', 'then', 'label', 'responsePos', 'head', 'body', 'responseOptions', 'subjectGroup', 'random', 'randomBlock', 'responseRows', 'required', 'stimFormat', 'pageBreak', 'pageName', 'bgColor', 'textColor', 'stimPos_actual', 'ITI_ms', 'ITI_f', 'ITI_fDuration', 'timestamp', 'response', 'RT', 'correct', 'responseCode', 'SubjectRpabsolue', 'Robot', 'Rpsoumise', 'Bonnerp', 'Successabsolu', 'Successrobot',];
opts.VariableTypes = ['double', 'double', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'categorical', 'string', 'string', 'categorical', 'string', 'string', 'categorical', 'categorical', 'string', 'double', 'string', 'double', 'categorical', 'double', 'string', 'categorical', 'categorical', 'categorical', 'double', 'double', 'double', 'double', 'double', 'double', 'string', 'double', 'categorical', 'double', 'categorical', 'categorical', 'double', 'double'];

% Specify variable properties
opts = setvaropts(opts, ['then', 'label', 'head', 'body', 'random', 'responseRows', 'pageName', 'correct', 'GMT_timestamp', 'local_timestamp', 'mindsCode', 'link', 'id', 'sex', 'education', 'handedness', 'nationality', 'completionCode'], 'WhitespaceRule', 'preserve');
opts = setvaropts(opts, ['type', 'title', 'fixation', 'ITI', 'trialText', 'trialTextPos', 'trialTextOptions', 'stim1', 'stimPos', 'button1', 'button2', 'if1', 'then', 'label', 'responsePos', 'head', 'body', 'responseOptions', 'subjectGroup', 'random', 'responseRows', 'stimFormat', 'pageName', 'bgColor', 'textColor', 'stimPos_actual', 'correct', 'SubjectRpabsolue', 'Rpsoumise', 'Bonnerp', 'Rception', 'GMT_timestamp', 'local_timestamp', 'mindsCode', 'link', 'id', 'sex', 'education', 'handedness', 'nationality', 'completionCode'], 'EmptyFieldRule', 'auto');

% Import the data
%for subject = 1:nbs
%    Subjects_receiver{subject}.news = readtable(strcat('C:\Users\vguigon\Dropbox (Compte personnel)\Neuroeconomics Lab\FAKE NEWS\Programmation Testable\ReceivingNews\Pilote\S', num2str(subject), '.xls'), opts, 'UseExcel', false) ;
%end

for subject = 1
    currentFile(subject) = strcat(currentFolder, (allNames(subject)))
    Receivingnews2(subject).info = readtable(currentFile, opts, 'UseExcel', false);
end

%%

%for subject = 1:nbs
%    Receivingnews2_data{subject}.info = 

% %Puis, je charge les 2 premières lignes dans une struct :Sx, page1=détails
% %Puis je charge le reste dans la struct Sx, page2=data
% %[~, ~, raw] = xlsread('C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews 2\Sujets\xls\294929_201112_154613_M081642.xls','Feuille1','A1:M2');
% %raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
% %cellVectors = raw(:,[3,4,5,7,9,10,11,12,13]);
% %raw = raw(:,[1,2,6,8]);
% 
% %% Create output variable
% data = reshape([raw{:}],size(raw));
% 
% %% Allocate imported array to column variable names
% subjectGroup = data(:,1);
% GMT_timestamp = data(:,2);
% local_timestamp = cellVectors(:,1);
% mindsCode = cellVectors(:,2);
% link = cellVectors(:,3);
% calibration = data(:,3);
% id = cellVectors(:,4);
% age = data(:,4);
% sex = cellVectors(:,5);
% education = cellVectors(:,6);
% handedness = cellVectors(:,7);
% nationality = cellVectors(:,8);
% completionCode = cellVectors(:,9);
% 
% %% Clear temporary variables
% clearvars data raw cellVectors R;