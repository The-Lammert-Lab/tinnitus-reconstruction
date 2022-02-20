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

    % Get the histogram of the power distribution for binning
    [pdf, bin_edges, bin_id] = histcounts(self.distribution, 16, 'Normalization', 'pdf');
    bin_centers = bin_edges(1) + cumsum(diff(bin_edges)/2);
    pdf = (pdf + 0.01 * mean(pdf));
    pdf = pdf/sum(pdf);
    cdf = cumsum(pdf);

    % Sample power values from the histogram
    r = rand(self.n_bins, 1);
    s = zeros(self.n_bins, 1);
    for ii = 1:length(r)
        [~, idx] = min((cdf - r(ii)) .^ 2);
        s(ii) = bin_centers(idx);
    end

    % Create the random frequency spectrum
    X = zeros(length(self.get_freq()), 1);
    binned_repr = zeros(self.n_bins, 1);
    for ii = 1:self.n_bins
        X(binnum==ii) = s(ii);
        binned_repr(ii) = s(ii);
    end

    % Generate the waveform
    stim = self.synthesize_audio(X, nfft);



