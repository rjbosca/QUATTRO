function h = guifigure(h)
%guifigure  Returns the parent figure associated with a GUI HGO
%
%   FIG = guifigure(H) returns the parent figure FIG associated with the
%   specified child HGO H. Note that this function is similar to MATLAB's gcbf,
%   but allows the parent figure of an HGO to be found even if the UI's callback
%   was called directly (as opposed to being fired when the UI is activated)

while ~isempty(h) && ~strcmp('figure',get(h,'Type'))
     h = get(h,'Parent');
end