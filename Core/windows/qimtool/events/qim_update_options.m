function qim_update_options(src,~)
%qim_update_options  Modeling GUI PostSet event handler parameter options
%
%   qim_update_options(SRC,EVENT)

    % Grab the modeling object
    if isempty(src.hFig) || ~ishandle(src.hFig)
        return
    end

    % Find the parameter options table
    hTable = findobj(src.hFig,'Tag','table_parameter_options');
    if isempty(hTable)
        return
    end

    % Initialize the workspace
    data     = get(hTable,'Data');
    nParams  = numel(src.nlinParams);
    pBounds  = cellfun(@(x) src.paramBounds.(x),src.nlinParams,...
                                                         'UniformOutput',false);
    pBounds  = reshape(cell2mat(pBounds),[],nParams)';
    pGuess   = cellfun(@(x) src.paramGuess.(x),src.nlinParams,...
                                                         'UniformOutput',false);
    cEdit    = get(hTable,'ColumnEditable');
    cEdit(1) = ~src.autoGuess;

    % Update the parameter bounds and guesses
    data(:,1)     = pGuess(:);
    data(:,2:end) = num2cell(pBounds);

    % Update the "ColumnEditable" property according to the value of the
    % modeling object's "autoGuess" property
    set(hTable,'ColumnEditable',cEdit);

    % Finally, store the table data
    set(hTable,'Data',data);

end %qim_update_options