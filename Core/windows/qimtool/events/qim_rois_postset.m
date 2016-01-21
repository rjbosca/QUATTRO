function qim_rois_postset(~,eventdata)
%qim_rois_postset  Post-set event for qt_exam property "rois"
%
%   qim_rois_postset(SRC,EVENT) handles post-set events following changes to the
%   "rois" property of a qt_exam object using the event source data(SRC) and
%   event data (EVENT) objects. Specifically, the list of ROIs available for 
%   the modeling GUI are updated according to the strings stored in the QUATTRO
%   listbox

    % Get the current modeling objects
    mObjs = eventdata.AffectedObject.models;

    % Grab only those modeling objects that have modeling GUIs
    mObjs = mObjs( cellfun(@(x) ~isempty(x.hFig),mObjs) );
    if isempty(mObjs)
        return
    end

    % Grab the new ROI names
    roiNames = eventdata.AffectedObject.roiNames.roi;

    % Determine the available options based on the new listbox string
    if isempty(roiNames)
        modes = {'','Cur. Pixel'};
    else
        modes = {'','Cur. Pixel','Cur. ROI Proj.','Cur. ROI','VOI'};
    end

    % Update the UI tools
    cellfun(@(x) update_ui_tools(x.hFig),mObjs);


        %-----------------------------
        function update_ui_tools(hFig)

            % Grab the handles structure
            hs = guidata(hFig);

            % Determine how to change the current value. The only case that must
            % be considered is in the event that ROIs existed, but have been
            % deleted
            if (get(hs.popupmenu_data,'Value')>numel(modes))
                set(hs.popupmenu_data,'Value',1);
                setappdata(mObjs.hFig,'dataMode','none');
            end    
            set(hs.popupmenu_data,'String',modes)

            % Update the ROI selection pop-up menu
            set(hs.popupmenu_roi,'String',roiNames);
            if (get(hs.popupmenu_data,'Value')>2)
                set(hs.popupmenu_roi,'Visible','on');
            end

        end %update_ui_tools


end %qim_rois_postset


