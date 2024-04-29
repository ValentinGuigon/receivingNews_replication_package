clear
clc

%% VARIABLES

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/raw/ReceivingNews3/Data_behavior'));

currentFolder = strcat(pwd,'/');
%nbs = 190; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
%nbstim = 48; %nb_stimuli
allFolders = dir('M*');
outsiders3 = {'M054316', 'M046560', 'M004973', 'M037499', 'M042397', 'M031319', 'M014502', 'M027995', 'M003422', 'M062860'}';
allFolders(ismember({allFolders.name}, outsiders3)) = [];
nbs = length(allFolders);
allNames = {allFolders.name};

%% OPEN AND READ FILE: SUBJECTS INFORMATIONS
opts = spreadsheetImportOptions("NumVariables", 13);
opts.Sheet = "Feuille1";
opts.DataRange = "A1:M2";
opts.VariableNames = ["subjectGroup", "GMT_timestamp", "local_timestamp", "mindsCode", "link", "calibration", "id", "age", "sex", "education", "handedness", "nationality", "completionCode"];
opts.VariableTypes = ["double", "string", "string", "string", "string", "double", "string", "double", "string", "string", "string", "string", "string"];

for subject = 1:nbs
    %currentFile(subject) = allNames(subject);
    %filename = char(currentFile(subject));
    fichier = dir(fullfile(currentFolder, allFolders(subject).name,'*.xls')).name; 
    data = readtable(strcat(project_root,"/data/raw/ReceivingNews3/Data_behavior/",allNames(subject),"/",fichier), opts, "UseExcel", false);
    
    Receivingnews3(subject).subject = strcat('subject', string(subject));
    Receivingnews3(subject).name = allNames(subject);
    
    Receivingnews3(subject).info.subject = strcat('Subject', num2str(subject));
    Receivingnews3(subject).info.file = fichier;
    Receivingnews3(subject).info.subjectGroup = table2array(data(2, 1));
    Receivingnews3(subject).info.GMT_timestamp = table2array(data(2, 2));
    Receivingnews3(subject).info.local_timestamp = table2array(data(2, 3));
    Receivingnews3(subject).info.mindsCode = table2array(data(2, 4));
    Receivingnews3(subject).info.link = table2array(data(2, 5));
    Receivingnews3(subject).info.calibration = table2array(data(2, 6));
    Receivingnews3(subject).info.id = table2array(data(2, 7));
    Receivingnews3(subject).info.age = table2array(data(2, 8));
    Receivingnews3(subject).info.sex = table2array(data(2, 9));
    
    if strcmp(Receivingnews3(subject).info.sex, 'male')                 Receivingnews3(subject).info.sex = 1;
    elseif strcmp(Receivingnews3(subject).info.sex, 'female')           Receivingnews3(subject).info.sex = 2;
    else                                                                Receivingnews3(subject).info.sex = Receivingnews3(subject).info.sex;
    end
    
    Receivingnews3(subject).info.education = table2array(data(2, 10));     % Useless data bc bad translation @Testable en->fr
    if strcmp(Receivingnews3(subject).info.education, 'less than High school ')             Receivingnews3(subject).info.education = 1;
    elseif strcmp(Receivingnews3(subject).info.education, 'College or Technical school')    Receivingnews3(subject).info.education = 2;
    elseif strcmp(Receivingnews3(subject).info.education, 'High school or equivalent ')     Receivingnews3(subject).info.education = 3;
    elseif strcmp(Receivingnews3(subject).info.education, 'Bachelor degree')                Receivingnews3(subject).info.education = 4;
    elseif strcmp(Receivingnews3(subject).info.education, 'Master degree')                  Receivingnews3(subject).info.education = 5;
    elseif strcmp(Receivingnews3(subject).info.education, 'Doctorate degree')               Receivingnews3(subject).info.education = 6;
    else                                                                                    Receivingnews3(subject).info.education = Receivingnews3(subject).info.education;
    end
    
    Receivingnews3(subject).info.handedness = table2array(data(2, 11));
    Receivingnews3(subject).info.nationality = table2array(data(2, 12));
    Receivingnews3(subject).info.completionCode = table2array(data(2, 13));
end
clear data

