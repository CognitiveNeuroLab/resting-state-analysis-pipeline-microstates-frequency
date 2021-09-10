%this script follows the code as descibed in Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018). Microstate EEGlab toolbox: An introductory guide.
% adapted for our pipeline on 8/27/2021 by Douwe

clear variables


Group = {'Aging'};% 'ASD' 'Control'};%'Control'
type={'EO' 'EC'};

for g=1:length(Group)
    switch Group{g}
        case 'Control' %excluding '10534' deleted too much data
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Control\';
            subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
        case 'ASD' %excluding '11516' deleted too much data and '11244' due to many button presses
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\ASD\';
            subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants;
        case 'Aging' %excluding '12094' deleted too much data
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Aging\';
            subject_list = {'12022' '12023' '12031' '12081'  '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
    end
    
    for t=1:length(type)
        save_path  = [home_path '\Microstates\' type{t} '\'];
        eeglab
        for s=1:length(subject_list)
            data_path  = [home_path subject_list{s} ''];% Path to the folder containing the current subject's data
            % Load original dataset
            fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
            EEG = pop_loadset('filename', [subject_list{s} '_' type{t} '.set'], 'filepath', data_path);
            [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        %this creates a grouped dataset using the standard values
        [EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous', 'avgref', 1, 'normalise', 0, 'MinPeakDist', 10, 'Npeaks', 1000, 'GFPthresh', 1, 'dataset_idx', 1:length(ALLEEG) );
        eeglab redraw
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG)-1,'retrieve',length(ALLEEG),'study',0); %this should select the last one, but not sure how to make it do that for sure
        eeglab redraw
        EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', 'sorting', 'Global explained variance', 'normalise', 0, 'Nmicrostates', 2:8, 'verbose', 1, 'Nrepetitions', 50, 'fitmeas', 'CV', 'max_iterations', 1000, 'threshold', 1e-06, 'optimised', 0 );
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        figure;MicroPlotTopo( EEG, 'plot_range', [] ); %plotting microstates
        print([save_path 'Group_microstate'], '-djpeg','-r300');
        
        EEG = pop_micro_selectNmicro( EEG ); % only select CV and GEV, look for where GEV doesn't increase significantly
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        for s=1:length(subject_list)
            sprintf('Importing prototypes and backfitting for dataset %s / %d.\n', string(s), length(subject_list))
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',s,'study',0);
            EEG = pop_micro_import_proto( EEG, ALLEEG, length(ALLEEG));
            %% 3.6 Back-fit microstates on EEG
            EEG = pop_micro_fit( EEG, 'polarity', 0 );
            %% 3.7 Temporally smooth microstates labels
            EEG = pop_micro_smooth( EEG, 'label_type', 'backfit', ...
                'smooth_type', 'reject segments', ...
                'minTime', 30, ...
                'polarity', 0 );
            %% 3.9 Calculate microstate statistics
            EEG = pop_micro_stats( EEG, 'label_type', 'backfit', ...
                'polarity', 0 );
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        for s=1:length(subject_list)
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',s,'study',0);
            figure('units','normalized','outerposition',[0 0 1 1]);[tt]=title(subject_list(s));tt.FontSize = 35; MicroPlotSegments( EEG, 'label_type', 'backfit', ...
                'plotsegnos', 'first', 'plot_time', [4200 5700], 'plottopos', 1 );
            print([save_path subject_list{s} '_microstate_' type{t}], '-djpeg' ,'-r300');
            close all
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_microstate_' type{t} '.set'],'filepath', data_path);
        end
    end
end