function save_Callback(hObj,~)
%save_Callback  Callback for handling QUATTRO save requests
%
%   save_Callback(H,EVENT)

    % Disable user controls
    hs  = guihandles(hObj);
    obj = getappdata(hs.figure_main,'qtExamObject');
    update_controls(hs.figure_main,'disable');

    % Determine save type
    objTag = get(hObj,'Tag');
    switch objTag
        case {'uipushtool_save_data','menu_save'}
            saveType = 'save';
        case 'menu_save_as'
            saveType = 'saveas';
        case {'menu_save_images','menu_save_maps','menu_save_rois'}
            saveType = objTag(11:end);
    end

    % Revert to original view for surgical planning exams
    isSurgery = strcmpi( getappdata(hs.figure_main,'examtype'), 'surgery' );
    if isSurgery
        vc = get(obj.h_view,'Value');
        vo = get_dicom_orientation(obj.headers(1,1),'ssd');
        obj.reformat(vo);
        setappdata(obj.h_view,'currentvalue',vo);
    end

    % Try to save exam
    try
        obj.save(saveType);
    catch ME
        rethrow(ME)
    end

    % Return to original format for surgical planning exams
    if isSurgery
        obj.reformat(vc);
        setappdata(obj.h_view,'currentvalue',vc);
    end

    % Enable user controls
    update_controls(hs.figure_main,'enable');

end %save_Callback