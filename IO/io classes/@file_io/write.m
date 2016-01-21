function write(obj,str,varargin)
%write  Writes data to the file_io object's file
%
%   write(OBJ,FORMAT,A,...) applies the FORMAT to all elements of A and writes
%   to the file specified by the file_io object's, OBJ, properties. FORMAT and A
%   can be row or column cell arrays of the same size, in which case the
%   contents of corresponding cells will be written to the file sequentially.
%
%   For more information about the FORMAT and A inputs or file write operations,
%   see the FPRINTF documentation.

    % Validate the number of inputs
    narginchk(2,inf);

    % Use an empty string for printing if none are specified otherwise
    if (nargin<3)
        varargin{1} = '';
    end

    % Before attempting any write operations, ensure that the permissions are
    % appropriate
    if ~any( strcmpi(obj.filePermission,{'w','w+','W'}) )
        error(['file_io:' mfilename ':invalidFilePermission'],...
              'The ''filePermission'' property must be one of ''w'', ''w+'' or ''W''.');
    end

    % Open the file if necessary
    if isempty(obj.fileId)
        obj.open;
    end

    % Write the data to the file
    if ~iscell(str) && ~iscell(varargin{1})
        fprintf(obj.fileId,str,varargin{:});
    else
        cellfun(@(x,y) obj.write(x,y{:}),str,varargin{1});
    end

end %file_io.write