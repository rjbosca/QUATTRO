function fList = gendirfiles(varargin)
%gendirfiles  Returns all files in a directory
%
%   FILES = gendirfiles(DIR) returns a cell array containing the full file names
%   (FILES) of all files in the directory specified by DIR
%
%   FILES = gendirfiles(DIR,EXT) returns the full file names of all files in
%   the directory DIR with extension EXT.

    % Parse the inputs
    [fExt,fPath] = parse_inputs(varargin{:});

    % List the directory contents and remove directories from the list
    fList = dir(fPath);
    fList = fList(~[fList.isdir]);

    % Grab only the file names and, if a specific extension has been specified,
    % look for only files with that extension
    fList = {fList.name};
    fExts = cell( size(fList) );
    for fIdx = 1:length(fList)
        [~,~,fExts{fIdx}] = fileparts(fList{fIdx});
    end
    if ~isempty(fExt)

        % The extension should contain the '.' for easier string searches
        if isempty( strfind(fExt,'.') )
            fExt = ['.' fExt];
        end

        % Keep only those files with the specified extension
        fList = fList( strcmpi(fExt,fExts) );
    end

    % Concatenate the file names and the search directory
    fList = cellfun(@(x) fullfile(fPath,x),fList, 'UniformOutput',false);

end %gendirfiles


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Parser setup
    parser = inputParser;
    parser.addRequired('path',@(x) exist(x,'dir')==7);
    parser.addOptional('extension','',@ischar);

    % Parse the inputs and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell( parser.Results );

end %parse_inputs