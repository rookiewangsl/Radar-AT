function Pos = readsdrd( fid )

% Read source depths and receiver depths
%
% Variable 'Pos' is a structure:
% Pos.r.z = vector of receiver depths
% Pos.Nrz = number of receiver depths
% Pos.s.z = vector of source depths
% Pos.Nsz = number of source depths

%%
% source depths
fprintf( '\n_______________________ \n' )

[ Pos.s.z, Pos.Nsz ] = readvector( fid );

fprintf( '\nNumber of source depths   = %i \n', Pos.Nsz )
fprintf( '\nSource depths (m)\n' );

if ( Pos.Nsz < 10 )
   fprintf( '%8.2f  \n', Pos.s.z )   % print all the depths
else
   fprintf( '%8.2f ... %8.2f \n', Pos.s.z( 1 ), Pos.s.z( end ) ) % print first, last depth
end

if Pos.Nsz > 2
  disp( 'Producing source depths by interpolation between sz(1) and sz(2)' )
end

%%
% receiver depths
fprintf( '\n_______________________ \n' )

[ Pos.r.z, Pos.Nrz ] = readvector( fid );

fprintf( '\nNumber of receivers depths = %i \n', Pos.Nrz )
fprintf( '\nReceiver depths (m)\n' );

if ( Pos.Nrz < 10 )
   fprintf( '%8.2f  \n', Pos.r.z )   % print all the depths
else
   fprintf( '%8.2f ... %8.2f \n', Pos.r.z( 1 ), Pos.r.z( end ) ) % print first, last depth
end

disp( '  ' )

if Pos.Nrz > 2
  disp( 'Producing receiver depths by interpolation between rd(1) and rd(2)' )
end

fprintf( '\n' )