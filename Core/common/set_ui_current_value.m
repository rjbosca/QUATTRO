function set_ui_current_value(h)
%set_ui_current_value  Stores the "currentvalue" application data
%
%   set_ui_current_value(H) stores the application data "currentvalue" for the
%   UI control (or figure children UI controls) specified by the handle H. H can
%   also be an array of handles.

    % For figures, grab the handles structure
    if strcmpi( get(h,'Type'), 'figure' )
        hFig = h; %cache the figure, to be removed since guihandles insists on
                  %placing the figure handle in the structure
        h    = struct2array( guihandles(h) );
        h    = h(h~=hFig);
    end

    % Catch arrays of handles, sending the constituents through
    % set_ui_current_value one at a time via arrayfun
    if (numel(h)>1)
        arrayfun(@set_ui_current_value,h);
        return
    end

    % Attempt to update the application data
    try

        % Validate that the UI control is useable
        uiStyle = get(h,'Style');
        validatestring(uiStyle,{'listbox','popupmenu','slider','edit'});

        % Update the value according the appropriate property
        if strcmpi(uiStyle,'edit')
            setappdata(h, 'currentvalue', str2double(get(h,'String')) );
        else
            setappdata(h, 'currentvalue', get(h,'Value') );
        end

    catch ME

        % For speed, the above code does not verify that "Style" is a valid
        % property of the given UI control. Additionally, validatestring will
        % also throw errors if "Style" does not match one of the specified
        % strings. Rethrow the error if neither of these caused it
        validErrs = {'MATLAB:class:InvalidProperty',...
                     'MATLAB:unrecognizedStringChoice',...
                     'MATLAB:hg:InvalidProperty'};
        if ~any( strcmpi(ME.identifier,validErrs) )
            rethrow(ME)
        end

    end

end %set_ui_current_value