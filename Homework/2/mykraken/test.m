clear 
clc
close all

%% signals
T=3;
t1=2; 
tau=1;
f1=100; 
B=20;   
Fs = 2000;
dt = 1/Fs;
df = 1/T;                 
M1 = [0,1,1,0];
M2 = [0,1,0,1];
code = [0, 1, 0, 1, 1];
v=15;
c=1500;
receive_x = 500;
receive_y = 100;


% LFM_length = T * Fs;
% [sig, T_series] = dl_genLFM(T, Fs, t1, tau, f1,B, 'tukey');   
% [sig, T_series] = Goldcode(Fs, tau, M1, M2);
% [sig, T_series] = HFM(T, B, f1, Fs);
 [sig, T_series] = CW(T, f1, Fs, v, c);
% [sig, T_series] = Barker(Fs, f1, T, code);
% [sig, T_series] = Mcode(Fs, tau, M1)

%%
ambiguity_function(T_series, sig, 1, 2);

power_spectrum(sig, Fs, 3);

[PlotTitle, PlotType, freqVec, atten, Pos, pressure] = read_shd('.\kraken\Ideal_range.shd');

plotshd('.\kraken\Ideal_range.shd')
hold on
scatter(receive_y, receive_x);

freq_resp = squeeze(pressure(1,1,:,:));

figure()
plot(1:length(sig), sig);

sig_fft = fft(sig, Fs + 1);
% sig_fft = fftshift(sig_fft);
% 
% x = 1 : length(sig_fft);
% xq = linspace(1,length(sig_fft),Fs - 1);
% 
% sig_fft_fix = interp1(x, sig_fft, xq);
sig_fft_fix = sig_fft;

[~,index] = max(sig_fft_fix);

if(index>0)
    sign = 1;
else
    sign = -1;
end

figure()
plot(1:length(sig_fft_fix), sig_fft_fix);

affect_range = -5:5;

% sig_fft_fix(ceil(length(sig_fft_fix) / 2)+ sign * f1 - 1) = sig_fft_fix(ceil(length(sig_fft_fix) / 2)+ sign * f1 - 1) * freq_resp(receive_y, receive_x);
sig_fft_fix(index+affect_range) = ...
    sig_fft_fix(index+affect_range) * freq_resp(receive_y, receive_x) * 1 / (1 + abs(affect_range).^2);
% sig_fft_fix = fftshift(sig_fft_fix);

figure()
plot(1:length(sig_fft_fix), sig_fft_fix);

sig_trans = ifft(sig_fft_fix);

figure();
plot(1:length(sig_trans), sig_trans);

