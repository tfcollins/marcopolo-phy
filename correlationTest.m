% Locate packet type in signal
numPackets = 4;
[packets , SIGNAL_OFDMModulated, SERVICE] = createLegacyPacket(numPackets);

% Add gaps
packets = [zeros(1e3,1); packets; zeros(1e3,1)];

% Add noise
noiseLevel = 30;
transmission = awgn(packets,noiseLevel,'measured');

% Make correlation filter from length field
taps = SIGNAL_OFDMModulated;%(6:6+12-1);
taps = taps(end:-1:1);

% Correlate
cor = filter(taps,1,transmission);
cor = abs(cor);
stem(cor);


