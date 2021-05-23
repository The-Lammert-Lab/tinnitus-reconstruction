% Inspired by 
% o By S.Gibson, School of Physical Sciences, University of Kent. 
% o 1st May, 2013.
% o version 1.0
% o NOTES: If the max number of iterations exceeds 25, error sometimes
%   occurs in l1eq_pd function call.
%
% www.mathworks.com/matlabcentral/fileexchange/41792-simple-compressed-sensing-example

%%%%%%%%%%%%%%%%%%%

% FIDDLE WITH:
% noisyness of subject selection process (below)
% cs samples - parameter m (below)
% biht parameter - sparsity (biht code) - lower (<64) is better
% basis type (1d vs 2d) - rougly the same, preference for 2D

%%%%%%%%%%%%%%%%%%%
% Setup

l = 100000;

A = imread('Screeching.png');
A = rgb2gray(A);
A = imresize(A,1024/size(A,1)); % 0.3
A = imresize(A,[min(size(A)) min(size(A))]); % 0.3
A = double(A)./256;

% Convert image to spectrum
A = mean(A,2);
A = 20.*log10(mean(A,2));
A = flipud(A);
A(1:5) = -4;

n = length(A);
m = 12500; % 2.5% of recommended 20k trials

%%%%%%%%%%%%%%%%%%%
% Real Basis

ii = 32;
b = dct(A);
bm = zeros(n,1);
[val idx] = sort(abs(b(:)),'descend');
bm(abs(b)>val(ii)) = b(abs(b)>val(ii));

AA = idct(bm);
figure
plot(A,'k');
hold all
plot(AA,'r')

A = AA;

%%%%%%%%%%%%%%%%%%%
% Subject Selection Process

