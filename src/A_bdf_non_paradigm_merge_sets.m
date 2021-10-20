% Testing the scr code 6/21/2021
% ------------------------------------------------
%% extra controls
clear variables
%_closed.bdf
%_open.bdf
subject_list = {'10399' '12002' '12122'};
%subject_list = {'10158' '10165' '10384' '10407' '10451' '10467' '10501' '10534' '10615' '10620' '10639' '10844' '10956'};
%subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912'};
filename     = 'restingstate'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
home_path    = 'C:\Users\dohorsth\Desktop\Testing restingstate\Remaining_controls\'; %place data is (something like 'C:\data\')
wrongconfig = zeros(1,length(subject_list)); %there are 160channel files that have a wrong config file, this is to save them
for s = 1:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  subject_list{s}  '.bdf'])
    
    %loading file 1, adding triggers
    EEG     = pop_biosig([data_path  subject_list{s}  '_open.bdf']);
    first   = 1; %where the trigger will happen
    second  = 10;
    TRIG    = [first 0; second 50]; %script doesn't like only one trigger so adding 2 (first one can be ignored)
    %%%% Import All events back into the EEG data structure
    EEG     = pop_importevent( EEG, 'event', TRIG, 'fields',{'latency','type'},'timeunit',NaN,'append','no');
    EEG     = pop_editeventvals(EEG,'delete',1); %deleting the extra event
    EEG     = eeg_checkset(EEG);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %loading file 2, adding triggers
    EEG     = pop_biosig([data_path  subject_list{s} '_closed.bdf']);
    first   = 1; %where the trigger will happen
    second  = 10;
    TRIG    = [first 0; second 51]; %script doesn't like only one trigger so adding 2 (first one can be ignored)
    %%%% Import All events back into the EEG data structure
    EEG     = pop_importevent( EEG, 'event', TRIG, 'fields',{'latency','type'},'timeunit',NaN,'append','no');
    EEG     = pop_editeventvals(EEG,'delete',1); %deleting the extra event
    EEG     = eeg_checkset(EEG);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG     = pop_mergeset( ALLEEG, 1:2, 0);%merging into one
    %merging files
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [subject_list{s} ' restingstate non-paradigm'],'gui','off');   %adds a name to the internal .set file
    %some files have been collected with a wrong config file, need to rename the first 64 channels to fit the 160 channel names.
    if strcmp(EEG.chanlocs(1).labels,'Fp1') && strcmp(EEG.chanlocs(65).labels,'C1')
        correct_160_chan={'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'};
        for n=1:64
            EEG.chanlocs(n).labels = correct_160_chan{n};
            wrongconfig(:,s)=string(subject_list(s));
        end
        disp('fixed configuration')
        if strcmp(subject_list{s},'10399') %collected data with 160chn config but only data in 64 ch
            EEG = pop_select( EEG, 'channel',{'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21','B22','B23','B24','B25','B26','B27','B28','B29','B30','B31','B32'});
            correct_64_chan={'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' 'FT7' 'FC5' 'FC3' 'FC1' 'C1' 'C3' 'C5' 'T7' 'TP7' 'CP5' 'CP3' 'CP1' 'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'Fp2' 'AF8' 'AF4' 'AFz' 'Fz' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6' 'FC4' 'FC2' 'FCz' 'Cz' 'C2' 'C4' 'C6' 'T8' 'TP8' 'CP6' 'CP4' 'CP2' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2'};
            for n=1:64
                EEG.chanlocs(n).labels = correct_64_chan{n};
                wrongconfig(:,s)=string(subject_list(s));
            end
        end
        EEG     = eeg_checkset(EEG);
    end
    %save the bdf as a .set file
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end
save([home_path 'participants_with_wrong_config'], 'wrongconfig');

