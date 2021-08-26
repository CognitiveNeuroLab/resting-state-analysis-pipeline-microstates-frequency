clear variables
eeglab
len  = 256;
Fs   = 256;
nfft = 512;  %should be power of 2
%noverlap = 0;  %we'll do 50% overlap, better b/c welch uses hamming window


group= {'Aging' }%'Control' 'ASD'};

for group_count = 1:length(group)
    if strcmp(group{group_count},'Aging')
        subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
    elseif strcmp(group{group_count},'ASD')
        subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants;
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
    elseif strcmp(group{group_count},'Control')
        subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
    end
    path_1 = ['C:\Users\dohorsth\Desktop\Testing restingstate\' group{group_count} '\'];
    
    for subject_list_count = 1:length(subject_list)
        path  = [path_1 subject_list{subject_list_count} '\'];
        EEG = pop_loadset('filename',[subject_list{subject_list_count} '_inter.set'],'filepath', path );
        %% separate EO from EC
        info = [];
        for i = 1:length(EEG.event)
            if strcmp(EEG.event(i).type, 'boundary') % in there because of manual artefact rejection
                continue
            elseif isfield(EEG.event,'edftype') %isempty(EEG.event(i).edftype)~=1
                info(i,1) = string(EEG.event(i).edftype);
            elseif isfield(EEG.event,'type') %isempty(EEG.event(i).type)~=1
                info(i,1) = string(EEG.event(i).type);
            end
            info(i,2) = EEG.event(i).latency;
        end
        if size(info,1)==2 && length(info)==2 %because there were no boundries, the data is in a 2x2 matrix instead of a 1x4)
            info(3,1)=0; %we add a zero, so it does the same
        end
        info(info==0) = []; %delete all zeros
        
        if isempty(info)%if there are no triggers, we are going to choose the data ourselves but take less to be safe
            durations=0;
            %when 1 or more triggers are missing, this loop happens. using the latencies + durations of the boundaries in EEG.event to reproduce the original continues data.
            %calculating which boundary is the one that would have included the trigger and using there latency to instead of the missing trigger's
            for ii= 1:length(EEG.event)
                durations=durations+EEG.event(ii).duration; %this will sum all the durations of the deleted data
                if EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(1).latency && EEG.event(ii).latency+durations+1>EEG.urevent(1).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after) (-1 and +1 just to prevent rounding up/down issues)
                    info=[50, 51, EEG.event(ii).latency]; %keeps the 2 correct ones from info, but uses the start of the boundry event for the first trigger
                    people_no50_trigger = [people_no50_trigger, subject_list(subject_list_count)];
                elseif EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(2).latency && EEG.event(ii).latency+durations+1>EEG.urevent(2).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after)
                    info=[info(1), info(2), info(3), EEG.event(ii).latency]; %don't think this is correct, I think this wil
                end
            end
            people_no_trigger = [people_no_trigger, subject_list(subject_list_count)];
        elseif length(info)~=4 %if one of the two triggers got deleted by the auto cleaning
            if info(1)==50 %trigger 51 is deleted (EC) will find the correct time and add it
                durations=0;
                for ii= 1:length(EEG.event)
                    durations=durations+EEG.event(ii).duration; %this will sum all the durations of the deleted data
                    if EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(2).latency && EEG.event(ii).latency+durations+1>EEG.urevent(2).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after)
                        info=[info(1), 51, info(2), EEG.event(ii).latency]; %don't think this is correct, I think this wil
                        people_no51_trigger = [people_no51_trigger, subject_list(subject_list_count)];
                    end
                end
            elseif info(1)==51 %trigger 51 is deleted (EC) will find the correct time and add it
                durations=0;
                for ii= 1:length(EEG.event)
                    durations=durations+EEG.event(ii).duration; %this will sum all the durations of the deleted data
                    if EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(1).latency && EEG.event(ii).latency+durations+1>EEG.urevent(1).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after) (-1 and +1 just to prevent rounding up/down issues)
                        info=[50, info(1), EEG.event(ii).latency, info(2)]; %keeps the 2 correct ones from info, but uses the start of the boundry event for the first trigger
                        people_no50_trigger = [people_no50_trigger, subject_list(subject_list_count)];
                    end
                end
            else
                breakhere
                
            end
        end
        if info(4)-info(3)<2 %this looks if trigger 50&51 are at almost the same time 1==1sec/256
            info(3)=1000;
            trigger50_51_same= [trigger50_51_same; subject_list(subject_list_count)];
        end
        data_EO = EEG.data(:,info(3):info(4));
        data_EO(:,1:2560)=[];%added to delete first 10 sec
        if info(4)+(info(4)-info(3))>EEG.pnts
            data_EC = EEG.data(:,info(4):end); %if the EC part is shorter then the EO part it would exceed the max pnts value
        else
            data_EC = EEG.data(:,info(4):info(4)+(info(4)-info(3))); %this makes sure they are both equally long
        end
        data_EC(:,1:2560)=[];%added to delete first 10 sec
        % end
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
        
        PSD_EO_CPzlog(:,subject_list_count) = 10*log10(P_EO_CPz);
        PSD_EO_Pzlog(:,subject_list_count)  = 10*log10(P_EO_Pz);
        PSD_EO_Czlog(:,subject_list_count)  = 10*log10(P_EO_Cz);
        PSD_EC_CPzlog(:,subject_list_count) = 10*log10(P_EC_CPz);
        PSD_EC_Pzlog(:,subject_list_count)  = 10*log10(P_EC_Pz);
        PSD_EC_Czlog(:,subject_list_count)  = 10*log10(P_EC_Cz);
        
    end
    %         save([path_1 'PSD_EO_CPzlog_' group{group_count}], 'PSD_EO_CPzlog')
    %         save([path_1 'PSD_EO_Pzlog_' group{group_count}], 'PSD_EO_Pzlog')
    %         save([path_1 'PSD_EO_Czlog_' group{group_count}], 'PSD_EO_Czlog')
    %         save([path_1 'PSD_EC_CPzlog_' group{group_count}], 'PSD_EC_CPzlog')
    %         save([path_1 'PSD_EC_Pzlog_' group{group_count}], 'PSD_EC_Pzlog')
    %         save([path_1 'PSD_EC_Czlog_' group{group_count}], 'PSD_EC_Czlog')
    save([path_1 'trigger50_51_same_' group{group_count}], 'trigger50_51_same')
    save([path_1 'people_no_trigger_' group{group_count}], 'people_no_trigger')
    save([path_1 'people_1_trigger_' group{group_count}], 'people_1_trigger')
    
end

