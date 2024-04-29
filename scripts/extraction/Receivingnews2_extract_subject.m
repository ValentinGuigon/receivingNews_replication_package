clear
clc

%% VARIABLES

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/raw/ReceivingNews2/Data_behavior/Sujets/csv'));

currentFolder = strcat(pwd,'/');
nbs = 80; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli
allFiles = dir(currentFolder);
allNames = {allFiles(3:82).name};

%% OPEN AND READ FILE: SUBJECTS INFORMATIONS
delimiter = ';';
endRow = 2;
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

for subject = 1:nbs
    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));

    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'ReturnOnError', false);
    fclose(fileID);

    % Convert the contents of columns containing numeric strings to numbers:
    % Replace non-numeric strings with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    for col=[1,7]
        % Converts strings in the input cell array to numbers. Replaced non-numeric
        % strings with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1);
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData{row}, regexstr, 'names');
                numbers = result.numbers;

                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if any(numbers==',');
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'));
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric strings to numbers.
                if ~invalidThousandsSeparator;
                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch me
            end
        end
    end

    % Split data into numeric and cell columns.
    rawNumericColumns = raw(:, [1,7]);
    rawCellColumns = raw(:, [2,3,4,5,6,8,9,10,11,12,13]);

    % Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

    % Allocate imported array to column variable names
    Receivingnews2(subject).subject = strcat('Subject', num2str(subject));
    id = strcat('Subject', num2str(subject));
    
    Receivingnews2(subject).info.subject = strcat('Subject', num2str(subject));
    Receivingnews2(subject).info.file = filename;
    Receivingnews2(subject).info.subjectGroup = cell2mat(rawNumericColumns(2, 1));
    Receivingnews2(subject).info.GMT_timestamp = cell2mat(rawCellColumns(2, 1));
    Receivingnews2(subject).info.local_timestamp = cell2mat(rawCellColumns(2, 2));
    Receivingnews2(subject).info.mindsCode = cell2mat(rawCellColumns(2, 3));
    Receivingnews2(subject).info.link = cell2mat(rawCellColumns(2, 4));
    Receivingnews2(subject).info.calibration = cell2mat(rawCellColumns(2, 5));
    Receivingnews2(subject).info.id = cell2mat(rawNumericColumns(2, 2));
    Receivingnews2(subject).info.age = str2double(rawCellColumns(2, 6));
    Receivingnews2(subject).info.sex = cell2mat(rawCellColumns(2, 7));
    
    if strcmp(Receivingnews2(subject).info.sex, 'male')
        Receivingnews2(subject).info.sex = 1;
    elseif strcmp(Receivingnews2(subject).info.sex, 'female')
        Receivingnews2(subject).info.sex = 2;
    else
        Receivingnews2(subject).info.sex = Receivingnews2(subject).info.sex;
    end
    
    Receivingnews2(subject).info.education = cell2mat(rawCellColumns(2, 8));
    % Useless data bc bad translation @Testable en->fr
    if strcmp(Receivingnews2(subject).info.education, 'less than High school ')
        Receivingnews2(subject).info.education = 1;
    elseif strcmp(Receivingnews2(subject).info.education, 'College or Technical school')
        Receivingnews2(subject).info.education = 2;
    elseif strcmp(Receivingnews2(subject).info.education, 'High school or equivalent ')
        Receivingnews2(subject).info.education = 3;
    elseif strcmp(Receivingnews2(subject).info.education, 'Bachelor degree')
        Receivingnews2(subject).info.education = 4;
    elseif strcmp(Receivingnews2(subject).info.education, 'Master degree')
        Receivingnews2(subject).info.education = 5;
    elseif strcmp(Receivingnews2(subject).info.education, 'Doctorate degree')
        Receivingnews2(subject).info.education = 6;
    else
        Receivingnews2(subject).info.education = Receivingnews2(subject).info.education;
    end
    
    Receivingnews2(subject).info.handedness = cell2mat(rawCellColumns(2, 9));
    Receivingnews2(subject).info.nationality = num2str(2, 10);
    Receivingnews2(subject).info.completionCode = cell2mat(rawCellColumns(2, 11));
