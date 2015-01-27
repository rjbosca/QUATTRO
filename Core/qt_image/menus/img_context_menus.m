function img_context_menus(hIm)
%img_context_menus  Creates on-image context menus
%
%   img_context_menus(H) generates context menus for modifying the image display
%   on the image specified by the handle H. H must be the child of type 'image'
%   and be a child of an axis object
%
%   Note: any previous context menus existing on the image will be deleted.

    % Validate the input
    if ~strcmpi( get(hIm,'Type'), 'image' )
        error(['qt_image:' mfilename ':invalidImageHandle'],...
               'H must be a handle graphics object of type ''image''.');
    elseif ~strcmpi( get(get(hIm,'Parent'),'Type'), 'axes' )
        error(['qt_image:' mfilename ':invalidParentHandle'],...
               'H must be the descendant of an axis.');
    elseif (numel(hIm)>1)
        error(['qt_image:' mfilename ':tooManyHandles'],...
               'H must be a scalar array of handles.');
    end

    % Delete any pre-existing context menus
    hCmenu = get(hIm,'UIContextMenu');
    if ~isempty(hCmenu) && ishandle(hCmenu)
        delete(hCmenu);
    end

    % Grab the current map object. Since hIm is the handle to an image object,
    % simply grab the 'imgObject' application data since this is generic data
    % (i.e. all image objects store the associated qt_image object as
    % 'imgObject').
    mapObj = getappdata(hIm,'imgObject');

    % To ensure that the context menu is attached to the appropriate HGO, grab
    % the current image's figure
    hFig = guifigure(hIm);
    isQt = ~isempty( getappdata(hFig,'linkedfigure') ) ||...
                                            strcmpi( get(hFig,'Name'), qt_name);

    % Create the parent menus
    hCmenu = uicontextmenu('Parent',hFig,...
                           'Tag','uicontextmenu_image',...
                           'Visible','on');
    hParntWwWl =    uimenu('Parent',hCmenu,...
                           'Enable','on',...
                           'Label','WW/WL Tools',...
                           'Tag','context_ww_wl_tools');
    hAutoWwWl  =   [uimenu('Parent',hParntWwWl,...
                           'Callback',@change_ww_wl_mode_Callback,...
                           'Enable','on',...
                           'Label','Lock WW/WL',...
                           'Tag','context_lock_ww_wl');
                    uimenu('Parent',hParntWwWl,...
                           'Callback',@change_ww_wl_mode_Callback,...
                           'Enable','on',...
                           'Label','Image Mean',...
                           'Tag','context_image_mean_ww_wl')];
                    uimenu('Parent',hParntWwWl,...
                           'Callback',@set_ww_wl_Callback,...
                           'Enable','on',...
                           'Label','Set WW/WL',...
                           'Separator','on',...
                           'Tag','context_set_ww_wl');

    % For the qmaptool, the user should be offered an option to change the
    % colormap
    if (numel( findobj(hFig,'Type','image') )>1)
        hParntCMap = uimenu('Parent',hCmenu,...
                            'Enable','on',...
                            'Label','Colormap',...
                            'Tag','context_colormap');
        clrMaps = {'hsv','hot','cool','bone','copper','gray',...
                                                  'pink','prism','prism','jet'};
        for clrIdx = clrMaps
            hCMap = uimenu('Parent',hParntCMap,...
                           'Callback',@change_colormap_Callback,...
                           'Enable','on',...
                           'Label',clrIdx{1},...
                           'Tag',['context_colormap_' clrIdx{1}]);
            if strcmpi(mapObj.color,clrIdx{1})
                set(hCMap,'Checked','on');
            end
        end

        % Now that the menus have been added, determine what colormap needs to
        % be used according to the "color" property of the qt_image object
        hColor = findobj(hParntCMap,'Tag',['context_colormap_' mapObj.color]);
        set(hColor,'Checked','on');
    end

    % The "Lock WW/WL" menu provides a means of keeping the WW/WL the same while
    % scrolling through imaging volumes/series. During stand-alone execution
    % (the only reason "isQt" would be false) of the qmaptool, there is no
    % syntax for displaying volumes/series of images so there is no need for
    % this tool to be available
    if ~isQt
        set(hAutoWwWl(1),'HandleVisibility','off','Visible','off');
    end

    % In addition to updating the "Lock WW/WL" visibility, the map object must
    % be used to determine if any of the auto WW/WL tools should be checked
    if strcmpi(mapObj.wwwlMode,'axis')
        set(hAutoWwWl(1),'Checked','on');
    elseif strcmpi(mapObj.wwwlMode,'immean')
        set(hAutoWwWl(2),'Checked','on');
    end

    set(hIm,'UIContextMenu',hCmenu);

end


%-----------------------Callback/Ancillary Functions----------------------------

