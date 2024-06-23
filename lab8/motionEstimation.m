function [bestMatch, mv] = motionEstimation(currentBlock)
% This function looks for the best match to currentBlock in the image
% stored in the global variable decodedFrameBuffer
% It returns the best matching block and the motion vector
% The cost function is a regularized SAD
% The regularization parameter is the coding cost of the motion vector

global params decodedFrameBuffer MVF 

%% Initializations
% look up the block position and size 
colIndex = params.colIndex;
rowIndex = params.rowIndex;
blockSizeRows = params.blockSize;
blockSizeCols = params.blockSize; 

% look up the Lagrangian parameter for ME
lambda = params.ME.lambda; 

% look up the image size
ROWS = params.nRow;
COLS = params.nCol;

% look up the search radius
radius = params.ME.radius; 

% Initialization of the best displacement
bestDeltaCol=0; bestDeltaRow=0;
% Best cost initialized at the highest possible value
Jmin=blockSizeRows*blockSizeCols*256*256;
% Init the matching block
bestMatch = zeros(blockSizeRows,blockSizeCols);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Motion vector prediction %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For the current position, we find the predictor of the motion
% vector. This predictor is used to encode the MV

% 1. There is no predictor for the first block: in this case
% we use (0,0)
if colIndex==1 && rowIndex ==1
    predictor = [0; 0];
    %Since there is no predictor in this case, we set
    %the penalization to zero
    weight = 0;
    % 2. For the first column (left), we take as predictor
    % the top neighbor. In this and all the other cases, a
    % predictor exists, so the penalization weight is lambda
elseif colIndex==1
    predictor = squeeze(MVF(rowIndex-blockSizeRows, colIndex,:));
    % The squeeze function makes sure that what we extract from the
    % 3D matrix MVF is, indeed, a column vector
    weight = lambda ;
    % 3. For the first row, we use the left neighbor
elseif rowIndex==1
    predictor = squeeze(MVF(rowIndex, colIndex-blockSizeCols,:));
    weight = lambda ;
else
    % 4. In all the other cases we take the MEDIAN of 3
    % neighbors: 1. the left neighbor, 2. the top neighbor 
    V1 = squeeze(MVF(rowIndex, colIndex-blockSizeCols, :));
    V2 = squeeze(MVF(rowIndex-blockSizeRows, colIndex, :));
    % The third neighbor is the top-right neighbor if it is
    % available (ie., except for the last column)
    if colIndex<(COLS-blockSizeCols)
        V3 = squeeze(MVF(rowIndex-blockSizeRows, colIndex+blockSizeCols, :));
    else
        % For the last column we take the top-left neighbor
        V3 = squeeze(MVF(rowIndex-blockSizeRows, colIndex-blockSizeCols, :));
    end
    % 5. Computing the median: the three neighbors are put as
    % column of a matrix, and then the median is computed row-wise
    predictor = median([V1,V2,V3],2);
    weight=lambda;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Motion Estimation main loop %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ME loop on candidate motion vectors v = (deltaCol,deltaRow)
% It is a full search in [-radius:radius]^2
for deltaCol= -radius:radius %% To be completed
    for deltaRow= -radius:radius %% To be completed
        % Check: the candidate vector must point inside the image
        if ((rowIndex+deltaRow>0)&&(rowIndex+deltaRow+blockSizeRows-1<=ROWS)&& ...
                (colIndex+deltaCol>0)&&(colIndex+deltaCol+blockSizeCols-1<=COLS))
            % Now we are sure that the motion vector points inside
            % the image and we can recover the reference block R
            % Notice that R is obtained by adding the suitable
            % diplacement to the row and col indexes
            R=decodedFrameBuffer.reference(rowIndex+deltaRow :rowIndex+deltaRow +blockSizeRows-1, ...
                colIndex+deltaCol:colIndex+deltaCol+blockSizeCols-1);
            differences =  abs(currentBlock - R) ;
            SAD= sum(differences(:)); 

            %% Regularization

            % 2. The regularization cost is the coding cost of the
            % prediction error

            predErr = [deltaRow; deltaCol]-predictor;
            cw = [encodeSEG(predErr(1)), encodeSEG(predErr(2))];

            bits = numel(cw);

            J= SAD + weight*bits;

            % If current candidate is better than the previous
            % best candidate, then update the best candidate
            if (J<Jmin)
                Jmin=J;
                bestDeltaCol=deltaCol;
                bestDeltaRow=deltaRow;
                bestMatch = R; 
            end

        end %
    end %
end % loop on candidate vectors
% Store the best MV 
mv(1) = bestDeltaRow;
mv(2) = bestDeltaCol; 