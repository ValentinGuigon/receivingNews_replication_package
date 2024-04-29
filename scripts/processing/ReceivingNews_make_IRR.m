clear
clc
close all

% IRR stands for Intra-Rater Reliability

%% VARIABLES

project_root = strrep(pwd(), '\', '/');

cd(strcat(project_root,'/data/processed'));

load ReceivingNews_tables

addpath(genpath(strcat(project_root,'/matlab_toolboxes/MATLAB Tools')))

nbs = 80; %nb sujets
nbo = 12; %nb_organisations
nbe = 6; %nb_evaluations
nbstim = 48; %nb_stimuli


%% ICC
idnews = ICC.idnews;

jj=1; kk=1; ll=1; mm=1; nn=1;
for ii = 1:length(idnews)
    if IRR(1).stims(IRR(1).stims == idnews(ii),:)
        IRR1_ambig(jj,:) = IRR(1).ambiguity(IRR(1).stims == idnews(ii),1:11);
        IRR1_split(jj,:) = IRR(1).split(IRR(1).stims == idnews(ii),1:11);
        IRR1_desir(jj,:) = IRR(1).desirability(IRR(1).stims == idnews(ii),1:11);
        jj=jj+1;
    end
    if IRR(2).stims(IRR(2).stims == idnews(ii),:)
        IRR2_ambig(kk,:) = IRR(2).ambiguity(IRR(2).stims == idnews(ii),1:10);
        IRR2_split(kk,:) = IRR(2).split(IRR(2).stims == idnews(ii),1:10);
        IRR2_desir(kk,:) = IRR(2).desirability(IRR(2).stims == idnews(ii),1:10);
        kk=kk+1;
    end
    if IRR(3).stims(IRR(3).stims == idnews(ii),:)
        IRR3_ambig(ll,:) = IRR(3).ambiguity(IRR(3).stims == idnews(ii),1:11);
        IRR3_split(ll,:) = IRR(3).split(IRR(3).stims == idnews(ii),1:11);
        IRR3_desir(ll,:) = IRR(3).desirability(IRR(3).stims == idnews(ii),1:11);
        ll=ll+1;
    end
    if IRR(4).stims(IRR(4).stims == idnews(ii),:)
        IRR4_ambig(mm,:) = IRR(4).ambiguity(IRR(4).stims == idnews(ii),1:11);
        IRR4_split(mm,:) = IRR(4).split(IRR(4).stims == idnews(ii),1:11);
        IRR4_desir(mm,:) = IRR(4).desirability(IRR(4).stims == idnews(ii),1:11);
        mm=mm+1;
    end
    if IRR(5).stims(IRR(5).stims == idnews(ii),:)
        IRR5_ambig(nn,:) = IRR(5).ambiguity(IRR(5).stims == idnews(ii),1:10);
        IRR5_split(nn,:) = IRR(5).split(IRR(5).stims == idnews(ii),1:10);
        IRR5_desir(nn,:) = IRR(5).desirability(IRR(5).stims == idnews(ii),1:10);
        nn=nn+1;
    end
end

IRR_ambig = [IRR1_ambig; IRR2_ambig NaN(length(IRR2_ambig),1,'single'); IRR3_ambig; IRR4_ambig; IRR5_ambig NaN(length(IRR5_ambig),1,'single')];
IRR_split = [IRR1_split; IRR2_split NaN(length(IRR2_split),1,'single'); IRR3_split; IRR4_split; IRR5_split NaN(length(IRR5_split),1,'single')];
IRR_desir = [IRR1_desir; IRR2_desir NaN(length(IRR2_desir),1,'single'); IRR3_desir; IRR4_desir; IRR5_desir NaN(length(IRR5_desir),1,'single')];

ICC.Properties.VariableNames(5) = {'imprecision'};

%% SAVE

cd(strcat(project_root,'/data/processed'));
clearvars -except allSubAllTrial ICC IRR IRR_ambig IRR_desir IRR_split
save('ReceivingNews_IRR.mat','-v6')
writetable(ICC, 'ICC.csv')