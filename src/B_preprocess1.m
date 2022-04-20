% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% fixing channel names for people with 160 config file with only 64 channels
% downsample
% exclude externals
% 1hz and 50hz filter
% channel info
% exclude channels
% ------------------------------------------------
clear variables
eeglab
group = {'Control' '22q' 'schiz'};%
lowpass_filter_hz=50; %50hz filter
highpass_filter_hz=1; %1hz filter
script_location= 'C:\Users\dohorsth\Documents\GitHub\resting-state-analysis-pipeline-microstates-frequency\src\';
for g=1:length(group)
    if strcmp(group{g},'22q')
        subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1108' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11369' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants
        home_path  = 'D:\Data\';
    elseif strcmp(group{g},'schiz')
        subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
        home_path  = 'D:\Data\';
    elseif strcmp(group{g},'Control')
        subject_list = {'10281'};%'10158' '10165' '10384' '10407' '10451' '10467' '10501' '10534' '10615' '10620' '10639' '10844' '10956' '10033' '10130' '10131' '10257' '10281' '10293' '10360' '10369' '10394' '10438' '10446' '10463' '10476' '10526' '10545' '10561' '10562' '10581' '10585' '10616' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935' '12005' '12007' '12010' '12215' '12328' '12360' '12413' '12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899'};% ------------------------------------------------
        home_path  = 'C:\Users\dohorsth\Desktop\practice\';%'C:\Users\dohorsth\Desktop\Testing restingstate\Remaining_controls\';
    end
    deleted_channels=zeros(length(subject_list),2);
    deleted_data=zeros(length(subject_list),2);
    wrongconfig_type2 = zeros(1,length(subject_list));
    % Loop through all subjects
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\\'];
        % Load original dataset (created by previous script)
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);
        %the following people have had a wrong config file that saved 160 channels even though only 64 have data
        if strcmp(subject_list{s},'1101' ) || strcmp(subject_list{s},'11583')|| strcmp(subject_list{s},'10501')
            EEG = pop_select( EEG, 'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'});
            correct_64_chan={'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' 'FT7' 'FC5' 'FC3' 'FC1' 'C1' 'C3' 'C5' 'T7' 'TP7' 'CP5' 'CP3' 'CP1' 'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'Fp2' 'AF8' 'AF4' 'AFz' 'Fz' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6' 'FC4' 'FC2' 'FCz' 'Cz' 'C2' 'C4' 'C6' 'T8' 'TP8' 'CP6' 'CP4' 'CP2' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2'};
            for n=1:64
                EEG.chanlocs(n).labels = correct_64_chan{n};
                wrongconfig_type2(:,s)=string(subject_list(s));
            end
            disp('fixed configuration')
            EEG     = eeg_checkset(EEG);
        end
        if strcmp(subject_list{s},'12851') %this file was the only mobi BDF file and needs not used channels deleted
            EEG = pop_select( EEG, 'nochannel',{'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'F10' 'F11' 'F12' 'F13' 'F14' 'F15' 'F16' 'F17' 'F18' 'F19' 'F20' 'F21' 'F22' 'F23' 'F24' 'F25' 'F26' 'F27' 'F28' 'F29' 'F30' 'F31' 'F32' 'G1' 'G2' 'G3' 'G4' 'G5' 'G6' 'G7' 'G8' 'G9' 'G10' 'G11' 'G12' 'G13' 'G14' 'G15' 'G16' 'G17' 'G18' 'G19' 'G20' 'G21' 'G22' 'G23' 'G24' 'G25' 'G26' 'G27' 'G28' 'G29' 'G30' 'G31' 'G32' 'H1' 'H2' 'H3' 'H4' 'H5' 'H6' 'H7' 'H8' 'H9' 'H10' 'H11' 'H12' 'H13' 'H14' 'H15' 'H16' 'H17' 'H18' 'H19' 'H20' 'H21' 'H22' 'H23' 'H24' 'H25' 'H26' 'H27' 'H28' 'H29' 'H30' 'H31' 'H32' 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7' 'EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
        end
        EEG = eeg_checkset( EEG );
        %downsample
        EEG = pop_resample( EEG, 256); %downsample to 256hz
        EEG = eeg_checkset( EEG );
        %deleting externals
        EEG = pop_select( EEG,'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exext.set'],'filepath', data_path);
        %filtering
        EEG.filter=table(lowpass_filter_hz,highpass_filter_hz); %adding it to subject EEG file
        EEG = pop_eegfiltnew(EEG, 'locutoff',highpass_filter_hz);
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass_filter_hz);
        close all
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_downft.set'],'filepath', data_path);
        EEG = pop_editset(EEG, 'chanlocs', [script_location  'Functions and files\BioSemi64.sfp']); %need to first load any sort of sfp file with the correct channels (the locations will be overwritten to the correct ones later)
        %adding channel location
        EEG=pop_chanedit(EEG, 'lookup',[fileparts(which('eeglab')) '\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp']); %make sure you put here the location of this file for your computer
        
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_info.set'],'filepath', data_path);
        old_n_chan = EEG.nbchan;
        old_samples=EEG.pnts;
        %old way, only channel rejection - used for Aging and ASD:
        %EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','on','Distance','Euclidian');
        %new way, also bad data (bursts) rejection:
        % the only thing to double check is if it will still reject eye
        % components in ICA or if these are pre-deleted now (which they shouldn't)
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
        new_n_chan = EEG.nbchan;
        new_samples=EEG.pnts;
        deleted_channels(s,:) = [string(subject_list{s}), old_n_chan-new_n_chan] ;
        deleted_data(s,:) = [string(subject_list{s}), new_samples/old_samples*100] ;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    %saving matrixes for quality control
    save([home_path  'wrongconfig_type2_' group{g}], 'wrongconfig_type2');
    save([home_path  'deleted_channels_' group{g}], 'deleted_channels');
    save([home_path  'deleted_data_' group{g}]    , 'deleted_data');
end
