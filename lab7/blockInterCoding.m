function [blockBitStream, decodedBlock, QDC, mv] = blockInterCoding(currentBlock,previousDC)
global params 

% Motion estimation, producing the predictor and the motion vector
[bestMatch, mv] = motionEstimation(currentBlock);

% Encode the motion vector
blockBitStream = [encodeSEG(mv(1)), encodeSEG(mv(2))]; 

% Compute the prediction error
predictionErrorBlock = currentBlock - bestMatch;

% Encode the prediction error as it was INTRA coding
dctBlock = dct2(predictionErrorBlock);
% A special quantization matrix must be used
quantizedDctBlock = round(dctBlock./params.q_mtx_Inter);
%------------------------------------
if params.verbose==2  % We display this only if verbose is on level 2
    disp('Original block:')
    currentBlock
    disp('Best predictor block:')
    bestMatch
    disp('Motion vector')
    mv
    disp('DCT')
    dctBlock
    disp('Quantized DCT')
    quantizedDctBlock
end
%------------------------------------
losslessCoderVerboseness = 0;
blockBitStream = block_entropy_coding(quantizedDctBlock(:)', losslessCoderVerboseness);
invQuant = params.q_mtx_Inter .* quantizedDctBlock;
decodedPredErrBlock = idct2(invQuant);
QDC = quantizedDctBlock(1,1);

% The decoded block is obtained by adding the quantized prediction error to the matched block
decodedBlock = bestMatch + decodedPredErrBlock ; 

%------------------------------------
if params.verbose==2
    disp('Inv. Quant. ')
    invQuant
    disp('Decoded')
    decodedBlock
end
%------------------------------------