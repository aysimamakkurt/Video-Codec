function loadedImage  = loadIntra(gopIndex)
%Loads the first image of a gop
%The parameters of the raw video file must be in the global variable params

global params

fid = fopen(params.inputVideoFile, 'r'); % <<-- replace with the file name from params
bytes_per_frame = params.nRow * params.nCol;% <<-- replace with the number of bytes per frame
                  % use params.nRow and params.nCol

byte_shift = bytes_per_frame * params.firstFrameGOP; % Compute the byte shift
if fseek(fid,byte_shift,'bof')<0 % fseek moves the file pointer to the desired position, if possible
    error('Impossible to get frame %d in file %s',params.firstFrameGOP,params.inputVideoFile);
elseif params.verbose
    fprintf('Loading Intra image from GOP %.3d (image no %.3d in the file)\n', ...
        gopIndex, params.firstFrameGOP);
end

%% Reading the image from the file
loadedImage = transpose(fread(fid, [params.nCol, params.nRow], 'uint8')); %% <<- replace 0 0 with the correct values                  

end