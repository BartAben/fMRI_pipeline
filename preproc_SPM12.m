%%% Preprocessing pipeline
%%% * slice timing correction
%%% * realign
%%% * coregister
%%% * segment
%%% * normalize
%%% * smooth
%%% This script should be saved one level higher than your participant
%%% folders structure.

%%% Bart Aben 4-7-2018

clearvars;

%% Set
subjPrefix =    'PP';
subjects=       31;
nSlices =       38;
TR =            2; % seconds
TA =            TR-(TR/nSlices); % time between first and last slice
% CHECK THE PROTOCOL! %
% SPM assumes aquisition from foot to head
hdr = spm_dicom_headers('F:\SPM_Effort\PP31\DICOM\EP2D_MAIN_EFFORT_0007\GIFMI_STU18_018_PP31_.MR.GIFMI_DEFAULT_SEQUENCES_BRAIN_LOCALIZERS.0007.0001.2018.06.29.12.55.05.288411.27959895.ima');
slice_times = hdr{1,1}.Private_0019_1029; % Slice order in ms
SO =            [2:2:nSlices 1:2:nSlices]; % interleaved (bottom -> up, starting with even)
%%%%%%%%%%%%%%%%%%%%%%%
refSlice =      nSlices/2;

%% Initalize
spm_jobman('initcfg');
spm_figure('GetWin','Graphics'); % Make sure spm graphics window is open, otherwise no .ps files will be saved

%%
for s=1:length(subjects)
    
    disp([subjPrefix, num2str(subjects(s))])
    subjDir = [subjPrefix num2str(subjects(s))];

    % functional image files
    functImages1 = {cellstr(spm_get('Files', subjDir, 'f*-0006-*.nii'))}; % 2 RUNS!
    functImages2 = {cellstr(spm_get('Files', subjDir, 'f*-0007-*.nii'))};        
    % structural image file
    structImage = {spm_get('Files', subjDir, 's*-0002-00001-000176-*.nii')}; 
 
    matlabbatch = {}; 
    
    %% slice timing correction
    matlabbatch{1}.spm.temporal.st.scans(1) = functImages1; %{cellstr(construct_list(fullDir, subjFiles1, '', 1))};
    matlabbatch{1}.spm.temporal.st.scans(2) = functImages2; %{cellstr(construct_list(fullDir, subjFiles2, '', 1))};
    matlabbatch{1}.spm.temporal.st.nslices = nSlices;
    matlabbatch{1}.spm.temporal.st.tr = TR;
    matlabbatch{1}.spm.temporal.st.ta = TA;
    matlabbatch{1}.spm.temporal.st.so = SO; 
    matlabbatch{1}.spm.temporal.st.refslice = refSlice;
    matlabbatch{1}.spm.temporal.st.prefix = 'a';
    
%     % realign and unwarp
%     spm_figure('GetWin','Graphics') % Make sure spm graphics window is open, otherwise no .ps files will be saved
%     matlabbatch{2}.spm.spatial.realignunwarp.data(1).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files')); % 2 RUNS !!
%     matlabbatch{2}.spm.spatial.realignunwarp.data(1).pmscan(1) = SourceImageFM1;
%     matlabbatch{2}.spm.spatial.realignunwarp.data(2).scans(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files')); % 2 RUNS !!
%     matlabbatch{2}.spm.spatial.realignunwarp.data(2).pmscan(1) = SourceImageFM2;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.sep = 4;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.rtm = 0;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.einterp = 2;
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
%     matlabbatch{2}.spm.spatial.realignunwarp.eoptions.weight = '';
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.jm = 0;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.sot = [];
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.rem = 1;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.noi = 5;
%     matlabbatch{2}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
%     matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
%     matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
%     matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
%     matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.mask = 1;
%     matlabbatch{2}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
    
    %% realgin: estimate & write
    matlabbatch{2}.spm.spatial.realign.estwrite.data = {
        cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)',...
        substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'))...
        cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)',...
        substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files')) % 2 RUNS !!
                                                        }';
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 0; % register to first image
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    %% coregister
    matlabbatch{3}.spm.spatial.coreg.estimate.ref = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
    matlabbatch{3}.spm.spatial.coreg.estimate.source = structImage;
    matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
%     matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.interp = 2;
%     matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
%     matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.mask = 0;
%     matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.prefix = 'c';
    
    %% segment
    matlabbatch{4}.spm.spatial.preproc.channel.vols(1) = structImage; %cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));    matlabbatch{4}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{4}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{4}.spm.spatial.preproc.tissue(1).tpm = {'C:\SPM\spm12\tpm\TPM.nii,1'};
    matlabbatch{4}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{4}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(2).tpm = {'C:\SPM\spm12\tpm\TPM.nii,2'};
    matlabbatch{4}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{4}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(3).tpm = {'C:\SPM\spm12\tpm\TPM.nii,3'};
    matlabbatch{4}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{4}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(4).tpm = {'C:\SPM\spm12\tpm\TPM.nii,4'};
    matlabbatch{4}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{4}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(5).tpm = {'C:\SPM\spm12\tpm\TPM.nii,5'};
    matlabbatch{4}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{4}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(6).tpm = {'C:\SPM\spm12\tpm\TPM.nii,6'};
    matlabbatch{4}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{4}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{4}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{4}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{4}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{4}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{4}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{4}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{4}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{4}.spm.spatial.preproc.warp.write = [0 1];              % FORWARD DEFORMATION IS NEEDED TO NORMALISE IMAGES TO MNI SPACE
    
    %% normalise
    matlabbatch{5}.spm.spatial.normalise.write.subj(1).def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{5}.spm.spatial.normalise.write.subj(1).resample(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{5}.spm.spatial.normalise.write.subj(1).resample(2) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','rfiles'));    
    % Normalize bias corrected structural:
    matlabbatch{5}.spm.spatial.normalise.write.subj(2).def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{5}.spm.spatial.normalise.write.subj(2).resample(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
    matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70 
                                                          78 76 85];
    matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;
    
    %% smooth
    matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];       % CHANGED FROM [8 8 8]
    matlabbatch{6}.spm.spatial.smooth.dtype = 0;
    matlabbatch{6}.spm.spatial.smooth.im = 0;
    matlabbatch{6}.spm.spatial.smooth.prefix = 's';
    
    %% write and execute jobfile
    batchfilename = [subjDir '\batch_preproc_' subjDir '.mat']; 
    save(batchfilename, 'matlabbatch');
    spm_jobman('run', matlabbatch);

end