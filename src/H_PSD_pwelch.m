% Restingstate pipepline (2021)
% SRC code 12/6/2021 - not final version
% this script loads separatly the EO and EC data
% calculates the Power Spectrum Density or The Power of each Frequency in Hz for pre-selected channels
% does a log transform and saves all participant results
% script is writen by Filip and edited by Douwe
%to do
%-  double check if NFFT should be 256 or 512 (nonequispaced fast Fourier
%transform?)
%-  double check if logtransform is only for PSD or also when only doing power

clear variables
eeglab

%% pwelch settings
WINDOW = []; %The size of the window, optimal is 8 segments with 50% overlap, which is what it will try to do if you leave it empty. (pwelch will cut data in segments and calculate on these indiv segments)
NOVERLAP = [];% samples of overlap from section to section.  If NOVERLAP is omitted or specified as empty, it is set to obtain a 50% overlap, 50% is the normal way of doing this.
Fs   = 256; % sampling rate, amount of samples per unit time
NFFT = 256;  %Number of DFT points, specified as a positive integer. For a real-valued input signal, x, the PSD estimate, pxx has length (nfft/2 + 1) if nfft is even, and (nfft + 1)/2 if nfft is odd. For a complex-valued input signal,x, the PSD estimate always has length nfft. If nfft is specified as empty, the default nfft is used. If nfft is greater than the segment length, the data is zero-padded. If nfft is less than the segment length, the segment is wrapped using datawrap to make the length equal to nfft.
SPECTRUMTYPE = 'power'; %Use the 'power' option to obtain an estimate of the power at each frequency. 'psd', returns the power spectral density
%% what channel to save
channel=64;% see EEG_EC.chanlocs for the number for all channels and names % CPz = 32; Pz  = 31; Cz  = 48;
ch_name= 'all'; %'Fpz' 'Fp2' 'AF7' 'AF3' 'AFz' 'AF4' 'AF8' 'F7' 'F5' 'F3' 'F1' 'Fz' 'F2' 'F4' 'F6' 'F8' 'FT7' 'FC5' 'FC3' 'FC1' 'FCz' 'FC2' 'FC4' 'FC6' 'FT8' 'T7' 'C5' 'C3' 'C1' 'Cz' 'C2' 'C4' 'C6' 'T8' 'TP7' 'CP5' 'CP3' 'CP1' 'CPz' 'CP2' 'CP4' 'CP6' 'TP8' 'P9' 'P7' 'P5' 'P3' 'P1' 'Pz' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO7' 'PO3' 'POz' 'PO4' 'PO8' 'O1' 'Oz' 'O2' 'Iz' 
%done: 
%ch_name='Fp1';
%% How to save the final table
file_type='excel';%saves the final table as either 'excel' or 'matlab'
if strcmp(file_type,'matlab')
    prompt = 'Do you want to save it as an table (write table) or idividual arrays (write array)?';
    how_to_save = input(prompt,'s');
    if ~strcmp(how_to_save,'table') && ~strcmp(how_to_save,'array')
        error('either type table or return so matlab can save your files; this error message was made on purpose')
    end
else
    how_to_save='table';
end
%% what group to run
group= {'22q' 'Control' 'sz'};  %'Control' 'schiz' 

for group_count = 1:length(group)
switch group{group_count}
    case 'Control' %excluding '10534' deleted too much data
        subject_list = {'10293' '10561' '10562' '10581' '10616' '10748' '10822' '10858' '10935' '12004' '12010' '12139' '12177' '12188' '12197' '12203' '12206'  '12272'  '12415' '12482' '12512' '12588' '12632' '12648' '12651' '12727' '12739' '12746' '12750'  '12770' '12815' '12852' '12870'};
    case 'sz' 
           subject_list = {'7003' '7007' '7019' '7025' '7046' '7051' '7054' '7058'  '7061' '7064' '7065' '7073'  '7078' '7089' '7092' '7094' '7123' '7556' '7808'};
    case '22q' 
        subject_list = {'2201' '2202' '2204' '2207' '2212' '2216' '2222' '2229' '2231' '2243' '2256' '2257' '2260' '2261' '2267'  '2274' '2281' '2284' '2286' '2292' '2295'};
