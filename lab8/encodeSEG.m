function bits= encodeSEG(N)
%Exp Golomb code for signed numbers

if N>0
    bits = encodeUEG(2*N-1);
else
    bits = encodeUEG(-2*N);
end
