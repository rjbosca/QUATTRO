function edit_options_Callback(hObj,eventdata) %#ok
%edit_options_Callback  Callback for handling edit text box option changes
%
%   edit_options_Callback(H,EVENT) performs validation on the value of the
%   options edit textbox specified by the handle H. EVENT is an event data
%   object and is currently unused.

    % Get user input and field
    fld = get(hObj,'Tag');
    if isempty( strfind(fld,'_dir') )
        val = str2double( get(hObj,'String') );
    else
        val = get(hObj,'String');
    end

    % Determine if the edit textbox value is valid. All values are expected to
    % be above zero. Also, a NaN indicates that a non-numeric string was
    % provided.
    isValid = ~isnan(val) && (~ischar(val) && val>0);
    if isValid %the value is reasonable, perform some more specific tests
        switch fld
            case 'nProcessors'
                % The number of processors should be greater than 1, but less
                % than the total number of course
                isValid = (val>=1) && (val<=feature('numcores')) && ~isinf(val);
            case {'dceModel','dwModel','multiflipModel','multiteModel'}
                isValid = any(val==1:2) && ~isinf(val);
            case 'hct'
                isValid = (val<=1) && ~isinf(val);
            case {'r2gd','bloodt10'}
                isValid = ~isinf(val);
            case {'loadDir','saveDir','importDir'}
                isValid = exist(val,'dir');
        end
    end

    % Update textbox and options
    if ~isValid
        hs  = guihandles(hObj);
        obj = getappdata(hs.figure_main,'qtOptsObject');
        val = obj.(fld);
    end

    % Set string
    assign_values(hObj,val);

end %edit_options_Callback