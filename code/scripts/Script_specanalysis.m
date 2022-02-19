
project_dir = pathlib.strip(mfilename('fullpath'), 3);
direc = pathlib.join(project_dir, 'data', 'sounds');
filenames = {...
    'ATA_Tinnitus_Buzzing_Tone_1sec.wav';...
    'ATA_Tinnitus_Electric_Tone_1sec.wav';...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav';...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav';...
    'ATA_Tinnitus_Static_Tone_1sec.wav';...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav';...
    };

POW = [];


%%%%%%%%%%%%%%%%%%%%
% Read Power Spectra

for itor = 1:length(filenames)
    
    [y, Fs] = audioread(pathlib.join(direc, filenames{itor}));
    
    y = (y-min(y))/range(y);
    
    %[pxx freq] = pwelch(y,Fs);
    %freq = (freq/pi)*(Fs/2);
    
    Y = fft(y,Fs)/length(y);
    freq = Fs/2*linspace(0,1,Fs/2+1);
    pxx = abs(Y(1:Fs/2+1));
    
    POW = [POW 10*log10(pxx)];
    
    %plot(freq,10*log10(pxx))
    %xlabel('Freq (Hz)')
    %ylabel('Power (dB)')
    
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define Frequency Bin Indices 1 through nbins_freq

nbins_freq = 64;
minfreq = freq(1);
maxfreq = freq(end);

bintops = round(mels2hz(linspace(hz2mels(minfreq),hz2mels(maxfreq),nbins_freq+1)));
binst = bintops(1:end-1);
binnd = bintops(2:end);
binnum = linspace(minfreq,maxfreq,length(freq));
for itor = 1:nbins_freq
    binnum(binnum<=binnd(itor) & binnum>=binst(itor)) = itor;
end

%%%%%%%%%%%%%%%%%%%%
% Bin Power Spectra

POWBIN = zeros(nbins_freq,size(POW,2));
for itor = 1:nbins_freq
    POWBIN(itor,:) = mean(POW(binnum==itor,:),1); 
end

figure
plot((binst+binnd)/2,POWBIN)
axis([0 Fs/2 -100 0])
xlabel('Freq (Hz)','fontsize',18)
ylabel('Power (dB)','fontsize',18)
grid on

%%%%%%%%%%%%%%%%%%%%
% Hist Power Spectra

%hbins = -100:10:10;

hbins = linspace(floor(min(min(POW))),ceil(max(max(POW))),16);

HIST = zeros(length(hbins),size(POW,2));
for itor = 1:length(filenames)
    
    val = hist(POWBIN(:,itor),hbins);
    
    HIST(:,itor) = val./sum(val);
     
end

figure
plot(hbins,HIST)
hold all
plot(hbins,mean(HIST,2),'k','linewidth',2);
axis([hbins(1) hbins(end) 0 0.75])
xlabel('Power (dB)','fontsize',18)
ylabel('Prob','fontsize',18)

%%%%%%%%%%%%%%%%%%%%
% Generate Random Power Spectra

pdf = mean(HIST,2);
pdf = (pdf + 0.01*mean(pdf))/(sum(pdf) + 0.01*mean(pdf)*length(pdf));% smooth probabilities
cdf = cumsum(pdf);

r = rand(nbins_freq,1);
s = zeros(nbins_freq,1);
for itor = 1:length(r)
    [val, idx] = min((cdf-r(itor)).^2);   
    s(itor) = hbins(idx);  
end

%%%%%%%%%%%%%%%%%%%%
% Synthesize Audio

% Generate Random Freq Spec in dB According to Frequency Bin Index
X = zeros(size(POW,1),1);
for itor = 1:nbins_freq
    X(binnum==itor) = s(itor);
end

phase = 2*pi*(rand(size(POW,1),1)-0.5); % assign random phase to freq spec
db = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
dbfull = [1; db; conj(flipud(db))];
y = ifft(dbfull); % transform from freq to time domain

soundsc(y,Fs)

%%% wavwrite((y-mean(y))./range(y),Fs,'StimEx3_tinnituslevs.wav')

%%%%%%%%%%%%%%%%%%%%
% Analyze Stimulus

Y = fft(y,Fs);
freq = Fs/2*linspace(0,1,Fs/2+1);
pxx = 10*log10(abs(Y(1:Fs/2+1)));

figure;
plot(freq,pxx)
axis([0 Fs/2 -80 0])
xlabel('Freq (Hz)','fontsize',18)
ylabel('Power (dB)','fontsize',18)

figure;
val = hist(pxx,hbins);
plot(hbins,val./sum(val),'linewidth',2)
xlabel('Power (dB)','fontsize',18)
ylabel('Prob','fontsize',18)

figure;
[val, cntrs] = hist(y,31);
plot(cntrs,val./sum(val),'linewidth',2)
xlabel('Sound Pressure Level','fontsize',18)
ylabel('Prob','fontsize',18)

figure;
plot(linspace(0,1,length(y)),y)
axis([0 1 min(y) max(y)])
xlabel('Time (sec)','fontsize',18)
ylabel('Sound Pressure Level','fontsize',18)

%eof
