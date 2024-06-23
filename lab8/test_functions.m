%% Script for testing
clc; clear variables; 
% Parameters
global params img decodedFrameBuffer
params.quantizationSteps = 20; % Start with a single value, then use a vector for multiple encodings
params.inputVideoName = 'foreman'; % Use one of the provided .y files
params.inputVideoFile   = [params.inputVideoName '_cif.y'];  % full input file name. Add the path if needed
params.modeSelectionLabmda = 10;  % Lagrangian param for mode selection. Start with 10
params.motionEstimationLambda = 3; % Lagrangian param for ME. Start with 3
params.ME.search=5;  % ME search window size
params.ME.dist = 'SAD'; % ME metric
params.GOPSize = 12; % Start with an "All Intra" configuration. Then move to IPP..P  Gops
params.numberOfGops = 3; % Start with a small number of GOPS for test, then use the full sequence
params.blockSize = 8;  % Can be modified later
params.nRow = 288;
params.nCol = 352;
params.verbose = 1;  % Setting the verboseness level might be useful for debugging and testing
% other possible parameters can be set as fields of the struct
decodedFrameBuffer.reference = zeros(params.nRow,params.nCol); % Since we do not use B, one decoded refernce is enough
decodedFrameBuffer.current   = zeros(params.nRow,params.nCol); % We also need a buffer for the current encoded image

nEncodings = numel(params.quantizationSteps);
PSNR = zeros(nEncodings, 1); 
RATE = zeros(nEncodings, 1); 

%% Test 1: loadIntra
gopIndex = 1; %% Modify this value and test the result
params.firstFrameGOP = params.GOPSize * (gopIndex-1) +1 ;
x = loadIntra(gopIndex);
figure; image(uint8(x)); axis image; axis off; colormap("gray")

%% Test 2: ypsnr
gopIndex = 1;
params.firstFrameGOP = params.GOPSize * (gopIndex-1) +1 ;
x = loadIntra(gopIndex);
noiseSTD = 20;  %% TEST if the noise standard deviation is doubled, the PSNR should decrease of 6 dBs
                 % Modify this value and test the function  
y = x+noiseSTD*randn(size(x));
figure; image(uint8([x y])); axis image; axis off; colormap("gray")
fprintf('STD: %3.2f, PSNR: %5.3f dB\n',noiseSTD,ypsnr(x,y))

%% Test 3: appendToFile(imgBitStream)

% Let us create an output file
testFileName = 'test_appendFile.bin';
params.fid = fopen(testFileName, 'wb');
% Let us create a random bitstream, and append it to the file
nBytes = 5;        % Modify this value and test the function  
nBits = 8*nBytes;
bitStream = char(double(rand(1,nBits)>0.5)+48); % char(48) is '0'
appendToFile(bitStream);
fclose (params.fid);

% Let us check the size of the file
sz = dir(testFileName).bytes;
fprintf('Stream size: %d bytes\nFile size:   %d bytes\n',nBytes, sz);

% Let us check the content of the file
fid = fopen(testFileName, 'rb');
fromFile = fread(fid,nBits, 'ubit1')+48;
fclose(fid);
fprintf('Written: %s\nRead:    %s\n',bitStream,fromFile);


%% Test 4: intraBlockCoder
q_mtx1 =     [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];
params.qual = 80; 
SF = (params.qual==100)+(params.qual<=99&&params.qual>50)*(200-2*params.qual)+ (params.qual<=50)*(5000/params.qual);
params.q_mtx = ceil(q_mtx1*SF/100);
params.q_mtx (params.q_mtx>256)=256; 

% Let us encode the same block as in Lab 4. We must obtain the same results
% We take the block in the image "color_small" at positions
% rowPos = 209;
% colPos = 161;
% When we run the script for lab 4 with this block, we should obtain the
% same results as here
% We have copied here the values of previous DC and of the block
previousDC = -80;
grayBlock =[
   60.9052   63.2249   67.2717   70.1239   72.4435   74.0633   77.8533   81.2886
   60.0464   60.9052   64.0837   66.4129   67.2717   68.3873   70.9638   73.2835
   56.9048   58.8604   59.9665   61.0358   60.5411   61.0547   61.4652   59.7570
   51.6815   53.5769   52.7275   49.4322   48.5639   53.3527   67.6951   85.7811
   40.6568   40.8852   51.4195   74.1028   94.0137  108.0959  118.1072  130.3832
   72.8188  100.1277  114.4237  120.9576  126.9651  127.4409  125.9285  129.7520
  117.9741  119.5749  120.3264  122.3618  125.1581  127.1935  130.2467  132.2821
  116.4840  120.0507  122.3523  124.1404  125.4149  127.7071  131.5211  132.5389 ];

% Now we run the test:
centeredValues = grayBlock-128;
[bits, decCenteredValues] =blockIntraCoding(centeredValues,previousDC)
bpp = numel(bits)/64
decodedBlock = decCenteredValues+128; 
% Compare to the results obtained in lab no 4. 

%% Test no 5. Complete Intra coding function
% Here we test the full Intra coding function
% Let us set all the parameters and encode an image in Intra mode

gopIndex = 1; %% Modify this value and test the result
params.firstFrameGOP = params.GOPSize * (gopIndex-1) +1 ;
img = loadIntra(gopIndex);
imgBitStream = IntraImgEncoder();
imgBPP = numel(imgBitStream)/numel(img);
PSNR = ypsnr(img,decodedFrameBuffer.current);
fprintf('RATE: %4.3f bpp\nPSNR: %4.2f dB\n',imgBPP,PSNR)

% Example of typical values, first image of foreman 
% Quality = 80 - rate = 1.181 bpp - PSNR = 38.61 dB