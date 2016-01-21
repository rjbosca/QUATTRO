function varargout = show(obj,varargin)
%show  Displays the QT_IMAGE object
%
%   show(OBJ) displays the image data from the QT_IMAGE object (or array of
%   objects), OBJ. When an axis or axes exist from a previous call to the "show"
%   method, that view's data are refreshed. Otherwise, a light-weight viewer is
%   created and used to display the image data.
%
%       Graphical tools:
%       ----------------
%       Adjusting WW/WL - holding the middle mouse button (or shift+LMB) and
%                         dragging the cursor allows the user to dynamically
%                         adjust the window width and window level.
%
%       Context menus   - right-clicking on the image will raise the qt_image
%                         context menus that provide a number of tools for
%                         adjusting the image display
%
%
%   show(OBJ,HAX) displays data in the manner defined previously on the axis
%   specified by the handle (or array of handles) HAX, where OBJ is a single
%   image object. This syntax replaces all current image data on the specified
%   axis/axes, if any exists.
%
%   show(OBJ,OLDOBJ) replaces all image views of a currently displayed qt_image
%   object OLDOBJ with data from the QT_IMAGE object OBJ. All display properties
%   (e.g., RGB, etc.) are copied from OLDOBJ. Both QT_IMAGE objects must be
%   scalars. This syntax is used by QUATTRO to update the axis/axes when, for
%   example, the slice location is changed.
%
%   show(...,'PARAM1',VAL1,...) performs the specified operations as described
%   previously in addition to applying the parameter/value pairs specified by
%   PARAM1/VAL1, etc. Valid parameters options are:
%
%       Show options:
%       -------------
%       'isDispText'    - a logical scalar that, when FALSE, disables on-image
%                         text. By default, QT_IMAGE objects display any
%                         on-image text
%
%       'isRgb'         - a logical scalar that, when TRUE, displays the image
%                         as an RGB image, converting the indexed voxel values
%                         based on the QT_IMAGE properties
%
%
%   H = show(...) also returns the handle(s) of the newly updated image HGOs

    % Parse inputs and pass to the imgview object
    [obj,isDispText,isRgb,hAxNew,oldObj] = parse_inputs(obj,varargin{:});

    % There are two cases to handle in the following: (1) the user is requesting
    % that current view be updated by providing a QT_IMAGE object as input to be
    % replaced or (2) a new display is being requested.
    if ~isempty(oldObj)

        % Create the new view objects and store the axis handle(s)
        oldViewObjs = oldObj.imgViewObj;
        nViewObjs   = numel(oldViewObjs);
        newViewObjs = imgview.empty(nViewObjs,0);
        hAxNew      = {oldObj.imgViewObj.hAxes};

        % For each imgview object, copy the display properties from the previous
        % object and deconstruct the image
        for viewIdx = 1:nViewObjs

            % Create the actual IMGVIEW object
            newViewObjs(viewIdx)            = imgview(obj);

            % Copy the properties
            newViewObjs(viewIdx).hImg       = oldViewObjs(viewIdx).hImg;
            newViewObjs(viewIdx).isRgb      = oldViewObjs(viewIdx).isRgb;
            newViewObjs(viewIdx).isDispText = oldViewObjs(viewIdx).isDispText;

            % Destroy the current axis contents to ensure that new images are
            % displayled correctly or deconstruct the image to "refresh" the
            % image view. When the any of the image dimensions are not equal,
            % reset the axis to ensure that an image replacement operation will
            % occur in the post-set listeners.
            if any(oldObj.dimSize(1:2)~=obj.dimSize(1:2))
                cla(oldViewObjs.hAxes,'reset')
            end
            notify(oldViewObjs(viewIdx),'deconstructView');

        end

    elseif isempty(oldObj) && isempty(hAxNew) %data refresh

        % For consistency, grab the imgview object(s) and associated axis(axes)
        % from the current object. The following code will then store the same
        % data in the respective fields, but fire the view change when the
        % axis/axes are updated
        newViewObjs = obj.imgViewObj;
        hAxNew      = {obj.imgViewObj.hAxes};

    else %axis handle(s) - replace plot

        % **Special case** If the QT_IMAGE object calling the "show" method
        % already has a view object on one of the axes, dconstruct the previous
        % object
        if ~isempty(obj.imgViewObj)
            isOldView = cellfun(@(x) any(x==[obj.imgViewObj.hAxes]),hAxNew);
            if any(isOldView)
                arrayfun(@(x) notify(x,'deconstructView'),...
                                                     obj.imgViewObj(isOldView));
            end
        end

        % Create new imgview objects for the new axis or axes on which to
        % display images
        nAxNew                = numel(hAxNew);
        newViewObjs(1:nAxNew) = imgview(obj);

        % Set the RGB and text display properties
        %FIXME: this should be updated (see optional input syntax) to support a
        %param/value FOR loop. Would this work with the other syntaxes described
        %in the help section?
        [newViewObjs(:).isRgb]      = deal(isRgb);
        [newViewObjs(:).isDispText] = deal(isDispText);

    end

    % Store the new imgview objects in the qt_image object for later access. The
    % objects must be associated with the image object at this point because the
    % "set" method for "imgViewObj" attaches the listeners that allow view
    % objects to actually update views
    obj.imgViewObj = newViewObjs;

    % Finally, update the axis handle(s) to fire the display events
    [newViewObjs(:).hAxes] = deal(hAxNew{:});

    % Show ROIs if any
    %TODO: handle case for array of objects
    %TODO: change this to "isempty" when when the qt_roi method "isempty" is no
    %longer overloaded
    if (numel(obj.roiObj)>0)
        obj.roiObj.show([hAxNew{:}]);
    end

    % Handle method output
    if nargout
        [varargout{:}] = deal([]);
        varargout{1}   = [newViewObjs(:).hImg];
    end

