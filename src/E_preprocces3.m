% Restingstate pipepline (2021)
% Final version of SRC code 12/6/2021
% this script allows for re-reference (which we skip)
% this script interpolates the bad channels
% does an average reference
% does ICA (using pop_runica) setting a PCA, of all chans minus 1. This is
% not great. So it's changed to pca = rank(EEG.data), which also takes care of bridged channels)
% does IC lable (to organize the ICA components and prints them per participant
% used to do an extra cleaning that is not needed anymore and excluded (12/6/2021)

clear variables
eeglab
subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267'  '2274' '2281' '2284' '2286' '2292' '2295' '7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808' '10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12449' '12482' '12512' '12588' '12632' '12648' '12651' '12707' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'};

home_path  = 'D:\restingstate\data\';


    figure_path = ['D:\restingstate\figures\'];
    participant_info = num2cell(zeros(length(subject_list),9));
    %deleted_data = num2cell(zeros(length(subject_list), 2));
    participant_data_qt = string(zeros(length(subject_list), 4)); %prealocationg space for speed
    components = num2cell(zeros(length(subject_list), 8)); %prealocationg space for speed
    refchan = { }; %if you want to re-ref to a channel add the name of the channel here, if empty won't re-ref to any specific channel
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '\\'];
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_triggerfix.set'], 'filepath', data_path);
        %% setting PCA for ICA (amount of ICs you want to be created)
        pca = EEG.nbchan-1; %the PCA part of the ICA needs stops the rank-deficiency % pre 12/6/2021 , is not accurate but so far the best we can do. Does not take bridging in account, but neither would the normal ICA function, which misses the avg ref sometimes
        %% interpolation
        EEGinter = pop_loadset('filename', [subject_list{s} '_info.set'], 'filepath', data_path);%loading participant file with 64 channels
        %saving the original amount of total channels
        labels_all = {EEGinter.chanlocs.labels}.'; %stores all the labels in a new matrix
        %interpolating for 64 channels
        labels_good = {EEG.chanlocs.labels}.'; %saves all the channels that are in the excom file
        disp(EEG.nbchan); %writes down how many channels are there
        EEG = pop_interp(EEG, EEGinter.chanlocs, 'spherical');%interpolates the data
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', [subject_list{s} '_inter.set'], 'filepath', data_path); %saves data
        disp(EEG.nbchan)
        %% re-referencing, if refchan is empty this get's skipped
        if isempty(refchan)~=1 %if no re-reference channels chose this gets skipped
            for j=1:length(EEG.chanlocs)
                if strcmp(refchan{1}, EEG.chanlocs(j).labels)
                    ref1=j; %stores here the index of the first ref channel
                end
            end
            if length(refchan) ==1
                EEG = pop_reref( EEG, ref1); % re-reference to the channel if there is only one input)
            elseif length(refchan) ==2 %if 2 re-ref channels are chosen it needs to find the second one
                for j=1:length(EEG.chanlocs)
                    if strcmp(refchan{2}, EEG.chanlocs(j).labels)
                        ref2=j;
                    end
                end
                EEG = pop_reref( EEG, [ref1 ref2]); %re-references to the average of 2 channels
            end
        end
        
        
        %% Avg re-reference as suggested for the ICA
        EEG = pop_reref( EEG, []);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ref.set'],'filepath', data_path);
        
        %Independent Component Analysis
        EEG = eeg_checkset( EEG );
        
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',pca); %using runica function, with the PCA part
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
        %organizing components
        EEG = pop_loadset('filename', [subject_list{s} '_ica.set'], 'filepath', data_path);
        clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
        EEG = iclabel(EEG); %does ICLable function
        ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
        %Only the eyecomponent will be deleted, thus only components 3 will be put into the 8 component
        ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
        %bad_components = (find(ICA_components(:,3)>0.70 & ICA_components(:,1)<0.10) || (ICA_components(:,2)>0.80 & ICA_components(:,1)<0.10) || (ICA_components(:,6)>0.70 & ICA_components(:,1)<0.10)); %if the new row is over 80% of the component and the component has less the 5% brain
        bad_components = (find((ICA_components(:,3)>0.70 | ICA_components(:,2)>0.80 | ICA_components(:,6)>0.70) & ICA_components(:,1)<0.10)); %if the new row is over 80% of the component and the component has less the 5% brain
          
        %Still labeling all the other components so they get saved in the end
        brain_ic = length(find(ICA_components(:,1)>0.80));
        muscle_ic = length(find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05));
        eye_ic = length(find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05));
        hearth_ic = length(find(ICA_components(:,4)>0.80 & ICA_components(:,1)<0.05));
        line_noise_ic = length(find(ICA_components(:,5)>0.80 & ICA_components(:,1)<0.05));
        channel_ic = length(find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05));
        other_ic = length(find(ICA_components(:,7)>0.80 & ICA_components(:,1)<0.05));
        %Plotting all eye componentes and all remaining components
        if isempty(bad_components)~= 1 %script would stop if people lack bad components
            if ceil(sqrt(length(bad_components))) == 1
                pop_topoplot(EEG, 0, [bad_components bad_components] ,subject_list{s} ,0,'electrodes','on');
            else
                pop_topoplot(EEG, 0, [bad_components] ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
            end
            title(subject_list{s});
            print([figure_path subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
            EEG = pop_subcomp( EEG, [bad_components], 0); %excluding the bad components
            close all
        else %instead of only plotting bad components it will plot all components
            title(subject_list{s}); text( 0.2,0.5, 'there are no eye-components found')
            print([figure_path subject_list{s} '_Bad_ICs_topos'], '-dpng' ,'-r300');
        end
        title(subject_list{s});
        pop_topoplot(EEG, 0, 1:size(EEG.icaweights,1) ,subject_list{s},[ceil(sqrt(size(EEG.icaweights,1))) ceil(sqrt(size(EEG.icaweights,1)))] ,0,'electrodes','on');
        print([figure_path subject_list{s} '_remaining_ICs_topos'], '-dpng' ,'-r300');
        close all
        %putting both figures in 1 plot saving it, deleting the other 2.
        figure('units','normalized','outerposition',[0 0 1 1])
        if EEG.nbchan<65
            subplot(1,5,1);
        else
            subplot(1,10,1);
        end
        imshow([figure_path subject_list{s} '_Bad_ICs_topos.png']);
        title('Deleted components')
        if EEG.nbchan<65
            subplot(1,5,2:5);
        else
            subplot(1,10,2:10);
        end
        imshow([figure_path subject_list{s} '_remaining_ICs_topos.png']);
        title('Remaining components')
        print([figure_path subject_list{s} '_ICs_topos'], '-dpng' ,'-r300');
        %deleting two original files
        delete([figure_path subject_list{s} '_Bad_ICs_topos.png'])
        delete([figure_path subject_list{s} '_remaining_ICs_topos.png'])
        close all
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
        %% saving structures
        subj_comps=[subject_list(s), num2cell(brain_ic), num2cell(muscle_ic), num2cell(eye_ic), num2cell(hearth_ic), num2cell(line_noise_ic), num2cell(channel_ic), num2cell(other_ic)];
        lables_del                 = setdiff(labels_all,labels_good); %only stores the deleted channels
        All_bad_chan               = strjoin(lables_del); %puts them in one string rather than individual strings
        ID                         = string(subject_list{s});%keeps all the IDs
        data_subj                  = [ID, length(lables_del), All_bad_chan, EEG.nbchan]; %combines IDs and Bad channels, total channels at the end
        participant_data_qt(s,:)   = data_subj;%combine new data with old data
        components(s,:)            =[subj_comps];
        clear EEG_temp EEGinter
    end
   save([home_path 'components' ], 'components');
    save([home_path 'deleted_data'], 'participant_data_qt');