clear variables
eeglab
home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\';

subject_list = {'10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' '12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899'};% ------------------------------------------------
epochs_resting=num2cell(zeros(length(subject_list),4));
for s=1:length(subject_list)
    data_path  = [home_path subject_list{s} '\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_excom.set'], 'filepath', data_path);
    %% adding events so we can epoch and clean
    start_eyes_closed= round(EEG.event(2).latency/256+2); %we add events, so we need to keep this time
    end_eyes_closed = round(EEG.event(2).latency/256+2)*2-20; %making sure that EO and EC are equally long
    n_epochs_eyes_open = 0; %so we can count how many epochs are created
    n_epochs_eyes_closed = 0;
    %createing the epochs for eyes open. Time is from trigger 50 until trigger 51
    for i = round(EEG.event(1).latency/256+2):2:round(EEG.event(2).latency/256)-20 %from time trigger 50 to time trigger 51
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 40},'changefield',{1 'latency' i});
        n_epochs_eyes_open = n_epochs_eyes_open + 1;
    end
    %then adding the eyes closed epoch (41) time is the same as the one before starting at trigger 51
    for i = start_eyes_closed:2:end_eyes_closed %from time trigger 51 to end
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 41},'changefield',{1 'latency' i});
        n_epochs_eyes_closed = n_epochs_eyes_closed +1;
    end
    %saving
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_epoch.set'],'filepath', data_path);%save
    %% cleaning
    %need to add a basic event list (not eveyone has that yet)
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
    EEG = eeg_checkset( EEG );
    %using the binlister so we can clean the data bin by bin (bin == epoch)
    EEG  = pop_binlister( EEG , 'BDF', [home_path 'binlist.txt'], 'IndexEL',  1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );
    EEG = pop_epochbin( EEG , [0.0  2000.0],  'none'); %epoch size and baseline size
    %this is the cleaning function (it's part of ERPlab plugin) it flags every epoch if it passes the noise treshold
    EEG  = pop_artmwppth( EEG , 'Channel',  1:EEG.nbchan, 'Flag',  1, 'Threshold',  200, 'Twindow', [ 0 1996.1], 'Windowsize',  200, 'Windowstep',  100 ); % GUI: 16-Jul-2021 09:08:20
    percent_deleted = (length(nonzeros(EEG.reject.rejmanual))/(length(EEG.reject.rejmanual)))*100; %looks for the length of all the epochs that should be deleted / length of all epochs * 100
    %deleting the flagged epochs
    EEG = pop_rejepoch( EEG, [EEG.reject.rejmanual] ,0);%this deletes the flaged epoches
    %counting how many epochs are left for both conditions
    eyes_open_epoch = 0;
    eyes_closed_epoch = 0;
    for i=1:length(EEG.urevent)
        if EEG.urevent(i).type == 40
            eyes_open_epoch = eyes_open_epoch +1;
        elseif EEG.urevent(i).type == 41
            eyes_closed_epoch = eyes_closed_epoch +1;
        end
    end
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_cleanepochs.set'],'filepath', data_path);%save
    epochs_resting(s,:) = [subject_list(s), percent_deleted, eyes_open_epoch, eyes_closed_epoch];
end
