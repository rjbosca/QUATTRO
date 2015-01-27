function qim_update_options(src,eventdata)
%qim_update_options  Modeling GUI PostSet event handler for "guess", "autoGuess"
%
%   qim_update_options(SRC,EVENT)

    % Grab the modeling object
    obj = eventdata.AffectedObject;
    if isempty(obj.hFig) || ~ishandle(obj.hFig)
        return
    end

    % Find the parameter options table
    hTable = findobj(obj.hFig,'Tag','table_parameter_options');
    if isempty(hTable)
        return
    end

    % Grab the table data from the specified new property and update according to
    % the new value
    data = get(hTable,'Data');
    if any( strcmpi(src.Name,{'guess','autoGuess','bounds'}) )
        data(:,1)       = num2cell(obj.guess);
        data(:,2:end-1) = num2cell(obj.bounds);
    else
        error('qt_models:update_options:invalidCaller','%s %s %s, %s.',...
              'Only PostSet calls to',mfilename,'from "autoGuess", "guess"',...
              'and "bounds" are allowed');
    end
    set(hTable,'Data',data);

end %qim_update_options