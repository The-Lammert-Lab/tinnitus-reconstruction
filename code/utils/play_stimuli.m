function play_stimuli(stimuli_matrix_1, stimuli_matrix_2, Fs, counter, target_sound, target_fs, pause_duration)

        arguments
            stimuli_matrix_1 {mustBeReal}
            stimuli_matrix_2 {mustBeReal}
            Fs (1,1) {mustBePositive, mustBeReal}
            counter (1,1) {mustBePositive, mustBeReal, mustBeInteger}
            target_sound (:,1) {mustBeReal} = []
            target_fs (1,1) {mustBePositive, mustBeReal} = []
            pause_duration (1,1) {mustBePositive, mustBeReal} = 0.3
        end

        % Present Target (if A-X protocol)
        if ~isempty(target_sound)
            assert(target_fs > 0, 'target_fs must be real and positive')
            soundsc(target_sound, target_fs)
            pause(length(target_sound) / target_fs + pause_duration) % ACL added (5MAY2022) to add 300ms pause between target and stimulus
        end

        % Present Stimulus #1
        soundsc(stimuli_matrix_1(:, counter), Fs)
        pause(length(stimuli_matrix_1(:, counter)) / Fs + pause_duration)

        % Present Target (if A-X protocol)
        if ~isempty(target_sound)
            assert(target_fs > 0, 'target_fs must be real and positive')
            soundsc(target_sound, target_fs)
            pause(length(target_sound) / target_fs + pause_duration) % ACL added (5MAY2022) to add 300ms pause between target and stimulus
        end

        % Present Stimulus #2
        soundsc(stimuli_matrix_2(:, counter), Fs)
        pause(length(stimuli_matrix_2(:, counter)) / Fs)
end % play_stimuli