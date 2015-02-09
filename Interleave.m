function interleaved = Interleave(data)

%% Based on example in standard
desired = [1 0 0 1 0 1 0 0;...
           1 1 0 1 0 0 0 0;...
           0 0 0 1 0 1 0 0;...
           1 0 0 0 0 0 1 1;...
           0 0 1 0 0 1 0 0;...
           1 0 0 1 0 1 0 0].';
interleavedDesired = reshape(desired,48,1).';

%%
Ncbps = 48; % Coded bits per symbol
Nbpsc = 1; % bits per subcarrier
s = max(Nbpsc/2,1); % Coded bits per subcarrier
Nrow = 16;
Ncol=Ncbps/Nrow; 

k=0:Ncbps-1;
i=Nrow*mod(k,Ncol) + floor(k/Ncol); % 1st permutation
permute1 = data(i+1); 
i=k;
j=s*floor(i/s) + mod(i+Ncbps-floor(Nrow*i/Ncbps),s); % 2nd permutation
interleaved = permute1(j+1); 
% reshape(interleaved,8,6)
%%
%interleaved2 = reshape(reshape(interleaved,6,8).',48,1).';
%[interleavedDesired.' , interleaved.',interleaved2.']
%interleaved = interleavedDesired;

end