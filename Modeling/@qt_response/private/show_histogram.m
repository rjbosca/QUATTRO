function show_histogram(obj)
%show_histogram  Disp

% Get the x/y data
x = obj.xProc;
y = obj.y(~obj.rmIdx & obj.subset);

% Initialize
predNms     = obj.names(obj.covIdx);
nPlots      = numel(obj.catNames);
[nRow,nCol] = subplotDist(nPlots+1);

% Loop through each covariate to generate n+1 plots
for vIdx = 1:size(x,2)
    % Generate the new figure for the ith covariate
    h  = figure;
    if ~isempty(obj.thresholds) && ~obj.standardize
        xl = obj.thresholds(:,vIdx)';
    elseif obj.standardize
        xl = [-2 2];
    else
        xl = [min(x(:,vIdx)) max(x(:,vIdx))];
    end

    % Determine the histogram settings
    xvals  = x(:,vIdx);
    xMask  = (xvals>=xl(1) & xvals<=xl(2));
%     optN   = sshist(xvals(xMask));
    optN   = 41;
    [~,xC] = hist(xvals(xMask),optN);

    % Initialize the storage array for the "stacked" data
    xS = zeros(numel(xC),size(x,2));

    % Loop through each category
    yMax = 0;
    for spIdx = 1:nPlots
        catMask = strcmpi(obj.catNames{spIdx},y) & xMask;
        figure(h);
        subplot(nRow,nCol,spIdx);
        xS(:,spIdx) = hist(xvals(catMask),xC);
        hBar(spIdx) = bar(xC,xS(:,spIdx));
        xlim(xl);
        title([predNms{vIdx} '-' obj.catNames{spIdx}]);

        % Determine the y limits
        yTest = get(gca,'YLim');
        if yTest(2)>yMax
            yMax = yTest(2);
        end

    end

    % Set the y limits
    arrayfun(@(x) set(get(x,'Parent'),'YLim',[0 yMax]),hBar);

    % Plot the "stacked" data
    subplot(nRow,nCol,nPlots+1);
    hBar = bar(xC,xS,'stacked');
    xlim(xl)
    title([predNms{vIdx} '-All Categories']);
    legend(obj.catNames,'location','best');
    colormap('hsv')
%     colors = hsv(length(hBar));
%     for barIdx = 1:length(hBar)
%         nColors = numel(get(get(hBar(barIdx),'Children'),'FaceVertexCData'));
%         set(get(hBar(barIdx),'Children'),'FaceVertexCData',...
%                                           repmat(colors(barIdx,:),[nColors 1]));
%     end

end %covariate loop