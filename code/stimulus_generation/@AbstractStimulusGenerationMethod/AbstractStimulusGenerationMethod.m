classdef (Abstract) AbstractStimulusGenerationMethod
    % Abstract class describing all features common
    % a stimulus generation method.

    properties
        % Properties common to all stimulus generation methods.
        % These are automatically instantiated for subclasses,
        % since they are not abstract themselves.
        min_freq (1,1) {mustBePositive, mustBeReal} = 100
        max_freq (1,1) {mustBePositive, mustBeReal} = 22e3
        duration (1,1) {mustBePositive, mustBeReal} = 0.4
        n_trials (1,1) {mustBePositive, mustBeReal} = 100
    end % abstract properties

    methods (Abstract)
        % Abstract methods common to all stimulus generation methods
        generate_stimulus(self)
    end % abstract methods

    methods
        % Concrete methods that are inherited by subclasses.

        function [y, X, binned_repr] = subject_selection_process(self, signal)

            %   [y, X, binned_repr] = subject_selection_process(self, signal)
            % 
            % Model of a subject performing the task.
            % Takes in a signal (the gold standard)
            % and returns an n_samples x 1 vector
            % of -1 for "no"
            % and 1 for "yes"
            [~, ~, X, binned_repr] = self.generate_stimuli_matrix();
            e = X' * signal(:);
            y = double(e <= prctile(e, 50));
            y(y == 0) = -1;
        end % function

        function Fs = get_fs(self)
            Fs = 2*self.max_freq;
        end % function

        function nfft = get_nfft(self)
            nfft = self.get_fs() * self.duration;
        end % function


        function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
            % Generate matrix of stimuli.
            % TODO: documentation for this

            if any(strcmp('n_bins', properties(self)))
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
                binned_repr_matrix = [];
            end

        end % function

        function freq = get_freq(self)
            freq = linspace(self.min_freq, self.max_freq, self.get_nfft() / 2);
        end % function

        function self = from_config(self, options)
            % Set properties from a struct holding config options.

            if isa(options, 'char')
                options = ReadYaml(options);
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
            else
                error('unknown type for "options", should be a character vector or a struct')
            end
        end % function

    end

    methods (Static)
        function stim = synthesize_audio(X, nfft)
            % Synthesize audio from spectrum, X.
            phase = 2*pi*(rand(nfft/2,1)-0.5); % assign random phase to freq spec
            s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
            ss = [1; s; conj(flipud(s))];
            stim = ifft(ss); % transform from freq to time domain
        end
    end


end % classdef
