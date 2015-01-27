function qim_selection_postset(src,eventdata)
%qim_selection_postset  PostSet event handler for slice/series edit boxes
%
%   qim_selection_postset(SRC,EVENT) handles PostSet events for the slice/series
%   edit textboxes and the ROI pop-up menu of the modeling GUI given by the
%   source (SRC) and event data (EVENT) objects. Specifically, application data
%   is updated to reflect the new string and, if appropriate, the modeling
%   object's data ("y" property) is refreshed.

    % Get the UI control handle and validate the action
    hObj     = eventdata.AffectedObject;
    objStyle = hObj.Style;
    if strcmpi(objStyle,'edit')

        if ~strcmpi(src.Name,'string')
            warning(['QUATTRO:' mfilename ':invalidEditEvent'],...
                    ['Event calls to %s must originate from a "String" ',...
                     'PostSet event.'],mfilename);
            return
        end

        % Get the new value and validate
        val = str2double(hObj.String);
        if isnan(val) || isinf(val) || (val==getappdata(hObj,'currentvalue'))
            return
        end

    elseif strcmpi(objStyle,'popupmenu')

        if ~strcmpi(src.Name,'value')
            warning(['QUATTRO:' mfilename ':invalidEditEvent'],...
                    ['Event calls to %s must originate from a "Value" ',...
                     'PostSet event.'],mfilename);
            return
        end

        % Get the new value
        val = hObj.Value;

    else
        warning(['QUATTRO:' mfilename ':invalidEventHandle'],...
                ['Event calls to %s must originate from an edit or listbox ',...
                 'UI control.'],mfilename);
        return
    end

    % Update the application data
    setappdata(hObj,'currentvalue',val);

    % Grab the current data mode and update the model data as appropriate
    hFig     = guifigure(hObj);
    dataMode = getappdata(hFig,'dataMode');
    if ~strcmpi(dataMode,'none')

        % Grab the modeling and qt_exam objects and the necessary indices
        modObj    = getappdata(hFig,'modelsObject');
        exObj     = getappdata(hFig,'qtExamObject');
        roiIdx    = get( findobj(hFig,'Tag','popupmenu_roi'), 'Value' );
        sliceIdx  = getappdata(findobj(hFig,'Tag','edit_slice'),'currentvalue');
        seriesIdx = getappdata(findobj(hFig,'Tag','edit_series'),'currentvalue');

        % Update the data
        modObj.y = exObj.getroivals(dataMode,@mean,true,...
                                    'roi',   roiIdx,...
                                    'series',seriesIdx,...
                                    'slice', sliceIdx,...
                                    'tag',   'roi');

    end

end %qim_selection_postset