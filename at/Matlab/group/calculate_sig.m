% --------------------说明------------------------
% calculate_sig.m 通过生成LFM信号、打开Green数据
% 在频域利用LFM_F与Green相乘得到Sf，再ifft得到时域sig_t，接着做了Matchfiler 
% Author : Lingxuan Li
% E-mail : lilingxuan@zju.edu.cn
% date: 2021.10.15
% v2.0

%% 程序 
clear; clc; close all;

%% path and load  file

FILEPATH = 'D:\phase8000\test\';
addpath(genpath('I:\copy daima\top'));

%% LFM信号生成

T=20;                                                                      %总时长
t1=0;                                                                       %start time of the chirp signal (secs)
tau=1;                                                                      %chirp信号持续时间
f1=1000;                                                                    %start frequency of the chirp
B=200;                                                                      %带宽
fs = 16000;
dt = 1/fs;
df = 1/T;                 %% 采样间隔

LFM_length = T*fs;
[LFM_sig, LFM_taxis] = dl_genLFM(T, fs, t1, tau, f1,B, 'tukey');    %LFM信号生成

LFM_f = ifft(LFM_sig);
LFM_faxis = linspace(-fs/2,fs/2,length(LFM_f));

%% load greenfunction

load([FILEPATH,'g2400_31.mat']);
Green = g8600_10; 
% clear g2400_3;
G = zeros(1,length(LFM_faxis));
G(:,900/df:1300/df) = Green;

%% calculate sig


sig_f = G.*LFM_f;
sig_t =fft(sig_f);
gt = fft(G);
% ----PLOT FIG------------------------------------------------------------------

    set(0,'defaultfigurecolor','w')
    
    set(0, 'CurrentFigure', figure(1)); clf(1);figure(1);
    plot(LFM_taxis,real(LFM_sig),'linewidth',1.5);
    set(gca,'fontsize',16);
    title('Intensity of LFM ');    %LFM信号时域图
    xlabel('Time(s)');
    ylabel('Intensity(dB)');
   
% 
%     set(0, 'CurrentFigure', figure(2)); clf(2);figure(2);
%     plot(LFM_faxis,real(fftshift(LFM_f)),'linewidth',1.5);
%     set(gca,'fontsize',16,'xlim',[-8000 8000]);
%     title('LFM after FFT ');    %LFM信号时域图
%     xlabel('Frequency(Hz)');ylabel('Amplitude');

    set(0, 'CurrentFigure', figure(3)); clf(3);figure(3);
    plot(faxis,20*log10(fftshift(abs(G))),'linewidth',1.5);
    set(gca,'fontsize',16,'xlim',[-8000 8000]);
    title('Green ');    %LFM信号时域图
    xlabel('Frequency(Hz)');ylabel('Intensity(dB)');
%     
%     set(0, 'CurrentFigure', figure(4)); clf(4);figure(4);
%     plot(LFM_faxis,20*log10(abs(fftshift(Sf))),'linewidth',1.5);
%     set(gca,'fontsize',16,'xlim',[-8000 8000]);
%     title('Signal(Frequency domain) ');    %LFM信号时域图
%     xlabel('Frequency(Hz)');ylabel('Intensity(dB)');
% 
%     set(0, 'CurrentFigure', figure(5)); clf(5);figure(5);
%     plot(LFM_taxis,20*log10(abs(sig_t)));
%     set(gca,'fontsize',16,'xlim',[0 20]);
%     title('Signal(Time domain) ');    %LFM信号时域图
%     xlabel('Time(s)');ylabel('Intensity(dB)');
%     xlim([1.5,6.5]);ylim([-200,0]);
% 
%     clear Green2;
%     clear G;
%     clear Sf;
%     clear LFM_taxis;
%     clear LFM_faxis;
%     clear LFM_f;

    % time-frequency图
    nfft = length(LFM_sig);
        window = 1024;%CODE2 30-40S
        numoverlap = 1/4 * window;
        [sl,fl,tl,pl] = spectrogram(conj(LFM_sig), window, numoverlap, nfft, fs);

        figure(6);clf(6);imagesc(tl,fl,20*log10(pl)); axis tight;
        xlabel('Time (Seconds)','fontsize',16); 
        ylabel('Frequency (Hz)','fontsize',16);title('LFM时频图','fontsize',16,'linewidth',1.5);
        caxis([-80, 90]);colorbar; colormap('jet');view(0,90);

    clear LFM_sig;
    clear sl;
    clear fl;
    clear tl;
    clear pl;

    nfft = length(sig_t);
        window = 1024;%CODE2 30-40S
        numoverlap = 1/4 * window;
        [s,f,t,p] = spectrogram(conj(sig_t), window, numoverlap, nfft, fs);

        figure(7);clf(7);imagesc(t,f,20*log10(p)); axis tight;
        xlabel('Time (Seconds)','fontsize',16); 
        ylabel('Frequency (Hz)','fontsize',16);title('sig时频图','fontsize',16,'linewidth',1.5);
        caxis([-250, -200]);colorbar; colormap('jet');view(0,90);

    clear s;
    clear f;
    clear t;
    clear p;

 %% 匹配滤波
[matchsig, match_taxis] = dl_genLFM(1, fs, 0, 1,f1,B, 'tukey');    %LFM信号生成
    Q = sum(abs(matchsig).^2)/2;

    mfout = conv(sig_t, fliplr(conj(matchsig)), 'valid')/Q;
    mfout_taxis = 0:1/fs:(length(mfout)-1)*1/fs;
   
    [~,index]= max(20*log10(abs(mfout)));
    index =index*1/fs;

    set(0, 'CurrentFigure', figure(1)); clf(1);
    plot(mfout_taxis,20*log10(abs(mfout)));
    title('mfout');xlabel('Time(s)');ylabel('Intensity(dB)')
    set(gca,'Fontsize',12);caxis([50, 120]);
   
    
   
%     figure(9);plot(mfout_taxis,20*log10(abs(mfout)));
%     xlabel('Time(s)');ylabel('Intensity(dB)')
%     set(gca,'Fontsize',12);caxis([50, 120]);
%     xlim([2.8,4.2]);ylim([-200,-50]);hold on;
%     legend('10th-mode','10modes')
%     
%     xlim([2.9,4.2]);ylim([-200,-50]);
%     clear match_taxis;
%     clear matchsig;
%     clear mfout;
%     clear mfout_taxis;
    
% save('sig_t.mat','sig_t');

% saveas(figure(1),[FILEPATH,'LFM_T.jpg']); 
% saveas(figure(2),[FILEPATH,'LFM_F.jpg']);
% saveas(figure(3),[FILEPATH,'Green.jpg']);
% saveas(figure(4),[FILEPATH,'Signal_F.jpg']);
% saveas(figure(5),[FILEPATH,'Signal_T.jpg']);
% saveas(figure(6),[FILEPATH,'spectrum_LFM.jpg']);
% saveas(figure(7),[FILEPATH,'spectrum_sig.jpg']);
% saveas(figure(2),[FILEPATH,'30th_mode.fig']);
% saveas(figure(9),[FILEPATH,'compare20_21.jpg']);

% close all;