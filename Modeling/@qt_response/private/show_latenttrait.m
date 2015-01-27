function show_latenttrait(obj)
%show_latenttrait  Displays a plot of the latent trait interpretation

% Validate the input
if isempty(obj.training)
    return
end

% Define the mean
m = 1.3;

% Draw the distribution
x = -5:0.01:5; y = pdf('norm',x,m,1);
figure; plot(x,y,'b');

% Plot the cutoffs
g = obj.training.indVar';
h = line(repmat(g,[2 1]),[zeros(1,length(g));pdf('norm',g,m,1)]);
set(h,'Color','r')
