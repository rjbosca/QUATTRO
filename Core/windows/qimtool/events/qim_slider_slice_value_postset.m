function qim_slider_slice_value_postset(src,eventdata)
%qim_slider_slice_value_postset  
%
%   qim_slider_slice_value_postset(SRC,EVENT) handles changes to the "Value"
%   property of QUATTRO's slice slider UI using the slider handle (SRC) and
%   event data (EVENT) objects.

    % Get the UI control handle and validate the event call
    hSlider = eventdata.AffectedObject;
    if ~strcmpi( get(hSlider,'Style'), 'slider' )
        warning(['QUATTRO:' mfilename ':invalidHandleStyle'],...
                 'Event calls to %s must originate from an slider UI control',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'value')
        waring(['QUATTRO:' mfilename ':invalidEditEvent'],...
                'Event calls to %s must originate from a "Value" PostSet event.',...
                mfilename);
        return
    end

    % Get the QUATTRO figure handle, some slider information, and the modeling
    % object
    hFig      = guifigure(eventdata.AffectedObject);
    sliderVal = round( get(eventdata.AffectedObject,'Value') );
    obj       = getappdata(hFig,'modelsObject');

    % Grab only those modeling objects that have modeling GUIs
    obj       = obj( ~isempty(obj(:).hFig) );
    if isempty(obj)
        return
    end

    %TODO: determine how to handle the following events if the modeling object
    %is an array of objects

    % Grab the appropriate edit text box handle and update the image location
    % variables
    hSlider = findobj(obj.hFig,'Tag','edit_slice');

    % Set the new value
    set(hSlider,'String',num2str(sliderVal));

end %qim_slider_slice_value_postset