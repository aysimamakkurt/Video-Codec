function img = loadInter(gopIndex,interIndex)
% Load inter frame
global params

frameIndex = params.GOPSize*(gopIndex-1) + 1 + interIndex; 

fid = fopen(params.inputVideoFile, 'r');
bytes_per_frame = params.nRow*params.nCol; 
byte_shift = bytes_per_frame * frameIndex; 
if fseek(fid,byte_shift,'bof')<0
    error('Impossible to get frame %d in file %s',frameIndex,params.inputVideoFile);
elseif params.verbose
    fprintf('Loading Inter image %3d from GOP %.3d (image no %.3d in the file)\n', ...
        interIndex, gopIndex, frameIndex);
end

%% Reading the image from the file
img = transpose(fread(fid, [params.nCol params.nRow ], 'uint8'));           

end