function change_colormap_Callback(hObj,eventdata) %#ok<*INUSD>
%change_colormap_Callback  Callback for changing the image colormap
%
%   change_colormap_Callback(H,EVENT)

    % Determine the current state of the check menu
    isOn  = strcmpi( get(hObj,'Checked'), 'on' );
    hFig  = guifigure(hObj);
    hOpts = findall(hFig,'-regexp','Tag','context_colormap_(\w)');
    set(hOpts,'Checked','off');
    if isOn
        set(hObj,'Checked','off');
    else
        set(hObj,'Checked','on');
    end

    % Determine the color map name from the tag
    tag = strrep(get(hObj,'Tag'),'context_colormap_','');

    % Grab the cached qt_image map object and the exams object from the
    % application data 
    imObj = getappdata(hFig,'qtMapObject');
    obj   = getappdata(hFig,'qtExamObject');

    % Update the "color" property. When an instance of QUATTRO is attached,
    % update all maps so the display doesn't change from slice to slice.
    if ~isempty(obj) && obj.isvalid
        imObj = [obj.maps.(imObj.tag)];
    end
    [imObj(:).color] = deal(tag); %#ok

end %change_colormap_Callback

function change_ww_wl_mode_Callback(hObj,eventdata)
%change_ww_wl_mode_Callback  Callback for locking WW/WL
%
%   change_ww_wl_mode_Callback(H,EVENT)

    % Determine the current state of the check menu
    isOn  = strcmpi( get(hObj,'Checked'), 'on' );
    hFig  = gcbf;
    hOpts = [findobj(hFig,'Tag','context_lock_ww_wl'),...
             findobj(hFig,'Tag','context_image_mean_ww_wl')];
    set(hOpts,'Checked','off'); %disable other checked menus, if any.
    if isOn
        set(hObj,'Checked','off');
    else
        set(hObj,'Checked','on');
    end

    % Determine which string to pass to the image objects to change the WW/WL
    % mode
    tag = 'internal'; %was previously checked; reset the WW/WL
    if ~isOn %was previously unchecked; force the current WW/WL on all images
        switch get(hObj,'Tag')
            case 'context_image_mean_ww_wl'
                tag = 'immean';
            case 'context_lock_ww_wl'
                tag = 'axis';
        end
    end

    % Grab the qt_exam object to be used for setting the WW and WL of all
    % current maps or images. Since maps are displayed only on the qmaptool
    % axes, always check to see if the "qtMapObject" application data exist
    % before looking for the "qtImgObject" since the latter will exist
    % regardless. This ensures that map objects are updated appropriately
    obj    = getappdata(hFig,'qtExamObject');
    imObj  = getappdata(hFig,'qtImgObject');
    mapObj = getappdata(hFig,'qtMapObject');
    if ~isempty(obj) && ~isempty(mapObj)
        imObj = [obj.maps.(mapObj.tag)];
    elseif ~isempty(obj)
        imObj = obj.imgs;
    end

    % Update the "wwwlMode" property
    [imObj(:).wwwlMode] = deal(tag); %#ok

end %change_ww_wl_mode_Callback

function set_ww_wl_Callback(hObj,eventdata)
%set_ww_wl_Callback  Callback for allowing the user to manually modify WW/WL
%
%   set_ww_wl_Callback(H,EVENT)

    % Grab the associated figure handle and disable any "auto" WW/WL calculation
    % options
    hFig  = gcbf;
    hOpts = [findobj(hFig,'Tag','context_lock_ww_wl'),...
             findobj(hFig,'Tag','context_image_mean_ww_wl')];
    set(hOpts,'Checked','off'); %disable other checked menus, if any.

    % Grab the images either from the callback figure. Since this context menu
    % services any arbitrary figure, search for image objects from the top down
    imObj = getappdata(hFig,'qtMapObject');
    if isempty(imObj)
        imObj = getappdata(hFig,'qtImgObject');
    end

    % Determine the current display WW/WL of the image object
    if strcmpi(imObj.wwwlMode,'internal')
        wwWl = {imObj.ww,imObj.wl};
    else
        clims   = get( findobj(hFig,'Tag','axes_main'), 'CLim' );
        wwWl{1} = diff(clims);
        wwWl{2} = min(clims)+wwWl{1}/2;
    end

    % Prompt the user for the new value
    %TODO: perform validiation somewhere
    oldLims = cellfun(@num2str,wwWl,'UniformOutput',false);
    newLims = inputdlg({'New window width:','New window level:'},...
                                                         'New WW/WL',1,oldLims);
    newLims = cellfun(@str2double,newLims);
    if isempty(newLims)
        return
    end

    % Replace NaN values with the originals
    newLims(isnan(newLims)) = [wwWl{isnan(newLims)}];

    % Set the "ww" and "wl" properties of the qt_image object and update the
    % "wwwlMode" property
    [imObj.ww,imObj.wl] = deal(newLims(1),newLims(2));
    imObj.wwwlMode      = 'internal';

end %set_ww_wl_Callback