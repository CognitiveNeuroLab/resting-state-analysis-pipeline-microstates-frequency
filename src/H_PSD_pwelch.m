% Restingstate pipepline (2021)
% SRC code 12/6/2021 - not final version
% this script loads separatly the EO and EC data
% calculates the Power Spectrum Density or The Power of each Frequency in Hz for pre-selected channels
% does a log transform and saves all participant results
% script is writen by Filip and edited by Douwe
%to do
%-  double check if NFFT should be 256 or 512
%-  double check if logtransform is only for PSD or also when only doing power

clear variables
%eeglab

%% pwelch settings
WINDOW = []; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
Fs   = 256; % sampling rate, amount of samples per unit time
NFFT = 256;  %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
SPECTRUMTYPE = 'power'; %Use the 'power' option to obtain an estimate of the power at each frequency. 'psd', returns the power spectral density
%% what channel to save
channel=48;% see EEG_EC.chanlocs for the number for all channels and names
ch_name='Cz';% CPz = 32; Pz  = 31; Cz  = 48;
%% How to save the final table
file_type='matlab';%saves the final table as either 'excel' or 'matlab'
if strcmp(file_type,'matlab')
    prompt = 'Do you want to save it as an table (write table) or idividual arrays (write array)?';
    how_to_save = input(prompt,'s');
    if ~strcmp(how_to_save,'table') && ~strcmp(how_to_save,'array')
        error('either type table or return so matlab can save your files; this error message was made on purpose')
    end
end
%% what group to run
group= {'Aging' };%'Control' 'ASD'};