end %qt_image.show


%----------------------------------------------------
function [obj,varargout] = parse_inputs(obj,varargin)

    % Validate the number of inputs
    narginchk(1,6);

    % There are two cases to consider: 1) the user called "show" on a stack of
    % image objects and 2) the user called "show" on a single element of an
    % image object array. Cases (1) and (2) are equivalent for a scalar image
    % array
    %
    % If a display figure does not already exist, it is easy: show the imgviewer
    % and be down with it. However, what to do if the viewer (or QUATTRO) exists
    % under these circumstances.
    validViewInd = arrayfun(@(x) any( ~isempty(x.imgViewObj) ),obj);
    if (nargin==1) && ~any(validViewInd(:))
        varargin{1} = obj.viewer;
        obj         = obj(1);
    elseif (nargin==2) && (numel(obj)>1)
        error(['qt_image:' mfilename ':tooManyImgObjs'],...
              ['Show may be called on only 1 qt_image object at a time. ',...
               'Try obj(1).show, where obj is the current QT_IMAGE object.']);
    end

    % Set up parser
    parser = inputParser;
    parser.addOptional('showObj',[],...
                         @(x) all(ishandle(x)) || strcmpi(class(x),'qt_image'));
    parser.addParamValue('isRGB',false,...
                             @(x) validateattributes(x,{'logical'},{'scalar'}));
    parser.addParamValue('isDispText',true,...
                             @(x) validateattributes(x,{'logical'},{'scalar'}));

    % Parse and grab the restuls and initialize the optional qt_image object
    % input field to satisfy the output syntax
    parser.parse(varargin{:});
    results        = parser.Results;
    results.oldObj = qt_image.empty(1,0);

    % Since the user can specify either (1) an axis/axes handle or (2) a
    % qt_image object, determine which is the case and perform some validation
    if strcmpi( class(results.showObj), 'qt_image' )
        results.oldObj  = results.showObj;
        results.showObj = [];
        if (numel(results.oldObj)>1)
            error(['qt_image:' mfilename ':tooManyOldImgObjs'],...
                  ['Refresh syntax of "show" may be called with only one ',...
                   'qt_image object to be refreshed. Type ''help qt_image.show ',...
                   'for more information.']);
        end
    else %axis/axes handle(s) were provided
        % For ease in dealing the axis handle(s) to individual image view
        % objects, a cell array is preferred
        results.showObj = num2cell(results.showObj);
    end

    % Deal the outputs
    varargout = struct2cell(results);

end %parse_inputs