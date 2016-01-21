function update_menu_scripts(hQt)
%update_menu_scripts  Updates the QUATTRO scripts menu
%
%   update_menu_scripts(H) updates the "Scripts" menu of the QUATTRO figure
%   specified by the handle H.

    % Get the qt_options object and the QUATTRO handles structure
    obj = getappdata(hQt,'qtOptsObject');
    hs  = guihandles(hQt);

    % Read all m-files in the scripts directory
    fList = gendirfiles(obj.scptDir,'m');

    % Find the static menus
    hStatic = [hs.import_script
               hs.delete_script
               hs.edit_script
               hs.new_script];

    % Determine if script names already exist
    hKids = get(hs.menu_scripts,'Children');
    hKids = hKids( arrayfun(@(x) all(x~=hStatic),hKids) ); %don't delete static menus
    if ~isempty(hKids)
        delete(hKids);
    end

    % Attempt to load the scripts
    for file = fList

        % Parse the file name and extension
        [~,fName] = fileparts(file{1});

        % Determine which file MATLAB calls when attempting to evaluate the
        % QUATTRO script. Notify the user of conflicts, but otherwise, allow the
        % script to be run.
        matFile = which(fName);
        if ~isempty(matFile) & ~strcmpi(matFile,file{1})
            warning(['QUATTRO:' mfilename ':mFileConflict'],...
                    ['The script "%s" conflicts with another script on MATLAB''s ',...
                     'search path - "%s". ',...
                     'The latter will be used until removed from the search ',...
                     'path. Please resolve this conflict to ensure that the ',...
                     'proper script is being run.\n'],file{1},matFile);
        end

        % Evaluating the script with no inputs should return the script name, if
        % not notify the user and ignore the file
        try
            scptName = eval(fName);
        catch ME
            if strcmpi(ME.identifier,'MATLAB:minrhs')
                warning('QUATTRO:scripts:nameChk',...
                         ['Invalid script syntax. See README.txt',...
                         '\n%s not loaded.\n'],fName);
            end
            continue
        end

        % Check script name and tooltip string
        if ~ischar(scptName) %script returned non-character data
            warning('QUATTRO:scripts:invalidScriptName',...
                                 ['An invalid script name was detected\n',...
                                  '%s not loaded'],file{1});
            continue
        end

        % Generate the menu
        hScptMenu   = uimenu('Parent',  hs.menu_scripts,...
                             'Callback',eval(['@' fName]),...
                             'Label',   scptName,...
                             'Tag',    ['script_' fName]);
        setappdata(hScptMenu,'fileName',fName);
    end

    % Reorder the menu items alphabetically
    hScptMenu = get(hs.menu_scripts,'Children');
    hScptMenu = hScptMenu(arrayfun(@(x) all(x~=hStatic),hScptMenu));
    if (numel(hScptMenu)>1)
        [~,idx]   = sort( get(hScptMenu(:),'Label') );
        hScptMenu = hScptMenu(idx(end:-1:1));
        set(hs.menu_scripts,'Children',[hScptMenu(:);hStatic(:)]);
    elseif isempty(hScptMenu) %no scripts were found
        set(hStatic(2),'Enable','off'); %disable when no scripts are available
        return
    end

    % Place the separator and enable the "Delete" menu
    set(hScptMenu(end),'Separator','on');
    set(hStatic(2),    'Enable','on');

end %update_menu_scripts