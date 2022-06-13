function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    %
    %   [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % 
    % 
    % Generate a vector of stimuli where
    % the bin amplitudes are -20 dB for an unfilled bin
    % and 0 dB for a filled bin.
    % Filled bins are chosen uniformly from unfilled bins, one at a time.
    % The total number of bins-to-be-filled is chosen from a Gaussian distribution.
    % 
    % Returns:
    %   stim: n x 1 numerical vector
    %       The stimulus waveform,
    %       where n is self.get_nfft() + 1.
    %   Fs: 1x1 numerical scalar
    %       The sample rate in Hz.
    %   spect: m x 1 numerical vector
    %       The half-spectrum,
    %       where m is self.get_nfft() / 2,
    %       in dB.
    %   binned_repr: self.n_bins x 1 numerical vector
    %       The binned representation.
    %   frequency_vector: m x 1 numerical vector
    %       The frequencies associated with the spectrum,
    %       where m is self.get_nfft() / 2,
    %       in Hz.
    % 
    % Class Properties Used:
    %   n_bins
    %   n_bins_filled_mean
    %   n_bins_filled_var
    % 
    % See Also: get_freq_bins, generate_stimuli_matrix

    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

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
        spect(binnum==bin_to_fill) = 0;
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