%% OPEN AND READ FILE: SUBJECTS ORGANIZATIONS DATA
opts = spreadsheetImportOptions("NumVariables", 39);
opts.Sheet = "Feuille1";
opts.DataRange = "A5:AM16";
opts.VariableTypes = ["double", "string", "categorical", "categorical", "categorical", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string", "string", "categorical", "string", "string", "categorical", "categorical", "double", "double", "categorical", "double", "categorical", "double", "categorical", "categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "string", "double", "string"];

for subject = 1:nbs
    fichier = dir(fullfile(currentFolder, allFolders(subject).name,'*.xls')).name; 
    data = readtable(strcat(project_root,"/data/raw/ReceivingNews3/Data_behavior/",allNames(subject),"/",fichier), opts, "UseExcel", false);
    %data=data(3:end,:);
    
    Receivingnews3(subject).organizations = table;
    Receivingnews3(subject).organizations.ordre = (data{1:12, 1});
    Receivingnews3(subject).organizations.organization = string(data{1:12, 2});
    Receivingnews3(subject).organizations.eval =  string(data{1:12, 39});
    Receivingnews3(subject).organizations.RT =  str2double(data{1:12, 37});
end

%% OPEN AND READ FILE: SUBJECTS NEWS DATA
opts = spreadsheetImportOptions("NumVariables", 59);
opts.Sheet = "Feuille1";
opts.DataRange = "A1:BG160";
opts.VariableNames = ["rowNo", "trialNo", "type",        "title",       "fixation",    "ITI",    "trialText",   "trialTextPos", "trialTextOptions", "stim1",        "stimPos",      "button1",      "button2",      "if1",          "then", "label", "responsePos", "head", "body", "responseOptions",  "subjectGroup", "random", "randomBlock", "responseRows", "required", "stimFormat",  "pageBreak", "pageName",    "bgColor",      "textColor",    "stimPos_actual",   "ITI_ms", "ITI_f",  "ITI_fDuration", "timestamp",   "response", "RT",       "correct", "responseCode",  "VarName40",    "VarName41", "VarName42",   "VarName43",    "VarName44", "VarName45",   "VarName46", "VarName47",   "VarName48", "VarName49",   "VarName50", "VarName51",   "VarName52", "VarName53", "VarName54",  "VarName55", "VarName56",   "VarName57",    "VarName58", "VarName59"];
opts.VariableTypes = ["double", "double", "categorical", "categorical", "categorical", "double", "categorical", "categorical",  "categorical",      "categorical",  "categorical",  "categorical",  "categorical",  "categorical",  "char", "char",  "categorical", "char", "char", "categorical",      "categorical",  "double", "double",      "categorical",  "double",   "categorical", "double",    "categorical", "categorical",  "categorical",  "categorical",      "double", "double", "double",        "double",      "double",   "double",   "double",  "double",        "string",       "double",    "string",      "string",       "double",    "double",      "double",    "double",      "double",    "categorical", "double",    "double",      "double",    "double",    "char",       "double",    "double",      "double",       "double",    "double"];
opts = setvaropts(opts, ["then", "label", "head", "body", "VarName54"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["type", "title", "fixation", "trialText", "trialTextPos", "trialTextOptions", "stim1", "stimPos", "button1", "button2", "if1", "then", "label", "responsePos", "head", "body", "responseOptions", "subjectGroup", "responseRows", "stimFormat", "pageName", "bgColor", "textColor", "stimPos_actual", "VarName40", "VarName42", "VarName43", "VarName49", "VarName54"], "EmptyFieldRule", "auto");

for subject = 1:nbs
    fichier = dir(fullfile(currentFolder, allFolders(subject).name,'*.xls')).name; 
    data = readtable(strcat(project_root,"/data/raw/ReceivingNews3/Data_behavior/",allNames(subject),"/",fichier), opts);
    
    Receivingnews3(subject).news = table;
    Receivingnews3(subject).news.ligne = data{17:3:160, 1};
    Receivingnews3(subject).news.idnews = data{17:3:160, 2};
    Receivingnews3(subject).news.evaluation = data{17:3:160, 39};
    Receivingnews3(subject).news.evaluation_RT = data{17:3:160, 37};
    Receivingnews3(subject).news.reception = data{18:3:160, 36};
    Receivingnews3(subject).news.reception_RT = data{18:3:160, 37};
    Receivingnews3(subject).news.WTP = data{19:3:160, 36};
    Receivingnews3(subject).news.WTP_RT = data{19:3:160, 37};
    Receivingnews3(subject).news.veracity_judgment = data{17:3:160, 40};
    Receivingnews3(subject).news.veracity_truth = data{17:3:160, 43};
    Receivingnews3(subject).news.eval_success = data{17:3:160, 45};
    
    Receivingnews3(subject).news = sortrows(Receivingnews3(subject).news,2);
end

%% QST DATA
for subject = 1:nbs
    fichier = dir(fullfile(project_root, 'data/raw/ReceivingNews3/data_questionnaires', allFolders(subject).name,'589965*.csv')).name; 
    data = readtable(strcat(project_root,"/data/raw/ReceivingNews3/Data_questionnaires/",allNames(subject),"/",fichier));
   
%Regarding epistemic curiosity items: Scale and items taken from Litman 2008 paper on Epistemic Curiosity Items for CFD-P and D-EC), Càd I-Type et D-type (from Diagram of the 10-item 2-factor I/D EC model)
    Receivingnews3(subject).questionnaire = table;
    %epistemic curiosity items
    data(1:10,13) = regexprep(data{1:10,13},{'Presque jamais','De temps en temps','Souvent','Presque toujours'},{'1', '2', '3', '4'});
    Receivingnews3(subject).questionnaire.EC_I_type_1 = str2double(data{1,13}); %1,13
    Receivingnews3(subject).questionnaire.EC_I_type_2 = str2double(data{5,13}); %5,13
    Receivingnews3(subject).questionnaire.EC_I_type_3 = str2double(data{3,13}); %3,13
    Receivingnews3(subject).questionnaire.EC_I_type_4 = str2double(data{9,13}); %9,13
    Receivingnews3(subject).questionnaire.EC_I_type_5 = str2double(data{7,13}); %7,13
    Receivingnews3(subject).questionnaire.EC_D_type_6 = str2double(data{4,13}); %4,13
    Receivingnews3(subject).questionnaire.EC_D_type_8 = str2double(data{2,13}); %2,13
    Receivingnews3(subject).questionnaire.EC_D_type_7 = str2double(data{8,13}); %8,13
    Receivingnews3(subject).questionnaire.EC_D_type_9 = str2double(data{6,13}); %6,13
    Receivingnews3(subject).questionnaire.EC_D_type_10 = str2double(data{10,13}); %10,13
    %compute EC score
    Receivingnews3(subject).questionnaire.EC_score = sum(Receivingnews3(subject).questionnaire{1,1:10});

    %News exposition
    Receivingnews3(subject).questionnaire.plateformesnews = data{11,13};
    Receivingnews3(subject).questionnaire.freqconsultation = data{12,13};
    Receivingnews3(subject).questionnaire.sourcesnews = data{13,13};
    
    %Estimated percentage of fake news in following environments:
    Receivingnews3(subject).questionnaire.politique =   str2double(data{14,13});
    Receivingnews3(subject).questionnaire.journaliste = str2double(data{15,13});
    Receivingnews3(subject).questionnaire.medecin =     str2double(data{16,13});
    Receivingnews3(subject).questionnaire.acteurjustsoc = str2double(data{17,13});
    Receivingnews3(subject).questionnaire.chercheur =   str2double(data{18,13});
    Receivingnews3(subject).questionnaire.acteurecologie = str2double(data{19,13});
    Receivingnews3(subject).questionnaire.general =     str2double(data{20,13});

    %Strategy during task
    Receivingnews3(subject).questionnaire.streval = data{21,13};
    Receivingnews3(subject).questionnaire.strrec = data{22,13};
    Receivingnews3(subject).questionnaire.receptionisreal = data{23,13};
    
    %mail
    Receivingnews3(subject).questionnaire.mail = data{24,13};
