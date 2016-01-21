function qim_seriesIdx_postset(~,eventdata)
%qim_seriesIdx_postset  Post-set event for qt_exam property "seriesIdx"
%
%   qim_seriesIdx_postset(SRC,EVENT) handles the post-set event following
%   changes to the "seriesIdx" property of a qt_exam object using the source
%   (SRC) and event data (EVENT) objects

    % Get the current modeling objects
    mObjs = eventdata.AffectedObject.models;

    % Grab only those modeling objects that have modeling GUIs
    mObjs = mObjs( cellfun(@(x) ~isempty(x.hFig),mObjs) );
    if isempty(mObjs)
        return
    end

    % Set the new value. Since listboxes can have multiple values selected, use
    % only the first
    seriesVal = eventdata.AffectedObject.seriesIdx;
    cellfun(@(x) update_ui_tool(x.hFig,seriesVal),mObjs);

end %qim_seriesIdx_postset


%--------------------------------
function update_ui_tool(hFig,val)
    if ~isempty(val)
        hs = guidata(hFig);
        set(hs.edit_series,'String',num2str(val));
        setappdata(hs.edit_series,'currentval',val);
    end
end