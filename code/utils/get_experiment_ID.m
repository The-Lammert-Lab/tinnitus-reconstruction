% NO LONGER USED WITH HASHED CONFIG SYSTEM
% 
% [expID] = get_experiment_ID(config)
% 
% Construct a character vector identifier
% for an experiment from a config file.
% 
% Arguments:
%   config: 1x1 struct
%       Struct generated from a config file.
%
%   ignore_fields: n x 1 cell array of character vectors, default: {}
%       Container of field names of `config` to ignore.
% 
%   property_separator: 1 x m character vector, default: '&&'
%       Delimiter for the output.
% 
% Returns:
%   expID: character vector
% 
% See Also: 
% prop2str
% parse_config

function expID = get_experiment_ID(config, ignore_fields, property_separator)

    arguments
        config (1,1) struct
        ignore_fields (:,1) cell = {}
        property_separator (1,:) char = '&&'
    end

    ignore_fields = [ignore_fields; {'target_audio_filepath'; 'data_dir'}];

    expID = prop2str(config, ignore_fields, property_separator);