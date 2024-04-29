clear
clc

%% VARIABLES
cd 'C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews\Pilote\Sujets\csv'
currentFolder = strcat(pwd,'\');
nbs = 20; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli
allFiles = dir(currentFolder);
allNames = {allFiles(3:22).name};

%% OPEN AND READ FILE: SUBJECTS INFORMATIONS
delimiter = ';';
startRow = 1;
endRow = 2;
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

for subject = 1:nbs
    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));
    
    opts = delimitedTextImportOptions("NumVariables", 39);    opts.DataLines = [2, 2];    opts.Delimiter = ";";
    opts.VariableNames = ["subjectGroup", "GMT_timestamp", "local_timestamp", "mindsCode", "link", "calibration", "id", "age", "sex", "education", "handedness", "nationality", "completionCode", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27", "Var28", "Var29", "Var30", "Var31", "Var32", "Var33", "Var34", "Var35", "Var36", "Var37", "Var38", "Var39"];
    opts.SelectedVariableNames = ["subjectGroup", "GMT_timestamp", "local_timestamp", "mindsCode", "link", "calibration", "id", "age", "sex", "education", "handedness", "nationality", "completionCode"];
    opts.VariableTypes = ["double", "double", "string", "string", "string", "double", "string", "double", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
    opts.ExtraColumnsRule = "ignore";    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, ["local_timestamp", "mindsCode", "link", "id", "sex", "education", "handedness", "nationality", "completionCode", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27", "Var28", "Var29", "Var30", "Var31", "Var32", "Var33", "Var34", "Var35", "Var36", "Var37", "Var38", "Var39"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["local_timestamp", "mindsCode", "link", "id", "sex", "education", "handedness", "nationality", "completionCode", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22", "Var23", "Var24", "Var25", "Var26", "Var27", "Var28", "Var29", "Var30", "Var31", "Var32", "Var33", "Var34", "Var35", "Var36", "Var37", "Var38", "Var39"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, ["calibration", "age"], "TrimNonNumeric", true);
    opts = setvaropts(opts, ["calibration", "age"], "ThousandsSeparator", ",");
    dataArray = readtable(strcat("C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews\Pilote\Sujets\csv\", filename), opts);

    if subject == 17 | subject == 19
        dataArray(1,5:13) = dataArray(1,4:12);
    end
    
    % Allocate imported array to column variable names
    ReceivingnewsPilote(subject).subject = strcat('Subject', num2str(subject));
    id = strcat('Subject', num2str(subject));
    
    ReceivingnewsPilote(subject).info.subject = strcat('Subject', num2str(subject));
    ReceivingnewsPilote(subject).info.file = filename;
    ReceivingnewsPilote(subject).info.subjectGroup = dataArray.subjectGroup;
    ReceivingnewsPilote(subject).info.GMT_timestamp = dataArray.GMT_timestamp;
    ReceivingnewsPilote(subject).info.local_timestamp = dataArray.local_timestamp;
    ReceivingnewsPilote(subject).info.mindsCode = dataArray.mindsCode;
    ReceivingnewsPilote(subject).info.link = dataArray.link;
    ReceivingnewsPilote(subject).info.calibration = dataArray.calibration;
    ReceivingnewsPilote(subject).info.id = dataArray.id;
    ReceivingnewsPilote(subject).info.age = dataArray.age;
    ReceivingnewsPilote(subject).info.sex = dataArray.sex;
    
    if strcmp(ReceivingnewsPilote(subject).info.sex, 'male')
        ReceivingnewsPilote(subject).info.sex = 1;
    elseif strcmp(ReceivingnewsPilote(subject).info.sex, 'female')
        ReceivingnewsPilote(subject).info.sex = 2;
    else
        ReceivingnewsPilote(subject).info.sex = ReceivingnewsPilote(subject).info.sex;
    end
    
    ReceivingnewsPilote(subject).info.education = dataArray.education;
    % Useless data bc bad translation @Testable en->fr
    if strcmp(ReceivingnewsPilote(subject).info.education, 'less than High school ')
        ReceivingnewsPilote(subject).info.education = 1;
    elseif strcmp(ReceivingnewsPilote(subject).info.education, 'College or Technical school')
        ReceivingnewsPilote(subject).info.education = 2;
    elseif strcmp(ReceivingnewsPilote(subject).info.education, 'High school or equivalent ')
        ReceivingnewsPilote(subject).info.education = 3;
    elseif strcmp(ReceivingnewsPilote(subject).info.education, 'Bachelor degree')
        ReceivingnewsPilote(subject).info.education = 4;
    elseif strcmp(ReceivingnewsPilote(subject).info.education, 'Master degree')
        ReceivingnewsPilote(subject).info.education = 5;
    elseif strcmp(ReceivingnewsPilote(subject).info.education, 'Doctorate degree')
        ReceivingnewsPilote(subject).info.education = 6;
    else
        ReceivingnewsPilote(subject).info.education = ReceivingnewsPilote(subject).info.education;
    end
    
    ReceivingnewsPilote(subject).info.handedness = dataArray.handedness;
    ReceivingnewsPilote(subject).info.nationality = dataArray.nationality;
    ReceivingnewsPilote(subject).info.completionCode = dataArray.completionCode;
end
clearvars filename endRow fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R

%% OPEN AND READ FILE: SUBJECTS ORGANIZATIONS DATA
delimiter = ';';
startRow = 4;
endRow = 16;
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

for subject = 1:nbs
    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));
    
    opts = delimitedTextImportOptions("NumVariables", 39);    opts.DataLines = [5, 16];    opts.Delimiter = ";";
    opts.VariableNames = ["rowNo", "trialNo", "type", "title", "fixation", "ITI", "trialText", "trialTextPos", "trialTextOptions", "stim1", "stimPos", "button1", "button2", "if1", "then", "label", "responsePos", "head", "body", "responseOptions", "subjectGroup", "random", "randomBlock", "responseRows", "required", "stimFormat", "pageBreak", "pageName", "bgColor", "textColor", "stimPos_actual", "ITI_ms", "ITI_f", "ITI_fDuration", "timestamp", "response", "RT", "correct", "responseCode"];
    opts.VariableTypes = ["double", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string", "double", "categorical", "string", "string", "categorical", "double", "double", "double", "categorical", "double", "categorical", "double", "categorical", "double", "categorical", "categorical", "double", "double", "double", "double", "string", "string", "double", "string"];
    opts.ExtraColumnsRule = "ignore";    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, ["then", "head", "body", "response", "responseCode"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["type", "title", "fixation", "ITI", "trialText", "trialTextPos", "trialTextOptions", "stim1", "stimPos", "button1", "button2", "if1", "then", "responsePos", "head", "body", "responseOptions", "responseRows", "stimFormat", "pageName", "textColor", "stimPos_actual", "response", "responseCode"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, ["label", "subjectGroup", "bgColor"], "TrimNonNumeric", true);
    opts = setvaropts(opts, ["label", "subjectGroup", "bgColor"], "ThousandsSeparator", ",");
    dataArray = readtable(strcat("C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews\Pilote\Sujets\csv\", filename), opts);

    text1 = '<b><font size="6"><center>';
    text2 = '</center></font></b>';
    dataArray.head = erase(dataArray.head(:,:), text1);
    dataArray.head = erase(dataArray.head(:,:), text2);
    dataArray.head(dataArray.head == "Groupe d'experts intergouvernemental sur l'évolution du climat (NIPCC)",:) = "NIPCC";
    
    % A cause d'un putain de bug de lecture d'Office de sa race, des
    % lignes ont ete decalees
    
    % Create output variable
    ReceivingnewsPilote(subject).organizations = table;
    ReceivingnewsPilote(subject).organizations.ordre = dataArray.rowNo;
    ReceivingnewsPilote(subject).organizations.organization = dataArray.head;
    ReceivingnewsPilote(subject).organizations.eval = dataArray.RT;
    ReceivingnewsPilote(subject).organizations.RT = dataArray.correct;
end

%% OPEN AND READ FILE: SUBJECTS NEWS DATA
for subject = 1:nbs
    delimiter = ';';
    formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';
    
    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));
    
    opts = delimitedTextImportOptions("NumVariables", 46);    opts.DataLines = [17, Inf];    opts.Delimiter = ";";
    opts.VariableNames = ["rowNo", "trialNo", "type", "title", "fixation", "ITI", "trialText", "trialTextPos", "trialTextOptions", "stim1", "stimPos", "button1", "button2", "if1", "then", "label", "responsePos", "head", "body", "responseOptions", "subjectGroup", "random", "randomBlock", "responseRows", "required", "stimFormat", "pageBreak", "pageName", "bgColor", "textColor", "stimPos_actual", "ITI_ms", "ITI_f", "ITI_fDuration", "timestamp", "response", "RT", "correct", "responseCode", "VarName40", "VarName41", "VarName42", "VarName43", "VarName44", "VarName45", "VarName46"];
    opts.VariableTypes = ["double", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string", "double", "categorical", "string", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "categorical", "double", "double", "double", "categorical", "categorical", "double", "double", "double", "double", "string", "double", "double", "double", "categorical", "double", "categorical", "categorical", "double", "double"];
    opts.ExtraColumnsRule = "ignore";    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, ["then", "head", "RT"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["type", "title", "fixation", "ITI", "trialText", "trialTextPos", "trialTextOptions", "stim1", "stimPos", "button1", "button2", "if1", "then", "responsePos", "head", "body", "responseOptions", "pageBreak", "stimPos_actual", "ITI_ms", "RT", "VarName41", "VarName43", "VarName44"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, ["label", "random", "randomBlock", "textColor"], "TrimNonNumeric", true);
    opts = setvaropts(opts, ["label", "random", "randomBlock", "textColor"], "ThousandsSeparator", ",");
    dataArray = readtable(strcat("C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Programmation Stimuli (Testable)\ReceivingNews\Pilote\Sujets\csv\", filename), opts);
    
    ReceivingnewsPilote(subject).news = table;
    ReceivingnewsPilote(subject).news.ligne = table2array(dataArray(1:3:144,1));
    ReceivingnewsPilote(subject).news.idnews = table2array(dataArray(1:3:144,2));
    ReceivingnewsPilote(subject).news.evaluation = str2double(table2array(dataArray(1:3:144,37)));
    ReceivingnewsPilote(subject).news.evaluation_RT = table2array(dataArray(1:3:144,38));
    ReceivingnewsPilote(subject).news.reception = table2array(dataArray(2:3:144,38));
    ReceivingnewsPilote(subject).news.reception_RT = table2array(dataArray(2:3:144,39));
    ReceivingnewsPilote(subject).news.WTP = str2double(table2array(dataArray(3:3:144,37)));
    ReceivingnewsPilote(subject).news.WTP_RT = table2array(dataArray(3:3:144,38));
    ReceivingnewsPilote(subject).news.veracity_judgment = table2array(dataArray(1:3:144,41));
    ReceivingnewsPilote(subject).news.veracity_truth = string(table2array(dataArray(1:3:144,44)));
    ReceivingnewsPilote(subject).news.eval_success = table2array(dataArray(1:3:144,45));
end

%% CLEAR VARS
clearvars filename endRow fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R allFiles currentFile delimiter formatSpec startRow subject;


%% PROCESS DATA
% Separate orgas eval into each dimension eval, then compute social distance
for subject = 1:nbs
    str = ReceivingnewsPilote(subject).organizations.eval(:);
    expression = '\_';
    splitStr = regexp(str,expression,'split');
    
    for org = 1:nbo
        for eval = 1:nbe
            temp(org,eval) = splitStr{org}(eval);
        end
    end
    temp=strrep(temp, 'na', '4'); %replace all NaNs
    ReceivingnewsPilote(subject).organizations.Q1_familiarity_self = str2num(cell2mat(temp(:,1)));
    ReceivingnewsPilote(subject).organizations.Q2_valuecloseness_self = str2num(cell2mat(temp(:,2)));
    ReceivingnewsPilote(subject).organizations.Q3_likeness_self = str2num(cell2mat(temp(:,3)));
    ReceivingnewsPilote(subject).organizations.Q4_familiarity_relatives = str2num(cell2mat(temp(:,4)));
    ReceivingnewsPilote(subject).organizations.Q5_valuecloseness_relatives = str2num(cell2mat(temp(:,5)));
    ReceivingnewsPilote(subject).organizations.Q6_likeness_relatives = str2num(cell2mat(temp(:,6)));
    ReceivingnewsPilote(subject).organizations.social_dist = round(((str2num(cell2mat(temp(:,1))) + str2num(cell2mat(temp(:,2))) + str2num(cell2mat(temp(:,3))) + str2num(cell2mat(temp(:,4))) + str2num(cell2mat(temp(:,5))) + str2num(cell2mat(temp(:,6))))*100)/42);
    %cell2mat to go from str array to ordinary array
    %then str2num to turn into numeric and do calculations
    ReceivingnewsPilote(subject).organizations = sortrows(ReceivingnewsPilote(subject).organizations, 1,'ascend'); %reorganize orga by order
end

clearvars eval expression index org splitStr str subject temp;

% Reorganize subjects data in allSubjects2
clearvars temp
for subject = 1:nbs
    str = ReceivingnewsPilote(subject).info.subject;
    id = sscanf(str,'Subject%d');
    allSubjectsPilote(subject,1) = array2table(id);
    allSubjectsPilote(subject,2) = array2table(ReceivingnewsPilote(subject).info.subjectGroup);
    clearvars temp
    for orga = 1:nbo
        temp(1,orga) = ReceivingnewsPilote(subject).organizations{orga,11};
    end
    allSubjectsPilote(subject,3:14) = array2table(temp(1,1:12));
    clearvars temp;      
end
clearvars temp orga subject;

clearvars temp;
allSubjectsPilote(1:20,15:446)=array2table(zeros(20,432));
for subject = 1:nbs
    allSubjectsPilote(subject,15:9:end) = num2cell(ReceivingnewsPilote(subject).news{:,2}');
    temp = ReceivingnewsPilote(subject).news{:,10}';
    for i = 1:length(temp)
        if strcmp(temp(1,i) , 'VRAIE')
            temp2(1,i) = 1;
        else
            temp2 (1,i) = 0;
        end
    end
    allSubjectsPilote(subject,16:9:end) = num2cell(temp2);
    allSubjectsPilote(subject,17:9:end) = array2table(ReceivingnewsPilote(subject).news{:,3}');
    allSubjectsPilote(subject,18:9:end) = array2table(ReceivingnewsPilote(subject).news{:,4}');
    allSubjectsPilote(subject,19:9:end) = array2table(ReceivingnewsPilote(subject).news{:,11}');
    allSubjectsPilote(subject,20:9:end) = array2table(ReceivingnewsPilote(subject).news{:,5}');
    allSubjectsPilote(subject,21:9:end) = array2table(ReceivingnewsPilote(subject).news{:,6}');
    allSubjectsPilote(subject,22:9:end) = array2table(ReceivingnewsPilote(subject).news{:,7}');
    allSubjectsPilote(subject,23:9:end) = array2table(ReceivingnewsPilote(subject).news{:,8}');
end

allSubjectsPilote(1:20,447:449)=array2table(zeros(20,3));
for subject = 1:nbs
    allSubjectsPilote(subject,447) = num2cell(ReceivingnewsPilote(subject).info.age);
    allSubjectsPilote(subject,448) = num2cell(ReceivingnewsPilote(subject).info.sex);
    allSubjectsPilote(subject,449) = num2cell(ReceivingnewsPilote(subject).info.education);
end

% Rename cols & rows
clearvars varNames;
varNames(1:2) = {'subject', 'group'};
varNames(3:14) = cellstr(ReceivingnewsPilote(1).organizations{1:12,2}');
varNames = regexprep(varNames, ' ', '_');
varNames = regexprep(varNames, '-', '_');
j=1; k=15;
for i = 1:48
    varNames(1,k) = {(strcat('stim', num2str(j),'_idnews'))};
    varNames(1,k+1) = {(strcat('stim', num2str(j),'_veracity'))};
    varNames(1,k+2) = {(strcat('stim', num2str(j),'_eval'))};
    varNames(1,k+3) = {(strcat('stim', num2str(j),'_eval_RT'))};
    varNames(1,k+4) = {(strcat('stim', num2str(j),'_success'))};
    varNames(1,k+5) = {(strcat('stim', num2str(j),'_rec'))};
    varNames(1,k+6) = {(strcat('stim', num2str(j),'_rec_RT'))};
    varNames(1,k+7) = {(strcat('stim', num2str(j),'_WTP'))};
    varNames(1,k+8) = {(strcat('stim', num2str(j),'_WTP_RT'))};
    j=j+1;
    k=k+9;
end
varNames(447:449) = {'age', 'sex', 'education'};
allSubjectsPilote.Properties.VariableNames = varNames;
for i = 1:20
   Names(1,i) = {(strcat('subject',num2str(i)))};
end
allSubjectsPilote.Properties.RowNames = Names;
clear allNames i j k subject varNames temp temp2 currentFolder id nbe nbo nbe nbstim

%% Save
clear allFolders allNames currentFolder data eval expression fichier i j k Names nbe nbo nbstim opts org orga splitStr str subject temp temp2 varNames id
cd 'C:\Users\vguigon\Dropbox (Personal)\Neuroeconomics Lab\FAKE NEWS\Scripts\Testable\Pilote data'
save ReceivingnewsPilote.mat allSubjectsPilote ReceivingnewsPilote