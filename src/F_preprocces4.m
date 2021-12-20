% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% this scripts interpolates channels using the _info.set file and the _clean.set file. It
% creates a matrix with all the previously deleted channels. If a
% particpant has 160 channels, their data gets interpolated to 64 channels
% Created by Douwe Horsthuis 
clear variables
eeglab
close all
Group = {'ASD' 'Control' 'Aging'};%'Control'
name_paradigm = 'restingstate'; % this is needed for saving the table at the end
function_folder = 'C:\Users\dohorsth\Documents\GitHub\resting-state-analysis-pipeline-microstates-frequency\src\Functions and files\';
for g=1:length(Group)
    switch Group{g}
        case 'Control'
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Control\';
            subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
        case 'ASD'
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\ASD\';
            subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants;
        case 'Aging'
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Aging\';
            subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
    end
    
    participant_badchan = string(zeros(length(subject_list), 5)); %prealocationg space for speed
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        clear labels_all labels_good lables_del data_subj
        data_path  = [home_path subject_list{s} ''];% Path to the folder containing the current subject's data
        % Load original dataset
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEGinter = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);%loading participant file with 64 channels
        %saving the original amount of total channels
        labels_all = {EEGinter.chanlocs.labels}.'; %stores all the labels in a new matrix
        %interpolating the 160channels to 64 channels
        if EEGinter.nbchan>159 %this will transform all the 160 channel data into 64 channel data
            EEG = pop_loadset('filename', [subject_list{s} '_clean.set'], 'filepath', data_path); %loads latest pre-proc file
            labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the _clean file
            EEG_temp = pop_loadset('filename', '64.set', 'filepath', home_path);
            %need to interpolate first so that we are sure everyone has their full 160ch
            EEG = pop_interp(EEG, EEGinter.chanlocs, 'spherical');
            for b=1:EEG.nbchan
                if strcmp(EEG.chanlocs(b).labels,'b32')
                    EEG.chanlocs(b).labels = 'B32'; %the channel location file used to have a typo (b32 instead of B32)
                end
            end
            oldFolder = cd; %this is where the function should be
            cd(function_folder)
            % using the transform_n_channels function to change 160ch data into 64 channel
            EEG = transform_n_channels(EEG,EEG_temp.chanlocs,64,'keep');
            %this deletes the channel location, so we add it back
            EEG = pop_editset(EEG, 'chanlocs', [home_path 'BioSemi64.sfp']); %need to first load any sort of sfp file with the correct channels (the locations will be overwritten to the correct ones later)
            EEG=pop_chanedit(EEG, 'lookup',[home_path 'standard-10-5-cap385.elp']); %make sure you put here the location of this file for your computer
            cd(oldFolder)
        else
            %interpolating for 64 channels
            EEG = pop_loadset('filename', [subject_list{s} '_clean.set'], 'filepath', data_path); %loads latest pre-proc file
            labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
            disp(EEG.nbchan); %writes down how many channels are there
            EEG = pop_interp(EEG, EEGinter.chanlocs, 'spherical');%interpolates the data
        end
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_inter.set'], 'filepath', data_path); %saves data
        disp(EEG.nbchan)
        %this part saves all the bad channels + ID numbers
        lables_del                 = setdiff(labels_all,labels_good); %only stores the deleted channels
        All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings
        ID                         = string(subject_list{s});%keeps all the IDs
        data_subj                  = [ID, length(lables_del),EEGinter.nbchan, All_bad_chan, EEG.nbchan]; %combines IDs and Bad channels, total channels at the end
        participant_badchan(s,:)   = data_subj;%combine new data with old data
        clear EEG_temp EEGinter
    end
    save([home_path  'participant_interpolation_info_' Group{g}], 'participant_badchan');
end