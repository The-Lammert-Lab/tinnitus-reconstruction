classdef Stimuli

    properties
        min_freq (1,1) {mustBeNumeric, mustBePositive} = 100
        max_freq (1,1) {mustBeNumeric, mustBePositive} = 22e3
        n_bins (1,1) {mustBeInteger, mustBePositive} = 100
        bin_duration (1,1) {mustBeNumeric} = 0.4
        n_trials (1,1) {mustBeInteger, mustBePositive} = 80
        n_bins_filled_mean (1,1) {mustBeInteger, mustBePositive} = 10
        n_bins_filled_var (1,1) {mustBeInteger, mustBePositive} = 3
        bin_prob (1,1) {mustBePositive, mustBeLessThanOrEqual(bin_prob, 1)} = 0.3
        amplitude_values (1,:) {mustBeNumeric} = linspace(-20, 0, 6)
    end

    methods
        function self = Stimuli(options)
            % Constructor for Stimuli class
            %
            %   stimuli = Stimuli() 
            %   stimuli = Stimuli(options)
            % 
            % Arguments:
            %   options: a 1x1 struct mapping to the properties of the class

            % default values
            self.min_freq = 100;
            self.max_freq = 22e3;
            self.n_bins = 100;
            self.bin_duration = 0.4;
            self.n_trials = 80;
            self.n_bins_filled_mean = 10;
            self.n_bins_filled_var = 3;
            self.amplitude_values = linspace(-20, 0, 6);
            self.bin_prob = 0.3;

            % if called with no arguments,
            % instantiate with default arguments
            if nargin < 1
                return
            end

            % set properties from an input struct, options
            self_fields = fieldnames(self);
            options_fields = fieldnames(options);
            if isa(options, 'struct')
                for ii = 1:length(options_fields)
                    is_in = strcmp(options_fields(ii), self_fields);
                    if any(is_in)
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