function [RATE PSNR] = sequenceEncoder()
% This function encodes a full sequence 
% All the encoder configuration is specified in params
% It returns the coding rate (bpp) and the PSNR

global params img decodedFrameBuffer

% Initialization: how many images - and store their rate and PSNR
nFrames = params.GOPSize * params.numberOfGops; 
perFramePSNR = zeros(nFrames, 1);
perFrameRATE = zeros(nFrames, 1);

% define the quantization matrix
SF = (params.qual==100)+(params.qual<=99&&params.qual>50)*(200-2*params.qual)+ (params.qual<=50)*(5000/params.qual);
q_mtx = ceil(params.q_mtx1*SF/100);
params.q_mtx (q_mtx>256)=256; 

% Create and open the output file
params.fid = fopen(params.compressedFileName, 'wb');
 
% Main loop
for gopIndex = 1:params.numberOfGops,
     params.firstFrameGOP =  params.GOPSize*(gopIndex-1) + 1;
     params.lastFrameGOP  =  params.GOPSize*gopIndex;
     [GOP_RATE, GOP_PSNR] = gopEncoder(params, gopIndex);
     perFramePSNR(params.firstFrameGOP:params.lastFrameGOP)   =  GOP_PNSR;
     perFrameRATE(params.firstFrameGOP:params.lastFrameGOP)   =  GOP_RATE;
end

% Compute average rate and PSNR
PSNR = mean(perFramePSNR);
RATE = mean(perFrameRATE); 

% Close the output file
fclose(params.fid); 
