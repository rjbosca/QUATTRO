function val = processThresh(obj,varargin)
%processThresh  Applies qt_response thresholds
%
%   val = processThresh applies all thresholds in the "thresholds" property to
%   the covariate data (i.e., "xProc"), returning a logical index of values to
%   *remove* from the array
%
%   val = processThresh(X) performs the same operations as above using the input
%   data X in lieu of the data generated in the "xProc" property of the
%   qt_response object.

% Check for input
if nargin==1
    x = obj.model(obj.x);
%     x = x(:,obj.covIdx);
else
    x = varargin{1};
end

% Initialize the output and check for thresholds
val = false(size(x,1),1);
if isempty(obj.thresholds)
    return
end

% Apply the thresholds
% b   = obj.thresholds(:,obj.covIdx);
b = obj.thresholds;
for idx = 1:obj.np
    % NaNs or below lower or above upper bound
    val = val | (x(:,idx)<b(1,idx) | x(:,idx)>b(2,idx));
end