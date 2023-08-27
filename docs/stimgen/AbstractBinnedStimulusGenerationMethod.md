# Abstract Binned Stimulus Generation Method 
 
Abstract class describing all features common to a stimulus generation method that uses a binned representation of the signal.

### Abstract Properties

This property is automatically instantiated for subclasses, since they are not abstract themselves. Default value is given:

```
- n_bins = 100
```

### get_freq_bins

```matlab
[binnum, Fs, nfft, frequency_vector] = self.get_freq_bins()
```

Generates a vector indicating
which frequencies belong to the same bin,
following a tonotopic map of audible frequency perception.

**OUTPUTS:**

- binnum: `n x 1` numerical vector
that contains the mapping from frequency to bin number
e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`

- Fs: `1x1` numerical scalar,
the sampling rate in Hz

- nfft: `1x1` numerical scalar,
the number of points of the full FFT

- frequency_vector: `n x 1` numerical vector.
the frequencies that `binnum` maps to bin numbers



!!! info "See Also"
    * [AbstractStimulusGenerationMethod.get_fs](../AbstractStimulusGenerationMethod/#get_fs)
    * [AbstractStimulusGenerationMethod.get_nfft](../AbstractStimulusGenerationMethod/#get_nfft)





### get_empty_spectrum

```matlab
[spect] = self.get_empty_spectrum()
```

**OUTPUTS:**

- spect: `n x 1` numerical vector,
where `n` is equal to the number of fft points (nfft)
and all values are set to -100 dB.



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)





### spect2binnedrepr

Get the binned representation
which is a vector containing the amplitude
of the spectrum in each frequency bin.

**ARGUMENTS:**

- T: `n_frequencies x n_trials` matrix
representing the stimulus spectra

**OUTPUTS:**

- binned_repr: `n_trials x n_bins` matrix
representing the amplitude for each frequency bin
for each trial



!!! info "See Also"
    * [binnedrepr2spect](../../utils/#binnedrepr2spect)
    * [spect2binnedrepr](../../utils/#spect2binnedrepr)
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2wav](../AbstractBinnedStimulusGenerationMethod/#binnedrepr2wav)





### binnedrepr2spect

Get the stimuli spectra from a binned representation.

**ARGUMENTS:**

- binned_repr: `n_bins x n_trials`
representing the amplitude in each frequency bin
for each trial

**OUTPUTS:**

- T: `n_frequencies x n_trials`
representing the stimulus spectra



!!! info "See Also"
    * [binnedrepr2spect](../../utils/#binnedrepr2spect)
    * [spect2binnedrepr](../../utils/#spect2binnedrepr)
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2wav](../AbstractBinnedStimulusGenerationMethod/#binnedrepr2wav)





### binnedrepr2wav

Get the peak-sharpened waveform of a binned representation 

**ARGUMENTS:**

- binned_repr: `n_bins x 1` numerical vector
representing the amplitude in each frequency bin.
- mult: `1 x 1` scalar, the peak sharpening factor.
- binrange: `1 x 1` scalar, must be between [1, 100],
the upper bound of the dynamic range of the 
stimuli from [0, binrange]
- new_n_bins: `1 x 1` scalar, default: 256,
the number of bins to upsample to before synthesis.

**OUTPUTS:**

- wav: `nfft+1 x 1` numerical vector
representing the upsampled, peak-sharpened, 
wavform of the binned representation.



!!! info "See Also"
    * [binnedrepr2spect](../../utils/#binnedrepr2spect)
    * [spect2binnedrepr](../../utils/#spect2binnedrepr)





### bin_signal

```matlab
W = self.bin_signal(W)
```

Inputs a waveform,
converts to a spectrum,
bins the spectrum,
and then converts back to a waveform.

**ARGUMENTS:**

W: `n x 1` numerical vector,
the waveform
Fs: `1x1` numerical scalar,
the sample rate



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2spect](../AbstractBinnedStimulusGenerationMethod/#binnedrepr2spect)
    * [AbstractBinnedStimulusGenerationMethod.spect2binnedrepr](../AbstractBinnedStimulusGenerationMethod/#spect2binnedrepr)
    * [signal2spect](../../utils/#signal2spect)



