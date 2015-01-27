function update_slice_context_menus(h)
%update_slice_context_menus  Creates ROI listbox "Go To"->"On Slice" menus
%
%   update_slice_context_menus(H) generates the "Go To" -> "On Slice" UI context
%   menus associated with an ROI listbox given by the handle H in QUATTRO
%   applications. All previous menus are deleted.

    % Validate the handle
    if ~ishandle(h)
        warning(['QUATTRO:' mfilename ':invalidHandle'],...
                              'Invalid handle. No context menus were created.');
        return
    elseif ~strcmpi(get(h,'Style'),'listbox')
        error(['QUATTRO:' mfilename ':invalidListHandle'],...
                                                     'Invalid listbox handle.');
    end

    % Grab the figure and qt_exam object
    hFig = guifigure(h);
    hs   = guihandles(hFig);
    obj  = getappdata(hFig,'qtExamObject');

    % Get the ROI context menu from the listbox in question. This ensures that a
    % context menu from a differnt listbox is not grabbed automatically
    hContext = findobj(get(h,'UIContextMenu'),'Tag','context_go2roi_slice');

    % Before proceeding, delete any previous children
    delete( get(hContext,'Children') );

    % Find the slices on which ROIs exist
    rois         = obj.rois.(obj.roiTag);
    idx          = get(hs.listbox_rois,'Value');
    validRois    = rois(idx,:,:).validaterois;
    validRoiInds = find( any( any( any(validRois,2), 3), 4) );

    % Determine the slice locations for each valid ROI that is selected
    allSlIdx = cell(1,numel(validRoiInds));
    allSeIdx = cell(1,numel(validRoiInds));
    for rIdx = validRoiInds(:)'

        % Grab the current, valid ROI indices
        validRoisSub = shiftdim( validRois(rIdx,:,:,:), 1 );

        % Determine which slices/series this ROI is on
        [allSlIdx{rIdx},allSeIdx{rIdx}] = find( any(validRoisSub, 3) );

    end

    % Convert the slice/series indices into vectors
    allSlIdx       = [ allSlIdx{:} ]';
    allSeIdx       = [ allSeIdx{:} ]';

    % Loop through each slice, using the smallest series index
    for slIdx = unique(allSlIdx(:))'

        % Determine the series index
        seIdx = min( allSeIdx(allSlIdx==slIdx) );

        % Create the callback function
        fcns = {@() set(hs.slider_slice,'Value',slIdx),...
                @() slider_Callback(hs.slider_slice,[]),...
                @() set(hs.slider_series,'Value',seIdx),...
                @() slider_Callback(hs.slider_series,[])};

        % Attach the new sub-menu
        uimenu('Parent',hContext,...
               'Label',num2str(slIdx),...
               'Callback',@(h,ed) cellfun(@(x) feval(x),fcns));
    end

end %update_slice_context_menus