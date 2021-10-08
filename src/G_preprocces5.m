clear variables
eeglab

group= {'Aging' 'Control'};
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
        trigger_times=num2cell(zeros(length(subject_list),5));
    end
    path_1 = ['C:\Users\dohorsth\Desktop\Testing restingstate\' group{group_count} '\'];
    
    for subject_list_count = 1:length(subject_list)
        path  = [path_1 subject_list{subject_list_count} '\'];
        EEG = pop_loadset('filename',[subject_list{subject_list_count} '_inter.set'],'filepath', path );
        %% documenting where the 50 and 51 triggers are and restoring them to the right place
        %step 1) checking in the normal place if they are there
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
        % step 2) if step 1 didn't work, looking at the original place, and
        % try to add the
        if isempty(info)%if there are no triggers, we are going to choose the data ourselves but take less to be safe
            durations=0;
            if strcmp(subject_list{subject_list_count},'11349') %for the subj something went wrong and EEG.urevent is wrong so we need the first .set file
                EEG = pop_loadset('filename',[subject_list{subject_list_count} '.set'],'filepath', path );
                temp_urevent= EEG.event;
                temp_urevent(3).latency=temp_urevent(3).latency/2; %needs to be downsampled
                temp_urevent(2) = [];
                EEG = pop_loadset('filename',[subject_list{subject_list_count} '_inter.set'],'filepath', path );
                EEG.urevent = temp_urevent;
                % clear temp_urevent
            end
            
            %when 1 or more triggers are missing, this loop happens. using the latencies + durations of the boundaries in EEG.event to reproduce the original continues data.
            %calculating which boundary is the one that would have included the trigger and using there latency to instead of the missing trigger's
            for ii= 1:length(EEG.event)
                if ~isnan(EEG.event(ii).duration)
                    durations=durations+EEG.event(ii).duration;
                end%this will sum all the durations of the deleted data
                if EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(1).latency && EEG.event(ii).latency+durations+1>EEG.urevent(1).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after) (-1 and +1 just to prevent rounding up/down issues)
                    info=[50, 51, EEG.event(ii).latency]; %keeps the 2 correct ones from info, but uses the start of the boundry event for the first trigger
                elseif EEG.event(ii).latency+durations-EEG.event(ii).duration-1<EEG.urevent(2).latency && EEG.event(ii).latency+durations+1>EEG.urevent(2).latency %if the start of the boundry is before the latency of the original 50 and the duration last until after)
                    info=[info(1), info(2), info(3), EEG.event(ii).latency]; %don't think this is correct, I think this wil
                end
            end
            people_no_trigger = [people_no_trigger, subject_list(subject_list_count)];
        elseif info(1)==50 && info(2)~=51 %trigger 51 is deleted (EC) will find the correct time and add it
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
        end
        if strcmp(subject_list{subject_list_count},'11349')
            continue
        else
            if info(4)-info(3)<2 %this looks if trigger 50&51 are at almost the same time 1==1sec/256
                info(3)=1000;
                trigger50_51_same= [trigger50_51_same; subject_list(subject_list_count)];
            end
            
            trigger_times(subject_list_count,:)=[subject_list(subject_list_count), info(1),info(2),info(3),info(4)];
            %% saving .set files for EO and EC separate
            EEG = pop_select( EEG, 'time',[info(3)/256+10 info(4)/256] ); %info 3= trigger 50 info 4 = trigger 51
            EEG = pop_saveset( EEG, 'filename',[subject_list{subject_list_count} '_EO.set'],'filepath', path);%save
            EEG = pop_loadset('filename',[subject_list{subject_list_count} '_inter.set'],'filepath', path );
            %deleting 51
            if info(4)+(info(4)-info(3))>EEG.pnts %either eo and ec are equally long or ec is shorter (because it has too few data)
                EEG = pop_select( EEG, 'time',[info(4)/256+10 max(EEG.times)] ); %info 3= trigger 50 info 4 = trigger 51
            else
                EEG = pop_select( EEG, 'time',[info(4)/256+10 (info(4)+(info(4)-info(3)))/256] ); %info 3= trigger 50 info 4 = trigger 51
            end
            EEG = pop_saveset( EEG, 'filename',[subject_list{subject_list_count} '_EC.set'],'filepath', path);%save
        end
    end
    if isempty(trigger50_51_same) ~=1
        save([path_1 'trigger50_51_same_' group{group_count}], 'trigger50_51_same');
    end
    if isempty(people_no_trigger) ~=1
        save([path_1 'people_no_trigger_' group{group_count}], 'people_no_trigger');
    end
    if isempty(trigger_times) ~=1
        save([path_1 'trigger_times_' group{group_count}], 'trigger_times');
    end
end