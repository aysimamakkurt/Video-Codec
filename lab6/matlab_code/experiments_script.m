%% Script for experiments %%

%% Initializations
% We use a struct to simplify the parameter exchange
global params img decodedFrameBuffer


% The variable params is a struct that contains all of the encoder configuration information
% It is a global, so it is available also within a function called in this script
% ** You have to properly fill those fields
params.IntraQualityFactorVector = 20; % Start with a single value, then use a vector for multiple encodings
deltaQ = 10;
params.InterQualityFactor = params.IntraQualityFactor-DeltaQ; % We use differe QF for Intra and Inter
params.inputVideoName = 'foreman'; % Use one of the provided .y files
params.inputVideoFile   = [params.inputVideoName '_cif.y']   % full input file name. Add the path if needed
params.modeSelectionLabmda = 10;  % Lagrangian param for mode selection. Start with 10
params.motionEstimationLambda = 3; % Lagrangian param for ME. Start with 3
params.ME.search=5;  % ME search window size
params.ME.dist = 'SAD'; % ME metric
params.GOPSize = 1; % Start with an "All Intra" configuration. Then move to IPP..P  Gops
params.numberOfGops = 3; % Start with a small number of GOPS for test, then use the full sequence
params.blockSize = 8;  % Can be modified later
params.nRow = 288;
params.nCol = 352;
params.verbose = 1;  % Setting the verboseness level might be useful for debugging and testing
% other possible parameters can be set as fields of the struct
decodedFrameBuffer.reference = zeros(params.nRow,params.nCol); % Since we do not use B, one decoded refernce is enough
decodedFrameBuffer.current   = zeros(params.nRow,params.nCol); % We also need a buffer for the current encoded image
params.compressedFileName = 'test.bin'; 


%% Initializations
% We want to perform a number pf encoding of a video sequence
% This number is the number of quantation steps
% For each quantization step, we compute a rate and a distortion
% Let us create the data structure to store these pieces of information

nEncodings = numel(params.IntraQualityFactorVector);
PSNR = zeros(nEncodings, 1); 
RATE = zeros(nEncodings, 1); 

%% Init for compression
params.q_mtx1 =     [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];


%% Main loop
for qualityIndex = 1:n
    param.qual = params.IntraQualityFactorVector(qualityIndex);
    [R, P] = sequenceEncoder(); %don't need input arg because param is global!
    RATE(qualityIndex) = R;
    PSNR(qualityIndex) = P;
end

%% This main loop can be replicated in order to test and compare different configurations, for example
params.GOPSize = 2; % let us test an IPIP... gop structure
PSNR2 = zeros(nEncodings, 1); 
RATE2 = zeros(nEncodings, 1); 
%% Main loop
for qualityIndex = 1:n
    param.qual = params.IntraQualityFactorVector(qualityIndex);
    [R, P] = sequenceEncoder(); %don't need input arg because param is global!
    RATE2(qualityIndex) = R;
    PSNR2(qualityIndex) = P;
end

% Compare the results
plot(RATE, PSNR,RATE2, PSNR2) ;
legend('All-Intra', 'IPIP gop');