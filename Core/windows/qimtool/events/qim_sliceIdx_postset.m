function qim_sliceIdx_postset(~,eventdata)
%qim_sliceIdx_postset  Post-set event for qt_exam property "sliceIdx"
%
%   qim_sliceIdx_postset(SRC,EVENT) handles the post-set event following
%   changes to the "sliceIdx" property of a qt_exam object using the source
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
    sliceVal = eventdata.AffectedObject.sliceIdx;
    cellfun(@(x) update_ui_tool(x.hFig,sliceVal),mObjs);

end %qim_sliceIdx_postset


%--------------------------------
function update_ui_tool(hFig,val)
    if ~isempty(val)
        hs = guidata(hFig);
        set(hs.edit_slice,'String',num2str(val));
        setappdata(hs.edit_series,'currentval',val);
    end
end