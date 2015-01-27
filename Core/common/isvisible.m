function tf = isvisible(h)
%isvisible  Determines if an HGO is visible
%
%   tf = isvisible(h) returns true if 'Visible' property of the HGO object,
%   h, is currently 'On' and false otherwise. h can also be an array of
%   HGOs.

    % Deal output
    tf = false( size(h) );

    if (verLessThan('matlab','8.4.0') && any( ~ishandle(h) )) ||...
       (~verLessThan('matlab','8.4.0') && any( ~isvalid(h) ))
        return
    end

    % Determine output
    if numel(h) == 1
        tf = strcmpi(get(h,'Visible'), 'on');
    else
        tf = cellfun(@(x) strcmpi(x,'on'), get(h,'Visible'));
    end

end %isvisible