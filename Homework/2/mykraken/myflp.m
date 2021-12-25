function  myflp(FILENAME,  Opt, NModes, NProf, ...
                RProf, NR, RMin, RMax, NSD, SD, NRD, RD, RR)
    % produce envfile in txt
    %   the argument is referenced by the manual
    %  FILENAME:string ('Pekeris.env') ,
    %  TOPOPT: string
    % MEDIA: struct, .nmesh,.sigma, .zmax, .z, .cp
    % BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho,
    % SD,RD: double arrays

    fileID = fopen([FILENAME, '.flp'], 'w');
    note_pos = 30;

    % Title
    Title = sprintf('''%s''', FILENAME);
    fprintf(fileID, '%s\n', mkstr(Title, '! TITLE', note_pos));
    % Opt
    context = sprintf('''%s''', Opt);
    fprintf(fileID, '%s\n', mkstr(context, '! OPT ''X/R'' (coords), ''C/A'' (couple/adiab)', note_pos));
    % NModes
    fprintf(fileID, '%s\n', mkstr(num2str(NModes), '! M  (number of modes to include)', note_pos));
    % NProfile
    fprintf(fileID, '%s\n', mkstr(num2str(NProf), '！NPROF', note_pos));
    % RProfile
    fprintf(fileID, '%s\n', mkstr(num2str(RProf), '! RPROF(1:NPROF) (km)', note_pos));

    % Receiver Range
    fprintf(fileID, '%s\n', mkstr(num2str(NR), '！ NR', note_pos));
    fprintf(fileID, mkstr(sprintf('%.1f  %.1f/', [RMin RMax]), '! RMIN,   RMAX (km)\n', note_pos));

    % source
    assert(NSD == 1);
    fprintf(fileID, '%d\n', NSD);
    fprintf(fileID, '%.1f /    !  SD(1:NSD)  (m) \n', SD);

    % Receiver Depth
    fprintf(fileID, '%d\n', NRD);
%     assert(length(RD) == 2);
    context = sprintf('%s/', num2str(RD));
    fprintf(fileID, '%s\n', mkstr(context,  '!  RD(1:NRD) (m)', note_pos));

    % Receiver Range Variance
    fprintf(fileID, '%d\n', NRD);
    fprintf(fileID, '%.1f /    ! RR(1:NRR)   (m) \n', RR);

    fclose(fileID);
end

% produce one line for env file
function line = mkstr(info, note, note_pos)
    len = length(info);
    while note_pos <= len
        note_pos = note_pos + 4;
    end
    space = char(32 * ones(1, note_pos - len - 1));
    line = [info, space, note];
end
