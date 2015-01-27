function show_density(obj)
%show_density  Displays plots of the probability densities

%TODO: perform computations to marginalize the densities
if sum(obj.covIdx)>1
    return
end

% Evaulate the user-defined function and get the responses
x   = obj.xProc;
f   = obj.invLinkFcn;
nms = obj.names(obj.covIdx);
nC  = obj.k;
B   = obj.training.B;
g   = obj.training.indVar;

% Determine the size of the subplot layout
n = ceil( sqrt(size(x,2)) );

% Create the figure
hf = figure; axis; hold on;

% Loop trough all of the variables
dx  = linspace(min(x),max(x),1000)';
x   = [ones(size(dx)) dx];
pid = zeros(1000,nC);
c   = {'r','g','b','c','m','y','k','w'};
for pIdx = 1:nC
    if pIdx==1
        pid(:,pIdx) = f(-x*B);
    elseif pIdx==nC
        pid(:,pIdx) = 1-f(g(pIdx-1)-x*B);
    else
        pid(:,pIdx) = f(g(pIdx)-x*B)-f(g(pIdx-1)-x*B);
    end
    plot(x(:,2),pid(:,pIdx),c{pIdx})
end
legend(obj.catNames,'Location','best');
xlabel(obj.names{obj.covIdx});
ylabel('Probability');