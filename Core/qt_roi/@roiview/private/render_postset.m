function render_postset(obj,src,eventdata)
%render_postset  PostSet event for roiview property "render"
%
%   render_postset(OBJ,SRC,EVENT)

    % Grab the roiview object for ease of access
    obj = eventdata.AffectedObject;

    % Determine what action to take
    if obj.render %Fire the handler for updating ROI displays
        obj.update;
    else %Delete any current ROI displays
        delete(obj.hRoi);
    end

end %roiview.render_postset