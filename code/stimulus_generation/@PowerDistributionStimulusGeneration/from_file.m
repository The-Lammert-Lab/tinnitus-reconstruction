function self = from_file(self, filepath, variable)

    arguments
        self PowerDistributionStimulusGeneration
        filepath {mustBeFile} = pathlib.join(fileparts(mfilename('fullpath')), 'distribution.mat')
        variable (1,:) {mustBeText} = 'distribution'
    end

    [~, ~, ext] = fileparts(filepath);

    if strcmp(ext, '.mat')
        S = load(filepath, variable);
        self.distribution = S.(variable);
    elseif strcmp(ext, '.csv')
        self.distribution = corelib.vectorise(csvread(filepath));
    else
        error('Unknown filetype of filename, expected csv or mat.')
    end

end % function
