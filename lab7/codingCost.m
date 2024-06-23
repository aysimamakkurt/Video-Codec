function [bits, stream] = codingCost(mvf,bsize,mode,verbose)
% mode = 0 --> entropy
% mode = 1 --> EG of components
% mode = 2 --> predictors = median of T, L and TR; EG of prediction error
if nargin<4
    verbose=0;
end
if nargin<3
    mode=0;
end
stream = '';
switch mode
    case 0
        bits = entropyCost(mvf,bsize);
    case {1,2}
        [R, C, ~ ] = size(mvf);

        if verbose
            fprintf('Position(H,V)|   MV  (H,V)| Predictor | Pred. err.|       Codewords\n');
        end

        for indexRow = 1:bsize:R
            for indexCol = 1:bsize:C
                if mode==1 || (indexRow==1 && indexCol==1)
                    predictor = [0;0];
                elseif indexRow==1
                    predictor = squeeze(mvf(indexRow, indexCol-bsize,:));
                elseif indexCol==1
                    predictor = squeeze(mvf(indexRow-bsize, indexCol,:));
                else
                    V1 = squeeze(mvf(indexRow, indexCol-bsize, :));
                    V2 = squeeze(mvf(indexRow-bsize, indexCol, :));
                    if indexCol<(C-bsize)
                        V3 = squeeze(mvf(indexRow-bsize, indexCol+bsize, :));
                    else
                        V3 = squeeze(mvf(indexRow-bsize, indexCol-bsize, :));
                    end
                    predictor = median([V1,V2,V3],2);
                end
                predErr = squeeze(mvf(indexRow, indexCol, :))-predictor;
                
                stream =  [stream, expGolombSigned(predErr(2)), expGolombSigned(predErr(1))];
                if verbose
                    fprintf('  (%3d,%3d)  |  (%3d,%3d) | (%3d,%3d) | (%3d,%3d) |  %10s %10s\n',...
                        indexCol,indexRow,mvf(indexRow, indexCol, 2),...
                        mvf(indexRow, indexCol, 1), predictor(2), predictor(1),...
                        predErr(2), predErr(1), ...
                        expGolombSigned(predErr(2)), expGolombSigned(predErr(1)));
                end
            end
        end
        bits = numel(stream);
    otherwise
        warning('MVF coding mode is not recognized. Using entropy instead.')
        bits = entropyCost(mvf,bsize);
end