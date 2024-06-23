function [imgBitStream, map]= InterImgEncoder()
% [imgBitStream, map]= InterImgEncoder()
% This function encodes in INTER the image stored in the global variable img
% It uses the global variable params to configure the encoding
% The decoded image is stored in the global variable decodedFrameBuffer.current
% The function returns the encoded bitstream
global params img decodedFrameBuffer MVF

% General initializations
previousDC = 128;
imgBitStream =[];
% Init the cost maps
mapRows = params.nRow / params.blockSize;
mapCols = params.nCol / params.blockSize;
map.Jintra = zeros(mapRows,mapCols);
map.Jinter = map.Jintra; 

% Image pre-processing: not performed in INTER coding, but remember that we
% initialize the DC predictor as 128, which is basically equivalent to the
% pre-processing

% Loop on the blocks
for rowIndex = 1:params.blockSize:params.nRow,
    for colIndex = 1:params.blockSize:params.nCol,

        % Access to the current block
        currentBlock = img(rowIndex:rowIndex+params.blockSize-1, colIndex:colIndex+params.blockSize-1);
                                    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perform the INTRA encoding of the current block  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [blockBitStreamIntra, decodedBlockIntra, quantizedDCIntra] = blockIntraCoding(currentBlock,previousDC);

        % Compute the cost: distortion + lambda * rate
        blockRateIntra = length(blockBitStreamIntra) * 8; % The number of bits used to encode the block
        blockMSEIntra = mean((currentBlock(:) - decodedBlockIntra(:)).^2); % The MSE of the decoded block with respect to the current block
        codingCostIntra = blockMSEIntra + params.modeSelectionLambda * blockRateIntra; % J=D+lambda*R
        % store the coding cost in the output variable map
        % note that in map we have one value per block, so we have to
        % rescale the position onto which we save the value of the cost
        mapRowPos = (rowIndex+params.blockSize-1)/params.blockSize; 
        mapColPos = (colIndex+params.blockSize-1)/params.blockSize;
        map.Jintra(mapRowPos,mapColPos) = codingCostIntra;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perform the INTER encoding of the current block  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % We need the coordinates of the block inside the blockInterCoding
        % function in order to access to the neighboring blocks and compute
        % the motion vector predictor using the associated vectors
        params.rowIndex = rowIndex;
        params.colIndex = colIndex;

        % The ~ in the output paramenters means that we do not need the
        % third output parameter (the quantized DC). The second input
        % parameter is zero because we do not it neither
        [blockBitStreamInter, decodedBlockInter, ~, motionVector] = blockInterCoding(currentBlock,0);
        % Computing and storing the coding cost
        blockRateInter = length(blockBitStreamInter) * 8; % The number of bits used to encode the block
        blockMSEInter = mean((currentBlock(:) - decodedBlockInter(:)).^2); % The MSE of the decoded block with respect to the current block
        codingCostInter = blockMSEInter + params.modeSelectionLambda * blockRateInter; % J=D+lambda*R
        map.Jinter(mapRowPos, mapColPos) = codingCostInter;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Rate-distortion omptimized mode selection (RDO-MS) %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if  codingCostIntra < codingCostInter

            % If the condition is met, the INTRA mode is selected

            % Encode a flag for signaling the selected mode and add the encoded block
            imgBitStream =[imgBitStream, '0', blockBitStreamIntra];

            % Update the decoded frame buffer for the *current* image
            decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1) = decodedBlockIntra;
       	   %Update the previous DC
           previousDC = quantizedDCIntra;

           % Even if here the block is encoded in INTRA mode, we need to update
           % the "decoded" motion vector field, in order to perform the
           % right motion vector prediction. In this case, we set the
           % motion vector for the current block to (0,0)
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 1) = 0;
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 2) = 0;

        else
            % The INTER mode has been selected

            % Encode a flag for signaling the selected mode and add the encoded block
            imgBitStream =[imgBitStream, '1', blockBitStreamInter];
            decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1) = decodedBlockInter;
            % Don't need to update the previous DC

            % Let us update the MVF
            MVF(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1, 1) = motionVector(1);
            MVF(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1, 2) = motionVector(2);
        end % Mode selection
    end % Loop on Cols
end % Loop on Rows
end