end

%% PROCESS DATA
% Separate orgas eval into each dimension eval, then compute social distance
for subject = 1:nbs
    str = Receivingnews3(subject).organizations.eval(:);
    expression = '\_';
    splitStr = regexp(str,expression,'split');
    
    for org = 1:nbo
        for eval = 1:nbe
            temp(org,eval) = splitStr{org}(eval);
        end
    end
    temp=strrep(temp, 'na', '4'); %replace all NaNs
    Receivingnews3(subject).organizations.Q1_familiarity_self = str2num(cell2mat(temp(:,1)));
    Receivingnews3(subject).organizations.Q2_valuecloseness_self = str2num(cell2mat(temp(:,2)));
    Receivingnews3(subject).organizations.Q3_likeness_self = str2num(cell2mat(temp(:,3)));
    Receivingnews3(subject).organizations.Q4_familiarity_relatives = str2num(cell2mat(temp(:,4)));
    Receivingnews3(subject).organizations.Q5_valuecloseness_relatives = str2num(cell2mat(temp(:,5)));
    Receivingnews3(subject).organizations.Q6_likeness_relatives = str2num(cell2mat(temp(:,6)));
    Receivingnews3(subject).organizations.social_dist = round(((str2num(cell2mat(temp(:,1))) + str2num(cell2mat(temp(:,2))) + str2num(cell2mat(temp(:,3))) + str2num(cell2mat(temp(:,4))) + str2num(cell2mat(temp(:,5))) + str2num(cell2mat(temp(:,6))))*100)/42);
    %cell2mat to go from str array to ordinary array then str2num to turn into numeric and do calculations
    Receivingnews3(subject).organizations = sortrows(Receivingnews3(subject).organizations, 1,'ascend'); %reorganize orga by order
