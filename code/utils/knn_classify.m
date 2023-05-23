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
% 
% **OUTPUTS:**
% 
%   - z_hat: `m x 1` vector,
%       estimated class labels for data points in T.

function z_hat = knn_classify(y,X,T,k)
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
        z_hat(ii) = mode(l);
    end
end
