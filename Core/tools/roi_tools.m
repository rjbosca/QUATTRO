function roi_tools(hQt)
%roi_tools  Builds QUATTRO ROI tools
%
%   roi_tools(H) creates the ROI UI tools including the ROI creation tools, ROI
%   stats tools, and the storage display (listbox)

    % Verify input
    if isempty(hQt) || ~ishandle(hQt) || ~strcmpi(get(hQt,'Name'),qt_name)
        error(['QUATTRO:' mfilename 'qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
    end

    % Get handles structure and colors
    bkg = get(hQt,'Color');

    % Prepare panel displays
    hUip = [uipanel('Parent',hQt,...
                    'Position',[560 450 374 160],...
                    'Tag','uipanel_roi_tools',...
                    'Title','ROI Tools',...
                    'Visible','off')
            uipanel('Parent',hQt,...
                    'Position',[560 100 162 310],...
                    'Tag','uipanel_roi_labels',...
                    'Title','ROI Labels',...
                    'Visible','off')
            uipanel('Parent',hQt,...
                    'Position',[720 100 212 310],...
                    'Tag','uipanel_roi_stats',...
                    'Title','ROI Stats',...
                    'Visible','off')];
    hUip = [hUip
            uipanel('Parent',hUip(3),...
                    'Position',[10 227 91 51],...
                    'Tag','uipanel_mean',...
                    'Title','Mean')
            uipanel('Parent',hUip(3),...
                    'Position',[10 167 91 51],...
                    'Tag','uipanel_median',...
                    'Title','Median')
            uipanel('Parent',hUip(3),...
                    'Position',[10 107 91 51],...
                    'Tag','uipanel_stddev',...
                    'Title','Std. Dev.')
            uipanel('Parent',hUip(3),...
                    'Position',[10 47 91 51],...
                    'Tag','uipanel_snr',...
                    'Title','Current SNR')
            uipanel('Parent',hUip(3),...
                    'Position',[111 227 91 51],...
                    'Tag','uipanel_area',...
                    'Title','Area (pix.)')
            uipanel('Parent',hUip(3),...
                    'Position',[111 167 91 51],...
                    'Tag','uipanel_nan_ratio',...
                    'Title','NaN Ratio')
            uipanel('Parent',hUip(3),...
                    'Position',[111 107 91 51],...
                    'Tag','uipanel_kurtosis',...
                    'Title','Kurtosis')];

    % Initialize the ROI creation tools
    rectIcon = double(imread('rect_pushbutton.png'));
    rectIcon = rectIcon/double(uint16(inf));
          uicontrol('Parent',hUip(1),...
                    'BackgroundColor',1.2*bkg,...
                    'Callback',@create_roi_Callback,...
                    'CData',rectIcon,...
                    'Position',[10 76 64 64],...
                    'Tag','pushbutton_rect_roi',...
                    'Tooltip','Create a new rectangular ROI.');
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@create_roi_Callback,...
                      'Position',[82 76 64 64],...
                      'String','Ellipse',....
                      'Tag','pushbutton_ellipse_roi',...
                      'Tooltip','Create a new elliptical ROI.');
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@create_roi_Callback,...
                      'Position',[153 76 64 64],...
                      'String','Freehand',...
                      'Tag','pushbutton_freehand_roi',...
                      'Tooltip','Create a free-hand ROI.');
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@create_roi_Callback,...
                      'Position',[225 76 64 64],...
                      'String','Poly',...
                      'Tag','pushbutton_poly_roi',...
                      'Tooltip','Create a polygon ROI.');
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@create_roi_Callback,...
                      'Position',[297 76 64 64],...
                      'String','Point',...
                      'Tag','pushbutton_point_roi',...
                      'Tooltip','Create an image point.');
           [uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@clone_roi_Callback,...
                      'Position',[10 40 100 22],...
                      'String','Clone ROI Label',...
                      'Tag','pushbutton_clone_roi')
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@delete_roi_Callback,...
                      'Position',[120 40 100 22],...
                      'String','Delete ROI',...
                      'Tag','pushbutton_delete_roi')
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@copy_roi_Callback,...
                      'Position',[10 10 50 22],...
                      'String','Copy',...
                      'Tag','pushbutton_copy')
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@paste_roi_Callback,...
                      'Position',[70 10 50 22],...
                      'String','Paste',...
                      'Tag','pushbutton_paste')
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@paste_roi_Callback,...
                      'Position',[130 10 90 22],...
                      'String','Paste to All',...
                      'Tag','pushbutton_paste_to_all')
            uicontrol('Parent',hUip(1),...
                      'BackgroundColor',1.2*bkg,...
                      'Callback',@undo_Callback,...
                      'Enable','off',...
                      'Position',[227 10 90 22],...
                      'String','Undo',...
                      'Tag','pushbutton_undo')
            uicontrol('Parent',hUip(2),...
                      'BackgroundColor','w',...
                      'Callback',@roi_listbox_Callback,...
                      'ForegroundColor','r',...
                      'Min',0,...
                      'Max',2,...
                      'Position',[10 10 140 240],...
                      'Style','listbox',...
                      'Tag','listbox_rois')
            uicontrol('Parent',hUip(3),...
                      'Callback',@volume_stats_Callback,...
                      'Position',[123 60 70 22],...
                      'String','Use VOI',...
                      'Style','checkbox',...
                      'Tag','checkbox_use_voi',...
                      'Value',false)
            uicontrol('Parent',hUip(2),...
                      'BackgroundColor','w',...
                      'ForegroundColor','r',...
                      'Position',[40 265 90 20],...
                      'String',{'ROI','Mask','Noise'},...
                      'Style','PopupMenu',...
                      'Tag','popupmenu_roi_tag',...
                      'Visible','on')
            uicontrol('Parent',hUip(3),...
                      'BackgroundColor','w',...
                      'Callback',@stats_change_Callback,...
                      'ForegroundColor','r',...
                      'Position',[56 10 100 20],...
                      'String',{'Image'},...
                      'Style','PopupMenu',...
                      'Tag','popupmenu_stats',...
                      'Visible','on')];

    % Prepare statistics displays and ROI tag text
            uicontrol('Parent',hUip(4),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_mean');
            uicontrol('Parent',hUip(5),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_median');
            uicontrol('Parent',hUip(6),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_stddev');
            uicontrol('Parent',hUip(7),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_snr');
            uicontrol('Parent',hUip(8),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_area');
            uicontrol('Parent',hUip(9),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_nan_ratio');
            uicontrol('Parent',hUip(10),...
                      'Enable','on',...
                      'Position',[10 11 70 20],...
                      'Style','text',...
                      'Tag','text_kurtosis');
            uicontrol('Parent',hUip(2),...
                      'Enable','on',...
                      'HorizontalAlignment','Left',...
                      'Position',[10 262 30 20],...
                      'String','Tag:',...
                      'Style','text',...
                      'Tag','text_roi_tag');

    drawnow;

    % Attach some property listeners to ensure that the listbox (and associated)
    % UI control(s) is updated appropriately
    hList = findobj(hQt,'Tag','listbox_rois');
    addlistener(hList,'String', 'PostSet',@listbox_string_postset);  %listbox_rois
    addlistener(hList,'Visible','PostSet',@listbox_visible_postset); %listbox_rois

    % Attach some property listeners to ensure that the ROI tag pop-up menu (and
    % associated) UI control(s) is(are) updated appropriately
    hPop = findobj(hQt,'Tag','popupmenu_roi_tag');
    addlistener(hPop,'Value','PostSet',@popupmenu_roi_tag_value_postset);

end %roi_tools



%-----------------------Callback/Ancillary Functions----------------------------

%------------------------------------
function roi_listbox_Callback(hObj,~)
    obj                     = getappdata(gcbf,'qtExamObject');
    obj.roiIdx.(obj.roiTag) = get(hObj,'Value');
end %roi_listbox_Callback

function clone_roi_Callback(hObj,eventdata) %#ok<*INUSD>

    % Get some necessary data
    hFig  = guifigure(hObj);
    obj   = getappdata(hFig,'qtExamObject');
    if (length(obj.roiIdx)>1)
        errordlg('Can clone only one label at a time.');
        return
    end

    % Prompts user for name of new contour
    [cName,ok] = cine_dlgs('contour_name');
    if ~ok
        return
    end
    if any( strcmpi(cName,obj.roiNames) )
        errordlg('The new contour name must be unique.');
        return
    end

    % Clone the ROI objects of the current index
    roiTag          = obj.roiTag;
    rois            = obj.rois.(roiTag)(obj.roiIdx.(roiTag),:,:);
    rois            = rois.clone('scale','tag');
    [rois(:).name]  = deal(cName);
    [rois(:).state] = deal('off'); %no need to show the ROIs immediately
    rois            = permute(rois,[2 3 1]); %ensure index 1/2 is slice/series

    % Loop through each of the ROIs slice/series index and store valid,
    % non-empty, qt_roi objects
    mRoi = size(rois); %since only a single ROI index selection is supported,
                       %there is no loss of generality in looping through only
                       %the slice and series indices
    for slIdx = 1:mRoi(1)
        for seIdx = 1:mRoi(2)
            if rois(slIdx,seIdx).validaterois
                obj.addroi(rois(slIdx,seIdx),'slice',slIdx,'series',seIdx);
            end
        end
    end

    % Notify the QT_EXAM object of the change
    notify(obj,'roiChanged');

end %clone_roi_Callback

function stats_change_Callback(hObj,eventdata)

    % Get current value
    val = get(hObj,'Value');
    if val==getappdata(hObj,'currentvalue')
        return
    end

    % Get exams object
    obj = getappdata( guifigure(hObj), 'qtExamObject' );

    % Calculate new stats and update app data
    setappdata(hObj,'currentvalue',val);
    obj.calc_stats;

end %stats_change_Callback

function volume_stats_Callback(hObj,eventdata)

    % Get new VOI data and calculate stats
    obj = getappdata(hQt,'qtExamObject'); obj.calc_stats;

    % Set text for "area" panel
    set(findobj(hQt,'Tag','uipanel_area'),'Title','Volume (pix.)');

end %volume_stats_Callback