end
home_path = 'D:\restingstate\data\';
    save_path = 'D:\restingstate\data\';

    if strcmp(how_to_save,'table')
    %    ID=zeros(64*129*length(subject_list),1); freq=zeros(64*129*length(subject_list),1); Power_EO_CH1=zeros(64*129*length(subject_list),1); Power_EC_CH1=zeros(64*129*length(subject_list),1);  Power_EO_CH1_LOG=zeros(64*129*length(subject_list),1);  Power_EC_CH1_LOG=zeros(64*129*length(subject_list),1);
    CHN=[]; ID=[]; freq=[]; Power_EO_CH1=[]; Power_EC_CH1=[];  Power_EO_CH1_LOG=[];  Power_EC_CH1_LOG=[];
    elseif strcmp(how_to_save,'array')
        Power_EO_CH1=zeros(129,length(subject_list)); Power_EC_CH1=zeros(129,length(subject_list)); Power_EO_CH1_LOG=zeros(129,length(subject_list)); Power_EC_CH1_LOG=zeros(129,length(subject_list));
    end
    for subject_list_count = 1:length(subject_list)
        path  = [home_path subject_list{subject_list_count} '/'];
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

        for ii=1:64
 %          Power_EO_CH1(subject_list_count*length(power_EO)-(length(power_EO)-1):(subject_list_count)*length(power_EO),ii)=power_EO(ii,:);
            Power_EO_CH1=[Power_EO_CH1;power_EO(ii,:)'];
            Power_EC_CH1=[Power_EC_CH1;power_EC(ii,:)'];
            Power_EO_CH1_LOG=[Power_EO_CH1_LOG;10*log10(power_EO(ii,:))'];%need to do a logtransformation
            Power_EC_CH1_LOG=[Power_EC_CH1_LOG;10*log10(power_EC(ii,:))'];%need to do a logtransformation
            freq=[freq;f];%all frequencies
            ID=[ID;str2double(repelem(subject_list(subject_list_count),length(f))')];
            CHN=[CHN;repelem(string(EEG_EC.chanlocs(ii).labels),length(f))'];
          %  Power_EO_CH1(ii*subject_list_count*length(power_EO)-(length(power_EO)-1):(ii*subject_list_count)*length(power_EO))=power_EO(ii,:);
          %  Power_EC_CH1(ii*subject_list_count*length(power_EC)-(length(power_EC)-1):(ii*subject_list_count)*length(power_EC))=power_EC(ii,:);
          %  Power_EO_CH1_LOG(ii*subject_list_count*length(power_EO)-(length(power_EO)-1):(ii*subject_list_count)*length(power_EO))=10*log10(power_EO(ii,:))';%need to do a logtransformation
          %  Power_EC_CH1_LOG(ii*subject_list_count*length(power_EC)-(length(power_EC)-1):(ii*subject_list_count)*length(power_EC))=10*log10(power_EC(ii,:))';%need to do a logtransformation
          %  ID(ii*subject_list_count*length(power_EO)-(length(power_EO)-1):(ii*subject_list_count)*length(power_EO))=str2double(repelem(subject_list(subject_list_count),length(f))'); %repeated variable with the ID number
          %  freq(ii*subject_list_count*length(power_EO)-(length(power_EO)-1):(ii*subject_list_count)*length(power_EO))=f;%all frequencies
        
        end    
       %     ID(subject_list_count*length(power_EO)-(length(power_EO)-1):(subject_list_count)*length(power_EO))=str2double(repelem(subject_list(subject_list_count),length(f))'); %repeated variable with the ID number
       %     freq(subject_list_count*length(power_EO)-(length(power_EO)-1):(subject_list_count)*length(power_EO))=f;%all frequencies
        
    end
%% saving everything to Excel or matlab

if strcmp(file_type,'excel') || strcmp(how_to_save,'table')
    Power_table = table(ID, freq, CHN, Power_EO_CH1, Power_EC_CH1, Power_EO_CH1_LOG, Power_EC_CH1_LOG);
end
if strcmp(file_type,'excel')
    filename_table = [save_path 'Power_table_' group{group_count} '.xlsx'];
    writetable(Power_table, filename_table);
elseif strcmp(file_type,'matlab')
    filename_table = [save_path 'Power_table_for_ch_' group{group_count}];
    if strcmp(how_to_save,'table')
        save(filename_table, Power_table);
    else
        save(filename_table, 'subject_list', 'f', 'Power_EO_CH1',  'Power_EC_CH1', 'Power_EO_CH1_LOG', 'Power_EC_CH1_LOG');
    end
end

end