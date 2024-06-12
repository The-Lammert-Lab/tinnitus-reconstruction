% This function is mainly for avoiding errors, combining multiple
% follow_up data files from the same config, and dealing with V1 
% survey data. The code needed to load and work with the most common
% case (follow_up_version = 2, only one data file), is very straightforward.

function T = collect_data_follow_up(options)
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.data_dir (1, :) char = ''
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', 'config file loaded from GUI')
    elseif isempty(options.config)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', ['config object loaded from provided file [', options.config_file, ']'])
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', 'config object provided')
    end

    % Get hash
    config_hash = get_hash(config);

    % If no data directory is provided, use the one from the config file
    if isempty(options.data_dir)
        options.data_dir = config.data_dir;
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', ['using data directory from config: ' char(config.data_dir)])
    else
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', ['using data directory from function arguments: ' options.data_dir])
    end

    %% Body
    T = table; % Initialize for loop and for early return

    % Follow up files used to be prefixed with 'survey', but changed to 'follow_up'
    file_info = [dir(fullfile(options.data_dir, ['follow_up_',config_hash,'*.csv'])); ...
        dir(fullfile(options.data_dir, ['survey_',config_hash,'*.csv']))];

    % No files found
    if isempty(file_info)
        corelib.verb(options.verbose, 'INFO: collect_data_follow_up', 'no FollowUp data found. Exiting...')
        return
    end

    V1_data_exists = false;
    for ii = 1:length(file_info)
        Tnew = readtable(fullfile(file_info(ii).folder, file_info(ii).name));

        % Tnew was from V1
        if width(Tnew) == 1
            Ttemp = table;
            V1_data_exists = true; % can only handle V1 data from here on
            cellNew = readcell(fullfile(file_info.folder, file_info.name)); % Read in as cell instead
            if any(cellfun(@(m)isequal(m,'recon-noise'),cellNew)) % Determine order
                Ttemp.recon_standard = cellNew{7};
                Ttemp.whitenoise = cellNew{8};
            else
                Ttemp.recon_standard = cellNew{8};
                Ttemp.whitenoise = cellNew{7};
            end
            % Fill expected fields for versions > 1
            Ttemp.hash = config_hash; Ttemp.version = 1; Ttemp.mult = NaN; Ttemp.binrange = NaN;
            % Fill guaranteed fields from V1
            Ttemp.Q1 = cellNew{4}; Ttemp.Q2 = cellNew{5}; Ttemp.Q3 = cellNew{6};
            % Add to table
            T = [T; Ttemp];
        elseif V1_data_exists
            corelib.verb(options.verbose, 'INFO: collect_data_follow_up', ['no support for collecting follow up data ' ...
                'from both V == 1 and V > 1 at the same time'])
            return
        else
            try
                T = [T; Tnew];
            catch % Different VarNames
                % Outerjoin sometimes drops a row! Unclear why. This doesn't do that
                
                % Check for differing column names
                indT = ~ismember(T.Properties.VariableNames, Tnew.Properties.VariableNames);
                indTnew = ~ismember(Tnew.Properties.VariableNames, T.Properties.VariableNames);
                if ~sum(indT) % Tnew has columns not in T (add to T)
                    for jj = find(indTnew,sum(indTnew))
                        T.(Tnew.Properties.VariableNames{jj}) = NaN(height(T),1);
                    end
                else % T has columns not in Tnew (add to Tnew)
                    for jj = find(indT,sum(indT))
                        Tnew.(T.Properties.VariableNames{jj}) = NaN(height(Tnew),1);
                    end
                end

                T = [T; Tnew];

                % Cleaner code that doesn't always work
%                 [T, ia, ~] = outerjoin(T,Tnew,'MergeKeys',true);
%                 % Preserve the order
%                 T.sortvar = ia;
%                 T = sortrows(T,'sortvar');
%                 T.sortvar = [];
            end
        end
    end
end