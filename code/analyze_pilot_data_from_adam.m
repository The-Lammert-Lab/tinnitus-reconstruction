%% Analyze Pilot Data from Adam

RECOMPUTE = true;

if RECOMPUTE == true

    %% Load the data
    
    % S = load("/home/alec/data/pilot-data-adam/roaringax_third1000.mat");
    S = load("/home/alec/data/pilot-data-adam/buzzax_second1000.mat");
    % T contains the random stimuli as linearly interpolated power spectra (the ones used for resynthesis).
    T = S.T;
    % I contains the binary responses.
    I = S.I;
    % R is the template spectrum, used as the example to listen for.
    R = S.R;
    
    S = load("/home/alec/data/pilot-data-adam/binnums.mat");
    % B contains the bin numbers    
    B = S.B;
    delete S;
    
    frequencies = 1:2:(2*length(R));
    
    % Get binned representation
    % This is *not* a binary representation
    % because the amplitude values are not binary
    % (e.g., only -20 and 0).
    n_bins = 32;
    binned_repr = zeros(size(T, 1), n_bins);
    for bin_num = 1:n_bins
        a = T(:, B == bin_num);
        binned_repr(:, bin_num) = a(:, 1);
    end

    return

    %% Compute reconstructions
    % varying the number of trials

    n_trials = round([0.01, 0.03, 0.1, 0.3, 1] * length(I));
    x_gs = zeros(length(R), length(n_trials));
    x_cs = zeros(length(R), length(n_trials));
    x_cs_nb = zeros(length(R), length(n_trials));

    for ii = 1:length(n_trials)
        this_I = I(1:n_trials(ii));
        this_T = T(1:n_trials(ii), :);

        % Linear Regression
        x_gs(:, ii) = gs(this_I, this_T);

        % Compressed Sensing with Basis
        x_cs(:, ii) = cs(this_I, this_T, round(0.1 * size(T, 2)));

        % Compressed Sensing no Basis
        x_cs_nb(:, ii) = cs_no_basis(this_I, this_T, round(0.1 * size(T, 2)));
    end
end

%% Plotting

% figure with all the different trial lengths overlaid
figure;
n_plots = 3;%4;

% create legend
leg = cell(length(n_trials), 1);
for ii = 1:length(leg)
    leg{ii} = ['N = ' num2str(n_trials(ii))];
end

for ii = n_plots:-1:1
    ax(ii) = subplot(n_plots, 1, ii);
end

% true spectrum
plot(ax(1), 1e-3 * frequencies, R);
ylabel('power (dB)')

% linear regression
plot(ax(2), 1e-3 * frequencies, x_gs)
% ylabel('power (dB)')
legend(ax(2), leg)

% compressed sensing, with basis
plot(ax(3), 1e-3 * frequencies, x_cs);
% ylabel('power (dB)')
legend(ax(3), leg)

% % compressed sensing, no basis
% plot(ax(4), 1e-3 * frequencies, x_cs_nb)
% ylabel('power (dB)')
% xlabel(ax(4), 'frequency (kHz)')

figlib.label()
figlib.pretty()

% generate a new figure for each trial length
for ii = 1:length(n_trials)
    figure;
    n_plots = 3;%4;

    for qq = n_plots:-1:1
        ax(qq) = subplot(n_plots, 1, qq);
    end

    % true spectrum
    plot(ax(1), 1e-3 * frequencies, R);
    ylabel('power (dB)')

    % linear regression
    plot(ax(2), 1e-3 * frequencies, x_gs(:, ii))
    % ylabel('power (dB)')

    % compressed sensing, with basis
    plot(ax(3), 1e-3 * frequencies, x_cs(:, ii));
    % ylabel('power (dB)')

    % % compressed sensing, no basis
    % plot(ax(4), 1e-3 * frequencies, x_cs_nb)
    % ylabel('power (dB)')
    % xlabel(ax(4), 'frequency (kHz)')

    title(['N = ' num2str(n_trials(ii))]);
    figlib.label()
    figlib.pretty()
end

%% Compute reconstructions
% using the binned representation
% varying the number of trials

n_trials = round([0.01, 0.03, 0.1, 0.3, 1] * length(I));
x_gs = zeros(length(R), length(n_trials));
x_cs = zeros(length(R), length(n_trials));
x_cs_nb = zeros(length(R), length(n_trials));

for ii = 1:length(n_trials)
    this_I = I(1:n_trials(ii));
    this_T = binned_repr(1:n_trials(ii), :);

    % Linear Regression
    x_gs_binned(:, ii) = gs(this_I, this_T);

    % Compressed Sensing with Basis
    x_cs_binned(:, ii) = cs(this_I, this_T, round(0.1 * size(T, 2)));

    % Compressed Sensing no Basis
    x_cs_nb_binned(:, ii) = cs_no_basis(this_I, this_T, round(0.1 * size(T, 2)));
end

% resynthesize waveforms from binned representation
x_gs_binned_spect = zeros(size(T));
for ii = 1:size(x_gs_binned_spect, 1)
    for qq = 1:n_bins
        x_gs_binned_spect(ii, B == qq) = x_gs_binned(ii, qq);
    end
end



%% Plotting (binned representation)

% figure with all the different trial lengths overlaid
figure;
n_plots = 3;%4;

% create legend
leg = cell(length(n_trials), 1);
for ii = 1:length(leg)
    leg{ii} = ['N = ' num2str(n_trials(ii))];
end

for ii = n_plots:-1:1
    ax(ii) = subplot(n_plots, 1, ii);
end

% true spectrum
plot(ax(1), 1e-3 * frequencies, R);
ylabel('power (dB)')

% linear regression
plot(ax(2), 1e-3 * frequencies, x_gs)
% ylabel('power (dB)')
legend(ax(2), leg)

% compressed sensing, with basis
plot(ax(3), 1e-3 * frequencies, x_cs);
% ylabel('power (dB)')
legend(ax(3), leg)

% % compressed sensing, no basis
% plot(ax(4), 1e-3 * frequencies, x_cs_nb)
% ylabel('power (dB)')
% xlabel(ax(4), 'frequency (kHz)')

figlib.label()
figlib.pretty()

% generate a new figure for each trial length
for ii = 1:length(n_trials)
    figure;
    n_plots = 3;%4;

    for qq = n_plots:-1:1
        ax(qq) = subplot(n_plots, 1, qq);
    end

    % true spectrum
    plot(ax(1), 1e-3 * frequencies, R);
    ylabel('power (dB)')

    % linear regression
    plot(ax(2), 1e-3 * frequencies, x_gs(:, ii))
    % ylabel('power (dB)')

    % compressed sensing, with basis
    plot(ax(3), 1e-3 * frequencies, x_cs(:, ii));
    % ylabel('power (dB)')

    % % compressed sensing, no basis
    % plot(ax(4), 1e-3 * frequencies, x_cs_nb)
    % ylabel('power (dB)')
    % xlabel(ax(4), 'frequency (kHz)')

    title(['N = ' num2str(n_trials(ii))]);
    figlib.label()
    figlib.pretty()
end