function uninstall_QUATTRO(varargin)
%uninstall_QUATTRO  Uninstalls QUATTRO
%
%   uninstall_QUATTRO attempts to remove all components of QUATTRO

    % Find current QUATTRO
    qPath = which('QUATTRO');
    if isempty(qPath)
        qPath = fileparts( mfilename('fullpath') );
        qPath = which('QUATTRO');
    end
    qtStart    = fullfile( fileparts(qPath), 'qt_startup' );
    qtStartOld = fullfile( fileparts(qPath), 'Core', 'common', 'qt_startup' );
    if exist(qtStart,'file')
        run(qtStart); %just in case...
    elseif exist(qtStartOld,'file')
        run(qtStartOld);
    end
    [qPath,fcn] = fileparts(qPath); %#ok<NASGU>
    qPath = strrep(qPath,'''','''''');
    if isempty(qPath) || ~exist(qPath,'dir')
        error(['QUATTRO:' mfilename ':fileChk'],...
               'Unable to locate QUATTRO directories. No actions performed...');
    end

    % Old versions of QUATTRO.m were stored in a sub-directory, remove the top
    % layer
    if ~isempty( strfind(qPath,'Core') ) ||...
                                           ~isempty( strfind(qPath,'gui main') )
        qPath = fileparts(qPath);
    end

    % Prompt the user about removing temporary files and scripts
    qtCfg = fullfile(qt_path('appdata'),'QUATTRO.cfg');
    if exist(qtCfg,'file')
        rmTemp = input('Remove configuration (recommended)? [y|(n)] ','s');
        rmTemp = ~isempty(rmTemp) &&...
                          strcmpi( validatestring(rmTemp,{'yes','no'}), 'yes' );
        if rmTemp
            fid   = fopen('all');
            fList = arrayfun(@fopen,fid,'UniformOutput',false);
                    arrayfun(@fclose,fid( strcmpi(qtCfg,fList) ));
            delete(qtCfg);
        end
    end

    % List of subfolders (this includes older directory format subfolders, just
    % in case...)
    qtParts = {'Core',...
               'Examples',...
               'IO',...
               'Links',...
               'Modeling',...
               'Registration',...
               'Third Party',...
               'gui main',...
               'private (analysis)',...
               'private (ancillary)',...
               'private (common)',...
               'private (dce package)',...
               'private (diffusion package)',...
               'private (dsc package)',...
               'private (import)',...
               'private (registration)',...
               'private (relaxometry package)',...
               'private (scripts)',...
               'private (storage)',...
               'private (surgery package)'};

    % Add QUATTRO sub-directories to the parts cell
    n = 0;
    while length(qtParts)~=n
        n = length(qtParts);
        qtParts = add_parts(qtParts);
    end

    % Check/remove path
    cellfun(@(x) check_paths(x,qPath),qtParts,'UniformOutput',false);

    % Save the path
    if savepath
        fprintf('%s\n%s\n','Unable to save the current MATLAB path.',...
                'Run install_QUATTRO at every startup or edit path manually.');
    end

    % As a final measure, if the parent directory of QUATTRO.m is on the path,
    % remove the directory, too
    if ~isempty( strfind(path,qPath) )
        rmpath(qPath);
    end

    % Sub finction for adding sub-directories to the install cell
    function c_out = add_parts(c)

        for i = 1:length(c)
            local_path = fullfile(qPath,c{i});
            lst = dir(local_path);

            % Remove '.' and '..'
            nms = {lst.name};
            nm_ind = cellfun(@(x) any(strcmpi(x,{'.','..'})),nms);
            lst(nm_ind) = []; nms(nm_ind) = [];

            % Find directories
            dir_ind = cell2mat({lst.isdir});
            lst(~dir_ind) = []; nms(~dir_ind) = [];
            if isempty(lst)
                continue
            end

            % Remove private directories (MATLAB won't add them to the path)
            nms( strcmpi('private',nms) ) = [];
            if isempty(nms)
                continue
            end

            % Add directories to install list
            nms = cellfun(@(x) fullfile(c{i},x),nms,'UniformOutput',false);
            c = {c{:} nms{:}};
        end

        % Remove duplicats
        c_out = {};
        for i = length(c):-1:1
            if isempty(c_out)
                c_out{1} = c{i};
            elseif ~any(strcmpi(c_out,c{i}))
                c_out{end+1} = c{i};
            end
        end

    end %add_parts

    % Finally, remove the persistnet "isFired" flag in qt_startup
    if mislocked( fullfile(qPath,'qt_startup') )
        munlock( fullfile(qPath,'qt_startup') );
    end
    clear(fullfile(qPath,'qt_startup'));

end %uninstall_QUATTRO


% Sub function for installing paths
function check_paths(p,cp)
    fp = fullfile(cp,p);
    if any(strfind(fp,'@')) || any(strfind(fp,'+'))
        return
    end
    if exist(fp,'dir')==7
        try
            rmpath(fp); str_add = 'was removed successfully';
        catch ME
            str_add = ['install failed. ::error:: ' ME.message];
        end
    else
        return
%         str_add = 'Unable to locate directory.';
    end

    fprintf('%s\n',sprintf('%s %s',p,str_add));
end