function scalar = adjust_volume(target_sound, target_fs, stimuli, Fs, scalar)
    
%%% Utility to dynamically adjust the target sound volume via a scaling
%%% factor.

    arguments
        target_sound (:,1) {mustBeNumeric}
        target_fs (1,1) {mustBeNumeric}
        stimuli (:,1) {mustBeNumeric}
        Fs (1,1) {mustBeNumeric}
        scalar double {mustBeNumeric} = 1.0
    end
    
    % Allowable range within which to scale target audio
    sld_max = 2;
    sld_min = 0.1;

    %% GUI
    fig = figure('Name', 'Volume Adjustment', 'NumberTitle', 'off');
    fig.CloseRequestFcn = {@closeRequest fig};
    
    sld = uicontrol(fig, 'Style', 'slider', ...
        'Position', [120 100 300 100], ...
        'min', sld_min, 'max', sld_max, ...
        'Value', scalar, 'Callback', @getValue);
    
    play_btn = uicontrol(fig,'Style','pushbutton', ...
        'position', [130 150 80 20], ...
        'String', 'Play Sounds', 'Callback', @playSounds);

    confirm_btn = uicontrol(fig,'Style','pushbutton', ...
        'position', [330 150 80 20], ...
        'String', 'Save Choice', 'Callback', {@closeRequest fig});

    uicontrol(fig, 'Style', 'text', 'String', ['Adjust the volume of the ' ...
        'target audio via the slider. Press "Play Sounds" ' ...
        'to hear the adjusted target audio compared to a sample stimulus. ' ...
        'Press "Save Choice" or close the ' ...
        'window when satisfied.'], 'Position', [120 200 300 100])

    uicontrol(fig, 'Style', 'text', 'String', num2str(sld_min), ... 
        'Position', [60 180 60 20]);

    uicontrol(fig, 'Style', 'text', 'String', num2str(sld_max), ... 
        'Position', [420 180 60 20]);

    waitfor(fig)

    %% Callback Functions
    function getValue(~,~)
        scalar = sld.Value;
    end

    function playSounds(~, ~)
        sound(target_sound*scalar, target_fs)
        pause(length(target_sound) / target_fs + 0.3)
        soundsc(stimuli, Fs)
    end

    function closeRequest(~,~,fig)
        ButtonName = questdlg('Confirm volume setting and continue protocol?',...
            'Confirm Volume', ...
            'Yes', 'No', 'Yes');
        switch ButtonName
            case 'Yes'
                delete(fig);
            case 'No'
                return
        end
    end

end
    

