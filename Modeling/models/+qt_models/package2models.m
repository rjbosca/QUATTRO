function c = package2models(tag,cOpt)
%package2models  Convert a model package to a list of model names
%
%   C = package2models(TAG) determines all available models (i.e., modeling
%   class within a modeling package) for the package specified by the string
%   TAG. A cell array, C, of model names is returned
%
%   C = package2models(TAG,'classes') returns the name of the class definition
%   files instead of the model names

    narginchk(1,2);

    % Validate the input
    if (nargin>1)
        cOpt = validatestring(cOpt,{'classes'});
    else
        cOpt = 'names';
    end

    % Grab modeling classes
    mClasses = meta.package.fromName(qt_models.model2str(tag));
    cList    = {mClasses.ClassList.Name};

    % Get the modeling names from the constant property "modelName" from all
    % classes
    if strcmpi(cOpt,'names')
        c = cellfun(@(x) eval([x '.modelName']),cList,'UniformOutput',false);
    elseif strcmpi(cOpt,'classes')
        c = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),cList,...
                                                         'UniformOutput',false);
    end

end %package2models