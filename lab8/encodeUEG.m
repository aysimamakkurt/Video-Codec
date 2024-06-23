function bits= encodeUEG(N)
%Exp Golomb code for non-negative numbers

if N
    trailBits = dec2bin(N+1,floor(log2(N+1)));
    headBits = dec2bin(0,numel(trailBits)-1);

    bits = [headBits trailBits];
else
    bits = '1';
end
