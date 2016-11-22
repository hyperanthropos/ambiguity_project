# madleine

### cognitive neuroscience project

using matlab with internal as well es external toolboxes, notably ["Statistical Parametric Mapping"] (http://www.fil.ion.ucl.ac.uk/spm/software/) and ["Psychtoolbox"] (http://psychtoolbox.org)

### this repository contains

- [x] code for behavioral experiments

    - experiment 1 can be started with the [presentation_wrapper.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/presentation_wrapper.m)
	* contains settings to allow for highly customizable stimuli to be created as defined by [stimuli.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/stimuli.m)
	* also contains [asjust_variance.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/assisting_scripts/adjust_variance.m) code to match trials in expected value and variance
	* task and timing parameters can be set in the [presentation.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/presentation.m) script, presentation of stimuli can further be configured in the [draw_stims.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/draw_stims.m) and [draw_stims_colors.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/draw_stims_colors.m), respectively
	* the [create_reward_file.m] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/task/create_reward_file.m) function can further be called to directly calulate individual ourpayment based on subjects responses

- [x] code to analyse behavioral data

    - create parameters of individual subjects analysing the logfiles of behavioral data for [experiment 1] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral_analysis/parameter_creation.m)
    - create group level graph and statistics out of individual parameters for [experiment 1] (https://github.com/hyperanthropos/madeleine/blob/master/behavioral/experiment_1/analysis/parameter_analysis.m)

---

- [ ] an fMRI task to evoke and collect neural data

- [ ] code for behavioral analysis of fMRI task data

    - creates regressors used as parametric modulations in the GLM to analyse BOLD data
    - creates labels and data structures for machine learning approaches to classify neural response
  
- [ ] code for neural analysis of fMRI data
