function xi = rigid3(w,x,ttype)
%rigid3  Performs a 3D rigid transformation
%
%   [XI YI ZI] = rigid3(W,X) performs a 3D rigid transformation on the the X, Y,
%   and Z, coordinates specified as an 1-by-3 cell X and transformation vector W
%   returning the transformed coordinates XI, YI, and ZI. Details of the vector
%   w are as follows:
%
%       Postion     Description
%       ---------------------------
%         w(1)      Rotation about x-axis in radians
%
%         w(2)      Rotation about y-axis
%
%         w(3)      Rotation about z-axis
%
%         w(4)      Translation in x direction
%
%         w(5)      Translation in y direction
%
%         w(6)      Translation in z direction
%
%
%   [...] = rigid3(...,TYPE) performs the previously described operations where
%   TYPE specifies the transformation direction and is one of 'inv' (default)
%   or 'fwd'
%
%   See also rigid2

% Validate transformation direction
if nargin==3
    ttype = validatestring(ttype,{'fwd','inv'});
else
    ttype = 'inv';
end

% Get transformation matrix from rotations and translations
if numel(w)==length(w)
    cor = cellfun(@(x) diff(x([1 end])) / 2, x(:)'); %get center of rotation
    h = makehgtform('translate',w(4:6)+cor,...perform x-y-z translations and 
                                           ...move image to center of rotation
                    'xrotate',w(1),...        perform rotation about x-axis
                    'yrotate',w(2),...        perform rotation about y-axis
                    'zrotate',w(3),...        perform rotation about z-axis
                    'translate',-cor);       %move image back to coordinates and
                                             %perform actual translation

end

% Get the transformation structure
if strcmpi(ttype,'inv')
    tform = fliptform( maketform('affine',h') ); %make the transform matrix
else
    tform = maketform('affine',h');
end

% Perform transformation
[xi{1:3}] = tforminv(tform,x{:});