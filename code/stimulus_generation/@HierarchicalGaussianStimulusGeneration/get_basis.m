% ### get_basis
% 
% ```matlab
% B = self.get_basis();
% ```
% 
% Generate a basis vector from the Gaussians stored in the class.
% 
% **OUTPUTS:**
% 
%   B: `self.nfft / 2 x self.n_broad + self.n_med + self.n_narrow` numerical array,
%       Gaussian distributions for each type specified in the class fields
% 
% **Class Properties Used:**
% 
% ```
% - n_broad
% - n_med
% - n_narrow
% - broad_std
% - med_std
% - narrow_std
% ```

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
