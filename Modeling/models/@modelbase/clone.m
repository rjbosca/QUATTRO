function newObj = clone(oldObj,varargin)
%clone  Clones a modeling object
%
%   NEWOBJ = clone(OLDOBJ) clones the modeling object OLDOBJ, creating a new
%   object of the same class NEWOBJ with identical properties. All non-constant,
%   non-dependent, and non-transient properties of OLDOBJ are copied to NEWOBJ.
%
%   NEWOBJ = clone(OLDOBJ,NEWOBJ) clones all properties of the modeling object
%   OLDOBJ, assigning the value of those properties to matching properites of
%   the modeling object NEWOBJ. OLDOBJ and NEWOBJ need not be the same class
%
%   NEWOBJ = clone(...,'exclude',PROPS) excludes the properties specified by the
%   cell array of strings PROPS from being copied.

    % Initialize the NEWOBJ CCing OLDOBJ
    [exclude,newObj] = parse_inputs(oldObj,varargin{:});

    % Create meta-classes from the old and new modeling objects
    newMetaObj = meta.class.fromName( class(newObj) );
    oldMetaObj = meta.class.fromName( class(oldObj) );

    % Copy the values of the properties from the old object if those properties
    % are also present in the new object
    newProps = {newMetaObj.PropertyList.Name};
    for prop = {oldMetaObj.PropertyList.Name}

        % Property does not exist in the new object - ignore
        propIdx = strcmpi(prop{1},newProps);
        if ~any(propIdx)
            continue
        end

        % Determine if the property is dependent, constant, transient or empty.
        % In any of these case, the copy operation is ignored
        propObj = newMetaObj.PropertyList(propIdx);
        if propObj.Dependent || propObj.Constant || propObj.Transient ||...
                 isempty(oldObj.(prop{1})) || any(strcmpi(propObj.Name,exclude))
            continue
        end

        % Copy the value
        try
            newObj.(prop{1}) = oldObj.(prop{1});
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:class:SetProhibited')
                rethrow(ME);
            end
        end

    end

end %modelbase.clone


%-------------------------------------------------
function varargout = parse_inputs(oldObj,varargin)

    % Validate a few properties of the input
    if (numel(oldObj)~=1)
        error(['QUATTRO:' mfilename ':tooManyModelingObjects'],...
              ['Calling the "%s" method on a stack of modeling objects is ',...
               'not permitted.'],mfilename);
    end

    % Parser setup
    parser = inputParser;

    % Add the options and parse the inputs
    parser.addOptional('newObj',eval( class(oldObj) ),@validate_newObj);
    parser.addParamValue('exclude',{''},...
                                @(x) iscell(x) && all( cellfun(@ischar,x) ));
    parser.parse(varargin{:});

    % Validate that the new and old modeling objects are not the same object
    if (parser.Results.newObj==oldObj)
        error(['QUATTRO:' mfilename ':sameSourceAndTarget'],...
               'The source and target objects must be different');
    end

    % Deal the outputs
    varargout = struct2cell(parser.Results);
    
end %parse_inputs

%---------------------------------
function tf = validate_newObj(obj)

    tf = true; %initialize
    if ~any( strcmpi('modelbase',superclasses(obj)) )
        error(['QUATTRO:' mfilename ':invalidInputObject'],...
               'The target object must be a sub-class of the MODELBASE class.');
    elseif (numel(obj)~=1)
        error(['QUATTRO:' mfilename ':invalidObjectArray'],...
               'The target object must be a scalar object.');
    end

end %validate_newObj