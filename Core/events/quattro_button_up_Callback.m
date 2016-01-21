function quattro_button_up_Callback(hObj,~)
%quattro_button_up_Callback  Mouse button up event callback for QUATTRO GUI
%
%   quattro_button_down_Callback(H,EVENT) determines what object within the
%   QUATTRO GUI was "hit" by the button up event, creating an undo for any "hit"
%   ROIs that were moved from their original location

    % Only consider LMB interactions
    if ~strcmpi( get(hObj,'SelectionType'), 'normal' )
        return
    end

    % Initialize the workspace
    hFig            = gcbf; %QUATTRO handle
    figCurrentPoint = get(hObj,'CurrentPoint');
    axCurrentPoint  = get(gca,'CurrentPoint');

    % Determine which object was "hit" by the button up event. Follwing the
    % release of MATLAB 2014b, the functionality of HITTEST changed
    if getappdata(hFig,'isNumericHandle') %pre-2014b
        obj      = hittest(hFig,figCurrentPoint);
    else
        obj      = hittest(hFig);
    end
    objParent    = get(obj,'Parent');
    objTag       = get(objParent,'Tag');
    if strcmpi(get(obj,'Tag'),'impoint')
        objTag   = get(obj,'Tag');
    end

    % Determine if an ROI object was "hit" and if the necessary application data
    % exists in the current figure
    hitRoi = any(strcmpi(objTag,{'imspline','imrect','imellipse',...
                                 'impoly','impoint'})) && ~isempty(objTag);
    if ~hitRoi
        return
    end

    % Grab the current QT_EXAM object and ROI cache
    examObj  = getappdata(hFig,'qtExamObject');

    % Determine which ROI was "hit" by looping through each of the current ROIs
    % and using the hidden "hittest" method. Once the ROI has been located,
    % there is no need to test any other ROIs as only one ROI can be "hit" at a
    % time.
    for roi = examObj.roi(:)'
        if roi.hittest(axCurrentPoint(1,1:2))
            examObj.addroiundo(roi,'moved');
            notify(roi,'mouseButtonUp');
            break
        end
    end

end %quattro_button_up_Callback