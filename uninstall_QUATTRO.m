function uninstall_QUATTRO(varargin)
%intall_QUATTRO  Installs all necessary paths for QUATTRO to run
%
%   install_QUATTRO attempts to remove all components of QUATTRO

% Find current QUATTRO
qPath = which('QUATTRO');
if isempty(qPath)
    qPath = fileparts( mfilename('fullpath') );
    qPath = which('QUATTRO');
end
[qPath,fcn] = fileparts(qPath); %#ok<NASGU>
qPath = strrep(qPath,'''','''''');
if isempty(qPath) || ~exist(qPath,'dir')
    error(['QUATTRO:' mfilename ':fileChk'],...
               'Unable to locate QUATTRO directories. No actions performed...');
end

% Old versions of QUATTRO.m were stored in a sub-directory, remove the top layer
if ~isempty( strfind(qPath,'Core') ) || ~isempty( strfind(qPath,'gui main') )
    qPath = fileparts(qPath);
end

% List of subfolders (this includes older directory format subfolders, just in
% case...)
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

end %uninstall_QUATTRO

% Sub function for installing paths
function check_paths(p,cp)
    fp = fullfile(cp,p);
    if any(strfind(fp,'@'))
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