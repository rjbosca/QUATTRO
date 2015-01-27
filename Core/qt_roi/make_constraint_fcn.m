function fcn = make_constraint_fcn(hAxes,obj,objType)
%make_constraint_fcn  Produce constraint function for QUATTRO
%
%   make_constraint_fcn(H,OBJ,TYPE) creates and adds a constraint function to
%   the ROI object of TYPE specified by OBJ based on the limits of the axis
%   specified by the handle H. H can also specify a two element cell array, each
%   element containing a two element array defining the minimum and maximum ROI
%   extent on the x and y axis, respectively.
%
%   FCN = make_constraint_fcn(...) performs the operation as defined above,
%   returning the constraint function handle, FCN
%
%   FCN = make_constraint_fcn(H,[],TYPE) creates and returns the constraint
%   function as described previously.

% Determine the object type
if ~exist('objType','var') && ~isempty(obj)
    objType = class(obj);
elseif ~exist('objType','var')
    error(['QUATTRO:' mfilename ':undefRoiType'],...
                      'An ROI object or ROI type must be specified as inputs.');
end
objType = strrep(objType,'imspline','imfreehand');

% Determine the limits
lims = hAxes;
if ishandle(hAxes)
    lims = get(hAxes,{'XLim','YLim'});
end

% Creates contraint function
fcn = makeConstrainToRectFcn(objType,lims{:});
if (nargout>0) || isempty(obj)
    return
end

% Set constraint function
setPositionConstraintFcn(obj,fcn);