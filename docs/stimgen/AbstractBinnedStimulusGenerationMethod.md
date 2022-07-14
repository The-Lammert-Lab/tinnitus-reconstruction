# Abstract Binned Stimulus Generation Method 
 
Abstract class describing a stimulus generation method that uses bins.

### get_freq_bins

[binnum, Fs, nfft, frequency_vector] = self.get_freq_bins()  

Outputs:

binnum: n x 1 numerical vector
Contains the mapping from frequency to bin number
e.g., [1, 1, 2, 2, 2, 3, 3, 3, 3, ...]

Fs: 1x1 numerical scalar
Sampling rate in Hz

nfft: 1x1 numerical scalar
Number of points of the full FFT

frequency_vector: n x 1 numerical vector
Frequencies that `binnum` maps to bin numbers

Generates a vector indicating
which frequencies belong to the same bin,
following a tonotopic map of audible frequency perception.



!!! info "See Also"
    * [get_fs](../AbstractStimulusGenerationMethod/AbstractStimulusGenerationMethod.get_fs)
    * [get_nfft](../AbstractStimulusGenerationMethod/AbstractStimulusGenerationMethod.get_nfft)





### get_empty_spectrum

[spect] = self.get_empty_spectrum();

Returns:
spect: n x 1 numerical vector
where n is equal to the number of fft points (nfft).

Returns a spectrum vector of the correct size
with all values set to -100 dB.



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)





### spect2binnedrepr

Get the binned representation
which is a vector containing the amplitude
of the spectrum in each frequency bin.

ARGUMENTS:

T: n_frequencies x n_trials
representing the stimulus spectra

OUTPUTS:

binned_repr: n_trials x n_bins matrix
representing the amplitude for each frequency bin
for each trial



!!! info "See Also"
    * [binnedrepr2spect](../../utils/#binnedrepr2spect)
    * [spect2binnedrepr](../../utils/#spect2binnedrepr)





### binnedrepr2spect

Get the stimuli spectra from a binned representation.

ARGUMENTS:
binned_repr: n_bins x n_trials
representing the amplitude in each frequency bin
for each trial

OUTPUTS:
T: n_frequencies x n_trials
representing the stimulus spectra



!!! info "See Also"
    * [binnedrepr2spect](../../utils/#binnedrepr2spect)
    * [spect2binnedrepr](../../utils/#spect2binnedrepr)





### bin_signal

W = self.bin_signal(W);

Inputs a waveform
converts to a spectrum
bins the spectrum
and then converts back to a waveform.

ARGUMENTS:
W: n x 1 numerical vector
the waveform
Fs: 1x1 numerical scalar
the sample rate



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2spect](../AbstractBinnedStimulusGenerationMethod/#binnedrepr2spect)
    * [AbstractBinnedStimulusGenerationMethod.spect2binnedrepr](../AbstractBinnedStimulusGenerationMethod/#spect2binnedrepr)
    * [signal2spect](../../utils/#signal2spect)


