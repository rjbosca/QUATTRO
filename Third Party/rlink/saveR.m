function saveR(fileName, varargin)
%SAVER  Save workspace variables to an R data file
%
%   SAVER(FILENAME) saves all workspace variables to the "R-file" named 
%   FILENAME.
%
%   SAVER(FILENAME, VAR1, VAR2,...) saves the variables specified by the
%   strings VAR1, VAR2, etc. to the file FILENAME.
%
%   Notes: saveR can handle scalars, vectors, matrices, and cell arrays of
%   strings. NaN's are saved as NA. Since R cannot handle structures, they
%   will not be saved and a warning will be given.
%
%   Version 1.0, August 3, 2010
%   
%   Author: Jeroen Janssens (http://www.jeroenjanssens.com)

% Parse the inputs
vars = varargin;
if(nargin < 1)
    error('rlink:saveR:invalidInputs','Requires at least one input arguments.');
elseif(nargin < 2)
    vars = evalin('caller', 'who');
end

% Ensure the file name has the correct extension
[fPath,fName,fExt] = fileparts(fileName);
if strcmpi(fExt,'R') && ~isempty(fExt)
    warning('rlink:saveR:invalidFileExt',...
                                  'Invalid file extension replaced with ".R".');
end
fileName = fullfile(fPath,[fName '.R']);

% Open the file
fid = fopen(fileName,'wt');

% Write the variables
for varIdx = 1:length(vars)

    % Determine the variable name
    varName = vars{varIdx};
    varNameStr = ['"' varName '" <-'];
    if ~evalin('caller',['exist(''' varName ''',''var'');'])
        warning('rlink:saveR:invalidVar',...
                'Invalid variable "%s" will be excluded from file "%s".',...
                varName,[fName '.R']);
        continue
    end

    % Get the variable value
    varValue = evalin('caller', vars{varIdx});

    % Determine the variable size, and the corresponding size of the value when
    % converted to a character array (used for writing the data)
    varSize = size(varValue);
    varSizeStr = mat2str(varSize(:));
    varSizeStr = strrep(varSizeStr(2:end-1),';',', ');

    % Generate the data to write
    varClass = class(varValue);
    switch varClass
        case 'cell'
            varValueStr = sprintf('"%s", ',varValue{:});
            varValueStr = ['structure(c(' varValueStr(1:end-2),...
                                                '), .Dim = c(' varSizeStr '))'];

        case {'char','double','int8','unit8','int16','uint16',...
              'int32','uint32','single','logical'}
            varValueStr = mat2str(varValue(:));
            varValueStr = strrep(varValueStr,'NaN','NA');
            varValueStr = ['structure(c(' strrep(varValueStr(2:end-1),';',', '),...
                           '), .Dim = c(' varSizeStr '))'];

        otherwise
            warning('rlink:saveR:invalidDataType',...
                   ['R cannot handle variables of type %s.\n',...
                    'Variable "%s" will be excluded from file "%s".'],...
                    varClass,varName,[fName '.R']);
            continue
    end

    % Write the data
    fprintf(fid, '%s\n%s\n', varNameStr, varValueStr);
    
end

fclose(fid);