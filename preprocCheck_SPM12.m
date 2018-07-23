%%% Preprocessing check

%%% Requires conn toolbox: https://www.nitrc.org/projects/conn
%%% This script should be saved one level higher than your participant
%%% folders structure. It saves a conn project file (conn_PreProcCheck.mat
%%% and conn_PreProc folder) in that folder.

%%% Bart Aben 6-7-2018

%%
clearvars;

%% Set
subjPrefix =    'PP';
subjects =      31;
sessions =      2; 
TR =            2;
funct_nr =      {'0006' '0007'};
funct_pref =    'swraf';
struct_pref =   'wms';

%% Initialize
BATCH.filename = 'conn_PreProcCheck.mat';
BATCH.subjects = length(subjects);
BATCH.Setup.isnew = 1;
BATCH.Setup.done = 0;
BATCH.Setup.overwrite =1;

BATCH.Setup.nsubjects = length(subjects);
BATCH.Setup.RT = TR;
BATCH.Setup.acquisitiontype = 1;
BATCH.Setup.covariates.names{1} = 'Movement parameters';
BATCH.Setup.covariates.add = 0;

%% Setup
for s=1:length(subjects)
    disp([subjPrefix, num2str(subjects(s))])
    for sess = 1: sessions
        subjDir = [subjPrefix, num2str(subjects(s))];
        % functional image files
        BATCH.Setup.functionals{s}{sess} = cellstr(spm_get('Files', subjDir, [funct_pref '*-' funct_nr{sess} '-*.nii']));
        % movement parameters
        BATCH.Setup.covariates.files{1}{s}{sess} = cellstr(spm_get('Files', subjDir, ['rp*' funct_nr{sess} '*.txt'])); 
    end
        % structural image file
        BATCH.Setup.structurals{s} = cellstr(spm_get('Files', subjDir, [struct_pref '*-0002-00001-000176-*.nii'])); 
end

%% write and execut batchfile
batchfilename = ['batch_conn_preprocCheck_' subjDir '.mat']; 
save(batchfilename, 'BATCH');
conn_batch(BATCH);
    