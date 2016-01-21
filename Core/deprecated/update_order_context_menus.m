function update_order_context_menus(hList,obj)
%update_order_context_menus  Creates ROI listbox "Order" menus
%
%   update_order_context_menus(H) generates the "Order" UI context menu
%   associated with the ROI listbox given by the handle H. All previous menus
%   are deleted during this operation.
%
%   update_roi_listbox(H,OBJ) performs the same operation, but uses the QT_EXAM
%   object OBJ. This syntax will run faster as the QUATTRO figure handle and
%   exam object will not need to be found.

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use "update_roi_context_menus" instead.'],mfilename);

    % Fire the new function
    if (nargin>1)
        update_roi_context_menus(hList,obj);
    else
        update_roi_context_menus(hList);
    end

end %update_order_context_menus