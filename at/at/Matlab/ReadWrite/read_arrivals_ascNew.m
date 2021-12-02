function [ Arr, Pos ] = read_arrivals_asc( ARRFile )

% Read the ASCII format arrivals data file written by BELLHOP or BELLHOP3D
%
% Usage: [ Arr, Pos ] = read_arrivals_asc( ARRFile );
%
% Arr is a structure array containing all the arrivals information
% Pos is a structure containing the positions of source and receivers
%
% ARRFile is the name of the ASCII format Arrivals File
%
% mbp Sep 1996
% jcp Jul 2018

fid = fopen( ARRFile, 'r' );	% open the file

if ( fid == -1 )
   error( [mfilename, ': Arrivals file cannot be opened'] )
end

% read the 2D/3D flag to determine the file format

flag = fscanf( fid, '%s',  1 );

% check for the case of erroneously reading a BINARY format arrivals file

if ~strcmp( flag, '''2D''' ) && ~strcmp( flag, '''3D''' )
   error( [mfilename, ': not an ASCII format Arrivals file?'] )
end

% proceed accordingly for the Bellhop 2D vs 3D format

if strcmp( flag, '''2D''' )

% read the 2D format % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

freq     = fscanf( fid, '%f',  1 );	% acoustic frequency

Nsz      = fscanf( fid, '%i',  1 );	% number of source   depths
Pos.s.sz = fscanf( fid, '%f', Nsz );	% source   depths

Nrz      = fscanf( fid, '%i',  1 );	% number of receiver depths
Pos.r.rz = fscanf( fid, '%f', Nrz );	% receiver depths

Nrr      = fscanf( fid, '%i',  1 );	% number of receiver ranges
Pos.r.rr = fscanf( fid, '%f', Nrr );	% receiver ranges

% pre-allocate memory for the Arr arrivals structure array

Arr = repmat( struct( 'Narr', {  0  }, ...
                         'A', { [ ] }, ...
                     'delay', { [ ] }, ...
              'SrcDeclAngle', { [ ] }, ...
             'RcvrDeclAngle', { [ ] }, ...
                 'NumTopBnc', { [ ] }, ...
                 'NumBotBnc', { [ ] } ), Nrr, Nrz, Nsz );

% loop over sources, rcv depths and rcv ranges to read all arrival info

for isd = 1:Nsz

   % read the maximum number of arrivals for this source
   Narrmx2 = fscanf( fid, '%i', 1 );

   for irz = 1:Nrz

      for irr = 1:Nrr

         % read the number of arrivals at this receiver
         Narr = fscanf( fid, '%i', 1 );
         Arr( irr, irz, isd ).Narr = Narr;

         % read and store all the arrivals, if there are any
         if Narr > 0

            da = fscanf( fid, '%f', [ 8, Narr ] );

            Arr( irr, irz, isd ).A = ...
                 da( 1, 1:Narr ) .* exp( 1.0i * da( 2, 1:Narr ) * pi/180.0 );
            Arr( irr, irz, isd ).delay = ...
                 da( 3, 1:Narr ) + 1.0i * da( 4, 1:Narr );
            Arr( irr, irz, isd ).SrcDeclAngle  = da( 5, 1:Narr );
            Arr( irr, irz, isd ).RcvrDeclAngle = da( 6, 1:Narr );
            Arr( irr, irz, isd ).NumTopBnc     = da( 7, 1:Narr );
            Arr( irr, irz, isd ).NumBotBnc     = da( 8, 1:Narr );

         end	% if any arrivals

      end	% next receiver range

   end	% next receiver depth

end	% next source

else	% end of read 2D file format data

% read the 3D format % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

freq         = fscanf( fid, '%f',  1 );		% acoustic frequency

Nsz          = fscanf( fid, '%i',  1 );		% number of source   depths
Pos.s.sz     = fscanf( fid, '%f', Nsz );	% source   depths

Nrtheta      = fscanf( fid, '%i',  1 );		% number of receiver bearings
Pos.r.rtheta = fscanf( fid, '%f', Nrtheta );	% receiver bearings

Nrz          = fscanf( fid, '%i',  1 );		% number of receiver depths
Pos.r.rz     = fscanf( fid, '%f', Nrz );	% receiver depths

Nrr          = fscanf( fid, '%i',  1 );		% number of receiver ranges
Pos.r.rr     = fscanf( fid, '%f', Nrr );	% receiver ranges

% pre-allocate memory for the Arr arrivals structure array

Arr = repmat( struct( 'Narr', {  0  }, ...
                         'A', { [ ] }, ...
                     'delay', { [ ] }, ...
              'SrcDeclAngle', { [ ] }, ...
              'SrcAzimAngle', { [ ] }, ...
             'RcvrDeclAngle', { [ ] }, ...
             'RcvrAzimAngle', { [ ] }, ...
                 'NumTopBnc', { [ ] }, ...
                 'NumBotBnc', { [ ] } ), Nrr, Nrz, Nrtheta, Nsz );

% loop over sources, rcv bearings, depths and ranges to read all arrival info

for isd = 1:Nsz

   % read the maximum number of arrivals for this source
   Narrmx2 = fscanf( fid, '%i', 1 );

   for irtheta = 1:Nrtheta

      for irz = 1:Nrz

         for irr = 1:Nrr

            % read the number of arrivals at this receiver
            Narr = fscanf( fid, '%i', 1 );
            Arr( irr, irz, irtheta, isd ).Narr = Narr;

            % read and store all the arrivals, if there are any
            if Narr > 0

               da = fscanf( fid, '%f', [ 10, Narr ] );

               Arr( irr, irz, irtheta, isd ).A = ...
                    da( 1, 1:Narr ) .* exp( 1.0i * da( 2, 1:Narr ) * pi/180.0 );
               Arr( irr, irz, irtheta, isd ).delay = ...
                    da( 3, 1:Narr ) + 1.0i * da( 4, 1:Narr );
               Arr( irr, irz, irtheta, isd ).SrcDeclAngle  = da(  5, 1:Narr );
               Arr( irr, irz, irtheta, isd ).SrcAzimAngle  = da(  6, 1:Narr );
               Arr( irr, irz, irtheta, isd ).RcvrDeclAngle = da(  7, 1:Narr );
               Arr( irr, irz, irtheta, isd ).RcvrAzimAngle = da(  8, 1:Narr );
               Arr( irr, irz, irtheta, isd ).NumTopBnc     = da(  9, 1:Narr );
               Arr( irr, irz, irtheta, isd ).NumBotBnc     = da( 10, 1:Narr );

            end	% if any arrivals

         end	% next receiver range

      end	% next receiver depth

   end	% next receiver bearing

end	% next source

end	% end of read 3D file format data

% close the arrivals file

fclose( fid );

%
% End of read_arrivals_asc.m
