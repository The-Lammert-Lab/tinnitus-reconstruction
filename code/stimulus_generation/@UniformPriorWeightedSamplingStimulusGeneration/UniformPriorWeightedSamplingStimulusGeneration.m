classdef UniformPriorWeightedSamplingStimulusGeneration < AbstractBinnedStimulusGenerationMethod
    % Stimulus generation method
    % in which the number of filled bins is selected
    % from a uniform distribution on [min_bins, max_bins]
    % but which bins are filled is determined by a non-uniform distribution.

    properties
        min_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 10
        max_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 50
        bin_probs (:,1) {mustBePositive, mustBeReal} = []
        alpha_ (1,1) {mustBePositive, mustBeReal} = 1
    end

    methods
        function self = UniformPriorWeightedSamplingStimulusGeneration()
            % ### UniformPriorWeightedSamplingStimulusGeneration
            % class constructor
            % 

            self = self.set_bin_probs();
        end


        function self = set.max_bins(self, value)
            assert(value <= self.n_bins, 'self.max_bins cannot be set to a value greater than self.n_bins')
            self.max_bins = value;
        end

        function bin_occupancy = get_bin_occupancy(self)
            % ### get_bin_occupancy
            % 
            % ```matlab
            % bin_occupancy = self.get_bin_occupancy();
            % ```
            % 
            % Compute the bin occupancy,
            % which is a ``self.n_bins x 1`` vector
            % which counts the number of unique frequencies in each bin.
            % This bin occupancy quantity is not related to which bins
            % are "filled".
            % 
            % **OUTPUTS**
            % 
            % - bin_occupancy: `self.n_bins x 1`
            %   representing the bin occupancy quantity, e.g.
            %   `bin_occupancy(1)` is the occupancy for the first bin.
            % 
            % See Also:
            % AbstractBinnedStimulusGenerationMethod.get_freq_bins

            binnums = self.get_freq_bins();

            bin_occupancy = zeros(self.n_bins, 1);
            for ii = 1:self.n_bins
                bin_occupancy(ii) = sum(binnums == ii);
            end
        end

        function self = set_bin_probs(self, alpha_)
            % ### set_bin_probs
            % 
            % ```matlab
            % self.set_bin_probs()
            % self.set_bin_probs(1.3)
            % ```
            % 
            % Sets ``self.bin_probs`` equal to
            % the bin occupancy, exponentiated by ``alpha_``.
            % If ``alpha_`` is empty, uses the existing ``self.alpha_``
            % value. Otherwise, ``self.alpha_`` is set as well,
            % and that value is used.
            % 
            % **ARGUMENTS**
            %
            % - self: the object
            % - alpha_: ``1x1`` nonnegative scalar
            % 
            % See Also:
            % UniformPriorWeightedSamplingStimulusGeneration.get_bin_occupancy

            arguments
                self (1,1) UniformPriorWeightedSamplingStimulusGeneration
                alpha_ (1,1) {mustBeGreaterThanOrEqual(alpha_, 0), mustBeReal} = []
            end

            if ~isempty(alpha_)
                self.alpha_ = alpha_;
            end

            bin_occupancy = self.get_bin_occupancy();
            bin_occupancy = bin_occupancy .^ self.alpha_;
            self.bin_probs = normalize(bin_occupancy, 'norm');
        end

        function [filled_bins] = sample(self, n_bins_to_fill)
            % ### sample
            % 
            % ```matlab
            % filled_bins = self.sample(weights, values)
            % ```
            % 
            % Get a vector of indices referred to bins that should be filled,
            % by taking successive weighted samples
            % without replacement from a list of values
            % with associated weights.
            % 
            % **ARGUMENTS**
            % - n_bins_to_fill: `1x1` integral scalar indicating how many bins to fill
            % 
            % 
            % **OUTPUTS**
            % - filled_bins: `n_bins_to_fill x 1` vector of bin indices
            % 

            arguments
                self (1,1) UniformPriorWeightedSamplingStimulusGeneration
                n_bins_to_fill (1,1) {mustBeGreaterThanOrEqual(n_bins_to_fill, 0), mustBeInteger}
            end

            assert(n_bins_to_fill <= self.n_bins, 'n_bins_to_fill must be less than or equal to self.n_bins')

            filled_bins = datasample(1:self.n_bins, n_bins_to_fill, ...
                'Replace', false, ...
                'Weights', self.bin_probs);
        end
    end

end % classdef