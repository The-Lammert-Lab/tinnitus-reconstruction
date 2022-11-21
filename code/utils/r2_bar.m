% ### r2_bar 
% 
% Plots bar charts of r^2 values from table data. 
% A separate figure is made for each subject.
% 
% **ARGUMENTS:**
% 
%   - T: `table` that includes r^2 values of interest
% 
% **OUTPUTS:**
%   - n figures, where n is the number of subjects included
%       in the table.
% 
% See Also:
% pilot_reconstructions

function r2_bar(T)

    arguments
        T table
    end
    
    % Get indices of r^2 data from table
    r2_lr_inds = contains(T.Properties.VariableNames,'r2_lr');
    r2_cs_inds = contains(T.Properties.VariableNames,'r2_cs');

    % Determine unique subjects
    subjects = unique(T.subject_ID);

    % Get column names with trial fraction information
    fracs = T.Properties.VariableNames(r2_lr_inds);

    % Create nice x-labels from column name info
    frac_labels = cell(1, sum(r2_lr_inds));
    for i = 1:length(fracs)
        temp = regexprep(fracs{i}, {'\D*([\d\.]+\d)[^\d]*', ...
            '[^\d\.]*'}, {'$1 ', ''}); % Parse for only numbers
        frac_labels{i} = strcat(temp(2),'.',temp(3:end));
    end

    % Create a figure for each subject
    for i = 1:length(subjects)
        figure
        t = tiledlayout('flow');
        exp_rows = find(contains(T.subject_ID, subjects{i}));

        % Plot two tiles (lr & cs) for each experiment within subject
        for j = 1:length(exp_rows)
            target_signal_name = T.target_signal_name{exp_rows(j)};
            total_trials = T.total_trials(exp_rows(j));

            nexttile
            bar(table2array(T(exp_rows(j), r2_lr_inds)))
            grid on
            set(gca, 'XTickLabel', frac_labels)
            xlabel(['Fraction of ', num2str(total_trials),...
                ' trials'], 'FontSize', 14)    
            ylabel('r^2', 'FontSize',14)
            title(['Linear ', target_signal_name], ...
                'FontSize', 14)

            nexttile
            bar(table2array(T(exp_rows(j), r2_cs_inds)))
            grid on
            set(gca, 'XTickLabel', frac_labels)
            xlabel(['Fraction of ', num2str(total_trials),...
                ' trials'], 'FontSize', 14)
            ylabel('r^2', 'FontSize',14)
            title(['CS ', target_signal_name], ...
                'FontSize', 14)
        end
        title(t, ['Subject: ', subjects{i}], 'FontSize', 18)
    end

end %function



