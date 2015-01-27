function I = mharead(varargin)
%mharead  Read MHA image
%
%   I = mharead(FILENAME) attempts to read the image data from an MHA image file
%   specified by the string FILENAME. The output will be an ND array.
%
%   I = mharead(INFO) reads the image data from an MHA header structure INFO.
%   The INFO structure is generated from the mhainfo function.
%
%   See also mhainfo mhawrite

% Determine if input was struct or file name
if ~isstruct(varargin{1})
    hdr = mhainfo(varargin{1});
else
    hdr = varargin{1};
end

% Open file for reading
fid = fopen(hdr.Filename,'r');
if fid==-1
    error([mfilename ':invalidFile'],'Unable to read specified file.');
end

% Seek to the image
fseek(fid,hdr.BeginningOfImage,-1);

% Read the image
perc = lower( strrep(hdr.ElementType,'MET_','') );
I = fread(fid,inf,perc);

% Resize the image
I = reshape(I,hdr.DimSize);

% Close the image
fclose(fid);