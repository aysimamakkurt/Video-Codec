function symb = decodeSEGstream(stream)
% Decode  signed Exp Golomb stream

symb = decodeUEGstream(stream);
% inverse mapping
for ind = 1:numel(symb),
    S = symb(ind);
    if mod(S,2),
        symb(ind) =  (S+1)/2;
    else
        symb(ind) = -S/2;
    end
end

%symb=int32(symb);