function tf = isNewSelection(h_parent, new_obj)
%ISNEWSELECTION  Determines if a new sub-menu element is selected
%   tf = isNewSelection(H,OBJ) determines, for single selection sub-menus,
%   if the object OBJ is newly selected, and updates the selection.

tf = false;

% Selection has changed if more than on menu is selected
old_obj = getCheckedMenu(h_parent);
if isempty(old_obj) || (new_obj==old_obj)
    return
end

% Update submenu
set(old_obj, 'Checked', 'off');
set(new_obj, 'Checked', 'on');

% Returns that the menu selection has been updated
tf = true;