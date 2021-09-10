%this script needs work. 
% 1) It should load the EO and EC data 
% 2) combine all the channels that that should be grouped and average them
% 3) compute the power on these 

clear variables
eeglab
len  = 256;
Fs   = 256;
nfft = 512;  %should be power of 2
%noverlap = 0;  %we'll do 50% overlap, better b/c welch uses hamming window


group= {'Aging' };%'Control' 'ASD'};

for group_count = 1:length(group)
    if strcmp(group{group_count},'Aging')
        subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
    elseif strcmp(group{group_count},'ASD')
        subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'}; %all the IDs for the indivual particpants;
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
    elseif strcmp(group{group_count},'Control')
        subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };% ------------------------------------------------
        people_no_trigger = [];
        people_no50_trigger = [];
        people_no51_trigger = [];
        trigger50_51_same = [];
        trigger_times=num2cell(zeros(length(subject_list),5));        
    end
    path_1 = ['C:\Users\dohorsth\Desktop\Testing restingstate\' group{group_count} '\'];
    
    for subject_list_count = 1:length(subject_list)
        path  = [path_1 subject_list{subject_list_count} '\'];
        EEG = pop_loadset('filename',[subject_list{subject_list_count} '_EO.set'],'filepath', path );
        EEG = pop_loadset('filename',[subject_list{subject_list_count} '_EC.set'],'filepath', path );
        %% separate EO from EC
        
        %% grouping data of different channels
        data_ch1_ch2_ch3= [EEG.data(1,:);EEG.data(3,:)]; %select here the channels you want to include
        data_ch1_ch2_ch3=mean(data_ch1_ch2_ch3); % here it turns it into an average
        
        
        %% Compute Power
        CPz = 32;
        Pz  = 31;
        Cz  = 48;
        
        [P_EO_CPz freqs] = pwelch(data_EO(CPz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EO_Pz          = pwelch(data_EO(Pz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EO_Cz          = pwelch(data_EO(Cz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_CPz         = pwelch(data_EC(CPz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_Pz          = pwelch(data_EC(Pz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        P_EC_Cz          = pwelch(data_EC(Cz,:),len,[],nfft,Fs);  %does not produce an image with outputs
        
        PSD_EO_CPzlog(:,subject_list_count) = 10*log10(P_EO_CPz);
        PSD_EO_Pzlog(:,subject_list_count)  = 10*log10(P_EO_Pz);
        PSD_EO_Czlog(:,subject_list_count)  = 10*log10(P_EO_Cz);
        PSD_EC_CPzlog(:,subject_list_count) = 10*log10(P_EC_CPz);
        PSD_EC_Pzlog(:,subject_list_count)  = 10*log10(P_EC_Pz);
        PSD_EC_Czlog(:,subject_list_count)  = 10*log10(P_EC_Cz);
        
    end  
end

