function s_hat = zhangpassivegamma(Phi,y,h)

m = size(Phi,1);
n = size(Phi,2);

a = (1/m)*(Phi'*y);

[val idx] = sort(abs(a),'descend');
gamma = val(h+1);

if norm(a,inf) <= gamma
    s_hat = zeros(n,1);
else
    s_hat = (1/norm(P(a,gamma),2))*P(a,gamma);
end

return
%eof