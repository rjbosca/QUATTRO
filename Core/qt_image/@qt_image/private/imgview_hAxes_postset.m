function imgview_hAxes_postset(obj,src,eventdata)
%imgview_hAxes_postset  PostSet event for imgview "hAxes" property
%
%   imgview_hAxes_postset(OBJ,SRC,EVENT) updates the imgview object specified by
%   the 

    % Validate the source
    if ~strcmpi(src.Name,'hAxes')
        error(['qt_image:' mfilename ':invalidEventCall'],...
              ['Only "hAxes" PostSet imgview event calls to ',...
               '"%s" are allowed.'],mfilename);
    end

    % Get the image view object, the actual image data, size of the image, and
    % determine if the image data represent RGB values
    viewObj = eventdata.AffectedObject;
    img     = obj.value;
    m       = size(img);
    isRGB   = (numel(m)>2) && any(m(3:end)>1);
    if (prod(m)==0)
        return
    end

    % Get the image color limits
    switch obj.wwwlMode
        case 'axis'
            clims = get(viewObj.hAxes,'CLim');
        case 'immean'
            ww    = mean( img( img~=0 & ~isnan(img) & ~isinf(img) ) );
            clims = (ww*[0 1]);
        case 'internal'
            clims = obj.wl + obj.ww/2*[-1 1];
    end

    % Perform real color conversion if requested and if the image is not already
    % in true color format
    if viewObj.isRgb && ~isRGB
        nColors = 256;

        % Update the WW/WL by resetting all values above the color limit max to
        % the max and all values below the minimum to the min
        img               = double(img);
        img(img<clims(1)) = clims(1);
        img(img>clims(2)) = clims(2);

        % Normalize the image according to the color limits
        img   = uint16( nColors*(img-clims(1))/diff(clims) );
        imMap = eval([obj.color, '(nColors)']);
        img   = ind2rgb(img,imMap);

    end

    % Grab the figure's associated data cursor, pan, and zoom mode objects
    hFig  = viewObj.hFig;
    hData = datacursormode(hFig);
    hPan  = pan(hFig);
    hZoom = zoom(hFig);

    % Determine if an image of the same type already exists. This method of
    % updating the 'CData' in lieu of re-showing image data on the same axis
    % provides a more seamless transition
    if isempty(viewObj.hImg) %show image data on an axis with no images or
                             %replace any existing images

        % Delete any previous image objects on the specified axes
        delete( findobj(viewObj.hAxes,'Tag',obj.tag) );

        %Show the image
        axTag        = get(viewObj.hAxes,'Tag'); %cache the tag, you'll see why
        viewObj.hImg = imshow(img,'Parent',viewObj.hAxes);
        set(viewObj.hImg, 'Tag',obj.tag);
        set(viewObj.hAxes,'NextPlot','Add',...
                          'Tag',axTag,...imshow resets the axis tag. Why???!!!
                          'XLim',[0 m(2)]+0.5,...
                          'XLimMode','manual',...
                          'YLim',[0 m(1)]+0.5,...
                          'YLimMode','manual',...
                          'DataAspectRatioMode','manual',...
                          'PlotBoxAspectRatioMode','manual',...
                          'PlotBoxAspectRatio',[512 512 1]);

    else %overwrite previous image data
        % Grab the data cursor info
        cursorInfo = hData.getCursorInfo;

        % Store the new image data
        set(viewObj.hImg,'CData',img);
    end

    % "CDataMapping" must be updated for all images to ensure that the colorbar
    % displays the correct information
    set(viewObj.hImg,'CDataMapping','scaled');

    % Update the axis color map for non-RGB images
    if ~viewObj.isRgb
        colormap(viewObj.hAxes,obj.color); %regardless of the image update
    end

    % Update the image transparency. Create a NaN mask to avoid computations
    % (these values are completely transparent on indexed image overlays)
    alpha = any( ~isnan(img), 3 );
    if obj.transparency && ~viewObj.isRgb && any(~alpha(:))
        set(viewObj.hImg,'AlphaData',obj.transparency*alpha);
    end

    % Determine the zoom state
    viewObj.isZoomed = viewObj.zoomStatus;

    % Determine data cursor, zoom, and pan mode states. When these modes are
    % active, figure button callbacks cannot be set, so this mode must be
    % disabled and re-enabled.
    isDataCursorMode = strcmpi(hData.Enable,'on');
    if isDataCursorMode
        hData.Enable = 'off';
    end
    isPanMode        = strcmpi(hPan.Enable,'on');
    if isPanMode
        hPan.Enable  = 'off';
    end
    isZoomMode       = strcmpi(hZoom.Enable,'on');
    if isZoomMode
        hZoom.Enable = 'off';
    end

    % Set the color limits and the delete function. Because multiple images
    % (i.e. color overlays) can exist on a single axis, use the iptaddcallback
    % function to ensure that the imgview object is always deleted when the axis
    % is destroyed
    if ~isempty(viewObj.deleteFcnIdx) %remove previous delete functions
        iptremovecallback(viewObj.hAxes,'DeleteFcn',viewObj.deleteFcnIdx);
    end
    viewObj.deleteFcnIdx =...
            iptaddcallback(viewObj.hAxes,'DeleteFcn',@(h,event) viewObj.delete);

    % Set the WW/WL functionality and color limits(only for indexed images)
    if ~viewObj.isRgb
        % Only update color limits for non-true color images
        set(viewObj.hAxes,'CLim',sort(clims));

        % WW/WL on-the-fly modification is handled by the figure. Ultimately,
        % the object properties are set during calls to the button up function
        viewObj.btnFcnIdx(1) = iptaddcallback(viewObj.hFig,...
                              'WindowButtonDownFcn',@image_button_down_fcn);
        viewObj.btnFcnIdx(2) = iptaddcallback(viewObj.hFig,...
                              'WindowButtonMotionFcn',@image_button_motion_fcn);
        viewObj.btnFcnIdx(3) = iptaddcallback(viewObj.hFig,...
                              'WindowButtonUpFcn',@image_button_up_fcn);
    end

    % Define some listeners to ensure zoom and pan operations perform correctly.
    % Cache these listeners to be deleted during object destruction, otherwise
    % they will pile up causing numerous calls to deleted imgview objects
    viewObj.listeners = addlistener(viewObj.hAxes,'XLim',...
                                          'PostSet',@viewObj.axes_xlim_postset);
    viewObj.listeners = addlistener(viewObj.hAxes,'YLim',...
                                          'PostSet',@viewObj.axes_ylim_postset);

    % Define the debugging listeners
    if obj.isDebug
        viewObj.listeners = addlistener(viewObj.hFig, 'WindowButtonDownFcn',...
                                            'PostSet',@windowbtndown_postset);
        viewObj.listeners = addlistener(viewObj.hFig, 'WindowButtonMotionFcn',...
                                            'PostSet',@windowbtnmotion_postset);
        viewObj.listeners = addlistener(viewObj.hFig, 'WindowButtonUpFcn',...
                                            'PostSet',@windowbtnup_postset);
    end

    % Considerations for the data cursor mode: (1) re-create any data tips that
    % were destroyed when changing views and (2) re-enable the data cursor mode
    if exist('cursorInfo','var') && ~isempty(cursorInfo)
        hDataTip = hData.createDatatip(cursorInfo.Target,cursorInfo);
        update(hDataTip,cursorInfo.Position); %update the position    
    end
    if isDataCursorMode
        hData.Enable = 'on';
    end
    if isPanMode
        hPan.Enable  = 'on';
    end
    if isZoomMode
        hZoom.Enable = 'on';
    end

    % Cache the attached QT_IMAGE object in the figure's application data so we
    % can fire events if needed (e.g., if displaying a new image on the same
    % axis). Also, as a convenience, cache the qt_image object in the axis'
    % image object. This must be done before creating the on-image context
    % menus, since the contructors require data from the object's properties
    if strcmpi(viewObj.imgObj.tag,'image')
        setappdata(hFig,'qtImgObject',viewObj.imgObj);
    else
        setappdata(hFig,'qtMapObject',viewObj.imgObj);
    end
    setappdata(viewObj.hImg,'imgObject',viewObj.imgObj);

    %TODO: currently, QUATTRO supports visualization of images (tag: 'image')
    %and parameter map overlays (tag: variable). As these capabilities expand,
    %the application data defined in the above manner will need to be updated to
    %include additional tags

    % Create a context menu on the image if they don't already exist
    %TODO: the image context menus currently consist of a few WW/WL controls
    %that are irrelevant on RGB images. However, in the future, this will likely
    %change. Therefore, this "if" statement needs to be removed and placed
    %within the function that creates the menus
    if ~viewObj.isRgb && (ndims(img)==2) &&...
                                      isempty(get(viewObj.hImg,'UIContextMenu'))
        img_context_menus(viewObj.hImg);
    end

    % Finally, notify the imgview object that new text needs to be displayed
    notify(viewObj,'newText');

end %qt_image.imgview_hAxes_postset