function roi_listbox_menus(h)
%roi_listbox_menus  Creates menus associated with ROI listboxes
%
%   roi_listbox_menus(H) creates the ROI context menus and associates those
%   menus with the listbox specified by the handle H.

    % Verify input
    if ~ishandle(h) || ~strcmpi(get(h,'Style'),'listbox')
        error(['QUATTRO:' mfilename ':handleChk'],...
            'An invalid handle or handle to an incorrect UI control was provided.');
    end

    % Find QUATTRO figure
    hQt = guifigure(h);

    % Create parent menus
    hCMenu = uicontextmenu('Parent',hQt,...
                           'Tag','uicontextmenu_roi_listbox');
                    uimenu('Parent',hCMenu,...
                           'Callback',@rename_Callback,...
                           'Enable','off',...
                           'Label','Rename',...
                           'Tag','context_rename');
                    uimenu('Parent',hCMenu,...
                           'Callback',@delete_roi_Callback,...
                           'Enable','off',...
                           'Label','Delete',...
                           'Tag','context_delete');
                    uimenu('Parent',hCMenu,...
                           'Enable','off',...
                           'Label','Order',...
                           'Tag','context_order');
                    uimenu('Parent',hCMenu,...
                           'Enable','off',...
                           'Label','Go to ROI',...
                           'Tag','context_go_to_roi');
                    uimenu('Parent',hCMenu,...
                           'Enable','off',...
                           'Label','Analysis',...
                           'Tag','context_analysis');
                    uimenu('Parent',hCMenu,...
                           'Enable','off',...
                           'Label','Use As',...
                           'Tag','context_use_as');
    setappdata(hCMenu,'listboxhandle',h);

    % Create the sub-menus for changing ROI order
    hSMenu = findobj(hCMenu,'Tag','context_order');
    uimenu('Parent',hSMenu,...
           'Callback',@order_roi_Callback,...
           'Label','Up',...
           'Tag','context_up');
    uimenu('Parent',hSMenu,...
           'Callback',@order_roi_Callback,...
           'Label','Down',...
           'Tag','context_down');

    % Create the sub-menus for finding ROIs within the exam
    hSMenu = findobj(hCMenu,'Tag','context_go_to_roi');
    uimenu('Parent',hSMenu,...
           'Callback',@go2roi_Callback,...
           'Label','First',...
           'Tag','context_go2roi_first');
    uimenu('Parent',hSMenu,...
           'Callback',@go2roi_Callback,...
           'Label','Last',...
           'Tag','context_go2roi_last');
    uimenu('Parent',hSMenu,...
           'Label','On Slice',...
           'Tag','context_go2roi_slice');

    % Create the sub-menus for performing analyses with the current ROI
    hSMenu = findobj(hCMenu,'Tag','context_analysis');
    uimenu('Parent',hSMenu,...
           'Callback',identityFcn,...
           'Label','CoM',...
           'Tag','context_com');

    % Create the sub-menus for changing an ROI's tag property
    hSMenu = findobj(hCMenu,'Tag','context_use_as');
    uimenu('Parent',hSMenu,...
           'Callback',@change_roi_tag_Callback,...
           'Label','ROI',...
           'Tag','context_use_as_roi',...
           'Visible','off'); %default ROI tag is "ROIs", so don't display
    uimenu('Parent',hSMenu,...
           'Callback',@change_roi_tag_Callback,...
           'Label','Mask',...
           'Tag','context_use_as_mask');
    uimenu('Parent',hSMenu,...
           'Callback',@change_roi_tag_Callback,...
           'Label','Noise',...
           'Tag','context_use_as_noise');
    uimenu('Parent',hSMenu,...
           'Callback',@change_roi_tag_Callback,...
           'Label','VIF',...
           'Tag','context_use_as_vif',...
           'Visible','off'); %only visible in DCE exams

    % Associate menu
    set(h,'UIContextMenu',hCMenu);

end %roi_listbox_menus


%------------------------------Callback Functions-------------------------------

function change_roi_tag_Callback(hObj,~)

    % Get the menu tag and convert to the field string
    menuTag = get(hObj,'Tag');
    menuTag = lower( strrep(menuTag,'context_use_as_','') );

    % Grab the figure handle, exam object, stack of ROIs, and the current
    % ROI index
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');
    rois = obj.rois.(obj.roiTag);
    idx  = obj.roiIdx.(obj.roiTag);

    % Update the ROIs according 
    [rois(idx,:,:,:).tag] = deal(menuTag); %#ok - the data in "rois" doesn't
                                           %need to be stored because the
                                           %changes will result in the
                                           %execution of a number of
                                           %property listeners 

    % Notify the "roiChanged" event
    notify(obj,'roiChanged');

