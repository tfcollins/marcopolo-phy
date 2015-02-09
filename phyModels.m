clc;
%% ToDo
% 1.) Confirm OFDM modulation for HT-SIG data
% 2.) Determine error in interleaver

%% References
% [1] "802.11a Standard" http://www.wardriving.ch/hpneu/info/doku/802.11a-1999.pdf

%% Legacy frame (Non-HT PPDU)

% Packet Structure (See page 259 of 802.11n Standard)
% L-STF | L-LTF | L-SIG | DATA

L_LENGTH = 100;

% Preamble
[PreamblePLCP, Pilots, hDataMod,hPreambleMod] = createLegacyPreambles;
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

HeaderPLCP = [SIGNAL, SERVICE];
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
[preambles,pilots,hDataMod,hPreambleMod] = createLegacyPreambles(NumSymbols);

ofdmData = step(hDataMod,modDataBits,-1*pilots);

% Put it all together
Packet = [PreamblePLCP; HeaderPLCP.'; ofdmData];

%% HT-Mixed (20MHz Version Only)
% In mixed mode the front portion of the preamble is identical to the
% legacy mode, so it will contain the length field. The HT portion of the
% mixed header contains a 16 bit length field located in HT-SIG portion of
% the header.  This bitfield is the number of octets of data in the PSDU in
% the range of 0 to 65535.

% Packet Structure (See page 259 of 802.11n Standard)
% L-STF | L-LTF | L-SIG | HT-SIG | HT-STF | HT-LTF .... HT-LTF | DATA

% HT-SIG1 (page 275)
MODULATION_AND_CODING = [0 0 0 0 0 0 0];
CBW_20_40 = 0; % Set to 0 for 20 MHz or 40 MHz upper/lower. Set to 1 for 40 MHz.
HT_LENGTH = de2bi(100,16,'right-msb'); % 16 bits, The number of octets of data in the PSDU in the range of 0 to 65535
HT_SIG1 = [MODULATION_AND_CODING, CBW_20_40, HT_LENGTH];

% HT-SIG2
SMOOTHING = 1;
NOT_SOUNDING = 1;
RESERVED = 0;
AGGREGATION = 0;
STBC = [0 0];
FEC = 0; % 1 LDPC, 0 BCC
SHORT_GI = 0; % Set if short GI is used after the HT training
NUMBER_OF_EXTENDED_SPATIAL_STREAMS = [0 0];
% Calculate CRC
CRC = createHTSIGCRC([HT_SIG1,SMOOTHING, NOT_SOUNDING, RESERVED, AGGREGATION, STBC,...
           FEC, SHORT_GI, NUMBER_OF_EXTENDED_SPATIAL_STREAMS]);
TAIL_BITS = [0 0 0 0 0 0];% Used to terminate the trellis of the convolution coder. Set to 0.
HT_SIG2 = [SMOOTHING, NOT_SOUNDING, RESERVED, AGGREGATION, STBC,...
           FEC, SHORT_GI, NUMBER_OF_EXTENDED_SPATIAL_STREAMS, CRC, TAIL_BITS];

% Encode
k = 7;
t = poly2trellis(7, [133 171]); % Define trellis
hConvEnc = comm.ConvolutionalEncoder(t);
HT_SIG1_Encoded = step(hConvEnc,HT_SIG1.').';
HT_SIG2_Encoded = step(hConvEnc,HT_SIG2.').';
       
% Interleave
HT_SIG1_Interleaved = Interleave(HT_SIG1_Encoded);
HT_SIG2_Interleaved = Interleave(HT_SIG2_Encoded);
       
% Modulate (RECONFIRM)
HT_SIG1_Modulated = 1i*(2*HT_SIG1_Interleaved-1);
HT_SIG1_OFDMModulated = step(hDataMod,HT_SIG1_Modulated.',Pilots);       
HT_SIG2_Modulated = 1i*(2*HT_SIG2_Interleaved-1);
HT_SIG2_OFDMModulated = step(hDataMod,HT_SIG2_Modulated.',Pilots);       
       
       
       
% HT_STF = createHT_STF;
% HT_LFT = createHT_LTF;
% 
% SIGNAL_Interleaved
% 
% 
% HT_MIXED = [SIGNAL_Interleaved, HT_SIG1, HT_SIG2, HT_STF, HT_LFT];






