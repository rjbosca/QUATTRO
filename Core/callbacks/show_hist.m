function show_hist(hObj,eventdata) %#ok
%show_hist  Updates QUATTRO's histogram window

    % Get object tag
    tag  = get(hObj,'Tag');
    hFig = guifigure(hObj);
    hs   = guihandles(hFig);

    % Get image data
    im = getappdata(hFig,'histogramdata');

    % Determine if the exams object needs to be called
    isIm   = isempty(im);
    isMask = get(hs.checkbox_apply_mask,'Value');
    if isIm || isMask
        obj = getappdata(hFig,'qtExamObject');
    end

    % Determine if a new image needs to be grabbed
    if isIm

        % Get new image data
        if get(hs.popupmenu_data_type,'Value')==1 %show image histogram
            im = double(obj.image.value);
        else %show map histogram
            im = double(obj.map.value);
        end
        setappdata(hFig,'histogramdata',im);

    end

    % Mask the image if necessary
    if isMask
        % Get/apply the current mask
        mask = obj.get_mask;
        if ~isempty(mask)
            im   = im(mask);
        end
    end

    % Get histogram information
    nBins  = str2double(get(hs.edit_n_bins,'String'));
    minVal = str2double(get(hs.edit_minimum,'String'));
    maxVal = str2double(get(hs.edit_maximum,'String'));
    if any(strcmpi(tag,{'figure_main','popupmenu_data_type'})) ||...
                                             any( isinf([minVal maxVal]) )
        % Overwrite infinite values. This is used to initialize the histogram
        % figure values according to new image input info
        minVal = min(im(:));      maxVal = max(im(:));
        minStr = num2str(minVal); maxStr = num2str(maxVal);
        set(hs.edit_minimum,       'String',minStr);
        set(hs.edit_maximum,       'String',maxStr);
        setappdata(hs.edit_minimum,'currentstring',minStr);
        setappdata(hs.edit_maximum,'currentstring',maxStr);
    end

    % Evaluate image info
    im(im<minVal | im>maxVal | isnan(im)) = [];
    hist(hs.axes_main,im(:),nBins);
    set(hs.axes_main,'Tag','axes_main');

end %show_hist