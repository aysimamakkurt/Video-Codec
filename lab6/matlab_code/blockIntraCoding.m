function [blockBitStream, decodedBlock, QDC] = blockIntraCoding(currentBlock,previousDC)
global params
dctBlock =  dct2( currentBlock) ;  % compute the dct of the current block 
quantizedDctBlock = round( dctBlock ./ params.q_mtx);  % compute the uniform quantization ;
%------------------------------------
if params.verbose==2  % We display this only if verbose is on level 2
    disp('Original block:')
    currentBlock
    disp('DCT')
    dctBlock
    disp('Quantized DCT')
    quantizedDctBlock
end
%------------------------------------
losslessCoderVerboseness = 0; % It is better to set no output, but you can set this to 1 for debug

% Now use the provided "block_entropy_coding" to perform the entropy coding
blockBitStream = block_entropy_coding(quantizedDctBlock,previousDC,losslessCoderVerboseness);
invQuant = params.q_mtx .*quantizedDctBlock; %% rescale the quantized coeff
decodedBlock = idct2(invQuant);  %% invert quantization
QDC = quantizedDctBlock(1,1); %% save the quantized DC coeff

%------------------------------------
if params.verbose==2
    disp('Inv. Quant. ')
    invQuant
    disp('Decoded')
    decodedBlock
end
%------------------------------------