% ### P
% 
% Soft threshold operator used in compressed sensing

function beta = P(alpha,gamma)

beta = zeros(length(alpha),1);

ind = abs(alpha)>gamma;

beta(ind) = sign(alpha(ind)).*(abs(alpha(ind))-gamma);

return
%eof