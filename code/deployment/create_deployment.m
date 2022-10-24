% Create the files for a deployment

function create_deployment(options)

    arguments
        options.verbose (1,1) {mustBeNumericOrLogical} = true
        options.version {mustBeText} = ''
        options.standalone (1,1) {mustBeNumericOrLogical} = false
        options.toolbox (1,1) {mustBeNumericOrLogical} = true
    end

    if isempty(options.version)
        options.version = char(datetime('today'));
    end

    % Print the options
    corelib.verb(options.verbose, 'INFO create_deployment', 'Arguments are:')
    disp(options)

    % Create the standalone
    if options.standalone
        corelib.verb(options.verbose, 'INFO create_deployment', 'Creating the standalone...')
        create_standalone(options.version);
        corelib.verb(options.verbose, 'INFO create_deployment', 'Standalone created.')
    end

    % Create the toolbox
    if options.toolbox
        corelib.verb(options.verbose, 'INFO create_deployment', 'Creating the toolbox...')
        matlab.addons.toolbox.toolboxVersion('tinnitus-project.prj', options.version);
        matlab.addons.toolbox.packageToolbox('tinnitus-project.prj', 'tinnitus-project.mltbx');
        corelib.verb(options.verbose, 'INFO create_deployment', 'Toolbox created.')
    end
end
