function [V, volsize, voxdims, header] = ReadAnalyze(filename)

% If image filename is not specified, prompt user to select one 
if nargin < 1
  [filename,pathname] = uigetfile('*.img;*.hdr','Load Analyze file');
  if filename == 0
    error(' No file selected.');
  end
  filename = [pathname filename(1:end-4)] ;
end

% Read Analyze Header (% mc is usually 'ieee-le')
[header, mc] = ReadAnalyzeHeader(filename);
volsize = double(header.hdr.dime.dim(2:4));
voxdims = double(header.hdr.dime.pixdim(2:4));

% Find image type (precision)
switch (header.hdr.dime.bitpix)
    case 16
        precision = 'int16';
    case 8
        precision = 'int8';
    otherwise
        error('Unsupport Analyze image type!');
end

% Setup memory for image efficently
V = zeros(volsize(1),volsize(2),volsize(3), precision);

% Load image volume
if isempty( strfind(filename,'.img') )
    fid = fopen([filename '.img'],'r', mc);
else
    fid = fopen(filename,'r',mc);
end

for iz = volsize(3):-1:1
    Temp = fliplr(int16(fread(fid,[volsize(1), volsize(2)],precision)));
    V(:,:,iz)= flipud(rot90(Temp));
end

fclose(fid);