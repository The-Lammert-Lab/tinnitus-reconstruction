# Power Distribution Stimulus Generation

This is a stimulus generation method in which the frequencies in each bin are sampled from a power distribution learned from tinnitus examples. 

-------

### build_distribution

Builds the default power distribution from ATA tinnitus sample files.
Saves the distribution as a vector in dB
and the corresponding frequency vector.

Arguments:
save_path : character vector, default: pathlib.join(fileparts(mfilename('fullpath')), 'distribution.mat');
Path to .mat file where distribution should be saved.

Returns:
distribution : numeric vector
Power distribution in dB.



!!! info "See Also"
    * [PowerDistributionStimulusGeneration.from_file,](../PowerDistributionStimulusGeneration/#from_file,)
    * [PowerDistributionStimulusGeneration.generate_stimulus](../PowerDistributionStimulusGeneration/#generate_stimulus)





-------

### from_file

Loads a power distribution from a .mat or .csv file into the object.



!!! info "See Also"
    * [PowerDistributionStimulusGeneration.build_distribution](../PowerDistributionStimulusGeneration/#build_distribution)





-------

### generate_stimulus

[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)


Generates stimuli by assigning the power in each bin
by sampling from a power distribution
learned from ATA tinnitus examples.

Returns:
stim: n x 1 numerical vector
The stimulus waveform,
where n is self.get_nfft() + 1.
Fs: 1x1 numerical scalar
The sample rate in Hz.
spect: m x 1 numerical vector
The half-spectrum,
where m is self.get_nfft() / 2,
in dB.
binned_repr: self.n_bins x 1 numerical vector
The binned representation.
frequency_vector: m x 1 numerical vector
The frequencies associated with the spectrum,
where m is self.get_nfft() / 2,
in Hz.

Class Properties Used:
n_bins



