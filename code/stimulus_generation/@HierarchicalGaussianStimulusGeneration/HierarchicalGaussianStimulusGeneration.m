classdef HierarchicalGaussianStimulusGeneration < AbstractStimulusGenerationMethod
    properties
        n_broad {mustBeInteger, mustBeGreaterThanOrEqual(n_broad,0)} = 3
        n_med {mustBeInteger, mustBeGreaterThanOrEqual(n_med,0)} = 8
        n_narrow {mustBeInteger, mustBeGreaterThanOrEqual(n_narrow,0)} = 6

        broad_std {mustBePositive, mustBeReal} = 8000
        med_std {mustBePositive, mustBeReal} = 2000
        narrow_std {mustBePositive, mustBeReal} = 100

        scale_fact {mustBePositive, mustBeReal} = 40
    end

    methods
        function B = get_basis(self)
            Fs = self.get_fs();
            frequency_vector = linspace(0, Fs/2, self.nfft/2)';

            % Construct Basis
            B = zeros(length(frequency_vector),self.n_broad + self.n_med + self.n_narrow);
%             Mu = mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_broad));
            Mu = linspace(self.min_freq, self.max_freq, self.n_broad);
            for itor = 1:length(Mu)
                temp = normpdf(frequency_vector,Mu(itor),self.broad_std);
                B(:,itor) = rescale(temp);
            end

%             Mu = mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_med));
            Mu = linspace(self.min_freq, self.max_freq, self.n_med);
            for itor = 1:length(Mu)
                temp = normpdf(frequency_vector,Mu(itor),self.med_std);
                B(:,itor+self.n_broad) = rescale(temp);
            end

%             Mu = mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_narrow));
            Mu = linspace(self.min_freq, self.max_freq, self.n_narrow);
            for itor = 1:length(Mu)
                temp = normpdf(frequency_vector,Mu(itor),self.narrow_std);
                B(:,itor+self.n_broad+self.n_med) = rescale(temp);
            end
        end
    end
end
