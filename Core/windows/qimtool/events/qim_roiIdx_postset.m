function qim_roiIdx_postset(~,eventdata)
%qim_roiIdx_postset  Post-set event for QT_EXAM property "roiIdx"
%
%   qim_roiIdx_postset(SRC,EVENT) handles post-set events following changes to
%   the "roiIdx" property of a QT_EXAM object using the source data (SRC) and
%   associated event data object (EVENT)

    % Get the current modeling objects
    mObjs = eventdata.AffectedObject.models;

    % Grab only those modeling objects that have modeling GUIs
    mObjs = mObjs( cellfun(@(x) ~isempty(x.hFig),mObjs) );
    if isempty(mObjs)
        return
    end

    % Set the new value. Since listboxes can have multiple values selected, use
    % only the first
    roiVal = eventdata.AffectedObject.roiIdx.roi;
    cellfun(@(x) update_ui_tool(x.hFig,roiVal),mObjs);

end %qim_roiIdx_postset


%--------------------------------------
function update_ui_tool(hFig,val)
    if ~isempty(val)
        hs = guidata(hFig);
        set(hs.popupmenu_roi,'Value',val);
        setappdata(hs.popupmenu_roi,'currentval',val);
    end
end