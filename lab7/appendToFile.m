function appendToFile(bits)
global params
fwrite(params.fid,(uint8(bits)-48),'ubit1');