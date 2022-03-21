function M = csvread2(filename)
    % csvread but with failover

    try
        M = csvread(filename);
    catch
        warning('CSV empty')
        M = [];
    end

end % function