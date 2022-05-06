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
group = { 'Control' '22q' 'schiz'};%
lowpass_filter_hz=50; %50hz filter
highpass_filter_hz=1; %1hz filter
script_location= 'D:\restingstate\scripts\';

for g=1:length(group)
    if strcmp(group{g},'22q')
        subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267' '2270' '2274' '2281' '2284' '2286' '2292' '2295'};
        home_path  = 'D:\restingstate\data\';
    elseif strcmp(group{g},'schiz')
        subject_list = {'7003' '7007' '7019' '7025' '7046' '7049' '7051' '7054' '7058' '7059' '7061' '7064' '7065' '7073' '7075' '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
        home_path  = 'D:\restingstate\data\';
    elseif strcmp(group{g},'Control')
        subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206' '12215' '12272' '12413' '12415' '12449' '12482' '12512' '12588' '12632' '12648' '12651' '12707' '12727' '12739' '12746' '12750' '12755' '12770' '12815' '12852' '12870'};
        home_path  = 'D:\restingstate\data\';
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
        %EEG = pop_clean_rawdata(EEG,
        %'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');%doesn't delete bad periods
        %first at 'BurstCriterion',20, this caused too much data to be
        %deleted, second time at 'BurstCriterion',50, this caused too few data to be
        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',35,'WindowCriterion','off','BurstRejection','on','Distance','Euclidian'); % deletes bad chns and bad periods
        EEG.deleteddata_wboundries=100-EEG.pnts/old_samples*100;
        new_n_chan = EEG.nbchan;
        deleted_sample=EEG.pnts;
        if ~isempty(EEG.event) %at least 1 participant with no events
            %adding one boundary at the end to stop issues, will delete later
            for i=1:length(EEG.event)
                EEG.event(i).time=EEG.event(i).latency/EEG.srate
            end
            EEG.event(length(EEG.event)+1)=EEG.event(length(EEG.event)); EEG.event(length(EEG.event)).type='temp';% EEG.event(length(EEG.event)).latency=EEG.event(length(EEG.event)).latency+100;EEG.event(length(EEG.event)).duration=EEG.event(length(EEG.event)).duration+100;
            for i = length(EEG.event)-1:-1:1%12139 caused issue
                if strcmp(EEG.event(i).type, 'boundary') && strcmp(EEG.event(i+1).type, 'boundary') && EEG.event(i+1).latency/EEG.srate-EEG.event(i).latency/EEG.srate < 2 %following event is also a boundary and less then 2 seconds of "good" data between them
                    disp(i)
                    EEG = pop_select( EEG, 'notime',[EEG.event(i).latency/EEG.srate EEG.event(i+1).latency/EEG.srate] );
                    if strcmp(EEG.event(length(EEG.event)).type, 'boundary')
                        EEG.event(length(EEG.event)+1)=EEG.event(length(EEG.event)); EEG.event(length(EEG.event)).type='temp';
                    end
                end
            end
            EEG.event(length(EEG.event)) = [];
        end
        % deleting the event we added before
        new_samples=EEG.pnts;
        EEG.deleteddata=100-EEG.pnts/old_samples*100;
        deleted_channels(s,:) = [string(subject_list{s}), old_n_chan-new_n_chan] ;
        deleted_data(s,:) = [string(subject_list{s}), new_samples/old_samples*100] ;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    %saving matrixes for quality control
    save([home_path  'wrongconfig_type2_' group{g}], 'wrongconfig_type2');
    save([home_path  'deleted_channels_' group{g}], 'deleted_channels');
    save([home_path  'deleted_data_' group{g}]    , 'deleted_data');
end
