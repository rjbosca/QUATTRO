function s = model_info(varargin)
%model_info  Gets all model names from the qt_models package
%
%   S = model_info builds the structure S containg field names corresponding to
%   the model packages available in the qt_models package. Each model field
%   contains information about the respective model package
%
%   S = model_info(TYPE) builds the structure S as described previously for the
%   exam type specified by the string TYPE.

    narginchk(0,1);

    % Create a meta-package to get information about the qt_models package
    qtMod = meta.package.fromName('qt_models');
    qtMod = qtMod.PackageList;

    % Packages contained within +qt_models correspond to supported exam types.
    % Parse these exam types from the package name
    eTypes = {qtMod.Name};

    % Parse the user input (if any). The string 'qt_models.' must be appended to
    % the start of each string to ensure matching can be performed
    if nargin
        eNames = cellfun(@(x) strrep(x,'qt_models.',''),eTypes,...
                                                         'UniformOutput',false);
        eTypes = { ['qt_models.' validatestring(varargin{1},eNames)] };
    end

    % For each of the generic model packages, parse the contents, appending the
    % output structure
    s = struct([]);
    for eType = eTypes

        % Get the package contents
        ePkgs = meta.package.fromName(eType{1});
        eInfo = eval([ePkgs.Name '.package_info;']);

        % Parse the contents
        for ePkg = ePkgs.PackageList'
            pInfo = eval([ePkg.Name '.package_info;']);
            if isfield(s,pInfo.ContainingPackage)
                error(['QUATTRO:qt_models:' mfilename],...
                      ['Multiple model packages with the name "%s" exist in ',...
                       'the qt_models package. QUATTRO will not function ',...
                       'properly until all modeling packages have unique ',...
                       'names.'],pInfo.ContainingPackage)
            end
            s(1).(pInfo.ContainingPackage)           = pInfo;
            s(1).(pInfo.ContainingPackage).ModelInfo = eInfo;
        end
    end

end %model_info