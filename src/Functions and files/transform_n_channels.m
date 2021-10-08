% transform_channels() - transform x amount of channel data into different
% amount of channels using the intpolation function of EEGlab
% 
%
% Usage: EEGOUT = transform_channels(EEG,chanlocs_new,n_new_chan,methode);
%
% Inputs:
%     EEG             -   EEGLAB dataset
%     chanlocs_new    -   chanlocs stucture with amount of channels
%                         desired for EEG to be transformed to.
%     n_new_chan      -   64 or 160, this will decide what channels to keep
%   Methods - there are 3 methods, choose which one
%     interpolate     -   this interpolates all the channels
%     keep            -   Only for 160 channel data that will be transformed
%                         to 64 channel data. Keep only the original channels
%                         and data that are closest to the 64channel
%                         equivalent.
%
% Output:
%     EEGOUT          -   dataset with the new amount of channels
%
% Example:
% EEG = transform_n_channels(EEG,EEG2.chanlocs,64,interpolate);
% Extra:
% To get the EEG2.chanlocs with the new amount of channels,
% simply load an .set file with those amount of channels
% making sure that the channel info has been inputted
%
% Author: Douwe Horsthuis, CNL Albert Einstein College of Medicine, 2021
% douwehorsthuis@gmail.com
%
% This function relies several EEGlab functions
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.

function EEG = transform_n_channels(ORGEEG, newchan,n_new_chan, methode)
% clearing things that are not correct anymore
    ORGEEG.icaact=[]; ORGEEG.icasphere =[]; ORGEEG.icaweights=[]; ORGEEG.icachansind=[];ORGEEG.icawinv=[];
