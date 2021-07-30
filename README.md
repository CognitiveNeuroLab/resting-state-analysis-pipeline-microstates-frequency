[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]




<br />
<p align="center">
  <a href="https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/">
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
3. [Pipeline](#roadmap)  
    - [Raw data to .set and merge](#raw-data-to-.set-and-merge)
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
Then there is the A_bdf_non_paradigm_merge_sets. Since some of the data is collected without a paradigm but is saved into 2 separate files without triggers, this script solves that. It loads the .bdf file that ends in _open.bdf and adds a eyes open trigger to the start. It does the same for the .bdf file eding in _closed with the exception that here it adds and eyes closed trigger. 
Lastly it merges the two files into one.  

#### A_XDF_merge_sets
The third script load XDF files. These are files that have both EEG data and [Optitrack](https://optitrack.com/) movement data.  
This script loads the xdf file (1 file per participant) and deletes the data that is not in the EEG channels or in the first channel.
The first channel has all the trigger info. The script uses this channel to add the trigger to the EEG data.  

### Pre processing
#### B_preprocess1
This script is the first of the pre-processing scripts. It runs all the people in order of their group.  
One of the issues we encounterd was that some participants had their data collected using the wrong configuration file. This is taken care of.  
The data is downsampled from 512Hz to 256 Hz.  
Externals are all deleted since not everyone has externals. So we cannot use them as a reference.  
We apply a 1Hz (filter order 1690) and 50Hz (filter order 136) filter.
We add channel info to all the channel. For this we use the following 3 files: standard-10-5-cap385, Cap160_fromBESAWebpage, BioSemi64. The first 2 are from BESA and have the correct layout. The 3rd is needed for the MoBI data.  
Lastly this script uses eeglab's clean_artifacts function deletes the bad channels. Channels will get deleted by the standard noise criteria, if they are flat over 4 seconds and the function checks if channels are overly correlated with eachother. **double check this last statement**

#### C_manual_check
This script plots all the data in EEGlab as continues data and allowes you to delete channels manually. 

#### D_preprocces2
This script will double check and fix any potential trigger issue we encountered. It saves a Matrix with the information for each indiviual participant. 

#### E_preprocces3
This script will do an average reference.  
This is followed by an [Independent Component Analysis](https://eeglab.org/tutorials/06_RejectArtifacts/RunICA.html) 
After his we delete only eyecompenents by using [IClabel](https://github.com/sccn/ICLabel). IClabel will only delete the component if it has more than 80% eye data and less then 5% brain data. 

#### F_epoching
Continue here

<!--
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



## License

Distributed under the MIT License. See `LICENSE` for more information.



## Contact

Your Name - [@douwejhorsthuis](https://twitter.com/douwejhorsthuis) - douwehorsthuis@gmail.com

Project Link: [https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/](https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/)




## Acknowledgements

* []()
* []()
* []()



-->

[contributors-shield]: https://img.shields.io/github/contributors/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[contributors-url]: https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[forks-url]: https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/network/members
[stars-shield]: https://img.shields.io/github/stars/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[stars-url]: https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/stargazers
[issues-shield]: https://img.shields.io/github/issues/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[issues-url]: https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/issues
[license-shield]: https://img.shields.io/github/license/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency.svg?style=for-the-badge
[license-url]: https://github.com/DouweHorsthuis/resting-state-analysis-pipeline-microstates-frequency/blob/master/LICENSE.txt
