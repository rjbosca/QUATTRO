function updatelimits(src,eventdata) %#ok
%updatelimits  Event handler for updating display limits of imgview objects
%
%   updatelimits(H,EVENT) updates the imgview object specified by the handle H

% Get the updated limits
xl = src.imgObj.xlim;
yl = src.imgObj.ylim;

% Update the text limits
if ~isempty(src.hText)
    x = 0.02*diff(xl)+xl(1);
    y = 0.98*diff(yl)+yl(1);
    set(src.hText,'Position',[x y]);
end