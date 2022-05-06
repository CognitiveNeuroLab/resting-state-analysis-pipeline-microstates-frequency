[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]




<br />
<p align="center">
  <a href="https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/">
    <img src="images/logo.jpeg" alt="Logo" width="160" height="160">
  </a> 

<h3 align="center">Resting state - Pre-process/Microstates/PowerFrequency</h1>

## About The Project

This is still a work in progress. This Repo will contain the full pipeline to analyse resting state data, in Matlab using EEGlab. The pipeline will contain everything from pre-processing to creating microstates and doing a power/frequency analysis. This  is work from [Ana Francisco](https://github.com/anafrancisco) [Douwe Horsthuis](https://github.com/DouweHorsthuis) and [Filip de Sanctis](https://github.com/pdesanctis) in discussion with Sophie Molholm. 




**Table of Contents**
1. [About The Project](#about-the-project)  
2. [Getting started](#getting-started)  
    - [Prerequisites](#prerequisites)  
3. [Resting state project](#resting-state-project)  
3. [Pipeline](#pipeline)
    - [Raw data to .set and merge](#raw-data-to-.set-and-merge)  
    - [Pre processing](#pre-processing) 
3. [Power Frequency Analysis](#power-frequency-analysis)  
3. [Microstates](#microstates)  
    - [I_Mictrostates_groups](#i-mictrostates-groups)  
    - [I_Mictrostates_all](#i-mictrostates-all)
3. [Extra functions](#extra-functions)
3. [License](#license)  
3. [Contact](#contact)  
3. [Acknowledgement](#acknowledgement)  



### Built With

* [Matlab](https://www.mathworks.com/)
* [EEGlab](https://sccn.ucsd.edu/eeglab/index.php)


## Getting Started

All of these scripts are created to run in matlab. They use EEGlab 

### Prerequisites

* [EEGlab](https://sccn.ucsd.edu/eeglab/index.php)
* [ERPlab](https://erpinfo.org/erplab) (eeglab plugin)
* [XDFimport](http://sccn.ucsd.edu/eeglab/plugins/xdfimport1.14.zip) (eeglab plugin)
* [IClabel](https://github.com/sccn/ICLabel) (eeglab plugin)

## Resting state project
### Paradigm
This pipeline is build to analyse data collected using the Restingstate paradigm in our lab. This paradigm is essentially a 5 min trial with a fixation cross with the text "Please fixate on the cross" followed by a 5 min trial that has the text "please close your eyes". However, some of our data is collected by telling the participant instead to just look at the center of the screen, or to keep your eyes closed for 5 minutes. For this reason, the pipeline might add the triggers to keep the eyes open and eyes closed data separate.

### Groups  
This data is collected for a lot of different groups. The script is set-up in a way that you can analyse 1 to 3 groups in one go. However, there is room to add another group or simply to run the script again for a different group.

## Pipeline

### Raw data to .set and merge
This is normally pretty straight forward in EEGlab. But in this case we have 3 different scripts, or variations of the same script.  

#### A_bdf_merge_sets
The mostly used script is the A_bdf_merge_sets. This simply takes the Raw data (.bdf) and turns it into a .set file  

#### A_bdf_non_paradigm_merge_sets
Then there is the A_bdf_non_paradigm_merge_sets. Since some of the data is collected without a paradigm but is saved into 2 separate files without triggers, this script solves that. It loads the .bdf file that ends in _open.bdf and adds a eyes open trigger to the start. It does the same for the .bdf file ending in _closed with the exception that here it adds and eyes closed trigger. 
Lastly it merges the two files into one.  

#### A_XDF_merge_sets
The third script load XDF files. These are files that have both EEG data and [Optitrack](https://optitrack.com/) movement data.  
This script loads the xdf file (1 file per participant) and deletes the data that is not in the EEG channels or in the first channel.
The first channel has all the trigger info. The script uses this channel to add the trigger to the EEG data.  

### Pre processing
#### B_preprocess1
This script is the first of the pre-processing scripts. It runs all the people in order of their group.  
One of the issues we encountered was that some participants had their data collected using the wrong configuration file. This is taken care of.  
The data is down-sampled from 512Hz to 256 Hz.  
Externals are all deleted since not everyone has externals. So we cannot use them as a reference.  
We apply a 1Hz and 50Hz filter.
We add channel info to all the channel. For this we use the following 3 files: standard-10-5-cap385, BioSemi160, BioSemi64. The first 2 are from BESA and have the correct layout. The 3rd is needed for the MoBI data. You can find these in the Functions and files folder (inside the src folder).  
Lastly this script uses eeglab's clean_artifacts function deletes the bad channels and bad parts of data. Channels will get deleted by the standard noise criteria, if they are flat over 5 seconds and the function checks if channels are overly correlated with each other.After that it devides the data in 0.5 second epochs. In these it looks if there data has peaks that go over 35 standard deviantion of the channels amplitlude. If so these get deleted. Because it's possible that between 2 of these moments there is a very short amount of data, we make sure to delete all the continues data if between 2 boundries there is less then 2 seconds of data. We got to the criteria of 35, because 20 is the default setting, but because resting state data is different from task based data, we had to find out a way that we still had enough data left, without it being noisy. 

#### C_manual_check
This script plots all the data in EEGlab as continues data and allows you to delete channels manually. 

#### D_preprocces2
This script will double check and fix any potential trigger issue we encountered. It saves a Matrix with the information for each individual participant. **This script can be skipped** It is only useful for documenting triggers. ~~We added the [pop_rejcont](https://github.com/wojzaremba/active-delays/blob/master/external_tools/eeglab11_0_4_3b/functions/popfunc/pop_rejcont.m) in the next script and this deletes triggers sometimes, so we need to double check triggers again (see [G_preprocces5](#g_preprocces5)).~~
Since off the 12/6/2021 update this is not the case. The clean_artifacts takes care of noisy continues data. But it might be good to run either script since they are quick. If you want to save time, skip this one.

#### E_preprocces3
This script loads a file with all the original channels, deletes the externals and uses these file locations to interpolate the channels of the corresponding subject's data. In the case of 160 channel data, it uses the [transform_n_channels](https://github.com/CognitiveNeuroLab/Interpolating_160ch_to_64ch_eeglab) function to interpolate the remaining channels not to the original 160, but to 64 channel data so that it is the same as all the other data. For this to work Matlab needs to know the location of 2 things, the trannsform_n_channel.m file and the EEG files called 64.set and 64.fdt.
We chose to interpolate before the ICA because like this we can still use the ICA weights for all the channels, and since we are setting a PCA (amount of ICs we want the ICA funtion to create) we account for the interpolated channels not being used for this. 

This script will do an average reference.  
This is followed by an [Independent Component Analysis](https://eeglab.org/tutorials/06_RejectArtifacts/RunICA.html). We use the pca option to prevent rank-deficiencies, as best as we can. We set it to be all channels before interpolation - 1. We don't want more because this gives "Ghost ICs" that are duplicates of existing ones. We also exclude an extra IC because of the avg ref, hence the -1.
After his we delete eye, muscle and channel noise components by using [IClabel](https://github.com/sccn/ICLabel). IClabel will only delete the component if it has more than 70% eye data or 80% muscle or 70% channel noise and always less then 10% brain data. Normally we only delete eye components (>0.8), and we arrived at this criteria after comparing (for a different dataset) how many components we (Ana, Douwe and Filip) would delete manually and what threshold would get the closest to that. However, since this is different data, and it's un epoched so its harder to clean, we decided to also delete extra components. 


#### G_preprocces4
In this script, we first make sure that the triggers are still in the right place. It is possible that the triggers got deleted if the corresponding continues data were too noisy. If they got deleted, the scripts calculates what the time of the onset of that deleted part of data was and uses that instead as the latency of the trigger. This should already be fixed before, but this is a double check.

### Power Frequency Analysis
 

After that we use the the [pwelch function of Matlab](https://www.mathworks.com/help/signal/ref/pwelch.html) and a log transformation of the results to get the power frequency results.  

for now we are only using 1 pre-selected channel to save data. This data can either be saved as an excel file, which is easy to use for stats in different platforms, or as a table or individual variable in Matlab.


### Microstates
this script follows the code as described in Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018). Microstate EEGlab toolbox: An introductory guide. [See their guide in bioRxiv for more information.](https://www.biorxiv.org/content/10.1101/289850v1)

#### I_Mictrostates_groups
In the We first focuses on the group level. Since we use both eyes open and eyes closed data, we want to check how many microstates are suggested for both, so we can choose the best (same) amount for both. In the case of patient/control group we would need to compare all 4 the suggestions. Running the whole script would take a lot of time that wasn't needed.

#### J_Microstates_all

The second script will backfit the mictrostates on the individual EEGs (since now you know how many microstates you want). Giving both plots per subject and adds data to the EEG structure to do stats on. We select the imporant data of each participant (participant ID, amount of microstates, GFP, Occurence, Duration, Coverage and GEV) and save this in an excel file per group and whether it's eyes open or eyes closed. 

#### Extra functions  
  
Because this script uses both 160 and 64 channel collected with biosemi caps we needed to get the to a same format. To do this we are using the transform_n_channels function [documented here](https://github.com/CognitiveNeuroLab/Interpolating-channels-between-different-cap-sizes). In this case it turns all the 160 channel data into 64 channels. But it will keep the original channels that are closed to the location of the corresponding 64ch cap.

## License

Distributed under the MIT License. See `LICENSE` for more information.



## Contact
Ana Francisco    - ana.alvesfrancisco@einsteinmed.org
Douwe Horsthuis  - douwehorsthuis@gmail.com
Filip De Sanctis - pierfilippo.sanctis@einsteinmed.org


Project Link: [resting-state-analysis-pipeline-microstates-frequency](https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency)



[contributors-shield]: https://img.shields.io/github/contributors/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[contributors-url]: https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[forks-url]: https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/network/members
[stars-shield]: https://img.shields.io/github/stars/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[stars-url]: https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/stargazers
[issues-shield]: https://img.shields.io/github/issues/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[issues-url]: https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/issues
[license-shield]: https://img.shields.io/github/license/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[license-url]: https://github.com/CognitiveNeuroLab/resting-state-analysis-pipeline-microstates-frequency/blob/master/LICENSE.txt
