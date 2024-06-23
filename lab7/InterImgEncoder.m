function imgBitStream = InterImgEncoder();
% This function encodes in INTRA the image stored in the global variable img
% It uses the global variable params to configure the encoding
% The decoded image is stored in the global variable decodedFrameBuffer.current
% The function returns the encoded bitstream
global params img decodedFrameBuffer

% Inits
previousDC = 0;
imgBitStream =[];

% We need a variable for the motion vector field
global MVF


% Encoding
img = img - 128;

% Loop on the blocks
for rowIndex = 1:params.blockSize:params.nRow,
    for colIndex = 1:params.blockSize:params.nCol,

        % Access to the current block
        currentBlock = img( rowIndex:rowIndex+params.blockSize-1, ...
            colIndex:colIndex+params.blockSize-1);

        % Perform the INTRA encoding of the current block
        [blockBitStreamIntra, decodedBlockIntra, quantizedDCIntra] = blockIntraCoding(currentBlock,previousDC);
        blockRateIntra = numel(blockBitStreamIntra);
        blockMSEIntra =  mean((currentBlock(:)-decodedBlockIntra(:)).^2);
        codingCostIntra = blockMSEIntra + params.modeSelectionLambda *blockRateIntra;

        % Perform the INTER encoding of the current block
        % We need the coordinates of the block in the following
        params.rowIndex = rowIndex;
        params.colIndex = colIndex;

        [blockBitStreamInter, decodedBlockInter, quantizedDCInter, motionVector] = blockInterCoding(currentBlock,previousDC);
        blockRateInter = numel(blockBitStreamInter);
        blockMSEInter =  mean((currentBlock(:)-decodedBlockInter(:)).^2);
        codingCostInter = blockMSEInter + params.modeSelectionLambda *blockRateInter;

        % Mode decision
        if codingCostIntra < codingCostInter
            % Encode a mode flag
            imgBitStream =[imgBitStream, '0', blockBitStreamIntra];
            % Update the decoded frame buffer for the *current* image
            decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1) = decodedBlockIntra;
     	   %Update the previous DC
           previousDC = quantizedDCIntra;
           % Even if the block is encoded in INTRA mode, we need to update
           % the "decoded" motion vector field, in order to perform the
           % right motion vector prediction. In this case, we set the
           % motion vector for the current block to (0,0)
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 1) = 0;
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 2) = 0;


        else
            % Encode a mode flag
            imgBitStream =[imgBitStream, '1', blockBitStreamInter];
            decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1) = decodedBlockInter;
     	   %Update the previous DC
           previousDC = quantizedDCInter;
           % Let us update the MVF
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 1) = motionVector(1);
           MVF(rowIndex:rowIndex+params.blockSize-1, ...
               colIndex:colIndex+params.blockSize-1, 2) = motionVector(2);


        end

        if params.verbose == 3,
            fprintf('Block %4d,%4d J_intra = %5.2f J_inter = %5.2f\n', params.rowIndex,params.colIndex,...
                codingCostIntra,codingCostInter)
            if codingCostIntra < codingCostInter, fprintf('*****************\n'); end
        end
    end
end
end
