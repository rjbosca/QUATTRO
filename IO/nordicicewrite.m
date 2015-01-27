function nordicicewrite(varargin)
%nordicicewrite  Writes a Nordic ICE ROI file
%
%   nordicicewrite(FILENAME,S) writes the ROI structure S contain the fields
%   'coordinates', 'size', and 'type' to the file specificied by the file
%   specified by the full file name FILENAME.
%
%   nordicicewrite(FILENAME,COOR,SIZE,TYPE) write the ROI specified by the array
%   of coordinates COOR, roi SIZE, and ROI type TYPE to the file specified by
%   the full file name FILENAME.
%
%   ROI Component       Description
%   -------------------------------
%   Coordinates         An array containing the x-y coordinates. Note that in
%                       MATLAB x-y coordinates are reversed (i.e. x=y and y=x).
%                       This utility automatically adjusts the coordinates and
%                       corrects for the 1-indexed arrays.
%
%      Type             A string specifying one of the following ROI types:
%                       'ellipse', 'polygon', 'rectangle', 'freehand'. Automatic
%                       conversions are made for 'imellipse', 'impoly',
%                       'imrect', and 'imspline', respectively, for
%                       compatability with built-in MATLAB ROIs.
%
%      Size             One of 'large', 'medium', or 'small'
%
%
%   See also nordiciceread


[fName,r,rSize,rType] = parse_inputs(varargin{:});

% Open file for writing
fid = fopen(fName,'w');
if fid==-1
    fprintf('Unable to write to file - %s',fName);
    return
end

% Format ROI information
 %rounds the coordinates and 0-indexes 
switch rType
    case 'ellipse' 
        r(1:2)=r(1:2)-1; r = round(r); r = r([3 4 1 2]);
    case 'polygon' 
        r = round(r-1); r = permute(r,[2 1]);
    case 'rectangle'
        r(1:2)=r(1:2)-1; r = round(r); r = r([3 4 1 2]);
    case 'freehand' 
        r = round(r-1); r = permute(unique(r,'rows'),[2 1]);
end

% Generate output
fprintf(fid,'%s\n%s\n',upper(rSize),rType);
fprintf(fid,'%u;%u\n',r);

% Close the file
fclose(fid);


%------------------------------------------
function varargout = parse_inputs(varargin)

% Prepare inputs for the parser
if nargin==2 && isstruct(varargin{2}) %roi structure syntax
    flds   = {'coordinates','size','type'};
    if any( ~isfield(varargin{2},flds) )
        error([mfilename ':inputChk'],['Missing fields in input structure.',...
                                       'Fields are case sensitive.']);
    end
    for idx = length(flds):-1:1 %order is important here
        varargin{idx+1} = varargin{2}.(flds{idx});
    end
elseif nargin~=4
    error([mfilename ':inputChk'],'Invalid input syntax. Type "help %s"\n',...
                                                                     mfilename);
end

% Perform conversions of ROI type strings
varargin{4} = strrep(lower(varargin{4}),'im','');
varargin{4} = strrep(varargin{4},'poly','polygon');
varargin{4} = strrep(varargin{4},'rect','rectangle');
varargin{4} = strrep(varargin{4},'spline','freehand');

% Prepare cells of valid strings
valid_sizes = {'small','medium','large'};
valid_types = {'ellipse','polygon','rectangle','freehand'};

% Parser setup
parser = inputParser;
parser.addRequired('File',@ischar);
parser.addRequired('Position',@isnumeric);
parser.addRequired('Size',@(x) any( strcmpi(x,valid_sizes) ));
parser.addRequired('Type',@(x) any( strcmpi(x,valid_types) ));

% Parse the inputs and deal
parser.parse(varargin{:});
varargout = struct2cell( parser.Results );