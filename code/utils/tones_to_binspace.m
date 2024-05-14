% ### tones_to_binspace
% 
% Spaces the values in a frequency vector into bins 
% determined by the stimgen object.
% 
% **ARGUMENTS:**
% 
%   - tones: `n x 1` vector of frequency values
%   - stimgen: Any object that inherets from `AbstractBinnedStimulusGenerationMethod`,
%       used to inform the spacing (min and max freqs, number of bins)      
% 
% **OUTPUTS:**
% 
%   - tones_bindist: `n_bins x 1` vector in Hz which contains the values in `tones`
%       placed into the appropriate bin (values are averaged if multiple fit into the same bin)
%       and the bin center frequency in all bins for which there was no value in `tones`.
% 
% See also:
% AbstractBinnedStimulusGenerationMethod.get_freq_bins

function tones_bindist = tones_to_binspace(tones, stimgen)
    arguments
        tones (:,1)
        stimgen (1,1)
    end

    [~, ~, ~, ~, bin_starts, bin_stops] = stimgen.get_freq_bins();

    % Initialize
    tones_bindist = mean([bin_starts; bin_stops])'; % Tones for each bin
    bins_matched = zeros(length(tones),1); % "Cache" for averaging data points if necessary
    for ii = 1:length(tones)
        % Get bin that this tone fits in
        bin_num = find(tones(ii) >= bin_starts & tones(ii) <= bin_stops);
        if ismember(bin_num, bins_matched) % A previous tone is in this bin
            tones_bindist(bin_num) = (tones_bindist(bin_num) + tones(ii)) / 2; % Average
        else % New bin
            tones_bindist(bin_num) = tones(ii); % Take datapoint
            bins_matched(ii) = bin_num; % Add to "cache"
        end
    end
end
