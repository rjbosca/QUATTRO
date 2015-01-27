function varargout = show(obj,varargin)
%show  Displays the qt_image object
%
%   show(OBJ) displays the image data from the qt_image object (or array of
%   objects), OBJ. When an axis or axes exist from a previous call to "show",
%   the view's data are refreshed. Otherwise, the qt_image viewer is created and
%   used to display the image data.
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
%   show(...,RGB) displays the qt_image object as described previously first
%   converting indexed image values to true color (i.e. RGB values) when the
%   flag RGB is true.
%
%   show(OBJ,OLDOBJ) replaces all image views of a currently displayed qt_image
%   object OLDOBJ with data from the qt_image object OBJ. All display properties
%   (e.g., RGB, etc.) are copied from OLDOBJ. Both qt_image objects must be
%   scalars. This syntax is used by QUATTRO to update the axis/axes when, for
%   example, the slice location is changed.
%
%   H = show(...) also returns the handle(s) of the newly updated image HGOs

    % Parse inputs and pass to the imgview object
    [obj,hAxNew,isRgb,oldObj] = parse_inputs(obj,varargin{:});

    % There are two cases to handle in the following: (1) the user is requesting
    % that current view be updated by specifying the qt_image object to be
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
            % Create the actual imgview object
            newViewObjs(viewIdx)            = imgview(obj);

            % Copy the properties
            newViewObjs(viewIdx).hImg       = oldViewObjs(viewIdx).hImg;
            newViewObjs(viewIdx).isRgb      = oldViewObjs(viewIdx).isRgb;
            newViewObjs(viewIdx).isDispText = oldViewObjs(viewIdx).isDispText;

            % Deconstruct the image
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

        % This is a special case. If the qt_image object calling the "show"
        % method already has a view object on one of the axes, dconstruct the
        % previous object
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
        newViewObjs(1:nAxNew)  = imgview(obj);

        % Set the RGB property
        [newViewObjs(:).isRgb] = deal(isRgb);

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

end %show


%----------------------------------------------------
function [obj,varargout] = parse_inputs(obj,varargin)

    % Validate the number of inputs
    narginchk(1,3);

    % There are two cases to consider: 1) the user called "show" on a stack of
    % image objects and 2) the user called "show" on a single element of an
    % image object array. Note that these cases for an array with one image
    % object are degenerate
    %
    % If a display figure does not already exist, it is easy: show the imgviewer
    % and be down with it. However, what to do if the viewer (or QUATTRO) exists
    % under these circumstances.
    validViewInd = arrayfun(@(x) any( ~isempty(x.imgViewObj) ),obj);
    if (nargin==1) && ~any(validViewInd(:))
        varargin{1} = obj.viewer;
        obj         = obj(1);
    elseif (nargin==2) && numel(obj)>1
        error(['qt_image:' mfilename ':tooManyImgObjs'],...
              ['Show may be called on only 1 qt_image object at a time.\n',...
               'Try obj(1).show, where obj is the current image object.\n']);
    end

    % Set up parser
    parser = inputParser;
    parser.addOptional('showObj',[],@(x) all(ishandle(x)) ||...
                                                  strcmpi(class(x),'qt_image'));
    parser.addOptional('useRGB',false,@(x) islogical( logical(x) ));

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
                  ['Refresh syntax of "show" may be called with only one\n',...
                   'qt_image object to be refreshed. Type ''help qt_image.show\n',...
                   'for more information.\n']);
        end
    else %axis/axes handle(s) were provided
        % For ease in dealing the axis handle(s) to individual image view
        % objects, a cell array is preferred
        results.showObj = num2cell(results.showObj);
    end

    % Deal the outputs
    varargout = struct2cell(results);

end %parse_inputs