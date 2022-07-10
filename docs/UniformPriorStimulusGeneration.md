# Uniform Prior Stimulus Generation

This is a stimulus generation method in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`.

-------

### generate_stimulus

[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)


Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
amplitudes based on a tonotopic map of audible frequency perception.

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
n_bins_filled_mean
n_bins_filled_var



