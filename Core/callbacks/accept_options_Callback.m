function accept_options_Callback(hObj,~)
%accept_options_Callback  Callback for handling option acception requests
%
%   accept_options_Callback(H,EVENT)

    % Update options
    hFig = guifigure(hObj);
    obj  = getappdata(hFig,'qtOptsObject');
    hs   = guihandles(hFig);

    % For each option, update the field
    for opt = fieldnames(hs)'

        % Ignore non-option UI controls
        if ~isprop(obj,opt{1})
            continue
        end

        % Grab the option according to the type of UI control
        switch lower( get(hs.(opt{1}),'Style') )
            case {'popupmenu','checkbox'}
                val = get(hs.( opt{1} ),'Value');
            case {'edit'}
                val = str2double( get(hs.( opt{1} ),'String') );
        end

        % For model pop-up menus, the model string must be determined
        if strcmpi(get(hs.(opt{1}),'Style'),'popupmenu')
            modelIdx = strfind(opt{1},'Model');
            if ~isempty(modelIdx)
                mClasses = meta.package.fromName(...
                                     qt_models.model2str(opt{1}(1:modelIdx-1)));
                val      = strrep(mClasses.ClassList(val).Name,...
                                                        [mClasses.Name '.'],'');
            end
        end

        % Update the option
        obj.(opt{1}) = val;
    end

    % Update user options (parallel comps and exam type)
    if strcmpi( get(hFig,'Name'),'QUATTRO Options' )

        % Attempt to disable/enable parallel computation
        obj        = getappdata(hFig,'qtOptsObject');
        [isPar,nS] = is_par; %check for parallel comp. support
        n          = obj.nProcessors;
        if isPar && obj.parallel && (n>1) && (nS~=n)
            if (matlabpool('size')>0)
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