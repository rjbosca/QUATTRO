function update_controls(hFig,varargin)
%controls  Handles display/functionality of all QUATTRO controls
%
%   controls(H,ACT) performs the specified action, ACT, to the main figure (H)
%   QUATTRO controls. Valid action strings are:
%
%       String          Description
%       ----------------------------
%       'enable'        Sets the enable property to 'on' for all controls. This
%                       is accomplished programatically to ensure that only
%                       controls that manipulate existing data are enabled.
%
%       'disable'       Sets the enable property of all user controls to 'off'.
%
%       'hide'          Sets the visible property of all user controls to 'off'.
%
%   controls(H,ACT1,ACT2,...) performs the specified actions, ACT1, ACT2, etc.
%   sequentially.

    % Validate the QUATTRO GUI
    if ~strcmpi(qt_name,get(hFig,'Name'))
        return
    end

    % Validate input
    action = cellfun(@(x) validatestring(x,{'enable','disable','hide'}),...
                                                varargin,'UniformOutput',false);

    % Get handles structure
    hs     = guihandles(hFig);

    % Grab some information from the current exams object
    eObj  = getappdata(hFig,'qtExamObject');
    isObj = eObj.isvalid;
    if isObj
        eType = eObj.type;
    end

    % Perform action. As of MATLAB 2015b, the use of CELLFUN with the action
    % cell causes an error (not being able to locate the sub-functions of
    % UPDATE_CONTROLS) becuase the ENABLE_CONTROLS, DISABLE_CONTROLS, and
    % HIDE_CONTROLS are hidden from the call to CELLFUN. A loop as been used
    % instead
    for s = action
        eval([s{1} '_controls']);
    end

    function enable_controls %#ok<*DEFNU>

        % Enable base user contorls
        set([hs.menu_file
             hs.menu_import
             hs.menu_import_images
             hs.uipushtool_open_file
             hs.uipushtool_new_quattro],'Enable','on');

        % Enable image parameter maps when present
        if isObj && eObj.exists.maps.current
            set([hs.popupmenu_maps
                 hs.menu_export_images
                 hs.menu_save_maps],'Enable','on');
        end

        % Enable images when present
        if isObj && eObj.exists.images.any
            set([hs.menu_save
                 hs.menu_exam
                 hs.menu_exam_type
                 hs.menu_image
                 hs.menu_save_as
                 hs.menu_save_only
                 hs.menu_save_images
                 hs.menu_export
                 hs.menu_analysis
                 hs.menu_load_maps
                 hs.menu_load_rois
                 hs.menu_import_rois 
                 hs.menu_import_maps
                 hs.pushbutton_poly_roi
                 hs.pushbutton_rect_roi
                 hs.pushbutton_ellipse_roi
                 hs.pushbutton_freehand_roi
                 hs.slider_slice
                 hs.slider_series
                 hs.uipushtool_save_data
                 hs.uitoggletool_zoom_in
                 hs.uitoggletool_data_cursor],'Enable','on');

             % Only enabled when the image is in zoom mode
             if eObj.image.isZoomed
                 set([hs.uitoggletool_drag
                      hs.uitoggletool_zoom_out],'Enable','on');
             end

             % Only enabled when 3D data is present
             if strcmpi(eType,'surgery')
                 set(hs.popupmenu_view_plane,'Enable','on');
             end

             % Only enabled when multiple exams are present
             if (numel(eObj)>1)
                 set(hs.menu_remove_exam,'Enable','on');
             end
        end

        % Enable parameter map calculations when supported
        if isObj && eObj.isReady.maps
            set(hs.menu_calculate_maps,'Enable','on');
        end

        % Only enable when multiple exam information is loaded
        if isObj && (numel(getappdata(eObj.hFig,'qtWorkspace'))>1)
            set([hs.popupmenu_exams...
                 hs.menu_remove_exam],'Enable','on');
        end

        % Enable ROIs when data are present
        if isObj && eObj.exists.rois.any &&...
                         strcmpi(get(hs.uitoggletool_data_cursor,'State'),'off')
            set([hs.checkbox_use_voi
                 hs.listbox_rois
                 hs.menu_reports
                 hs.menu_save_rois
                 hs.menu_snr_calcs
                 hs.menu_roi_reports
                 hs.menu_export_rois
                 hs.menu_report_roi_pixels],'Enable','on');
            set([hs.menu_export_rois
                 hs.menu_export_rois_masks
                 hs.menu_export_rois_pinnacle],'Visible','on');

            % Only enabled when a contour is selected
            if any(eObj.roi(:).validaterois)
                set([hs.pushbutton_copy
                     hs.pushbutton_delete_roi],'Enable','on');
            end

            % Only enabled when a single ROI label is selected
            if numel(get(hs.listbox_rois,'Value'))==1
                set(hs.pushbutton_clone_roi,'Enable','on');
            end

            % Only enabled when a contour has been copied
            if any(eObj.roiCopy(:).validaterois)
                set([hs.pushbutton_paste
                     hs.pushbutton_paste_to_all],'Enable','on');
            end

            % DCE specific
            if strcmpi(eType,'DCE') && isfield(eObj.exists.rois,'vif') &&...
                                                            eObj.exists.rois.vif
                set(hs.menu_report_vif,'Enable','on');
            end

            % Surgical planning
            if strcmpi(eType,'surgery')
                set(hs.menu_export_images,'Enable','on');
            end
        end

    end %enable_controls

    function disable_controls

        % Disable controls
        set([hs.checkbox_use_voi
             hs.listbox_rois
             hs.menu_file
             hs.menu_exam
             hs.menu_save
             hs.menu_image
             hs.menu_import
             hs.menu_save_as
             hs.menu_reports
             hs.menu_analysis
             hs.menu_save_only
             hs.menu_report_vif
             hs.menu_remove_exam
             hs.menu_roi_reports
             hs.pushbutton_copy
             hs.pushbutton_paste
             hs.pushbutton_poly_roi
             hs.pushbutton_rect_roi
             hs.pushbutton_clone_roi
             hs.pushbutton_delete_roi
             hs.pushbutton_ellipse_roi
             hs.pushbutton_freehand_roi
             hs.pushbutton_paste_to_all
             hs.popupmenu_maps
             hs.popupmenu_exams
             hs.popupmenu_view_plane
             hs.slider_slice
             hs.slider_series
             hs.uipushtool_open_file
             hs.uipushtool_save_data
             hs.uitoggletool_drag
             hs.uitoggletool_zoom_in
             hs.uitoggletool_zoom_out
             hs.uitoggletool_data_cursor], 'Enable','off');

    end %disable_controls

    function hide_controls

        % Sets image specific UI controls
        if isObj && ~eObj.exists.images.any
            set([hs.text_view_plane
                 hs.text_exam_info
                 hs.popupmenu_view_plane
                 hs.slider_slice
                 hs.slider_series
                 hs.uipanel_axes_main
                 hs.uipanel_roi_tools
                 hs.uipanel_exams
                 hs.menu_modeling_options], 'Visible', 'off');
        end

        % Sets ROI specific UI controls
        if isObj && ~eObj.exists.rois.any
            set([hs.menu_report_vif
                 hs.pushbutton_undo
                 hs.pushbutton_copy
                 hs.pushbutton_paste
                 hs.pushbutton_paste_to_all
                 hs.pushbutton_clone_roi
                 hs.pushbutton_delete_roi
                 hs.uipanel_roi_labels
                 hs.uipanel_roi_stats], 'Visible', 'off');
            set(hs.listbox_rois,'Value',[]);
        end

        % Sets overlay specific UI controls
        if ~isempty( get(hs.popupmenu_maps,'String') )
            set(hs.uipanel_maps, 'Visible', 'off');
        end

    end %hide_controls

end %update_controls