function update_slice_context_menus(hList,obj)
%update_slice_context_menus  Creates ROI listbox "Go To"->"On Slice" menus
%
%   update_slice_context_menus(H) generates the "Go To" -> "On Slice" UI context
%   menus associated with an ROI listbox given by the handle H. All previous
%   menus are deleted during this operation.
%
%   update_slice_context_menus(H,OBJ) performs the same operation, but uses the
%   QT_EXAM object OBJ. This syntax will run faster as the QUATTRO figure handle
%   and exam object will not need to be found

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use "update_roi_context_menus" instead.'],mfilename);

    % Fire the new function
    if (nargin>1)
        update_roi_context_menus(hList,obj);
    else
        update_roi_context_menus(hList);
    end

end %update_slice_context_menus