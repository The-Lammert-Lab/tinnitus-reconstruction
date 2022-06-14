function [distribution] = build_distribution(self, save_path)
    % Builds the default power distribution from ATA tinnitus sample files.
    % Saves the distribution as a vector in dB
    % and the corresponding frequency vector.
    % 
    % Arguments:
    %   save_path : character vector, default: pathlib.join(fileparts(mfilename('fullpath')), 'distribution.mat');
    %       Path to .mat file where distribution should be saved.
    % 
    % Returns:
    %   distribution : numeric vector
    %       Power distribution in dB.
    % 
    % See Also: PowerDistributionStimulusGeneration.from_file, PowerDistributionStimulusGeneration.generate_stimulus

    %% Preamble
    project_dir = pathlib.strip(mfilename('fullpath'), 4);
    sound_dir = pathlib.join(project_dir, 'code', 'experiment', 'ATA');
    filenames = {...
        'ATA_Tinnitus_Buzzing_Tone_1sec.wav';...
        'ATA_Tinnitus_Electric_Tone_1sec.wav';...
        'ATA_Tinnitus_Roaring_Tone_1sec.wav';...
        'ATA_Tinnitus_Screeching_Tone_1sec.wav';...
        'ATA_Tinnitus_Static_Tone_1sec.wav';...
        'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav';...
        };

    % Get the frequency vector
    freq = self.get_freq();

    %% Read the power spectra
    [y, Fs_file] = audioread(pathlib.join(sound_dir, filenames{1}));
    y = (y - min(y)) / range(y);
    Y = fft(y, Fs_file) / length(y);
    freq_file = Fs_file/2 * linspace(0, 1, Fs_file/2 + 1);
    pxx = abs(Y(1:Fs_file/2 + 1));
    
    power_spectra = zeros(length(pxx), length(filenames));

    for ii = 2:length(filenames)
        [y, Fs_file] = audioread(pathlib.join(sound_dir, filenames{ii}));
        y = (y - min(y)) / range(y);
        Y = fft(y, Fs_file) / length(y);
        pxx = abs(Y(1:Fs_file/2 + 1));        

        power_spectra(:, ii) = 10*log10(pxx);
    end

    % Get power spectrum averaged across tinnitus samples
    spect = mean(power_spectra, 2);

    % Resample power spectrum w.r.t. the frequency vector
    distribution = interp1(freq_file, spect, freq, 'cubic');

    %% Save distribution

    if nargin < 2
        save_path = pathlib.join(fileparts(mfilename('fullpath')), 'distribution.mat');
    end

    save(save_path, 'distribution', 'freq');

end % function