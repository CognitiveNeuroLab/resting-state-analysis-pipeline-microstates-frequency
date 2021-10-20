% this script fixes events and makes sure that everyone has the same events
% there are 2 people with the wrong triggers (63539 & 63538 (wrong?) & 63488)
% there are 2 people without a trigger but we have the logfile with the time
% there are several people with 255 as an extra trigger
%clear variables
%eeglab
Group = 'Control'; % 'Control'  'ASD' 'Aging'

switch Group
    case 'Control'
        %         home_path  = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\Control\';
        %       %% aged matched controls
        %subject_list = {'10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' '12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899'};% ------------------------------------------------
        %% extra controls
        subject_list = {'10297' '10331' '10385' '10399' '10497' '10553' '10590' '10640' '10867' '10906' '12002' '12004' '12006' '12122' '12139' '12177' '12188' '12197' '12203' '12206' '12230' '12272' '12415' '12474' '12482' '12516' '12534' '12549' '12588' '12632' '12735' '12746' '12755' '12770' '12852' '12870'};
        home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Remaining_controls\';
        % did these again because need extra channels deleted
        % subject_list = {'12139' '10399'};
        % home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Remaining_controls\';
        
        participant_info = num2cell(zeros(length(subject_list),9));
    case 'ASD'
        home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\ASD\';
        subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants
        participant_info = num2cell(zeros(length(subject_list),9));
    case 'Aging'
        home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Aging\';
        subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
        participant_info = num2cell(zeros(length(subject_list),9));
end
for s=1:length(subject_list)
    data_path  = [home_path subject_list{s} '\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    trigger_info = 'Has trigger 50 and 51';
    amount_triggers = length(EEG.event);
    %% looking for people without triggers and sees if they at least have a logfile and thus if they were run with the paradigm
    if isempty(EEG.event)
        logloc = dir([data_path '*.log']);
        if isempty(logloc)
            trigger_info = 'No triggers and no logfiles';
        else
            trigger_info = 'No triggers but has logfile';
            clear logloc
        end
        %based on the raw data we decided that for these people we could place the triggers in the same place
        if strcmp(subject_list{s},'12272') || strcmp(subject_list{s},'12755') || strcmp(subject_list{s},'10748') || strcmp(subject_list{s},'10929')|| strcmp(subject_list{s},'12215')|| strcmp(subject_list{s},'12413') || strcmp(subject_list{s},'11515')
            EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        end
        if strcmp(subject_list{s},'10385')
            EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_early.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        end
        
        
        %% looking and replacing wrong tiggers due to USB error
    elseif strcmp(string(EEG.event(1).type), "63488") && strcmp(string(EEG.event(3).type), "63539")
        EEG.event(1).type = 50; %EO trigger becomes 50
        EEG.event(3).type = 51; %EC trigger becomes 51
        EEG = pop_editeventvals(EEG,'delete',2); % this deletes the second trigger, which is a wrong trigger
        trigger_info = 'Had long trigger issue, now fixed';
        %% only adding first trigger (started saving too late so missed the first trigger)
    elseif strcmp(subject_list{s},'1838')
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_first.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
    end
    
    
    %% looking if there are 255 triggers that indicates button presses
    index=[];
    trigger_225 = 'no 255';
    for i = 1:length(EEG.event) %225 happens is someone clicks mouse button
        if strcmp(string(EEG.event(i).type), "255")
            index = [index,i];
        end
    end
    if isempty(index)~=1 %delete the 225 triggers
        EEG = pop_editeventvals(EEG,'delete',index);
        trigger_225 = [num2str(length(index)) ' times 225'];
    end
    %% if arduino caused issues trigger 128 would be added often
    index=[];
    for i = 1:length(EEG.event) %128 happens is someone clicks mouse button
        if strcmp(string(EEG.event(i).type), "128")
            index = [index,i];
        end
    end
    if isempty(index)~=1 %delete the 225 triggers
        EEG = pop_editeventvals(EEG,'delete',index);
        trigger_225 = [num2str(length(index)) ' times 128'];
    end
    
    if isfield(EEG.etc, 'clean_channel_mask')== 0 %this field does not exist if no channels were deleted automatically so we create it
        if EEG.nbchan< 65
            EEG.etc.clean_channel_mask = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];
            disp('used it 64')
        elseif EEG.nbchan< 161
            EEG.etc.clean_channel_mask = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];
            disp('used it 160')
        end
    end
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_triggerfix.set'],'filepath', data_path);%save
    %doing the final test to make sure everyone has trigger 50 and 51 (ignoring boundary)
    final_triggers={EEG.event.type};
    ii=[];
    for i=1:length(final_triggers)
        if strcmp(final_triggers(1,i),'boundary')
            ii=i;
        end
    end
    final_triggers(ii)=[];
    if length(final_triggers) > 2
        final_triggers= {'error too ', 'many triggers'};
    elseif length(final_triggers) < 1
        final_triggers= {'error too ', 'few triggers'};
    end
    participant_info(s,:)= [subject_list(s), trigger_info, trigger_225, length(EEG.etc.clean_channel_mask), EEG.nbchan, 100-(EEG.nbchan/length(EEG.etc.clean_channel_mask)*100), EEG.xmax,final_triggers];
end
save([home_path 'participant_info_160chn'], 'participant_info');