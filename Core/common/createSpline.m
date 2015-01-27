function SplineOut = createSpline( pts, num_pts, CurveShape )
% CREATESPLINE Create smooth spline from x-y coordinates.
%   SplineOut = CreateSpine(P, BOUNDARY, N, METHOD) returns the coordinates
%   of a smooth spline containing N points from the interpolation of the
%   initial coordinates P.
%
%   BOUNDARY can be a string describing the splines boundary:
%
%       'open'      - an open curve (i.e. line with endpoints)
%
%       ('closed')  - curve that is closed (i.e. has boundary)
%
%   CURVESHAPE specifies the spline interpolation method:
%
%       ('cubic')   - piecewise cubic polynomial
%
%       'hermite'   - shape preserving cubic spline
%
%   Example:
%       x = [269 218 152 86 50 48 74 120 199 318 269];
%       y = [80 82 107 165 243 317 394 447 488 92 80];
%       S = CreateSpline([x;y],100,'hermite');
%       figure, imshow('moon.tif');
%       hold on, plot(S(:,1),S(:,2),'r',x,y,'oy');

% Initialize output
SplineOut = deal([]);

% A quick error check
if isempty(pts)
    return
end
if ~isequal( size( pts, 1 ), 2 ) && ~isequal( size( pts, 2 ), 2 )
    error('Too few or improperly formatted coordinates');
end
if ~exist('CurveShape','var')
    CurveShape = 'cubic';
elseif ~strcmpi(CurveShape,'hermite') && ~strcmpi(CurveShape,'cubic');
    CurveShape = 'cubic';
end

% Ensures that the pts array is oriented correctly
if (size( pts, 1) > size( pts, 2 ))
    pts = pts';
end

% Creates the data point space needed by SPLINE
X = linspace(min(pts(1,:)),max(pts(1,:)),length(pts));

% Defines new interpolation space
xx = linspace(min(pts(1,:)),max(pts(1,:)),num_pts);

% Determines which spline to use
if strcmpi(CurveShape, 'Hermite')
    % Creates cubic hermite spline.
    SplineOut = pchip(X,pts,xx)';
else
    % Creates cubic spline.
    SplineOut = spline(X,pts,xx)';
end