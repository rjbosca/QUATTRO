function im_orientation = get_dicom_orientation(varargin)
%get_dicom_orientation  Get orientation plane of DICOM image.
%
%   O = get_dicom_orientation(HDR) returns the image orientation numeric code
%   using information stored in the DICOM header, HDR.
%
%       Numeric Code    Description
%       ----------------------------
%           1           'sagittal'
%           2           'coronal'
%           3           'axial'
%          inf          'oblique'
%
%   O = get_dicom_orientation(...,matchtype) returns the image orientation
%   by matching the header information with the directional cosines
%   according to matchtype.
%
%       Type String     Description
%       --------------------------------
%       'exact'         Checks for vector equivalence
%
%       'ssd'           Finds the minimum of the sum of squared differences
%
%   O = get_dicom_orientation(...,'','str') returns the string description of
%   the image orientation instead of the numeric code
    

% Parse inputs
[hdr opts] = parse_inputs(varargin{:});

% Get header information
dir_vec = hdr.ImageOrientationPatient;

% Find orientation
d = [dir_vec - [0;1;0;0;0;-1],... %sagittal
     dir_vec - [1;0;0;0;0;-1],... %coronal
     dir_vec - [1;0;0;0;1; 0]];   %axial
d = sum( d.^2 );
[min_d ind] = min(d);

if strcmpi(opts.compare,'ssd') && min_d>cos(pi/4)^2
    ind = inf;
end
if strcmpi(opts.output,'num')
    im_orientation = ind;
else
    switch ind
        case 3
            im_orientation = 'axial'; %RAS
        case 1
            im_orientation = 'sagittal'; %SAR
        case 2
            im_orientation = 'coronal'; %RSA
        otherwise
            im_orientation = 'oblique';
    end
end


%------------------------------------------
function varargout = parse_inputs(varargin)

% Set up parser
parser = inputParser;
parser.addRequired('header',@isstruct);
parser.addOptional('compare','exact',@(x) any(strcmpi(x,{'exact','ssd',''})));
parser.addOptional('output', 'num',  @(x) any(strcmpi(x,{'num','str'})));

% Parse inputs
parser.parse(varargin{:});

% Store output
varargout{1} = parser.Results.header;
varargout{2} = rmfield(parser.Results,'header');