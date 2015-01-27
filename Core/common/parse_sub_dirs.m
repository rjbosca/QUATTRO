function dList = parse_sub_dirs(varargin)
%parse_sub_dirs  Returns all sub-directories within in a directory
%
%   DIRS = parse_sub_dirs(DIR) returns a cell array containing the full name of
%   all sub-directories (DIRS) contained in the directory DIR. The directories
%   '.' and '..' are ignored

    % Parse the inputs
    [fPath] = parse_inputs(varargin{:});

    % List the directory contents and remove non-directories
    dList = dir(fPath);
    dList = dList([dList.isdir]);

    % Convert the directory names to a cell array of strings and remove the
    % system directories '.' and '..'
    dList = {dList.name};
    dList = dList( ~strcmpi('.',dList) & ~strcmpi('..',dList) );

    % Concatenate the paths
    dList = cellfun(@(x) fullfile(fPath,x),dList, 'UniformOutput',false);

end %parse_sub_dirs


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Parser setup
    parser = inputParser;
    parser.addRequired('path',@(x) exist(x,'dir')==7);

    % Parse the inputs and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell( parser.Results );

end %parse_inputs