end
clearvars filename endRow fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

%% OPEN AND READ FILE: SUBJECTS ORGANIZATIONS DATA
delimiter = ';';
startRow = 4;
endRow = 16;
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

for subject = 1:nbs
    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));
    
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'HeaderLines', startRow-1, 'ReturnOnError', false);
    fclose(fileID);

    % Replace non-numeric strings with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    for col=[1,7,16,18,21,22,23,25,27,29,32,33,34,35,37,38,39]
        % Converts strings in the input cell array to numbers. Replaced non-numeric
        % strings with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1);
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData{row}, regexstr, 'names');
                numbers = result.numbers;

                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if any(numbers==',');
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'));
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric strings to numbers.
                if ~invalidThousandsSeparator;
                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch me
            end
        end
    end

    % Split data into numeric and cell columns.
    rawNumericColumns = raw(:, [1,7,16,18,21,22,23,25,27,29,32,33,34,35,37,38,39]);
    rawCellColumns = raw(:, [2,3,4,5,6,8,9,10,11,12,13,14,15,17,19,20,24,26,28,30,31,36]);
    
    % Replace non-numeric cells with NaN
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells  

    % Create output variable
    Receivingnews2(subject).organizations = table;
    Receivingnews2(subject).organizations.ordre = cell2mat(rawNumericColumns(2:13, 1));
    Receivingnews2(subject).organizations.organization = rawCellColumns(2:13, 1);
    Receivingnews2(subject).organizations.eval = rawCellColumns(2:13, 22);
    Receivingnews2(subject).organizations.RT = cell2mat(rawNumericColumns(2:13, 15));
end

%% OPEN AND READ FILE: SUBJECTS NEWS DATA
for subject = 1:nbs
    delimiter = ';';
    formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

    currentFile(subject) = allNames(subject);
    filename = char(currentFile(subject));
    
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    fclose(fileID);
    
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = dataArray{col};
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    for col=[1,2,7,16,18,21,22,23,25,27,29,32,33,34,35,36,37,38,39,41,44,45,46,47,48,50,52,53]
        % Converts strings in the input cell array to numbers. Replaced non-numeric
        % strings with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1);
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData{row}, regexstr, 'names');
                numbers = result.numbers;

                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if any(numbers==',');
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'));
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric strings to numbers.
                if ~invalidThousandsSeparator;
                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch me
            end
        end
    end
    
    rawNumericColumns = raw(:, [1,2,7,16,18,21,22,23,25,27,29,32,33,34,35,36,37,38,39,41,44,45,46,47,48,50,52,53]);
    rawCellColumns = raw(:, [3,4,5,6,8,9,10,11,12,13,14,15,17,19,20,24,26,28,30,31,40,42,43,49,51,54]);
    
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
    
    Receivingnews2(subject).news = table;
    Receivingnews2(subject).news.ligne = cell2mat(rawNumericColumns(17:3:160, 1));
    Receivingnews2(subject).news.idnews = cell2mat(rawNumericColumns(17:3:160, 2));
    Receivingnews2(subject).news.evaluation = rawNumericColumns(17:3:160, 16);
    Receivingnews2(subject).news.evaluation_RT = rawNumericColumns(17:3:160, 17);
    Receivingnews2(subject).news.reception = rawNumericColumns(18:3:160, 16);
    Receivingnews2(subject).news.reception_RT = rawNumericColumns(18:3:160, 17);
    Receivingnews2(subject).news.WTP = rawNumericColumns(19:3:160, 16);
    Receivingnews2(subject).news.WTP_RT = rawNumericColumns(19:3:160, 17);
    Receivingnews2(subject).news.veracity_judgment = rawCellColumns(17:3:160, 22);
    Receivingnews2(subject).news.veracity_truth = rawCellColumns(17:3:160, 23);
    Receivingnews2(subject).news.eval_success = rawNumericColumns(17:3:160, 21);
