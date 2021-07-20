close all
clear variables
%group                    = 'Pa';
path_1                     = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\'; %loading
pathEO_1 = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\'; %saving
pathEC_1 = '\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\'; %saving
eeglab


       subj          = [12632 13287 4336542 ];

%%
for subj_count = 1:length(subj)
    path    = [path_1 num2str(subj(subj_count)) '\'];
    pathEO  = [pathEO_1 num2str(subj(subj_count)) '\'];
    pathEC  = [pathEC_1 num2str(subj(subj_count)) '\'];
    EEG     = pop_loadset ('filename', [num2str(subj(subj_count)) '_inter.set'],...
                               'filepath', path , 'loadmode', 'all');

    if EEG.srate ~=125
       EEG  = pop_resample(EEG,125);
    end
    
    
    
    %test = EEG.data;
    %find latency of triggger 50(EO) and  51(EC)
    info = [];
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'boundary') % in there because of manual artefact rejection
            continue
        end
        info(i,1) = EEG.event(i).edftype;
        info(i,2) = EEG.event(i).latency;
    end
    info(info==0) = []; %delete all zeros
    
    data_EO = EEG.data(:,info(3):info(4));
    data_EO(:,1:1250)=[];%added to delete first 10 sec
    data_EC = EEG.data(:,info(4):end);
    data_EC(:,1:1250)=[];%added to delete first 10 sec
    
    %2-sec Epoch & sample rate of 125Hz = 250 sample points per epoch
    count = 1;
    for i = 1:floor((size(data_EO,2)/250)) 
        data_EO_epoched(:,:,i) = data_EO(1:64,count:(count+250));
        count                  = count + 249;
    end
    count = 1;
    for i = 1:floor((size(data_EC,2)/250))
        data_EC_epoched(:,:,i) = data_EC(1:64,count:(count+250));
        count                  = count + 249;
    end
    
    %pathEO = '\\data.einsteinmed.org\users\Filip Ana Douwe\Scripts\Aging\EO_epochs\';
    % write txt file of first 20 epochs for microstate analysis 
    for i=1:20
        data_EO_txt = data_EO_epoched(:,:,i);
        fid=fopen([pathEO num2str(subj(subj_count)) '_EO_tr' num2str(i)  '.asc'],'w');
        fprintf(fid, '%f %f	%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f	%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n', data_EO_txt);
        fclose(fid);
    end
   % pathEC = '\\data.einsteinmed.org\users\Filip Ana Douwe\Scripts\Aging\EC_epochs\';
    for i=21:40
        data_EC_txt = data_EC_epoched(:,:,i);
        fid=fopen([pathEC num2str(subj(subj_count)) '_EC_tr' num2str(i)  '.asc'],'w');
        fprintf(fid, '%f %f	%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f	%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f \n', data_EC_txt);
        fclose(fid);
    end
end

    
    
    
    
