% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% Load the raw data of each participant to see if they have bad channels
% Deleting remaining bad channels by eye + seeing if there is something
% of note going on with the raw data of each person
clear variables
%subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267' '2270' '2274' '2281' '2284' '2286' '2292' '2295'};
%subject_list = {'7003' '7007' '7019' '7025' '7046' '7049' '7051' '7054' '7058' '7059' '7061' '7064' '7065' '7073' '7075' '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206' '12215' '12272' '12413' '12415' '12449' '12482' '12512' '12588' '12632' '12648' '12651' '12707' '12727' '12739' '12746' '12750' '12755' '12770' '12815' '12852' '12870'};
home_path  = 'D:\restingstate\data\';
for s=1:length(subject_list)
    clear bad_chan;
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];
    EEG = pop_loadset('filename', [subject_list{s} '_exchn.set'], 'filepath', data_path);
    pop_eegplot( EEG, 1, 1, 1);
    prompt = 'Delete channels? If yes, input them all as strings inside {}. If none hit enter ';
    bad_chan = input(prompt); %
    if isempty(bad_chan) ~=1
        EEG = pop_select( EEG, 'nochannel',bad_chan);
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_exchn.set'],'filepath', data_path);
    end
    close all

end
%2204 a lot of alpha eyes closed
%7064 muscle artifact, check ICA 
%10561 noisy
%12449 don't use only 16 chn left
%12707 check n channels (seems few left)