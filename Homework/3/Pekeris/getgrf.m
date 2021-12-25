function grf = getgrf(pressure, xs, ys)
%GETGRF get the grf in specified position
global RMax RD

pressure=squeeze(pressure);
nx=round(xs/RMax*size(pressure,2));
ny=round(ys/RD(end)*size(pressure,1));
grf=pressure(ny,nx);

end

