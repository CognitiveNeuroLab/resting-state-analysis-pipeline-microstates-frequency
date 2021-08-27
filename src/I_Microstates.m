%this script follows the code as descibed in Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018). Microstate EEGlab toolbox: An introductory guide.
% adapted for our pipeline on 8/27/2021 by Douwe

clear variables
eeglab
home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Control\';
save_path  = [home_path 'figures\Microstates\'];
subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
for s=1:length(subject_list)
    data_path  = [home_path subject_list{s} ''];% Path to the folder containing the current subject's data
    % Load original dataset
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_inter.set'], 'filepath', data_path);
    [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end
%this creates a grouped dataset using the standard values
[EEG, ALLEEG] = pop_micro_selectdata( EEG, ALLEEG, 'datatype', 'spontaneous', 'avgref', 1, 'normalise', 0, 'MinPeakDist', 10, 'Npeaks', 1000, 'GFPthresh', 1, 'dataset_idx', 1:length(ALLEEG) );
%[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG)-1,'retrieve',length(ALLEEG),'study',0); %this should select the last one, but not sure how to make it do that for sure
eeglab redraw
EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', 'sorting', 'Global explained variance', 'normalise', 0, 'Nmicrostates', 2:8, 'verbose', 1, 'Nrepetitions', 50, 'fitmeas', 'CV', 'max_iterations', 1000, 'threshold', 1e-06, 'optimised', 0 );

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
figure;MicroPlotTopo( EEG, 'plot_range', [] ); %plotting microstates
print([save_path 'Group_microstate'], '-djpeg');

EEG = pop_micro_selectNmicro( EEG ); % only select CV and GEV, look for where GEV doesn't increase significantly
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%errors are coming, line 83 of pop_micro_fit Dot indexing is not supported for variables of this type
for s=1:length(subject_list)
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 60,'retrieve',s,'study',0);
    fprintf('Importing prototypes and backfitting for dataset %i\n',i)
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
    figure('units','normalized','outerposition',[0 0 1 1]);[t]=title(subject_list(s));t.FontSize = 35; MicroPlotSegments( EEG, 'label_type', 'backfit', ...
        'plotsegnos', 'first', 'plot_time', [4200 5700], 'plottopos', 1 );
    print([save_path subject_list{s} '_microstate'], '-djpeg');
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_microstate.set'],'filepath', data_path);
end
