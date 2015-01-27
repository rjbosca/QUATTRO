function show_scatter(obj)
%show_scatter  Displays scatter plots of explanatory/response variables

% Evaulate the user-defined function and get the responses
x   = obj.xProc;
y   = obj.yProc;
ord = obj.catNames;
nms = obj.names(obj.covIdx);
nC  = obj.k;

% Determine the size of the subplot layout
n = ceil( sqrt(size(x,2)) );

% Create the figure
hf = figure;

% Loop trough all of the variables
for pIdx = 1:numel(nms)
    subplot(n,n,pIdx);
    scatter(x(:,pIdx),y);
    ylim([1 nC]);
    xlabel(nms{pIdx});
    ylabel('Response');
    set(gca,'YTickLabel',ord,'YTick',1:nC)
end