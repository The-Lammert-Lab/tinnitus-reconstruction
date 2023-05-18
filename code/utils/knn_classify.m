% Inputs:
%    y - A n-by-1 vector of class labels, corresponding to data points in X
%    X - A n-by-p data matrix
%    T - A m-by-p matrix of reference points, without/needing class labels
%    k - A scalar value indicating the number of nearest neighbors
%        to be considered.
% 
% Outputs:
%    z_hat - A m-by-1 vector of estimated class labels for data points in T
%
% Description: Determine estimated class labels for a matrix of 
%               reference points T, given data points X and labels y

function z_hat = knn_classify(y,X,T,k)
    % Setup
    m = size(T,1); % number of data points in T
    n = size(X,1); % number of data points in X
    z_hat = zeros(m,1); % vector for storing class label predictions
    distance = zeros(n,1); % vector of distances
    
    % Iterate over all reference points in T
    for ii = 1:m
        % Calculate the distance between each point in x 
        % and the current reference point in T.
        for jj = 1:n
            distance(jj) = pdist([T(ii,:);X(jj,:)]);
        end
        
        % Get neighbor labels
        [~, ind] = sort(distance);
        l = y(ind(1:k))';
            
        % Determine the class label
        z_hat(ii) = mode(l);
    end
end
