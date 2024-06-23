function img = loadImage(filename, frameNumber)
    % loadImage: Load a specific frame from a .y file (YUV format).
    % filename: The name of the .y file.
    % frameNumber: The frame number to load (1-based index).

    % CIF format dimensions
    width = 352;
    height = 288;
    
    % Calculate the frame size
    frameSize = width * height;
    
    % Open the file
    fileID = fopen(filename, 'r');
    if fileID == -1
        error('Cannot open input video file %s', filename);
    end
    
    % Seek to the frame
    fseek(fileID, (frameNumber - 1) * frameSize, 'bof');
    
    % Read the frame data
    Y = fread(fileID, frameSize, 'uint8');
    
    % Close the file
    fclose(fileID);
    
    % Reshape the Y data into the correct dimensions
    img = reshape(Y, width, height)';
end
