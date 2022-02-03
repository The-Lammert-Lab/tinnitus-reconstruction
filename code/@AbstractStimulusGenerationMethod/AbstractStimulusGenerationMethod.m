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
        generate_stimuli_matrix(self)
    end % abstract methods

    methods
        % Concrete methods that are inherited by subclasses.

        function [y, X, binned_repr] = subject_selection_process(self, signal)
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