end

%% CLEAR VARS
clearvars filename endRow fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R allFiles currentFile delimiter formatSpec startRow subject;

%% QST DATA

filename = strcat(project_root,'/data/raw/ReceivingNews2/Data_questionnaires/589965_201120_084612_n85/589965_201120_084612_n85_response_linkedtonewsdata.csv');

delimiter = ';';
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = dataArray{col};
        end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[7,8,21]
            % Converts strings in the input cell array to numbers. Replaced non-numeric
            % strings with NaN.
            rawData = dataArray{col};
            for row=1:size(rawData, 1);
                % Create a regular expression to detect and remove non-numeric prefixes and
                % suffixes.
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData{row}, regexstr, 'names');
                    numbers = result.numbers;

                    % Detected commas in non-thousand locations.
                    invalidThousandsSeparator = false;
                    if any(numbers==',');
                        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                        if isempty(regexp(numbers, thousandsRegExp, 'once'));
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    % Convert numeric strings to numbers.
                    if ~invalidThousandsSeparator;
                        numbers = textscan(strrep(numbers, ',', ''), '%f');
                        numericData(row, col) = numbers{1};
                        raw{row, col} = numbers{1};
                    end
                catch me
                end
            end
        end

rawNumericColumns = raw(:, [7,8,21]);
rawCellColumns = raw(:, [1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25]);
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%Regarding epistemic curiosity items: Scale and items taken from Litman 2008 paper on Epistemic Curiosity 
%(Items for CFD-P and D-EC), Càd I-Type et D-type (from Diagram of the 10-item 2-factor I/D EC model)
n85responselinkedtonewsdata = table;
n85responselinkedtonewsdata.receivingnews2filename = rawCellColumns(2:end, 1);
n85responselinkedtonewsdata.filename = rawCellColumns(2:end, 2);
n85responselinkedtonewsdata.GMT_timestamp = rawCellColumns(2:end, 3);
n85responselinkedtonewsdata.local_timestamp = rawCellColumns(2:end, 4);
n85responselinkedtonewsdata.id = rawCellColumns(2:end, 5);
n85responselinkedtonewsdata.link = rawCellColumns(2:end, 6);
n85responselinkedtonewsdata.duration = cell2mat(rawNumericColumns(2:end, 1));
n85responselinkedtonewsdata.duration_m = cell2mat(rawNumericColumns(2:end, 2));

%epistemic curiosity items
n85responselinkedtonewsdata.EC_I_type_1 = rawCellColumns(2:end, 7);
n85responselinkedtonewsdata.EC_I_type_2 = rawCellColumns(2:end, 11);
n85responselinkedtonewsdata.EC_I_type_3 = rawCellColumns(2:end, 9);
n85responselinkedtonewsdata.EC_I_type_4 = rawCellColumns(2:end, 15);
n85responselinkedtonewsdata.EC_I_type_5 = rawCellColumns(2:end, 13);
n85responselinkedtonewsdata.EC_D_type_6 = rawCellColumns(2:end, 10);
n85responselinkedtonewsdata.EC_D_type_8 = rawCellColumns(2:end, 8);
n85responselinkedtonewsdata.EC_D_type_7 = rawCellColumns(2:end, 14);
n85responselinkedtonewsdata.EC_D_type_9 = rawCellColumns(2:end, 12);
n85responselinkedtonewsdata.EC_D_type_10 = rawCellColumns(2:end, 16);

