%%%%%
% Formerly a script for computing IntraClass Correlation Coefficients
% ICC has been chosen according to Koo and Li, 2016 - A guideline of selecting and reporting intraclass correlation coefficients for reliability research
% Now ICC is not computed anymore (commented lines)
%%%%%

clear
clc

%% Variables

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/stimuli'));
currentFolder = strcat(pwd,'/');

%% Setup the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 12);
opts.Sheet = "Feuil3";
opts.DataRange = "A2:L43";
opts.VariableTypes = ["double", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char", "char"];

opts.VariableNames = ["Stimulus", "Sujet5", "Sujet9", "Sujet13", "Sujet19", "Sujet20", "Sujet27", "Sujet29", "Sujet37", "Sujet41", "Sujet45", "Sujet49"];
IRRG1 = readtable(strcat(currentFolder, "stimuli_excel_for_IRR_G1.xlsx"), opts, "UseExcel", false);

opts.VariableNames = ["Stimulus", "Sujet4",	"Sujet6", "Sujet12", "Sujet17", "Sujet23", "Sujet25", "Sujet33", "Sujet38", "Sujet42", "Sujet44", "Sujet51"];
IRRG2 = readtable(strcat(currentFolder, "stimuli_excel_for_IRR_G2.xlsx"), opts, "UseExcel", false);
% get rid of sujet17, that responded 5_5_5 everytime
IRRG2.Sujet17=[];

opts.VariableNames = ["Stimulus", "Sujet2",	"Sujet7", "Sujet14", "Sujet18", "Sujet21", "Sujet26", "Sujet30", "Sujet35", "Sujet43", "Sujet47", "Sujet50", "Sujet55"];
IRRG3 = readtable(strcat(currentFolder, "stimuli_excel_for_IRR_G3.xlsx"), opts, "UseExcel", false);
% get rid of sujet18, that responded 5_5_5 everytime
IRRG3.Sujet18=[];

opts.VariableNames = ["Stimulus", "Sujet1",	"Sujet10", "Sujet15", "Sujet24", "Sujet28", "Sujet31", "Sujet36", "Sujet39", "Sujet46", "Sujet53", "Sujet54"];
IRRG4 = readtable(strcat(currentFolder, "stimuli_excel_for_IRR_G4.xlsx"), opts, "UseExcel", false);

opts.VariableNames = ["Stimulus", "Sujet3",	"Sujet8", "Sujet11", "Sujet16", "Sujet22", "Sujet32", "Sujet34", "Sujet40", "Sujet48", "Sujet52"];
IRRG5 = readtable(strcat(currentFolder, "stimuli_excel_for_IRR_G5.xlsx"), opts, "UseExcel", false);

%% Clear temporary variables
clear opts

%% ICC for All stims

stimsG1 = [1 2 5 9 31 39 42 51 57 68 69 72 74 83 88 89 91 100 103 106 113 121 135 137 142 150 152 153 154 158 160 162 173 175 181 188 189 197 198 200 204 210];
stimsG2 = [3 22 30 40 49 56 60 65 67 75 96 98 108 109 111 112 114 119 122 123 126 127 128 131 133 136 140 141 143 145 146 147 167 169 172 174 183 185 194 196 207 208];
stimsG3 = [11 16 17 19 20 23 28 29 34 41 43 44 47 52 70 73 76 85 87 105 110 117 118 120 124 125 129 139 151 163 164 166 168 176 177 182 186 187 191 192 195 202];
stimsG4 = [7 10 12 14 18 26 27 45 54 55 58 59 63 77  79 82 84 86 92 93 94 97 101 102 104 107 115 130 132 134 138 155 157 161 165 171 178 179 190 193 201 205];
stimsG5 = [4 6 8 13 15 21 24 25 32 33 35 36 37 38 46 48 50 53 61 62 64 66 71 78 80 81 90 95 99 116 144 148 149 156 159 170 180 184 199 203 206 209 ];

IRR(1).type = 'stimsG1'; IRR(1).stims = stimsG1'; IRR(1).matrices = IRRG1;
IRR(2).type = 'stimsG2'; IRR(2).stims = stimsG2'; IRR(2).matrices = IRRG2;
IRR(3).type = 'stimsG3'; IRR(3).stims = stimsG3'; IRR(3).matrices = IRRG3;
IRR(4).type = 'stimsG4'; IRR(4).stims = stimsG4'; IRR(4).matrices = IRRG4;
IRR(5).type = 'stimsG5'; IRR(5).stims = stimsG5'; IRR(5).matrices = IRRG5;
clear IRRG1 IRRG2 IRRG3 IRRG4 IRRG5

for ii = 1:5
    for jj = 1:length(IRR(ii).stims(:,1))
        for kk = 1:width(IRR(ii).matrices(1,:))-1
            tmp = split(IRR(ii).matrices{jj,kk+1},"_");
            amb(jj,kk) = str2num(cell2mat(tmp(1)));
            spl(jj,kk) = str2num(cell2mat(tmp(2)));
            des(jj,kk) = str2num(cell2mat(tmp(3)));
        end
    end
        IRR(ii).ambiguity = amb; IRR(ii).split = spl; IRR(ii).desirability = des; 
    for jj = 1:length(IRR(ii).stims(:,1))
        IRR(ii).ambiguity(jj,width(IRR(ii).matrices(1,:))) = mean(amb(jj,1:size(amb,2))); % ambiguity
        IRR(ii).split(jj,width(IRR(ii).matrices(1,:))) = mean(spl(jj,1:size(amb,2))); % split
        IRR(ii).desirability(jj,width(IRR(ii).matrices(1,:))) = mean(des(jj,1:size(amb,2))); % desirability
    end
    %if ii < 5
        clear amb spl des
    %end
end

% We add the column 'consensuality', that is the inverse of split
for ii=1:5
    IRR(ii).consensuality = 10 - IRR(ii).split;
end


%% Save

cd(strcat(project_root,'/data/stimuli'));
clearvars -except IRR
save News_evaluations