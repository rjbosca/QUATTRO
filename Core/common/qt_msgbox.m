function h = qt_msgbox(varargin)
%qt_msgbox  QUATTRO wrapper for msgbox
%
%   H = qt_msgbox(...) creates a message box using the inputs to the built-in
%   MATLAB function MSGBOX using the default QUATTRO GUI settings, returning the
%   figure handle H. For more information on appropriate inputs, type "help
%   msgbox"
%
%   See also msgbox

    % Wrap the user's input
    h = msgbox(varargin{:});

    % Update the figure settings
    set(h,'Color',[93 93 93]/255);
    add_logo(h);

end %qt_msgbox