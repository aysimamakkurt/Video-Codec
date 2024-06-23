function [RATE, PSNR, perFrameRATE, perFramePSNR] = sequenceEncoder()
% This function encodes a full sequence 
% All the encoder configuration is specified in params
% It returns the average coding rate (bpp) and the average PSNR
% Also the per-frame metrics can be returned

global params  

% Initialization: how many images - and store their rate and PSNR
nFrames = params.GOPSize * params.numberOfGops; 
perFramePSNR = zeros(nFrames, 1);
perFrameRATE = zeros(nFrames, 1);

% define the quantization matrix for Intra frames
SF_Intra = (params.qual==100)+(params.qual<=99&&params.qual>50)*(200-2*params.qual)+ (params.qual<=50)*(5000/params.qual);
params.q_mtx_Intra = ceil(params.q_mtx1*SF_Intra/100);
params.q_mtx_Intra (params.q_mtx_Intra >256)=256;

% define the quantization matrix for Inter frames
params.qual_Inter=max(min(params.qual - params.deltaQ,100),0); 

SF_Inter = (params.qual_Inter==100)+(params.qual_Inter<=99&&params.qual_Inter>50)*(200-2*params.qual_Inter)+ (params.qual_Inter<=50)*(5000/params.qual_Inter);
params.q_mtx_Inter = ceil(params.q_mtx1*SF_Inter/100);
params.q_mtx_Inter (params.q_mtx_Inter >256)=256; 


% Create and open the output file
params.fid = fopen(params.compressedFileName, 'wb');
 
% Main loop
for gopIndex = 1:params.numberOfGops
     params.firstFrameGOP =  params.GOPSize*(gopIndex-1) + 1;
     params.lastFrameGOP  =  params.GOPSize*gopIndex;
     [GOP_RATE, GOP_PSNR] = gopEncoder(gopIndex);
     perFramePSNR(params.firstFrameGOP:params.lastFrameGOP)   =  GOP_PSNR;
     perFrameRATE(params.firstFrameGOP:params.lastFrameGOP)   =  GOP_RATE;
end

% Compute average rate and PSNR
PSNR = mean(perFramePSNR);
RATE = mean(perFrameRATE); 

% Close the output file
fclose(params.fid); 
