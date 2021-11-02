function [stim, Fs, X, binned_repr] = custom_generate_stimuli(self)
    % Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
    % amplitudes based on a tonotopic map of audible frequency perception.

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft] = self.get_freq_bins();

    % Generate Random Freq Spec in dB Acccording to Frequency Bin Index
    
    % master list of frequency bins unfilled
    frequency_bin_list = 1:self.n_bins;

    % sample from Gaussian distribution to get the number of bins to fill
    n_bins_to_fill = -1;
    
    while n_bins_to_fill < 1
        n_bins_to_fill = round(normrnd(self.n_bins_filled_mean, self.n_bins_filled_var));
    end
    filled_bins = zeros(length(n_bins_to_fill), 1);

    % fill the bins
    X = -20 * ones(nfft/2, 1);
    for ii = 1:n_bins_to_fill
        % select a bin at random from the list
        random_bin_index = 0;
        while random_bin_index < 1 || random_bin_index > self.n_bins
            random_bin_index = randi([1 length(frequency_bin_list)], 1, 1);
        end
        bin_to_fill = frequency_bin_list(random_bin_index);
        filled_bins(ii) = bin_to_fill;
        % fill that bin
        X(binnum==bin_to_fill) = 0;
        % remove that bin from the master list
        frequency_bin_list(frequency_bin_list==bin_to_fill) = [];
    end
    % X = zeros(nfft/2,1);
    % for itor = 1:self.n_bins
    %     X(binnum==itor) = -20 * floor(2 * rand(1,1) .^ self.prob_f);
    % end
    % filled_bins = sort(filled_bins);

    % Synthesize Audio
    stim = self.synthesize_audio(X, nfft);

    % get the binned representation
    binned_repr = -20 * ones(self.n_bins, 1);

end