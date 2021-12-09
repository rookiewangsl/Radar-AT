function [grf] = getgrf(pressure, xs, ys)
% GETGRF get the grf in (xs,ys)
    % xs in km, ys in m
    % pressure(freq,theta,source,NRD,NR)
    % pressure=zeros(K,1,1,NRD,NR);
    global RMax RMin RD
    
    pressure=squeeze(pressure);
    [NRD,NR]=size(pressure);
    
    xpos=round(xs/(RMax-RMin)*NR);
    ypos=round(ys/RD(end)*NRD);
    grf=pressure(xpos,ypos);
    
end
