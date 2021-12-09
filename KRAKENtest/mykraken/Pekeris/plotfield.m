function [greens] = plotfield(FILENAME, NMode)
    % CALFIELD 此处显示有关此函数的摘要

    if nargin < 2
        sprintf('didn''t config number of modes');
    end

    [~, ~, ~, ~, ~, ~, raxis, Pos] = read_flp(FILENAME);
    clear read_modes_bin;
    Modes = read_modes_bin([FILENAME, '.mod'], 0);

    srcz = reshape(Pos.s.z, [], 1);
    rcvz = reshape(Pos.r.z, [], 1);

    greens = zeros(length(rcvz), length(raxis));

    for ii = 1:length(srcz)
        phis = interp1(Modes.z, Modes.phi, srcz(ii)).';
        phir = interp1(Modes.z, Modes.phi, rcvz).';
        k = reshape(Modes.k, 1, []).';

        factor = sqrt(2 * pi) / 4 / pi;
        k = k(1:NMode);

        for mm = 1:length(k)
            greens = greens + factor * phis(mm) * phir(mm, :).' * exp(1i * raxis.' * k(mm)) ./ sqrt(k(mm)) ./ sqrt(raxis.');
        end
    end

    figure;
    imagesc(20 * log10(abs(greens)));
    colorbar;
    % caxis([-120, -60]);
end
