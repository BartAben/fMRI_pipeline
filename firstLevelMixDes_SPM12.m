%%% Specify and estimate mixed design matrix 

%%% First specifies a SPM  with only block regressors, which have length = 
%%% block duration and are convolved with HRF + time derivatives. Next,
%%% these regressors are included (together with the rp and outlier
%%% regressors) in the second SPM which contains the trial (FIR)
%%% regressors. 
%%% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=SPM;3e5782f7.0806

%%% This script should be saved one level higher than your participant
%%% folders structure. 

%%% Bart Aben 6-7-2018

clearvars;

%% Set
subjPrefix =    'PP';
subjects =      31;
funct_nr =      '0006';
funct_pref =    'swraf'; % swraf = realligned, slice timing corrected, normalized, smoothed images
fir_dur =       20; % length of FIR
fir_nbins =      fir_dur/2; % nr of bins (length/TR

%% Initialize
spm_jobman('initcfg');

%% 1. specify (but not estimate) a design with block regressors

% Specify FIR (block) model
for s=1:length(subjects)
    disp([subjPrefix, num2str(subjects(s))])

    subjDir = [subjPrefix, num2str(subjects(s))];
    
    funcFiles = cellstr(spm_get('Files', subjDir, [funct_pref '*-' funct_nr '-*.nii']));
        
    % Specify batch
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subjDir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = funcFiles;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(cd, subjDir, 'onsetsBlocksMain.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];    
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
 
    % write and execute batchfile
    batchfilename = 'batch_1stLevel_Blocks_' subjDir '.mat']; 

    save(fullfile(subjDir, batchfilename), 'matlabbatch');
    spm_jobman('run', matlabbatch); % Start SPM in case it is not started yet to prevent warning
    clear matlabbatch;

%% 2. retrieve the block regressors from 1 and store them together with rp's and outliers.

    % load block regressors
    load(fullfile(subjDir, 'SPM.mat'))
    blockRegr = SPM.xX.X(:,1:end-1); % load block regressors, exclude constant
    names = [SPM.xX.name(:,1:end-1), 'R1','R2','R3','R4','R5','R6', 'R7']; % must be of equal length as R
    
    % load ART movement parameters and outlier regressors
    rp = dir([subjDir '\art_regression_outliers_and_movement_raf*-0006-*.mat']);
    load(fullfile(subjDir, rp.name));
    
    % Save block and rp regressors in one mat
    R = [blockRegr R];
    save(fullfile(subjDir, 'multiRegr'), 'R', 'names');
    
    % Rename SPM.mat (this prevents dialogbox that asks to overwrite)
    movefile(fullfile(subjDir, 'SPM.mat'), fullfile(subjDir, 'SPM_Block.mat'))

%% 3. Specify FIR for trials and include the regressors from 2. as "multiple regressors"

    % Specify batch 
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subjDir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = funcFiles;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {fullfile(cd, subjDir, 'onsetsTrialsMain.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(subjDir, 'multiRegr.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = fir_dur;
    matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = fir_nbins;
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% 4. Estimate model
    
    % Estimate
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % write and execute batchfile
    batchfilename = ['batch_1stLevel_Mixed_' subjDir '.mat']; 
    save(fullfile(subjDir, batchfilename), 'matlabbatch');
    spm_jobman('run', matlabbatch); % Start SPM in case it is not started yet to prevent warning
    clear matlabbatch;
   
end
