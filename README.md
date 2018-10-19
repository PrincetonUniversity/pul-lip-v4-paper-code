# Analysis and Figures for Pulvinar, LIP, V4 Manuscript

These Matlab scripts compute the stats and generate the figures used in the manuscript: 

Saalmann YB, Ly R, Pinsk MA, Kastner S. (in review). Pulvinar influences parietal delay activity and information transmission between dorsal and ventral visual cortex in macaques. Preprint: https://www.biorxiv.org/content/early/2018/08/31/405381

The analysis pipeline makes use of the [Chronux](http://chronux.org/) toolbox. 

## Setup

Until the data are publicly released, please contact rly@princeton.edu for access to the data. In `config.m`, set the variable `ENV.dataDir` to the path to the data. Then navigate to the repo root directory in Matlab, and run `config` to set up the workspace.

## Figures

### Figure 3: Delay period spiking activity in LIP, pulvinar, and V4

Run the script `runSpdfsAndDelayPeriodFRStats` from any directory. Figures will be generated in `{root_dir}/firing_rate_analysis/figures/`.

This script also computes and prints out the reported statistics of attentional modulation of delay period spiking in each area. 

## Contact

Please contact rly@princeton.edu with any questions. 
