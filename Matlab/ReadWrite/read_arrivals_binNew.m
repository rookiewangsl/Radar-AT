function [ Arr, Pos ] = read_arrivals_bin( ARRFile )

% Read the BINARY format arrivals data file written by BELLHOP or BELLHOP3D
%
% Usage: [ Arr, Pos ] = read_arrivals_bin( ARRFile );
%
% Arr is a structure array containing all the arrivals information
% Pos is a structure containing the positions of source and receivers
%
% ARRFile is the name of the ASCII format Arrivals File
%
% mbp Sep 1996
% jcp Jul 2018

% This hard-wired parameter specifies the number of (4 byte) words used
% as record markers at the beginning and end of FORTRAN unformatted records.
% For most FORTRAN compilers, the default is one 4 byte word, while some
% have a command line option to specify the value (e.g. the -frecord-marker
% option in the case of gfortran), while other compilers insist on using
% some other fixed value with no way to change it. If read_arrivals_bin
% crashes or you get garbled results, try changing marker_len to 2.

marker_len = 1;		 % 1 is the default for most FORTRAN compilers

% attempt to open the arrivals file

fid = fopen( ARRFile, 'r' );

if ( fid == -1 )
   error( [mfilename, ': Arrivals file cannot be opened'] )
end

% read the 2D/3D flag to determine the file format

fseek( fid, 4*marker_len, 0 );		% skip over one record marker

flag = fread( fid, [ 1, 4 ], 'uint8=>char' );

% check for the case of erroneously reading an ASCII format arrivals file

if ~strcmp( flag, '''2D''' ) && ~strcmp( flag, '''3D''' )
   error( [mfilename, ': not a BINARY format Arrivals file?'] )
end

% proceed accordingly for the Bellhop 2D vs 3D format

if strcmp( flag, '''2D''' )

% read the 2D format % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
freq     = fread( fid, 1, 'float32' );		% acoustic frequency

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nsz      = fread( fid, 1, 'int32' );		% number of source   depths
Pos.s.sz = fread( fid, Nsz, 'float32' );	% source   depths

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nrz      = fread( fid, 1, 'int32' );		% number of receiver depths
Pos.r.rz = fread( fid, Nrz, 'float32' );	% receiver depths

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nrr      = fread( fid, 1, 'int32' );		% number of receiver ranges
Pos.r.rr = fread( fid, Nrr, 'float32' );	% receiver ranges

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
   fseek( fid, 8*marker_len, 0 );		% skip over two record markers
   Narrmx2 = fread( fid, 1, 'int32' );

   for irz = 1:Nrz

      for irr = 1:Nrr

         % read the number of arrivals at this receiver
         fseek( fid, 8*marker_len, 0 );		% skip over two record markers
         Narr = fread( fid, 1, 'int32' );
         Arr( irr, irz, isd ).Narr = Narr;

         % read and store all the arrivals, if there are any
         if Narr > 0

            % the first one or two words of each column (depends on the
            % marker_len param), contain record markers and are ignored.
            da = fread( fid, [ 8+2*marker_len, Narr ], 'float32' );

            % discard the records markers to simplify indexing
            da = da( 2*marker_len+1:end, 1:Narr );

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

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
freq         = fread( fid, 1, 'float32' );	% acoustic frequency

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nsz          = fread( fid, 1, 'int32' );	% number of source   depths
Pos.s.sz     = fread( fid, Nsz, 'float32' );	% source   depths

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nrtheta      = fread( fid, 1, 'int32' );	% number of receiver bearings
Pos.r.rtheta = fread( fid, Nrtheta, 'float32' );% receiver bearings

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nrz          = fread( fid, 1, 'int32' );	% number of receiver depths
Pos.r.rz     = fread( fid, Nrz, 'float32' );	% receiver depths

fseek( fid, 8*marker_len, 0 );			% skip over two record markers
Nrr          = fread( fid, 1, 'int32' );	% number of receiver ranges
Pos.r.rr     = fread( fid, Nrr, 'float32' );	% receiver ranges

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
   fseek( fid, 8*marker_len, 0 );		% skip over two record markers
   Narrmx2 = fread( fid, 1, 'int32' );

   for irtheta = 1:Nrtheta

      for irz = 1:Nrz

         for irr = 1:Nrr

            % read the number of arrivals at this receiver
            fseek( fid, 8*marker_len, 0 );	% skip over two record markers
            Narr = fread( fid, 1, 'int32' );
            Arr( irr, irz, irtheta, isd ).Narr = Narr;

            % read and store all the arrivals, if there are any
            if Narr > 0

               % the first two or four words of each column (depends on the
               % marker_len param), contain record markers and are ignored.
               da = fread( fid, [ 10+2*marker_len, Narr ], 'float32' );

               % discard the records markers to simplify indexing
               da = da( 2*marker_len+1:end, 1:Narr );

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
% End of read_arrivals_bin.m
