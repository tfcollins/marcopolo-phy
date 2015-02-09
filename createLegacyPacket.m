function [packets , SIGNAL_OFDMModulated, SERVICE] = createLegacyPacket(numPackets)

%% Legacy frame (Non-HT PPDU)

% Packet Structure (See page 259 of 802.11n Standard)
% L-STF | L-LTF | L-SIG | DATA

L_LENGTH = 100;

% Preamble
[PreamblePLCP, Pilots, hDataMod,~] = createLegacyPreambles;
% Header
% Coded/OFDM (BPSK, R=1/2)
% 24 bits of configuration fields
RATE = [1 0 1 1]; % 4 bits, Ref 1 Table 80
RESERVED = 0; % Always set to 0
LENGTH = de2bi(L_LENGTH,12,'right-msb'); % 12 bits
PARITY = 0; % 1 bit (Almost always 0)
TAIL = [0 0 0 0 0 0]; % 6 or 7 bits, depending how reserved used 
SIGNAL = [RATE, RESERVED, LENGTH, PARITY, TAIL];
%clc;reshape(SIGNAL,12,2) % compare with table

% Encode
k = 7;
t = poly2trellis(7, [133 171]); % Define trellis
hConvEnc = comm.ConvolutionalEncoder(t);
SIGNAL_Encoded = step(hConvEnc,SIGNAL.').';
%clc;reshape(SIGNAL_Encoded,8,6) % compare with table (Correct)

% Interleave
Ncbps = 48; % Coded bits per symbol
Nbpsc = 1; % bits per subcarrier
Nrow = 16;

SIGNAL_Interleaved = Interleave(SIGNAL_Encoded);
%clc;reshape(SIGNAL_Interleaved,8,6)
%SIGNAL_Deinterleaved = Deinterleave(SIGNAL_Interleaved);
%[SIGNAL_Encoded.' , SIGNAL_Deinterleaved.']

% Modulate
SIGNAL_Modulated = 2*SIGNAL_Interleaved-1; %BPSK
SIGNAL_OFDMModulated = step(hDataMod,SIGNAL_Modulated.',-1*Pilots);
%clc;fftshift(fft(SIGNAL_OFDMModulated(17:end))) % check table G.10 (Correct)

SCRAMBLER_INITIALIZATION = zeros(1,7);
RESERVED_SERVICE = [0 1 0 1 0 1 0]; % Reserved
SERVICE = [SCRAMBLER_INITIALIZATION, RESERVED_SERVICE];

%HeaderPLCP = [SIGNAL_OFDMModulated, SERVICE];
HeaderPLCP = [SIGNAL_OFDMModulated]; % FIX LATER!!!!!!!!!!!!!! NEED SERVICE FIELD
% Problems, is reserve bit used in SIGNAL?

% Add data to preamble and header, data does not represent coderate and
% modulation of header
TailBits = 6;
bitsInData = L_LENGTH*8+TailBits;
bitsInData = bitsInData + 144 - mod(bitsInData,48);
modDataBits = randi([0 1],bitsInData,1);
NumSymbols = bitsInData/48;
modDataBits = reshape(modDataBits,48,NumSymbols);

% Construct Modulator
[~,pilots,hDataMod,~] = createLegacyPreambles(NumSymbols);

ofdmData = step(hDataMod,modDataBits,-1*pilots);

% Put it all together
Packet = [PreamblePLCP; HeaderPLCP; ofdmData];

packets = repmat(Packet,numPackets*length(Packet),1);

end