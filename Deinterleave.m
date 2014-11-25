function dataHat = Deinterleave(interleaved)


%%
Ncbps = 48; % Coded bits per symbol
Nbpsc = 1; % bits per subcarrier
s = max(Nbpsc/2,1); % Coded bits per subcarrier

% k = 0:Ncbps-1;
% i = (Ncbps/16)*(mod(k,16)) + floor(k/16);
% permute1 = data(i+1);
% i = k;
% j = s*floor(i/s) + mod(i + Ncbps - floor(16*i/Ncbps),s);
% interleaved = permute1(j+1); 

j = 0:Ncbps-1;
i = s *floor(j/s) + mod(j + floor(16*(j/Ncbps)),s);
depermute1 = interleaved(i+1);
k = 16*i - (Ncbps - 1)*floor(16*i/Ncbps);
dataHat = depermute1(k+1);

%%
%interleaved2 = reshape(reshape(interleaved,6,8).',48,1).';
%[interleavedDesired.' , interleaved.',interleaved2.']
%interleaved = interleavedDesired;

end