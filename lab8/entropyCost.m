function bits = entropyCost(mvf,bsize)
%ENTROPYCOST estimate the coding cost of a MV using the entropy
%   bits = entropyCost(mvf,bsize)
%   bsize is the input blocksize of the dense mvf
%   the output variable is the number of bit needed to code the MVF
%

if numel(bsize)==1
    BS = [bsize, bsize];
else
    BS = bsize;
end
X = mvf(1:BS(1):end,1:BS(2):end,1);
X=X(:);
Y = mvf(1:BS(1):end,1:BS(2):end,2);
Y=Y(:);

bits = ceil((entr(X)+entr(Y))*numel(X));



function h = entr(X)
occ = hist(X,min(X):max(X));
n=occ(find(occ));
p = n'/sum(n);
h = -p'*log2(p);
end
end



