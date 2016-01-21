function newModelData_event(obj,src,eventdata)
%newModelData_event  
%
%   newModelData_event(MODEL,SRC,EVENT)

    % Before performing any computations, ensure that the data event modes and
    % model modes match
    %TODO: this code assumes that a model data mode of 'manual' cannot be
    %achieved. Is this correct???
    modelDataMode = obj.dataMode;
    eventDataMode = eventdata.dataMode;
    isRoi         = strcmpi(eventDataMode,'roi');
    isCorrectMode = (~isRoi && strcmpi(modelDataMode,'pixel')) ||...pixel mode
                    (isRoi && any(strcmpi(modelDataMode,{'label','project'})));
    if ~isCorrectMode
        return
    end

    %FIXME: the current code assumes that the user is operating with a GUI. Will
    %this always be true???

    % Grab the handles structure
    hs = guidata(obj.hFig);

    % Validate "on-the-fly" event information. When operating in this mode
    % (i.e., when an ROI or the QT_EXAM "voxelIdx" property has changed), the
    % location of the modeling object must be commensurate with the QT_EXAM
    % location properties
    slIdx  = getappdata(hs.edit_slice,'currentvalue');
    seIdx  = getappdata(hs.edit_series,'currentvalue');
    roiIdx = get(hs.popupmenu_roi,'Value');
    if strcmpi(eventdata.eventMode,'otf') && ~strcmpi(modelDataMode,'pixel')
        isCorrectLoc = (src.sliceIdx==slIdx) && (src.seriesIdx==seIdx) &&...
                                                    any(src.roiIdx.roi==roiIdx);
        if ~isCorrectLoc
            return
        end
    end

    % Perform the appropriate "get" operation and update the modeling object's
    % "y" property
    yData = [];
    switch eventdata.dataMode
        case 'pixel'
            yData = src.getroivals('pixel');
        case 'roi'
            yData = src.getroivals(modelDataMode,@mean,true,...
                                   'slice',slIdx,...
                                   'series',seIdx,...
                                   'roi',roiIdx,...
                                   'tag','roi');
    end

    if ~isempty(yData)
        obj.y = yData;
    end
end %qt_exam.newModelData_event