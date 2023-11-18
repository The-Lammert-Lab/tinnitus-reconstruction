classdef (Abstract) AbstractStimulusGenerationMethod
    % Abstract class describing all features common
    % a stimulus generation method.

    properties
        % Properties common to all stimulus generation methods.
        % These are automatically instantiated for subclasses,
        % since they are not abstract themselves.
        min_freq (1,1) {mustBePositive, mustBeReal} = 100
        max_freq (1,1) {mustBePositive, mustBeReal} = 22e3
        duration (1,1) {mustBePositive, mustBeReal} = 0.5
        n_trials (1,1) {mustBePositive, mustBeReal} = 100
        Fs (1,1) {mustBePositive, mustBeReal} = 44.1e3
        unfilled_dB (1,1) {mustBeReal} = -100
        filled_dB (1,1) {mustBeReal} = 0
    end % abstract properties
    
    properties (Dependent)
        nfft (1,1) {mustBePositive, mustBeInteger}
    end

    methods (Abstract)
        % Abstract methods common to all stimulus generation methods
        generate_stimulus(self)
    end % abstract methods

    methods
        % Concrete methods that are inherited by subclasses.

        function [y, spect, binned_repr] = subject_selection_process(self, signal)
            % ### subject_selection_process
            % 
            % ```matlab
            % [y, spect, binned_repr] = subject_selection_process(self, signal)
            % ```
            % 
            % Model of a subject performing the task.
            % Takes in a signal (the gold standard)
            % and returns a `self.n_trials x 1` vector
            % of `-1` for "no"
            % and `1` for "yes".
            [~, ~, spect, binned_repr] = self.generate_stimuli_matrix();
            e = spect' * signal(:);
            y = double(e >= prctile(e, 50));
            y(y == 0) = -1;
        end % function

        function Fs = get_fs(self)
            Fs = self.Fs;
        end % function

        function nfft = get.nfft(self)
            nfft = self.get_fs() * self.duration;
        end % function

        function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix, W] = generate_stimuli_matrix(self)
            % ### generate_stimuli_matrix
            % 
            % ```matlab
            % [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
            % ```
            %
            % Generates a matrix of stimuli.
            % Explicitly calls the `generate_stimulus()`
            % class method.
            % 
            % **OUTPUTS:**
            % 
            %   - stimuli_matrix: `n x self.n_trials` numerical vector,
            %       the stimulus waveform,
            %       where `n` is `self.nfft + 1`.
            % 
            %   - Fs: `1x1` numerical scalar,
            %       the sample rate in Hz.
            % 
            %   - spect_matrix: `m x self.n_trials` numerical vector,
            %       the half-spectrum,
            %       where `m` is `self.nfft / 2`,
            %       in dB.
            % 
            %   - binned_repr_matrix: `self.n_bins x self.n_trials` numerical vector,
            %       the binned representation.
            % 
            % See Also: 
            % BernoulliStimulusGeneration.generate_stimulus
            % BrimijoinStimulusGeneration.generate_stimulus
            % GaussianNoiseNoBinsStimulusGeneration.generate_stimulus
            % GaussianNoiseStimulusGeneration.generate_stimulus
            % GaussianPriorStimulusGeneration.generate_stimulus
            % PowerDistributionStimulusGeneration.generate_stimulus
            % UniformNoiseNoBinsStimulusGeneration.generate_stimulus
            % UniformNoiseStimulusGeneration.generate_stimulus
            % UniformPriorStimulusGeneration.generate_stimulus
            % WeightedPriorStimulusGeneration.generate_stimulus

            if isa(self,'AbstractBinnedStimulusGenerationMethod')
                % generate first stimulus
                binned_repr_matrix = zeros(self.n_bins, self.n_trials);
                [stim1, Fs, spect, binned_repr_matrix(:, 1)] = self.generate_stimulus();

                % instantiate stimuli matrix
                stimuli_matrix = zeros(length(stim1), self.n_trials);
                spect_matrix = zeros(length(spect), self.n_trials);
                stimuli_matrix(:, 1) = stim1;
                spect_matrix(:, 1) = spect;
                for ii = 2:self.n_trials
                    [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), binned_repr_matrix(:, ii)] = self.generate_stimulus();
                end
                W = [];
            else
                if isa(self,'HierarchicalGaussianStimulusGeneration')
                    [stim1, Fs, spect, ~, w1] = self.generate_stimulus();

                    % instantiate stimuli matrix
                    stimuli_matrix = zeros(length(stim1), self.n_trials);
                    spect_matrix = zeros(length(spect), self.n_trials);
                    W = zeros(length(w1), self.n_trials);
                    stimuli_matrix(:, 1) = stim1;
                    spect_matrix(:, 1) = spect;
                    W(:,1) = w1;
                    for ii = 2:self.n_trials
                        [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), ~, W(:,ii)] = self.generate_stimulus();
                    end
                else
                    % generate first stimulus
                    [stim1, Fs, spect, ~] = self.generate_stimulus();

                    % instantiate stimuli matrix
                    stimuli_matrix = zeros(length(stim1), self.n_trials);
                    spect_matrix = zeros(length(spect), self.n_trials);
                    stimuli_matrix(:, 1) = stim1;
                    spect_matrix(:, 1) = spect;
                    for ii = 2:self.n_trials
                        [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), ~] = self.generate_stimulus();
                    end
                    W = [];
                end
                binned_repr_matrix = [];
            end

        end % function

        function freq = get_freq(self)
            freq = linspace(self.min_freq, self.max_freq, self.nfft / 2);
        end % function

        function self = from_config(self, options)
            % ### from_config
            % 
            % Set properties from a struct holding config options.
            % 
            % See also: 
            % * [yaml.loadFile](https://github.com/MartinKoch123/yaml/blob/master/%2Byaml/loadFile.m)

            if isa(options, 'char')
                options = yaml.loadFile(options);
            end

            self_fields = fieldnames(self);
            options_fields = fieldnames(options);
            if isa(options, 'struct')
                for ii = 1:length(options_fields)
                    is_in = strcmp(options_fields{ii}, self_fields);
                    if any(is_in)
                        self.(self_fields{is_in}) = options.(options_fields{ii});
                    end
                end
                % Create distribution file and rebuild self if Power Distribution protocol
                if strcmp(options.stimuli_type, 'PowerDistribution')
                    % If file exists, try to load directly
                    if exist(options.distribution_filepath, 'file') == 2
                        [~, ~, ext] = fileparts(options.distribution_filepath);
                        if strcmp(ext, '.mat')
                            self.distribution = struct2array(load(options.distribution_filepath, 'distribution'));
                        elseif strcmp(ext, '.csv')
                            self.distribution = readmatrix(options.distribution_filepath);
                        else
                            warn('unknown file extension for distribution filepath')
                            self.distribution = self.build_distribution(options.distribution_filepath);
                        end
                    else
                        self.distribution = self.build_distribution(options.distribution_filepath);
                    end
                end
            else
                error('unknown type for "options", should be a character vector or a struct')
            end
        end % function

        function wav = white_noise(self)
            % ### white_noise
            % Generate a white noise sound.
            %
            % **ARGUMENTS:**
            %
            % - self: `1 x 1` `AbstractStimulusGenerationMethod`
            %
            % **OUTPUTS:**
            %
            %   - wav: `n x 1` white noise waveform.
            arguments
                self (1,1) AbstractStimulusGenerationMethod
            end
            spect = zeros(self.nfft/2,1);

            % Create frequency vector
            freqs = linspace(0, floor(self.Fs/2), self.nfft/2)';

            % Flatten out of range freqs and synthesize
            spect(freqs > self.max_freq | freqs < self.min_freq) = self.unfilled_dB;
            wav = self.synthesize_audio(spect, self.nfft);
        end

        function stim = pure_tone(self, tone_freq, nfft)
            arguments
               self (1,1) AbstractStimulusGenerationMethod
               tone_freq (1,1) {mustBePositive, mustBeInteger}
               nfft (1,1) {mustBePositive, mustBeInteger} = self.nfft
            end
            spectrum = self.unfilled_dB*ones(nfft/2,1);
            spectrum(tone_freq) = self.filled_dB;
            stim = self.synthesize_audio(spectrum,nfft);
        end
    end

    methods (Static)
        function stim = synthesize_audio(X, nfft)
            % ### synthesize_audio
            % Synthesize audio from spectrum, `X`.
            % If `X` is an array, each column is treated as a spectrum.
            phase = 2*pi*(rand(nfft/2,size(X,2))-0.5); % assign random phase to freq spec
            s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
            ss = [ones(1,size(X,2)); s; conj(flipud(s))];
            stim = ifft(ss); % transform from freq to time domain
        end
    end


end % classdef
