function gui_seriesIdx_postset(src,eventdata)
%gui_seriesIdx_postset  GUI PostSet event for qt_exam property "seriesIdx"
%
%   gui_seriesIdx_postset(SRC,EVENT)

    % Update the slice slider's position if needed
    obj     = eventdata.AffectedObject; %alias
    tag     = 'slider_series';
    hSlider = findobj(obj.hFig,'Tag',tag);
    if ~isempty(hSlider) && (obj.(src.Name)==getappdata(hSlider,'currentvalue'))
        return
    elseif isempty(hSlider) %no slider found - useful for devs
        warning(['QUATTRO:' mfilename ':missingUIObj'],...
                 'Unknown UI graphics object with the tag "%s".\n',tag);
        return
    end

    % Update the slider value according to the new "seriesIdx" value and update
    % the application data
    set(hSlider,'Value',obj.(src.Name));
    setappdata(hSlider,'currentvalue',obj.(src.Name));

    % Update the ROI stats display
    update_roi_stats([],struct('AffectedObject',obj.roi),obj.hFig);

end %gui_seriesIdx_postset