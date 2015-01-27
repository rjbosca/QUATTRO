function addmap(obj,varargin)
%addmap  Adds a parameter map to a qt_exam object
%
%   addmap(OBJ,MAP) appeds the qt_image object specified by MAP to the
%   qt_exam object, OBJ, storing the data under the name given by the "tag"
%   property of MAP. MAP is added at the location specified by the "sliceIdx"
%   property of the qt_exam object.
%
%       **IMPORTANT: The qt_image property "tag" must be a string other than
%                    'image' to ensure proper handling of the map object.
%
%   addmap(...,'slice',VAL) specifies the slice location to be used in lieu of
%   the qt_exam object properties with the corresponding index value, VAL.

    % Parse the inputs
    [mapObj,mapTag,slIdx] = parse_inputs(varargin{:});

    %TODO: Catch an array of maps

    % Initialize some default map object properties
    mapObj.transparency = 0.5;
    mapObj.color        = 'hsv';

    % The qt_image property "tag" is used to distinguish maps from basic images.
    % The latter uses the value 'image', which is protected to ensure proper
    % visualization of maps/images in QUATTRO
    if strcmpi(mapObj.tag,'image')
        warning(['qt_exam:' mfilename ':useOfProtectedTag'],...
                ['Attempted to add an image as a map. Maps must have a\n',...
                 'property value for "tag" other than''image''.\n']);
        return
    end

    % Grab the stack of maps stored currently in the qt_exam object. Because the
    % "maps" property is a structure with indeterminate fields (at least until
    % some maps are computed) the structure must be initialized if it's empty
    mapStack = obj.maps;
    if isempty(mapStack)
        mapStack = repmat( struct(mapTag,[]), [slIdx 1] );
    end

    % Since the user can specify the map name and slice location, the data
    % location must be checked for duplicates to ensure that no data are
    % overwritten.
    try %get the maps of interest
        mapObjs = mapStack(slIdx);

        % Create a unique name for the new map if one with the same name already
        % exists
        cnt = 1;
        while cnt>0
            %TODO: finish this function
            if ~isfield(mapObjs,mapTag) || isempty(mapObjs.(mapTag))
                break
            end

            % The name already exists, so append a "NEW*" to the end of the tag
            % or rewrite a new "*"
            mapTag = strrep(mapTag,['NEW' num2str(cnt)],'');
            mapTag = [mapTag 'NEW' num2str(cnt)];
            cnt    = cnt + 1;
        end
    catch ME
        if ~strcmpi( ME.identifier, 'MATLAB:badsubscript' )
            rethrow(ME)
        end
    end

    % Update the stack of map objects
    mapStack(slIdx).(mapTag) = mapObj;

    % Store the new stack in the exams object
    obj.maps = mapStack;


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Validate the number of inputs
        narginchk(2,4);

        % Set up the parser
        parser = inputParser;
        parser.addRequired('maps',@(x) all( strcmpi(class(x),'qt_image') ));
        parser.addRequired('name',@ischar)
        parser.addParamValue('slice',obj.sliceIdx,...
                                               @(x) x>0 && x<=size(obj.imgs,1));

        % Parse the inputs and deal the outputs
        parser.parse(varargin{:});
        varargout = struct2cell(parser.Results);

    end %parse_inputs

end %addmap