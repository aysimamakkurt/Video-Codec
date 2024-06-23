function [GOP_RATE, GOP_PSNR] = gopEncoder(gopIndex)
% This function encodes a full GOP
% It updates the compressed file
% It computes the per-frame rate and PSNR
global params img decodedFrameBuffer

% Init 
GOP_PSNR = zeros(params.GOPSize,1);
GOP_RATE = zeros(params.GOPSize,1);

% First image in the GOP: INTRA
img = loadIntra(gopIndex); % This function loads a single Y image from the input file
imgBitStream = IntraImgEncoder(); % This function encodes a single image in Intra mode
% write the encoded intra image to file
appendToFile(imgBitStream);
% Update rate and psnr
GOP_PSNR(1) = ypsnr(img, decodedFrameBuffer.current); % ypsnr is a function that shall compute the PSNR between Y images
GOP_RATE(1) = numel(imgBitStream) / (params.nRow * params.nCol) ; % rate in bpp
% the currently decoded image becomes the reference for the next frame
decodedFrameBuffer.reference = decodedFrameBuffer.current;

numberOfInter = params.GOPSize-1;
% Other images: INTER
for interIndex = 1:numberOfInter
   img = loadInter(gopIndex,interIndex);
   imgBitStream = InterImgEncoder();

    % write the encoded inter image to file
    appendToFile(imgBitStream);
    % Update rate and psnr
    GOP_PSNR(interIndex+1) = ypsnr(img, decodeImageBuffer.current); 
    GOP_RATE(interIndex+1) = numel(imgBitStream) / (params.nRow * params.nCol) ;
    % the currently decoded image becomes the reference for the next frame
    decodedFrameBuffer.reference = decodedFrameBuffer.current;

end