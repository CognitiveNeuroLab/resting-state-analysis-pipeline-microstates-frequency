% Testing the scr code 6/21/2021
% ------------------------------------------------


clear variables

subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1108' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11369' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants
% Path to the parent folder, which contains the data folders for all subjects
home_path  = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\ASD\';
figure_path = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\ASD\figures\';
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
    %Independent Component Analysis
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'extended',1,'interupt','on'); %using runica function
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_ica.set'],'filepath', data_path);
end
for s=1:length(subject_list)
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '\\'];
    fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
    EEG = pop_loadset('filename', [subject_list{s} '_ica.set'], 'filepath', data_path);
    %organizing components
    clear bad_components brain_ic muscle_ic eye_ic hearth_ic line_noise_ic channel_ic other_ic
    pca = EEG.nbchan-1; %the PCA part of the ICA needs stops the rank-deficiency 
    EEG = pop_runica(EEG, 'extended',1,'interupt','on','pca',pca); %using runica function, with the PCA part
    ICA_components = EEG.etc.ic_classification.ICLabel.classifications ; %creates a new matrix with ICA components
    %Only the eyecomponent will be deleted, thus only components 3 will be put into the 8 component
    ICA_components(:,8) = ICA_components(:,3); %row 1 = Brain row 2 = muscle row 3= eye row 4 = Heart Row 5 = Line Noise row 6 = channel noise row 7 = other, combining this makes sure that the component also gets deleted if its a combination of all.
    bad_components = find(ICA_components(:,8)>0.80 & ICA_components(:,1)<0.05); %if the new row is over 80% of the component and the component has less the 5% brain
    %Still labeling all the other components so they get saved in the end
    brain_ic = length(find(ICA_components(:,1)>0.80));
    muscle_ic = length(find(ICA_components(:,2)>0.80 & ICA_components(:,1)<0.05));
    eye_ic = length(find(ICA_components(:,3)>0.80 & ICA_components(:,1)<0.05));
    hearth_ic = length(find(ICA_components(:,4)>0.80 & ICA_components(:,1)<0.05));
    line_noise_ic = length(find(ICA_components(:,5)>0.80 & ICA_components(:,1)<0.05));
    channel_ic = length(find(ICA_components(:,6)>0.80 & ICA_components(:,1)<0.05));
    other_ic = length(find(ICA_components(:,7)>0.80 & ICA_components(:,1)<0.05));
    %will plot all the IC components that get deleted
    if isempty(bad_components)~= 1 %script would stop if people lack bad components
        if ceil(sqrt(length(bad_components))) == 1
            pop_topoplot(EEG, 0, [bad_components bad_components] ,subject_list{s} ,0,'electrodes','on');
        else
            pop_topoplot(EEG, 0, [bad_components] ,subject_list{s},[ceil(sqrt(length(bad_components))) ceil(sqrt(length(bad_components)))] ,0,'electrodes','on');
        end
        title(subject_list{s});
        print([figure_path subject_list{s} '_Bad_ICs_topos'], '-dpng');
        EEG = pop_subcomp( EEG, [bad_components], 0); %excluding the bad components
    else %instead of only plotting bad components it will plot all components
        pop_topoplot(EEG, 0, 1:length(ICA_components) ,subject_list{s},[ceil(sqrt(length(ICA_components))) ceil(sqrt(length(ICA_components)))] ,0,'electrodes','on');
        title(subject_list{s});
        print([figure_path subject_list{s} '_no_bad_ICs_topos'], '-dpng');
    end
    close all
    EEG = pop_saveset( EEG, 'filename',[subject_list{s} '_excom.set'],'filepath', data_path);%save
    subj_comps=[subject_list(s), num2cell(brain_ic), num2cell(muscle_ic), num2cell(eye_ic), num2cell(hearth_ic), num2cell(line_noise_ic), num2cell(channel_ic), num2cell(other_ic)];
    components(s,:)=[subj_comps];
end
save([home_path 'components'], 'components');

