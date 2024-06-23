function bits = block_entropy_coding(blk,dc,verbose)
% JPEG-like entropy coding of a single block
%

%Default: verbose=0
if nargin==2,
    verbose=0;
end
%% Zig-zag scan
coeffs = zigzagscan(blk);

%% DC Coding
dcPredErr = (coeffs(1)-dc); % prediction
cat = ceil(log2(abs(dcPredErr)+1));
bits = catValCod(cat,dcPredErr);
if verbose,
    fprintf('DC coding\nDC_P\tCat\tBits\n')
    fprintf('%3d\t%7d\t%s\n',dcPredErr,cat,bits);

    %% AC Coding
    fprintf('AC coding\n#AC\tRun\tCat\tValue\tBits\n')
end

nzp = find(coeffs);
runs = diff(nzp)-1;
ACvalues = (coeffs(nzp(2:end)));
acCat = ceil(log2(abs(ACvalues)+1));
for k = 1:numel(ACvalues),
    RC = [runs(k), acCat(k)];
    codeword = AChuffTables(runs(k), acCat(k));
    
    if ACvalues(k) >0 
        valCod =  dec2bin(ACvalues(k),acCat(k));
    else 
        valCod =  97-(dec2bin(-ACvalues(k),acCat(k)));
    end
    if verbose
        fprintf('%3d\t%3d\t%3d\t%3d\t\t%s %s\n',k,RC,ACvalues(k),codeword, valCod );
    end
    bits = [bits codeword valCod];
end
bits = [bits '1010'];
if verbose, 
    fprintf('EOB                                     1010\n')
end

function y=clip(x)
y=(abs(x)<1024).*x + sign(x).*(abs(x)>=1024)*1023;
end
end
