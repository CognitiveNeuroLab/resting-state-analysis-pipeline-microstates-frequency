clear all
eeglab
len  = 256;
Fs   = 256;
nfft = 512;  %should be power of 2
%noverlap = 0;  %we'll do 50% overlap, better b/c welch uses hamming window

path_1 ='\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\';
group= {'Controls'};

for group_count = 1:length(group)
    if strcmp(group{group_count},'Controls')
        subj = [12632];%only controls id
        skipped_people_no_trigger= [];
        people_no_trigger = [];
    elseif strcmp(group{group_count},'Schiz')
        subj = [12632];
        skipped_people_no_trigger = [];
        people_no_trigger = [];
    elseif strcmp(group{group_count},'22q')
        subj = [12632];
        skipped_people_no_trigger = [];
        people_no_trigger = [];
    end
    
    for subj_count = 1:length(subj)
        path  = [path_1 num2str(subj(subj_count)) '\'];
        EEG = pop_loadset('filename',[num2str(subj(subj_count)) '_inter.set'],'filepath', path );
        %% separate EO from EC
        info = [];
        for i = 1:length(EEG.event)
            if strcmp(EEG.event(i).type, 'boundary') % in there because of manual artefact rejection
                continue
            end
            if isempty(EEG.event(i).edftype)~=1
                info(i,1) = EEG.event(i).edftype;
            elseif isempty(EEG.event(i).type)~=1
                info(i,1) = EEG.event(i).type;
            end
            info(i,2) = EEG.event(i).latency;
        end
        info(info==0) = []; %delete all zeros
        
        if isempty(info)%if there are no triggers, we are going to choose the data ourselves but take less to be safe
            if length(EEG.data) < 161280
                data_EO = EEG.data(:,5120:76801);%skip first 20sec until 300 sec
                data_EC = EEG.data(:,81921:153601); %skip another 20 sec to be safe go untill 600sec
                people_no_trigger = [people_no_trigger, subj(subj_count)];
            else
                skipped_people_no_trigger = [skipped_people_no_trigger, subj(subj_count)]; %saving people that did not have triggers and had too much data
            end
        else
            data_EO = EEG.data(:,info(3):info(4));
            data_EO(:,1:2560)=[];%added to delete first 10 sec
            data_EC = EEG.data(:,info(4):info(4)+(info(4)-info(3)));
            data_EC(:,1:2560)=[];%added to delete first 10 sec
        end
        %% Compute Power
        CPz = 32;
        Pz  = 31;
        Cz  = 48;
        
        [P_EO_CPz freqs] = pwelch(data_EO(CPz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EO_Pz          = pwelch(data_EO(Pz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EO_Cz          = pwelch(data_EO(Cz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_CPz         = pwelch(data_EC(CPz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_Pz          = pwelch(data_EC(Pz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_Cz          = pwelch(data_EC(Cz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        
        PSD_EO_CPzlog(:,subj_count) = 10*log10(P_EO_CPz);
        PSD_EO_Pzlog(:,subj_count)  = 10*log10(P_EO_Pz);
        PSD_EO_Czlog(:,subj_count)  = 10*log10(P_EO_Cz);
        PSD_EC_CPzlog(:,subj_count) = 10*log10(P_EC_CPz);
        PSD_EC_Pzlog(:,subj_count)  = 10*log10(P_EC_Pz);
        PSD_EC_Czlog(:,subj_count)  = 10*log10(P_EC_Cz);
        
    end
    
    if strcmp(group{group_count},'Controls')
        save([path_1 'PSD_EO_CPzlog_ct'], 'PSD_EO_CPzlog')
        save([path_1 'PSD_EO_Pzlog_ct'], 'PSD_EO_Pzlog')
        save([path_1 'PSD_EO_Czlog_ct'], 'PSD_EO_Czlog')
        save([path_1 'PSD_EC_CPzlog_ct'], 'PSD_EC_CPzlog')
        save([path_1 'PSD_EC_Pzlog_ct'], 'PSD_EC_Pzlog')
        save([path_1 'PSD_EC_Czlog_ct'], 'PSD_EC_Czlog')
        save([path_1 'skipped_people_no_trigger_ct'], 'skipped_people_no_trigger')
        save([path_1 'people_no_trigger_ct'], 'people_no_trigger')
    elseif strcmp(group{group_count},'Schiz')
        save([path_1 'PSD_EO_CPzlog_sz'], 'PSD_EO_CPzlog')
        save([path_1 'PSD_EO_Pzlog_sz'], 'PSD_EO_Pzlog')
        save([path_1 'PSD_EO_Czlog_sz'], 'PSD_EO_Czlog')
        save([path_1 'PSD_EC_CPzlog_sz'], 'PSD_EC_CPzlog')
        save([path_1 'PSD_EC_Pzlog_sz'], 'PSD_EC_Pzlog')
        save([path_1 'PSD_EC_Czlog_sz'], 'PSD_EC_Czlog')
        save([path_1 'skipped_people_no_trigger_sz'], 'skipped_people_no_trigger')
        save([path_1 'people_no_trigger_sz'], 'people_no_trigger')
    elseif strcmp(group{group_count},'22q')
        save([path_1 'PSD_EO_CPzlog_22q'], 'PSD_EO_CPzlog')
        save([path_1 'PSD_EO_Pzlog_22q'], 'PSD_EO_Pzlog')
        save([path_1 'PSD_EO_Czlog_22q'], 'PSD_EO_Czlog')
        save([path_1 'PSD_EC_CPzlog_22q'], 'PSD_EC_CPzlog')
        save([path_1 'PSD_EC_Pzlog_22q'], 'PSD_EC_Pzlog')
        save([path_1 'PSD_EC_Czlog_22q'], 'PSD_EC_Czlog')
        save([path_1 'skipped_people_no_trigger_22q'], 'skipped_people_no_trigger')
        save([path_1 'people_no_trigger_22q'], 'people_no_trigger')
    end
    
end

