clc;
%% References
% [1] 802.11a http://www.wardriving.ch/hpneu/info/doku/802.11a-1999.pdf

%% Legacy frame (Non-HT PPDU)
% Preamble
[PreamblePLCP, Pilots, hDataMod,hPreambleMod] = createLegacyPreambles;
% Header
% Coded/OFDM (BPSK, R=1/2)
% 24 bits of configuration fields
RATE = [1 0 1 1]; % 4 bits, Ref 1 Table 80
RESERVED = 0;
LENGTH = de2bi(100,12,'right-msb'); % 12 bits
PARITY = 0; % 1 bit
TAIL = [0 0 0 0 0 0]; % 6 or 7 bits, depending how reserved used 
SIGNAL = [RATE, RESERVED, LENGTH, PARITY, TAIL];
%clc;reshape(SIGNAL,12,2)

% Encode
k = 7;
t = poly2trellis(7, [133 171]); % Define trellis
hConvEnc = comm.ConvolutionalEncoder(t);
SIGNAL_Encoded = step(hConvEnc,SIGNAL.').';
%clc;reshape(SIGNAL_Encoded,8,6)

% Interleave
SIGNAL_Interleaved = Interleave(SIGNAL_Encoded);
%clc;reshape(SIGNAL_Interleaved,8,6)
%SIGNAL_Deinterleaved = Deinterleave(SIGNAL_Interleaved);
%[SIGNAL_Encoded.' , SIGNAL_Deinterleaved.']

% Modulate
SIGNAL_Modulated = 2*SIGNAL_Interleaved-1;
SIGNAL_OFDMModulated = step(hDataMod,SIGNAL_Modulated.',Pilots);
%clc;fftshift(fft(SIGNAL_OFDMModulated(17:end))) % check table G.10

SCRAMBLER_INITIALIZATION = zeros(1,7);
RESERVED_SERVICE = [0 1 0 1 0 1 0]; % Reserved
SERVICE = [SCRAMBLER_INITIALIZATION, RESERVED_SERVICE];

HeaderPLCP = [SIGNAL, SERVICE];
% Problems, is reserve bit used in SIGNAL?


%% HT-Mixed
HT_SIG = ;
HT_STF = ;
HT_LFT = ;

SIGNAL_Interleaved


HT_MIXED = [SIGNAL_Interleaved, HT_SIG, HT_STF, HT_LFT];






