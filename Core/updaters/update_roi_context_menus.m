function update_roi_context_menus(hList,obj)
%update_roi_context_menus  Updates ROI associated context menus
%
%   update_roi_context_menus(H) updates all ROI context menus for the ROI
%   listbox specified by the handle H.
%
%   update_roi_context_menus(H,OBJ) performs the same operation using the
%   QT_EXAM object OBJ. This syntax will run faster as the QUATTRO figure handle
%   and exam object will not need to be found

    %TODO: this function is being called twice when creating an ROI. WHY???

    % Catch an array of listbox handles
    %TODO: I'm not sure why this is here. I was planning something at some
    %point, but whatever it was it doesn't seem to be part of the plan any more.
    if (numel(hList)>1)
        arrayfun(@(x) create_order_context_menus(x,obj),hList);
        return
    end

    % Grab the handles structure
    hs = guidata(hList);

    % Parse and validate the input(s)
    if (nargin==1)
        obj  = getappdata(hs.figure_main,'qtExamObject');
    end
    if ~strcmpi( get(hList,'Type'), 'uicontrol' ) ||...
            ~strcmpi( get(hList,'Style'), 'listbox' )
        error(['QUATTRO:' mfilename ':invalidObjectHandle'],...
              ['The provided handle must be a UI control with a value of ',...
               '''listbox'' for the ''Style'' property.']);
    elseif ~strcmpi( get(hList,'Tag'), 'listbox_rois' )
        warning(['QUATTRO:' mfilename ':unknownListbox'],...
                ['An unexpected signature for the listbox handle was ',...
                 'detected. The listbox should correspond to QUATTRO''s ROI ',...
                 'listbox, otherwise unanticipated results may occur.']);
    end

    % Enable/disable the appropriate menus
    hContext = get(hs.listbox_rois,'UIContextMenu');
    hKids    = get(hContext,'Children');
    hKids    = hKids( ~strcmpi('context_order',get(hKids,'Tag')) ); %this tag is
                                                                    %handled in the 
                                                                    %string PostSet
    isRoisSelected = any(obj.roiIdx.(obj.roiTag));

    % Update the a couple of context menus
    set(hKids,'Enable','off'); %disable all controls by default
    if isRoisSelected

        set(hKids,'Enable','on');
        
        % "Go To" slice context menu updates
        update_slice_context_menus(hs,obj);

        % "Order" context menu updates
        update_order_context_menus(hs,obj);

    end


end %update_roi_context_menus

%------------------------------------------
function update_slice_context_menus(hs,obj)
%update_slice_context_menus  Creates ROI listbox "Go To"->"On Slice" menus
%
%   update_slice_context_menus(HS,OBJ) generates the "Go To" -> "On Slice" UI
%   context menus associated with an ROI listbox, where HS is the QUATTRO
%   handles structure and OBJ is the corresopnding QT_EXAM object.

    % Before proceeding, delete any previous children
    delete( get(hs.context_go2roi_slice,'Children') );

    % Find the slices on which ROIs exist
    rois         = obj.rois.(obj.roiTag);
    idx          = obj.roiIdx.(obj.roiTag);
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
        uimenu('Parent',hs.context_go2roi_slice,...
               'Label',num2str(slIdx),...
               'Callback',@(hObj,ed) cellfun(@(x) feval(x),fcns));
    end

end %update_slice_context_menus

%------------------------------------------
function update_order_context_menus(hs,obj)
%update_order_context_menus  Creates ROI listbox "Order" menus
%
%   update_order_context_menus(HS,OBJ) generates the "Order" UI context menu
%   associated with an ROI listbox, where HS is the QUATTRO handles structure
%   and OBJ is the corresopnding QT_EXAM object.

    % Grab the figure and qt_exam object
    rIdx = obj.roiIdx.(obj.roiTag);
    rStr = obj.roiNames.(obj.roiTag);
    nRoi = numel(rStr);

    % Ensure the "Order" and associated sub-menus are enabled
    set([hs.context_up hs.context_down hs.context_order],'Enable','on');

    % There are four cases to handle: (1) this is the first ROI in the list
    % ("Up" is disabled), (2) his is the last ROI in the list ("Down") is
    % disabled, (3) both the irst and last ROI in the list are selected (the
    % "Order" menu must be disabled), (4) the ROI is in the middle of the stack
    % ("Up" and "Down" are enabled). The fourth case is handled implicitly by
    % enabling all context menus
    if (nRoi<2)
        set(hs.context_order,'Enable','off');
    elseif any(rIdx==1)
        set(hs.context_up,'Enable','off');
    elseif any(rIdx==nRoi)
        set(hs.context_down,'Enable','off');
    end

end %update_order_context_menus 