function [preambles,pilots,hDataMod,hPreambleMod] = createLegacyPreambles(numSymbols)

if nargin==0
    NumDataSymbolsPerFrame = 1; % Not important ATM
else
    NumDataSymbolsPerFrame = numSymbols; % Not important ATM
end


%% Create Short Preamble
ShortPreamble = [ 0 0  1+1i 0 0 0  -1-1i 0 0 0 ... % [-27:-17]
    1+1i 0 0 0  -1-1i 0 0 0 -1-1i 0 0 0   1+1i 0 0 0 ... % [-16:-1]
    0    0 0 0  -1-1i 0 0 0 -1-1i 0 0 0   1+1i 0 0 0 ... % [0:15]
    1+1i 0 0 0   1+1i 0 0 0  1+1i 0 0 ].';               % [16:27]

% Create modulator
hPreambleMod = comm.OFDMModulator(...
    'NumGuardBandCarriers', [6; 5],...
    'CyclicPrefixLength',   0,...
    'FFTLength' ,           64,...
    'NumSymbols',           1);

% Modulate and scale
ShortPreambleOFDM = sqrt(13/6)*step(hPreambleMod, ShortPreamble);

% Form 10 Short Preambles
CompleteShortPreambleOFDM = [ShortPreambleOFDM; ShortPreambleOFDM; ShortPreambleOFDM(1:32)];

%% Create Long Preamble
LongPreamble = [1,  1, -1, -1,  1,  1, -1,  1, -1,  1,  1,  1,...
    1,  1,  1, -1, -1,  1,  1, -1,  1, -1,  1,  1,  1,  1, 0,...
    1, -1, -1,  1,  1, -1,  1, -1,  1, -1, -1, -1, -1, -1,...
    1,  1, -1, -1,  1, -1,  1, -1,  1,  1,  1,  1].';

x =[1,  1,  1,  1, -1, -1,  1,  1, -1,  1, -1,  1,  1,  1,...
    1,  1,  1, -1, -1,  1,  1, -1,  1, -1,  1,  1,  1,  1, 0,...
    1, -1, -1,  1,  1, -1,  1, -1,  1, -1, -1, -1, -1, -1,...
    1,  1, -1, -1,  1, -1,  1, -1,  1,  1,  1,  1  -1  -1].';

% Modulate
LongPreambleOFDM = step( hPreambleMod, complex(LongPreamble,0) );

% Form 2 Long Preambles
CompleteLongPreambleOFDM =[LongPreambleOFDM(33:64); LongPreambleOFDM; LongPreambleOFDM];

% Combine Preambles
preambles = [CompleteShortPreambleOFDM; CompleteLongPreambleOFDM];

% Create Pilots
hPN = comm.PNSequence(...
    'Polynomial',[1 0 0 0 1 0 0 1],...
    'SamplesPerFrame', NumDataSymbolsPerFrame,...
    'InitialConditions',[1 1 1 1 1 1 1]);

pilot = step(hPN); % Create pilot
pilotsTmp = repmat(pilot, 1, 4 ); % Expand to all pilot tones
pilots = 2*double(pilotsTmp.'<1)-1; % Bipolar to unipolar
pilots(4,:) = -1*pilots(4,:); % Invert last pilot


% NEED FOR DECODING
FFTLength = 64;
CyclicPrefixLength = 16;
PilotCarrierIndices = [12;26;40;54];
NumGuardBandCarriers = [6;5];

% Construct Modulator
hDataMod = comm.OFDMModulator(...
    'CyclicPrefixLength',   CyclicPrefixLength,...
    'FFTLength' ,           FFTLength,...
    'NumGuardBandCarriers', NumGuardBandCarriers,...
    'NumSymbols',           NumDataSymbolsPerFrame,...
    'PilotInputPort',       true,...
    'PilotCarrierIndices',  PilotCarrierIndices,...
    'InsertDCNull',         true);

% Construct Demod from mod
hDataDemod = comm.OFDMDemodulator(hDataMod);

% Construct Demod from mod
hPreambleDemod = comm.OFDMDemodulator(hPreambleMod);

%
% pilotLocationsWithoutGuardbands = PilotCarrierIndices-NumGuardBandCarriers(1);
% % Calculate locations of subcarrier datastreams without guardbands
% TMPdataSubcarrierIndexies = 1:FFTLength-sum(NumGuardBandCarriers);%Remove guardband offsets
% DCNullLocation = 33 - NumGuardBandCarriers(1);%Remove index offsets for pilots and guardbands
% TMPdataSubcarrierIndexies([pilotLocationsWithoutGuardbands;DCNullLocation]) = 0;%Remove pilot and DCNull locations
% dataSubcarrierIndexies = TMPdataSubcarrierIndexies(TMPdataSubcarrierIndexies>0);
% CRC = comm.CRCDetector([1 0 0 1], 'ChecksumsPerFrame',1);


end
