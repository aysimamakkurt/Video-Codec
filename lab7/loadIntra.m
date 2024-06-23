function loadedImage  = loadIntra(gopIndex)
%Loads the first image of a gop
%The parameters of the raw video file must be in a global variable

global params

fid = fopen(params.inputVideoFile, 'r');
bytes_per_frame = params.nRow*params.nCol; 
byte_shift = bytes_per_frame * params.firstFrameGOP; 
if fseek(fid,byte_shift,'bof')<0
    error('Impossible to get frame %d in file %s',params.firstFrameGOP,params.inputVideoFile);
elseif params.verbose
    fprintf('Loading Intra image from GOP %.3d (image no %.3d in the file)\n', ...
        gopIndex, params.firstFrameGOP);
end

%% Reading the image from the file
loadedImage = transpose(fread(fid, [352 288 ], 'uint8')); %% <<- replace 0 0 with the correct values                  

end