temp=(regexprep(rawCellColumns(2:end,7:16),{'Presque jamais','De temps en temps','Souvent','Presque toujours'},{'1', '2', '3', '4'}));
n85responselinkedtonewsdata.EC_I_type_1 = str2num(cell2mat(temp(:,1)));
n85responselinkedtonewsdata.EC_I_type_2 = str2num(cell2mat(temp(:,2)));
n85responselinkedtonewsdata.EC_I_type_3 = str2num(cell2mat(temp(:,3)));
n85responselinkedtonewsdata.EC_I_type_4 = str2num(cell2mat(temp(:,4)));
n85responselinkedtonewsdata.EC_I_type_5 = str2num(cell2mat(temp(:,5)));
n85responselinkedtonewsdata.EC_D_type_6 = str2num(cell2mat(temp(:,6)));
n85responselinkedtonewsdata.EC_D_type_8 = str2num(cell2mat(temp(:,7)));
n85responselinkedtonewsdata.EC_D_type_7 = str2num(cell2mat(temp(:,8)));
n85responselinkedtonewsdata.EC_D_type_9 = str2num(cell2mat(temp(:,9)));
n85responselinkedtonewsdata.EC_D_type_10 = str2num(cell2mat(temp(:,10)));

% %compute EC score
n85responselinkedtonewsdata.EC_score = (n85responselinkedtonewsdata.EC_I_type_1 + ...
n85responselinkedtonewsdata.EC_I_type_2 + n85responselinkedtonewsdata.EC_I_type_3 + ...
n85responselinkedtonewsdata.EC_I_type_4 + n85responselinkedtonewsdata.EC_I_type_5 + ...
n85responselinkedtonewsdata.EC_D_type_6 + n85responselinkedtonewsdata.EC_D_type_7 + ...
n85responselinkedtonewsdata.EC_D_type_8 + n85responselinkedtonewsdata.EC_D_type_9 + ...
n85responselinkedtonewsdata.EC_D_type_10);

%News exposition
n85responselinkedtonewsdata.row15 = rawCellColumns(2:end, 17);
n85responselinkedtonewsdata.row16 = rawCellColumns(2:end, 18);
n85responselinkedtonewsdata.row17 = cell2mat(rawNumericColumns(2:end, 3));

%Strategy during task
n85responselinkedtonewsdata.row19 = rawCellColumns(2:end, 19);
n85responselinkedtonewsdata.row20 = rawCellColumns(2:end, 20);
n85responselinkedtonewsdata.row21 = rawCellColumns(2:end, 21);

%mail
n85responselinkedtonewsdata.row22 = rawCellColumns(2:end, 22);    

% FONCTIONNE. NE PAS TOUCHER
for subject = 1:nbs   
        index = find(strcmp(n85responselinkedtonewsdata.receivingnews2filename(:,1),cellstr(Receivingnews2(subject).info.file)));
        Receivingnews2(subject).questionnaire = n85responselinkedtonewsdata(index,:);
end

clearvars filename endRow fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R allFiles currentFile delimiter formatSpec startRow subject n85responselinkedtonewsdata temp;

%% PROCESS DATA
% Separate orgas eval into each dimension eval, then compute social distance
for subject = 1:nbs
    str = Receivingnews2(subject).organizations.eval(:);
    expression = '\_';
    splitStr = regexp(str,expression,'split');
    
    for org = 1:nbo
        for eval = 1:nbe
            temp(org,eval) = splitStr{org}(eval);
        end
    end
    temp=strrep(temp, 'na', '4'); %replace all NaNs
    Receivingnews2(subject).organizations.Q1_familiarity_self = str2num(cell2mat(temp(:,1)));
    Receivingnews2(subject).organizations.Q2_valuecloseness_self = str2num(cell2mat(temp(:,2)));
    Receivingnews2(subject).organizations.Q3_likeness_self = str2num(cell2mat(temp(:,3)));
    Receivingnews2(subject).organizations.Q4_familiarity_relatives = str2num(cell2mat(temp(:,4)));
    Receivingnews2(subject).organizations.Q5_valuecloseness_relatives = str2num(cell2mat(temp(:,5)));
    Receivingnews2(subject).organizations.Q6_likeness_relatives = str2num(cell2mat(temp(:,6)));
    Receivingnews2(subject).organizations.social_dist = round(((str2num(cell2mat(temp(:,1))) + str2num(cell2mat(temp(:,2))) + str2num(cell2mat(temp(:,3))) + str2num(cell2mat(temp(:,4))) + str2num(cell2mat(temp(:,5))) + str2num(cell2mat(temp(:,6))))*100)/42);
    %cell2mat to go from str array to ordinary array
    %then str2num to turn into numeric and do calculations
    Receivingnews2(subject).organizations = sortrows(Receivingnews2(subject).organizations, 1,'ascend'); %reorganize orga by order
