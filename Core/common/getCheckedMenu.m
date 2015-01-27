function hgos = getCheckedMenu(obj)
%getCheckedMenu  Return the handles of all sub menus that are checked.
%
%   hgos = getCheckedMenu(H) finds all checked children menus of H and
%   returns their handles in the array hgos.

    % ERROR CHECK: (1) obj must be a valid HGO
    if (verLessThan('matlab','8.4.0') && ~ishandle(obj)) ||...
                          (~verLessThan('matlab','8.4.0') && ~isvalid(obj))
        error(['QUATTRO:' mfilename ':handleChk'],'Invalid handle object.');
    end

    % Gets all children of PARENTMENU
    hgos = get(obj, 'Children');

    % ERROR CHECK: (1) PARENTMENU must have children
    if isempty(hgos)
        error(['QUATTRO:' mfilename ':childChk'],'Handle object has no children.');
    end

    % Determines which child is checked
    selection = get(hgos,'Checked');

    % Store output
    hgos = hgos(strcmpi('on',selection));

end %getCheckedMenu