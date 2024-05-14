% ### RunAllExp
% 
% This function goes one by one through each of the experimental protocols
% using one config file. PitchMatch is repeated 3 times by default. 
% 
% **ARGUMENTS:**
% 
%   - cal_dB: `1x1` scalar, the externally measured decibel level of a 
%       1kHz tone at the system volume that will be used during the
%       protocol.
%   - config_path: `character vector`, default: ``''``
%       A path to a YAML-spec configuration file. 
%       If empty, a GUI is opened to navigate to the file. 
%   - n_pm: `1x1` positive integer, the number of times to repeat 
%       the PitchMatch protocol. Default: `3`.

function RunAllExp(cal_dB, config_path, n_pm)
    arguments
        cal_dB (1,1) {mustBeReal}
        config_path (1,:) char = ''
        n_pm (1,1) {mustBePositive, mustBeInteger} = 3
    end

    if isempty(config_path)
        [file, abs_path] = uigetfile('*.yaml');
        config_path = fullfile(abs_path, file);
    end

    ThresholdDetermination(cal_dB,'config_file',config_path,'del_fig',false);
    LoudnessMatch(cal_dB,'config_file',config_path,'fig',gcf,'del_fig',false);

    for ii = 1:n_pm
        PitchMatch(cal_dB,'config_file',config_path,'fig',gcf,'del_fig',false);
    end
     
    RevCorr(cal_dB, 'config_file',config_path,'fig',gcf);
end
