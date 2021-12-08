clear;
clc;
close all;

[TitleEnv, Opt, Comp, MLimit, NProf, rProf, raxis, Pos] = read_flp('pekeris');
clear read_modes_bin;
Modes = read_modes_bin('pekeris.mod', 0);

srcz = reshape(Pos.s.z, [], 1);
rcvz = reshape(Pos.r.z, [], 1);

greens = zeros(length(rcvz), length(raxis));

for ii = 1:length(srcz)
    phis = interp1(Modes.z, Modes.phi, srcz(ii)).';
    phir = interp1(Modes.z, Modes.phi, rcvz).';
    k = reshape(Modes.k, 1, []).';

    factor = sqrt(2 * pi) / 4 / pi;

    maxModes = 4;
    k = k(1:maxModes);

    for mm = 1:length(k)
        greens = greens + factor * phis(mm) * phir(mm, :).' * exp(1i * raxis.' * k(mm)) ./ sqrt(k(mm)) ./ sqrt(raxis.');
    end

end

figure;
imagesc(20 * log10(abs(greens)));
caxis([-120, -60]);
