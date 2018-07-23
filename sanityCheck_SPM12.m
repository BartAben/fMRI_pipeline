%%% Create .mat with regressors names, durations, and onsets.
%%% Next, it specifies a SPM with motor or non-motor related regressors, which
%%% are convolved with HRF. Rp and outlierc regressors are also included.
%%% Finally, relevant contrasts are created.

%%% This script should be saved one level higher than your participant
%%% folders structure. 

%%% Note: the relevant arrays must be named "names", "durations", "onsets", and "pmod".

%%% Bart Aben 10-7-2018

%%
clearvars;

%% Set
subjPrefix =    'PP';
subjects =      31;
task =          'Main'; % 'Main', '1-back'
dataFldr =      'Onsetfiles';
varNames =      {'Left', 'Right', 'Cue'};
funct_nr =      '0006';
funct_pref =    'swraf'; % swraf = realligned, slice timing corrected, normalized, smoothed images

    
%% Get onsets
for s=1:length(subjects)
    taskFile = [num2str(subjects(s)) '_' task '_data'];
    disp([subjPrefix, num2str(subjects(s)) ' ' task ' sanity'])

    subjDir = fullfile(dataFldr, taskFile);
    data = readtable([subjDir '.csv']);

    % Create new colums
    newC = length(varNames);
    data(:,end+1:end+newC) = array2table(NaN(size(data,1), newC));
    data.Properties.VariableNames(end-(newC-1):end) = varNames;

    % Get onsets trials
    data.LEFT(data.Resp==1) = data.stimOnset(data.Resp==1);
    data.RIGHT(data.Resp==2) = data.stimOnset(data.Resp==2);
    data.CUE(data.x_thisN==0) = data.cueOnset(data.x_thisN==0);

    % Select variables
    V = data(:,end-(newC-1):end);

    % Create conditions
    % Names
    names = varNames;
    % Onsets
    for i = 1:3
        temp = table2array(V(:,i));
        temp(isnan(temp)) = []; temp(temp==0) = [];
        onsets{i} = temp;
    end
    % Durations
    durations ={0,0,3};
  
    % Save trials
    subjDir = [subjPrefix num2str(subjects(s))];
    mkdir(fullfile(subjDir, 'sanityCheck'))
    outputName = fullfile(subjDir, 'sanityCheck', ['onsetsSanityCheck_' subjDir '.mat']);
    save(outputName, 'names', 'onsets', 'durations'); %, 'pmod')   
    
%% Specify and estimate design matrix 

    % Initialize
    spm_jobman('initcfg');

    subjDir = [subjPrefix, num2str(subjects(s))];
    
    % Get functional files
    funcFiles = cellstr(spm_get('Files', subjDir, [funct_pref '*-' funct_nr '-*.nii']));
    % Get movement par's and outliers
    rp = dir([subjDir '\art_regression_outliers_and_movement_raf*-0006-*.mat']);
    rp = rp.name;    
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(subjDir, 'sanityCheck')};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = funcFiles;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {outputName};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(subjDir, rp)};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];    
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
 
%% Estimate
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
%% Contrasts
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = '<UNDEFINED>';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'LeftVsRight';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'RightVsLeft';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'MotorVsCue';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0.5 0.5 -1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
%% write and execute batchfile
    batchfilename = ['batch_1stLevel_sanityCheck_' subjDir '.mat']; 
    save(fullfile(subjDir, batchfilename), 'matlabbatch');
    spm_jobman('run', matlabbatch); % Start SPM in case it is not started yet to prevent warning
    clear matlabbatch;
    
end


