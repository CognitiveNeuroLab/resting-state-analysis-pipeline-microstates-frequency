% Testing the scr code 6/21/2021
subject_list = {'10033' '10130' '10131' '10257' '10281' '10293' '10360' '10369' '10385' '10394' '10438' '10446' '10463' '10476' '10526' '10545' '10561' '10562' '10581' '10585' '10616' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935' '12005' '12006' '12007' '12010' '12215' '12328' '12360' '12413' '12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899'};% ------------------------------------------------

%subject_list = {'1106' '1108' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11051' '11056' '11098' '11106' '11198' '11220' '11244' '11293' '11325' '11354' '11369' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants
filename     = 'restingstate'; % if your bdf file has a name besides the ID of the participant (e.g. oddball_paradigm)
home_path    = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\Control\'; %place data is (something like 'C:\data\')
blocks       = 1; % the amount of BDF files. if different participant have different amounts of blocks, run those participant separate
for s = 3:length(subject_list)
    clear ALLEEG
    eeglab
    close all
    data_path  = [home_path subject_list{s} '\'];
    disp([data_path  subject_list{s} '_' filename '.bdf'])
    
    %if blocks == 1
        %if participants have only 1 block, load only this one file
       EEG = pop_biosig([data_path  subject_list{s} '_' filename '.bdf']);
       

%     else
%         for bdf_bl = 1:blocks
%             %if participants have more than one block, load the blocks in a row
%             %your files need to have the same name, except for a increasing number at the end (e.g. id#_file_1.bdf id#_file_2)
%             EEG = pop_biosig([data_path  subject_list{s} '_' filename '_' num2str(bdf_bl) '.bdf']);
%             [ALLEEG, ~] = eeg_store(ALLEEG, EEG, CURRENTSET);
%         end
%         %since there are more than 1 files, they need to be merged to one big .set file.
%         EEG = pop_mergeset( ALLEEG, 1:blocks, 0);
%     end
 [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', [subject_list{s} ' restingstate paradigm'],'gui','off');   %adds a name to the internal .set file
    %save the bdf as a .set file
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '.set'],'filepath',data_path);
end

