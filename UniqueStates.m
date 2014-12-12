
N = 16;
BitsEnc = zeros(N,8);

for x=0:N-1
    
    Bits = de2bi(x,4,'right-msb'); % 12 bits
    
    % Encode
    k = 7;
    t = poly2trellis(7, [133 171]); % Define trellis
    hConvEnc = comm.ConvolutionalEncoder(t);
    BitsEnc(x+1,:) = step(hConvEnc,Bits.').';

end

disp(['Unique Blocks: ',num2str(size(unique(BitsEnc,'rows'),1))]);