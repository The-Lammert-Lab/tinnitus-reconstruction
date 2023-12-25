% ### parse_rand_nbins
% 
% Parses stimuli and responses into cells 
% based on number of bins in the stimuli
% 
% **ARGUMENTS:**
% 
%   - responses: `n x 1` numerical array, response data, 
%       where `n` is the number of completed trials.
%   - stimuli: `m x n`, the stimuli data,
%       where `m` is the max number of bins
% 
% **OUTPUTS:**
%   
%   - resp_cell: `p x 1` cell, where `p` is the number of unique bins.
%       Responses organized into arrays within the cell.
%   - stim_cell: `p x 1` cell, the corresponding stimuli to 
%       `resp_cell` in increasing bin order.
% 
% See also:
% UniformPriorRandNBinsStimulusGeneration.generate_stimuli_matrix

function [resp_cell, stim_cell] = parse_rand_nbins(responses, stimuli)
    % Count number of bins in each stimulus
    n_bins = sum(~isnan(stimuli));
    [sorted_n_bins,sorted_inds] = sort(n_bins);

    % Sort the stimuli and responses
    stimuli = stimuli(:,sorted_inds);
    responses = responses(sorted_inds);

    % Collect the sorted group numbers
    [~,~,groups] = unique(sorted_n_bins);

    % Group into cells
    stim_cell = splitapply(@(x){x(:,1:sum(~isnan(x(1,:))))},stimuli',groups);
    resp_cell = splitapply(@(x){x},responses,groups);
end
