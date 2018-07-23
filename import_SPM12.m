%%% Import DICOM (*.ima) files (i.e., convert to NIFTI (*.nii)).
%%% Rename NIFTI files.
%%% This script should be saved one level higher than your participant
%%% folders structure.

%%% Bart Aben 4-7-2018

clearvars;

%% Set
subjPrefix = 'PP';
subjects= 31;

%% Specify file locations
homeDir = cd;
for s=1:length(subjects)
    
    subjDir = [subjPrefix, num2str(subjects(s))];
    
    % Get datapaths
    dataPath={};
    dataPath{1}= fullfile(subjDir,'DICOM','LOCALIZER_0001'); % Localizer
    dataPath{2}= fullfile(subjDir,'DICOM','T1_MPRAGE_0002'); % Structural
    dataPath{3}= fullfile(subjDir,'DICOM','FIELDMAP_SIEMENS_0003'); % Fieldmap magnitude
    dataPath{4}= fullfile(subjDir,'DICOM','FIELDMAP_SIEMENS_0004'); % Fieldmap phase
    % The following are reversed for PP31:
    dataPath{5}= fullfile(subjDir,'DICOM','EP2D_1_BACK_0006'); % Functional main
    dataPath{6}= fullfile(subjDir,'DICOM','EP2D_MAIN_EFFORT_0007'); % Functional 1-back

    % Define output directories
    outPut = {};
    outPut{1} = fullfile(subjDir, 'localizer'); 
    outPut{2} = fullfile(subjDir);
    outPut{3} = fullfile(subjDir, 'fieldmap0003');
    outPut{4} = fullfile(subjDir, 'fieldmap0004'); 
    outPut{5} = fullfile(subjDir);
    outPut{6} = fullfile(subjDir);
    
    for i = 1:length(dataPath)
        
        disp(dataPath{i});

        % Create output directory
        mkdir(outPut{i});
        
        % Get datafiles
        files= spm_get('Files',dataPath{i},'*.IMA');
        
        % Create import batch
        matlabbatch{1}.spm.util.import.dicom.data = cellstr(files);
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = outPut(i);
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        
        % Write jobfile
        batchfilename = [outPut{i} '\batch_import' subjDir '.mat']; 
        save(batchfilename, 'matlabbatch');

        % Execute it
        spm_jobman('run', matlabbatch);
        clear matlabbatch;

    end
    
    %% Change file names (replace QP number with PPnr)
    for j = 1:length(unique(outPut))
        cd(outPut{j});
        oldFiles  = dir('*.nii');
        for f = 1:length(oldFiles)
            prefix = oldFiles(f).name(1);
            QP = strtok(oldFiles(f).name,'-'); % Get QP part
            newFile = [prefix strrep(oldFiles(f).name, QP, subjDir)]; % Replace QP part with PPnr
            movefile(oldFiles(f).name, newFile); % Change file name
        end
    cd(homeDir);
    end

end



