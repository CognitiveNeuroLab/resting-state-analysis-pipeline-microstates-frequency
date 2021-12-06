% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% Merging script to create .set file from MoBI particpant.
% Base file is .XDF not .BDF needs extra EEGLAB plugin
% ----------------------
subject_list = {'12851'};%{'12856' '12857' '12859' '12871' '12872' '12892'};%'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'   }; %all the IDs for the indivual particpants
filename     = 'Resting_State'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
home_path    = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\MoBI\'; %place data is (something like 'C:\data\')
blocks       = 1; % the amount of BDF files. if different participant have different amounts of blocks, run those participant separate
for s = 1:length(subject_list) %12376 might be 13
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  filename '.xdf'])
    
    EEG  = pop_loadxdf([data_path filename  '.xdf'] , 'streamtype', 'EEG', 'exclude_markerstreams', {});
    temp      = EEG.data;
    EEG.data  = temp([2:65],:);   % This should work for a 64 cap
    triggers  = temp(1,:);                % triggers
    triggers  = double(triggers - temp(1,1)); % take first sample and substract from time series to create zero-baseline
    ind     = find(triggers > 40); % this should work to ID triggers send for starting presentation and for starting eyes closed block
    first   = ind(1);
    second  = ind(end);
    % Create event structure
    TRIG    = [first 50; second 51];%these are the same numbers as the paradigm has
    %%%% Import All events back into the EEG data structure
    EEG     = pop_importevent( EEG, 'event', TRIG, 'fields',{'latency','type'},'timeunit',NaN,'append','no');
    EEG     = eeg_checkset(EEG);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [subject_list{s} ' restingstate'],'gui','off');   %adds a name to the internal .set file
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end

