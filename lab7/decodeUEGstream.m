function symb = decodeUEGstream(stream)
%

nBits=numel(stream);
symb = [];
nSymb = 0;
n=1; 
while n<=nBits, % Symbol index    
    % Scan bits of the next codeword
    cw = stream(n);
    if isequal(cw,'1')
        decoded=0;
        n=n+1; 
    else
        leadingBits=0;
        while isequal(stream(n), '0'),
            n=n+1;
            leadingBits=leadingBits+1;
        end
        decoded = bin2dec(stream(n:n+leadingBits))-1;
        n= n+leadingBits+1;
    end
    nSymb=nSymb+1;
    symb(nSymb)=decoded;
end