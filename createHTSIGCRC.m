function crc = createHTSIGCRC( bits )

%% 802.11n CRC for HT-SIG CRC Field
I_D = ones(1,8);
M_D_xor_I_D = xor(bits(1:8), I_D);

M8 = [M_D_xor_I_D,bits(9:end),0 0 0 0 0 0 0 0];
GD = [1 0 0 0 0 0 1 1 1];

for k=1:length(M8) - length(GD) + 1
    
    if M8(k)==0
        continue;
    end
    
    result = xor(M8(k:k+length(GD)-1),GD);
    M8(k:k+length(GD)-1) = result;
    
end

crc = ~M8(end-7:end);

desired = [1 0 1 0 1 0 0 0];

[desired.' crc.']


end