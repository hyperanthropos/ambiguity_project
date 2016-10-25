# madleine

### cognitive neuroscience project

using matlab with internal as well es external toolboxes, notably ["Statistical Parametric Mapping"] (http://www.fil.ion.ucl.ac.uk/spm/software/) and ["Psychtoolbox"] (http://psychtoolbox.org)

### this repository contains

- [x] a behavioral pilot task

    - can be started with the [presentation_wrapper.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral_pilot/presentation_wrapper.m)
  
- [x] code to analyse pilot data

    - create parameters of individual subjects analysing the logfiles of behavioral data [link] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral_analysis/parameter_creation.m)
    - create groups level graph and statistics out of individual parameters [link] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral_analysis/parameter_analysis.m)

- [ ] an fMRI task to evoke and collect neural data
- [ ] code for behavioral analysis of fMRI task data

    - creates regressors used as parametric modulations in the GLM to analyse BOLD data
    - creates labels for machine learning approaches to classify neural response
  
- [ ] code for neural analysis of fMRI data
