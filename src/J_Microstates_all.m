% Restingstate pipepline (2021)
% SRC code 12/6/2021 - final version
% this script follows the code as descibed in Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018). Microstate EEGlab toolbox: An introductory guide.
% adapted for our pipeline on 12/20/2021 by Douwe

clear variables


Group = {'22q' };% 'Control 22q' 'Control sz' '22q +' '22q -' 'sz' };%
type={'EC'};
n_microstates=4;%how many microstates should be plotted
for g=1:length(Group)
    switch Group{g}
        %% original groups
        %     case 'Control'
        %         subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12482' '12512' '12588' '12632' '12648' '12651' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'};
        %     case 'sz'
        %            subject_list = {'7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
        %     case '22q'
        %         subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267'  '2274' '2281' '2284' '2286' '2292' '2295'};
        %% groups when split up
        case 'Control sz'
            subject_list = {'12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12482' '12588' '12651' '12852' '12870'};
        case 'sz'
            subject_list = {'7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
        case 'Control 22q'
            subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12512' '12632' '12648' '12727' '12739' '12746' '12750'  '12770' '12815'};
        case '22q +'
            subject_list = {'2201' '2207' '2216' '2243' '2256' '2267' '2274' '2281' '2286' '2292'};
        case '22q -'
            subject_list = {'2202' '2204' '2212' '2222' '2229' '2231' '2257' '2260' '2261' '2284' '2295'};
        case  '22q'
            subject_list = {'2201','2207','2216','2243','2256','2267','2274','2281','2286','2292','2202','2204','2212','2222','2229','2231','2257','2260','2261','2284','2295'};
    end
    home_path = 'D:\restingstate\data\';
    %% creating arrays to save data in
    Microstate=zeros(n_microstates*length(subject_list),1); GFP=zeros(length(n_microstates)*length(subject_list),1) ;
    Occurence=zeros(n_microstates*length(subject_list),1) ;Duration=zeros(length(n_microstates)*length(subject_list),1) ;
    Coverage=zeros(n_microstates*length(subject_list),1) ;GEV=zeros(length(n_microstates)*length(subject_list),1) ;
    ID=zeros(n_microstates*length(subject_list),1) ;
    for t=1:length(type)
        save_path  = [home_path 'Microstates\' type{t} '\'];
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
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'retrieve',length(ALLEEG),'study',0); %this should select the last one, but not sure how to make it do that for sure
        eeglab redraw
        EEG = pop_micro_segment( EEG, 'algorithm', 'modkmeans', 'sorting', 'Global explained variance', 'normalise', 0, 'Nmicrostates', n_microstates, 'verbose', 1, 'Nrepetitions', 50, 'fitmeas', 'CV', 'max_iterations', 1000, 'threshold', 1e-06, 'optimised', 0 );
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        figure;MicroPlotTopo( EEG, 'plot_range', [] ); %plotting microstates
        print([save_path Group{g} '_microstate_' type{t}], '-djpeg','-r300');
        eeglab redraw
        EEG = pop_micro_selectNmicro( EEG,  'Nmicro' ,  n_microstates); % in this script we decided the n_microstates so we don't have to deal with clicking through the figure
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = pop_saveset( EEG, 'filename',[Group{g} '_microstate_' type{t} '.set'],'filepath', home_path);
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
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_microstate_' type{t} '.set'],'filepath', data_path);
            %% plotting the
            figure('units','normalized','outerposition',[0 0 1 1]);[tt]=title(subject_list(s));tt.FontSize = 35; MicroPlotSegments( EEG, 'label_type', 'backfit', ...
                'plotsegnos', 'first', 'plot_time', [4200 5700], 'plottopos', 1 );
            print([save_path subject_list{s} '_microstate_' type{t}], '-djpeg' ,'-r300');
            close all
            EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_microstate_' type{t} '.set'],'filepath', data_path);
            
            %% creating datafiles to save for stats
            Microstate(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=(1:length(EEG.microstate.stats.TP));
            GFP(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=EEG.microstate.stats.Gfp';
            Occurence(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=EEG.microstate.stats.Occurence';
            Duration(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=EEG.microstate.stats.Duration';
            Coverage(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=EEG.microstate.stats.Coverage';
            GEV(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=EEG.microstate.stats.GEV';
            ID(s*length(EEG.microstate.stats.TP)-3:s*length(EEG.microstate.stats.TP),1)=str2double(repelem(subject_list(s),length(EEG.microstate.stats.TP))'); %repeated variable with the ID number
        end
        Microstate_table=table(ID,Microstate,GFP,Occurence,Duration,Coverage,GEV);
        filename_table = [save_path 'Microstate_table_' Group{g} '_' type{t} '.xlsx'];
        writetable(Microstate_table, filename_table);
    end
end

