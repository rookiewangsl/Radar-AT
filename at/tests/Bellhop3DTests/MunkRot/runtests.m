% run the 3D Munk case
% the angular limits are chosen so as not to hit the free surface

global units
units = 'km';

%%
bellhop3d Munk3D

figure
plotshdpol( 'Munk3D.shd', 0, 0, 3000 )
caxisrev( [ 50 100 ] )
axis( [ -1 4 0 100 ] )

%%
bellhop3d Munk3Dz

figure
plotshd( 'Munk3Dz.shd' )
caxisrev( [ 50 100 ] )

