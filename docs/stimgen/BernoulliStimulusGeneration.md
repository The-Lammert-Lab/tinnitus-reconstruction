# Bernoulli Stimulus Generation

This is a stimulus generation method in which each tonotopic bin has a probability `p` of being at 0 dB, otherwise it is at -20 dB.

-------

### generate_stimulus

[stim, Fs, X, binned_repr] = generate_stimulus(self)

Generate a matrix of stimuli
where the matrix is of size nfft x n_trials.
Bins are filled with an an amplitude of -20 or 0.
Each bin is randomly filled with a change of being filled
(amplitude = 0) with a probability of `self.bin_prob`.

Class Properties Used:
`n_bins`
`bin_prob`



