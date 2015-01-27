function tf = check_singleton(parent,prop,val)
%check_singleton  Checks for an existing figure
%
%   TF = check_singleton(PARENT,PROPERTY,VALUE) attempts to find any children of
%   the handle object PARENT with property/value pairs matching those specified
%   by PROPERTY/VALUE, returning true (and changing focus) if a matching figure
%   is found.

    tf = false; %initialize

    % Try to find the handle to the figure
    h = findall(parent,prop,val);
    if isempty(h) || (verLessThan('matlab','8.4.0') && ~ishandle(h)) ||...
                            (~verLessThan('matlab','8.4.0') && ~isvalid(h))
        return
    elseif (numel(h)>1)
        error(['QUATTRO:' mfilename ':tooManyHgos'],...
               'More than one handle was found...');
    end

    % A handle has been found. Attempt to compare the properties specified by
    % the user to those found
    handleProp = get(h,prop);
    switch class(handleProp)
        case 'char'
            tf = any( strcmpi(val,handleProp) );
        otherwise
            error(['QUATTRO:' mfilename ':unsupportedData'],...
                   'Data of type %s is unsupported.',class(handleProp));
    end

    % Refocus MATLAB
    if tf
        figure(h);
    end

end %check_singleton