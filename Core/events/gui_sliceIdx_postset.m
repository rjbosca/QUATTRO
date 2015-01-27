function gui_sliceIdx_postset(src,eventdata)
%gui_sliceIdx_postset  GUI PostSet event for qt_exam property "sliceIdx"
%
%   gui_sliceIdx_postset(SRC,EVENT)

    % Update the slice slider's position if needed
    obj     = eventdata.AffectedObject; %alias
    tag     = 'slider_slice';
    hSlider = findobj(obj.hFig,'Tag',tag);
    if ~isempty(hSlider) && (obj.(src.Name)==getappdata(hSlider,'currentvalue'))
        return
    elseif isempty(hSlider) %no slider found - useful for devs
        warning(['QUATTRO:' mfilename ':missingUIObj'],...
                 'Unknown UI graphics object with the tag "%s".\n',tag);
        return
    end

    % Update the slider value according to the new "sliceIdx" value and update
    % the application data
    set(hSlider,'Value',obj.(src.Name));
    setappdata(hSlider,'currentvalue',obj.(src.Name));

    % Update the maps pop-up menu and ROI stats display
    update_map_popupmenu(obj.hFig,obj);
    update_roi_stats([],struct('AffectedObject',obj.roi),obj.hFig);

end %gui_sliceIdx_postset