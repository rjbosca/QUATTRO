function pos = calcEllipsePos(xlim,ylim)

% Specify default size
width = 250;
heigth = 250;

% Calculate (x,y)
pos = [xlim(2)*.25 ylim(2)*.25 width heigth];