if n_new_chan == 64
    old = {'A1',  'A19'  'A23'  'B32'  'C7'  'D4'  'D8'  'E4'  'E9'  'C1'  'C2'  'C3'  'C4'  'C5'  'C6'};
    new = {'AA1', 'AA19' 'AA23' 'BB32' 'CC7' 'DD4' 'DD8' 'EE4' 'EE9' 'CC1' 'CC2' 'CC3' 'CC4' 'CC5' 'CC6'};
    final={'Cz' 'Pz' 'Oz' 'T8' 'C4' 'Fz' 'Fpz' 'C3' 'T7'};
    old_keep={'D9' 'D22' 'D20' 'D13'  'D19' 'D24' 'D32' 'E8' 'E6' 'D27' 'D17' 'E2' 'EE4' 'E11' 'EE9' 'E16' 'E14' 'E26' 'E25' 'A5' 'A7' 'E29' 'E18' 'E32' 'A10' 'A8' 'A15' 'A25' 'AA23' 'A21' 'AA19' 'A3' 'DD8' 'C32' 'C18' 'C20' 'D6' 'DD4' 'C28' 'C21' 'C16' 'C12' 'C11' 'C9' 'C23' 'C24' 'D2' 'AA1' 'CC3' 'CC7' 'B30' 'BB32' 'B19' 'B21' 'B23' 'B24' 'A32' 'B4' 'B13' 'B17' 'B10' 'B7' 'B5' 'A28'};
    new_keep={'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' 'FT7' 'FC5' 'FC3' 'FC1' 'C1' 'C3' 'C5' 'T7' 'TP7' 'CP5' 'CP3' 'CP1' 'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'Fp2' 'AF8' 'AF4' 'AFz' 'Fz' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6' 'FC4' 'FC2' 'FCz' 'Cz' 'C2' 'C4' 'C6' 'T8' 'TP8' 'CP6' 'CP4' 'CP2' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2'};
    % Cz=A1 Pz=A19 Oz=A23 T8=B32 C4 =C7 Fz=D4 FPz=D8 C3=E4 T7=E9
    for c=1:length(old)%updating channel names to prefent duplicates
        for n=1:length(ORGEEG.chanlocs)
            if strcmp(ORGEEG.chanlocs(n).labels, old{c})
                ORGEEG.chanlocs(n).labels = new{c};
            end
        end
    end
    if strcmp(methode, 'keep') %for this one we need to skip the iterpolation
        %need the chose 160 channels in the 64 channel order
        data=ORGEEG.data([105;118;116;109;115;120;128;136;134;123;113;130;132;139;137;144;142;154;153;5;7;157;146;160;10;8;15;25;23;21;19;3;104;96;82;84;102;100;92;85;80;76;75;73;87;88;98;1;67;71;62;64;51;53;55;56;32;36;45;49;42;39;37;28],:);
        ORGEEG = pop_select( ORGEEG, 'channel',{'AA1','A3','A5','A7','A8','A10','A15','AA19','A21','AA23','A25','A28','A32','B4','B5','B7','B10','B13','B17','B19','B21','B23','B24','B30','BB32','CC3','CC7','C9','C11','C12','C16','C18','C20','C21','C23','C24','C28','C32','D2','DD4','D6','DD8','D9','D13','D17','D19','D20','D22','D24','D27','D32','E2','EE4','E6','E8','EE9','E11','E14','E16','E18','E25','E26','E29','E32'});
       %                                         {'A1',                                  'A19'       'A23'                                                                                  'B32'  'C3'  'C7'                                                                       'D4'       'D8'  'E4'                                                                     'E9'  'C1'  'C2'  'C3'  'C4'  'C5'  'C6'};
    else
        
        [ORGEEG] = pop_interp(ORGEEG, newchan, 'spherical');
    end
    %% giving the right urchan to the new ones
    if strcmp(methode, 'keep') %for this one we need to look for different channels then the rest
        ORGEEG.data = data;
    else
        for u=1:length(ORGEEG.chanlocs)
            for c=1:length(final)%updating channel names to prefent duplicates
                for n=1:length(ORGEEG.chanlocs)
                    if strcmp(ORGEEG.chanlocs(n).labels, final{c})
                        urch = ORGEEG.chanlocs(n).urchan;
                    end
                end
                for n=1:length(ORGEEG.chanlocs)
                    if strcmp(ORGEEG.chanlocs(n).labels, new{c}) %looking for the old channels
                        ORGEEG.chanlocs(n).urchan = urch; %updating their lables with the new name
                    end
                    
                end
            end
        end
    end
    %% Only selecting the right channels
    % ORGEEG = pop_select( ORGEEG, 'channel',{'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' 'FT7' 'FC5' 'FC3' 'FC1' 'C1' 'EE4' 'C5' 'EE9' 'TP7' 'CP5' 'CP3' 'CP1' 'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'AA23' 'POz' 'AA19' 'CPz' 'DD8' 'Fp2' 'AF8' 'AF4' 'AFz' 'DD4' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6' 'FC4' 'FC2' 'FCz' 'AA1' 'C2' 'CC7' 'C6' 'BB32' 'TP8' 'CP6' 'CP4' 'CP2' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2'});
    if strcmp(methode, 'interpolate')
        ORGEEG = pop_select( ORGEEG, 'nochannel',{'AA1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10', 'A11', 'A12', 'A13', 'A14', 'A15', 'A16', 'A17', 'A18', 'AA19', 'A20', 'A21', 'A22', 'AA23', 'A24', 'A25', 'A26', 'A27', 'A28', 'A29', 'A30', 'A31', 'A32', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11', 'B12', 'B13', 'B14', 'B15', 'B16', 'B17', 'B18', 'B19', 'B20', 'B21', 'B22', 'B23', 'B24', 'B25', 'B26', 'B27', 'B28', 'B29', 'B30', 'B31', 'BB32', 'CC1', 'CC2', 'CC3', 'CC4', 'CC5', 'CC6', 'CC7' 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16', 'C17', 'C18', 'C19', 'C20', 'C21', 'C22', 'C23', 'C24', 'C25', 'C26', 'C27', 'C28', 'C29', 'C30', 'C31', 'C32', 'D1', 'D2', 'D3', 'DD4', 'D5', 'D6', 'D7', 'DD8', 'D9', 'D10', 'D11', 'D12', 'D13', 'D14', 'D15', 'D16', 'D17', 'D18', 'D19', 'D20', 'D21', 'D22', 'D23', 'D24', 'D25', 'D26', 'D27', 'D28', 'D29', 'D30', 'D31', 'D32', 'E1', 'E2', 'E3', 'EE4', 'E5', 'E6', 'E7', 'E8', 'EE9', 'E10', 'E11', 'E12', 'E13', 'E14', 'E15', 'E16', 'E17', 'E18', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24', 'E25', 'E26', 'E27', 'E28', 'E29', 'E30', 'E31', 'E32'});
    elseif strcmp(methode, 'keep')
        for c=1:length(old_keep)%updating channel names to final names
            for n=1:length(ORGEEG.chanlocs)
                if strcmp(ORGEEG.chanlocs(n).labels, old_keep{c})
                    ORGEEG.chanlocs(n).labels = new_keep{c};
                    ORGEEG.chanlocs(n).urchan=c;
                end
            end
        end
    else
        disp('error no methode was inputted')
    end
elseif n_new_chan == 160
    old={  'Cz'   'Pz'   'Oz'   'T8'   'C4'  'Fz'  'Fpz' 'C3'  'T7'  'C1'  'C2'  'C5'  'C6'};
    new = {'AA1', 'AA19' 'AA23' 'BB32' 'CC7' 'DD4' 'DD8' 'EE4' 'EE9' 'CC1' 'CC2' 'CC5' 'CC6'};   
    for c=1:length(old)%updating channel names to prefent duplicates
        for n=1:length(ORGEEG.chanlocs)
            if strcmp(ORGEEG.chanlocs(n).labels, old{c}) %looking for the old channels
                ORGEEG.chanlocs(n).labels = new{c}; %updating their lables with the new name
            end
        end
    end
    [ORGEEG] = pop_interp(ORGEEG, newchan, 'spherical'); % to create the extra channels (also needed for keep)
    %% only selecting the ones you need
    if strcmp(methode, 'interpolate')
        ORGEEG = pop_select( ORGEEG, 'nochannel',{'Fp1', 'AF7', 'AF3', 'F1', 'F3', 'F5', 'F7', 'FT7', 'FC5', 'FC3', 'FC1', 'CC1', 'EE4', 'CC5', 'EE9', 'TP7', 'CP5', 'CP3', 'CP1', 'P1', 'P3', 'P5', 'P7', 'P9', 'PO7', 'PO3', 'O1', 'Iz', 'AA23', 'POz', 'AA19', 'CPz', 'DD8', 'Fp2', 'AF8', 'AF4', 'AFz', 'DD4', 'F2', 'F4', 'F6', 'F8', 'FT8', 'FC6', 'FC4', 'FC2', 'FCz', 'AA1', 'CC2','CC7', 'CC4', 'CC6', 'BB32', 'TP8', 'CP6', 'CP4', 'CP2', 'P2', 'P4', 'P6', 'P8', 'P10', 'PO8', 'PO4', 'O2'});
    elseif strcmp(methode, 'keep')
        %% need to find the 64channels to delete; all from the 64chan except the equivalents (A1 should go not Cz)
     new_del={'D9' 'D22' 'D20' 'D13'  'D19' 'D24' 'D32' 'E8' 'E6' 'D27' 'D17' 'E2' 'E4' 'E11' 'E9' 'E16' 'E14' 'E26' 'E25' 'A5' 'A7' 'E29' 'E18' 'E32' 'A10' 'A8' 'A15' 'A25' 'A23' 'A21' 'A19' 'A3' 'D8' 'C32' 'C18' 'C20' 'D6' 'D4' 'C28' 'C21' 'C16' 'C12' 'C11' 'C9' 'C23' 'C24' 'D2' 'A1' 'C3' 'C7' 'B30' 'B32' 'B19' 'B21' 'B23' 'B24' 'A32' 'B4' 'B13' 'B17' 'B10' 'B7' 'B5' 'A28'};
     old_keep={'Fp1' 'AF7' 'AF3' 'F1' 'F3' 'F5' 'F7' 'FT7' 'FC5' 'FC3' 'FC1' 'CC1' 'EE4' 'CC5' 'EE9' 'TP7' 'CP5' 'CP3' 'CP1' 'P1' 'P3' 'P5' 'P7' 'P9' 'PO7' 'PO3' 'O1' 'Iz' 'AA23' 'POz' 'AA19' 'CPz' 'DD8' 'Fp2' 'AF8' 'AF4' 'AFz' 'DD4' 'F2' 'F4' 'F6' 'F8' 'FT8' 'FC6' 'FC4' 'FC2' 'FCz' 'AA1' 'CC2' 'CC7' 'CC6' 'BB32' 'TP8' 'CP6' 'CP4' 'CP2' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO8' 'PO4' 'O2'};
         for c=1:length(new_del)%updating channel names to final names
            for n=1:length(ORGEEG.chanlocs)
                if strcmp(ORGEEG.chanlocs(n).labels, new_del{c}) %looking for the new names
                    urchan=ORGEEG.chanlocs(n).urchan;
                end
            end
            for n=1:length(ORGEEG.chanlocs)
                if strcmp(ORGEEG.chanlocs(n).labels, old_keep{c}) %looking for the new names
                    ORGEEG.chanlocs(n).urchan=urchan;
                end
            end
         end
        ORGEEG = pop_select( ORGEEG, 'nochannel',{'D9' 'D22' 'D20' 'D13'  'D19' 'D24' 'D32' 'E8' 'E6' 'D27' 'D17' 'E2' 'E4' 'E11' 'E9' 'E16' 'E14' 'E26' 'E25' 'A5' 'A7' 'E29' 'E18' 'E32' 'A10' 'A8' 'A15' 'A25' 'A23' 'A21' 'A19' 'A3' 'D8' 'C32' 'C18' 'C20' 'D6' 'D4' 'C28' 'C21' 'C16' 'C12' 'C11' 'C9' 'C23' 'C24' 'D2' 'A1' 'C3' 'C7' 'B30' 'B32' 'B19' 'B21' 'B23' 'B24' 'A32' 'B4' 'B13' 'B17' 'B10' 'B7' 'B5' 'A28'});
        for c=1:length(new_del)%updating channel names to final names
            for n=1:length(ORGEEG.chanlocs)
                if strcmp(ORGEEG.chanlocs(n).labels, old_keep{c}) %looking for the new names
                   ORGEEG.chanlocs(n).labels = new_del{c}; % updating them with their final names
                end
            end
         end
        %% moving the ORGEEG to correct location
       ORGEEG.data= [[ORGEEG.chanlocs.urchan].',ORGEEG.data];
       ORGEEG.data=sortrows(ORGEEG.data,1);
       ORGEEG.data=ORGEEG.data(:,2:end);
    end
end
[~,index] = sortrows([ORGEEG.chanlocs.urchan].'); ORGEEG.chanlocs = ORGEEG.chanlocs(index);clear index
EEG = ORGEEG;
end