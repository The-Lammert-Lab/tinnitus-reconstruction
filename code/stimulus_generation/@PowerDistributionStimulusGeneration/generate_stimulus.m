function [stim, Fs, X, binned_repr] = generate_stimulus(self)
    % Generates stimuli by assigning the power in each bin
    % by sampling from a power distribution
    % learned from ATA tinnitus examples.
    % 
    % Class Properties Used:
    %   n_bins

    if isempty(self.distribution)
        error("self.distribution must not be empty!")
    end

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft] = self.get_freq_bins();

    % 