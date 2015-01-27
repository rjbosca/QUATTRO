function varargout = show_predhist(obj,varargin)

% Get the x/y data
x = obj.xProc;
y = obj.y(~obj.rmIdx & obj.subset);

% Initialize
predNms = obj.names(obj.covIdx);
nCol    = numel(obj.catNames)+1;
nRow    = size(x,2);
h       = figure;
thresh  = obj.thresholds(:,obj.covIdx);

% Generate the histogram data (the current code assumes standardized variables)
for rowIdx = 1:nRow

    % Initialize the histogram properties
    if obj.standardize
        aMax = 2;
    elseif ~isempty(obj.thresholds)
        aMax = max( abs(thresh(:,rowIdx)) );
    else
        aMax = max(x(:,rowIdx));
    end
    nBin     = 41;
    binE     = linspace(-aMax,aMax,nBin+1);
    binC     = linspace(-aMax,aMax,nBin);
    prcp = zeros(nBin,nCol);

    % Calculate the probability of category x
    for colIdx = 1:nCol-1
    for idx = 1:nBin
        mask      = binE(idx)<x(:,rowIdx) & x(:,rowIdx)<binE(idx+1);
        if ~any(mask)
            continue
        end
        nCat      = sum( strcmpi(obj.catNames{colIdx},y(mask)) );
        prcp(idx,colIdx) = nCat/sum(mask);
    end
    figure(h);
    subplot(nRow,nCol,colIdx+(rowIdx-1)*nCol);
    bar(binC,prcp(:,colIdx));
    xlim([-aMax aMax]); ylim([0 1]);
    xlabel(predNms{rowIdx});
    title(obj.catNames{colIdx});
    end

    % Plot the data
    figure(h);
    subplot(nRow,nCol,rowIdx*nCol);
    bar(binC,prcp,'stacked');
    % title([predNms{yidx} ' (' obj.catNames{xidx} ')']);
    xlim([-aMax aMax]);
    xlabel(predNms{rowIdx});
    legend(obj.catNames{:},'Location','best');

end

% Generate the cross terms
if nRow<=1
    return
end
xIdx     = nchoosek(1:nRow,2);
[nRow,nCol] = subplotDist(size(xIdx,1));
nBin     = floor(nBin/2)+1;
binE     = linspace(-aMax,aMax,nBin+1);
binC     = linspace(-aMax,aMax,nBin);
for cIdx = 1:numel(obj.catNames)
h(1)     = figure;
h(2)     = figure;
for rowIdx = 1:size(xIdx,1)

    % Initialize the proportion array
    prcp = zeros(nBin,nBin);

    % Calculate the probability of category x1 and x2
    for idx1   = 1:nBin
    for idx2   = 1:nBin
        % Determine which values of variable xi and xj are between the mth and
        % nth bin edge
        mask = binE(idx1)<x(:,xIdx(rowIdx,1)) & x(:,xIdx(rowIdx,1))<binE(idx1+1) &...
               binE(idx2)<x(:,xIdx(rowIdx,2)) & x(:,xIdx(rowIdx,2))<binE(idx2+1);
        if ~any(mask)
            continue
        end

        % Calculate the number of values in the mask that are of the current
        % category, and calculate the corresponding probability
        nCat = sum( strcmpi(obj.catNames{cIdx},y(mask)) );
        prcp(idx1,idx2) = nCat/sum(mask);
    end %variable 1 loop
    end %variable 2 loop

    % Plot the 2D histogram data
    figure(h(1));
    subplot(nRow,nCol,rowIdx);
    imagesc(binC,binC,flipud(prcp'),[0 1]);
    colorbar
    xlabel(predNms{xIdx(rowIdx,1)});
    ylabel(predNms{xIdx(rowIdx,2)});
    title(obj.catNames{cIdx});

    % Plot 2D scatter data
    figure(h(2));
    subplot(nRow,nCol,rowIdx);
    catMask = strcmpi(obj.catNames{cIdx},y);
    scatter(x(catMask,xIdx(rowIdx,1)),x(catMask,xIdx(rowIdx,2)),1);
    xlim([-aMax aMax]); ylim([-aMax aMax]);
    xlabel(predNms{xIdx(rowIdx,1)});
    ylabel(predNms{xIdx(rowIdx,2)});
    title(obj.catNames{cIdx});
end
end