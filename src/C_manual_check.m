% Testing the scr code 6/21/2021
% ------------------------------------------------
%clear variables
%% ASD
%subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1108' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11369' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants
%home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\ASD\';
%% ASD controls
%subject_list = {'10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' '12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899'};% ------------------------------------------------
%home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Control\';
%% MoBI
subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};             
% controls and ASD subjects that need to be re-checked because of 160 channel info
%'10131' '10257' '10369' '10438' '10545' '10585' '12360' '12898' '1808' '1852' '1855' '11345' '1106' '1134' '1154' '1160' '1174' '1179' '1190' '1838' '11106' '11375' '11913'
home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Aging\';
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
