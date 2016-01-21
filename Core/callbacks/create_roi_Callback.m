function create_roi_Callback(hObj,~)
%create_roi_Callback  Callback for ROI creation requests
%
%   create_roi_Callback(H,EVENT)

    % Get handles structure and the exams object
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');

    % Get some properties that will be used later
    newIdx = obj.roiIdx.(obj.roiTag)+1;
    roiTag = obj.roiTag;
    roiNms = obj.roiNames.(roiTag);

    % Determine the new ROI name. There are 3 cases: (1) no ROIs exist and a new
    % name must be provided, (2) ROIs exist and the user wants to create a new
    % label, (3) ROIs exist and the user wants to add the new ROI to one of the
    % pre-existing labels.
    if obj.exists.rois.(roiTag) %ROIs exist. Determine either case (2) or (3)
        [roiNm,ok] = listdlg('PromptString','Select a contour label.',...
                             'SelectionMode','Single',...
                             'ListString',[roiNms(:);...
                                           '-----------------------------';...
                                           'Add new label'],...
                             'InitialValue',min(newIdx)-1,...
                             'Name','New ROI Label');

        % Determine what selection the user made
        nRois = numel(roiNms);
        if ~ok || (roiNm==nRois+1)
            return
        elseif (roiNm>nRois)
            roiNm  = '';
            newIdx = nRois + 1;
        end

    end
    if ~obj.exists.rois.(roiTag) || isempty(roiNm) %case (1) or (2)
        roiNm      = inputdlg('Enter new label','New ROI',1,{'NewLabel'});
        if isempty(roiNm)
            return
        end
        roiNm      = roiNm{1};
        isUniqueNm = all(~strcmpi(roiNm,roiNms));
        if ~isUniqueNm
            errordlg('ROI names must be unique');
            return
        end
    elseif isnumeric(roiNm) %case (3)
        newIdx = roiNm;
        roiNm  = roiNms{newIdx};
    end

    % Disable user controls
    update_controls(hFig,'disable')
    set( findall(hFig,'Tag','uitoggletool_data_cursor'), 'State', 'off' );

    % Hide all ROI displays for the current QUATTRO location
    isPreviousRois = any(obj.roi(:).validaterois);
    if isPreviousRois
        [obj.roi(:).state] = deal('off');
    end

    % Initiate interactive session for placing the ROI
    rType    = strrep( regexp(get(hObj,'Tag'),'_\w*_','match'), '_','' );
    rType{1} = strrep(rType{1},'freehand','spline'); %'freehand' is not valid - qt_roi
    roiObj   = qt_roi(obj.image,rType{1},'Tag',obj.roiTag);

    if roiObj.validaterois

        % Store the new ROI name
        roiObj.name = roiNm;

        % Add the post-set listener to update the QUATTRO ROI stats and store
        % the new ROI object and index.
        fcn = @(src,event) update_roi_stats(src,event,hFig);
        addlistener(roiObj,'roiStats','PostSet',fcn);
        obj.addroi(roiObj);

        % Notify the "roiChanged" event to ensure all ROI UI tools are updated
        % appropriately.
        notify(obj,'roiChanged');
        obj.roiIdx.(obj.roiTag) = newIdx;

    else

        % Reinstate the view of all current ROI
        if isPreviousRois
            [obj.roi(:).state] = deal('on');
        end

    end

end %create_roi_Callback