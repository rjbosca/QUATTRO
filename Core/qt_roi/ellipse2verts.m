function verts = ellipse2verts(pos)
%ellipse2verts  Creates x-y pairs from an imellipse position array
%
%   V = ellipse2verts(P) returns the x-y coordinates of an imellipse
%   position matrix P

% Get the major/minor axes of the ellipse
a = pos(3)/2;
b = pos(4)/2;

% Ellipse polar parameterization
r = @(theta) a*b./sqrt((b*cos(theta)).^2 + (a*sin(theta)).^2);
x = @(theta) r(theta).*cos(theta) + (pos(1)+a);
y = @(theta) r(theta).*sin(theta) + (pos(2)+b);

% Approximate the circumference and attempt to use that information to determine
% the number of points necessary
h    = (a-b)^2/(a+b)^2;
circ = pi*(a+b)*(1+3*h/(10+sqrt(4-3*h)));

% Calculate the verticies
th = linspace(0,2*pi,256)';
verts = [x(th) y(th)];