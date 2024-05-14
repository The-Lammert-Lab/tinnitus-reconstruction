% ### zhangpassivegamma
% 
% Passive algorithm for 1-bit compressed sensing with no basis.
% 
<<<<<<< Updated upstream
% # References
=======
>>>>>>> Stashed changes
% - Zhang, L., Yi, J. and Jin, R., 2014, June. Efficient algorithms for robust one-bit compressive sensing. In *International Conference on Machine Learning* (pp. 820-828). PMLR.

function s_hat = zhangpassivegamma(Phi,y,h)
    m = size(Phi,1);
    n = size(Phi,2);
    
    a = (1/m)*(Phi'*y);
    
    [val, ~] = sort(abs(a),'descend');
    gamma = val(h+1);
    
    if norm(a,inf) <= gamma
        s_hat = zeros(n,1);
    else
        s_hat = (1/norm(P(a,gamma),2))*P(a,gamma);
    end
end
