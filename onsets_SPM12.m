%%% Create .mat with regressors names, durations, and onsets.

%%% This script should be saved one level higher than your participant
%%% folders structure. 

%%% Note: the relevant arrays must be named "names", "durations", "onsets", and "pmod".

%%% Bart Aben 6-7-2018

%%
clearvars;

%% Set
subjPrefix =    'PP';
subjects =  31;
task =      'Main'; % 'Main', '1-back'
dataFldr =  'Onsetfiles';
varNames =  {'FaceLowEffTr','FaceHighEffTr','HouseLowEffTr','HouseHighEffTr', ... % tr = trial, bl = block
            'FaceLowEffBl','FaceHighEffBl','HouseLowEffBl','HouseHighEffBl', ...
            'FaceLowEffBl_Dur','FaceHighEffBl_Dur','HouseLowEffBl_Dur','HouseHighEffBl_Dur', ...
            'FaceLowEff_Par','FaceHighEff_Par','HouseLowEff_Par','HouseHighEff_Par'};

%% Get onsets
for s=1:length(subjects)
    taskFile = [num2str(subjects(s)) '_' task '_data'];
    disp([subjPrefix, num2str(subjects(s)) ' ' task])

    subjDir = fullfile(dataFldr, taskFile);
    data = readtable([subjDir '.csv']);

    % Get P values from targetIm name
    token = extractBefore(data.targetIm, '.');
    token =  extractAfter(token, '_');
    token =  str2double(extractAfter(token, '_'));
    data.par = token;

    % Create new colums
    newC = length(varNames);
    data(:,end+1:end+newC) = array2table(NaN(size(data,1), newC));
    data.Properties.VariableNames(end-(newC-1):end) = varNames;

    % Get onsets trials
    data.F_LE_tr(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff'));
    data.F_HE_tr(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff'));
    data.H_LE_tr(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff'));
    data.H_HE_tr(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff'));
    % Get onsets blocks
    data.F_LE_bl(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')&data.x_thisN==0);
    data.F_HE_bl(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')&data.x_thisN==0);
    data.H_LE_bl(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')&data.x_thisN==0);
    data.H_HE_bl(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')&data.x_thisN==0);
    % Get durations blocks
    data.F_LE_bl_dur(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')&data.x_thisN==17)-...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')&data.x_thisN==0);
    data.F_HE_bl_dur(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')&data.x_thisN==17)-...
        data.stimOnset(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')&data.x_thisN==0);
    data.H_LE_bl_dur(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')&data.x_thisN==17)-...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')&data.x_thisN==0);
    data.H_HE_bl_dur(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')&data.x_thisN==0) = ...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')&data.x_thisN==17)-...
        data.stimOnset(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')&data.x_thisN==0);
    % Get par values
    data.F_LE_par(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff')) = ...
        data.par(strcmp(data.Task,'F')&strcmp(data.Block, 'LowEff'));
    data.F_HE_par(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff')) = ...
        data.par(strcmp(data.Task,'F')&strcmp(data.Block, 'HighEff'));
    data.H_LE_par(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff')) = ...
        data.par(strcmp(data.Task,'H')&strcmp(data.Block, 'LowEff'));
    data.H_HE_par(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff')) = ...
        data.par(strcmp(data.Task,'H')&strcmp(data.Block, 'HighEff'));

    % Select variables
    V = data(:,end-(newC-1):end);

    % Create conditions
    % Names
    names_temp = varNames(1:end-8); % Exclude durs and pars
    % Onsets
    for i = 1:8
        temp = table2array(V(:,i));
        temp(isnan(temp)) = []; temp(temp==0) = [];
        onsets_temp{i} = temp;
    end
    % Durations
    durations_temp ={0,0,0,0};
    for i = 1:4  
        temp = table2array(V(:,8+i));
        temp(isnan(temp)) = []; temp(temp==0) = [];
        durations_temp{4+i} = temp;
    end
    % Parametric modulators (see Specification module for explanation)
    pmod = struct('name',{''},'param',{},'poly',{}); % Empty structure
    for i = 1:4
        pmod(i).name{1} = names_temp{i}; % get trial names
        temp = table2array(V(:,12+i));
        temp(isnan(temp)) = [];
        pmod(i).param{1} = temp-mean(temp); % col mean centered
        pmod(i).poly{1} = 1;
    end
    
    % Save trials
    names = names_temp(1:4); onsets = onsets_temp(1:4); durations= durations_temp(1:4);
    outputTrName = fullfile([subjPrefix num2str(subjects(s))], ['onsetsTrials_' task '_' subjDir '.mat']);
    save(outputTrName, 'names', 'onsets', 'durations'); %, 'pmod')   
    
    % Save blocks
    names = names_temp(5:8); onsets = onsets_temp(5:8); durations = durations_temp(5:8);
    outputBlName = fullfile([subjPrefix num2str(subjects(s))], ['onsetsBlocks_' task '_' subjDir '.mat']);
    save(outputBlName, 'names', 'onsets', 'durations'); %, 'pmod')   
    
end


