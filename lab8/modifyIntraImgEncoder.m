function [imgBitStream, map] = modifyIntraImgEncoder()
    % [imgBitStream, map]= IntraImgEncoder()
    % This function encodes in INTRA the image stored in the global variable img
    % It uses the global variable params to configure the encoding
    % The decoded image is stored in the global variable decodedFrameBuffer.current
    % The function returns the encoded bitstream and the coding cost map

    global params img decodedFrameBuffer

    % General initializations
    previousDC = 128;
    imgBitStream = [];
    % Init the cost maps
    mapRows = params.nRow / params.blockSize;
    mapCols = params.nCol / params.blockSize;
    map.Jintra = zeros(mapRows, mapCols);

    % Loop on the blocks
    for rowIndex = 1:params.blockSize:params.nRow
        for colIndex = 1:params.blockSize:params.nCol

            % Access to the current block
            currentBlock = img(rowIndex:rowIndex+params.blockSize-1, colIndex:colIndex+params.blockSize-1);

            % Perform the INTRA encoding of the current block
            [blockBitStreamIntra, decodedBlockIntra, quantizedDCIntra] = blockIntraCoding(currentBlock, previousDC);

            % Compute the cost: distortion + lambda * rate
            blockRateIntra = length(blockBitStreamIntra) * 8; % The number of bits used to encode the block
            blockMSEIntra = mean((currentBlock(:) - decodedBlockIntra(:)).^2); % The MSE of the decoded block with respect to the current block
            codingCostIntra = blockMSEIntra + params.modeSelectionLambda * blockRateIntra; % J=D+lambda*R

            % Store the coding cost in the output variable map
            mapRowPos = (rowIndex+params.blockSize-1) / params.blockSize;
            mapColPos = (colIndex+params.blockSize-1) / params.blockSize;
            map.Jintra(mapRowPos, mapColPos) = codingCostIntra;

            % Append the encoded block bitstream
            imgBitStream = [imgBitStream, blockBitStreamIntra];

            % Update the decoded frame buffer
            decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
                colIndex:colIndex+params.blockSize-1) = decodedBlockIntra;

            % Update the previous DC
            previousDC = quantizedDCIntra;
        end
    end
end
