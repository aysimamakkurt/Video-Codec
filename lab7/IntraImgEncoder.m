function imgBitStream = IntraImgEncoder()
% This function encodes the image stored in the global variable img
% It uses the global variable params to configure the encoding
% The decoded image is stored in the global variable decodedFrameBuffer.current
% The function returns the encoded bitstream 

global params img decodedFrameBuffer

% Init
imgBitStream =[];

% JPEG processing
% First, remove 128
img = img - 128;

% Set the value for the previous DC coefficient
previousDC = 0;

for rowIndex = 1:params.blockSize:params.nRow,
    for colIndex = 1:params.blockSize:params.nCol,
        % Access to the current block
        currentBlock = img( rowIndex:rowIndex+params.blockSize-1, ...
            colIndex:colIndex+params.blockSize-1); 
        % Perform the encoding of the current block
        [blockBitStream, decodedBlock, quantizedDC] = blockIntraCoding(currentBlock,previousDC);
        % Update the decoded frame buffer for the *current* image
        decodedFrameBuffer.current(rowIndex:rowIndex+params.blockSize-1, ...
            colIndex:colIndex+params.blockSize-1) = decodedBlock;
        % Update the bitstream
        imgBitStream =[imgBitStream, blockBitStream];
        % Update the previous DC value
        previousDC = quantizedDC ; 
    end
end


