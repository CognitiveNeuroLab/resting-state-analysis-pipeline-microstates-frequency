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

This is still a work in progress. This Repo will contain the full pipeline to analyse resting state data, in Matlab using EEGlab. The pipeline will contain everything from pre-processing to creating microstates and doing a power/frequency analysis. This  is work from [Ana Francisco](https://github.com/anafrancisco) [Douwe Horsthuis](https://github.com/DouweHorsthuis) and [Filip de Sanctis](https://github.com/pdesanctis) 




**Table of Contents**
1. [About The Project](#about-the-project)  
2. [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)  
3. [Resting state project](#resting-state-project)
3. [Pipeline](#pipeline)  
    - [Raw data to .set and merge](#raw-data-to-.set-and-merge)
    - [Pre processing](#pre-processing)  
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
Explain here what the paradigm is and why some of the data does not have a paradigm. 

### Groups  
Explain what groups we have and maybe why

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
We apply a 1Hz (filter order 1690) and 50Hz (filter order 136) filter.
We add channel info to all the channel. For this we use the following 3 files: standard-10-5-cap385, Cap160_fromBESAWebpage, BioSemi64. The first 2 are from BESA and have the correct layout. The 3rd is needed for the MoBI data. You can find these in the Functions and files folder (inside the src folder).  
Lastly this script uses eeglab's clean_artifacts function deletes the bad channels. Channels will get deleted by the standard noise criteria, if they are flat over 4 seconds and the function checks if channels are overly correlated with each other. **double check this last statement**

#### C_manual_check
This script plots all the data in EEGlab as continues data and allows you to delete channels manually. 

#### D_preprocces2
This script will double check and fix any potential trigger issue we encountered. It saves a Matrix with the information for each individual participant. 

#### E_preprocces3
This script will do an average reference.  
This is followed by an [Independent Component Analysis](https://eeglab.org/tutorials/06_RejectArtifacts/RunICA.html). We use the pca option to prevent rank-deficiencies.
After his we delete only eye components by using [IClabel](https://github.com/sccn/ICLabel). IClabel will only delete the component if it has more than 80% eye data and less then 5% brain data. 
After that we use [pop_rejcont](https://github.com/wojzaremba/active-delays/blob/master/external_tools/eeglab11_0_4_3b/functions/popfunc/pop_rejcont.m). This function epochs the data temporatly and deletes the epochs that are noisy. We set this to a threshold of 8, because this would delete between 0-20% of the data. We save a matlab structure with how much data of each participant get's deleted. 

**note** for the Aging group, we use the [pop_rejcont](https://github.com/wojzaremba/active-delays/blob/master/external_tools/eeglab11_0_4_3b/functions/popfunc/pop_rejcont.m) function also right before the ICA. This is because the data was too noisy for more than 50% of the participants to find eye components. 

#### F_preprocces4
This script loads a file with all the original channels, deletes the externals and uses these file locations to interpolate the channels of the corresponding's subjects data.  
In the case of 160 channel data, it uses the [transform_n_channels](https://github.com/CognitiveNeuroLab/Interpolating_160ch_to_64ch_eeglab) function to interpolate the remaining channels not to the original 160, but to 64 channel data so that it is the same as all the other data. For this to work Matlab needs to know the location of 2 things, the trannsform_n_channel.m file and the EEG files called 64.set and 64.fdt.

### Power Frequency Analysis
In the G_PSD_pwelsh script, we first make sure that the triggers are still in the right place. Due to the extra cleaning we did with the pop_rejcont function in [E_preprocces3](#e_preprocces3) it is possible that the triggers got deleted if the corresponding continues data were too noisy. If they got deleted, the scripts calculates what the time of the onset of that deleted part of data was and uses that instead as the latency of the trigger. 

After that we use the the [pwelch function of Matlab](https://www.mathworks.com/help/signal/ref/pwelch.html) and a log tranformation of the results to get the power frequency results.  

# add here what channels we use, for now it's just indivual but we will change this to groups and averages of those groups

### Microstates
this script follows the code as descibed in Poulsen, A. T., Pedroni, A., Langer, N., & Hansen, L. K. (2018). Microstate EEGlab toolbox: An introductory guide.



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
