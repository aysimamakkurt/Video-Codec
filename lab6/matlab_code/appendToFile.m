function appendToFile(data)
global params
fid = params.fid % take the fid from the params
bits = uint8(data) - 48 % the data must be converted in uint8 with values 0 or 1
           % hint: cast into uint8, and then subtract 48
format = 'ubit1'; % We tell matlab to write one unsigned bit per element of the vector           
fwrite(fid,bits ,'ubit1');

