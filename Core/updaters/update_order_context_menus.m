function update_order_context_menus(h)
%update_order_context_menus  Creates ROI listbox "Order" menus
%
%   update_order_context_menus(H) generates the "Order" UI context menu
%   associated with an ROI listbox given by the handle H in QUATTRO
%   applications. All previous menus are deleted during this operation.

% Catch an array of listbox handles
if numel(h)>1
    arrayfun(@create_order_context_menus,h);
    return
end

% Validate the handle
if ~ishandle(h)
    warning(['QUATTRO:' mfilename ':invalidHandle'],...
                              'Invalid handle. No context menus were created.');
elseif ~strcmpi(get(h,'Style'),'listbox')
    error(['QUATTRO:' mfilename ':invalidListHandle'],...
                                                     'Invalid listbox handle.');
end

% Grab the figure and qt_exam object
rIdx = get(h,'Value');
rStr = get(h,'String');
nRoi = numel(rStr);

% Get the handles structure
hUp    = findobj(get(h,'UIcontext'),'Tag','context_up');
hDown  = findobj(get(h,'UIcontext'),'Tag','context_down');
hOrder = findobj(get(h,'UIcontext'),'Tag','context_order');

% Ensure the "Order" menu is enabled
set(hOrder,'Enable','on');

% Enable both context menus (disabling will occur later)
set([hUp hDown],'Enable','on');

% There are four cases to handle: (1) this is the first ROI in the list ("Up"
% is disabled), (2) his is the last ROI in the list ("Down") is disabled, (3)
% both the irst and last ROI in the list are selected (the "Order" menu must be
% disabled), (4) the ROI is in the middle of the stack ("Up" and "Down" are
% enabled). The fourth case is handled implicitly when enabling all context
% menus
if any(rIdx==1) && any(rIdx==nRoi)
    set(hOrder,'Enable','off');
elseif any(rIdx==1)
    set(hUp,'Enable','off');
elseif any(rIdx==nRoi)
    set(hDown,'Enable','off');
end