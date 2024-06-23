function [bitstream, map] = modifyInterImgEncoder()
    global params img decodedFrameBuffer MVF

    % Initialize cost maps
    interCost = zeros(params.nRow / params.blockSize, params.nCol / params.blockSize);
    intraCost = zeros(params.nRow / params.blockSize, params.nCol / params.blockSize);
    
    % Initialize mode decision maps
    map.Jinter = zeros(params.nRow / params.blockSize, params.nCol / params.blockSize);
    map.Jintra = zeros(params.nRow / params.blockSize, params.nCol / params.blockSize);

    % Motion estimation and compensation
    for row = 1:params.blockSize:params.nRow-params.blockSize+1
        for col = 1:params.blockSize:params.nCol-params.blockSize+1
            % Define block indices
            blockRow = (row-1) / params.blockSize + 1;
            blockCol = (col-1) / params.blockSize + 1;

            % Extract the current block from the current frame
            currentBlock = img(row:row+params.blockSize-1, col:col+params.blockSize-1);

            % Motion estimation to find the best matching block in the reference frame
            [mv, compensatedBlock] = motionEstimation(decodedFrameBuffer.reference, currentBlock, row, col, params.ME.radius);

            % Calculate Inter cost
            interCost(blockRow, blockCol) = calculateCost(currentBlock, compensatedBlock) + params.ME.lambda * norm(mv);

            % Calculate Intra cost using Intra prediction
            predictedBlock = intraPrediction(decodedFrameBuffer.reference, row, col);
            intraCost(blockRow, blockCol) = calculateCost(currentBlock, predictedBlock);

            % Mode decision: choose the mode with the lower cost
            if interCost(blockRow, blockCol) < intraCost(blockRow, blockCol)
                map.Jinter(blockRow, blockCol) = 1; % Inter mode
                MVF(row:row+params.blockSize-1, col:col+params.blockSize-1, :) = mv; % Store motion vectors
            else
                map.Jintra(blockRow, blockCol) = 1; % Intra mode
            end
        end
    end

    % Calculate bitstream (existing code)
    bitstream = calculateBitstream();
end

function [mv, compensatedBlock] = motionEstimation(reference, currentBlock, row, col, radius)
    % Dummy implementation for illustration purposes
    mv = [0, 0]; % No motion
    compensatedBlock = reference(row:row+size(currentBlock, 1)-1, col:col+size(currentBlock, 2)-1);
end

function cost = calculateCost(currentBlock, predictedBlock)
    cost = sum((currentBlock(:) - predictedBlock(:)).^2); % Sum of squared differences
end

function predictedBlock = intraPrediction(reference, row, col)
    % Dummy implementation for illustration purposes
    predictedBlock = reference(row:row+7, col:col+7); % Just copy the block from the reference
end

function bitstream = calculateBitstream()
    % Dummy implementation for illustration purposes
    bitstream = randi([0, 1], 1, 100); % Random bitstream
end
