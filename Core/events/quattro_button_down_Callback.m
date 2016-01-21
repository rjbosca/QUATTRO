function quattro_button_down_Callback(hObj,~)
%quattro_button_down_Callback  Mouse button down event callback for QUATTRO GUI
%
%   quattro_button_down_Callback(H,EVENT) determines what object within the
%   QUATTRO GUI was "hit" by the button down event, caching any "hit" ROIs to be
%   used in determining the undo status

    % Grab the current point for the figure and axis
    figCurrentPoint = get(hObj,'CurrentPoint');
    axCurrentPoint  = get(gca,'CurrentPoint');

    % Determine which object was "hit" by the button down event. Follwing the
    % MATLAB 2014b release, the functionality of HITTEST changed
    if getappdata(gcbf,'isNumericHandle')
        obj       = hittest(hObj,figCurrentPoint);
    else
        obj       = hittest(hObj);
    end
    objParent     = get(obj,'Parent'); %ROI handle (hopefully)
    objTag        = get(objParent,'Tag');
    if isempty(objTag) || ~isempty(strfind(objTag,'axes'))
        objTag    = get(obj,'Type');
    end
    if strcmpi(objTag,'hggroup')
        objTag    = get(obj,'Tag');
    end

    % Mouse selection type
    clickType = get(hObj,'SelectionType');

    % Determines if ROI was hit with a normal click
    hitRoi = any( strcmpi(objTag,{'imspline','imrect',...
                                  'imellipse','impoly','impoint'}) );
    if ~hitRoi || ~strcmpi(clickType,'normal')
        return
    end

    % Get the QT_EXAM object
    examObj = getappdata(gcbf,'qtExamObject');

    % Determine which ROI was "hit" by looping through each of the current ROIs
    % and using the hidden "hittest" method. Once the ROI has been located,
    % there is no need to test any other ROIs as only one ROI can be "hit" at a
    % time.
    for roi = examObj.roi(:)'
        if roi.hittest(axCurrentPoint(1,1:2))
            notify(roi,'mouseButtonDown');
            break
        end
    end

end %quattro_button_down_Callback