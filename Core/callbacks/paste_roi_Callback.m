function paste_roi_Callback(hObj,~)
%paste_roi_Callback  Callback for ROI paste requests
%
%   paste_roi_Callback(H,EVENT)

    % Ensure there is a copied ROI to paste
    obj = getappdata(gcbf,'qtExamObject');
    if obj.roiCopy.isEmpty || ~obj.roiCopy.isvalid
        return
    end

    % Determine paste type
    if strcmpi(get(hObj,'String'),'paste') %paste current
        pstType = 'single';
    else %paste to all
        % Allows the user to choose whether to copy and paste to all subsequent
        % or to all time points in the series of the current slice
        str = lower( questdlg( {'Paste to all images in the series',...
                                'or only images subsquent to the current?'},...
                                'Paste to All', 'Subsequent', 'All',...
                                'Cancel', 'Subsequent') );
        if (strcmpi(str,'cancel') || isempty(str))
            return
        end
    end

    % Gather some information about the qt_exam object's data
    seMax = size(obj.imgs,2);

    % Determine where the new ROIs should be pasted
    switch pstType
        case 'single'
            seInds = obj.seriesIdx;
        case 'all'
            seInds = 1:seMax;
        case 'subsequent'
            seInds = obj.seriesIdx+1:seMax;
    end

    % Perform paste operation for each ROI and series index
    roiCopyTag = obj.roiCopy.tag;
    roiNames   = obj.roiNames;
    for rIdx = obj.roiIdx.(roiCopyTag)

        % Determine the ROI name to be used for pasting at this ROI location
        name = roiNames.(roiCopyTag){rIdx};

        for seIdx = seInds

            % Create a clone of the copied ROI, including the previous "tag"
            % property to ensure that the ROI is stored in the correct location
            % while calling the "addroi" method. When pasting ROIs, the new
            % objects are copied to the current index so the "state" property
            % must be set to 'on'
            roiClone       = obj.roiCopy.clone('tag');
            roiClone.name  = name;
            roiClone.state = 'on';

            % Add the listener for updating the ROI statistics. This is a
            % QUATTRO GUI specific listener so add it here instead of the
            % "addroi" method
            fcn = @(src,event) update_roi_stats(src,event,obj.hFig);
            addlistener(roiClone,'roiStats','PostSet',fcn);

            % Add the ROI to the stack
            obj.addroi(roiClone,'series',seIdx);

        end %series loop

    end %ROI index loop

end %paste_roi_Callback