function  myenv(FILENAME, FREQ, TOPOPT, MEDIA, BOTTOM, ...
                PSMIN, PSMAX, RMAX, NSD, SD, NRD, RD)
    % produce envfile in txt
    %   the argument is referenced by the manual
    %  FILENAME:string ('Pekeris.env') ,
    %  TOPOPT: string
    % MEDIA: struct, .nmesh,.sigma, .zmax, .z, .cp
    % BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho,
    % SD,RD: double arrays

    fileID = fopen([FILENAME, '.env'], 'w');
    note_pos = 30;

    % Title
    Title = sprintf('''%s''', FILENAME);
    fprintf(fileID, '%s\n', mkstr(Title, '! TITLE', note_pos));
    % Freq
    context = sprintf('%s', num2str(FREQ));
    fprintf(fileID, '%s\n', mkstr(context, '! FREQ (Hz)', note_pos));
    % nmedia
    NMEDIA = length(MEDIA);
    fprintf(fileID, '%s\n', mkstr(num2str(NMEDIA), '! NMEDIA (default:1)', note_pos));
    % Top options
    context = sprintf('''%s''', TOPOPT);
    fprintf(fileID, '%s\n', mkstr(context, '! TOP OPTION', note_pos));

    % Layers and SSP
    for i = 1:length(MEDIA)
        % NMESH SIGMA ZMAX
        context = sprintf('%d  %.1f  %.1f', MEDIA(i).nmesh, MEDIA(i).sigma, MEDIA(i).zmax);
        fprintf(fileID, '%s\n', mkstr(context, '! NMESH  SIGMA  ZMAX', note_pos));

        % Z CP
        context = sprintf('%.1f %.1f/', ...
                          MEDIA(i).z{1}, MEDIA(i).cp{1});
        fprintf(fileID, '%s\n', mkstr(context, '! Z  CP  CS  RHO(g/cm3)  ATTN_P  ATTN_S', note_pos));

        for j = 2:length(MEDIA(i).z)
            fprintf(fileID, '%.1f %.1f /\n', MEDIA(i).z{j}, MEDIA(i).cp{j});
        end
    end

    % Bottom options
    % opt sigma
    context = sprintf('''%s''  %.1f', BOTTOM.opt, BOTTOM.sigma);
    fprintf(fileID, '%s\n', mkstr(context, '! BOTOPT, SIGMA (m)', note_pos));

    % z cp cs rho ap as
    context = sprintf('%8.1f %8.1f %4.1f %4.1f/', ...
                      [BOTTOM.z BOTTOM.cp BOTTOM.cs BOTTOM.rho]);
    fprintf(fileID, '%s\n', mkstr(context, ...
                                  '     ! Z  CP  CS  RHO(g/cm3)  AP  AS', note_pos));

    % phase speed
    fprintf(fileID, mkstr(sprintf('%.1f  %.1f', [PSMIN PSMAX]), '! range of phase speed\n', note_pos));

    % rmax
    fprintf(fileID, mkstr(sprintf('%.1f', RMAX), '! RMAX (km)\n', note_pos));

    % source
    assert(NSD == 1);
    fprintf(fileID, '%d\n', NSD);
    fprintf(fileID, '%.1f /    !  SD(1:NSD) (m)\n', SD);

    % Receiver Depth
    fprintf(fileID, '%d\n', NRD);
%     assert(length(RD) == 2);
    context = sprintf('%s/', num2str(RD));
    fprintf(fileID, '%s\n', mkstr(context,  '!  RD(1:NSD) (m)', note_pos));

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
