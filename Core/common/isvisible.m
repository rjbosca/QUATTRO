function tf = isvisible(h)
%isvisible  Determines if an HGO is visible
%
%   TF = isvisible(H) returns TRUE if 'Visible' property of the HGO object, H,
%   is currently 'On' and FALSE otherwise. H can also be an array of HGOs.

    % Deal output
    tf = false( size(h) );

    if (verLessThan('matlab','8.4.0') && any( ~ishandle(h) )) ||...
       (~verLessThan('matlab','8.4.0') && any( ~isvalid(h) ))
        return
    end

    % Determine the state
    if (numel(h)==1)
        tf = strcmpi(get(h,'Visible'), 'on');
    else
        tf = cellfun(@(x) strcmpi(x,'on'), get(h,'Visible'));
    end

end %isvisible