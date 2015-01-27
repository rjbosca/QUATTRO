function show_boxplot(obj,varargin)

% Get the x/y data
x = obj.xProc;
y = obj.y(~obj.rmIdx & obj.subset);

% Initialize
predNms = obj.names(obj.covIdx);
nPlots  = numel(predNms);
h       = figure;

% Determine the number of rows/columns for the subplot
[nRow,nCol] = subplotDist(nPlots);

% Loop through the number of plots
for idx = 1:nPlots

    % Generate a sub-plot for each parameter
    figure(h);
    subplot(nRow,nCol,idx);
    boxplot(x(:,idx),y);
    if obj.standardize
        ylabel(['Standardized ' predNms{idx}]);
    else
        ylabel(predNms{idx});
    end
end