for group_count = 1:length(group)
    if strcmp(group{group_count},'Aging')
        subject_list = {'12022' '12023' '12031' '12081' '12094' '12188' '12255' '12335' '12339' '12362' '12364' '12372' '12376' '12390' '12398' '12407' '12408' '12451' '12454' '12457' '12458' '12459' '12468' '12478' '12498' '12510' '12517' '12532' '12564' '12631' '12633' '12634' '12636' '12665' '12670' '12696' '12719' '12724' '12751' '12763' '12769' '12776' '12790' '12806' '12814' '12823' '12830' '12847' '12851' '12855' '12856' '12857' '12859' '12871' '12872' '12892'};
    elseif strcmp(group{group_count},'ASD')
        subject_list = {'1101' '1164' '1808' '1852' '1855' '11014' '11094' '11151' '11170' '11275' '11349' '11516' '11558' '11583' '11647' '11729' '11735' '11768' '11783' '11820' '11912' '1106' '1132' '1134' '1154' '1160' '1173' '1174' '1179' '1190' '1838' '1839' '1874' '11013' '11056' '11098' '11106' '11198' '11244' '11293' '11325' '11354' '11375' '11515' '11560' '11580' '11667' '11721' '11723' '11750' '11852' '11896' '11898' '11913' '11927' '11958' '11965'};
    elseif strcmp(group{group_count},'Control')
        subject_list = {'12512' '12648' '12651' '12707' '12727' '12739' '12750' '12815' '12898' '12899' '10033' '10130' '10131' '10158' '10165' '10257' '10281' '10293' '10360' '10369' '10384' '10394' '10407'  '10438' '10446' '10451' '10463' '10467' '10476' '10501' '10526' '10534' '10545' '10561' '10562' '10581' '10585' '10616' '10615' '10620' '10639' '10748' '10780' '10784' '10822' '10858' '10906' '10915' '10929' '10935'  '10844' '10956'  '12005' '12007' '12010' '12215' '12328' '12360' '12413' };
    end
    save_path = ['\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\' group{group_count} '\'];
    load_path = ['\\data.einsteinmed.org\users\Filip Ana Douwe\Resting state data\' group{group_count} '\'];
    if strcmp(how_to_save,'table')
        Power_EO_CH1_LOG=zeros(129*length(subject_list),1); ID=zeros(129*length(subject_list),1); freq=zeros(129*length(subject_list),1); Power_EO_CH1=zeros(129*length(subject_list),1); Power_EC_CH1=zeros(129*length(subject_list),1);
    elseif strcmp(how_to_save,'array')
        Power_EO_CH1=zeros(129,length(subject_list)); Power_EC_CH1=zeros(129,length(subject_list)); Power_EO_CH1_LOG=zeros(129,length(subject_list)); Power_EC_CH1_LOG=zeros(129,length(subject_list));
    end
    for subject_list_count = 1:length(subject_list)
        path  = [load_path subject_list{subject_list_count} '\'];
        EEG_EO = pop_loadset('filename',[subject_list{subject_list_count} '_EO.set'],'filepath', path );
        EEG_EC = pop_loadset('filename',[subject_list{subject_list_count} '_EC.set'],'filepath', path );
        %% Compute Power
        power=zeros(64,(NFFT/2+1));
        for i=1:64
            [ power_EO(i,:), f] = pwelch(EEG_EO.data(i,:),WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE);
        end
        for i=1:64
            [ power_EC(i,:), f] = pwelch(EEG_EC.data(i,:),WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE);
        end
        if strcmp(how_to_save,'table') || strcmp(file_type,'excel')
            if subject_list_count==1
                Power_EO_CH1(1:129,:)=power_EO(channel,:);
                Power_EC_CH1(1:129,:)=power_EC(channel,:);
                Power_EO_CH1_LOG(1:129,:)=10*log10(power_EO(channel,:))';%need to do a logtransformation
                Power_EC_CH1_LOG(1:129,:)=10*log10(power_EC(channel,:))';%need to do a logtransformation
                ID(1:129,:)=str2double(repelem(subject_list(subject_list_count),length(f))'); %repeated variable with the ID number
                freq(1:129,:)=f;%all frequencies
            else
                Power_EO_CH1((subject_list_count-1)*129+1:subject_list_count*129,:)=power_EO(channel,:);
                Power_EC_CH1((subject_list_count-1)*129+1:subject_list_count*129,:)=power_EC(channel,:);
                Power_EO_CH1_LOG((subject_list_count-1)*129+1:subject_list_count*129,:)=10*log10(power_EO(channel,:))';%need to do a logtransformation
                Power_EC_CH1_LOG((subject_list_count-1)*129+1:subject_list_count*129,:)=10*log10(power_EC(channel,:))';%need to do a logtransformation
                ID((subject_list_count-1)*129+1:subject_list_count*129,:)=str2double(repelem(subject_list(subject_list_count),length(f))'); %repeated variable with the ID number
                freq((subject_list_count-1)*129+1:subject_list_count*129,:)=f;%all frequencies
            end
        else
            Power_EO_CH1(:,subject_list_count)=power_EO(channel,:)';
            Power_EC_CH1(:,subject_list_count)=power_EC(channel,:)';
            Power_EO_CH1_LOG(:,subject_list_count)=10*log10(power_EO(channel,:));%need to do a logtransformation
            Power_EC_CH1_LOG(:,subject_list_count)=10*log10(power_EC(channel,:));%need to do a logtransformation
        end
        
    end
end
%% saving everything to Excel or matlab

if strcmp(file_type,'excel') || strcmp(how_to_save,'table')
    Power_table = table(ID, freq,Power_EO_CH1, Power_EC_CH1, Power_EO_CH1_LOG, Power_EC_CH1_LOG);
end
if strcmp(file_type,'excel')
    filename_table = [save_path 'Power_table_for_ch_' ch_name '_' group{group_count} '.xlsx'];
    writetable(Power_table, filename_table);
elseif strcmp(file_type,'matlab')
    filename_table = [save_path 'Power_table_for_ch_' ch_name '_' group{group_count}];
    if strcmp(how_to_save,'table')
        save(filename_table, Power_table);
    else
        save(filename_table, 'subject_list', 'f', 'Power_EO_CH1',  'Power_EC_CH1', 'Power_EO_CH1_LOG', 'Power_EC_CH1_LOG');
    end
end