function [stim, Fs, X, binned_repr] = generate_stimulus(self)
    % Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
    % amplitudes based on a tonotopic map of audible frequency perception.
    %
    % Class Properties Used:
    %   n_bins
    %   n_bins_filled_mean
    %   n_bins_filled_var

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft] = self.get_freq_bins();

    % Generate Random Freq Spec in dB Acccording to Frequency Bin Index
    
    % master list of frequency bins unfilled
    frequency_bin_list = 1:self.n_bins;

    % sample from Gaussian distribution to get the number of bins to fill
    n_bins_to_fill = -1;


    cont = true;
    count = 0;
    while cont
        n_bins_to_fill = round(normrnd(self.n_bins_filled_mean, self.n_bins_filled_var));
        if n_bins_to_fill > 0 && n_bins_to_fill <= self.n_bins
            cont = false;
        else
            count = count + 1;
        end
        if count > 10
            error('can''t get n_bins_to_fill to be between 1 and self.n_bins after 10 tries, erroring out')
        end
    end
    
    % fill the bins
    filled_bins = zeros(length(n_bins_to_fill), 1);
    X = -20 * ones(nfft/2, 1);
    for ii = 1:n_bins_to_fill
        % select a bin at random from the list
        random_bin_index = 0;
        while random_bin_index < 1 || random_bin_index > self.n_bins
            random_bin_index = randi([1 length(frequency_bin_list)], 1, 1);
        end
        bin_to_fill = frequency_bin_list(random_bin_index);
        % fill that bin
        filled_bins(ii) = bin_to_fill;
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
    binned_repr(filled_bins) = 0;

end