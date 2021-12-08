function write_fieldflp( flpfil, Option, Pos, nmodes )

% Write a field-parameters file

if ( ~strcmp( flpfil( end - 3 : end ), '.flp' ) )
  flpfil = [ flpfil '.flp' ]; % append extension
end

fid = fopen( flpfil, 'w' );

fprintf(fid, '%s\n', mkstr('/', '! Title', 65));
fprintf(fid, '%s\n', mkstr(sprintf('''%s''', Option), '! Option', 65));
fprintf(fid, '%s\n', mkstr(sprintf('%d', nmodes), '! Mlimit', 65));
fprintf(fid, '%s\n', mkstr('1', '! NPROF', 65));
fprintf(fid, '%s\n', mkstr(sprintf('%.3f', 0), '! RPROF(1:NPROF) (km)', 65));

% receiver ranges
fprintf(fid, '%s\n', mkstr(sprintf('%i', length(Pos.r.range)), '! NR', 65));
context = sprintf('%10.3f %10.3f /', Pos.r.range(1), Pos.r.range(end));
fprintf(fid, '%s\n', mkstr(context, '! R(1:NR)   (km)', 65));

% source depths
fprintf(fid, '%s\n', mkstr(sprintf('%i', length(Pos.s.depth)), '! NSD', 65));
if length(Pos.s.depth)>1
    context = sprintf('%10.3f %10.3f /', Pos.s.depth(1), Pos.s.depth(end));
else
    context = sprintf('%10.3f /', Pos.s.depth);
end
fprintf(fid, '%s\n', mkstr(context, '! SD(1:NSD) (m)', 65));

% receiver depths
fprintf(fid, '%s\n', mkstr(sprintf('%i', length(Pos.r.depth)), '! NRD', 65));
context = sprintf('%10.3f %10.3f /', Pos.r.depth(1), Pos.r.depth(end));
fprintf(fid, '%s\n', mkstr(context, '! RD(1:NRD) (m)', 65));

% receiver range offsets (vertical / tilting rcv array)
fprintf(fid, '%s\n', mkstr(sprintf('%i', length(Pos.r.depth)), '! NRR', 65));
context = sprintf('%10.3f %10.3f /', 0, 0);
fprintf(fid, '%s\n', mkstr(context, '! RR(1:NRR) (m)', 65));

fclose( fid );

end

function str = mkstr(str1, str2, str2_start)
len = length(str1);
while str2_start <= len
    str2_start = str2_start + 4;
end
dummy = char(32*ones(1,str2_start-len-1));
str = [str1, dummy, str2];
end