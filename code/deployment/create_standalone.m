% Creates a directory containing a compiled standalone application
% that runs the protocol.

function res = create_standalone(this_version)

    %% Get additional files

    % m-files found by trawling the codebase
    additional_files = matlab.codetools.requiredFilesAndProducts(["../experiment/Protocol.m", "../scripts/hyperparameter_sweep_custom.m"])';

    % .jar file required for yaml loading/parsing
    additional_files{end+1} = '../../../yaml/+yaml/snakeyaml/snakeyaml-1.30.jar';

    % data and image files
    data_image_files = [dir("../experiment/ATA/*.wav"); dir("../experiment/fixationscreen/*.png")];
    additional_files = [additional_files; cellfun(@(x, y) pathlib.join(x, y), {data_image_files.folder}, {data_image_files.name}, 'UniformOutput', false)'];

    disp(additional_files)

    %% Create the standalone
    res = compiler.build.standaloneApplication(...
        '../experiment/Protocol.m', ...
        'ExecutableName', 'tinnitus_project', ...
        'ExecutableVersion', this_version, ...
        'AdditionalFiles', additional_files);

end