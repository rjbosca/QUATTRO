function varargout = qt_uigetfile(varargin)
%qt_uigetfile  QUATTRO wrapper for uigetfile
%
%   [FILE,OK] = qt_uigetfile(FILTERSPEC,TITLE,DFILE) presents the user with an
%   interactive file dialog box using the file filter specification FILTERSPEC,
%   dialog box TITLE, and default file name DFILE. The full file name, FILE, is
%   returned in addition to a logical value, OK, is true if the user provided a
%   usable file name.
%
%   [...] = qt_uigetfile(...,MULTI) performs the above described operations,
%   where MULTI is a string ('on' or 'off') specifying the ability to select
%   ('on') multiple files. By default, MULTI is off. 
%
%   [...,FILTERINDEX] = qt_uigetfile(...) performs the above described operation
%   in addition to returning the index of the filter specification selected by
%   the user.
%
%   See also uigetfile

    % Parse the inputs to handle the case for multi-select mode
    [varargin{:}] = parse_inputs(varargin{:});

    % Send the inputs through uigetfile
    [fName,fPath,fIdx] = uigetfile(varargin{:});

    % Validate the selected file, dealing an empty string to both if none was
    % selected, concatenating whatever resulted and storing in the output
    if isnumeric(fName) || isnumeric(fPath)
        [fName,fPath] = deal('');
    end
    if ~iscell(fName)
        fName = {fName};
    end
    varargout{1} = cellfun(@(x) fullfile(fPath,x),fName,'UniformOutput',false);
    if (numel(varargout{1})==1)
        varargout{1} = varargout{1}{1};
    end

    % Determine the value of the success output flag
    varargout{2} = (exist(varargout{1},'file')==2);

    % Pass the filter specification index if requested
    if nargout>2
        varargout{3} = fIdx;
    end

end %qt_uigetfile


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Only handle the case in which the user provided the multi-select string,
    % otherwise let uigetfile deal with the other inputs
    varargout = varargin(1:3);
    if (nargin>4)
        [varargout{4:5}] = deal('MultiSelect',varargin{4});
    end

end %parse_inputs