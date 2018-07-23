%%% Preprocessing check

%%% Requires conn toolbox: https://www.nitrc.org/projects/conn
%%% This script should be saved one level higher than your participant
%%% folders structure. It saves a conn project file (conn_PreProcCheck.mat
%%% and conn_PreProc folder) in that folder.

%%% Note: art needs subject-motion files to estimate possible outliers. If a 'realignment' 
%%% first-level covariate exists it will load the subject-motion parameters from that first-
%%% level covariate; otherwise it will look for a rp_*.txt file (SPM format) in the same 
%%% folder as the functional data.

%%% Bart Aben 6-7-2018

%%
clearvars;

%% Set
subjPrefix =    'PP';
subjects =      31;
sessions =      2; 
TR =            2;
funct_nr =      {'0006' '0007'};
funct_pref =    'raf'; % raf = realligned, slice timing corrected images
art_thresholds(1) = 5; % threshold value for global-signal (z-value; default 5) 
art_thresholds(2) = .9; % threshold value for subject-motion (mm; default .9)  
% note: the default art_thresholds(1:2) [5 .9] values correspond to the "intermediate" 
% (97th percentile) settings, to use the "conservative" (95th percentile) settings use 
% [3 .5], to use the "liberal" (99th percentile) settings use [9 2] values instead

%% Initialize
BATCH.filename = 'conn_ART.mat';
BATCH.subjects = length(subjects);
BATCH.Setup.isnew = 1;
BATCH.Setup.done = 0;
BATCH.Setup.overwrite =1;

BATCH.Setup.nsubjects = length(subjects);
BATCH.Setup.RT = TR;
BATCH.Setup.acquisitiontype = 1;

%%
for s=1:length(subjects)
    disp([subjPrefix, num2str(subjects(s))])
    for sess = 1: sessions
        subjDir = [subjPrefix, num2str(subjects(s))];
        % functional image files
        funcFiles = dir([subjDir '\' funct_pref '*-' funct_nr{sess} '-*.nii']);
        BATCH.Setup.functionals{s}{sess} = fullfile(subjDir, {funcFiles.name}');
    end
end

BATCH.Setup.preprocessing.steps = 'functional_art'; %functional identification of outlier scans (from motion displacement and global signal changes)
BATCH.Setup.preprocessing.art_thresholds = art_thresholds;

%% write and execute batchfile
batchfilename = ['batch_conn_ART_' subjDir '.mat']; 
save(batchfilename, 'BATCH');
conn_batch(BATCH);
    