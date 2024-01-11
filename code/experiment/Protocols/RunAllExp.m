
% This function goes one by one through each of the experimental protocols
% using one config file.

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
     
    RevCorr('config_file',config_path,'fig',gcf);
end
