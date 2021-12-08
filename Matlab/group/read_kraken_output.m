function [greens, raxis, Depth_modeshape, prop_modes] = read_kraken(rho, rmax, freq, svp2, src_depth, dr, prop_modes)

% rho   -- Density of the media in layer #1 (mostly water)
%       -- Notice that the unit of rho in .env file is (gram / cm^3), in
%          this file, its unit need to be converted to kg / m^3 (by *1e3)
% rmax  -- Maximum range set in .env file
%       -- Notice that the unit of rmax in .env file is km, in this file,
%          its unit need to be converted to m (by * 1e3)

system('/home/dlwang/Desktop/Seafloor_Scattering/ProgramFiles/dduane_kraken/readmodes_mat.out');

load xi_tot
load mode_shape
load Depth_modeshape

% system('rm xi_tot mode_shape Depth_modeshape 2>/dev/null');


num_depths = length(Depth_modeshape);
num_modes = length(xi_tot);

rho = rho * 1e3;
rmax = rmax * 1e3;
if ~exist('dr', 'var')
    dr = 50;
end

raxis = dr : dr : rmax;
rmat = repmat(reshape(raxis, 1, []), num_depths, 1);

%%
if ~exist('prop_modes', 'var')
    prop_modes = numel(find(xi_tot(:,1) > 2*pi*freq./mean(svp2)));
    prop_modes = 1:prop_modes;
end

disp(prop_modes);

modeshape_r = reshape(mode_shape(:,1),num_depths,num_modes) * sqrt(1000);
modeshape_i = reshape(mode_shape(:,2),num_depths,num_modes) * sqrt(1000);
modeshape_c = modeshape_r - 1i*modeshape_i;

[~, src_ind] = min(abs(Depth_modeshape - src_depth));

greens = zeros(num_depths, length(raxis));
for jj = prop_modes
    k_rm = (xi_tot(jj,1)-1i*xi_tot(jj,2));
    unz = modeshape_c(:,jj);
    unz_matrix = repmat(unz, 1, length(raxis));
    unz0 = modeshape_c(src_ind,jj);
    greens = greens + ((1./rho).*sqrt(2.*pi./rmat).*unz_matrix.*unz0.*exp(1i.*k_rm.*rmat)./sqrt(k_rm)) / 4 / pi;
end

end