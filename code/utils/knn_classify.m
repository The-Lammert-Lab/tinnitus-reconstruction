% ### knn_classify
% 
% Returns the estimated class labels for a matrix of 
%   reference points T, given data points X and labels y.
% 
% **ARGUMENTS:**
% 
%   - y: `n x 1` vector,
%       representing class labels that correspond to data points in `X`.
%   - X: `n x p` numerical matrix,
%       labelled data points.
%   - T: `m x p` numerical matrix,
%       representing reference points without/needing class labels
%   - k: `scalar`,
%       indicating the number of nearest neighbors to be considered.
%   - method: `char`, name-value, default: 'mode',
%       method by which to determine the class label.
%       Valid methods are 'mode', which takes the most common neighbor label
%       'min_class', which takes the least common, 
%       and 'percent', which takes the class with the closest percent occurrance.
%   - percent: `scalar`, name-value, default: 75,
%       if method is 'percent', label is assigned based on the class with 
%       the closest percent occurrance to this argument.
%   
% **OUTPUTS:**
% 
%   - z_hat: `m x 1` vector,
%       estimated class labels for data points in T.

function z_hat = knn_classify(y,X,T,k,options)
    arguments
        y (:,1)
        X (:,:)
        T (:,:)
        k (1,1)
        options.method char = 'mode'
        options.percent (1,1) {mustBePositive, mustBeLessThanOrEqual(options.percent,100)} = 75
    end

    m = size(T,1);
    z_hat = zeros(m,1);
    
    for ii = 1:m
        % Calculate the distance between each point in X
        % and the current reference point in T.
        distance = pdist2(T(ii,:), X);
        
        % Get neighbor labels
        [~, ind] = sort(distance);
        l = y(ind(1:k));

        % Determine the class label
        switch options.method
            case 'mode'
                z_hat(ii) = mode(l);
            case 'min_class'
                tbl = tabulate(l);
                % If there's only one class, that's the only option.
                if size(tbl, 1) < 2
                    z_hat(ii) = tbl(1,1);
                else
                    % Get min class
                    [~, idx] = min(tbl(:,3));
                    z_hat(ii) = tbl(idx,1);
                end
            case 'percent'
                tbl = tabulate(l);
                % Get index of class with closest percent to target
                [~,idx] = min(abs(tbl(:,3) - options.percent));
                % If the closest percent is 0 (no occurrance), take the
                % next closest
                if tbl(idx, 3) == 0
                    p = unique(tbl(:,3));
                    idx = find(tbl(:,3) == p(2));
                end
                % Take first value in case there are multiple (same).
                z_hat(ii) = tbl(idx(1),1);
            otherwise
                error("Unknown class label determination method." + ...
                    "`method` keyword must be either 'mode', or 'min_class'")
        end
    end
end
