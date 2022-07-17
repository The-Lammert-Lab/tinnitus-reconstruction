% ### adjust_volume
% 
% For use in A-X experimental protocols.
% `adjust_volume` is a utility to dynamically adjust the target sound volume via a scaling factor.
% Opens a GUI using a standard MATLAB figure window 
% with a slider for scaling the target sound audio 
% and a button for replaying the sound compared to an unchanged stimulus noise.  
% 
% **another another another another!!**
% 
% **ARGUMENTS:**
% 
%   - target_sound: `n x 1` vector, the target sound.
%   - target_fs: `1 x 1` scalar, the frequency of target_sound.
%   - stimuli: `n x 1` vector, a sample stimulus sound.
%   - Fs: `1 x 1` scalar, the frequency of the sample stimuli.
%   - scale_factor: `1 x 1` scalar, the scalar by which to multipy the target sound.
%   default: `1.0`.
% 
% **OUTPUTS:**
% 
%   - scale_factor: `1 x 1` scalar, 
%       the scalar by which the target signal is multipled 
%       that results in the preferred volume chosen by the user.

function scale_factor = adjust_volume(target_sound, target_fs, stimuli, Fs, scale_factor)

    arguments
        target_sound (:,1) {mustBeNumeric}
        target_fs (1,1) {mustBeNumeric}
        stimuli (:,1) {mustBeNumeric}
        Fs (1,1) {mustBeNumeric}
        scale_factor double {mustBeNumeric} = 1.0
    end
    
    % Allowable range within which to scale target audio
    sld_max = 3;
    sld_min = 0.1;

    %% GUI
    fig = figure('Name', 'Volume Adjustment', 'NumberTitle', 'off');
    fig.CloseRequestFcn = {@closeRequest fig};
    
    sld = uicontrol(fig, 'Style', 'slider', ...
        'Position', [120 100 300 100], ...
        'min', sld_min, 'max', sld_max, ...
        'Value', scale_factor, 'Callback', @getValue);
    
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
        scale_factor = sld.Value;
    end % getValue

    function playSounds(~, ~)
        sound(target_sound*scale_factor, target_fs)
        pause(length(target_sound) / target_fs + 0.3)
        soundsc(stimuli, Fs)
    end % playSounds

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
    end % closeRequest

end % adjust_volume 