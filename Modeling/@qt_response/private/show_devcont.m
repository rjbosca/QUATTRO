function varargout = show_devcont(obj,varargin)
%show_devcont  Displays deviance contributions

% Get the x/y data
x = obj.xProc;
y = obj.y(~obj.rmIdx & obj.subset);

% Initialize
nPlots      = size(x,2);
varName     = obj.names(obj.covIdx);
[nRow,nCol] = subplotDist(nPlots);

% Loop through all covariates, showing the deviance contribution
h = figure;
for idx = 1:nPlots

    figure(h);
    subplot(nRow,nCol,idx);
    plot(x(:,idx),obj.training.devRes,'*');
    xlabel(varName{idx}); ylabel('Deviance Contribution');

end

% Determine if the deviances and y data are the same size
if numel(y)==numel(obj.training.devRes)
    h(2) = figure;
    boxplot(obj.training.devRes,y);
    xlabel('Category'); ylabel('Deviance Contribution');
end

% Output
if nargout
    varargout = {h};
end