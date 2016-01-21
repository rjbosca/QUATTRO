function update_exam_tools(~,eventdata)
%update_exam_tools  Updates the QUATTRO GUI following changes to exam type
%
%   update_exam_tools(SRC,EVENT) handles QUATTRO GUI update following changes to
%   the "type" property of QT_EXAM objects. Exam specific UI controls are 
%   updated during calls to this event function

    % Grab the qt_exam object and determine the exam type
    obj = eventdata.AffectedObject;
    if isempty(obj.hFig) || ~ishandle(obj.hFig)
        return
    end

    % Get the handles structure
    hFig = obj.hFig;
    hs   = guidata(hFig);

    % Update the "Checked" property for the "Exam Type" selections
    newTypeTag = ['menu_' obj.type];
    if isfield(hs,newTypeTag)
        set( hs.(newTypeTag), 'Checked','on' );
    else
        warning(['QUATTRO:' mfilename ':invalidMenu'],...
                ['An attempt was made to set the exam type sub-menu ',...
                 'with tag "%s". This is likely the result of a newly ',...
                 'supported exam type in the QT_EXAM object. Update ',...
                 '"gui_menus" to reflect the change.'],newTypeTag);
    end

    % Delete previous exam-specific tools and ensure the ROI listbox is the
    % appropriate size
    delete(findobj(hFig,      'Tag','uipanel_surgical_planning')); %surgery tools
    set(hs.uipanel_roi_labels,'Position',[560 100 162 310]);

    % Generate the exam specific UI controls
    if any( strcmpi(obj.type,{'dce','dsc'}) )

        % Prepare the dynamic MRI UI tools
        set([hs.menu_modeling
             hs.menu_report_vif
             hs.menu_modeling_options
             hs.context_use_as_vif],'Enable','on','Visible','on');
        popStr = get(hs.popupmenu_roi_tag,'String');
        if ~any( strcmpi(popStr,'vif') )
            set(hs.popupmenu_roi_tag,'String',[popStr(:);'VIF']);
        end

    elseif strcmpi(obj.type,'surgery')

        % Determine image orientation and set pop-up menu
        vp = get_dicom_orientation(hdrs(1,1),'ssd');
        if isinf(vp)
            errordlg({'Oblique data detected.',...
                      'New data orientations not supported.'},...
                      'Oblique data warning','modal');
            vp = 1; str = {'Oblique'};
        else
            str = {'Sagittal','Coronal','Axial'};
        end
        setappdata(hs.popupmenu_view_plane,'currentvalue',vp);

        % Hide UI tools
        set(hs.checkbox_use_voi,'Value',0,'Visible','off');
        hMenu = findobj(get(hs.listbox_rois,'UIContextMenu'),...
                                                  'Tag','context_go2roi_slice');
        set([hs.uipanel_roi_tools
             hs.menu_calculate_maps
             hs.menu_map_options
             hs.menu_modeling
             hMenu(:)],'Visible','off');

        % Prepare UI tools
        set(hs.popupmenu_view_plane,'Value',vp,'String',str,'Visible','on');
        set(hs.uipanel_roi_labels,'Title','Target Labels');
        set(hs.text_view_plane,'Visible','on');
        set(hs.menu_export_images,'Enable','on');
        surgery_tools(hFig);
        if numel(str) > 1
            set(hs.popupmenu_view_plane,'Enable','on','Visible','on');
        end

    end

    % Update the exam type specific menu tags
    visStr = 'on';
    if any( strcmpi(obj.type,{'generic','surgery'}) )
        visStr = 'off';
    end
    set(hs.menu_modeling_options,'Visible',visStr);

    % Update the handles structure
    guidata(hFig,guihandles(hFig));

end %update_exam_tools