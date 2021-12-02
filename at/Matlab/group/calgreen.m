function [raxis, zaxis, greens] = calgreen(fileroot, max_modes, option)
%CALCULATE_GREENS_FROM_MOD Summary of this function goes here
%   Detailed explanation goes here

% [ TitleEnv, freq, SSP, Bdry, Pos, Beam, cInt, RMax, fid ] = read_env( fileroot, 'krakenc' );
[ TitleEnv, Opt, Comp, MLimit, NProf, rProf, raxis, Pos ] = read_flp( fileroot );


greens = zeros(length(Pos.r.depth), length(raxis));

% PhiR
PhiR = load('PhiR.prt');
phir = PhiR(2:end-1,:);
phir = phir(:,1) - 1i*phir(:,2);
phir = reshape(phir, PhiR(1,2), []);

% PhiS
PhiS = load('PhiS.prt');
phis = PhiS(2:end-1,:);
phis = phis(:,1) - 1i*phis(:,2);

% k
k = load('k.prt');
k = k(2:end-1,:);
k = k(:,1) - 1i*k(:,2);

% calculate
if exist('option', 'var') && option == 1
    factor = sqrt(2*pi)/4/pi;
else
    factor = sqrt(2*pi)*1i*exp(-1i*pi/4)/4/pi;
end
const = factor .* phis ./ sqrt(k);
cmat = diag(const) * phir;
hank_tmp = exp(1i * raxis * transpose(k));
hank = zeros(size(hank_tmp));
if exist('max_modes', 'var')
    hank(:,1:max_modes) = hank_tmp(:,1:max_modes);
else
    hank = hank_tmp;
end

for ii = 1:size(hank,1)
    greens(:,ii) = hank(ii,:) * cmat / sqrt(raxis(ii));
end

zaxis = Pos.r.depth;

end

