% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% this script fixes events and makes sure that everyone has the same events
% this is needed because 1) some people have bad data that included events
% deleted. 2) if data was collected without paradigm, there was no trigger

clear variables
eeglab
%don't include: '7049' '7059' too few remaining data - '12215' '12755' '2270' '7075' '12413' not clear where
%triggers used to be
subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267'  '2274' '2281' '2284' '2286' '2292' '2295' '7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808' '10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12449' '12482' '12512' '12588' '12632' '12648' '12651' '12707' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'};

home_path  = 'D:\restingstate\data\';
participant_info = num2cell(zeros(length(subject_list),9));
for s=1:length(subject_list)
    data_path  = [home_path subject_list{s} '\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    trigger_info = 'start of analysis';
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
        if strcmp(subject_list{s},'placeholder')
            EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        end
        if strcmp(subject_list{s},'7094')
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
        trigger_info = 'Missed 50, saving started too late';
    else %% all the rest that seem to have triggers
        trigger_info = 'has events';
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
    
    %doing the final test to make sure everyone has trigger 50 and 51 (ignoring boundary)
    final_triggers={EEG.event.type};
    for i=length(final_triggers):-1:1
        if strcmp(final_triggers(1,i),'boundary')
            final_triggers(i)=[];
        end
    end
    %we manually checked these people and they have a onset of alpha
    % 7059 - very clearly at 186.5 - dont use this one (too few data)
    % 12512- at 227
    % 12215- maybe at 232 - dont use
    % 12272- 236
    % 2229 - 264,
    % 12755- not sure maybe at 246 - dont use
    % 2281 -282
    % 7092 -clear at 291 -
    % 2270 - maybe at 312 boundry? - dont use
    %7075 -no idication , also no events in previous files...    - dont use
    %12413- no idea  - dont use
    % alpha at 306 '2204'  2207 at 296 2231 at 302 - 10748 clear at 304 -
    % everyone that has between 295 and 305 %since we'll cut the first 10 sec we have a range
    if strcmp(subject_list{s}, '2204') || strcmp(subject_list{s}, '2207') || strcmp(subject_list{s}, '2231') || strcmp(subject_list{s}, '10748')
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        final_triggers= {'added 50', 'added 51'};
    elseif strcmp(subject_list{s}, '12512') || strcmp(subject_list{s}, '12272')
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_227.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        final_triggers= {'added 50', 'added 51'};
    elseif strcmp(subject_list{s}, '2229')
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_264.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        final_triggers= {'added 50', 'added 51'};
    elseif strcmp(subject_list{s}, '2281') || strcmp(subject_list{s}, '7092')
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_282.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        final_triggers= {'added 50', 'added 51'};
    elseif length(final_triggers) > 2
        final_triggers= {'error too ', 'many triggers'};
    elseif length(final_triggers) < 1
        final_triggers= {'error ', 'no triggers'};
%         logloc = dir([data_path '*.log']);
%         if isempty(logloc)
%             %No triggers and no logfiles
%             final_triggers= {'nothing', 'nothing'}
%             clear logloc
%         else
%             final_triggers= {'nothing', 'nothing'};%No triggers but has logfile
%             % EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
%             % final_triggers= {'added 50', 'added 51'};%No triggers but has logfile
%             clear logloc
%         end
    elseif strcmp(final_triggers(1),'condition 50') &&  length(final_triggers)==1
        final_triggers= {'has 50', 'missing 51'};
        if strcmp(subject_list{s}, '12177')
            EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_last.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
            final_triggers= {'has 50', 'added missing 51'};
        end
    elseif strcmp(final_triggers(1),'condition 51') &&  length(final_triggers)==1
        EEG = pop_importevent( EEG, 'event',[home_path 'trigger_info_first.txt'],'fields',{'latency' 'type' 'position'},'skipline',1,'timeunit',1);
        final_triggers= {'added  50,', 'has 51'};
    elseif (strcmp(final_triggers(1),'condition 50') &&  strcmp(final_triggers(2),'condition 51')) || (strcmp(final_triggers{1},'50') &&  strcmp(final_triggers{2},'51'))
        final_triggers= {'has 50', 'has 51'};
    elseif final_triggers{1}==50 && final_triggers{2}==51
        final_triggers= {'has 50', 'has 51'};
    end
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_triggerfix.set'],'filepath', data_path);%save
    participant_info(s,:)= [subject_list(s), trigger_info, trigger_225, length(EEG.etc.clean_channel_mask), EEG.nbchan, 100-(EEG.nbchan/length(EEG.etc.clean_channel_mask)*100), EEG.xmax,final_triggers];
end
save([home_path 'participant_info'], 'participant_info');