end %add_remove_vif_Callback

function go2roi_Callback(hObj,~)

    % Get QT_EXAM object
    obj  = getappdata(gcbf,'qtExamObject');

    % Determine caller and listbox
    hList = getappdata( get(get(hObj,'Parent'),'Parent'), 'listboxhandle');
    tag   = lower(get(hObj,'Label'));
    val   = get(hList,'Value');
    if isempty(val)
        warning(['QUATTRO:' mfilename ':noRoiSelected'],'%s\n',...
                            'Could not locate ROI in QUATTRO environment.');
        return
    end

    % Attempt to find on current slice
    rois          = obj.rois.(obj.roiTag)(val,:,:,:);
    validRois     = any(rois.validaterois, 4);
    validRois     = shiftdim(validRois,1); %moves the singleton "ROI"
                                           %dimension to the end
    [slIdx,seIdx] = find(validRois,1,tag);

    % Render display by updating the slice and series index of the current 
    % QT_EXAM object
    obj.sliceIdx  = slIdx;
    obj.seriesIdx = seIdx;

end %go2roi_Callback

function order_roi_Callback(hObj,~)
%order_roi_Callback  Callback for ROI context menus
%
%   order_roi_Callback(H,EVENT) callback for "Down" and "Up" context menus
%   associated with ROI listbox "Order" menus specified by the handle H. Event
%   data, specified by the input EVENT, is unused currently

    % Get ordering direction and move
    hs = guidata(hObj);
    if any(strcmpi(get(hObj,'Label'),{'up','down'}))
        mvDir = lower(get(hObj,'Label'));
        hList = hs.listbox_rois;
    else
        hList = getappdata(get(hObj,'Parent'),'listboxhandle');
        mvDir = strrep(get(hList,'Tag'),'listbox_','');
    end

    % Get the ROI indices in question and create a linear index of values that
    % will be altered using the masks created below to resort the ROIs.
    rIdx   = get(hList,'Value');
    newIdx = 1:numel(get(hList,'String'));

    % Create two masks that will store the location of all ROIs that are not
    % selected, but must be moved to accomodate the location of the ROIs that
    % are being moved.
    [newMask,oldMask] = deal( true(size(newIdx)) );
    oldMask(rIdx)     = false;

    % Move the ROIs according to the specified action
    if strcmpi(mvDir,'down')

        % Ensure that the new maximum index does not exceed the number of
        % ROIs. If so, perform no action
        if ( (rIdx(end)+1)>newIdx(end) )
            return
        end

        % Increment the ROI indices by +1
        newRIdx = rIdx+1;

    elseif strcmpi(mvDir,'up')

        % Ensure that the new minimum index is not below one (the lowest valid
        % index). If so, perform no action
        if ( (rIdx(1)-1)<1 )
            return
        end

        % Increment the ROI indices by +1
        newRIdx = rIdx-1;

    end

    % Update the "newMask" to represent the new location of all ROIs that are
    % not selected
    newMask(newRIdx) = false;

    % Use masks to linearly fill the new index locations and store the location
    % of the ROI indices that are being moved
    newIdx(newMask) = newIdx(oldMask);
    newIdx(newRIdx) = rIdx;

    % Store the ROIs
    obj = getappdata(hs.figure_main,'qtExamObject');
    obj.moveroi(newIdx);

    % Update the context menus according to the new data
    %TODO: this runs a lot of other functions. Really, the only thing that needs
    %to be accomplished here is to enable disable the appropriate "Order"
    %context menus
    update_roi_context_menus(hs.listbox_rois);

end %order_Callback

function rename_Callback(hObj,~)

    % Get ROI names
    hList = getappdata(get(hObj,'Parent'),'listboxhandle');
    names = get(hList,'String');
    vals  = get(hList,'Value');

    % Store new name
    [name,ok] = cine_dlgs('roi_label',names{vals(1)});
    if ~ok
        return
    end

    % Get exams object, rename ROI, and update the listbox
    obj            = getappdata(gcbf,'qtExamObject');
    rois           = obj.rois.(obj.roiTag)(vals(1),:,:);
    [rois.name]    = deal(name);
    names{vals(1)} = name;
    set(hList,'String',names);

end %rename_Callback