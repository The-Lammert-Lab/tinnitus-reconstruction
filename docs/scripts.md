# Scripts

Housed within this folder are data processing and analysis scripts. 

### adjust_individual_resynth
A simple script to run the adjustment protocol for a given config file





-------

### analyze_consistency 
This script compares the consistency in reconstructions from 
data collected several days in a row by NB with all settings the same

Setup





-------

### analyze_phase2
This script contains two different analysis options
for assessing the functionality of a "phase 2" in RC experiments.
Phase 2 consists of taking the original/standard RC reconstruction
and using it as the basis for generating new stimuli.
Those options can be seen in the local function `local_create_files_and_stimuli_phaseN`





-------

### compare_norena
Run simulated observer on Norena stimgen 
and two UniformPrior options (1 bin filled and multiple bins filled)
and visualize the results





-------

### compare_recons
The purpose of this script is to assess the qualitative effect of the
peak-sharpening procedure. 
Runs adjust_resynth.m followed by follow_up.m on select
configs/associated data.





-------

### compare_stim_and_recon
Runs the simulated observer on two UniformPrior options 
(1 bin filled and multiple bins filled) and uses several
different reconstruction methods (ten scale, ridge regression, linear)
and visualizes the results





-------

### hyperparameter_sweep_custom

Hyperparameter Sweep Custom Stimulus

Evaluate hyperparameters of stimulus generation using the 'custom' stimulus paradigm.
Evaluate hyperparameters over different target signals.





-------

### optimize_hierGauss
Run a grid search on HierarchicalGaussian stimgen parameters
to determine the best combination of broad, medium, and narrow bases.





-------

### optimize_resynth
Determine the best mult and binrange parameters for resynthesis. 
This can be used to extrapolate a good range 
to present to subjects for a given bin number.





-------

### patient_reconstructions
Generate reconstructions and visualizatinos for non-target sound data
Includes lots of flags for response prediction analysis
NOTE: should also work with make_figures_paper2 (not recently tested though)





-------

### pilot_reconstructions

Compute reconstructions for the pilot data experiment (with target signal).
This code assumes that each each experiment uses the same number of bins 
and that the reconstructions should be done over the bin representation.

**OUTPUTS:**
- T: a data table that contains information about the experiments and their reconstructions





-------

### predict_on_TSFdata
Run just the cross validation section on data used to train ML model
Uses data formatted to be digestable by the TinnitusStimulusFitter package.





-------

### reconstruction_viz
Visualization for reconstructions
Run ``pilot_reconstructions.m`` first to generate recons, etc.





-------

### survey_viz
This script collects and analyzes subjective rankings from ompare_recons.m





-------

## target_signal_sparsity
Quantify the sparsity of the target signals (ATA tinnitus examples)
in the DCT basis.



