function [ Arr, Pos ] = read_arrivals_bin( ARRFile, Narrmx )

% Read the arrival time/amplitude data computed by BELLHOP
%
% usage:
%[ Arr, Pos ] = read_arrivals_bin( ARRFile, Narrmx );
%
% Arr is a structure containing all the arrivals information
% Pos is a structure containing the positions of source and receivers
%
% ARRFile is the name of the Arrivals File
% Narrmx is the maximum number of arrivals allowed
% mbp 9/96

if nargin == 1
   Narrmx = 50;
end

fid = fopen( ARRFile, 'r');	% open the file

% read the header info

fseek( fid, 4, -1 );
ArrType = fread( fid, 4, '*char'   );
ArrType = ArrType';
if ( contains( ArrType, '3D' ) )
   ThreeD = 1;
else
   ThreeD = 0;
end

fseek( fid, 8, 0 );   % skip 4 bytes for end-of-record and 4 bytess for start-of-record
freq = fread( fid, 1, 'float' );

fseek( fid, 8, 0 );   % skip 4 bytes for end-of-record and 4 bytes for beginning-of-record
Nsd           = fread( fid, 1, 'long'  );
Pos.s.z   = fread( fid, Nsd,    'float' );

if ( ThreeD )
   fseek( fid, 8, 0 );
   Ntheta      = fread( fid, 1, 'long'  );
   Pos.r.theta = fread( fid, Ntheta, 'float' );
end

fseek( fid, 8, 0 );
Nrd           = fread( fid, 1, 'long'  );
Pos.r.z       = fread( fid, Nrd,    'float' );

fseek( fid, 8, 0 );
Nrr           = fread( fid, 1, 'long'  );
Pos.r.range   = fread( fid, Nrr,    'float' );

fseek( fid, 8, 0 );

% loop to read all the arrival info (delay and amplitude)

Arr.A         = zeros( Nrr, Narrmx, Nrd, Nsd );
Arr.delay     = zeros( Nrr, Narrmx, Nrd, Nsd );
Arr.SrcAngle  = zeros( Nrr, Narrmx, Nrd, Nsd );
Arr.RcvrAngle = zeros( Nrr, Narrmx, Nrd, Nsd );
Arr.NumTopBnc = zeros( Nrr, Narrmx, Nrd, Nsd );
Arr.NumBotBnc = zeros( Nrr, Narrmx, Nrd, Nsd );

for isd = 1:Nsd
   Narrmx2 = fread( fid, 1, 'int', 8 );
   %disp( [ 'Max. number of arrivals for source index ', num2str( isd ), ' is ', num2str( Narrmx2 ) ] );
   for ird = 1 : Nrd
      for ir = 1 : Nrr
         
         Narr = fread( fid, 1, 'int', 8 );
         Arr.Narr( ir, ird, isd ) = Narr;
         
         if Narr > 0   % do we have any arrivals?
            da = fread( fid, [ 10, Narr ], 'float');
            Narr = min( Narr, Narrmx ); % we'll keep no more than Narrmx values
            Arr.Narr( ir, ird, isd ) = Narr;
            
            Arr.A(      ir, 1:Narr, ird, isd ) = da( 1, 1:Narr ) .* exp( 1i * da( 2, 1:Narr ) * pi/180 );
            Arr.delay(  ir, 1:Narr, ird, isd ) = da( 3, 1:Narr ) + 1i * da( 4, 1:Narr );
            %SrcAngle(  ir, 1:Narr, ird, isd ) = da( 5, : );
            %RcvrAngle( ir, 1:Narr, ird, isd ) = da( 6, : );
            %NumTopBnc( ir, 1:Narr, ird, isd ) = da( 7, : );
            %NumBotBnc( ir, 1:Narr, ird, isd ) = da( 8, : );
         end
      end		% next receiver range
   end		% next receiver depth
end	  % next source depth

fclose( fid );