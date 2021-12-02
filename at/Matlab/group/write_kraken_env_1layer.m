function write_kraken_env_1layer(fname, frequency,nummedia,globalopt,...
    nummesh1,sigma1,zmax1,svp1,svs1,svp_depth1,density1,atten_p1,atten_s1,...
    ...nummesh2,sigma2,zmax2,svp2,svs2,svp_depth2,density2,atten_p2,atten_s2,...
    botopt,botsigma,botsvp,botsvs,botsvp_depth,botdensity,botatten_p,botatten_s,...
    minphase,maxphase,rmax,nsd,src_depth,nrd,rcv_depth)

fid = fopen(fname,'w');

fprintf(fid, '%s\n', mkstr('''Sand Bottom''', '! TITLE', 32));
fprintf(fid, '%s\n', mkstr(sprintf('%5.1f', frequency), '! FREQ (Hz)', 32));
fprintf(fid, '%s\n', mkstr(sprintf('%1.0f', nummedia), '! NMEDIA', 32));
fprintf(fid, '%s\n', mkstr(sprintf('''%s''', globalopt), '! OPTIONS', 32));
fprintf(fid, '%s\n', mkstr(sprintf('%1.0f %3.2f %5.1f', nummesh1, sigma1, zmax1), ...
    '! NMESH  SIGMA (roughness, m)  ZMAX(NSSP)', 32));

fprintf(fid, '%s\n', mkstr(...
    sprintf('%7.2f %7.2f %7.2f %7.2f %7.5f %7.5f', svp_depth1(1), svp1(1), svs1(1), density1(1), atten_p1(1), atten_s1(1)), ...
    '! Z(m)  CP  CS(m/s)  DENSITY(kg/m^3)  ATTN_P  ATTN_S', 32));

for ii = 2:length(svp_depth1)
    fprintf(fid,'%7.2f %7.2f %7.2f %7.2f %7.5f %7.5f\n', [svp_depth1(ii) svp1(ii) svs1(ii) density1(ii) atten_p1(ii) atten_s1(ii) ]);
end

% fprintf(fid, '%s\n', mkstr(sprintf('%1.0f %3.2f %5.1f', nummesh2, sigma2, zmax2), ...
%     '! NMESH  SIGMA (roughness, m)  ZMAX(NSSP)', 32));
% fprintf(fid, '%s\n', mkstr(...
%     sprintf('%7.2f %7.2f %7.2f %7.2f %7.5f %7.5f', svp_depth2(1), svp2(1), svs2(1), density2(1), atten_p2(1), atten_s2(1)), ...
%     '! Z(m)  CP  CS(m/s)  DENSITY(kg/m^3)  ATTN_P  ATTN_S', 32));
% 
% for ii = 2:length(svp_depth2)
%     fprintf(fid,'%7.2f %7.2f %7.2f %7.2f %7.5f %7.5f\n', [svp_depth2(ii) svp2(ii) svs2(ii) density2(ii) atten_p2(ii) atten_s2(ii) ]);
% end

fprintf(fid, '%s\n', mkstr(sprintf('''%s'' %1.1f', botopt, botsigma), '! BOTOPT, SIGMA (m)', 32));
for ii = 1 : length(botsvp_depth)
    fprintf(fid, '%7.2f %7.2f %7.2f %7.2f %7.5f %7.5f\n', [botsvp_depth(ii) botsvp(ii) botsvs(ii) botdensity(ii) botatten_p(ii) botatten_s(ii) ]);
end

fprintf(fid, mkstr(sprintf('%5.1f %5.1f', [minphase maxphase]), '! min/max phase speed\n',32));
fprintf(fid, mkstr(sprintf('%5.1f', rmax), '! RMAX (km)\n', 32));
assert(nsd == 1);
fprintf(fid, '%1.0f\n', nsd);
fprintf(fid,'%5.1f / ! source depth \n', src_depth);
assert(length(rcv_depth) == 2);
fprintf(fid,'%1.0f \n', nrd);
fprintf(fid,'%5.1f %5.1f / ! receiver depth \n',rcv_depth);

fclose(fid);

end

function str = mkstr(str1, str2, str2_start)
len = length(str1);
while str2_start <= len + 1
    str2_start = str2_start + 4;
end
dummy = char(32*ones(1,str2_start-len-1));
str = [str1, dummy, str2];
end