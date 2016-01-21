function tf = qt_abort_set(h,prop)
%qt_abort_set  Abort set for QUATTRO UI controls
%
%   TF = qt_abort_set(H,PROP) tests the value of the property (PROP) specified
%   by the handle H against the application data "currentvalue" returning TRUE
%   if the values are the same and FALSE otherwise

    tf = false; %initialize
    if ~isappdata(h,'currentvalue')
        error(['QUATTRO:' mfilename ':missingAppData'],...
              ['Necessary application data for the UI control with tag "%s" ',...
               'could not be found.'],get(h,'Tag'));
    elseif ~isprop(h,prop)
        error(['QUATTRO:' mfilename ':invalidProperty'],...
              ['PROP must be a string specifying a valid property of the ',...
               'handle H']);
    end

    % Validate the application data
    appData = getappdata(h,'currentvalue');
    propVal = get(h,prop);
    if ~strcmpi( class(appData), class(propVal) )
        error(['QUATTRO:' mfilename ':incommensurateDataTypes'],...
              ['The application data class and handle property class must ',...
               'be the same.']);
    end

    % Determine if the values are the same
    if isnumeric(appData)
        tf = (appData==propVal);
    elseif ischar(appData)
        tf = strcmpi(appData,propVal);
    end

end %qt_abort_set