clear temp
end

%% Reorganize subjects data in allSubjects3
for subject = 1:nbs
    str = Receivingnews3(subject).info.subject;
    id = sscanf(str,'Subject%d');
    allSubjects3(subject,1) = array2table(id);
    allSubjects3(subject,2) = array2table(Receivingnews3(subject).info.subjectGroup);
    clear temp
    for orga = 1:nbo
        temp(1,orga) = Receivingnews3(subject).organizations{orga,11};
    end
    allSubjects3(subject,3:14) = array2table(temp(1,1:12));
    clear temp;      
end

allSubjects3(1:nbs,15:446)=array2table(zeros(nbs,432));
for subject = 1:nbs
    allSubjects3(subject,15:9:end) = num2cell(Receivingnews3(subject).news{:,2}');
    temp = Receivingnews3(subject).news{:,10}';
    for i = 1:length(temp)
        if strcmp(temp(1,i) , 'VRAIE')
            temp2(1,i) = 1;
        else
            temp2 (1,i) = 0;
        end
    end
    allSubjects3(subject,16:9:end) = num2cell(temp2);
    allSubjects3(subject,17:9:end) = array2table(Receivingnews3(subject).news{:,3}');
    allSubjects3(subject,18:9:end) = array2table(Receivingnews3(subject).news{:,4}');
    allSubjects3(subject,19:9:end) = array2table(Receivingnews3(subject).news{:,11}');
    allSubjects3(subject,20:9:end) = array2table(Receivingnews3(subject).news{:,5}');
    allSubjects3(subject,21:9:end) = array2table(Receivingnews3(subject).news{:,6}');
    allSubjects3(subject,22:9:end) = array2table(Receivingnews3(subject).news{:,7}');
    allSubjects3(subject,23:9:end) = array2table(Receivingnews3(subject).news{:,8}');
end

allSubjects3(1:nbs,447:457)=array2table(zeros(nbs,11));
for subject = 1:nbs
    allSubjects3(subject,447) = array2table(Receivingnews3(subject).info.age);
    allSubjects3(subject,448) = array2table(Receivingnews3(subject).info.sex);
    allSubjects3(subject,449) = array2table(Receivingnews3(subject).info.education);
    allSubjects3(subject,450) = Receivingnews3(subject).questionnaire(1,11);
    
    allSubjects3(subject,451:457) = Receivingnews3(subject).questionnaire(1,15:21);
end

% Rename cols & rows
clearvars varNames;
varNames(1:2) = {'subject', 'group'};
varNames(3:14) = cellstr(Receivingnews3(1).organizations{1:12,2});
varNames = regexprep(varNames, ' ', '_');   varNames = regexprep(varNames, '-', '_');

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
varNames(447:457) = {'age', 'sex', 'education', 'EC', 'prcnt_politique', 'prcnt_journaliste', 'prcnt_medecin', 'prcnt_acteurjustsoc', 'prcnt_chercheur', 'prcnt_acteurecologie', 'prcnt_general'};

allSubjects3.Properties.VariableNames = varNames;
for i = 1:nbs
   Names(1,i) = {(strcat('subject',num2str(i)))};
end
allSubjects3.Properties.RowNames = Names;


%% Save
clear allFolders allNames currentFolder data eval expression fichier i j k Names nbe nbo nbstim opts org orga splitStr str subject temp temp2 varNames id

 cd(strcat(project_root,'/data/intermediate'));
 save Receivingnews3_extracted.mat allSubjects3 Receivingnews3