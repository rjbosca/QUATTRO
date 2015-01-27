function varargout = sort(obj,varargin)
%sort  Sorts images of a qt_image object
%
%   OBJ = sort(OBJ,FLD) performs a sorting operation according to the values in
%   the field FLD along the first non-singleton dimesion of the qt_image object
%   array OBJ.
%
%   OBJ = sort(...,DIM) sorts along the dimension specified by DIM.
%
%   OBJ = sort(...,MODE) performs the sort operation using the sorting mode.
%   MODE is either 'ascend' (default) or 'descend' and sorts in ascending or
%   descending order, respectively.
%
%   [OBJ,VALS] = sort(...) performs the sort operation, returning the qt_image
%   object array in addition to the unique values of the sorting field.

    [dim,fld,sortMode] = parse_inputs(varargin{:});

    % Determine the object array size
    m = size(obj);

    % Get the value of the fields
    vals = cellfun(@(x) x.(fld), {obj.metaData}, 'UniformOutput',false);
    vals = reshape(vals,m); %force same data shape

    % Determine the data class
    isNum  = cellfun(@isnumeric,vals);
    isChar = cellfun(@ischar,vals);
    if any( ~isNum & ~isChar )
        error(['qt_image:' mfilename ':classChk'],...
                                             'Unsupported data type detected.');
    end
    isNum  = all(isNum(:));
    isChar = all(isChar(:)); %stack the logicals for later
    if ~isNum && ~isChar
        error(['qt_image:' mfilename ':classChk'],'%s: %s\n%s\n',...
                                              'Cannot stack using field',fld,...
                              'Incommensurate data types detected in metaData');
    end

    % Perform sorting
    if isNum
        vals = cell2mat(vals);
    elseif isChar
        %TODO: I need to add support for sorting by character meta data fields
    end
    [vals,idx] = sort(vals,dim,sortMode);

    % Prepare index for dimensions > 1
    nd = sum(m~=1);
    if (nd>1)

        % Permute so that the first dimensions is the sorted dimension
        permVec = [dim 1:dim-1 dim+1:nd];
        idx      = permute(idx,permVec);

        % Loop through the sorted index vectors, multiplying by the nth column
        n = prod(m)/m(dim); %get the number of vectors
        for vecIdx = 1:n
            shift = m(dim)*(vecIdx-1);
            idx( (1:m(dim))+shift ) = idx( (1:m(dim))+shift )+shift;
        end

        % Undo the permutation
        idx = permute(idx,permVec);

    end

    % Apply sorting to object
    varargout{1} = obj(idx);

    % Return unique values if requested
    if nargout>1
        varargout{2} = unique(vals);
    end


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Validate string inputs
        if nargin==3
            varargin{3} = validatestring(varargin{3},{'ascend','descend'});
        end

        % Construct parser
        parser = inputParser;
        parser.addRequired('Field',@validateFld)
        parser.addOptional('Dimension',find(size(obj)~=1,1,'first'),@validateDim)
        parser.addOptional('Mode','ascend',@ischar);

        % Parse and deal
        parser.parse(varargin{:});
        varargout = struct2cell(parser.Results);

    end %parse_inputs

    function tf = validateDim(dim)
        tf = (dim<=ndims(obj));
        if ~tf
            error(['qt_image:' mfilename ':dimChk'],...
                      'DIM should be <= to the # of dimensions of the object.');
        end
    end %validateDim

    function tf = validateFld(fld)
        tf = all( ~cellfun(@isempty,{obj.metaData}) ); %check for missing meta data
        if ~tf && any( ~obj.read ) %read the meta data for all other images
            error(['qt_image:' mfilename ':metaDataChk'],...
                                   'Unable to detect meta data in all images.');
        end
        tf = all( cellfun(@isstruct,{obj.metaData}) ); %validate meta data
        if ~tf
            error(['qt_image:' mfilename ':metaDataChk'],...
                                     'Invalid meta data in one of the objects');
        end
        tf = all( cellfun(@(x) isfield(x,fld),{obj.metaData}) );
        if ~tf
            error(['qt_image:' mfilename ':fldChk'],...
                       ['At least one image is missing meta data field: ' fld]);
        end
    end %validateFld

end %qt_image.sort