function writebdry3d( bdryfil, interp_type, Bdry )

% write a 3d bathymetry file for use by BELLHOP3D
% useage:
% writebdry3d( bdryfil, Bdry )
%
% mbp July 2011

% Some of my code uses Bathy.Lonkm ad .Latkm but I think this is confusing
% since they are Eastings and Northings at that point, not lat/longs.

%Bathy.X = Bathy.Lonkm;
%Bathy.Y = Bathy.Latkm;

Bdry.depth( isnan( Bdry.depth ) ) = 0.0;   % remove NaNs

%interp_type = 'R';   % rectilinear grid
nx = length( Bdry.X );
ny = length( Bdry.Y );

fid = fopen( bdryfil, 'wt' );
fprintf( fid, '''%c''\n', interp_type );

fprintf( fid, '%i \n', nx );
%fprintf( fid, '%f %f /', Bathy.X( 1 ), Bathy.X( end ) );

fprintf( fid, '%f ', Bdry.X( 1 : end ) );
fprintf( fid, '\n');

fprintf( fid, '%i \n', ny );
%fprintf( fid, '%f %f /', Bathy.Y( 1 ), Bathy.Y( end ) );
fprintf( fid, '%f ', Bdry.Y( 1 : end ) );
fprintf( fid, '\n');

for iy = 1 : ny
   fprintf( fid, '%9.3f ', Bdry.depth( iy, : ) );
   fprintf( fid, '\n');
end

fclose( fid );
