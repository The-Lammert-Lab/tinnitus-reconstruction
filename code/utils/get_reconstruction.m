function x = get_reconstruction(responses, stimuli_matrix, config, method)

    %
    %   x = get_reconstruction(responses, stimuli_matrix)
    % 
    %   x = get_reconstruction(responses, stimuli_matrix, config)
    % 
    %   x = get_reconstruction(responses, stimuli_matrix, config, method)
    % 
    % 
    % Compute the reconstruction, given the response vector
    % and the stimuli matrix
    % with a preprocessing step
    % and a method chosen from {'cs', 'cs_nb', 'linear'}
    % 
    % See Also: collect_reconstructions, collect_data

    arguments
        responses (:,1) {mustBeNumeric}
        stimuli_matrix {mustBeNumeric}
        config = []
        method (1,:) {mustBeText} = 'cs'
    end

    if isempty(config)
        PREPROCESSING = false;
    elseif ischar(config) || isstring(config)
        % read the config file => struct
        config = ReadYaml(config);
        PREPROCESSING = true;
    else
        PREPROCESSING = true;
    end

    %% Preprocessing Step
    if PREPROCESSING
        if strcmp(config.stimuli_save_type, 'bins')
            if size(stimuli_matrix, 1) > config.n_bins
                % stimuli are probably saved as waveforms
                % but should be in bins
                stimgen = eval([config.stimuli_type, 'StimulusGeneration()']);
                stimgen.from_config(config);
                stimuli_matrix = signal2spect(stimuli_matrix); % waveform => spectrum
                stimuli_matrix = stimgen.spect2binnedrepr(stimuli_matrix); % spectrum => bin repr
            end
        end
    end

    %% Reconstruction Step
    switch method
    case 'cs'
        x = cs(responses, stimuli_matrix');
    case 'cs_nb'
        x = cs_no_basis(responses, stimuli_matrix');
    case 'linear'
        x = gs(responses, stimuli_matrix');
    otherwise
        error('Unknown method')
    end

end % function