classdef Stimuli

    properties
        min_freq (1,1) {mustBeNumeric} = 100
        max_freq (1,1) {mustBeNumeric} = 22e3
        n_bins (1,1) {mustBeNumeric} = 100
        bin_duration (1,1) {mustBeNumeric} = 0.4
        % prob_f (1,1) {mustBeNumeric} = 0.4
        n_trials (1,1) {mustBeNumeric} = 80
        n_bins_filled_mean (1,1) {mustBeNumeric} = 10
        n_bins_filled_var (1,1) {mustBeNumeric} = 3
        amplitude_values {mustBeNumeric} = linspace(-20, 0, 6)
    end

    methods
        function self = Stimuli(options)
            self.min_freq = 100;
            self.max_freq = 22e3;
            self.n_bins = 100;
            self.bin_duration = 0.4;
            self.n_trials = 80;
            self.n_bins_filled_mean = 10;
            self.n_bins_filled_var = 3;
            self.amplitude_values = linspace(-20, 0, 6);

            if nargin < 1
                return
            end

            self_fields = fieldnames(self);
            options_fields = fieldnames(options);
            if isa(options, 'struct')
                for ii = 1:length(options_fields)
                    is_in = strcmp(options_fields(ii), self_fields);
                    if sum(is_in) == 1
                        self.(self_fields{is_in}) = options.(options_fields{ii});
                    end
                end
            end
        end
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

end