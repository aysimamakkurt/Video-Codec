function [blockBitStream, decodedBlock, QDC] = blockIntraCoding(currentBlock,previousDC)
global params
dctBlock = dct2(currentBlock);
quantizedDctBlock = round(dctBlock./params.q_mtx_Intra);
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
losslessCoderVerboseness = 0;
blockBitStream = block_entropy_coding(quantizedDctBlock,previousDC,losslessCoderVerboseness);
invQuant = params.q_mtx_Intra .* quantizedDctBlock;
decodedBlock = idct2(invQuant);
QDC = quantizedDctBlock(1,1);

%------------------------------------
if params.verbose==2
    disp('Inv. Quant. ')
    invQuant
    disp('Decoded')
    decodedBlock
end
%------------------------------------