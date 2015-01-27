function accept_options_Callback(hObj,eventdata) %#ok
%accept_options_Callback  Callback for handling option acception requests
%
%   accept_options_Callback(H,EVENT)

    % Update options
    hFig = guifigure(hObj);
    obj  = getappdata(hFig,'qtExamObject');
    hs   = guihandles(hFig);

    % Update the qt_options object for each option handled by the current option
    % GUI. All options GUI use the "optionNames" application data for storing
    % the necessary options name
    optNames = getappdata(hFig,'optionNames');

    % For each option, update the field
    for optIdx = 1:length(optNames)
        if ~isfield(hs,optNames{optIdx})
            continue
        end
        switch optNames{optIdx}
            case fixed_val_flds
                val = get(hs.( optNames{optIdx} ),'Value');
            case {'loadDir','saveDir','importDir'}
                continue
            otherwise
                val = str2double( get(hs.( optNames{optIdx} ),'String') );
        end

        obj.opts.( optNames{optIdx} ) = val;
    end

    % Update user options (parallel comps and exam type)
    if strcmpi( get(hFig,'Name'),'QUATTRO Options' )

        % Attempt to disable/enable parallel computation
        obj        = getappdata(hFig,'qtOptsObject');
        [isPar,nS] = is_par; %check for parallel comp. support
        n          = obj.nProcessors;
        if isPar && obj.parallel && (n>1) && (nS~=n)
            if matlabpool('size')>0
                matlabpool('close');
            end
            matlabpool(n);
        elseif isPar && ~obj.parallel && (nS>0) 
            matlabpool('close');
        end

    end

    % Delete figure
    delete(hFig);

end %accept_options_Callback