function plot_ambiguity(fs, sig,varargin)

N=length(sig);
t=(1:N)/fs;

xs=(-(N-1):(N-1))/fs;
dop=0.1;
doppler=linspace(-dop,dop,2*N-1);

ambiguity=zeros(2*N-1);
for i=1:2*N-1
    sig_shift=sig.*exp(1i*2*pi*doppler(i)*t);
    ambiguity(i,:)=pow2(abs(xcorr(sig,sig_shift)));
end

ambiguity=ambiguity/max(ambiguity,[],'all');

if(nargin==2)
    figure()
    contour(xs,doppler,ambiguity,[db2mag(-3),db2mag(-3)]);
    title('Normalized Ambiguity');
    xlabel('relative time shift')
    ylabel('doppler shift')
end