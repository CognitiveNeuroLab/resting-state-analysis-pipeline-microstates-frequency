% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% creates separate Eyes open and Eyes closed files
% We double check triggers, and split the data into eyes open and eyes closed 
clear variables
eeglab

subject_list = {'10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12482' '12512' '12588' '12632' '12648' '12651' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'};
%'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267'  '2274' '2281' '2284' '2286' '2292' '2295' '7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808' '10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12482' '12512' '12588' '12632' '12648' '12651' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'
home_path  = 'D:\restingstate\data\';
for subject_list_count = 1:length(subject_list)
    path  = [home_path subject_list{subject_list_count} '\'];
    EEG = pop_loadset('filename',[subject_list{subject_list_count} '_excom-manual.set'],'filepath', path );
    %% documenting where the 50 and 51 triggers are and restoring them to the right place
    %step 1) checking in the normal place if they are there
    info = [];
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'boundary') % in there because of manual artefact rejection
            continue
        elseif isfield(EEG.event,'type') %isempty(EEG.event(i).type)~=1
            info(i,1) = string(EEG.event(i).type);
            if strcmp(EEG.event(i).type,'condition 50')
                info(i,1) = 50;
            elseif strcmp(EEG.event(i).type,'condition 51')
                info(i,1) = 51;
            end
        elseif isfield(EEG.event,'edftype') %isempty(EEG.event(i).edftype)~=1
            info(i,1) = string(EEG.event(i).edftype);
        end
        info(i,2) = EEG.event(i).latency;
    end
    if size(info,1)==2 && length(info)==2 %because there were no boundries, the data is in a 2x2 matrix instead of a 1x4)
        info(3,1)=0; %we add a zero, so it does the same
    end
    info(info==0) = []; %delete all zeros

    %% saving .set files for EO and EC separate
    %Start of each epoch is 10sec after the trigger (giving people time to close eyes/read text etc.) until 200s later.
    %We chose 200 seconds because this means almost everyone has enough data and it can be the same for both conditions.
    EEG = pop_select( EEG, 'time',[info(3)/256+10 info(3)/256+210]);%info 3= trigger 50 210 will give in total 200 seconds
    EO_length=EEG.xmax;
    EEG = pop_saveset( EEG, 'filename',[subject_list{subject_list_count} '_EO.set'],'filepath', path);%save
    EEG = pop_loadset('filename',[subject_list{subject_list_count} '_excom-manual.set'],'filepath', path );
    %deleting 51
    EEG = pop_select( EEG, 'time',[info(4)/256+10 info(4)/256+210] ); %info(4) = trigger 51
    EEG = pop_saveset( EEG, 'filename',[subject_list{subject_list_count} '_EC.set'],'filepath', path);%save
    triggers(subject_list_count,:)=[subject_list{subject_list_count}, info(1:2), EO_length, EEG.xmax];
end
save([home_path 'last_trigger_check'], 'triggers');

