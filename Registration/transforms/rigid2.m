function xi = rigid2(w,x,ttype)
%rigid2  Performs a 2D rigid transformation
%
%   [XI YI] = rigid2(W,X) performs a 2D rigid transformation on the the X and Y
%   coordinates specified as an 1-by-2 cell X and transformation vector W
%   returning the transformed coordinates XI and YI. Details of the vector W are
%   as follows:
%
%       Position    Description
%       ----------------------
%         w(1)      Angle of rotation specified in radians
%
%         w(2)      Translation in the x direction
%
%         w(3)      Translation in the y direction
%
%
%   [...] = rigid2(...,TYPE) performs the previously described operations where
%   TYPE specifies the transformation direction and is one of 'inv' (default)
%   or 'fwd'.
%
%   See also rigid3, qt_reg

% Validate transformation direction
if nargin==3
    ttype = validatestring(ttype,{'fwd','inv'});
else
    ttype = 'inv';
end

x = x(:)'; %enforce row vector

% Get transformation matrix from rotations and translations
isW = (numel(w)==length(w));
if  isW
    % Get the center of image rotation
    centerOfRot = cellfun(@(x) diff(x([1 end])) / 2, x);

    % Perform x-y translations before performing the rotations about the z-axis
    h           = makehgtform('translate',[w(2:3)+centerOfRot 0],...
                              'zrotate',  w(1),...
                              'translate',[-centerOfRot 0]); 

    % Since this is a 2-D rigid transformation, remove the z component of the
    % transformation matrix
    h(3,:) = []; h(:,3) = [];
end

% Get the transform structure
if strcmpi(ttype,'inv')
    tform = fliptform( maketform('affine',h') );
else
    tform = maketform('affine',h');
end

% Perform transformation
[xi{1:2}] = tforminv(tform,x{:});