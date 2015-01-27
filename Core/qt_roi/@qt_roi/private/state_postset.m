function state_postset(obj,src,eventdata)
%state_postset  PostSet event for the "state" property
%
%   state_postset(OBJ,SRC,EVENT)

    % Grab the roiview object
    viewObj = obj.roiViewObj;
    if isempty(viewObj) || ~any(viewObj.isvalid)
        return
    end

    % Set the render property of the view object to false
    if strcmpi(obj.state,'off')
        [viewObj(:).render] = deal(false);
    else
        [viewObj(:).render] = deal(true);
    end

end %qt_roi.state_postset