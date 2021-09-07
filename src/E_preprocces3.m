clear variables
eeglab
Group = {'Aging' 'Control' 'ASD'}; %'Control'

for g=1:length(Group)
    switch Group{g}
        case 'Control'
            home_path  = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\Control\';
            subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
        case 'ASD'
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\ASD\';
            subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants;
        case 'Aging'
            home_path  = 'C:\Users\dohorsth\Desktop\Testing restingstate\Aging\';
            subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
            deleted_data_before = num2cell(zeros(length(subject_list), 2)); %only this group wil have their data cleaned extra
    end
    figure_path = [home_path 'figures\'];
    participant_info = num2cell(zeros(length(subject_list),9));
    deleted_data = num2cell(zeros(length(subject_list), 2));
    components = num2cell(zeros(length(subject_list), 8)); %prealocationg space for speed
    refchan = { }; %if you want to re-ref to a channel add the name of the channel here, if empty won't re-ref to any specific channel
    for s=1:length(subject_list)
        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        % Path to the folder containing the current subject's data
        data_path  = [home_path subject_list{s} '\\'];
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_triggerfix.set'], 'filepath', data_path);
        %re-referencing, if refchan is empty this get's skipped
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
        EEG = eeg_checkset( EEG );
        
        %another re-ref to the averages as suggested for the ICA
        EEG = pop_reref( EEG, []);
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ref.set'],'filepath', data_path);
        
        %because the ICA data + overall data is short seem noisy we clean extra for this group
        if strcmp(Group{g}, 'Aging')
            orig_length=EEG.xmax;
            EEG = pop_rejcont(EEG, 'elecrange',[1:EEG.nbchan] ,'freqlimit',[20 40] ,'threshold',8 ,'epochlength',0.5,'contiguous',4,'addlength',0.25,'taper','hamming');
            clean_length=EEG.xmax;
            deleted_data_before(s,:)=[subject_list(s), 100-(clean_length/orig_length)*100];
        end
        %Independent Component Analysis
        EEG = eeg_checkset( EEG );
        pca = EEG.nbchan-1; %the PCA part of the ICA needs stops the rank-deficiency
        EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',pca); %using runica function, with the PCA part
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
        
        %organizing components
        clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
        EEG = iclabel(EEG); %does ICLable function
        ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
        %Only the eyecomponent will be deleted, thus only components 3 will be put into the 8 component
        ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
        bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.10); %if the new row is over 80% of the component and the component has less the 5% brain
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
            pop_topoplot(EEG, 0, 1:length(ICA_components) ,subject_list{s},[ceil(sqrt(length(ICA_components))) ceil(sqrt(length(ICA_components)))] ,0,'electrodes','on');
            title(subject_list{s});
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
        %% extra cleaning
        orig_length=EEG.xmax;
        EEG = pop_rejcont(EEG, 'elecrange',[1:EEG.nbchan] ,'freqlimit',[20 40] ,'threshold',8 ,'epochlength',0.5,'contiguous',4,'addlength',0.25,'taper','hamming');
        clean_length=EEG.xmax;
        EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_clean.set'],'filepath', data_path);%save
        %% saving structures
        deleted_data(s,:)=[subject_list(s), 100-(clean_length/orig_length)*100];
        subj_comps=[subject_list(s), num2cell(brain_ic), num2cell(muscle_ic), num2cell(eye_ic), num2cell(hearth_ic), num2cell(line_noise_ic), num2cell(channel_ic), num2cell(other_ic)];
        components(s,:)=[subj_comps];
    end
    save([home_path 'components'], 'components');
    save([home_path 'deleted_data'], 'deleted_data');
end