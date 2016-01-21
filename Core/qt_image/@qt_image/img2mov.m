function M = img2mov(obj,varargin)
%img2mov  Converts a movie from a QT_IMAGE object
%
%   M = img2mov(OBJ) creates an array structure (with fields "cdata" and
%   "colormap") that can be used to write or display a movie. 
%
%   See also VideoWriter and movie

    % Parse the inputs
    parse_inputs(varargin{:});



end %qt_image.img2mov



%------------------------------------------
function varargout = parse_inputs(varargin)
end