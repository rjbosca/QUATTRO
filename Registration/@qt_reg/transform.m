function im = transform(obj,varargin)
%transform  Transforms the moving image of a qt_reg object
%
%   I = transform transforms the moving image (i.e. im2) of the qt_reg object
%   using the transformation property, wc. If no transformation is present, an
%   identity transformation is used. Note that this will force the moving image
%   grid to conform to the target image grid.
%
%   I = transform(W) performs the user specified transformation on the moving
%   image of the qt_reg object. W can be a vector of transformation parameters
%   or an N+1-by-N+1 transformation matrix where N is the dimensionality of the
%   image properties. Applying multiple transformations can be accomplished by
%   passing an N-by-1 cell array W.
%
%   I = transform(W,'fwd') performs a forwrad user specified transformation on
%   the moving image of the qt_reg object, where W is as described previously.
%   Note that image registration tasks actually compute and apply the inverse of
%   the  transformation W, aligning the moving image to the target image. To
%   compute a forward transformation for im2, use the 'fwd' option, which
%   inverts W, resulting in a foward transformation
%
%
%       Example
%       -------
%
%       % Load MRI brain data
%       load('mri');
%
%       % Create a qt_reg object
%       x = qt_reg( squeeze(D(:,:,1,13)), squeeze(D(:,:,1,13)) );
%
%       % Perform a forward translation/rotation to make the moving image
%       x.im2 = x.transform([5*pi/180 -7 8],'fwd');
%
%       % Register the images and show the history
%       x.register; x.show_history;
%
%   See also qt_reg

% Parse inputs
[w,tformDir] = parse_inputs(varargin{:});

% Return original image if no transform exist
if isempty(w)
    w = {obj.identity};
elseif ~iscell(w)
    w = {w(:)'}; %enforce row vector
end

% Cache the moving image
im = obj.imMoving;

% Get the transformation and interpolation functions
fTrafo  = obj.transformationFcn;
fInterp = @(x,xi) interpn(x{:},im,xi{:},obj.interpolation,-1);

% Grab the current moving image grid and determine if an expansions/contraction
% is necessary
xi   = obj.x2;
ext1 = obj.pixdim1.*obj.mTarget;
ext2 = obj.pixdim2.*obj.mMoving;
for extIdx = 1:length(ext1)
    if ext1(extIdx)~=ext2(extIdx)
        xi{extIdx} = obj.x1{extIdx};
    end
end

% Apply transformations
for wcIdx = 1:length(w)
    xi = fTrafo(w{wcIdx},xi,tformDir);
end

% Perform the image transformation
im = fInterp(obj.x2,xi);


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Validate the string
        if nargin>1
            varargin{2} = validatestring(varargin{2},{'inv','fwd'});
        end

        % Parse inputs
        parser = inputParser;
        parser.addOptional('transform',obj.wc,@(x) numel(x)>1 || iscell(x));
        parser.addOptional('type','inv',@ischar);
        parser.parse(varargin{:});

        % Deal outputs
        varargout = struct2cell(parser.Results);

    end %parse_inputs

end %transform