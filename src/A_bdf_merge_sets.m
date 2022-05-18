% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% Merging script to create .set file
clear all
%subject_list = {'2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2261' '2267' '2270' '2274' '2281' '2284' '2286' '2292' '2295'};
%subject_list = {'7003' '7007' '7019' '7025' '7046' '7049' '7051' '7054' '7058' '7059' '7061' '7064' '7065' '7073' '7075' '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206' '12215' '12272' '12413' '12415' '12449' '12482' '12512' '12588' '12632' '12648' '12651' '12707' '12727' '12739' '12746' '12750' '12755' '12770' '12815' '12852' '12870'};
filename     = 'restingstate'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
home_path    = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\'; %place data is (something like 'C:\data\')
blocks       = 1; % the amount of BDF files. if different participant have different amounts of blocks, run those participant separate
for s = 1:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  subject_list{s} '_' filename '.bdf'])
    
    if blocks == 1
        %if participants have only 1 block, load only this one file
        EEG = pop_biosig([data_path  subject_list{s} '_' filename '.bdf']); 
    else
        for bdf_bl = 1:blocks
            %if participants have more than one block, load the blocks in a row
            %your files need to have the same name, except for a increasing number at the end (e.g. id#_file_1.bdf id#_file_2)
            EEG = pop_biosig([data_path  subject_list{s} '_' filename '_' num2str(bdf_bl) '.bdf']);
            [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        %since there are more than 1 files, they need to be merged to one big .set file.
        EEG = pop_mergeset( ALLEEG, 1:blocks, 0);
    end
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [subject_list{s} ' restingstate paradigm'],'gui','off');   %adds a name to the internal .set file
    %save the bdf as a .set file
    mkdir( ['D:\restingstate\data\' subject_list{s}])
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',['D:\restingstate\data\' subject_list{s}]);
end