AA = repmat(A',l,1);
X = round(rand(l,n));

% % Ideal selection
% e = sum((X-AA).^2,2);
% y = double(e>=prctile(e,49.5));
% y(y==0) = -1;

% Ideal Selection
e = X*A;
y = double(e>=prctile(e,50));
y(y==0) = -1;

% % % % Noisy selection
% % % e = sum((X-AA).^2,2);
% % % e = e + 0.2*range(e)*randn(size(e));
% % % y = double(e>=prctile(e,49.5));
% % % y(y==0) = -1;

%%%%%%%%%%%%%%%%%%%
% Linear Reconstruction a la Gosselin

x_gossl = (1/n)*X'*y;

% figure
% imagesc(reshape(x_gossl,50,50))

%%%%%%%%%%%%%%%%%%%
% Measurement Matrix
% -> a matrix of stimulus images, vectorized

Phi = X(1:m,:);

%%%%%%%%%%%%%%%%%%%
% Measurement
% -> responses from subjects, in light of stimuli (and internal model)

ym = y(1:m);

%%%%%%%%%%%%%%%%%%%
% Linear Reconstruction a la Gosselin - limited samples

x_gossm = (1/n)*Phi'*ym;

% figure
% imagesc(reshape(x_gossm,50,50))

%%%%%%%%%%%%%%%%%%%
% Basis Matrix & Theta
% -> matrix of assumed internal model basis functions
% NOTE: Avoid calculating Psi (nxn) directly to avoid memory issues.

Theta = zeros(m,n);
for ii = 1:n
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    Theta(:,ii) = Phi*psi;
end

% Theta = zeros(m,n);
% for ii = 1:n
%     ek = zeros(sqrt(n),sqrt(n));
%     ek(ii) = 1;
%     psi = reshape(idct2(ek),n,1);
%     Theta(:,ii) = Phi*psi;
% end

%%%%%%%%%%%%%%%%%%%
% Weighting Reconstruction - L2 Norm

s2 = pinv(Theta)*ym;

%%%%%%%%%%%%%%%%%%%
% Weighting Reconstruction - L1 Norm
%
% min_{s,u} sum(u)  s.t.  -u <= s <= u,  Theta*s=y
%
% Need: min_{s,u} sum(u)  s.t.  -u <= s <= u,  Theta*s=y

%   Basis Pursuit
%s1 = l1eq_pd(s2,Theta,Theta',y,5e-3,20); % L1-magic toolbox
%s1 = l1eq_pd(s2,Theta,Theta',y,5e-4,100); % L1-magic toolbox

%%%s1 = rfpi(s2,Theta,y);

%s1 = biht(s2,Theta,ym);

%gamma = 0.4*sqrt(log(n)/m);
%s1 = zhangpassive(Theta,ym,gamma);

gamma = 32;
s1 = zhangpassivegamma(Theta,ym,gamma);

ym_est = sign(Theta*s1);

corrcoef(ym,ym_est)

%%%%%%%%%%%%%%%%%%%
% Viz Weighting Reconstruction

ek = dct(A);

figure
plot(ek(:)./max(ek(:)),'b'), hold all
scatter(1:length(s1),s1./max(s1),'ro')
legend('actual dct basis','biht basis')

%%%%%%%%%%%%%%%%%%%
% IMAGE RECONSTRUCTION - LSQ

x_csl2 = zeros(n,1);
for ii = 1:n
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    x_csl2 = x_csl2+psi*s2(ii);
end

% x_csl2 = zeros(n,1);
% for ii = 1:n
%     ek = zeros(sqrt(n),sqrt(n));
%     ek(ii) = 1;
%     psi = reshape(idct2(ek),n,1);
%     x_csl2 = x_csl2+psi*s2(ii);
% end

%%%%%%%%%%%%%%%%%%%
% IMAGE RECONSTRUCTION - BIHT - Small Sample

x_csl1 = zeros(n,1);
for ii = 1:n
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    x_csl1 = x_csl1+psi*s1(ii);
end

% x_csl1 = zeros(n,1);
% for ii = 1:n
%     ek = zeros(sqrt(n),sqrt(n));
%     ek(ii) = 1;
%     psi = reshape(idct2(ek),n,1);
%     x_csl1 = x_csl1+psi*s1(ii);
% end

%%%%%%%%%%%%%%%%%%%
% IMAGE RECONSTRUCTION - BIHT - Full Sample

w = l;

yw = y(1:w);
Phiw = X(1:w,:);
Thetaw = zeros(w,n);
for ii = 1:n
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    Thetaw(:,ii) = Phiw*psi;
end
% % % s2w = pinv(Thetaw)*yw;
% % % s1w = biht(s2w,Thetaw,yw);
%s1w = zhangpassive(Thetaw,yw,gamma);
s1w = zhangpassivegamma(Thetaw,yw,gamma);
x_csl0 = zeros(n,1);
for ii = 1:n
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    x_csl0 = x_csl0+psi*s1w(ii);
end

%%%%%%%%%%%%%%%%%%%
% Viz Image Reconstruction - Proposal Figure

f = linspace(100,10000,n)';

figure('name','Compressive Sensing')
subplot(5,1,1), plot(f,A), title('Cognitive Representation'), set(gca,'xtick',[]), ylabel('Power (dB)')
axis([100 10000 -7 -1])
subplot(5,1,2), plot(f,-x_gossl.*-(mean(A)./mean(x_gossl))), title('Conventional Estim (n=10k)'), set(gca,'xtick',[]), ylabel('Power (dB)')
axis([100 10000 -7 -1])
subplot(5,1,3), plot(f,-x_gossm.*-(mean(A)./mean(x_gossm))), title('Conventional Estim (n=1000)'), set(gca,'xtick',[]), ylabel('Power (dB)')
axis([100 10000 -7 -1])
subplot(5,1,4), plot(f,-x_csl1.*-(mean(A)./mean(x_csl1))), title('CS Reconstruction (n=1000)'), set(gca,'xtick',[]), ylabel('Power (dB)')
axis([100 10000 -7 -1])
subplot(5,1,5), plot(f,-x_csl0.*-(mean(A)./mean(x_csl0))), title('CS Reconstruction (n=10k)'), xlabel('Frequency (Hz)'), ylabel('Power (dB)')
axis([100 10000 -7 -1])

r = corr(A(:),x_gossl);
fprintf('Squared Correlation - Linear, High Sample: %5.4f\n',r^2)

r = corr(A(:),x_gossm);
fprintf('Squared Correlation - Linear, Low Sample: %5.4f\n',r^2)

r = corr(A(:),x_csl2);
fprintf('Squared Correlation - CS, Least Squares: %5.4f\n',r^2)

r = corr(A(:),x_csl1);
fprintf('Squared Correlation - CS, Zhang Passive, Low Sample: %5.4f\n',r^2)

r = corr(A(:),x_csl0);
fprintf('Squared Correlation - CS, Zhang Passive, High Sample: %5.4f\n',r^2)

%%%%%%%%%%%%%%%%%%%
% Viz Image Quality - Proposal Experiment & Figure

return

gamma = 64;

W = (500:500:l)';

CORRln = zeros(length(W),1);
CORRcs = zeros(length(W),1);

for itor = 1:length(W)
    
    w = W(itor)
    
    % Construct Theta
    yw = y(1:w);
    Phiw = X(1:w,:);
    Thetaw = zeros(w,n);
    for ii = 1:n
        ek = zeros(sqrt(n),sqrt(n));
        ek(ii) = 1;
        psi = reshape(idct2(ek),n,1);
        Thetaw(:,ii) = Phiw*psi;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gosselin
    
    % Estimate
    x_ln = (1/n)*Phiw'*yw;
    
    % Evaluate
    CORRln(itor) = corr(A(:),x_ln);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compressive Sensing
    
    % Estimate
    s_zhang = zhangpassivegamma(Thetaw,yw,gamma);

    % Reconstruct Gosselin
    x_cs = zeros(n,1);
    for ii = 1:n
        ek = zeros(sqrt(n),sqrt(n));
        ek(ii) = 1;
        psi = reshape(idct2(ek),n,1);
        x_cs = x_cs+psi*s_zhang(ii);
    end
    
    % Evaluate
    CORRcs(itor) = corr(A(:),x_cs);
    
end

figure
plot(W,CORRln.^2,'b','linewidth',2);
hold all
plot(W,CORRcs.^2,'r','linewidth',2);
xlabel('Number of Samples','fontsize',18);
ylabel('Correlation w/ Template (r^2)','fontsize',18);
legend('Conventional Reconstruction','Compressive Sensing','location','SE');
set(gca,'fontsize',18)

%eof