end

clearvars eval expression index org splitStr str subject temp;

% Reorganize subjects data in allSubjects2
clearvars temp
for subject = 1:nbs
    str = Receivingnews2(subject).info.subject;
    id = sscanf(str,'Subject%d');
    allSubjects2(subject,1) = array2table(id);
    allSubjects2(subject,2) = array2table(Receivingnews2(subject).info.subjectGroup);
    clearvars temp
    for orga = 1:nbo
        temp(1,orga) = Receivingnews2(subject).organizations{orga,11};
    end
    allSubjects2(subject,3:14) = array2table(temp(1,1:12));
    clearvars temp;      
end
clearvars temp orga subject;

clearvars temp;
allSubjects2(1:80,15:446)=array2table(zeros(80,432));
for subject = 1:nbs
    allSubjects2(subject,15:9:end) = num2cell(Receivingnews2(subject).news{:,2}');
    temp = table2array(cell2table(Receivingnews2(subject).news{:,10}'));
    for i = 1:length(temp)
        if strcmp(temp(1,i) , 'VRAIE')
            temp2(1,i) = 1;
        else
            temp2 (1,i) = 0;
        end
    end
    allSubjects2(subject,16:9:end) = num2cell(temp2);
    allSubjects2(subject,17:9:end) = Receivingnews2(subject).news{:,3}';
    allSubjects2(subject,18:9:end) = Receivingnews2(subject).news{:,4}';
    allSubjects2(subject,19:9:end) = Receivingnews2(subject).news{:,11}';
    allSubjects2(subject,20:9:end) = Receivingnews2(subject).news{:,5}';
    allSubjects2(subject,21:9:end) = Receivingnews2(subject).news{:,6}';
    allSubjects2(subject,22:9:end) = Receivingnews2(subject).news{:,7}';
    allSubjects2(subject,23:9:end) = Receivingnews2(subject).news{:,8}';
end

allSubjects2(1:80,447:450)=array2table(zeros(80,4));
for subject = 1:nbs
    allSubjects2(subject,447) = num2cell(Receivingnews2(subject).info.age);
    allSubjects2(subject,448) = num2cell(Receivingnews2(subject).info.sex);
    allSubjects2(subject,449) = num2cell(Receivingnews2(subject).info.education);
    allSubjects2(subject,450) = Receivingnews2(subject).questionnaire(1,19);
end

% Rename cols & rows
clearvars varNames;
varNames(1:2) = {'subject', 'group'};
varNames(3:14) = Receivingnews2(1).organizations{1:12,2};
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
varNames(447:450) = {'age', 'sex', 'education', 'EC'};
allSubjects2.Properties.VariableNames = varNames;
for i = 1:80
   Names(1,i) = {(strcat('subject',num2str(i)))};
end
allSubjects2.Properties.RowNames = Names;
clear allNames i j k subject varNames temp temp2 currentFolder id nbe nbo nbe nbstim

%% Save
 clear allFolders allNames currentFolder data eval expression fichier i j k Names nbe nbo nbstim opts org orga splitStr str subject temp temp2 varNames id
 
 cd(strcat(project_root,'/data/intermediate'));
 save Receivingnews2_extracted.mat allSubjects2 Receivingnews2